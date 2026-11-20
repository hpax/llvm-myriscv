; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
; RUN: llc -mtriple=riscv32 -mcpu=myriscv -O2 < %s | FileCheck %s
; RUN: llc -mtriple=riscv32 -mcpu=myriscv -mattr=+f -O2 < %s \
; RUN:   | FileCheck %s --check-prefix=F

define void @profiled(i1 %c, ptr %p) !prof !0 {
entry:
  br i1 %c, label %hot, label %cold, !prof !1
hot:
  store volatile i32 1, ptr %p
  ret void
cold:
  store volatile i32 2, ptr %p
  ret void
}

define void @unprofiled(i1 %c, ptr %p) {
entry:
  br i1 %c, label %hot, label %cold
hot:
  store volatile i32 1, ptr %p
  ret void
cold:
  store volatile i32 2, ptr %p
  ret void
}

; CHECK-LABEL: profiled:
; CHECK: baeqz.pn
; CHECK-LABEL: unprofiled:
; CHECK: baeqz{{[ \t]}}
; CHECK-NOT: baeqz.pt
; CHECK-NOT: baeqz.pn
; F-LABEL: profiled:
; F: baeqz{{[ \t]}}
; F-NOT: baeqz.pt
; F-NOT: baeqz.pn

!0 = !{!"function_entry_count", i64 100}
!1 = !{!"branch_weights", i32 99, i32 1}
