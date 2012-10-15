# Proyecto1: Juego Mastermind.
#
#
# Autores:
#
# Gabriela Limonta
# 10-10385
#
# Luis Miranda
# 10-10463
#
# Planificacion de registros:
#

OPEN = 13
READ = 14
WRITE = 15
CLOSE = 16

.data

buf: 		.space 32
numInt:		.space 4
numCod:		.space 4

nombArch:	.asciiz "aci.txt"
espacio:	.asciiz " "
error:		.asciiz "\n ERROR: No se ha leido un numero."


finDeArch: 	.asciiz "\n y se acabo n_n "



.text

main:	la $a0, nombArch	#guardo el nombre del archivo en a0
	li $v0, OPEN		#indico que voy a abrir
	li $a1 0x0		#indico que solo abrire para lectura
	syscall

	move $t0, $v0 		#guardo el file descriptor en t0

	la $t2, numInt		
	la $t3, numCod
	li $t1, 0               #contador

leer1:	move $a0, $t0		#copio el file descriptor en a0 para 
	la $a1, buf		#empezar a leer el archivo y le indico
	li $a2, 1		#tambien la direccion del buffer. 
	li $v0, READ		#y la cantidad de bytes que leere
	syscall

	blez $v0, fin		#si lo que retorna en v0 es 0 significa
				#que es el fin del archivo y si es -1
				#significa que hubo un error

	la $a0, buf		#imprimo lo que hay en el buffer
	li $v0, 4
	syscall

	lb $t5, 0($a0)		#almacenamos el byte que leimos en t4
	sb $t5, 0($t2)		#guardamos el byte en numInt

	addi $t2, $t2, 1	#movemos 1 byte numInt

	beq $t5, 0xa, leer2

	blt $t5, 0x30, ErrorLectura
	bgt $t5, 0x39, ErrorLectura

	b leer1

leer2:	move $a0, $t0		#copio el file descriptor en a0 para 
	la $a1, buf		#empezar a leer el archivo y le indico
	li $a2, 1		#tambien la direccion del buffer. 
	li $v0, READ		#y la cantidad de bytes que leere
	syscall
	
	addi $t1, $t1, 1        #sumo uno al contador

	blez $v0, fin		#si lo que retorna en v0 es 0 significa
				#que es el fin del archivo y si es -1
				#significa que hubo un error

	la $a0, buf		#imprimo lo que hay en el buffer
	li $v0, 4
	syscall

	lb $t5, 0($a0)		#almacenamos el byte que leimos en t4
	sb $t5, 0($t3)		#guardamos el byte en numCod

	addi $t3, $t3, 1	#movemos 1 byte numCod

	beq $t5, 0xa, leerInt

	blt $t5, 0x30, ErrorLectura
	bgt $t5, 0x39, ErrorLectura

	b leer2

leerInt:	jal transf
		
		mul $t4, $t4, 4
		
		move $a0, $t4
		li $v0, 9
		syscall

		la $t8, 0($v0)
		move $t7, $t8

leer3:	move $a0, $t0
	la $a1, buf
	li $a2, 1
	li $v0, READ
	syscall

	blez $v0, fin
	
	la $a0, buf
	li $v0, 4
	syscall

	lb $t5, 0($a0)
	
	sb $t5, 0($t7)

	beq $t5, 0xa, leer4

	blt $t5, 0x30, ErrorLectura
	bgt $t5, 0x39, ErrorLectura

	addi $t7, $t7, 1
	
	b leer3

leer4:
	addi $t7, $t7, 1
	
	b leer3

ErrorLectura:	la $s3, error
		li $v0, 4
		syscall
	
fin:	la $a0, finDeArch
	li $v0, 4
	syscall

	move $a0, $t0		#muevo el file descriptor para proceder
	li $v0, CLOSE		#a cerrar el archivo
	syscall
	
	li $v0, 10		#fin del programa
	syscall
transf:	la $t3, numCod

	li $t4, 0       	#almaceno 0 en el resultado
	addi $t6, $t1, -1
	add $t3, $t6, $t3
	li $t6, 0
	li $s0, 0
	li $s1, 1

loop:	beq $t1, $t6, saltar
	
	lb $s0, 0($t3)
	li $s2, 0x30
	beq $s0, $s2, cero

	li $s2, 0x31
	beq $s0, $s2, uno

	li $s2, 0x32
	beq $s0, $s2, dos

	li $s2, 0x33
	beq $s0, $s2, tres

	li $s2, 0x34
	beq $s0, $s2, cuatro

	li $s2, 0x35
	beq $s0, $s2, cinco

	li $s2, 0x36
	beq $s0, $s2, seis

	li $s2, 0x37
	beq $s0, $s2, siete

	li $s2, 0x38
	beq $s0, $s2, ocho

	li $s2, 0x39
	beq $s0, $s2, nueve

cero:	li $s2, 0
	b pos

uno:	li $s2, 1
	b pos

dos:	li $s2, 2
	b pos

tres:	li $s2, 3
	b pos

cuatro:	li $s2, 4
	b pos

cinco:	li $s2, 5
	b pos

seis:	li $s2, 6
	b pos

siete:	li $s2, 7
	b pos

ocho:	li $s2, 8
	b pos

nueve:	li $s2, 9

pos:	mul $s2, $s2, $s1
	add $t4, $t4, $s2

	li $s3, 10
	mul $s1, $s1, $s3

	addi $t3, $t3, -1
	addi $t6, $t6, 1

	j loop

saltar:	jr $ra
