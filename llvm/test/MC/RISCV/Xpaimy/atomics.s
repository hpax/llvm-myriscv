# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy -show-encoding < %s | FileCheck %s
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy - | FileCheck %s --check-prefix=DIS

lr.b a0, (a1)
# CHECK: lr.b a0, (a1) # encoding: [0x2f,0x85,0x05,0x10]
lr.h a0, (a1)
# CHECK: lr.h a0, (a1) # encoding: [0x2f,0x95,0x05,0x10]
lr.bu a0, (a1)
# CHECK: lr.bu a0, (a1) # encoding: [0x2f,0xc5,0x05,0x10]
lr.hu a0, (a1)
# CHECK: lr.hu a0, (a1) # encoding: [0x2f,0xd5,0x05,0x10]
sc.b a0, a1, (a2)
# CHECK: sc.b a0, a1, (a2) # encoding: [0x2f,0x05,0xb6,0x18]
sc.h a0, a1, (a2)
# CHECK: sc.h a0, a1, (a2) # encoding: [0x2f,0x15,0xb6,0x18]
lr.b.aqrl a0, (a1)
# CHECK: lr.b.aqrl a0, (a1) # encoding: [0x2f,0x85,0x05,0x16]
sc.h.aq a0, a1, (a2)
# CHECK: sc.h.aq a0, a1, (a2) # encoding: [0x2f,0x15,0xb6,0x1c]

# DIS: lr.b a0, (a1)
# DIS: lr.h a0, (a1)
# DIS: lr.bu a0, (a1)
# DIS: lr.hu a0, (a1)
# DIS: sc.b a0, a1, (a2)
# DIS: sc.h a0, a1, (a2)
# DIS: lr.b.aqrl a0, (a1)
# DIS: sc.h.aq a0, a1, (a2)
