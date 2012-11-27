		.kdata
m1:		.asciiz "\nxxxxxxxx\nxaaaaaax\nxaaxx<ax\nxaaaaaax\nxxxxxxxx\n"
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

#
# Estaba en el ejemplo
# esta guardando los supuestos registros importantes
#
	
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
#
# Aqui se carga el vector de la interrupcion de teclado y se revisa a
# ver si fue una interrupcion de teclado
# si es de teclado el resultado no deberia ser 0
# si es = 0 entonces entro por interrupcion de timer y se va a display
#
	lui $t0 0xFFFF

	lw $t1, 0($t0) 
	andi $t1, $t1, 0x0001
	beq $t1, $zero, display

##################################################################
#
# Una vez que es una interrupcion de teclado revisas si es "q"
# true = me salgo
#
	addi $s0, $0, 113 # q

	lw $a1, 4($t0)
	bne $a1, $s0, Mov

	li $v0 10
	syscall

#
# Como en este caso si no es q entonces deberia ser de movimiento
# entramos en el procedimiento que dependiendo de lo que lea enciende
# un bit en direccion y retorna al ciclo infinito
#
	
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

print:	sw $k0 direccion

	b end

##################################################################
#
# Si entro por timer entonces tiene que actualizar el monitor
#
#
display:

#
# Guardo todo lo que tengo que guardar y paso lo que tenga que pasar
# como parametro para poder llamar a la funcion que mueve al pacman
#
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

#
# Imprimo el tablero con 4 lineas
# 
	
	li $v0,4
	la $a0, m1
	syscall

	li $v0,4
	la $a0, new_line
	syscall

# Reinicio el timer
	
	li $t0, 5
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
# Funcion que lo mueve
#
# a1 = la posicion de lo que vas a mover
# a0 = dirrecion
# a2 = mapa
#
# t0 = 0(dummy)
# t2 = dummy
# t3 = destino (arriba y abajo)
# t5 = x
# t1 = lo que esta en destino
#
	
mover:
	li $t0 0
	lb $t0 0($a1)

	sb $t0 dummy

	la $t2 dummy
	li $t5 1

	# deberia ir $fp en vez de $sp
	lw $v0, 12($sp)

# reviso que bit tengo prendido
	li $t0, 8
	beq $a0, $t0, der
	li $t0, 4
	beq $a0, $t0, izq
	li $t0, 2
	beq $a0, $t0, baj
	li $t0, 1
	beq $a0, $t0, arr

# Si no tengo ninguno de esos pendidos
# limpio direccion y me salgo
	li $a0 0
	sw $a0 direccion
	j $ra

#
# Para moverme hacia arriba como tengo el tama~o
# de cada fila de la matriz lo que restar esa cantidad y
# asi salto a la posicion que esta "arriba"
#
arr:
	nor $a3 $a3 $a3
	addi $a3 $a3 1
	
	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 k

	li $t0 0x56
	li $t6 0x6F

	# en dummy guardo lo que estaba a donde me voy a mover
	sb $t1 0($t2)
	# cargo "V" en la posicion a donde me voy a mover
	sb $t0 0($t3)
	# coloco "o" donde estaba antes
	sb $t6 0($a1)	

	#devuelvo la nueva posicion del pacman
	move $v0 $t3 

	b k

#
# Lo mismo que arriba solo que se suma la cantidad para
# asi bajar una en vez de subir
#
# Esta falta ponerla bonita como la de arriba para fines practicos
# hace lo mismo que arriba
baj:

	lb $t0 0($t2)

	add $t3 $a1 $a3
	
	lb $t1 0($t3)

	li $t5 0x78	
	beq $t1 $t5 k
	
	sb $t1 0($t2)

	bne $t4 $t5 fbaj
	li $t0 0x56
	b bajo
fbaj:	lb $t0 0($t2)

bajo:	sb $t1 0($t2)
	li $t0 0x5E
	sb $t0 0($t3)
	
	move $v0 $t3 
	li $t0 0x6F
	sb $t0 0($a1)
	b k
#
# +1 para decir que es a la derecha
#
der:

	lb $t0 0($t2)

	lb $t1 1($a1)

	li $t5 0x78	
	beq $t1 $t5 k
	
	sb $t1 1($t2)

	li $t0 0x3C
	sb $t0 1($a1)
	
	addi $v0 $a1 1
	li $t0 0x6F
	sb $t0 0($a1)
	b k

#
# -1 para decir que es a la izquirda
#

izq:

	lb $t0 0($t2)
	lb $t1 -1($a1)

	li $t5 0x78	
	beq $t1 $t5 k

	sb $t1 1($t2)

	li $t0 0x3E
	sb $t0 -1($a1)
	addi $v0 $a1 -1
	li $t0 0x6F
	sb $t0 0($a1)
	
k:	li $a0 0
	sw $a0 direccion
 	j $ra
	
#####################################################
#
#
# Aqui comienza el programa, cuando comienza el carga esto
#
#######################################################
	.text
	.globl __start

__start:
# Esto estaba en el ejemplo que ellos dieron no se que es
	
	lw $a0 0($sp)		# argc
	addiu $a1 $sp 4		# argv
	addiu $a2 $a1 4		# envp
	sll $v0 $a0 2
	addu $a2 $a2 $v0

# Esto habilita las interrupciones por teclaso
	
	li $a0, 0xffff0000
	lw $t0, 0($a0)
	ori $t0, 0x02  # use keyboard interrupts
	sw $t0, 0($a0)
	
	mfc0 $t0, $12
	ori $t0, $t0, 0xff01
	mtc0 $t0, $12

# Aqui se configura el timer a 5ms
	li $t0, 5
	mtc0 $t0, $11
	mtc0 $zero, $9

# Me carga la posicion del pacman al apuntador $t5
	
	la $t5 m1
	la $t5 24($t5)

	lb $a0 0($t5)
	li $v0 11
	syscall

	
################################################
# Esto estaba en el ejemplo asi que lo dejo	
	jal main
	nop
	
# Cuando el main hace j $ra entra en el loop infinito,
# nada mas sale de ahi si se encuentra con una interrupcion
	
loop:	
	b loop

	
#############################################################

