		.data

#
# $t2 donde se guarda la entrada
# $t3 cuantas buenas he conseguido
# $t4 el que se va a mover por "guar"
# $t5 donde esta "guar"
# $t6 el que se va a mover por la entrada
# $t7 posicion de entrada (y)
# $t8 posicion de "guar" (x)
# $t9 maxItera
# $s0 numIntentos
#
	
maxIntentos:	.asciiz "5"
guar:		.asciiz "1476"
numCod:		.space 5

HighScore:	.asciiz "\nDeberia imprimir los 3 mejores,\n pero no lo hago por que soy idiota\n"

leIn:		.space 5

salida1:	.asciiz "Intento #"
ln:		.asciiz "\n"
blanco:		.asciiz "B "
negro:		.asciiz "N "
ninguno:	.asciiz "X "

PreguntaFinal:	.asciiz "\nQuieres jugar otra vez? [y,n]\n"

PreguntaNombre:	.asciiz "Cual es tu nombre? \n"
Nombre:		.space 8

		.align 2
	
		.text

main:
#######################################
		lb $t9, maxIntentos
		li $s1, 0x30

bigCiclo:
########################################

		la $a0, salida1
		li $v0, 4
		syscall

		move $a0, $s1
		li $v0, 11
		syscall

		la $a0, ln
		li $v0, 4
		syscall


#		li $v0, 8
#		la $a0, numCod
# 		li $a1, 5
#		syscall
#		move $t2, $a0

		la $t2, leIn
		li $t8, 0
	
leerC:		li $v0, 12
		syscall

		beq $v0, 0x51, preg
		beq $v0, 0x71, preg
		beq $v0, 0x45, HS
		beq $v0, 0x65, HS
	
		move $t5, $v0
		sb $t5, 0($t2)
		
		addi $t2, $t2, 1
		addi $t8, $t8, 1
	
		bne $t8, 4, leerC

		move $a0, $t2
		li $v0, 4
		syscall

		la $t2, leIn
		
########################################

		la $t5, guar

		li $t7, 0
		li $t8, 0

		la $a0, ln
		li $v0, 4
		syscall
	
ciclo:		lb $t4, 0($t5)		

		lb $t6, 0($t2)
	
		beq $t4, $t6, AeqB
		b else
	
AeqB:		beq $t7, $t8, XeqY
		la $a0, blanco
		b cAeqB
	
XeqY:		la $a0, negro
		addi $t3, $t3, 1
cAeqB:		lb $t4, 0($t5)
		li $t8, 0

		li $v0, 4
		syscall
	
		addi $t7, $t7, 1
#		lb $t6, 2($t2)

		addu $t2, $t2, 1

		la $t5, guar
	
		b finCiclo

else:		addi $t8, $t8, 1
#		lb $t4, 2($t5)

		addu $t5, $t5, 1

		bne $t8, 4, finCiclo

		la $a0, ninguno
		li $v0, 4
		syscall

		addi $t7, $t7, 1
#		lb $t6, 2($t2)

		addu $t2, $t2, 1

		lb $t4, 0($t5)

		li $t8, 0

		la $t5, guar
	
		b finCiclo
	
finCiclo:	blt $t7, 4, ciclo

		la $a0, ln
		li $v0, 4
		syscall

		beq $t3, 4, fin
########################################
		addi $s1, $s1, 1

		li $t3, 0
#######################################	
		bgt $s1, $t9, fin

######################################
		li $t8, 0
		li $t7, 0
		la $t5, leIn

clean:		sb $zero, 0($t5)
		addi $t5, $t5, 1
		addi $t8, $t8, 1
		bne $t8, 4, clean
######################################

		b bigCiclo

		la $a0, ln
		li $v0, 4
		syscall

preg:		la $a0, PreguntaFinal
		li $v0, 4
		syscall

		li $v0, 12
		syscall

		move $t8, $v0

		la $a0, ln
		li $v0, 4
		syscall

		beq $t8, 0x59, bigCiclo
		beq $t8, 0x79, bigCiclo

		beq $t8, 0x4e, fin
		beq $t8, 0x6e, fin
		b preg
	
fin:		la $a0, guar
		li $v0, 4
		syscall
		li $v0, 10
		syscall

HS:		la $a0, HighScore
		li $v0, 4
		syscall

		beq $t8, 0, finHS
		la $a0, leIn
		li $v0, 4
		syscall
finHS:		b leerC