# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple=riscv32 -mattr=+f,+xpaimy -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+f,+xpaimy - \
# RUN:   | FileCheck %s

fmadd.s fa0, fa1, fa2, fa3, rne
# CHECK: fmadd.s fa0, fa1, fa2, fa3, rne
