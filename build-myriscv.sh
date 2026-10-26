#!/usr/bin/env bash
# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# Configure, build, and install the native MyRISCV LLVM toolchain.

set -euo pipefail

REPOSITORY_DIR="${REPOSITORY_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
BUILD_DIR="${BUILD_DIR:-${REPOSITORY_DIR}/../build}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/riscv/my}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
JOBS="${JOBS:-16}"

triple=riscv32-myriscv-none-elf

# Flags are selected for MCU single-binary applications
declare -a flags=(-target "$triple" -mcpu=myriscv
    -mno-strict-align -fno-math-errno -fno-trapping-math
    -ftls-model=local-exec
    -fshort-wchar -fshort-enums -fno-strict-return
    -ffine-grained-bitfield-accesses
    -falign-functions=4 -fpreferred-function-alignment=4
    -falign-loops=4 -falign-labels=4
    -ffunction-sections -fdata-sections
    -mshorten-memrefs -malign-data=natural
    -mpreferred-stack-boundary=2
    -fno-pic -fno-pie
    -glldb)

cmake -S "${REPOSITORY_DIR}/llvm" -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="$triple" \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_ENABLE_PROJECTS='clang;lld' \
  -DLLVM_ENABLE_RUNTIMES='compiler-rt' \
  -DLLVM_TARGETS_TO_BUILD=RISCV \
  -DLLVM_BUILD_TOOLS=ON \
  -DLLVM_BUILD_TESTS=ON \
  -DCOMPILER_RT_BUILD_BUILTINS=ON \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
  -DCOMPILER_RT_BAREMETAL_BUILD=ON \
  -DRUNTIMES_builtin_COMPILER_FLAGS="${flags[*]}"

cmake --build "${BUILD_DIR}" --parallel "${JOBS}"
cmake --install "${BUILD_DIR}"
