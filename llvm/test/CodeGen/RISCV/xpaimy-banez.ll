; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
;
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy < %s | FileCheck %s

define void @branch_on_and(i32 %lhs, i32 %rhs, ptr %address) {
; CHECK-LABEL: branch_on_and:
; CHECK:       banez a0, a1, .LBB0_2
; CHECK-NOT:   and
; CHECK:       ret
  %and = and i32 %lhs, %rhs
  %iszero = icmp eq i32 %and, 0
  br i1 %iszero, label %zero, label %nonzero, !prof !0

zero:
  store volatile i32 0, ptr %address
  ret void

nonzero:
  store volatile i32 1, ptr %address
  ret void
}

!0 = !{!"branch_weights", i32 2000, i32 1}
