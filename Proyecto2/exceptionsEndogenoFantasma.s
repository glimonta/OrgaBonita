		.kdata
m1:		.asciiz "\nxxxxxxxx\nxaaaaaax\nxaaxx$ax\nxaaaaaax\nxxxxxxxx\n"
exp:		.asciiz "\n"
new_line: 	.asciiz "\n\n\n\n"
direccion:	.word 0
tamano:		.word 9
up:	.word 119 # w
down:	.word 115 # s
left:	.word 107 # k
rigth:	.word 108 # l
s1:	.word 0
s2:	.word 0
ra:	.word 0
dummy:	.ascii "a "

#
# $t5 => pacman
#
	
	.ktext 0x80000180

	.set noat
	move $k1 $at		# Save $at
	.set at
	sw $v0 s1		# Not re-entrant and we can't trust $sp
	sw $a0 s2		# But we need to use these registers
	sw $ra ra

	mfc0 $k0 $13		# Cause register
	srl $a0 $k0 2		# Extract ExcCode Field
	andi $a0 $a0 0x1f

###################################################################
	
	lui $t0 0xFFFF

	lw $t1, 0($t0) 
	andi $t1, $t1, 0x0001
	beq $t1, $zero, display

##################################################################

	addi $s0, $0, 113 # q

	lw $a1, 4($t0)
	bne $a1, $s0, Mov

	li $v0 10
	syscall

Mov:	lw $k0 direccion

	li $v0,4
	la $a0, exp
	syscall

	lw $s0, up
	beq $a1, $s0, mU
	lw $s0, down
	beq $a1, $s0, mD
	lw $s0, left
	beq $a1, $s0, mL
	lw $s0, rigth
	beq $a1, $s0, mR
	b end

# 0001 = up
# 0010 = down
# 0100 = left
# 1000 = rigth
mU:	ori $k0 0x0001
	b print
mD:	ori $k0 0x0002
	b print
mL:	ori $k0 0x0004
	b print
mR:	ori $k0 0x0008

#
# AQUI HAY UN ERROR QUE TENGO QUE REVISAR
# funciona sin el 0x0010	
print:	#ori $k0 0x0010
	sw $k0 direccion

	
	b end

##################################################################
	
display:
	la $a0 dummy
	li $v0 4
	syscall
	la $a0 exp
	li $v0 4
	syscall
	la $a0 exp
	li $v0 4
	syscall

	lw $a0 direccion
	move $a1 $t5
	la $a2 m1
	lw $a3 tamano

	addi $sp $sp -16
	sw $t1 4($sp)
	sw $t0 8($sp)
	sw $t5 12($sp)
	sw $v0 16($sp)
	addi $fp $sp -16

	jal mover

	lw $t1 4($sp)
	lw $t0 8($sp)
	move $t5 $v0
	lw $v0 16($sp)
	addi $sp $sp 16
	addi $fp $sp 16

	la $a0 dummy
	li $v0 4
	syscall
	la $a0 exp
	li $v0 4
	syscall
	la $a0 exp
	li $v0 4
	syscall
	
	li $v0,4
	la $a0, m1
	syscall

	li $v0,4
	la $a0, new_line
	syscall

	li $t0, 10
	mtc0 $t0, $11
	mtc0 $zero, $9
	

###################################################################
	
end:	lw $v0 s1		# Restore other registers
	lw $a0 s2
	lw $ra ra

	.set noat
	move $at $k1		# Restore $at
	.set at

	mtc0 $0 $13		# Clear Cause register
	mfc0 $k0 $12		# Set Status register
	ori  $k0 0x1		# Interrupts enabled
	mtc0 $k0 $12
	
	eret

######################################################
#
# a1 = la posicion de lo que vas a mover
# a0 = dirrecion
# a2 = mapa
#
# t0 = 0(dummy)
# t2 = dummy
# t3 = destino (arriba y abajo)
# t4 = 1 pacman 0 fantasma
# t5 = x
# t1 = lo que esta en destino
#
mover:

	la $t2 dummy
	li $t5 1

	# deberia ir $fp en vez de $sp
	lw $v0, 12($sp)

	li $t0, 8
	beq $a0, $t0, der
	li $t0, 4
	beq $a0, $t0, izq
	li $t0, 2
	beq $a0, $t0, baj
	li $t0, 1
	beq $a0, $t0, arr
	
	li $a0 0
	sw $a0 direccion
	j $ra

arr:
	nor $a3 $a3 $a3
	addi $a3 $a3 1
	
	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 k

	lb $t6 0($t2)

	li $t0 0x24
	
	sb $t1 0($t2)
	sb $t0 0($t3)
	sb $t6 0($a1)	

	move $v0 $t3 

	b k
	
baj:
	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 k

	lb $t6 0($t2)
	
	li $t0 0x24

	sb $t1 0($t2)
	sb $t0 0($t3)
	sb $t6 0($a1)
	
	move $v0 $t3 

	b k

der:
	lb $t6 0($t2)
	lb $t1 1($a1)

	li $t5 0x78	
	beq $t1 $t5 k
	
	sb $t1 0($t2)

	li $t0 0x24
	sb $t0 1($a1)
	
	addi $v0 $a1 1

	sb $t6 0($a1)
	b k

izq:

	lb $t6 0($t2)
	lb $t1 -1($a1)

	li $t5 0x78	
	beq $t1 $t5 k

	sb $t1 0($t2)

	li $t0 0x24
	sb $t0 -1($a1)

	addi $v0 $a1 -1

	sb $t6 0($a1)
	
k:	li $a0 0
	sw $a0 direccion
 	j $ra
#####################################################
	
	.text
	.globl __start

__start:
	lw $a0 0($sp)		# argc
	addiu $a1 $sp 4		# argv
	addiu $a2 $a1 4		# envp
	sll $v0 $a0 2
	addu $a2 $a2 $v0

	li $a0, 0xffff0000
	lw $t0, 0($a0)
	ori $t0, 0x02  # use keyboard interrupts
	sw $t0, 0($a0)
	
	mfc0 $t0, $12
	ori $t0, $t0, 0xff01
	mtc0 $t0, $12
	
	li $t0, 10
	mtc0 $t0, $11
	mtc0 $zero, $9

	la $t5 m1
	la $t5 24($t5)

	lb $a0 0($t5)
	li $v0 11
	syscall

	
################################################
	
	jal main
	nop

loop:	
	b loop

	
#############################################################

