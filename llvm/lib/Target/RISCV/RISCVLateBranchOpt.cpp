//===-- RISCVLateBranchOpt.cpp - Late Stage Branch Optimization -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
//
//===----------------------------------------------------------------------===//
///
/// This file provides RISC-V-specific late branch optimizations, including
/// folding statically evaluable conditions and selecting branch hints from
/// profile data.
///
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVInstrInfo.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/MachineBranchProbabilityInfo.h"
#include "llvm/CodeGen/MachineFunctionAnalysisManager.h"
#include "llvm/CodeGen/MachinePassManager.h"
#include "llvm/IR/Analysis.h"

using namespace llvm;

#define RISCV_LATE_BRANCH_OPT_NAME "RISC-V Late Branch Optimisation Pass"

namespace {

struct RISCVLateBranchOptLegacy : public MachineFunctionPass {
  static char ID;

  RISCVLateBranchOptLegacy() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override { return RISCV_LATE_BRANCH_OPT_NAME; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &Fn) override;
};
} // namespace

char RISCVLateBranchOptLegacy::ID = 0;
INITIALIZE_PASS(RISCVLateBranchOptLegacy, "riscv-late-branch-opt",
                RISCV_LATE_BRANCH_OPT_NAME, false, false)

static bool runLateBranchOptOnMBB(MachineBasicBlock &MBB,
                                  const RISCVInstrInfo *RII) {
  MachineBasicBlock *TBB, *FBB;
  SmallVector<MachineOperand, 4> Cond;
  if (RII->analyzeBranch(MBB, TBB, FBB, Cond, /*AllowModify=*/false))
    return false;

  if (!TBB || Cond.size() != 3)
    return false;

  RISCVCC::CondCode CC = RISCVInstrInfo::getCondFromBranchOpc(Cond[0].getImm());
  if (CC == RISCVCC::COND_INVALID)
    return false;

  MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();

  // Try and convert a conditional branch that can be evaluated statically
  // into an unconditional branch.
  int64_t C0, C1;
  if (!RISCVInstrInfo::isFromLoadImm(MRI, Cond[1], C0) ||
      !RISCVInstrInfo::isFromLoadImm(MRI, Cond[2], C1))
    return false;

  MachineBasicBlock *Folded =
      RISCVInstrInfo::evaluateCondBranch(CC, C0, C1) ? TBB : FBB;

  // At this point, its legal to optimize.
  RII->removeBranch(MBB);

  // Only need to insert a branch if we're not falling through.
  if (Folded) {
    DebugLoc DL = MBB.findBranchDebugLoc();
    RII->insertBranch(MBB, Folded, nullptr, {}, DL);
  }

  // Update the successors. Remove them all and add back the correct one.
  while (!MBB.succ_empty())
    MBB.removeSuccessor(MBB.succ_end() - 1);

  // If it's a fallthrough, we need to figure out where MBB is going.
  if (!Folded) {
    MachineFunction::iterator Fallthrough = ++MBB.getIterator();
    if (Fallthrough != MBB.getParent()->end())
      MBB.addSuccessor(&*Fallthrough);
  } else
    MBB.addSuccessor(Folded);

  return true;
}

static unsigned getBranchHintOpcode(unsigned Opc, bool PredictTaken) {
  switch (Opc) {
  default:
    return Opc;
  case RISCV::BEQ:
    return PredictTaken ? RISCV::BEQ_PT : RISCV::BEQ_PN;
  case RISCV::BNE:
    return PredictTaken ? RISCV::BNE_PT : RISCV::BNE_PN;
  case RISCV::BLT:
    return PredictTaken ? RISCV::BLT_PT : RISCV::BLT_PN;
  case RISCV::BGE:
    return PredictTaken ? RISCV::BGE_PT : RISCV::BGE_PN;
  case RISCV::BLTU:
    return PredictTaken ? RISCV::BLTU_PT : RISCV::BLTU_PN;
  case RISCV::BGEU:
    return PredictTaken ? RISCV::BGEU_PT : RISCV::BGEU_PN;
  case RISCV::BAEQZ:
    return PredictTaken ? RISCV::BAEQZ_PT : RISCV::BAEQZ_PN;
  case RISCV::BANEZ:
    return PredictTaken ? RISCV::BANEZ_PT : RISCV::BANEZ_PN;
  }
}

static bool addBranchHint(MachineBasicBlock &MBB, const RISCVInstrInfo *RII,
                          const MachineBranchProbabilityInfo &MBPI) {
  MachineBasicBlock *TBB = nullptr, *FBB = nullptr;
  SmallVector<MachineOperand, 4> Cond;
  if (RII->analyzeBranch(MBB, TBB, FBB, Cond, /*AllowModify=*/false) || !TBB ||
      Cond.size() != 3)
    return false;

  const BranchProbability TakenProb = MBPI.getEdgeProbability(&MBB, TBB);
  // Avoid turning weak profile information into a static prediction.
  const BranchProbability Threshold(4, 5);
  bool PredictTaken;
  if (TakenProb >= Threshold)
    PredictTaken = true;
  else if (TakenProb <= Threshold.getCompl())
    PredictTaken = false;
  else
    return false;

  const unsigned OldOpc = Cond[0].getImm();
  const unsigned NewOpc = getBranchHintOpcode(OldOpc, PredictTaken);
  if (NewOpc == OldOpc)
    return false;

  for (MachineInstr &MI : MBB.terminators()) {
    if (MI.getOpcode() == OldOpc && MI.getNumExplicitOperands() == 3 &&
        MI.getOperand(2).isMBB() && MI.getOperand(2).getMBB() == TBB) {
      MI.setDesc(RII->get(NewOpc));
      return true;
    }
  }
  return false;
}

static bool runLateBranchOptOnMF(MachineFunction &Fn) {
  auto &ST = Fn.getSubtarget<RISCVSubtarget>();
  const RISCVInstrInfo *RII = ST.getInstrInfo();

  bool Changed = false;
  for (MachineBasicBlock &MBB : Fn)
    Changed |= runLateBranchOptOnMBB(MBB, RII);

  if (!ST.hasVendorXpaimy() || ST.hasStdExtF() ||
      !Fn.getFunction().hasProfileData())
    return Changed;

  MachineBranchProbabilityInfo MBPI;
  for (MachineBasicBlock &MBB : Fn)
    Changed |= addBranchHint(MBB, RII, MBPI);
  return Changed;
}

FunctionPass *llvm::createRISCVLateBranchOptLegacyPass() {
  return new RISCVLateBranchOptLegacy();
}

bool RISCVLateBranchOptLegacy::runOnMachineFunction(MachineFunction &MF) {
  if (skipFunction(MF.getFunction()))
    return false;
  return runLateBranchOptOnMF(MF);
}

PreservedAnalyses
RISCVLateBranchOptPass::run(MachineFunction &MF,
                            MachineFunctionAnalysisManager &MFAM) {
  return runLateBranchOptOnMF(MF) ? getMachineFunctionPassPreservedAnalyses()
                                  : PreservedAnalyses::all();
}
