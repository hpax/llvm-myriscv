# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: not llvm-mc -triple=riscv32 -mattr=+xpaimy < %s 2>&1 \
# RUN:   | FileCheck %s

dds.b a0, a1, a2, -1
# CHECK: :[[@LINE-1]]:19: error: immediate must be an integer in the range [0, 3]
dds.b a0, a1, a2, 4
# CHECK: :[[@LINE-1]]:19: error: immediate must be an integer in the range [0, 3]
dds.b a0, a1, a2
# CHECK: :[[@LINE-1]]:17: error: too few operands for instruction
dds.d a0, a1, a2, 0
# CHECK: :[[@LINE-1]]:19: error: unexpected extra operand for instruction
