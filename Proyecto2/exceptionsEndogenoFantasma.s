		.kdata
m1:		.asciiz "\nxxxxxxxx\nxaaaxaax\nxaaaa$ax\nxaaxaaax\nxxxxxxxx\n"
exp:		.asciiz "\n"
new_line: 	.asciiz "\n\n\n\n"
direccion:	.word 1
tamano:		.word 9
up:	.word 119 # w
down:	.word 115 # s
left:	.word 107 # k
rigth:	.word 108 # l
s1:	.word 0
s2:	.word 0
ra:	.word 0
dummy:	.ascii "a "

valores:	.word 1,2,4,8
inicio:		.word 0, 0, 0 ,0 	
seed1:       .word   0x10111001
seed2:       .word   0x10111001

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

##################################################################


	
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
	
	jal moverf

	lw $t1 4($sp)
	lw $t0 8($sp)
	move $t5 $v0
	lw $v0 16($sp)
	addi $sp $sp 16
	addi $fp $sp 16
	
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
moverf:

	la $t2 dummy
	li $t5 1

	# deberia ir $fp en vez de $sp
	lw $v0, 12($sp)

	li $t0, 8
	beq $a0, $t0, derf
	li $t0, 4
	beq $a0, $t0, izqf
	li $t0, 2
	beq $a0, $t0, bajf
	li $t0, 1
	beq $a0, $t0, arrf

arrf:
	nor $a3 $a3 $a3
	addi $a3 $a3 1
	
	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 kfx

	lb $t6 0($t2)

	li $t0 0x24
	
	sb $t1 0($t2)
	sb $t0 0($t3)
	sb $t6 0($a1)	

	move $v0 $t3 

	b kf
	
bajf:
	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 kfx

	lb $t6 0($t2)
	
	li $t0 0x24

	sb $t1 0($t2)
	sb $t0 0($t3)
	sb $t6 0($a1)
	
	move $v0 $t3 

	b kf

derf:
	lb $t6 0($t2)
	lb $t1 1($a1)

	li $t5 0x78	
	beq $t1 $t5 kfx
	
	sb $t1 0($t2)

	li $t0 0x24
	sb $t0 1($a1)
	
	addi $v0 $a1 1

	sb $t6 0($a1)
	b kf

izqf:

	lb $t6 0($t2)
	lb $t1 -1($a1)

	li $t5 0x78	
	beq $t1 $t5 kfx

	sb $t1 0($t2)

	li $t0 0x24
	sb $t0 -1($a1)

	addi $v0 $a1 -1

	sb $t6 0($a1)
	b kf

kfx:	addi $sp $sp -40
	sw $a0 4($sp)
	sw $a1 8($sp)
	sw $a2 12($sp)
	sw $t0 16($sp)
	sw $t1 20($sp)
	sw $t2 24($sp)
	sw $t3 28($sp)
	sw $t4 32($sp)
	sw $t5 36($sp)
	sw $ra 40($sp)

	jal numAleatorio
	
	lw $ra 40($sp)
	lw $t5 36($sp)
	lw $t4 32($sp)
	lw $t3 28($sp)
	lw $t2 24($sp)
	lw $t1 20($sp)
	lw $t0 16($sp)
	lw $a2 12($sp)
	lw $a1 8($sp)
	lw $a0 4($sp)
	addi $sp $sp 40

	sw $v0 direccion
	lw $v0, 12($sp)
	
kf:	j $ra
#####################################################

numAleatorio:

	li $t1, 50
	lw $t2, seed1
	li $t7 , 20   # numero de valores aleatorio que se generaran
	li $t8, 8    # Rango de los valores aleatorios a generar, 
                      # de 0 a 10, esto fue modificado del algoritmo 
                      # original

ciclo2:
	srl $t3, $t2, 3    #  
	xor $t4, $t3, $t2
	sll $t5, $t4, 5
	xor $t6, $t5, $t4
	addi $t1, $t1, -1
	
	move $t2, $t6

	                  # ciclo interno para el calculo de un 
	                  # valor aleatorio
	bgtz $t1, ciclo2  # este ciclo interno se ejecuta 50 
                          # veces para producir un número 
                          # peudo-aleatorio
        div $t6, $t8      
        mfhi $t9	          # se obtiene el modulo para reducir la
                          # cantidad de valores aletaorios a generar
	abs $t9, $t9      # se calcula el valor absoluto para 
                          # solo generar valores positivos
	
	beqz $t9, cero
	beq $t9, 3, tres
	beq $t9, 5, cinco
	beq $t9, 6, seis
	beq $t9, 7, siete
	b cont
	
cero:   li $t9, 1
        b cont

tres:   li $t9, 2
        b cont
        
cinco:  li $t9, 4
        b cont

seis:   li $t9, 8
        b cont

siete:  li $t9, 8

	#  Esta seccion de aqui en adelante simplemente imprime 
	# uno de los 20 valores aleatorios que el programa genera
cont:
	la $v0 seed1
	sw $t2 0($v0)

	move $v0 $t9	


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

