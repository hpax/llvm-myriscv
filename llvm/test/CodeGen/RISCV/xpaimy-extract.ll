; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mattr=-xpaimy -verify-machineinstrs < %s | FileCheck %s --check-prefix=BASE
; RUN: llc -mtriple=riscv64 -mattr=+xpaimy -verify-machineinstrs < %s | FileCheck %s --check-prefix=BASE

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

define i32 @extract_variable_aligned(i32 %x, i32 %amount) {
; CHECK-LABEL: extract_variable_aligned:
; CHECK:       andi a1, a1, 28
; CHECK-NEXT:  extru a0, a0, a1, 4
; CHECK-NEXT:  ret
; BASE-LABEL: extract_variable_aligned:
; BASE-NOT:   extru
; BASE:       srl
; BASE:       andi
; BASE:       ret
  %shift = and i32 %amount, 28
  %shifted = lshr i32 %x, %shift
  %field = and i32 %shifted, 15
  ret i32 %field
}

define i32 @extract_variable_signed(i32 %x, i32 %amount) {
; CHECK-LABEL: extract_variable_signed:
; CHECK:       andi a1, a1, 28
; CHECK-NEXT:  extrs a0, a0, a1, 4
; CHECK-NEXT:  ret
  %shift = and i32 %amount, 28
  %shifted = lshr i32 %x, %shift
  %left = shl i32 %shifted, 28
  %field = ashr i32 %left, 28
  ret i32 %field
}

define i32 @extract_signed_arithmetic_shift(i32 %x, i32 %amount) {
; CHECK-LABEL: extract_signed_arithmetic_shift:
; CHECK:       andi a1, a1, 28
; CHECK-NEXT:  extrs a0, a0, a1, 4
; CHECK-NEXT:  ret
  %shift = and i32 %amount, 28
  %shifted = ashr i32 %x, %shift
  %left = shl i32 %shifted, 28
  %field = ashr i32 %left, 28
  ret i32 %field
}

; A crossing field wraps in EXTRU/EXTRS, but not in an LLVM logical shift.
define i32 @extract_variable_unbounded(i32 %x, i32 %shift) {
; CHECK-LABEL: extract_variable_unbounded:
; CHECK:       srl a0, a0, a1
; CHECK-NEXT:  andi a0, a0, 15
; CHECK-NEXT:  ret
  %shifted = lshr i32 %x, %shift
  %field = and i32 %shifted, 15
  ret i32 %field
}

define i32 @extract_variable_signed_unbounded(i32 %x, i32 %shift) {
; CHECK-LABEL: extract_variable_signed_unbounded:
; CHECK:       srl a0, a0, a1
; CHECK-NEXT:  extrsi a0, a0, 0, 4
; CHECK-NEXT:  ret
  %shifted = lshr i32 %x, %shift
  %left = shl i32 %shifted, 28
  %field = ashr i32 %left, 28
  ret i32 %field
}

define i32 @extract_variable_rotate(i32 %x, i32 %shift) {
; CHECK-LABEL: extract_variable_rotate:
; CHECK:       extru a0, a0, a1, 4
; CHECK-NEXT:  ret
  %rotated = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 %shift)
  %field = and i32 %rotated, 15
  ret i32 %field
}

; EXTRS saturates the sign-bit position rather than wrapping it.
define i32 @extract_signed_rotate_unbounded(i32 %x, i32 %shift) {
; CHECK-LABEL: extract_signed_rotate_unbounded:
; CHECK-NOT:   extrs{{[ \t]}}
; CHECK:       ret
  %rotated = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 %shift)
  %left = shl i32 %rotated, 28
  %field = ashr i32 %left, 28
  ret i32 %field
}

define i32 @extract_signed_rotate_bounded(i32 %x, i32 %amount) {
; CHECK-LABEL: extract_signed_rotate_bounded:
; CHECK:       andi a1, a1, 28
; CHECK-NEXT:  extrs a0, a0, a1, 4
; CHECK-NEXT:  ret
  %shift = and i32 %amount, 28
  %rotated = call i32 @llvm.fshr.i32(i32 %x, i32 %x, i32 %shift)
  %left = shl i32 %rotated, 28
  %field = ashr i32 %left, 28
  ret i32 %field
}

define i32 @extract_crossing_constant(i32 %x) {
; CHECK-LABEL: extract_crossing_constant:
; CHECK-NOT:   extrui
; CHECK:       srli a0, a0, 30
; CHECK-NEXT:  ret
  %shifted = lshr i32 %x, 30
  %field = and i32 %shifted, 15
  ret i32 %field
}

declare i32 @llvm.fshr.i32(i32, i32, i32)

; The loop induction variable is a multiple of four, even though its
; SelectionDAG copy from another block does not retain those known bits.
define void @extract_loop(ptr %out, i32 %x) {
; CHECK-LABEL: extract_loop:
; CHECK:       extru {{[a-z0-9]+}}, a1, {{[a-z0-9]+}}, 4
; CHECK-NOT:   srl
; CHECK:       ret
entry:
  br label %loop
loop:
  %shift = phi i32 [ 28, %entry ], [ %next, %loop ]
  %ptr = phi ptr [ %out, %entry ], [ %ptr.next, %loop ]
  %shifted = lshr i32 %x, %shift
  %field = and i32 %shifted, 15
  store volatile i32 %field, ptr %ptr
  %next = add nsw i32 %shift, -4
  %ptr.next = getelementptr i32, ptr %ptr, i32 1
  %done = icmp eq i32 %shift, 0
  br i1 %done, label %exit, label %loop
exit:
  ret void
}
