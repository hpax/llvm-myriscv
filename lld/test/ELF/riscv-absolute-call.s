# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
# REQUIRES: riscv
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+relax %s -o %t.o
# RUN: ld.lld --relax --image-base=0 -Ttext=0x29a %t.o -o %t.relax
# RUN: ld.lld --no-relax --image-base=0 -Ttext=0x29a %t.o -o %t.norelax
# RUN: llvm-objdump -d --no-show-raw-insn -M no-aliases %t.relax | \
# RUN:   FileCheck %s
# RUN: llvm-objdump -d --no-show-raw-insn -M no-aliases %t.norelax | \
# RUN:   FileCheck %s

# CHECK:      <_start>:
# CHECK-NEXT: auipc ra, 0x40000
# CHECK-NEXT: jalr ra, -0x29c(ra)

target = 0x40000000
.globl _start
_start:
  call target
