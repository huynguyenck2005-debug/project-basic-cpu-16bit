MAIN:
mv  r0, #2
LOOP:
sub r0, #1
bne #LOOP
beq #T1
mv  pc, #DEAD
T1:
mvt r0, #0xFF00
add r0, #0xFF
bcc #T2
mv  pc, #DEAD
T2:
add r0, #1
bcs #T3
mv  pc, #DEAD
T3:
b   #MAIN
DEAD:
mv  pc, #DEAD
