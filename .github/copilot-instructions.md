<!-- Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com> -->

# LLVM Project Copilot Instructions

## Build and test

LLVM is an out-of-tree CMake build. Configure the projects needed for the
change; most developers use Ninja:

```sh
cmake -S llvm -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="clang;lld"
cmake --build build
```

`LLVM_ENABLE_PROJECTS` builds tools built on LLVM (such as `clang`, `lld`,
`lldb`, `mlir`, and `polly`). Configure runtime libraries separately with
`LLVM_ENABLE_RUNTIMES` (for example, `compiler-rt`, `libcxx`, and `openmp`).
Use the generator-independent form below with an existing build directory.

```sh
cmake --build build --target check-llvm       # LLVM regression tests
cmake --build build --target check-llvm-unit  # LLVM unit tests
cmake --build build --target check-clang      # Clang tests, when enabled
cmake --build build --target check-all        # all configured suites
build/bin/llvm-lit llvm/test/CodeGen/X86/foo.ll  # one lit test
```

Lit executes tests from the source tree using configuration generated in the
build tree. Tests are usually declarative `RUN:` lines and check output with
`FileCheck`; use the component's `test/` directory and its `lit.cfg.py` as
the closest precedent. CMake targets, component libraries, and lit suites are
registered through helpers in `llvm/cmake/modules/AddLLVM.cmake`.

Format changed C/C++ code with the repository's LLVM-based `.clang-format`,
for example `git clang-format HEAD~1`. Preserve existing formatting where
formatting unrelated surrounding code would obscure a functional change.

## Architecture

This is a monorepo. `llvm/` supplies the foundational IR, analyses,
optimizations, code generator, MC layer, support libraries, and tools.
Frontends such as `clang/` lower source languages to LLVM IR; `lld/` consumes
object files; `lldb/` uses LLVM libraries for debugger functionality; `mlir/`
is a related multi-level IR framework. Other top-level projects provide
runtimes, standard libraries, sanitizers, OpenMP, and compiler support.

Within `llvm/`, public interfaces live in `include/llvm/`; implementations are
organized in corresponding `lib/` libraries. The normal compilation path is
IR (`lib/IR`) through analyses and IR transforms (`lib/Analysis`,
`lib/Transforms`), then target-independent code generation (`lib/CodeGen`) and
target descriptions/lowering (`lib/Target/<arch>`), ending in assembler and
object handling (`lib/MC`). Target backends pair C++ code with TableGen (`.td`)
descriptions that generate interfaces and instruction data at build time.

## Repository-specific conventions

- Read and obey path-scoped files under `.github/instructions/` before editing.
  For LLVM control-flow changes, preserve profile-data and debug-information
  correctness, particularly for branches and calls. LLDB has distinct C++17,
  naming, header-layering, and style requirements.
- Reuse LLVM APIs and idioms rather than standard-library equivalents when
  nearby code does: notably `isa`, `cast`, and `dyn_cast` for LLVM's RTTI,
  `StringRef`/`Twine` for non-owning or deferred strings, and LLVM ADT
  containers where their semantics fit.
- Keep source headers, library registration, and tests aligned. New LLVM
  libraries use the CMake helpers such as `add_llvm_component_library`; test
  suites use the `add_lit_*` helpers rather than custom test runners.
- Follow the standard LLVM source-file license header exactly for new C/C++
  source and headers. Do not add or alter it.
