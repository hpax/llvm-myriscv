# Copyright (C) 2026 H. Peter Anvin <hpa@zytor.com>
#
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy,+xpasmy -show-encoding < %s \
# RUN:   | FileCheck %s
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy,+xpasmy -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy,+xpasmy - | FileCheck %s --check-prefix=DIS
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy,+xpasmy -filetype=obj < %s \
# RUN:   | llvm-readobj -r - | FileCheck %s --check-prefix=RELOC

sh1sub a0, a1, a2
# CHECK: sh1sub a0, a1, a2 # encoding: [0x33,0xa5,0xc5,0x60]
clo a0, a1
# CHECK: clo a0, a1 # encoding: [0x13,0x95,0x05,0x61]
sloi a0, a1, 3
# CHECK: sloi a0, a1, 3 # encoding: [0x13,0x95,0x35,0x80]
seq a0, a1, a2
# CHECK: seq a0, a1, a2 # encoding: [0x33,0xa5,0xc5,0x40]
baeqz a0, a1, 8
# CHECK: baeqz a0, a1, 8 # encoding: [0x63,0x24,0xb5,0x00]
extru a0, a1, a2, 4
# CHECK: extru a0, a1, a2, 4 # encoding: [0x2b,0xd5,0xc5,0x08]
extrui a0, a1, 3, 4
# CHECK: extrui a0, a1, 3, 4 # encoding: [0x0b,0xd5,0x35,0x08]
extrcs a0, a1, a2, 4
# CHECK: extrcs a0, a1, a2, 4 # encoding: [0x2b,0xd5,0xc5,0xc8]
zext a0, a1, a2
# CHECK: zext a0, a1, a2 # encoding: [0x2b,0xf5,0xc5,0x00]
csext a0, a1, a2
# CHECK: csext a0, a1, a2 # encoding: [0x2b,0xf5,0xc5,0xc0]
cneg a0, a1, a2
# CHECK: cneg a0, a1, a2 # encoding: [0x2b,0xe5,0xc5,0x00]
cnegi a0, a1, -1
# CHECK: cnegi a0, a1, -1 # encoding: [0x0b,0xe5,0xf5,0xff]
shaddpc a0, a1, 2
# CHECK: shaddpc a0, a1, 2 # encoding: [0x0b,0x95,0x25,0x20]
shsubpc a0, a1, 2
# CHECK: shsubpc a0, a1, 2 # encoding: [0x0b,0x95,0x25,0x60]
lai a0, 2048
# CHECK: lai a0, 2048 # encoding: [0x4b,0x05,0x10,0x00]
lai a0, 2049
# CHECK: lai a0, 2049 # encoding: [0x4f,0x05,0x10,0x00]
lai a0, .Ltarget
# CHECK: lai a0, .Ltarget # encoding: [0x4b'A',0x05'A',A,A]
# CHECK: fixup A - offset: 0, value: .Ltarget, kind: fixup_riscv_lai
  .space 8
.Ltarget:
add.xu a0, a1, a2
# CHECK: add.xu a0, a1, a2 # encoding: [0x2b,0x85,0xc5,0x00]
add.xu a0, a1, -1
# CHECK: add.xu a0, a1, -1 # encoding: [0x0b,0x85,0xf5,0xff]
add.xc a0, a1, a2, 3
# CHECK: add.xc a0, a1, a2, 3 # encoding: [0x2b,0x85,0xc5,0x86]
add.ux a0, a1, a2
# CHECK: add.ux a0, a1, a2 # encoding: [0x2b,0xa5,0xc5,0x00]
sub.ux a0, a1, a2
# CHECK: sub.ux a0, a1, a2 # encoding: [0x2b,0xa5,0xc5,0x40]
add.cx a0, a1, a2, 3
# CHECK: add.cx a0, a1, a2, 3 # encoding: [0x2b,0xa5,0xc5,0x86]
sub.cx a0, a1, a2, 3
# CHECK: sub.cx a0, a1, a2, 3 # encoding: [0x2b,0xa5,0xc5,0xc6]
add.sc a0, a1, a2, 3
# CHECK: add.sc a0, a1, a2, 3 # encoding: [0x2b,0xb5,0xc5,0x86]
add.sm a0, a1, a2
# CHECK: add.sm a0, a1, a2 # encoding: [0x2b,0xb5,0xc5,0x80]
c.ecall
# CHECK: c.ecall # encoding: [0x02,0x80]
wfi a0, a1
# CHECK: wfi a0, a1 # encoding: [0x73,0x85,0x55,0x10]
wfi zero, zero
# CHECK: wfi zero, zero # encoding: [0x73,0x00,0x50,0x10]

slo a0, a1, 3
# CHECK: sloi a0, a1, 3 # encoding: [0x13,0x95,0x35,0x80]
sro a0, a1, 3
# CHECK: sroi a0, a1, 3 # encoding: [0x13,0xd5,0x35,0x80]
srcs a0, a1, 3
# CHECK: srcsi a0, a1, 3 # encoding: [0x13,0xd5,0x35,0xc0]
extru a0, a1, 3, 4
# CHECK: extrui a0, a1, 3, 4 # encoding: [0x0b,0xd5,0x35,0x08]
extrs a0, a1, 3, 4
# CHECK: extrsi a0, a1, 3, 4 # encoding: [0x0b,0xd5,0x35,0x48]
extro a0, a1, 3, 4
# CHECK: extroi a0, a1, 3, 4 # encoding: [0x0b,0xd5,0x35,0x88]
extrcs a0, a1, 3, 4
# CHECK: extrcsi a0, a1, 3, 4 # encoding: [0x0b,0xd5,0x35,0xc8]
zext a0, a1, 4
# CHECK: extrui a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x08]
sext a0, a1, 4
# CHECK: extrsi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x48]
oext a0, a1, 4
# CHECK: extroi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x88]
csext a0, a1, 4
# CHECK: extrcsi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0xc8]
zexti a0, a1, 4
# CHECK: extrui a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x08]
sexti a0, a1, 4
# CHECK: extrsi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x48]
oexti a0, a1, 4
# CHECK: extroi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0x88]
csexti a0, a1, 4
# CHECK: extrcsi a0, a1, 0, 4 # encoding: [0x0b,0xd5,0x05,0xc8]
cneg a0, a1, -1
# CHECK: cnegi a0, a1, -1 # encoding: [0x0b,0xe5,0xf5,0xff]
lai a0, .Lodd
# CHECK: lai a0, .Lodd # encoding: [0x4b'A',0x05'A',A,A]
# CHECK: fixup A - offset: 0, value: .Lodd, kind: fixup_riscv_lai
.byte 0
.Lodd:
lai a0, lai_external
# CHECK: lai a0, lai_external # encoding: [0x4b'A',0x05'A',A,A]
# CHECK: fixup A - offset: 0, value: lai_external, kind: fixup_riscv_lai

# DIS: sh1sub a0, a1, a2
# DIS: clo a0, a1
# DIS: seq a0, a1, a2
# DIS: baeqz a0, a1
# DIS: extru a0, a1, a2, 0x4
# DIS: extrui a0, a1, 0x3, 0x4
# DIS: shaddpc a0, a1, 0x2
# DIS: shsubpc a0, a1, 0x2
# DIS: lai a0, 0x838
# DIS: lai a0, 0x83d
# DIS: lai a0, 0x4c
# DIS: add.xc a0, a1, a2, 0x3
# DIS: add.ux a0, a1, a2
# DIS: sub.ux a0, a1, a2
# DIS: add.cx a0, a1, a2, 0x3
# DIS: sub.cx a0, a1, a2, 0x3
# DIS: add.sc a0, a1, a2, 0x3
# DIS: c.ecall
# DIS: wfi a0, a1
# DIS: wfi zero, zero
# DIS: sloi a0, a1, 0x3
# DIS: sroi a0, a1, 0x3
# DIS: srcsi a0, a1, 0x3
# DIS: extrui a0, a1, 0x3, 0x4
# DIS: extrsi a0, a1, 0x3, 0x4
# DIS: extroi a0, a1, 0x3, 0x4
# DIS: extrcsi a0, a1, 0x3, 0x4
# DIS: extrui a0, a1, 0x0, 0x4
# DIS: extrsi a0, a1, 0x0, 0x4
# DIS: extroi a0, a1, 0x0, 0x4
# DIS: extrcsi a0, a1, 0x0, 0x4
# DIS: cnegi a0, a1, -0x1
# DIS: lai a0, 0xbf

# RELOC: R_RISCV_CUSTOM192 lai_external 0x0
