# SPIM S20 MIPS simulator.
# The default exception handler for spim.
#
# Copyright (c) 1990-2010, James R. Larus.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or
# other materials provided with the distribution.
#
# Neither the name of the James R. Larus nor the names of its contributors may
# be
# used to endorse or promote products derived from this software without
# specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#

# Define the exception handling code.  This must go first!

        .kdata
__m1_:  .asciiz "  Exception "
__m2_:  .asciiz " occurred and ignored\n"
__e0_:  .asciiz "  [Interrupt] "
__e1_:  .asciiz "  [TLB]"
__e2_:  .asciiz "  [TLB]"
__e3_:  .asciiz "  [TLB]"
__e4_:  .asciiz "  [Address error in inst/data fetch] "
__e5_:  .asciiz "  [Address error in store] "
__e6_:  .asciiz "  [Bad instruction address] "
__e7_:  .asciiz "  [Bad data address] "
__e8_:  .asciiz "  [Error in syscall] "
__e9_:  .asciiz "  [Breakpoint] "
__e10_: .asciiz "  [Reserved instruction] "
__e11_: .asciiz ""
__e12_: .asciiz "  [Arithmetic overflow] "
__e13_: .asciiz "  [Trap] "
__e14_: .asciiz ""
__e15_: .asciiz "  [Floating point] "
__e16_: .asciiz ""
__e17_: .asciiz ""
__e18_: .asciiz "  [Coproc 2]"
__e19_: .asciiz ""
__e20_: .asciiz ""
__e21_: .asciiz ""
__e22_: .asciiz "  [MDMX]"
__e23_: .asciiz "  [Watch]"
__e24_: .asciiz "  [Machine check]"
__e25_: .asciiz ""
__e26_: .asciiz ""
__e27_: .asciiz ""
__e28_: .asciiz ""
__e29_: .asciiz ""
__e30_: .asciiz "  [Cache]"
__e31_: .asciiz ""
__excp: .word __e0_, __e1_, __e2_, __e3_, __e4_, __e5_, __e6_, __e7_, __e8_,
        .word __e9_
        .word __e10_, __e11_, __e12_, __e13_, __e14_, __e15_, __e16_, __e17_,
        .word __e18_,
        .word __e19_, __e20_, __e21_, __e22_, __e23_, __e24_, __e25_, __e26_,
        .word __e27_,
        .word __e28_, __e29_, __e30_, __e31_
s1:     .word 0
s2:     .word 0
buf:    .space 1
tab:    .word 0
def:    .asciiz "pac.txt"

        

# This is the exception handler code that the processor runs when
# an exception occurs. It only prints some information about the
# exception, but can server as a model of how to write a handler.
#
# Because we are running in the kernel, we can use $k0/$k1 without
# saving their old values.

# This is the exception vector address for MIPS-1 (R2000):
#       .ktext 0x80000080
# This is the exception vector address for MIPS32:
        .ktext 0x80000180
# Select the appropriate one for the mode in which SPIM is compiled.
        .set noat
        move $k1 $at            # Save $at
        .set at
        sw $v0 s1               # Not re-entrant and we can't trust $sp
        sw $a0 s2               # But we need to use these registers

        mfc0 $k0 $13            # Cause register
        srl $a0 $k0 2           # Extract ExcCode Field
        andi $a0 $a0 0x1f

        # Print information about exception.
        #
        li $v0 4                # syscall 4 (print_str)
        la $a0 __m1_
        syscall

        li $v0 1                # syscall 1 (print_int)
        srl $a0 $k0 2           # Extract ExcCode Field
        andi $a0 $a0 0x1f
        syscall

        li $v0 4                # syscall 4 (print_str)
        andi $a0 $k0 0x3c
        lw $a0 __excp($a0)
        nop
        syscall

        bne $k0 0x18 ok_pc      # Bad PC exception requires special checks
        nop

        mfc0 $a0 $14            # EPC
        andi $a0 $a0 0x3        # Is EPC word-aligned?
        beq $a0 0 ok_pc
        nop

        li $v0 10               # Exit on really bad PC
        syscall

ok_pc:
        li $v0 4                # syscall 4 (print_str)
        la $a0 __m2_
        syscall

        srl $a0 $k0 2           # Extract ExcCode Field
        andi $a0 $a0 0x1f
        bne $a0 0 ret           # 0 means exception was an interrupt
        nop

# Interrupt-specific code goes here!
# Don't skip instruction at EPC since it has not executed.


ret:
# Return from (non-interrupt) exception. Skip offending instruction
# at EPC to avoid infinite loop.
#
        mfc0 $k0 $14            # Bump EPC register
        addiu $k0 $k0 4         # Skip faulting instruction
                                # (Need to handle delayed branch case here)
        mtc0 $k0 $14


# Restore registers and reset procesor state
#
        lw $v0 s1               # Restore other registers
        lw $a0 s2

        .set noat
        move $at $k1            # Restore $at
        .set at

        mtc0 $0 $13             # Clear Cause register

        mfc0 $k0 $12            # Set Status register
        ori  $k0 0x1            # Interrupts enabled
        mtc0 $k0 $12

# Return from exception on MIPS32:
        eret

# Return sequence for MIPS-I (R2000):
#       rfe                     # Return from exception handler
                                # Should be in jr's delay slot
#       jr $k0
#        nop



# Standard startup code.  Invoke the routine "main" with arguments:
#       main(argc, argv, envp)
#
        .text
        .globl __start
__start:
        lw $a0 0($sp)           # argc
        addiu $a1 $sp 4         # argv
        addiu $a2 $a1 4         # envp
        sll $v0 $a0 2
        addu $a2 $a2 $v0
###################################################################

lectura:        la $a0, def
                li $v0, 13
                li $a1, 0x0
                syscall
                
                move $t0, $v0
                
                li $a0, 4
                li $v0, 9
                syscall
                
                sw $v0, tab
                lw $t3, tab
                move $t4, $zero
                move $t5, $zero
                move $t7, $zero         #contador de "a"
                move $t8, $zero         #contador de "*"
                
leer:   move $a0, $t0
        la $a1, buf
        li $a2, 1
        li $v0, 14
        syscall
        
        blez $v0, bleh
        
        la $a0, buf
        beq $a0, 0xa, leer
        li $v0, 4
        syscall
        
        lb $t2, 0($a0)
        #beq $t2, 0xa, leer
        beq $t2, 0xd, leer
        beq $t2, 0x61, sumA
        beq $t2, 0x2a, sumC
        sb $t2, 0($t3)
        addi $t3, $t3, 1
        addi $t4, $t4, 1
        beq $t4, 4, masEsp
        
        b leer
        
sumA:   addi $t7, $t7,1
        sb $t2, 0($t3)
        addi $t3, $t3, 1
        addi $t4, $t4, 1
        beq $t4, 4, masEsp
        
        b leer
        
sumC:   addi $t8, $t8,1
        sb $t2, 0($t3)
        addi $t3, $t3, 1
        addi $t4, $t4, 1
        beq $t4, 4, masEsp
        
        b leer
        
masEsp: li $v0, 9
        li $a0, 4
        syscall
        
        move $t4, $zero
        move $t3, $v0
        
        b leer
        
bleh:   lw $t5, tab

imprimir:       lb $a0, 0($t5)
                beqz $a0, bleh2
                li $v0, 11
                syscall
                
                addi $t5, $t5, 1
                b imprimir
        
bleh2:
###################################################################
        jal main
        nop

fin:    li $v0 10
        syscall                 # syscall 10 (exit)

        .globl __eoth
__eoth:
