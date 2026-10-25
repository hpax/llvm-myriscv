# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy,+xpasmy -show-encoding < %s \
# RUN:   | FileCheck %s
# RUN: llvm-mc -triple riscv32 -mattr=+xpaimy,+xpasmy -filetype=obj < %s \
# RUN:   | llvm-objdump -d --mattr=+xpaimy,+xpasmy - | FileCheck %s --check-prefix=DIS

sh1sub a0, a1, a2
# CHECK: sh1sub a0, a1, a2 # encoding: [0x33,0xa5,0xc5,0x60]
clo a0, a1
# CHECK: clo a0, a1 # encoding: [0x13,0x95,0x05,0x61]
sloi a0, a1, 3
# CHECK: sloi a0, a1, 3 # encoding: [0x13,0x95,0x35,0x80]
seq a0, a1, a2
# CHECK: seq a0, a1, a2 # encoding: [0x33,0xa5,0xc5,0x02]
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
add.xu a0, a1, a2
# CHECK: add.xu a0, a1, a2 # encoding: [0x2b,0x85,0xc5,0x00]
add.xu a0, a1, -1
# CHECK: add.xu a0, a1, -1 # encoding: [0x0b,0x85,0xf5,0xff]
add.xc a0, a1, a2, 3
# CHECK: add.xc a0, a1, a2, 3 # encoding: [0x2b,0x85,0xc5,0x86]
add.sc a0, a1, a2, 3
# CHECK: add.sc a0, a1, a2, 3 # encoding: [0x2b,0xb5,0xc5,0x86]
add.sm a0, a1, a2
# CHECK: add.sm a0, a1, a2 # encoding: [0x2b,0xb5,0xc5,0x80]
c.ecall
# CHECK: c.ecall # encoding: [0x02,0x80]

# DIS: sh1sub a0, a1, a2
# DIS: clo a0, a1
# DIS: seq a0, a1, a2
# DIS: baeqz a0, a1
# DIS: extru a0, a1, a2, 0x4
# DIS: extrui a0, a1, 0x3, 0x4
# DIS: add.xc a0, a1, a2, 0x3
# DIS: add.sc a0, a1, a2, 0x3
# DIS: c.ecall
