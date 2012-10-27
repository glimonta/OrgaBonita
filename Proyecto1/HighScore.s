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
# s0: contador

.data

nomArch:        .asciiz "score.txt"
nuevPunt:       .asciiz "9 Santiago"
prim:           .space 14
seg:            .space 14
ter:            .space 14
buf:            .space 4
                .align 2


.text

main:   la $a0, nomArch         #abrimos el archivo solo para lectura
        li $v0, 13
        li $a1, 0x0
        syscall
        
        move $t0, $v0           #movemos el file descriptor a t0
                        
inter:  la $t1, prim            #cargamos la direccion de prim en t1
        
leer1:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf             #indicamos la direccion de buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall

        blez $v0, comparar      #si es el final del archivo nos vamos a comparar

        la $a0, buf             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos el byte del buffer en t4
        sb $t4, 0($t1)          #guardamos este byte en la direccion de prim
        
        beq $t4, 0xa, inter2    #si llegamos al salto de linea nos vamos
                                #a inter2

        addi $t1, $t1, 1        #nos movemos 1 byte en la direccion de prim
        
        b leer1                 #ciclo de lectura
       
inter2: la $t1, seg             #cargamos en t1 la direccion de seg

leer2:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf             #indicamos la direccion del buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall
        
        blez $v0, comparar      #si es el final del archivo nos vamos a comparar
        
        la $a0, buf             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos el byte del buffer en t4
        sb $t4, 0($t1)          #guardamos este byte en la direccion de seg
        
        beq $t4, 0xa, inter3    #si llegamos al salto de linea nos vamos a
                                #inter3
        
        addi $t1, $t1, 1        #nos movemos 1 byte en la direccion de seg
        
        b leer2                 #ciclo
        
inter3: la $t1, ter             #cargamos en t1 la direccion de ter
        
leer3:  move $a0, $t0           #movemos el file descriptor a a0
        la $a1, buf             #indicamos la direccion del buffer
        li $a2, 1               #indicamos que leeremos un byte
        li $v0, 14              #indicamos que vamos a leer
        syscall

        blez $v0, comparar      #si es el final del archivo nos vamos a comparar
        
        la $a0, buf             #imprimimos lo que hay en el buffer
        li $v0, 4
        syscall

        lb $t4, 0($a0)          #cargamos en t4 el byte del buffer
        sb $t4, 0($t1)          #almacenamos este byte en la direccion de ter
        
        beq $t4, 0xa, leer3     #si llegamos al salto de linea nos vamos
                                #a comparar
        
        addi $t1, $t1, 1

        b leer3
        
comparar:       lb $t5, nuevPunt        #cargamos el nuevo puntaje en t5
                         
                lb $t4, prim            #cargamos en t4 el primer byte de prim
                bgt $t5, $t4, escrib1a  #si t5 es mayor que t4 nos vamos a
                                        #escrib1a
                  
                lb $t4, seg             #cargamos en t4 el primer byte de seg
                bgt $t5, $t4, escrib2a  #si t5 es mayor a t4 nos vamos a 
                                        #escrib2a
                          
                lb $t4, ter             #cargamos en t4 el primer byte de ter
                bgt $t5, $t4, escrib3   #si t5 es mayor a t4 entonces vamos a
                                        #escrib3
                
                b fin                   #si nada de esto pasa nos vamos al final
          
escrib3:        la $t5, nuevPunt        #cargamos la direccion de nuevPunt en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                
sobreescribir3: lb $t6, 0($t5)          #cargamos en t6 el byte actual

                move $a0, $t6           #imprimimos en pantalla este byte
                li $v0, 11
                syscall
		
                sb $t6, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en la direccion de
                                        #nuevPunt
                addi $t4, $t4, 1        #nos movemos 1 byte en la direccion de
                                        #ter

                bnez $t6, sobreescribir3        
                b fin                   #cuando terminemos vamos a fin

escrib2a:       la $t5, seg             #cargamos la direccion de seg en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                                        #aca sobreescribiremos seg en ter

sobreescribir2: lb $t6, 0($t5)          #cargamos en t6 el byte actual
	
                move $a0, $t6           #imprimimos por pantalla este byte
                li $v0, 11
                syscall

                sb $t6, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en seg
                addi $t4, $t4, 1        #nos movemos 1 byte en ter

                bnez $t6, sobreescribir2

escrib2b:       la $t5, nuevPunt        #cargamos la direccion de nuevPunten t5
                la $t4, seg             #cargamos la direccion de seg en t4
                                        #aca sobreescribiremos la nueva punt
                                        #en seg
                
sobreescribir2b: lb $t6, 0($t5)         #cargamos el byte actual en t6
        
                move $a0, $t6           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t6, 0($t4)          #almacenamos en seg este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en nuevPunt
                addi $t4, $t4, 1        #nos movemos 1 byte en seg

                bnez $t6, sobreescribir2b
                b fin                   #cuando terminamos vamos a fin

escrib1a:       la $t5, seg             #cargamos la direccion de seg en t5
                la $t4, ter             #cargamos la direccion de ter en t4
                                        #aca sobreescribiremos seg en ter

sobreescribir1: lb $t6, 0($t5)          #cargamos el byte actual en t6

                move $a0, $t6           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t6, 0($t4)          #almacenamos este byte en ter

                addi $t5, $t5, 1        #nos movemos 1 byte en seg
                addi $t4, $t4, 1        #nos movemos 1 byte en ter
                
                bnez $t6, sobreescribir1
                
escrib1b:       la $t5, prim            #cargamos la direccion de prim en t5
                la $t4, seg             #cargamos la direccion de seg en t6
                                        #aca sobreescribiremos prim en seg
                
sobreescribir1b: lb $t6, 0($t5)         #cargamos en t6 el byte actual

                move $a0, $t6           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t6, 0($t4)          #almacenamos en seg este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en prim
                addi $t4, $t4, 1        #nos movemos 1 byte en seg
                
                bnez $t6, sobreescribir1b       
                
escrib1c:       la $t5, nuevPunt        #cargamos en t5 la direccion de nuevPunt
                la $t4, prim            #cargamos en t4 la direccion de prim
                                        #queremos sustituir en prim la nuevPunt
                
sobreescribir1c: lb $t6, 0($t5)         #cargamos en t6 el byte actual

                move $a0, $t6           #imprimimos este byte
                li $v0, 11
                syscall

                sb $t6, 0($t4)          #almacenamos en prim este byte

                addi $t5, $t5, 1        #nos movemos 1 byte en nuevPunt
                addi $t4, $t4, 1        #nos movemos 1 byte en prim
                
                bnez $t6, sobreescribir1c

fin:    li $v0, 10      #finalizamos el programa 
        syscall