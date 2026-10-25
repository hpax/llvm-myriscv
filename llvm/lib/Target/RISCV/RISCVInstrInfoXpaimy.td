//===-- RISCVInstrInfoXpaimy.td - MyRISCV instructions --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
//
//===----------------------------------------------------------------------===//
//
// MyRISCV vendor instruction definitions.
//
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
class MyRISCVCustomR<bits<7> funct7, bits<3> funct3, string mnemonic>
    : RVInstR<funct7, funct3, OPC_CUSTOM_1, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2), mnemonic, "$rd, $rs1, $rs2"> {
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVStdALURR<bits<7> funct7, bits<3> funct3, string mnemonic>
    : ALU_rr<funct7, funct3, mnemonic> {
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVStdShift<bits<5> imm11_7, bits<3> funct3, string mnemonic>
    : Shift_ri<imm11_7, funct3, mnemonic> {
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVStdUnary<bits<12> imm12, bits<3> funct3, string mnemonic>
    : Unary_r<imm12, funct3, mnemonic> {
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVBranch<bits<3> funct3, string mnemonic>
    : BranchCC_rri<funct3, mnemonic> {
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVCustomI<bits<3> funct3, string mnemonic>
    : RVInstI<funct3, OPC_CUSTOM_0, (outs GPR:$rd),
              (ins GPR:$rs1, simm12_lo:$imm12), mnemonic,
              "$rd, $rs1, $imm12"> {
  let DecoderNamespace = "MyRISCV";
}

class MyRISCVExtractR<bits<2> kind, string mnemonic>
    : RVInstR<0, 0b101, OPC_CUSTOM_1, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2, uimm5:$width), mnemonic,
              "$rd, $rs1, $rs2, $width"> {
  bits<5> width;
  let Inst{31-30} = kind;
  let Inst{29-25} = width;
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVExtractI<bits<2> kind, string mnemonic>
    : RVInstI<0b101, OPC_CUSTOM_0, (outs GPR:$rd),
              (ins GPR:$rs1, uimmlog2xlen:$shift, uimm5:$width), mnemonic,
              "$rd, $rs1, $shift, $width"> {
  bits<5> shift;
  bits<5> width;
  let Inst{31-30} = kind;
  let Inst{29-25} = width;
  let Inst{24-20} = shift;
  let DecoderNamespace = "MyRISCV";
}
class MyRISCVExtend<bits<2> kind, string mnemonic>
    : RVInstR<0, 0b111, OPC_CUSTOM_1, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2), mnemonic, "$rd, $rs1, $rs2"> {
  let Inst{31-30} = kind;
  let DecoderNamespace = "MyRISCV";
}
}

let Predicates = [HasVendorXpaimy] in {
def SH1SUB : MyRISCVStdALURR<0b0110000, 0b010, "sh1sub">;
def SH2SUB : MyRISCVStdALURR<0b0110000, 0b100, "sh2sub">;
def SH3SUB : MyRISCVStdALURR<0b0110000, 0b110, "sh3sub">;

def CLO   : MyRISCVStdUnary<0b011000010000, 0b001, "clo">;
def CTO   : MyRISCVStdUnary<0b011000010001, 0b001, "cto">;
def CPOPZ : MyRISCVStdUnary<0b011000010010, 0b001, "cpopz">;

def SLO  : MyRISCVStdALURR<0b1000000, 0b001, "slo">;
def SRO  : MyRISCVStdALURR<0b1000000, 0b101, "sro">;
def SRCS : MyRISCVStdALURR<0b1100000, 0b101, "srcs">;
def SLOI  : MyRISCVStdShift<0b10000, 0b001, "sloi">;
def SROI  : MyRISCVStdShift<0b10000, 0b101, "sroi">;
def SRCSI : MyRISCVStdShift<0b11000, 0b101, "srcsi">;

def SGE  : MyRISCVStdALURR<0b0000010, 0b010, "sge">;
def SEQ  : MyRISCVStdALURR<0b0000001, 0b010, "seq">;
def SNE  : MyRISCVStdALURR<0b0000011, 0b010, "sne">;
def SGEU : MyRISCVStdALURR<0b0000010, 0b011, "sgeu">;
def SAEQZ : MyRISCVStdALURR<0b0000001, 0b011, "saeqz">;
def SANEZ : MyRISCVStdALURR<0b0000011, 0b011, "sanez">;

def BAEQZ : MyRISCVBranch<0b010, "baeqz">;
def BANEZ : MyRISCVBranch<0b011, "banez">;

def EXTRU   : MyRISCVExtractR<0b00, "extru">;
def EXTRS   : MyRISCVExtractR<0b01, "extrs">;
def EXTRO   : MyRISCVExtractR<0b10, "extro">;
def EXTRCS  : MyRISCVExtractR<0b11, "extrcs">;
def EXTRUI  : MyRISCVExtractI<0b00, "extrui">;
def EXTRSI  : MyRISCVExtractI<0b01, "extrsi">;
def EXTROI  : MyRISCVExtractI<0b10, "extroi">;
def EXTRCSI : MyRISCVExtractI<0b11, "extrcsi">;

def ZEXT  : MyRISCVExtend<0b00, "zext">;
def SEXT  : MyRISCVExtend<0b01, "sext">;
def OEXT  : MyRISCVExtend<0b10, "oext">;
def CSEXT : MyRISCVExtend<0b11, "csext">;

def CNEG  : MyRISCVCustomR<0b0000000, 0b110, "cneg">;
def CNEGN : MyRISCVCustomR<0b0100000, 0b110, "cnegn">;
def CNEGI : MyRISCVCustomI<0b110, "cnegi">;

def C_ECALL : RVInst16CR<0b1000, OPC_C2, (outs), (ins), "c.ecall", "">,
              Sched<[]> {
  let rs1 = 0;
  let rs2 = 0;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let DecoderNamespace = "MyRISCV";
}

def : PatGpr<int_riscv_myriscv_clo, CLO>;
def : PatGpr<int_riscv_myriscv_cto, CTO>;
def : PatGpr<int_riscv_myriscv_cpopz, CPOPZ>;
def : Pat<(sub (shl GPR:$rs1, (i32 1)), GPR:$rs2),
          (SH1SUB GPR:$rs1, GPR:$rs2)>;
def : Pat<(sub (shl GPR:$rs1, (i32 2)), GPR:$rs2),
          (SH2SUB GPR:$rs1, GPR:$rs2)>;
def : Pat<(sub (shl GPR:$rs1, (i32 3)), GPR:$rs2),
          (SH3SUB GPR:$rs1, GPR:$rs2)>;
}

let hasSideEffects = 1, mayLoad = 0, mayStore = 0,
    Predicates = [HasVendorXpasmy] in {
class MyRISCVContextR<bits<2> kind, bits<3> funct3, string mnemonic>
    : RVInstR<0, funct3, OPC_CUSTOM_1, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2, uimm5:$context), mnemonic,
              "$rd, $rs1, $rs2, $context"> {
  bits<5> context;
  let Inst{31-30} = kind;
  let Inst{29-25} = context;
  let DecoderNamespace = "MyRISCVMicro";
}
class MyRISCVSystemR<bits<7> funct7, bits<3> funct3, string mnemonic>
    : RVInstR<funct7, funct3, OPC_CUSTOM_1, (outs GPR:$rd),
              (ins GPR:$rs1, GPR:$rs2), mnemonic, "$rd, $rs1, $rs2"> {
  let DecoderNamespace = "MyRISCVMicro";
}

def ADD_XU : MyRISCVSystemR<0b0000000, 0b000, "add.xu">;
def SUB_XU : MyRISCVSystemR<0b0100000, 0b000, "sub.xu">;
def ADD_UX : MyRISCVSystemR<0b0000000, 0b001, "add.ux">;
def SUB_UX : MyRISCVSystemR<0b0100000, 0b001, "sub.ux">;
def ADD_XC : MyRISCVContextR<0b10, 0b000, "add.xc">;
def SUB_XC : MyRISCVContextR<0b11, 0b000, "sub.xc">;
def ADD_CX : MyRISCVContextR<0b10, 0b001, "add.cx">;
def SUB_CX : MyRISCVContextR<0b11, 0b001, "sub.cx">;
def ADD_SU : MyRISCVSystemR<0b0000000, 0b011, "add.su">;
def SUB_SU : MyRISCVSystemR<0b0100000, 0b011, "sub.su">;
def ADD_SC : MyRISCVContextR<0b10, 0b011, "add.sc">;
def SUB_SC : MyRISCVContextR<0b11, 0b011, "sub.sc">;
}
