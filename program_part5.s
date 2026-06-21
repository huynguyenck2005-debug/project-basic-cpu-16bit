.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000

mv  r2, #0
mv  r6, #T1
sub r0, r0
T1:
bne #FAIL
mv  r6, #C1
C1:
beq #C2
b   #FAIL
C2:
add r2, #2

mv  r6, #T2
T2:
bne #S1
mv  pc, #FAIL
S1:
mv  r6, #C3
beq #FAIL
add r2, #2
C3:

mv  r6, #T3
T3:
mv  r3, #ALLONES
ld  r3, [r3]
add r3, #1
bcc #FAIL
mv  r6, #C4
bcs #C5
b   #FAIL
C5:
add r2, #2
C4:

mv  r6, #T4
T4:
mv  r3, #0
add r3, r3
bcc #S2
mv  pc, #FAIL
S2:
mv  r6, #C6
bcs #FAIL
add r2, #2
C6:

mv  r6, #T5
mv  r4, #_LDTEST
ld  r4, [r4]
mv  r3, #0x1A5
sub r3, r4
T5:
bne #FAIL
add r2, #1

mv  r6, #T6
mv  r3, #0x1A5
mv  r4, #_STTEST
st  r3, [r4]
ld  r4, [r4]
sub r3, r4
bne #FAIL
add r2, #1
T6:

mv  pc, #PASS
FAIL:
mvt r3, #LED_ADDRESS
st  r6, [r3]
mv  r5, #_FAIL
mv  pc, #PRINT

PASS:
mvt r3, #LED_ADDRESS
st  r2, [r3]
mv  r5, #_PASS

PRINT:
mvt r4, #HEX_ADDRESS
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1
ld  r3, [r5]
st  r3, [r4]
add r5, #1
add r4, #1

HERE:
mv  pc, #HERE

_PASS:
.word 0b0000000001011110
.word 0b0000000001111001
.word 0b0000000001101101
.word 0b0000000001101101
.word 0b0000000001110111
.word 0b0000000001110011

_FAIL:
.word 0b0000000001011110
.word 0b0000000001111001
.word 0b0000000000111000
.word 0b0000000000110000
.word 0b0000000001110111
.word 0b0000000001110001

ALLONES:
.word 0xFFFF
_LDTEST:
.word 0x01A5
_STTEST:
.word 0x015A
