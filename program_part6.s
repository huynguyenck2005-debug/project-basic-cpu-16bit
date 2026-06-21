.define LED_ADDRESS 0x1000
.define SW_ADDRESS  0x3000

mvt r3, #LED_ADDRESS
mvt r4, #SW_ADDRESS
MAIN:
mv  r0, #0
LOOP:
st  r0, [r3]
ld  r1, [r4]
and r1, #0x1FF
add r1, #1
DLY1:
mv  r2, #0x1FF
DLY2:
sub r2, #1
bne #DLY2
sub r1, #1
bne #DLY1
add r0, #1
bcc #LOOP
b   #MAIN
