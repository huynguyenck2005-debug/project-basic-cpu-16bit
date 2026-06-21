.define LED_ADDRESS 0x1000
.define SW_ADDRESS  0x3000

// Read SW switches and display on LEDs forever
mvt r3, #LED_ADDRESS
mvt r4, #SW_ADDRESS
MAIN:
ld  r0, [r4]
st  r0, [r3]
mv  pc, #MAIN
