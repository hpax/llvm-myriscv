# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple=riscv32 -mcpu=myriscv -show-encoding < %s \
# RUN:   | FileCheck %s --check-prefixes=INST,ENC
# RUN: llvm-mc -triple=riscv32 -mcpu=myriscv -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy --no-print-imm-hex - \
# RUN:   | FileCheck %s --check-prefix=DIS
# RUN: not llvm-mc -triple=riscv32 -show-encoding < %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=ERR
# RUN: not llvm-mc -triple=riscv32 -mattr=+f,+xpaimy -show-encoding < %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=FERR

beq.pt a0, a1, 8
# INST: beq.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x04,0xb5,0x00]
# DIS: beq.pt a0, a1,
# ERR: error: instruction requires the following: 'Xpaimy'
# FERR: error: instruction requires the following: 'Xpaimy' without 'F'
beq.pn a0, a1, 8
# INST: beq.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x04,0xb5,0x00]
# DIS: beq.pn a0, a1,
bne.pt a0, a1, 8
# INST: bne.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x14,0xb5,0x00]
# DIS: bne.pt a0, a1,
bne.pn a0, a1, 8
# INST: bne.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x14,0xb5,0x00]
# DIS: bne.pn a0, a1,
baeqz.pt a0, a1, 8
# INST: baeqz.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x24,0xb5,0x00]
# DIS: baeqz.pt a0, a1,
baeqz.pn a0, a1, 8
# INST: baeqz.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x24,0xb5,0x00]
# DIS: baeqz.pn a0, a1,
banez.pt a0, a1, 8
# INST: banez.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x34,0xb5,0x00]
# DIS: banez.pt a0, a1,
banez.pn a0, a1, 8
# INST: banez.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x34,0xb5,0x00]
# DIS: banez.pn a0, a1,
blt.pt a0, a1, 8
# INST: blt.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x44,0xb5,0x00]
# DIS: blt.pt a0, a1,
blt.pn a0, a1, 8
# INST: blt.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x44,0xb5,0x00]
# DIS: blt.pn a0, a1,
bge.pt a0, a1, 8
# INST: bge.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x54,0xb5,0x00]
# DIS: bge.pt a0, a1,
bge.pn a0, a1, 8
# INST: bge.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x54,0xb5,0x00]
# DIS: bge.pn a0, a1,
bltu.pt a0, a1, 8
# INST: bltu.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x64,0xb5,0x00]
# DIS: bltu.pt a0, a1,
bltu.pn a0, a1, 8
# INST: bltu.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x64,0xb5,0x00]
# DIS: bltu.pn a0, a1,
bgeu.pt a0, a1, 8
# INST: bgeu.pt a0, a1, 8
# ENC-SAME: encoding: [0x43,0x74,0xb5,0x00]
# DIS: bgeu.pt a0, a1,
bgeu.pn a0, a1, 8
# INST: bgeu.pn a0, a1, 8
# ENC-SAME: encoding: [0x47,0x74,0xb5,0x00]
# DIS: bgeu.pn a0, a1,
