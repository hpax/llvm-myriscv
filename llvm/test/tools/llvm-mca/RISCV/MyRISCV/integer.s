# Copyright (c) 2026 H. Peter Anvin
# RUN: llvm-mca -mtriple=riscv32 -mcpu=myriscv -instruction-tables < %s | FileCheck %s

# The MyRISCV pipeline is single issue. ALU results are available after E;
# loads and multiplies are available after M.
add a0, a1, a2
lw a0, 0(a1)
mul a0, a1, a2

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     1.00                        add
# CHECK-NEXT:  1      2     1.00    *                   lw
# CHECK-NEXT:  1      2     1.00                        mul
