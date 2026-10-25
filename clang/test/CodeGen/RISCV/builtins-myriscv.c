// RUN: %clang_cc1 -triple riscv32 -target-feature +xpaimy -emit-llvm -o - %s | FileCheck %s

unsigned clo(unsigned x) { return __builtin_riscv_myriscv_clo_32(x); }
// CHECK-LABEL: define{{.*}} @clo
// CHECK: call i32 @llvm.riscv.myriscv.clo.i32

unsigned cto(unsigned x) { return __builtin_riscv_myriscv_cto_32(x); }
// CHECK-LABEL: define{{.*}} @cto
// CHECK: call i32 @llvm.riscv.myriscv.cto.i32

unsigned cpopz(unsigned x) { return __builtin_riscv_myriscv_cpopz_32(x); }
// CHECK-LABEL: define{{.*}} @cpopz
// CHECK: call i32 @llvm.riscv.myriscv.cpopz.i32
