# HighScore.s : Programa que lee de un archivo las tres primeras posiciones
# con las mayores puntuaciones, almacena en memoria y luego compara con nuevas
# puntuaciones. Si las nuevas son mayores la informacion en memoria se 
# reemplaza
#
# Autores:
#
# Gabriela Limonta
# Carnet: 10-10385
# 
# Luis Miranda
# Carnet: 10-10463
#
# Planificacion de registros:
#
# t0: file descriptor
# t1: primera puntuacion
# t2: segunda puntuacion
# t3: tercera puntuacion
# t4: temporal para mover cosas de lado a lado

.data

nomArch:	.asciiz "score.txt"
prim:		.space 10
seg:		.space 10
ter:		.space 10
buf:		.space 32


.text

main:	la $a0, nomArch
	li $v0, 13
	li $a1, 0x0
	syscall

	move $t0, $v0

	la $t1, prim
	la $t2, seg
	la $t3, ter

leer1:	move $a0, $t0
	la $a1, buf
	li $a2, 1
	li $v0, 14
	syscall

	blez $v0, finLec

	la $a0, buf
	li $v0, 4
	syscall

	lb $t4, 0($a0)
	sb $t4, 0($t1)

	addi $t1, $t1, 1
	
	b leer1

leer2:	move $a0, $t0
	la $a1, buf
	li $a2, 1
	li $v0, 14
	syscall

	blez $v0, finLec

	la $a0, buf
	li $v0, 4
	syscall

	lb $t4, 0($a0)
	sb $t4, 0($t2)

	addi $t2, $t2, 1
	
	b leer2

leer3:	move $a0, $t0
	la $a1, buf
	li $a2, 1
	li $v0, 14
	syscall

	blez $v0, finLec

	la $a0, buf
	li $v0, 4
	syscall

	lb $t4, 0($a0)
	sb $t4, 0($t3)

	addi $t3, $t3, 1
	
	b leer3

finLec:	li $v0, 10
	syscall
