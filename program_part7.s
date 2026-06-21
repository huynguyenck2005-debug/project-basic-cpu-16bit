.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000
.define STACK       0x0100

mv  r6, #STACK
mv  r5, pc
mv  pc, #BLANK
MAIN:
mv  r3, #0

LOOP:
mv  r0, r3
mv  r2, #5
mvt r4, #HEX_ADDRESS
DIGIT_LOOP:
mv  r5, pc
mv  pc, #DIV10
mv  r5, r1
mv  r1, #DATA
add r1, r0
ld  r0, [r1]
st  r0, [r4]
add r4, #1
mv  r0, r5
sub r2, #1
bne #DIGIT_LOOP
mv  r0, #0
st  r0, [r4]

mvt r1, #SW_ADDRESS
ld  r1, [r1]
and r1, #0x1FF
add r1, #1
WAIT_OUTER:
mv  r2, #0x1FF
WAIT_INNER:
sub r2, #1
bne #WAIT_INNER
sub r1, #1
bne #WAIT_OUTER

add r3, #1
bcc #LOOP
mv  r5, pc
mv  pc, #BLANK
b   #MAIN

DIV10:
sub r6, #1
st  r2, [r6]
mv  r1, #0
DLOOP:
mv  r2, #9
sub r2, r0
bcc #RETDIV
add r1, #1
sub r0, #10
b   #DLOOP
RETDIV:
ld  r2, [r6]
add r6, #1
add r5, #1
mv  pc, r5

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
.word 0b01111101
.word 0b00000111
.word 0b01111111
.word 0b01101111
