; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
;
; RUN: llc -mtriple=riscv32 -mcpu=myriscv -verify-machineinstrs < %s \
; RUN:   | FileCheck %s

define i32 @pack(i32 %a, i32 %b) {
; CHECK-LABEL: pack:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pack a0, a0, a1
; CHECK-NEXT:    ret
  %low = and i32 %a, 65535
  %high = shl i32 %b, 16
  %result = or i32 %high, %low
  ret i32 %result
}

define i32 @packh(i32 %a, i32 %b) {
; CHECK-LABEL: packh:
; CHECK:       # %bb.0:
; CHECK-NEXT:    packh a0, a0, a1
; CHECK-NEXT:    ret
  %low = and i32 %a, 255
  %high = shl i32 %b, 8
  %maskedhigh = and i32 %high, 65280
  %result = or i32 %maskedhigh, %low
  ret i32 %result
}

define i32 @packb(i32 %a, i32 %b) {
; CHECK-LABEL: packb:
; CHECK:       # %bb.0:
; CHECK-NEXT:    packb a0, a0, a1
; CHECK-NEXT:    ret
  %low = and i32 %a, 255
  %high = shl i32 %b, 8
  %maskedhigh = and i32 %high, 65280
  %half = or i32 %maskedhigh, %low
  %repeat = shl i32 %half, 16
  %result = or i32 %repeat, %half
  ret i32 %result
}
