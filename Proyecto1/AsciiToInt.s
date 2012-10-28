# AsciiToInt.s : Funcion que toma un valor ascii y lo transforma a un numero.
#
#
# Autores:
#
# Gabriela Limonta
# 10-10385
# 
# Luis Miranda
# 10-10463
#
# Planificacion de registros:
#
# t0: direccion del ascii en memoria
# s0: cantidad de digitos (contando el espacio en blanco) del ascii
# es decir, la cantidad de numeros que tiene mas uno.
# t3: aqui devuelve el numero ya transformado
# t4: auxiliar utilizado para las decenas
# t5: auxiliar utilizado para las centenas

.data

numer:  .asciiz "9"
numer2: .asciiz "45"
numer3: .asciiz "523"
dig:    .word 2
dig2:   .word 3
dig3:   .word 4

.text

main:   la $t0, numer
        lw $s0, dig
        
        jal transf
        
        move $a0, $t3
        li $v0, 1
        syscall
        
        la $t0, numer2
        lw $s0, dig2
        
        jal transf
        
        move $a0, $t3
        li $v0, 1
        syscall
        
        la $t0, numer3
        lw $s0, dig3
        
        jal transf
        
        move $a0, $t3
        li $v0, 1
        syscall
        
        li $v0, 10
        syscall

transf: beq $s0, 3, dosDigitos
        beq $s0, 4, tresDigitos
        lb $t3, 0($t0)
        addi $t3, $t3, -48
        jr $ra
                
dosDigitos:     lb $t4, 0($t0)
                lb $t3, 1($t0)
                addi $t4, $t4, -48
                addi $t3, $t3, -48
                mul $t4, $t4, 10
                add $t3, $t4, $t3
                jr $ra
                
tresDigitos:    lb $t5, 0($t0)
                lb $t4, 1($t0)
                lb $t3, 2($t0)
                addi $t5, $t5, -48
                addi $t4, $t4, -48
                addi $t3, $t3, -48
                mul $t5, $t5, 100
                mul $t4, $t4, 10
                add $t4, $t4, $t5
                add $t3, $t3, $t4
                jr $ra