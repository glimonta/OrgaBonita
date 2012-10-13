OPEN = 13
READ = 14
WRITE = 15
CLOSE = 16

.data

buf: 		.space 32
buf2:		.space 32

nombArch:	.asciiz "aci.txt"
espacio:	.asciiz " "

finDeArch: 	.asciiz "\n y se acabo n_n "



.text

main:	la $a0, nombArch	#guardo el nombre del archivo en a0
	li $v0, OPEN		#indico que voy a abrir
	li $a1 0x0		#indico que solo abrire para lectura
	syscall

	move $t0, $v0 		#guardo el file descriptor en t0

	la $t1, buf2		#guardamos la direccion del buffer 2


ciclo:	move $a0, $t0		#copio el file descriptor en a0 para 
	la $a1, buf		#empezar a leer el archivo y le indico
	li $a2, 1		#tambien la direccion del buffer. 
	li $v0, READ		#y la cantidad de bytes que leere
	syscall

	blez $v0, fin		#si lo que retorna en v0 es 0 significa
				#que es el fin del archivo y si es -1
				#significa que hubo un error

	la $a0, espacio		#imprimo un espacio
	li $v0, 4
	syscall

	la $a0, buf		#imprimo lo que hay en el buffer
	li $v0, 4
	syscall

	lb $t2, 0($a0)		#colocamos en t2 el contenido del buffer
	
	sb $t2, 0($t1)		#guardamos en memoria en el buffer2

	addi $t2, $t2, 1 	#movemos 1 byte buf2

	la $a0, espacio
	li $v0, 4
	syscall
	
	b ciclo			#sigue repitiendo el ciclo hasta que
				#pueda salir por final de archivo o error	
	
fin:	la $a0, finDeArch
	li $v0, 4
	syscall

	move $a0, $t0		#muevo el file descriptor para proceder
	li $v0, CLOSE		#a cerrar el archivo
	syscall
	
	li $v0, 10		#fin del programa
	syscall
