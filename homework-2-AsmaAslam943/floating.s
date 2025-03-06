
	# Constants for system calling, for the print functions
	# and the like 
	.equ PRINT_DEC 0
	.equ PRINT_STR 4
	.equ PRINT_HEX 1
	.equ READ_HEX 11
	.equ EXIT 20

	# Data section messages.
	.data
newline:   .asciz "\n"
welcome:   .asciz "Welcome to Floating in Assembly\n"
invalid:   .asciz "Invalid hexidecimal\n"
argument:  .asciz "Argument: "
ashex:	   .asciz "As hex:          "
as16:      .asciz "To 16b Floating: "
	
	## Code section
	.text
	.globl main

main:
	# Preamble for main:
	# s0 = argc
	# s1 = argv
	# s2 = loop index i
	# s3 = A callee saved temporary
	# that is used to cross some call boundaries
	addi sp sp -20
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	sw s2 12(sp)
	sw s3 16(sp)

	# Keep argc and argv around, and initialize i to 1
	mv s0 a0
	mv s1 a1
	
	# Print the welcome message
	la a0 welcome
	jal printstr

	# for i = 1, i < argc, ++i
	li s2 1
loop_start:	
	bge s2 s0 loop_exit

	li a0 argument
	jal printstr
	
	slli t0  s2 2  # t0 = i * 4
	add  t0  t0 s1 # t0 = argv + (4 * i)
	lw   s3 0(t0)  # s3 = argv[i]

	mv a0 s3
	jal printstr
	la a0 newline
	jal printstr

	la a0 ashex
	jal printstr
	
	mv a0 s3       
	jal parsehex
	mv s3 a0       # s3 = parsehex(argv[i])
        jal printhex
	la a0 newline
	jal printstr

	la a0 as16
	jal printstr

	# Do the actual conversion, and print it out.
	mv a0 s3
	jal as_ieee_16
	jal printhex
	la a0 newline
	jal printstr

	la a0 newline
	jal printstr
	
	addi s2 s2 1	
	j loop_start
loop_exit:

	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	lw ra 0(sp)
	addi sp sp 20
	ret

	# Function for parsing a hexidecimal string
	# given as a string.  In C its declaration would
	# be
	# uint32_t parsehex(char * str)

	# We need this because although the simulator has
	# a built in "read number in hex", THAT is reading
	# from the console and we want to read from the command line.

	# This is not a leaf function becaues it will print an error
	# if the item is not well formed.
parsehex:
	addi sp sp -12
	sw ra 0(sp) # We need some saved variables
	sw s0 4(sp) # str
	sw s1 8(sp) # the return value
	mv s0 a0    # Save str in s0
	li s1 0     # Return value starts at 0
	li t1 '0'   # Temporary values for ASCII character
	li t2 '9'   # constants that are compared against.
	li t3 'A'
	li t4 'F'
	li t5 'a'
	li t6 'f'

	# This takes advantage that "0-9" < "A-F" < "a-f" so
	# we can add/subtract the values and compare on the
	# range

	# while (*str) != 0
parsehex_loop:       
	lbu t0 0(s0) 		     # t0 = *str
	beqz t0 parsehex_exit
	
	blt t0 t1 parsehex_error     # if(*str < '0') -> error
	bgt t0 t2 parsehex_not_digit # if(*str > '9') -> not digit
	sub t0 t0 t1                 # to = *str - '0'
	j parsehex_loop_end

parsehex_not_digit:
	blt t0 t3 parsehex_error     # if(*str < 'A') -> error
	bgt t0 t4 parsehex_lower     # if(*str > 'F') -> not upper
	sub t0 t0 t3                 # t0 = *str - 'A' + 10
	addi t0 t0 10
	j parsehex_loop_end

parsehex_lower:
	blt t0 t5 parsehex_error     # if(*str < 'a') -> error
	bgt t0 t6 parsehex_error     # if(*str > 'f') -> error
	sub t0 t0 t5                 # to = *str - 'a' + 10
	addi t0 t0 10

parsehex_loop_end:
	slli s1 s1 4                 # ret = ret << 4 | t0
	or s1 s1 t0
	addi s0 s0 1                 # str++
	j parsehex_loop

parsehex_error:
	la a0 invalid
	jal printstr
	li s0 0xFFFFFFFF
	j parsehex_exit
	
parsehex_exit:
	mv a0 s1                     # set return value and cleanup
	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	addi sp sp 12
	ret

	# This is an example of using ecall to call
	# one of the built-in system routines
printhex:	
	li a7 PRINT_HEX
	ecall
	ret
	
printstr:
	li a7 PRINT_STR
	ecall
	ret


# DO NOT CHANGE ANY CODE ABOVE THIS LINE!

	# This is the function you need to complete,
	# It is the same as the C version.  It accepts
	# a 32b value in IEEE floating point, and returns
	# a 16b value that is the IEEE half-precision floating
	# point number.  The upper 16b of the returned data
	# should be 0

	
	# This is a leaf function so we don't need
	# to save any caller saved registers (e.g. ra)
	# UNLESS you want to call other functions	
as_ieee_16:
	li a0 0xdeadbeef
	ret
