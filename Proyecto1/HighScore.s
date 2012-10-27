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
nuevPunt:       .asciiz "9 Sant"
prim:           .space 10
seg:            .space 10
ter:            .space 10
buf:            .space 4
                .align 2


.text

main:   la $a0, nomArch         #abro el archivo solo para lectura
        li $v0, 13
        li $a1, 0x0
        syscall
        
        move $t0, $v0           #muevo el file descriptor a t0
                        
inter:  la $t1, prim
        
leer1:  move $a0, $t0
        la $a1, buf
        li $a2, 1
        li $v0, 14
        syscall

        blez $v0, comparar

        la $a0, buf
        li $v0, 4
        syscall

        lb $t4, 0($a0)
        sb $t4, 0($t1)
        
        beq $t4, 0xa, inter2

        addi $t1, $t1, 1
        
        b leer1
       
inter2: la $t1, seg

leer2:  move $a0, $t0
        la $a1, buf
        li $a2, 1
        li $v0, 14
        syscall
        
        blez $v0, comparar
        
        la $a0, buf
        li $v0, 4
        syscall

        lb $t4, 0($a0)
        sb $t4, 0($t1)
        
        beq $t4, 0xa, inter3
        
        addi $t1, $t1, 1
        
        b leer2
        
inter3: la $t1, ter
        
leer3:  move $a0, $t0
        la $a1, buf
        li $a2, 1
        li $v0, 14
        syscall

        blez $v0, comparar      
        
        la $a0, buf
        li $v0, 4
        syscall

        lb $t4, 0($a0)
        sb $t4, 0($t1)
        
        beq $t4, 0xa, leer3
        
        addi $t1, $t1, 1
	
        b leer3
        
comparar:       lb $t5, nuevPunt        #cargo el nuevo puntaje en t5
                
                la $t1, prim         
                lb $t4, 0($t1)                    
                bgt $t5, $t4, escrib1a 
                
                la $t1, seg    
                lb $t4, 0($t1)     
                bgt $t5, $t4, escrib2a
                
                la $t3, ter            
                lb $t4, 0($t3)
                blt $t5, $t4, escrib3
          
escrib3:        la $t5, nuevPunt
                la $t4, ter
                
sobreescribir3: lb $t6, 0($t5)

                move $a0, $t6
                li $v0, 11
                syscall
		
                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1

                bnez $t6, sobreescribir3
                b fin

escrib2a:       la $t5, seg
                la $t4, ter

sobreescribir2: lb $t6, 0($t5)
	
                move $a0, $t6
                li $v0, 11
                syscall

                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1

                bnez $t6, sobreescribir2

escrib2b:       la $t5, nuevPunt
                la $t4, seg
                
sobreescribir2b: lb $t6, 0($t5)
        
                move $a0, $t6
                li $v0, 11
                syscall

                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1

                bnez $t6, sobreescribir2b
                b fin

escrib1a:       la $t5, seg
                la $t4, ter

sobreescribir1: lb $t6, 0($t5)

                move $a0, $t6
                li $v0, 11
                syscall

                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1
                
                bnez $t6, sobreescribir1
                
escrib1b:       la $t5, prim
                la $t4, seg
                
sobreescribir1b: lb $t6, 0($t5)

                move $a0, $t6
                li $v0, 11
                syscall

                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1
                
                bnez $t6, sobreescribir1b
                
escrib1c:       la $t5, nuevPunt
                la $t4, prim
                
sobreescribir1c: lb $t6, 0($t5)

                move $a0, $t6
                li $v0, 11
                syscall

                sb $t6, 0($t4)

                addi $t5, $t5, 1
                addi $t4, $t4, 1
                
                bnez $t6, sobreescribir1c

fin:    li $v0, 10
        syscall