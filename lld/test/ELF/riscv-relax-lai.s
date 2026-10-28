# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
# REQUIRES: riscv
# RUN: rm -rf %t && split-file %s %t
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax,+xpaimy \
# RUN:   %t/xpaimy.s -o %t/xpaimy.o
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax %t/base.s -o %t/base.o
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax,+xpaimy \
# RUN:   %t/odd.s -o %t/odd.o
# RUN: ld.lld --relax --image-base=0 -Ttext=0 %t/xpaimy.o -o %t/xpaimy
# RUN: ld.lld --relax --image-base=0 -Ttext=0 %t/base.o -o %t/base
# RUN: ld.lld --relax --image-base=0 -Ttext=0 %t/odd.o -o %t/odd
# RUN: llvm-objdump -d --no-show-raw-insn --mattr=+xpaimy %t/xpaimy | \
# RUN:   FileCheck %s --check-prefix=XPAIMY
# RUN: llvm-objdump -d --no-show-raw-insn %t/base | FileCheck %s --check-prefix=BASE
# RUN: llvm-objdump -d --no-show-raw-insn --mattr=+xpaimy %t/odd | \
# RUN:   FileCheck %s --check-prefix=ODD

# XPAIMY:      <_start>:
# XPAIMY-NEXT: lai a0, 0x4
# XPAIMY:      <target>:
# XPAIMY-NEXT: nop

# BASE:      <_start>:
# BASE-NEXT: auipc a0, 0x0
# BASE-NEXT: addi a0, a0, 0x8
# BASE:      <target>:
# BASE-NEXT: nop

# ODD:      <_start>:
# ODD-NEXT: lai a0, 0x5

#--- xpaimy.s
.attribute arch, "rv32i2p1_xpaimy1p0"
.globl _start
_start:
  la a0, target
target:
  nop

#--- odd.s
.attribute arch, "rv32i2p1_xpaimy1p0"
.globl _start
_start:
  la a0, target
  .byte 0
target:
  nop

#--- base.s
.globl _start
_start:
  la a0, target
target:
  nop
