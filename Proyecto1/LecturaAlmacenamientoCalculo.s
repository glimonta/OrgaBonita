# Proyecto1.s: Juego Mastermind.
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
# t1: contador para los digitos de numCod y numInt
# t2: direccion de numInt
# t3: direccion de numCod
# t4: byte actual que leemos
# t5: direccion de la memoria asignada por el sistema para los codigos
# t6: temporal para movernos por los codigos
# t7: maximo de intentos
# t8: contador que por comodidad se carga en ASCII
# t9: contador para los caracteres que ingresa el jugador, se usa como 
#     contador de la posicion de la entrada tambien
# s0: almacena la direccion de leIn (la entrada)
# s1: temporal que guarda los caracteres que introduce el jugador
# s2: contador de la posicion del codigo actual
# s3: lo utilizamos para movernos por el contenido del codigo actual
# s4: lo utilizamos para movernos por el contenido del codigo introducido
#     por el jugador
# s5: cantidad de aciertos que tiene el jugador

.data

nomArch:	.asciiz "aci.txt"
espacio: 	.asciiz " "
error:		.asciiz "\n EROOR: No se ha leido un numero :("
finDeArch:	.asciiz "\n Archivo cargado con exito! :D \n"
HighScore:	.asciiz "\n Deberia imprimir los tres mejores, \n pero no lo hago porque soy idiota :(\n"
salida1: 	.asciiz "Intento #"
linea:		.asciiz "\n"
blanco:		.asciiz "B "
negro:		.asciiz "N "
ninguno: 	.asciiz "X "
preguntaFinal:	.asciiz "\n¿Quieres jugar otra vez? :D (y/n)\n"
preguntaNombre: .asciiz "¿Como te llamas? \n"
buf:	 	.space 32
numInt:	 	.space 8
numCod: 	.space 8
leIn:		.space 5
nombre:		.space 8

		.align 2

.text

######################################################
#                                                    #
#  Lectura y Almacenamiento del archivo aci.txt      #
#                                                    #
######################################################

main:	la $a0, nomArch		#guardo el nombre del archivo en a0
	li $v0, 13		#indico que abrire
	li $a1, 0x0		#indico que solo será para lectura
	syscall

	move $t0, $v0		#guardo el file descriptor en t0
	
	la $t2, numInt		#cargo direccion de numInt
	la $t3, numCod		#cargo direccion de numCod
	li $t1, 0		#inicializo contador en cero

leer1:	move $a0, $t0		#muevo file descriptor a a0
	la $a1, buf		#indico la direccion del buffer
	li $a2, 1		#indico que leere un byte
	li $v0, 14		#indico que leere
	syscall

	blez $v0, finLec	#si lo que retorna en v0 es 0 => fin de
				#archivo y si es -1 => ERROR

	la $a0, buf		#esto es para imprimir lo que lei
	li $v0, 4		#en el buffer, no es relevante para el
	syscall 		#codigo final del proyecto

	lb $t4, 0($a0)		#not quite sure if this works
	sb $t4, 0($t2)		#cargo el byte que tengo en el buffer 
				#almaceno en t2 que es numInt

	addi $t2, $t2, 1 	#movemos numInt 1 byte
	addi $t1, $t1, 1	#aumentamos en 1 el contador

	beq $t4, 0xa, checkInt	#si es un salto de linea pasamos a la conversion
	
	blt $t4, 0x30, ErrorLectura
	bgt $t4, 0x39, ErrorLectura

	b leer1

checkInt: 	beq $t1, 3, checkInt2 	#si tiene 2 digitos va a check2 
		la $t2, numInt		#cargamos la direccion de numInt
		lb $t4, 0($t2)		#cargamos el numero en ascii en t4
		addi $t4, $t4, -48	#restamos 48 para que nos de el entero
		sb $t4, 0($t2)		#lo guardamos de nuevo en numInt

		li $t1, 0		#reiniciamos el contador
		b leer2			#saltamos a leer2

checkInt2:	la $t2, numInt		#cargamos la direccion de numInt
		lb $t4, 1($t2)		#cargamos el segundo digito del numero en t4
		addi $t4, $t4, -38 	#como tiene dos digitos se le resta 48 y se suman 10
		sb $t4, 0($t2)		#lo guardamos de nuevo en numInt
		li $t1, 0		#reiniciamos el contador

leer2:	move $a0, $t0		#muevo file descriptor a a0
	la $a1, buf		#indico la direccion del buffer
	li $a2, 1		#indico que leere un byte
	li $v0, 14		#indico que leere
	syscall

	blez $v0, finLec	#si lo que retorna en v0 es 0 => fin de
				#archivo y si es -1 => ERROR

	la $a0, buf		#esto es para imprimir lo que lei
	li $v0, 4		#en el buffer, no es relevante para el
	syscall 		#codigo final del proyecto

	lb $t4, 0($a0)		#cargo en t4 lo que hay en el buf
	sb $t4, 0($t3)		#almaceno en numCod el digito

	addi $t1, $t1, 1	#aumento en 1 el contador
	addi $t3, $t3, 1 	#movemos numCod 1 byte

	beq $t4, 0xa, checkCod 	#si es un salto de linea vamos a checkCod

	blt $t4, 0x30, ErrorLectura
	bgt $t4, 0x39, ErrorLectura

	b leer2

checkCod: 	beq $t1, 3, checkCod2 	#si tiene 2 digitos va a check2 
		la $t3, numCod		#cargamos la direccion de numInt
		lb $t4, 0($t3)		#cargamos el numero en ascii en t4
		addi $t4, $t4, -48	#restamos 48 para que nos de el entero
		sb $t4, 0($t3)		#lo guardamos de nuevo en numInt

		li $t1, 0		#reiniciamos el contador
		b pedirEspacio		#saltamos a pedirEspacio

checkCod2:	la $t3, numCod		#cargamos la direccion de numInt
		lb $t4, 1($t3)		#cargamos el segundo digito del numero en t4
		addi $t4, $t4, -38 	#como tiene dos digitos se le resta 48 y se suman 10
		sb $t5, 0($t3)		#lo guardamos de nuevo en numInt
		li $t1, 0		#reiniciamos el contador

pedirEspacio: 	lb $t4, numCod		#cargamos el numCod en t4
		mul $t4, $t4, 5		#multiplicamos por 4 (esto se puede hacer distintos con sll)
		
		move $a0, $t4		#movemos a a0 cuanto espacio queremos del sistema
		li $v0, 9		#pedimos el espacio
		syscall

		la $t5, 0($v0)
		move $t6, $t5

leer3: 	move $a0, $t0		#muevo file descriptor a a0
	la $a1, buf		#indico la direccion del buffer
	li $a2, 1		#indico que leere un byte
	li $v0, 14		#indico que leere
	syscall

	blez $v0, finLec	#si lo que retorna en v0 es 0 => fin de
				#archivo y si es -1 => ERROR

	la $a0, buf		#esto es para imprimir lo que lei
	li $v0, 4		#en el buffer, no es relevante para el
	syscall 		#codigo final del proyecto

	lb $t4, 0($a0)		#cargo en t4 lo que hay en el buf
	sb $t4, 0($t6)		#almaceno en t6 (memoria donde estan los codigos)

	beq $t4, 0xa, leer4	#si es un salto de linea va a leer4

	blt $t4, 0x30, ErrorLectura
	bgt $t4, 0x39, ErrorLectura

	addi $t6, $t6, 1	#sumamos 1 a la direccion de los codigos
	
	b leer3			#saltamos a leer3 (ciclo)

leer4:	addi $t6, $t6, 1 	#cuando es salto de linea agregamos 1 a t6 
	b leer3			#y regresamos a leer3

ErrorLectura: 	la $a0, error	#imprimimos mensaje de error
		li $v0, 4
		syscall

finLec:	la $a0,finDeArch	#imprimo mensaje de que lei el archivo
	li $v0, 4
	syscall

	move $a0, $t0		#cierro el archivo
	li $v0, 16
	syscall

	#li $v0, 10		#terminamos el programa, for now.
	#syscall	

######################################################

######################################################
#                                                    #
# 	    Comienzo del juego y calculo             #
#                                                    #
######################################################

inic:	lb $t7, numInt	#cargamos el max de intentos en t7
	li $t8, 0x31	#cargamos el 1 en ASCII por comodidad (contador)
	
	la $a0, preguntaNombre	#preguntamos el nombre del jugador
	li $v0, 4
	syscall

	li $v0, 8		#lee los 8 bytes de la entrada y los
	la $a0, nombre		#almacena en nombre
	li $a1, 8
	syscall

	move $t6, $t5 		#asigno a t6 la direccion que esta en t5 (codigos)

bigCiclo:	la $a0, salida1	#imprimimos que intento es
		li $v0, 4
		syscall
		
		move $a0, $t8	#movemos el numero de intento a a0
		li $v0, 11	#imprimir char
		syscall

		la $a0, linea
		li $v0, 4
		syscall

		la $s0, leIn	#cargamos el espacio para lo dado por el usuario
		li $t9, 0	#inicializamos contador en cero

#####################################################################
#vamos leyendo uno a uno los caracteres que intenta poner el usuario#
#que se almacenan en leIn                                           #
#####################################################################

leerC:	li $v0, 12 		#leemos caracter
	syscall

	beq $v0, 0x51, preg	#si es Q pregunta si quiere salir del juego
	beq $v0, 0x71, preg	#si es q pregunta si quiere salir del juego
	beq $v0, 0x45, HS	#si es E muestra los highscores
	beq $v0, 0x65, HS	#si es e muestra los highscores

	move $s1, $v0 		#movemos el caracter a s1
	sb $s1, 0($s0)		#almacenamos el caracter de s1 a leIn

	addi $s0, $s0, 1	#movemos 1byte la direccion de s0
	addi $t9, $t9, 1	#aumentamos en uno el contador

	bne $t9, 4, leerC	#repite el ciclo hasta que lea 4 char
	
	move $a0, $s0		#aun no se para que es esto
	li $v0, 4
	syscall

	la $s0, leIn		#ni esto

	li $t9, 0 		#inicializamos contador pos codig
	li $s2, 0		#inicializamos contador	pos entrada

	la $a0, linea
	li $v0, 4
	syscall


######################################################
#                                                    #
# 	        Ciclo de comparacion:                #
#                                                    #
#  Este ciclo compara lo que introduce el jugador    #
#  y va comparando con los caracteres del codigo     #
#  actual, si consigue que son iguales, compara los  #
#  indices respectivos (posicion en el codigo). Si   #
#  son iguales escribe "N", si son diferentes        #
#  escribe "B" y si no consigue el numero imprime    #
#  "X".                                              #
######################################################

ciclo:	lb $s3, 0($t6)	#cargamos el elemento actual del codigo actual
	lb $s4, 0($s0)	#cargamos el elemento actual del codigo de entrada
	
	beq $s3, $s4, AeqB 	#primer condicional si son iguales
	b else

AeqB:	beq $s2, $t9, XeqY	#segundo condicional si los indices son iguales

	b cAeqB

XeqY:	la $a0, negro		#imprimo negro
	addi $s5, $s5, 1	

cAeqB:	lb $s3, 0($t6)		# que carrizo hace esto?

	li $t9, 0

	la $a0, blanco		#imprimo blanco
	li $v0, 4
	syscall

	addi $s2, $s2, 1	#aumento el contador de la pos del cod de entrada
	addu $s0, $s0, 1	#me muevo 1byte en el codigo de entrada

	move $t6, $t5

	b finCiclo

else: 	addi $t9, $t9, 1	#aumento el contador de la posicion del codigo actual
	addu $t6, $t6, 1	#me muevo 1byte en el codigo actual

	bne $t9, 4, finCiclo 	#si ya reviso los 4 numeros sale

	la $a0, ninguno 	#imprimo "X"
	li $v0, 4
	syscall

	addi $s2, $s2, 1	#aumento el contador de la pos del codigo de entrada
	addu $s0, $s0, 1	#me muevo 1 byte en el codigo de entrada

	lb $s3, 0($t6)		#cargo el codigo actual en s3
	li $t9, 0
	
	move $t6, $t5

finCiclo:	blt $s2, 4, ciclo
	
		la $a0, linea
		li $v0, 4
		syscall
	
		beq $s5, 4, fin
		
		addi $t8, $t8, 1

		li $s5, 0

		bgt $t8, $t7, fin

# LIMPIAMOS EL LE IN

		li $s2, 0
		la $s0, leIn

clean:	sb $zero, 0($s0)
	addi $s0, $s0, 1
	addi $s2, $s2, 1
	
	bne $s2, 4, clean	#sale cuando haya limpiado todo leIn

	b bigCiclo
	
	la $a0, linea
	li $v0, 4
	syscall

preg:	la $a0, preguntaFinal
	li $v0, 4
	syscall

	li $v0, 12
	syscall

	move $s1, $v0

	la $a0, linea
	li $v0, 4
	syscall

	beq $s1, 0x59, bigCiclo
	beq $s1, 0x79, bigCiclo

	beq $s1, 0x4e, fin
	beq $s1, 0x6e, fin

	b preg

fin:	move $a0, $t5
	li $v0, 4
	syscall

	li $v0, 10
	syscall

HS: 	la $a0, HighScore
	li $v0, 4
	syscall

	beq $s1, 0, finHS
	la $a0, leIn
	li $v0, 4
	syscall

finHS: b leerC
