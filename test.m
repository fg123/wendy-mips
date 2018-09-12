.word 0x12345678
add $1, $2, $3
sub $1, $2, $3
mult $1, $2
multu $1, $2
div $1, $2
divu $1, $2
mfhi $1
mflo $1
lis $1
lw $1, 0x1234($2)
sw $1, 0x1234($2)
slt $1, $2, $3
sltu $1, $2, $3
beq $1, $2, 0x1234
bne $1, $2, 0x1234
jr $1
jalr $2
