; Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
;
; RUN: llc -mtriple=riscv32 -mattr=+xpaimy < %s | FileCheck %s

declare void @llvm.riscv.myriscv.trap(i32 immarg)

define void @always() {
; CHECK-LABEL: always:
; CHECK: trapeq 3, zero, zero
  call void @llvm.riscv.myriscv.trap(i32 3)
  ret void
}

define void @conditional(i32 %x) {
; CHECK-LABEL: conditional:
; CHECK: trapne 7, a0, zero
  %test = icmp ne i32 %x, 0
  br i1 %test, label %trap, label %done

trap:
  call void @llvm.riscv.myriscv.trap(i32 7)
  br label %done

done:
  ret void
}
