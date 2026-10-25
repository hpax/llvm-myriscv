#!/usr/bin/env bash
# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# Configure, build, and install the native MyRISCV LLVM toolchain.

set -euo pipefail

REPOSITORY_DIR="${REPOSITORY_DIR:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
BUILD_DIR="${BUILD_DIR:-$(pwd)/build}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/opt/riscv/my}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
JOBS="${JOBS:-16}"

cmake -S "${REPOSITORY_DIR}/llvm" -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DLLVM_DEFAULT_TARGET_TRIPLE=riscv32-hpa-elf \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_ENABLE_PROJECTS=clang \
  -DLLVM_ENABLE_RUNTIMES= \
  -DLLVM_TARGETS_TO_BUILD=RISCV \
  -DLLVM_BUILD_TOOLS=ON \
  -DLLVM_BUILD_TESTS=ON

cmake --build "${BUILD_DIR}" --parallel "${JOBS}"
cmake --install "${BUILD_DIR}"
