; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy -verify-machineinstrs < %s | FileCheck %s

; C: (x >> 5) & 7
define i32 @extract_unsigned(i32 %x) {
; CHECK-LABEL: extract_unsigned:
; CHECK:       extrui a0, a0, 5, 3
; CHECK-NEXT:  ret
  %shifted = lshr i32 %x, 5
  %field = and i32 %shifted, 7
  ret i32 %field
}

; C: (x << (32 - 13)) >> (32 - 13)
define i32 @extract_signed(i32 %x) {
; CHECK-LABEL: extract_signed:
; CHECK:       extrsi a0, a0, 0, 13
; CHECK-NEXT:  ret
  %shifted = shl i32 %x, 19
  %field = ashr exact i32 %shifted, 19
  ret i32 %field
}

; C: (x << (32 - width)) >> (32 - width)
define i32 @extend_signed(i32 %x, i32 %width) {
; CHECK-LABEL: extend_signed:
; CHECK:       sext a0, a0, a1
; CHECK-NEXT:  ret
  %shift = sub i32 32, %width
  %shifted = shl i32 %x, %shift
  %field = ashr exact i32 %shifted, %shift
  ret i32 %field
}

; C: signed 3-bit field at bit 5
define i32 @extract_offset_signed(i32 %x) {
; CHECK-LABEL: extract_offset_signed:
; CHECK:       extrsi a0, a0, 5, 3
; CHECK-NEXT:  ret
  %shifted = shl i32 %x, 24
  %field = ashr exact i32 %shifted, 29
  ret i32 %field
}
