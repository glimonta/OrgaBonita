	.data
valores:	.word 1,2,3,4
inicio:		.word 0, 0, 0 ,0 	
minicio:			.asciiz "Comienzo del programa\n"
mfin:       .asciiz "Fin del programa\n"
linea:       .asciiz "\n"
val:        .asciiz "Valor = "
nciclo:     .asciiz "  Ciclo = " 
seed1:       .word   0x 10111001
seed2:       .word   0x 10111001

	.text
	#  Programa que realiza el calculo de numeros aleatorios
	#  Modificado a partir de un programa para generar los números pseudo­aleatorios basado en el Algoritmo de Tausworthe
	#  Tomado de la siguiente fuente: http://www.eweb.unex.es/eweb/fisteor/antonio_astillero/ec/spim/ENUNCIADO_PRACTICA_SPIM_2006_07.pdf
	
main:
	la $a0, minicio
	li $v0, 4
	syscall
    li $t1, 50
    li $t2, 0xB9  # load seed1, cargar la semilla1
	li $t7 , 20   # numero de valores aleatorio que se generaran
	li $t8, 10    # Rango de los valores aleatorios a generar, de 0 a 10, esto fue modificado del algoritmo original
ciclo1:	

ciclo2:
	srl $t3, $t2, 3    #  
	xor $t4, $t3, $t2
	sll $t5, $t4, 5
	xor $t6, $t5, $t4
	addi $t1, $t1, -1
	
	move $t2, $t6

	                  # ciclo interno para el calculo de un valor aleatorio
	bgtz $t1, ciclo2  # este ciclo interno se ejecuta 50 veces para producir un número peudo-aleatorio
    div $t6, $t8      
    mfhi $t9	      # se obtiene el modulo para reducir la cantidad de valores aletaorios a generar
	abs $t9, $t9      # se calcula el valor absoluto para solo generar valores positivos
	
	#  Esta seccion de aqui en adelante simplemente imprime uno de los 20 valores aleatorios que el programa genera
	la $a0, val
	li $v0, 4
	syscall
	
	move $a0, $t9
	li $v0, 1
	syscall
	
	la $a0, nciclo
	li $v0, 4
	syscall
	
	move $a0, $t7
	li $v0, 1
	syscall
	
	la $a0, linea
	li $v0, 4
	syscall
	
	
	addi $t7, $t7, -1
	
	bgtz $t7, ciclo1 # Ciclo para calcular varios (20) valores aleatorio diferentes
	
	
	la $a0, mfin     # Se imprime un mensaje de Fin del Programa
	li $v0, 4
	syscall
   
    li    $v0, 10
    syscall
   