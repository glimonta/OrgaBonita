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
#
	
maxIntentos:	.asciiz "5"
guar:		.asciiz "1476"
numCod:		.space 5

salida1:	.asciiz "Intento #"
ln:		.asciiz "\n"
blanco:		.asciiz "B "
negro:		.asciiz "N "
ninguno:	.asciiz "X "


		.align 2
	
		.text

main:
		lb $t9, maxIntentos

		la $a0, salida1
		li $v0, 4
		syscall

bigCiclo:
		li $v0, 8
		la $a0, numCod
 		li $a1, 5
		syscall
		move $t2, $a0

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
	
		addi $t9, $t9, -1
		li $t3, 0
	
		beq $t9, 48, fin
		b bigCiclo

fin:		la $a0, ln
		li $v0, 4
		syscall

		
		
		la $a0, guar
		li $v0, 4
		syscall
		li $v0, 10
		syscall