; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
;
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mcpu=myriscv < %s | FileCheck %s

define i32 @genmask(i32 %bits) {
; CHECK-LABEL: genmask:
; CHECK:       slo a0, zero, a0
; CHECK-NEXT:  ret
  %shift = shl i32 -1, %bits
  %mask = xor i32 %shift, -1
  ret i32 %mask
}
