# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple=riscv32 -mcpu=myriscv -show-encoding < %s \
# RUN:   | FileCheck %s --check-prefixes=INST,ENC
# RUN: llvm-mc -triple=riscv32 -mattr=+xpaimy -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy --no-print-imm-hex - \
# RUN:   | FileCheck %s --check-prefix=INST
# RUN: not llvm-mc -triple=riscv32 < %s 2>&1 \
# RUN:   | FileCheck %s --check-prefix=ERR

dds.b a0, a1, a2, 0
# INST: dds.b a0, a1, a2, 0
# ENC-SAME: encoding: [0x2b,0xe5,0xc5,0x10]
# ERR: :[[@LINE-3]]:1: error: instruction requires the following: 'Xpaimy'

dds.b a0, a1, a2, 1
# INST: dds.b a0, a1, a2, 1
# ENC-SAME: encoding: [0x2b,0xe5,0xc5,0x12]
# ERR: :[[@LINE-3]]:1: error: instruction requires the following: 'Xpaimy'

dds.b a0, a1, a2, 2
# INST: dds.b a0, a1, a2, 2
# ENC-SAME: encoding: [0x2b,0xe5,0xc5,0x14]
# ERR: :[[@LINE-3]]:1: error: instruction requires the following: 'Xpaimy'

dds.b a0, a1, a2, 3
# INST: dds.b a0, a1, a2, 3
# ENC-SAME: encoding: [0x2b,0xe5,0xc5,0x16]
# ERR: :[[@LINE-3]]:1: error: instruction requires the following: 'Xpaimy'

dds.d a0, a1, a2
# INST: dds.d a0, a1, a2
# ENC-SAME: encoding: [0x2b,0xe5,0xc5,0x18]
# ERR: :[[@LINE-3]]:1: error: instruction requires the following: 'Xpaimy'
