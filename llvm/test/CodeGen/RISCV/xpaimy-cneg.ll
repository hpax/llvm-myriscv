; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy -verify-machineinstrs < %s | FileCheck %s

; C: dividend < 0 ? -dividend : dividend
define i32 @signed_dividend_abs(i32 %dividend) {
; CHECK-LABEL: signed_dividend_abs:
; CHECK:       cneg a0, a0, a0
; CHECK-NEXT:  ret
  %negative = icmp slt i32 %dividend, 0
  %negated = sub i32 0, %dividend
  %absolute = select i1 %negative, i32 %negated, i32 %dividend
  ret i32 %absolute
}

; C: quotient_negative ? -magnitude : magnitude
define i32 @conditional_negate(i32 %sign, i32 %magnitude) {
; CHECK-LABEL: conditional_negate:
; CHECK:       cneg a0, a0, a1
; CHECK-NEXT:  ret
  %negative = icmp slt i32 %sign, 0
  %negated = sub i32 0, %magnitude
  %result = select i1 %negative, i32 %negated, i32 %magnitude
  ret i32 %result
}

; C: dividend < 0 ? dividend : -dividend
define i32 @negated_signed_dividend_abs(i32 %dividend) {
; CHECK-LABEL: negated_signed_dividend_abs:
; CHECK:       cnegn a0, a0, a0
; CHECK-NEXT:  ret
  %negative = icmp slt i32 %dividend, 0
  %negated = sub i32 0, %dividend
  %result = select i1 %negative, i32 %dividend, i32 %negated
  ret i32 %result
}

; C: dividend < 0 ? -1 : 1
define i32 @signed_dividend_sign(i32 %dividend) {
; CHECK-LABEL: signed_dividend_sign:
; CHECK:       cnegi a0, a0, 1
; CHECK-NEXT:  ret
  %negative = icmp slt i32 %dividend, 0
  %sign = select i1 %negative, i32 -1, i32 1
  ret i32 %sign
}

; C-like restoring-division quotient-bit correction:
; quotient = (quotient << 1) | (remainder >= divisor);
define i32 @udiv_quotient_correction(i32 %quotient, i32 %remainder,
                                      i32 %divisor) {
; CHECK-LABEL: udiv_quotient_correction:
; CHECK:       sgeu [[BIT:a[0-7]]], a1, a2
; CHECK:       slli a0, a0, 1
; CHECK:       or a0, a0, [[BIT]]
; CHECK-NEXT:  ret
  %fits = icmp uge i32 %remainder, %divisor
  %bit = zext i1 %fits to i32
  %shifted = shl i32 %quotient, 1
  %next = or i32 %shifted, %bit
  ret i32 %next
}
