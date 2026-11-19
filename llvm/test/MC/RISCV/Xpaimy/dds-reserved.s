# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple=riscv32 -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy - | FileCheck %s

# The decimal encoding reserves imm2 values 1 through 3.
.insn 4, 0x1ac5e52b
.insn 4, 0x1cc5e52b
.insn 4, 0x1ec5e52b
# CHECK: 1ac5e52b <unknown>
# CHECK: 1cc5e52b <unknown>
# CHECK: 1ec5e52b <unknown>
