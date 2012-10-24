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
# $s1 numIntentos
# $s3 puntaje
# $s5 archivo escribir
# $s6 dummy
# $s7
#
	
maxIntentos:	.word 5
guar:		.asciiz "7845"
numCod:		.space 5
dummy:		.asciiz "  "
HighScore:	.asciiz "\nDeberia imprimir los 3 mejores,\n pero no lo hago por que soy idiota\n"

leIn:		.space 7

salida1:	.asciiz "Intento #"
ln:		.asciiz "\n"
blanco:		.asciiz "B "
negro:		.asciiz "N "
ninguno:	.asciiz "X "

PreguntaFinal:	.asciiz "\nQuieres jugar otra vez? [y,n]\n"

PreguntaNombre:	.asciiz "Cual es tu nombre? \n"
Nombre:		.space 8

arch:		.asciiz "./score.txt"

		.align 2
	
		.text

main:
#######################################
		lb $t9, maxIntentos
		li $s1, 1 # Como es un contador, por comodidad se carga el 0 en ASCII

# Pregunta y carga el nombre del jugador 
		la $a0, PreguntaNombre
		li $v0, 4
		syscall		

		li $v0, 8
		la $a0, Nombre
 		li $a1, 8
		syscall

		li $s3, 0x30

# Aqui es donde la magia comienza
bigCiclo:
######################################## (<= Se~al de que la magia comienza)

# Se imprime que por que intento va
	
		la $a0, salida1
		li $v0, 4
		syscall

		move $a0, $s1
		li $v0, 1
		syscall

		la $a0, ln
		li $v0, 4
		syscall

		la $t2, leIn
		li $t8, 0
	
###############################################################
# Lee el intento del usuario, revisando cada char (se guarda en leIn)
# 
# Aqui se usan los registros distintos de como sale arriba
# Because fuck you
#
# Creo que:
#
# $t2 es el registro hacia leIn
# $t5 se usa como intermediario para guardar las cosas
# $t8 es un contador
#

leerC:		li $v0, 12
		syscall

		beq $v0, 0x51, preg # 0x51 = Q si es Q se sale del juego
		beq $v0, 0x71, preg # 0x71 = q
		beq $v0, 0x45, HS # 0x45 = E si es E muestra Highscore
		beq $v0, 0x65, HS # 0x65 = e
	
		move $t5, $v0
		sb $t5, 0($t2)
		
		addi $t2, $t2, 1
		addi $t8, $t8, 1
	
		bne $t8, 4, leerC # cuando revisa 4 char se sale se sale

		move $a0, $t2
		li $v0, 4
		syscall

		la $t2, leIn
# Usted esta dejando el vacio legal donde se siguen usando
# los registros de arriba, vaya con dios
###########################################################

		la $t5, guar # se carga el codigo que tienen que adivinar

# se inicializan contadores
	
		li $t7, 0 
		li $t8, 0

		la $a0, ln #<= NEW LINE
		li $v0, 4
		syscall
#
# Como no estoy seguro de que hice hago una introduccion:
#
# El "ciclo" recorre lo que introdujo el usuario y va comparando
# con los caracteres del codigo, si consigue que son iguales,
# compara los indices respectivos (que representan la posicion en el codigo)
# si son iguales escribe "N", diferentes "B", si no consigue el numero
# imprime "X"
#

ciclo:		lb $t4, 0($t5)		

		lb $t6, 0($t2)
	
		beq $t4, $t6, AeqB # primer "IF" si son iguales
		b else
	
AeqB:		beq $t7, $t8, XeqY # segundo "IF" si los indices son iguales
		la $a0, blanco
		b cAeqB
	
XeqY:		la $a0, negro
		addi $t3, $t3, 1
cAeqB:		lb $t4, 0($t5)
		li $t8, 0

		li $v0, 4
		syscall
	
		addi $t7, $t7, 1 
		addu $t2, $t2, 1

		la $t5, guar 
	
		b finCiclo

else:		addi $t8, $t8, 1
		addu $t5, $t5, 1

		bne $t8, 4, finCiclo # si ya revise los 4 numeros me voy

		la $a0, ninguno
		li $v0, 4
		syscall

		addi $t7, $t7, 1
		addu $t2, $t2, 1

		lb $t4, 0($t5)

		li $t8, 0

		la $t5, guar
	
		b finCiclo
	
finCiclo:	blt $t7, 4, ciclo
	
		la $a0, ln
		li $v0, 4
		syscall

		beq $t3, 4, preg

		addi $s1, $s1, 1

		li $t3, 0

		bgt $s1, $t9, preg

###############################################
# limpia el leIn
#
# El mismo peo con los registros
# No me juzgues
#
# $t5 es el que esta con leIn
# $t8 contador
#
		li $t8, 0
		la $t5, leIn

clean:		sb $zero, 0($t5)
		addi $t5, $t5, 1
		addi $t8, $t8, 1
		bne $t8, 4, clean # mientras no recorra todo leIn no se va
#
######################################

		b bigCiclo

		la $a0, ln
		li $v0, 4
		syscall
##########################################
#
# ESTE ESTA COMPLETAMENTE ENTENDIBLE NO ME #!(^$%!#$
# ESTO FUE LO QUE CAMBIASTE PARA LO DEL PUNTAJE
	
preg:		bne $t3, 4, noAdivino

		beq $s1, $t9, enLaUltima
		add $s3, $s3, 2
		b noAdivino
enLaUltima:	add $s3, $s3, 1

noAdivino:	la $a0, Nombre
		li $v0, 4
		syscall
	
		move $a0, $s3
		li $v0, 11
		syscall

		la $a0, PreguntaFinal
		li $v0, 4
		syscall

		li $v0, 12
		syscall

		move $t8, $v0

		la $a0, ln
		li $v0, 4
		syscall

		li $s1, 1
		li $t3, 0

		beq $t8, 0x59, bigCiclo
		beq $t8, 0x79, bigCiclo

		beq $t8, 0x4e, fin
		beq $t8, 0x6e, fin
		b preg
	
##################################################
	
fin:		la $a0, guar
		li $v0, 4
		syscall
		

abrirEsc:	la $a0, arch #open nombre del archivo
		li $a1, 0x102 # 0x109 = 0x100 Create + 0x8 Append + 0x1 Write
		li $a2, 0x1FF # Mode 0x1FF = 777 rwx rwx rwx

		li $v0, 13 #open
		syscall

		move $s5, $v0
		bgt  $v0, $zero, escribir  # si lo consigui escribir

		la	$a0, arch    ## open nombre del archivo
		li	$a1, 0x41C2   ##  41C2 Permite la cracion del archivo 
		li	$a2, 0x1FF    ##  Mode 0x1FF = 777 rwx rwx rwx

		li $v0, 13			# open syscall
		syscall

		move	$a0, $v0
		li $v0, 16			# close
		syscall

        	b abrirEsc

escribir:	la $s6, dummy

#		move	$t1, $v0
		move	$a0, $s5 #le pasas el nombre del archivo

		sb $s3, 0($s6)
	
		la $a1, dummy
		li $a2, 2        # Max nummero de bytes a escribir
 		li $v0, 15			# write
 		syscall

		move	$a0, $s5
		la $t8, Nombre


contar:	lb $t4, 0($t8) 
	beq $t4, 0xa, sali # me calcula el espacio exacto de la palabra
	beq $t4, $zero sali # para no usar espacio de mas y que escriba bien
	addi $s7, $s7, 1
	addi $t8, $t8, 1
	b contar

sali:	la $a1, Nombre
	move $a2, $s7        # Max nummero de bytes a escribir
 	li $v0, 15			# write
 	syscall
	
	li $v0, 10
	syscall
	
##############################################
#
# una de las cosas que falta xD
#
HS:		la $a0, HighScore
		li $v0, 4
		syscall

		beq $t8, 0, finHS
		la $a0, leIn
		li $v0, 4
		syscall
finHS:		b leerC
