.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000

// This program shows the digits 543210 on the HEX displays.
// Each digit has to be selected by using the SW switches.
mv  r5, pc
mv  pc, #BLANK
MAIN:
mvt r2, #HEX_ADDRESS
mv  r3, #DATA
mvt r4, #SW_ADDRESS
ld  r0, [r4]
and r0, #0x7
add r2, r0
add r3, r0
ld  r0, [r3]
st  r0, [r2]
mv  pc, #MAIN

BLANK:
mv  r0, #0
mvt r1, #HEX_ADDRESS
st  r0, [r1]
add r1, #1
st  r0, [r1]
add r1, #1
st  r0, [r1]
add r1, #1
st  r0, [r1]
add r1, #1
st  r0, [r1]
add r1, #1
st  r0, [r1]
add r5, #1
mv  pc, r5

DATA:
.word 0b00111111
.word 0b00000110
.word 0b01011011
.word 0b01001111
.word 0b01100110
.word 0b01101101
