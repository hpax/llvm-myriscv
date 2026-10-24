//===-- RISCVSchedMyRISCV.td - MyRISCV Scheduling Definitions -*- tablegen -*-===//
//
// Copyright (c) 2026 H. Peter Anvin
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// MyRISCV is a single-issue, in-order RV32 pipeline. Integer operations
// produce their results in E; loads and multiplies produce their results in M.
def MyRISCVModel : SchedMachineModel {
  let MicroOpBufferSize = 0;
  let IssueWidth = 1;
  let LoadLatency = 2;
  let MispredictPenalty = 6;
  let CompleteModel = 0;
  let UnsupportedFeatures = [HasVInstructions];
}

let SchedModel = MyRISCVModel in {
let BufferSize = 0 in {
def MyRISCVALU : ProcResource<1>;
def MyRISCVLSU : ProcResource<1>;
def MyRISCVMul : ProcResource<1>;
def MyRISCVBranch : ProcResource<1>;
}

// Branches resolve in E.
def : WriteRes<WriteJmp, [MyRISCVBranch]>;
def : WriteRes<WriteJal, [MyRISCVBranch]>;
def : WriteRes<WriteJalr, [MyRISCVBranch]>;

// Integer arithmetic and logic complete in E.
def : WriteRes<WriteIALU32, [MyRISCVALU]>;
def : WriteRes<WriteIALU, [MyRISCVALU]>;
def : WriteRes<WriteShiftImm32, [MyRISCVALU]>;
def : WriteRes<WriteShiftImm, [MyRISCVALU]>;
def : WriteRes<WriteShiftReg32, [MyRISCVALU]>;
def : WriteRes<WriteShiftReg, [MyRISCVALU]>;
def : WriteRes<WriteSHXADD, [MyRISCVALU]>;
def : WriteRes<WriteSHXADD32, [MyRISCVALU]>;
def : WriteRes<WriteRotateImm, [MyRISCVALU]>;
def : WriteRes<WriteRotateImm32, [MyRISCVALU]>;
def : WriteRes<WriteRotateReg, [MyRISCVALU]>;
def : WriteRes<WriteRotateReg32, [MyRISCVALU]>;
def : WriteRes<WriteCLZ, [MyRISCVALU]>;
def : WriteRes<WriteCLZ32, [MyRISCVALU]>;
def : WriteRes<WriteCTZ, [MyRISCVALU]>;
def : WriteRes<WriteCTZ32, [MyRISCVALU]>;
def : WriteRes<WriteCPOP, [MyRISCVALU]>;
def : WriteRes<WriteCPOP32, [MyRISCVALU]>;
def : WriteRes<WriteREV8, [MyRISCVALU]>;
def : WriteRes<WriteORCB, [MyRISCVALU]>;
def : WriteRes<WriteIMinMax, [MyRISCVALU]>;
def : WriteRes<WriteSingleBit, [MyRISCVALU]>;
def : WriteRes<WriteSingleBitImm, [MyRISCVALU]>;
def : WriteRes<WriteBEXT, [MyRISCVALU]>;
def : WriteRes<WriteBEXTI, [MyRISCVALU]>;

// The default MyRISCV configuration implements Zmmul, not M.
let Unsupported = true in {
def : WriteRes<WriteIDiv, [MyRISCVALU]>;
def : WriteRes<WriteIDiv32, [MyRISCVALU]>;
def : WriteRes<WriteIRem, [MyRISCVALU]>;
def : WriteRes<WriteIRem32, [MyRISCVALU]>;
}

// Multiplies and loads produce their results in M, one cycle after E.
let Latency = 2 in {
def : WriteRes<WriteIMul, [MyRISCVMul]>;
def : WriteRes<WriteIMul32, [MyRISCVMul]>;
def : WriteRes<WriteLDB, [MyRISCVLSU]>;
def : WriteRes<WriteLDH, [MyRISCVLSU]>;
def : WriteRes<WriteLDW, [MyRISCVLSU]>;
def : WriteRes<WriteLDD, [MyRISCVLSU]>;
}

def : WriteRes<WriteSTB, [MyRISCVLSU]>;
def : WriteRes<WriteSTH, [MyRISCVLSU]>;
def : WriteRes<WriteSTW, [MyRISCVLSU]>;
def : WriteRes<WriteSTD, [MyRISCVLSU]>;

let Latency = 2 in {
def : WriteRes<WriteAtomicB, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicH, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicW, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicD, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicLDW, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicLDD, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicSTW, [MyRISCVLSU]>;
def : WriteRes<WriteAtomicSTD, [MyRISCVLSU]>;
}

def : WriteRes<WriteCSR, [MyRISCVALU]>;
def : WriteRes<WriteNop, []>;

def : InstRW<[WriteIALU], (instrs COPY)>;

// Inputs are consumed in E. The write latencies above model the E and M
// forwarding paths.
def : ReadAdvance<ReadJmp, 0>;
def : ReadAdvance<ReadJalr, 0>;
def : ReadAdvance<ReadCSR, 0>;
def : ReadAdvance<ReadStoreData, 0>;
def : ReadAdvance<ReadMemBase, 0>;
def : ReadAdvance<ReadIALU, 0>;
def : ReadAdvance<ReadIALU32, 0>;
def : ReadAdvance<ReadShiftImm, 0>;
def : ReadAdvance<ReadShiftImm32, 0>;
def : ReadAdvance<ReadShiftReg, 0>;
def : ReadAdvance<ReadShiftReg32, 0>;
def : ReadAdvance<ReadSHXADD, 0>;
def : ReadAdvance<ReadSHXADD32, 0>;
def : ReadAdvance<ReadRotateImm, 0>;
def : ReadAdvance<ReadRotateImm32, 0>;
def : ReadAdvance<ReadRotateReg, 0>;
def : ReadAdvance<ReadRotateReg32, 0>;
def : ReadAdvance<ReadCLZ, 0>;
def : ReadAdvance<ReadCLZ32, 0>;
def : ReadAdvance<ReadCTZ, 0>;
def : ReadAdvance<ReadCTZ32, 0>;
def : ReadAdvance<ReadCPOP, 0>;
def : ReadAdvance<ReadCPOP32, 0>;
def : ReadAdvance<ReadREV8, 0>;
def : ReadAdvance<ReadORCB, 0>;
def : ReadAdvance<ReadIMinMax, 0>;
def : ReadAdvance<ReadSingleBit, 0>;
def : ReadAdvance<ReadSingleBitImm, 0>;
def : ReadAdvance<ReadIDiv, 0>;
def : ReadAdvance<ReadIDiv32, 0>;
def : ReadAdvance<ReadIRem, 0>;
def : ReadAdvance<ReadIRem32, 0>;
def : ReadAdvance<ReadIMul, 0>;
def : ReadAdvance<ReadIMul32, 0>;
def : ReadAdvance<ReadAtomicBA, 0>;
def : ReadAdvance<ReadAtomicBD, 0>;
def : ReadAdvance<ReadAtomicHA, 0>;
def : ReadAdvance<ReadAtomicHD, 0>;
def : ReadAdvance<ReadAtomicWA, 0>;
def : ReadAdvance<ReadAtomicWD, 0>;
def : ReadAdvance<ReadAtomicDA, 0>;
def : ReadAdvance<ReadAtomicDD, 0>;
def : ReadAdvance<ReadAtomicLDW, 0>;
def : ReadAdvance<ReadAtomicLDD, 0>;
def : ReadAdvance<ReadAtomicSTW, 0>;
def : ReadAdvance<ReadAtomicSTD, 0>;

defm : UnsupportedSchedF;
defm : UnsupportedSchedSFB;
defm : UnsupportedSchedV;
defm : UnsupportedSchedZbc;
defm : UnsupportedSchedZbkb;
defm : UnsupportedSchedZbkx;
defm : UnsupportedSchedZfa;
defm : UnsupportedSchedZvk;
defm : UnsupportedSchedXsf;
}
