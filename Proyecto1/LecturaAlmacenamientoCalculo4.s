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
# t1: contador para los digitos de numCod y numInt // puntaje
# t2: direccion de numInt // temporal para copiar la puntuacion nueva a nuev
# t3: direccion de numCod // temporal para almacenar las puntuaciones en memoria
# t4: byte actual que leemos // temporal que se le pasa a la funcion 
# transf para decir cuando digitos tiene el numero
# t5: direccion de la memoria asignada por el sistema para los codigos //
# almacena las direcciones de prim, seg y ter
# t6: temporal para movernos por los codigos // dummy de escritura
# t7: maximo de intentos // temporal que se le pasa a la funcion de trasnformar
# con la direccion del numero
# t8: contador del numero de intento actual
# t9: contador para los caracteres que ingresa el jugador, se usa como 
#     contador de la posicion de la entrada tambien
# s0: almacena la direccion de leIn (la entrada) // retorno de la funcion
# transformar
# s1: temporal que guarda los caracteres que introduce el jugador
# s2: contador de la posicion del codigo actual
# s3: lo utilizamos para movernos por el contenido del codigo actual
# s4: lo utilizamos para movernos por el contenido del codigo introducido
#     por el jugador
# s5: cantidad de aciertos que tiene el jugador // almacena las direcciones de
# pun1, pun2 y pun3
# s6: almacena el numero de partida
# s7: almacena la direccion del codigo actual // contador de espacio

.data

                .align 4
partida:        .word 0
codigos:        .word 0
nomArch:        .asciiz "aci.txt"
archScore:      .asciiz "score.txt"
espacio:        .asciiz " "
error:          .asciiz "\n ERROR: No se ha leido un numero :("
finDeArch:      .asciiz "\n Archivo cargado con exito! :D \n"
HighScore:      .asciiz "\n Deberia imprimir los tres mejores, \n pero no lo
hago porque soy idiota :(\n"
salida1:        .asciiz "Intento #"
linea:          .asciiz " \n"
blanco:         .asciiz "B "
negro:          .asciiz "N "
ninguno:        .asciiz "X "
preguntaFinal:  .asciiz "\nQuieres jugar otra vez? :D (y/n)\n"
preguntaNombre: .asciiz "Como te llamas? \n"
default:        .asciiz "0 \n"
highs:          .asciiz "HIGHSCORES: \n"
mensajeFHS:     .asciiz "Puedes continuar adivinando ahora :D \n"
puntu:          .asciiz "Puntuacion: "
jugad:          .asciiz "Jugador: "
cero:           .asciiz "0"
buf:            .space 32
numInt:         .space 8
numCod:         .space 8
leIn:           .space 5
nombre:         .space 8
codAct:         .space 4
prim:           .space 14
seg:            .space 14
ter:            .space 14
nuev:           .space 14
pun1:           .word 0
pun2:           .word 0
pun3:           .word 0
punN:           .space 2
buf2:           .space 2
dummy:          .asciiz "  "
                .align 4

.text

######################################################
#                                                    #
#  Lectura y Almacenamiento del archivo aci.txt      #
#                                                    #
######################################################

main:   la $a0, nomArch         #guardo el nombre del archivo en a0
        li $v0, 13              #indico que abrire
        li $a1, 0x0             #indico que solo será para lectura
        syscall

        move $t0, $v0           #guardo el file descriptor en t0
        
        la $t2, numInt          #cargo direccion de numInt
        la $t3, numCod          #cargo direccion de numCod
        li $t1, 0               #inicializo contador en cero

leer1:  move $a0, $t0           #muevo file descriptor a a0
        la $a1, buf             #indico la direccion del buffer
        li $a2, 1               #indico que leere un byte
        li $v0, 14              #indico que leere
        syscall

        blez $v0, finLec        #si lo que retorna en v0 es 0 => fin de
                                #archivo y si es -1 => ERROR

        la $a0, buf     #esto es para imprimir lo que lei
        li $v0, 4       #en el buffer, no es relevante para el
        syscall         #codigo final del proyecto

        lb $t4, 0($a0)          #not quite sure if this works
        sb $t4, 0($t2)          #cargo el byte que tengo en el buffer 
                                #almaceno en t2 que es numInt

        addi $t2, $t2, 1        #movemos numInt 1 byte
        addi $t1, $t1, 1        #aumentamos en 1 el contador

        beq $t4, 0xa, checkInt  #si es un salto de linea pasamos a la conversion
        
        blt $t4, 0x30, ErrorLectura
        bgt $t4, 0x39, ErrorLectura

        b leer1

checkInt:       la $t2, numInt          #cargamos en t2 la direccion de numInt
                move $t7, $t2           #movemos a t7 la direccion del numero a
                                        #transformar
                move $t4, $t1           #movemos a t4 la cantidad de digitos
                                        #del numero
                
                jal transf              #llamamos a la funcion transformar
                
                sb $s0, 0($t2)          #guardamos el entero en la dir de numInt

                move $t1, $zero         #reiniciamos el contador

leer2:  move $a0, $t0           #muevo file descriptor a a0
        la $a1, buf             #indico la direccion del buffer
        li $a2, 1               #indico que leere un byte
        li $v0, 14              #indico que leere
        syscall

        blez $v0, finLec        #si lo que retorna en v0 es 0 => fin de
                                #archivo y si es -1 => ERROR

        la $a0, buf             #esto es para imprimir lo que lei
        li $v0, 4               #en el buffer, no es relevante para el
        syscall                 #codigo final del proyecto

        lb $t4, 0($a0)          #cargo en t4 lo que hay en el buf
        sb $t4, 0($t3)          #almaceno en numCod el digito

        addi $t1, $t1, 1        #aumento en 1 el contador
        addi $t3, $t3, 1        #movemos numCod 1 byte

        beq $t4, 0xa, checkCod  #si es un salto de linea vamos a checkCod

        blt $t4, 0x30, ErrorLectura
        bgt $t4, 0x39, ErrorLectura

        b leer2

checkCod:       la $t3, numCod  #cargamos la direccion de numCod en t3
                move $t7, $t3   #movemos a t7 la direccion de numCod
                move $t4, $t1   #movemos a t4 el contador de los digitos del num
                
                jal transf      #llamamos a la funcion
                
                sb $s0, 0($t3)  #almacenamos en numCod el numero entero
                move $t1, $zero #reiniciamos el contador
                move $t4, $zero #limpiamos t4 
                move $t7, $zero #limpiamos s7

pedirEspacio:   lb $t4, numCod          #cargamos el numCod en t4
                sll $t4, $t4, 2         #multiplicamos por 4 
                
                move $a0, $t4           #movemos a a0 cuanto espacio queremos
                                        #del sistema
                li $v0, 9               #pedimos el espacio
                syscall

                la $t5, 0($v0)
                sw $t5, codigos
                lw $t6, codigos

leer3:  move $a0, $t0           #muevo file descriptor a a0
        la $a1, buf             #indico la direccion del buffer
        li $a2, 1               #indico que leere un byte
        li $v0, 14              #indico que leere
        syscall

        blez $v0, finLec        #si lo que retorna en v0 es 0 => fin de
                                #archivo y si es -1 => ERROR

        la $a0, buf             #esto es para imprimir lo que lei
        li $v0, 4               #en el buffer, no es relevante para el
        syscall                 #codigo final del proyecto

        lb $t4, 0($a0)          #cargo en t4 lo que hay en el buf

        beq $t4, 0xa, leer3     #si es un salto de linea va a leer3

        sb $t4, 0($t6)          #almaceno en t6 (memoria donde estan los
                                #codigos)

        blt $t4, 0x30, ErrorLectura
        bgt $t4, 0x39, ErrorLectura

        addi $t6, $t6, 1        #sumamos 1 a la direccion de los codigos
        
        b leer3                 #saltamos a leer3 (ciclo)

ErrorLectura:   la $a0, error	#imprimimos mensaje de error
                li $v0, 4
                syscall

		li $v0, 10
        	syscall

finLec: la $a0,finDeArch        #imprimo mensaje de que lei el archivo
        li $v0, 4
        syscall

        move $a0, $t0           #cierro el archivo
        li $v0, 16
        syscall

#####################################################
#                                                   #
#              Carga del HighScore                  #
#                                                   #
#    Aqui utilizamos t2 para almacenar la direccion #
#  de prim, seg y ter mientras vamos leyendo el     #
#  archivo. Usamos t0 para el file descriptor.      #
#  tambien utilizamos t4 como temporal para mover   #
#  lo que leo del archivo que esta en el buffer a   #
#  su espacio de memoria correspondiente.           #
#                                                   #
#####################################################

cargaHS:
        la $a0, archScore       #guardamos el nombre del archivo en a0
        li $v0, 13              #indicamos que abriremos
        li $a1, 0x0             #indicamos que solo será para lectura
        syscall

        move $t0, $v0           #guardamos el file descriptor en t0
        bgt $v0, $zero, inter1  #si conseguimos el archivo nos vamos a inter1
        
        la $a0, archScore       #indicamos el nombre del archivo
        li $a1, 0x41c2          #41c2 permite la creacion del archivo
        li $a2, 0x1FF           #Mode 0x1FF = 777 rwx rwx rwx
        
        li $v0, 13              #indicamos que abriremos
        syscall

#############################################################################
        
        la $a0, archScore       # open nombre del archivo
        li $a1, 0x102           #(flags are 0: read, 1: write) 0x109 = 0x100
                                #Create + 0x8 Append + 0x1 Write
        li $a2, 0x1FF           #Mode 0x1FF = 777 rwx rwx rwx

        li $v0, 13              # open syscall
        syscall

        move $t0, $v0        
        
        #Aqui procederemos a inicializar las puntuaciones maximas en cero
        #ya que es la primera vez que se juega y el archivo score.txt 
        #no existe.

        move $a0, $t0
        
        la $a1, default         #indicamos que escribiremos lo que hay en
                                #default en el archivo
        li $a2, 3               #indicamos el maximo de bytes a escribir
        li $v0, 15              #indicamos que escribiremos
        syscall
        
        la $a1, default         #indicamos que escribiremos lo que hay en
                                #default en el archivo
        li $a2, 3               #indicamos el maximo de bytes a escribir
        li $v0, 15              #indicamos que escribiremos
        syscall
        
        la $a1, default         #indicamos que escribiremos lo que hay en
                                #default en el archivo
        li $a2, 3               #indicamos el maximo de bytes a escribir
        li $v0, 15              #indicamos que escribiremos
        syscall
        
        move $a0, $t0           #movemos el file descriptor a a0
        li $v0, 16              #indicamos que cerraremos
        syscall
        
        #abrimos nuevamente el archivo para leerlo
        
        la $a0, archScore       #guardamos el nombre del archivo en a0
        li $v0, 13              #indicamos que abriremos
        li $a1, 0x0             #indicamos que solo será para lectura
        syscall
        
        move $t0, $v0           #movemos el file descriptor a t0
        
inter1: la $t2, prim            #cargamos la direccion de prim en t2
        
read1:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf2            #indicamos la direccion de buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall

        blez $v0, finCargaHS    #si es el final del archivo nos vamos a
                                #intermedPunt

        la $a0, buf2             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos el byte del buffer en t4
	beq $t4, $zero, jump1
        sb $t4, 0($t2)          #guardamos este byte en la direccion de prim
jump1:	
        beq $t4, 0xa, inter2    #si llegamos al salto de linea nos vamos
                                #a inter2

        addi $t2, $t2, 1        #nos movemos 1 byte en la direccion de prim
        
        b read1                 #ciclo de lectura          
        
inter2: la $t2, seg             #cargamos la direccion de seg en t2

read2:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf2             #indicamos la direccion del buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall
        
        blez $v0, finCargaHS    #si es el final del archivo nos vamos a comparar
        
        la $a0, buf2             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos el byte del buffer en t4
	beq $t4, $zero, jump2
        sb $t4, 0($t2)          #guardamos este byte en la direccion de seg
jump2:	
        beq $t4, 0xa, inter3    #si llegamos al salto de linea nos vamos a
                                #inter3
        
        addi $t2, $t2, 1        #nos movemos 1 byte en la direccion de seg
        
        b read2                 #ciclo
        
inter3: la $t2, ter             #cargamos en t2 la direccion de ter
        
read3:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf2             #indicamos la direccion del buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall

        blez $v0, finCargaHS  #si es el final del archivo nos vamos a comparar
        
        la $a0, buf2             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos en t4 el byte del buffer
	beq $t4, $zero, jump3
        sb $t4, 0($t2)          #almacenamos este byte en la direccion de ter
jump3:	
        beq $t4, 0xa, read3     #entramos al ciclo de nuevo
        
        addi $t2, $t2, 1

        b read3

finCargaHS:     la $a0, linea           #imprimimos una linea en blanco
                li $v0, 4
                syscall
        
######################################################
#                                                    #
#           Comienzo del juego y calculo             #
#                                                    #
######################################################

inic:   lb $t7, numInt          #cargamos el max de intentos en t7
        li $t8, 1               #contador del numero de intentos
        
        la $a0, preguntaNombre  #preguntamos el nombre del jugador
        li $v0, 4
        syscall

        li $v0, 8               #lee los 8 bytes de la entrada y los
        la $a0, nombre          #almacena en nombre
        li $a1, 8
        syscall

        la $a0, nombre          #imprimimos el nombre del jugador
        li $v0, 4
        syscall

        la $t1, punN            #inicializamos la puntuacion en cero
        lb $t6, cero
        sb $t6, 0($t1)
        sb $t6, 1($t1)
        li $a0, 0x30            #imprimimos que su puntuacion es cero 
        li $v0, 11
        syscall

        la $a0, linea           #imprimimos una linea 
        li $v0, 4
        syscall

        lw $t6, codigos         #cargo en t6 la direccion de los codigos
        la $s7, codAct          #cargo en s7 la direccion de codAct
        
bigCiclo:       la $a0, salida1 #imprimimos que intento es
                li $v0, 4
                syscall
                
                move $a0, $t8   #movemos el numero de intento a a0
                li $v0, 1       #imprimir entero
                syscall

                la $a0, linea   #imprimimos una linea
                li $v0, 4
                syscall

                la $s0, leIn    #cargamos el espacio para lo dado por el usuario
                li $t9, 0       #inicializamos contador en cero

#########################################################################
#  vamos leyendo uno a uno los caracteres que intenta poner el usuario  #
#  que se almacenan en leIn                                             #
#########################################################################

leerC:  li $v0, 12              #leemos caracter
        syscall

        beq $v0, 0x51, preg     #si es Q pregunta si quiere salir del juego
        beq $v0, 0x71, preg     #si es q pregunta si quiere salir del juego
        beq $v0, 0x45, HS       #si es E muestra los highscores
        beq $v0, 0x65, HS       #si es e muestra los highscores

        move $s1, $v0           #movemos el caracter a s1
        sb $s1, 0($s0)          #almacenamos el caracter de s1 a leIn

        addi $s0, $s0, 1        #movemos 1byte la direccion de s0
        addi $t9, $t9, 1        #aumentamos en uno el contador

        bne $t9, 4, leerC       #repite el ciclo hasta que lea 4 char

        la $s0, leIn            #cargo en s0 la direccion de leIn

        li $t9, 0               #inicializamos contador pos codig
        li $s2, 0               #inicializamos contador pos entrada

        la $a0, linea           #imprimimos una linea
        li $v0, 4
        syscall

buscarCod:      lw $s6, partida         #cargamos el numero de partida en s6
                la $s7, codAct          #cargamos la direccion de codAct en s7
                sll $s6, $s6, 2         #multiplicamos por 4 el numero de
                                        #partida para saber en que posicion esta
                                        #el codigo que buscamos
                lw $t6, codigos         #cargamos la direccion de los codigos
                add $t6, $t6, $s6       #a la direccion de los codigos le
                                        #sumamos s6 para indicarle en que
                                        #posicion buscara el codigo
                                

#aqui usamos s3 como temporal para pasar el codigo y s2 como contador

obtenerCod:     lb $s3, 0($t6)          #cargo un byte de codigos a s3
                sb $s3, 0($s7)          #almaceno este byte en codigo actual
                addu $s7, $s7, 1        #me muevo un byte en codAct
                addu $t6, $t6, 1        #me muevo un byte en los codigos
                addi $s2, $s2, 1        #sumo 1 al contador
                blt $s2, 4, obtenerCod  #mientras no sea 4 el contador seguimos
                                        #en el ciclo

intermed:       la $t6, codAct          #cargamos en t6 la direccion de codAct
                move $s2, $zero         #reiniciamos el contador s2 a cero
        
                move $s5, $zero         #inicializamos s5 en cero

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

ciclo:  lb $s3, 0($t6)          #cargamos el elemento actual del codigo actual
        lb $s4, 0($s0)          #cargamos el elemento actual del codigo de
                                #entrada
        
        beq $s3, $s4, AeqB      #primer condicional si son iguales
        b else

AeqB:   beq $s2, $t9, XeqY      #segundo condicional si los indices son iguales
        
        la $a0, blanco          #si los indices no son iguales cargamos en a0 
                                #blanco para imprimirlo
        b cAeqB                 #y nos vamos a cAeqB

XeqY:   la $a0, negro           #como los indices son iguales cargamos negro
                                #para imprimir 
        addi $s5, $s5, 1        #sumamos uno al numero de aciertos

cAeqB:  move $t9, $zero         #reinciamos el contador

        li $v0, 4               #imprimimos blanco o negro segun lo anterior
        syscall

        addi $s2, $s2, 1        #aumentamos el contador de la pos del cod de
                                #entrada
        addu $s0, $s0, 1        #nos movemos 1byte en el codigo de entrada

        la $t6, codAct          #cargamos la direccion del codigo actual a t6

        b finCiclo              #vamos al final del ciclo

else:   addi $t9, $t9, 1        #aumentamos el contador de la posicion del
                                #codigo actual
        addu $t6, $t6, 1        #nos movemos 1byte en el codigo actual
        
        bne $t9, 4, finCiclo    #si ya revisamos los 4 numeros sale

        la $a0, ninguno         #imprimimos "X"
        li $v0, 4
        syscall
        
        addi $s2, $s2, 1        #aumento el contador de la pos del codigo de
                                #entrada
        addu $s0, $s0, 1        #me muevo 1 byte en el codigo de entrada

        move $t9, $zero         #reinicio el contador
        
        la $t6, codAct          #cargo en t6 la direccion del codigo actual

finCiclo:       blt $s2, 4, ciclo       #mientras no revisemos los 4 digitos
                                        #regresamos a ciclo
        
                la $a0, linea           #imprimimos una linea
                li $v0, 4
                syscall
        
                beq $s5, 4, reinic      #cuando la cantidad de aciertos es 4
                                        #nos vamos a reinic 
                
                addi $t8, $t8, 1        #aumentamos en 1 el numero de intento
                
                move $s5, $zero         #reiniciamos la cantidad de aciertos

                bgt $t8, $t7, pregun       #si el numero de intento actual es
                                        #mayor al maximo de intentos vamos a fin

                #Limpiamos leIn

                move $s2, $zero         #reiniciamos el contador s2
                la $s0, leIn            #cargamos en s0 la direccion de leIn

clean:  sb $zero, 0($s0)        #almacenamos cero en la posicion actual
                                #de leIn
        addi $s0, $s0, 1        #nos movemos 1 byte en leIn        
        addi $s2, $s2, 1        #sumamos 1 al contador
        
        bne $s2, 4, clean       #sale cuando haya limpiado todo leIn

        b bigCiclo              #regresamos a bigCiclo

preg:   bne $s5, 4, noAdivino           #si la cantidad de aciertos no es 4 es
                                        #porque no adivino

        beq $t8, $t7, enLaUltima        #si la cantidad de intentos es igual al
                                        #maximo es porque adivino en el ultimo
                                        #intento solo se le otorga 1 punto
        
        la $t1, punN                    #cargo la direccion de punN en t1
        lb $t2, 0($t1)                  #cargo en t2 el byte de las decenas
        lb $t3, 1($t1)                  #cargo en t3 el byte de las unidades
        
        beq $t3, 0x39, casoBorde        #si llegamos al caso donde las unidades
                                        #son 9 vamos a casoBorde
        beq $t3, 0x38, casoBorde2       #si llegamos al caso donde las unidades
                                        #son 8 vamos a casoBorde2
        
        add $t3, $t3, 2                 #de resto si adivino y no esta en esos
                                        #dos casos anteriores se le suman 2 ptos
                                        #a las unidades
        sb $t3, 1($t1)                  #almacenamos en memoria
        
        b noAdivino                     #nos vamos a noAdivino para imprimir
                                        #el nombre del jugador y su puntuacion
        
casoBorde:      addi $t2, $t2, 1        #aumentamos en 1 las decenas 
                li $t3, 0x31            #cargamos en las unidades el 1
                sb $t2, 0($t1)          #almacenamos en memoria
                sb $t3, 1($t1)
                b noAdivino             #vamos a noAdivino para imprimir el
                                        #nombre del jugador y su puntuacion
                
casoBorde2:     addi $t2, $t2, 1        #aumentamos en 1 las decenas
                li $t3, 0x30            #cargamos en las unidades el 0
                sb $t2, 0($t1)          #almacenamos en memoria
                sb $t3, 1($t1)
                b noAdivino             #vamos a noAdivino para imprimir el 
                                        #nombre del jugador y su puntuacion
        
enLaUltima:     la $t1, punN            #cargo la direccion de punN en t1
                lb $t2, 0($t1)          #cargo en t2 el byte de las decenas
                lb $t3, 1($t1)          #cargo en t3 el byte de las unidades

                beq $t3, 0x39, casoBorde3       #si las unidades son 1 nos vamos
                                                #al casoBorde3
                                        
                                        #si no ocurre esto lo que hacemos es que
                add $t3, $t3, 1         #sumamos el punto correspondiente
                sb $t3, 1($t1)          #almacenamos en memoria
                b noAdivino             #vamos a noAdivino para imprimir el
                                        #nombre del jugador y su puntuacion
                        
casoBorde3:     addi $t2, $t2, 1        #sumamos 1 a las decenas
                li $t3, 0x30            #cargamos cero en las unidades
                sb $t2, 0($t1)          #almacenamos en memoria
                sb $t3, 1($t1)
                
noAdivino:      la $a0, jugad           #imprimimos "Jugador: "
                li $v0, 4
                syscall

                la $a0, nombre          #imprimimos el nombre del jugador
                li $v0, 4
                syscall
                
                la $a0, puntu           #imprimimos "Puntuacion: "
                li $v0, 4
                syscall
                
                la $a0, punN            #imprimimos la puntuacion
                li $v0, 4
                syscall
                
                lb $s2, numCod          #cargamos el numero de codigos en t2
                beq $s6, $s2, fin       #si el numero de codigos es igual al 
                                        #numero de partidas vamos a fin
        
pregun: la $a0, preguntaFinal           #preguntamos si desea jugar de nuevo
        li $v0, 4
        syscall

        li $v0, 12                      #leemos la respuesta
        syscall

        move $s1, $v0                   #la almacenamos en s1

        la $a0, linea                   #imprimimos una linea en blanco
        li $v0, 4
        syscall

        beq $s1, 0x59, bigCiclo         #si es "y" entonces vamos a bigCiclo
        beq $s1, 0x79, bigCiclo         #si es "Y" entonces vamos a bigCiclo

        beq $s1, 0x4e, fin              #si es "n" entonces vamos a fin
        beq $s1, 0x6e, fin              #si es "N" entonces vamos a fin

        b pregun                        #si no responde ninguna de las
                                        #anteriores preguntamos de nuevo


#usamos s2 como temporal y luego reiniciamos su valor
reinic: lw $s6, partida         #cargamos a s6 el numero de partida
        addi $s6, $s6, 1        #le sumamos uno

        lb $s2, numCod          #cargamos el numero de codigos en s2
        beq $s6, $s2, preg      #si el numero de partida es igual al numero
                                #de codigos vamos a preg

        sw $s6, partida         #guardamos en memoria el numero de partida
                                #atual

        la $s7, codAct          #cargamos en s7 la direccion a codAct
        li $t8, 1               #reiniciamos el contador de intentos a 1
        b preg                  #nos vamos a preg
        
      
#################################################################
#                                                               #
#                 Final y Escritura en el Archivo               #
#                                                               #
#  Aqui guardaremos en memoria las puntuaciones que estan en el #
#  archivo score.txt en memoria y la nueva puntuacion y luego   #
#  de compararlas escribira las puntuaciones mas altas en el    #
#  archivo.                                                     #
#                                                               #
#################################################################
      
      
fin:    la $t1, punN
        lb $s2, 0($t1)
        lb $s3, 1($t1)
        
        lb $s1, espacio
        la $t2, nuev
        sb $s2, 0($t2)
        sb $s3, 1($t2)
        sb $s1, 2($t2)
        addi $t2, $t2, 3
        la $t5, nombre
        
nuev0:  lb $t3, 0($t5)          
        sb $t3, 0($t2)
        
        addi $t5, $t5, 1
        addi $t2, $t2, 1
        
        bnez $t3, nuev0
        
        la $t5, nuev            
        la $s5, punN            
        move $t4, $zero
        
cargarNuev:     lb $t3, 0($t5)
                sb $t3, 0($t2)
                
                addi $t2, $t2, 1
                addi $t5, $t5, 1
                addi $t4, $t4, 1
                
                bne $t3, 0x20, contCargarNuev
                
                la $t7, punN
                jal transf
                
                sw $s0, punN
                
                b intermedPrim
                
contCargarNuev: blt $t3, 0x30, ErrorLectura
                bgt $t3, 0x39, ErrorLectura
                
                b cargarNuev
        
#################################################
#                                               #
#  aca estamos guardando en pun1, pun2 y pun3   #
#  las puntuaciones que hay guardadas en mem    #
#  de prim, seg y ter que son los highscores    #
#  leidos del archivo de texto de highscores    #
#                                               #
#################################################



intermedPrim:   la $t5, prim            #cargamos en t5 la direccion de prim
                la $s5, pun1            #cargamos la direccion de pun1 en s5
                move $t4, $zero         #reiniciamos el contador t4 a cero
        
cargarPrim:     lb $t3, 0($t5)          #cargamos el byte actual
                sb $t3, 0($s5)          #guardamos en pun1 el byte actual
                
                addi $t4, $t4, 1        #sumamos 1 al contador
                addi $t5, $t5, 1        #nos movemos un byte en t5
                addi $s5, $s5, 1        #nos movemos un byte en s5
                
                bne $t3, 0x20, contCargarPrim   #si no llegamos a un espacio en
                                                #blanco nos vamos a
                                                #contCargarPrim
                
                la $t7, pun1    #en caso de que si lleguemos al espacio cargamos
                                #la direccion de pun1 en t7
                jal transf      #llamamos a la funcion transformar
                
                sw $s0, pun1    #guardamos pun1 el entero que nos retorna la
                                #funcion en s0
                
                b intermedSeg   #nos vamos a intermedSeg
                
contCargarPrim: blt $t3, 0x30, ErrorLectura     #si no leimos un numero => ERROR
                bgt $t3, 0x39, ErrorLectura     #si no leimos un numero => ERROR
                
                b cargarPrim    #regresamos al ciclo cargarPrim
                
intermedSeg:    la $t5, seg     #cargamos en t5 la direccion de seg
                la $s5, pun2    #cargamos en s5 la direccion de 
                move $t4, $zero #reiniciamos el contador
                
cargarSeg:      lb $t3, 0($t5)          #cargamos el byte actual
                sb $t3, 0($s5)          #guardamos en pun2 el byte actual
                
                addi $t4, $t4, 1        #sumamos 1 al contador
                addi $t5, $t5, 1        #nos movemos 1 byte en t5
                addi $s5, $s5, 1        #nos movemos 1 byte en s5
                
                bne $t3, 0x20, contCargarSeg    #si aun no llegamos al espacio
                                                #en blanco nos vamos a
                                                #ContCargarSeg
                
                la $t7, pun2    #en caso de que si lleguemos al espacio cargamos
                                #la direccion de pun2 en t7      
                jal transf      #llamamos a la funcion transformar
                
                sw $s0, pun2    #guardamos en pun2 el entero que nos retorna la 
                                #funcion en s0
                
                b intermedTer   #nos vamos a intermedTer

contCargarSeg:  blt $t3, 0x30, ErrorLectura     #si no leimos un numero => ERROR
                bgt $t3, 0x39, ErrorLectura     #si no leimos un numero => ERROR
                
                b cargarSeg     #regresamos al ciclo cargarSeg
                
intermedTer:    la $t5, ter             #cargamos la direccion de ter en t5
                la $s5, pun3            #cargamos la direccion de pun3 en s5
                move $t4, $zero         #reiniciamos el contador
                
cargarTer:      lb $t3, 0($t5)          #cargamos el byte actual
                sb $t3, 0($s5)          #almacenamos en pun3 el byte actual
                
                addi $t4, $t4, 1        #sumamos 1 al contador
                addi $t5, $t5, 1        #nos movemos 1 byte en t5
                addi $s5, $s5, 1        #nos movemos 1 byte en s5
                
                bne $t3, 0x20, contCargarTer    #si aun no llegamos al espacio
                                                #en blanco nos vamos a
                                                #ContCargarTer
                
                la $t7, pun3    #en caso de que si lleguemos al espacio cargamos
                                #la direccion de pun3 en t7 
                jal transf      #llamamos a la funcion transformar
                
                sw $s0, pun3    #guardamos en pun3 el entero que nos retorna la 
                                #funcion en s0
                
                b comparar      #nos vamos a comparar

contCargarTer:  blt $t3, 0x30, ErrorLectura     #si no leimos un numero => ERROR
                bgt $t3, 0x39, ErrorLectura     #si no leimos un numero => ERROR
                
                b cargarTer     #regresamos al ciclo cargarTer
                
#aca reutilizamos t4 y t5 para comparar los numeros.
                
comparar:       lw $t5, punN            #cargamos en t5 la puntuacion nueva

                lw $t4, pun1            #cargamos en t4 la puntuacion 1
                bgt $t5, $t4, escrib1a  #si es mayor la nueva vamos a escrib1a
                
                lw $t4, pun2            #cargamos en t4 la puntuacion 2
                bgt $t5, $t4, escrib2a  #si es mayor la nueva vamos a escrib2a
                
                lw $t4, pun3            #cargamos en t4 la puntuacion 3
                bgt $t5, $t4, escrib3   #si la nueva es mayor vamos a escrib3a
                
                b abrirEsc              #si no pasa nada de lo anterior vamos
                                        #directamente a escribir el archivo de
                                        #los highscores
                
escrib3:        la $t5, nuev            #cargamos la direccion de nuev en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                
sobreescribir3: lb $t3, 0($t5)          #cargamos en t3 el byte actual

                move $a0, $t3           #imprimimos en pantalla este byte
                li $v0, 11
                syscall
                
                sb $t3, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en la direccion de
                                        #nuev
                addi $t4, $t4, 1        #nos movemos 1 byte en la direccion de
                                        #ter

                bnez $t3, sobreescribir3        
                b abrirEsc              #cuando terminemos vamos a abrirEsc
                
escrib2a:       la $t5, seg             #cargamos la direccion de seg en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                                        #aca sobreescribiremos seg en ter

sobreescribir2: lb $t3, 0($t5)          #cargamos en t3 el byte actual
        
                move $a0, $t3           #imprimimos por pantalla este byte
                li $v0, 11
                syscall

                sb $t3, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en seg
                addi $t4, $t4, 1        #nos movemos 1 byte en ter

                bnez $t3, sobreescribir2

escrib2b:       la $t5, nuev            #cargamos la direccion de nuev en t5
                la $t4, seg             #cargamos la direccion de seg en t4
                                        #aca sobreescribiremos la nueva punt
                                        #en seg
                
sobreescribir2b:lb $t3, 0($t5)         #cargamos el byte actual en t3
        
                move $a0, $t3           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t3, 0($t4)          #almacenamos en seg este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en nuevPunt
                addi $t4, $t4, 1        #nos movemos 1 byte en seg

                bnez $t3, sobreescribir2b
                b abrirEsc              #cuando terminamos vamos a abrirEsc
                
escrib1a:       la $t5, seg             #cargamos la direccion de seg en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                                        #aca sobreescribiremos seg en ter

sobreescribir1: lb $t3, 0($t5)          #cargamos el byte actual en t3

                move $a0, $t3           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t3, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en seg
                addi $t4, $t4, 1        #nos movemos 1 byte en ter
                
                bnez $t3, sobreescribir1
                
escrib1b:       la $t5, prim            #cargamos la direccion de prim en t5
                la $t4, seg             #cargamos la direccion de seg en t6
                                        #aca sobreescribiremos prim en seg
                
sobreescribir1b: lb $t3, 0($t5)         #cargamos en t3 el byte actual

                move $a0, $t3           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t3, 0($t4)          #almacenamos en seg este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en prim
                addi $t4, $t4, 1        #nos movemos 1 byte en seg
                
                bnez $t3, sobreescribir1b       
                
escrib1c:       la $t5, nuev            #cargamos en t5 la direccion de nuevPunt
                la $t4, prim            #cargamos en t4 la direccion de prim
                                        #queremos sustituir en prim la nuevPunt
                
sobreescribir1c: lb $t3, 0($t5)         #cargamos en t3 el byte actual

                move $a0, $t3           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t3, 0($t4)          #almacenamos en prim este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en nuev
                addi $t4, $t4, 1        #nos movemos 1 byte en prim
                
                bnez $t3, sobreescribir1c
        
abrirEsc:       la $a0, archScore       #open nombre del archivo
                li $a1, 0x102           # 0x109 = 0x100 Create + 0x8 Append +
                                        # 0x1 Write
                li $a2, 0x1FF           # Mode 0x1FF = 777 rwx rwx rwx
                li $v0, 13              #indicamos que vamos a abrir
                syscall

                move $t0, $v0

escribir1:      move $a0, $t0           #movemos el file descriptor a a0

                la $t8, prim            #cargamos en t8 prim
                move $s7, $zero         #inicializamos s7 en cero
                jal contat              #llamamos a contat que nos calcula el
                                        #espacio exacto que debe utilizar para
                                        #escribir la palabra
        
                la $a1, prim            #cargamos la direccion de lo que
                                        #imprimiremos en a1
                move $a2, $s7           #max nummero de bytes a escribir
                li $v0, 15              #indicamos que vamos a escribir
                syscall
                
escribir2:      la $t8, seg             #cargamos en t8 seg
                move $s7, $zero         #inicializamos s7 en cero
                jal contat              #llamamos a contat que nos calcula
                                        #el espacio exacto que debe utilizar
                                        #para escribir la palabra

                la $a1, seg             #cargamos la direccion de lo que 
                                        #imprimiremos en a1
                move $a2, $s7           #max numero de bytes a escribir
                li $v0, 15              #indicamos que vamos a escribir
                syscall
                
escribir3:      la $t8, seg             #cargamos en t8 ter
                move $s7, $zero         #inicializamos s7 en cero
                jal contat              #llamamos a contat que nos calcula 
                                        #el espacio exaco que debe utilizar para
                                        #escribir la palabra
        
                la $a1, ter             #cargamos la direccion de lo que 
                                        #imprimiremos en a1
                move $a2, $s7           #max numero de bytes a imprimir
                li $v0, 15              #indicamos que vamos a escribir
                syscall

seAcabo:        li $v0, 10
                syscall

########################################################################################
        
HS:     la $a0, linea           #imprimimos una linea
        li $v0, 4
        syscall
        
        la $a0, highs           #imprimimos mensaje highs
        li $v0, 4
        syscall 
        
        la $a0, prim            #imprimimos el primer highscore
        li $v0, 4
        syscall
        
        la $a0, seg             #imprimimos el segundo highscore
        li $v0, 4
        syscall

        la $a0, ter             #imprimimos el tercer highscore
        li $v0, 4
        syscall
        
        la $a0, linea           #imprimimos una linea
        li $v0, 4
        syscall
        
        la $a0, mensajeFHS      #imprimimos el mensajeFHS
        li $v0, 4
        syscall

        b leerC                 #regresamos a leerC
                                

######################################################
#                                                    #
#     Funcion para transformar de ASCII a Entero     #
#                                                    #
#     aqui utilizamos el registro t4 para indicar la #
#  cantidad de digitos que tiene el numero (contando #
#  un espacio en blanco despues del mismo), al igual #
#  que utiliza el registro s0 para la salida ya que  #
#  en este registro queda el numero entero. Tambien  #
#  utiliza como auxiliares los registros s3 y s4     #
#  para los casos en que el numero tiene dos y tres  #
#  digitos, allí se almacenan decenas y centenas.    #
#                                                    #
######################################################

transf: beq $t4, 3, dosDigitos  #si el numero tiene 3 digitos(contando el
                                #espacio) se va a dosDigitos
        beq $t4, 4, tresDigitos #si tiene 4 digitos (con el espacio) se
                                #va a tresDigitos
        lb $s0, 0($t7)          #cargamos el primer byte del numero
        addi $s0, $s0, -48      #restamos 48 para saber su valor entero
        jr $ra
       
dosDigitos:     lb $s3, 0($t7)          #cargamos el primer byte del numero
                                        #(decenas)
                lb $s0, 1($t7)          #cargamos el segundo byte del numero
                                        #(unidades)
                addi $s0, $s0, -48      #restamos 48 para saber su valor entero
                addi $s3, $s3, -48
                mul $s3, $s3, 10        #multiplicamos por 10 ya que este
                                        #numero es de las decenas
                add $s0, $s0, $s3       #sumamos las unidades con las decenas
                jr $ra
                
tresDigitos:    lb $s4, 0($t7)          #cargamos el primer byte del numero
                                        #(centenas)
                lb $s3, 1($t7)          #cargamos el segundo byte del numero
                                        #(decenas)
                lb $s0, 2($t7)          #cargamos el tercer byte del numero
                                        #(unidades)
                
                addi $s0, $s0, -48      #restamos 48 a todos para saber sus
                addi $s3, $s3, -48      #valores enteros
                addi $s4, $s4, -48
                
                mul $s3, $s3, 10        #multiplicamos por 10 las decenas
                mul $s4, $s4, 100       #multiplicamos por 100 las centenas
                
                add $s3, $s3, $s4       #sumamos decenas y centenas
                add $s0, $s0, $s3       #ahora se lo sumamos a las unidades
                
                jr $ra                  

#########################################
#                                       #
# contat nos calcula el espacio exacto  #
# que ocupa la palabra para que escriba #
# correctamente en el archivo.          #
#                                       #
#########################################
                
contat: lb $t4, 0($t8)          #cargo en t4 el byte actual
        beq $t4, 0xa, sali2     #si es un salto de linea vamos a sali2
        beq $t4, $zero sali2    #si es un cero vamos a sali2
        addi $s7, $s7, 1        #sino sumamos 1 al numero de espacios
        addi $t8, $t8, 1        #nos movemos 1 byte en la direccion de t8
        b contat                #ciclo
        
sali2:  addi $s7, $s7, 1        #sumamos uno al numero de espacios
        jr $ra                  #y regresamos