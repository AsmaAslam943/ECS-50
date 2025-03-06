
	# Constants for system calling, for the print functions
	# and the like 
	.equ PRINT_DEC 0
	.equ PRINT_STR 4
	.equ PRINT_HEX 1
	.equ READ_HEX 11
	.equ EXIT 20

	# Data section messages.
	.data
welcome:   .asciz "Welcome to Hash Table Testing\n"

teststr1: .asciz "test1"
teststr2: .asciz "test2"
teststr1dup: .asciz "test1"

problemstring1: .asciz "assertion failed: "
problemstring2:	 .asciz " (a0) != "
problemstring3:	 .asciz " (a1)\n"

donestring: .asciz "Done with testing\n"
	
printmsg: .asciz "... Value returned\n"
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
	call printstr

	# Testing code from in development
	# jal malloctest	
	# jal strcmptest

	# Run the hashtable tests
	call hashtabletest

	li a0 donestring
	call printstr

	
	# Return 0
	li a0 0
	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	addi sp sp 20
	ret


	# streq(a, b)
	# basically it is !strncmp(a, b).
	# We do the !strncmp by doing a
	# set less than unsigned immediate of 1,
	# which means everything but all 0s will be set to
	# 0, while 0 will be set to 1
streq:	addi sp sp -4
	sw ra 0(sp)
	jal strcmp
	sltiu a0 a0 1 # will be 1 if equal, 0 otherwise
	lw ra 0(sp)
	addi sp sp 4
	ret


	# Technically a VALID hashfunction, it is
	# not very good which means things reduce to linked
	# list behavior, but that is fine for basic testing,
	# if anything it is better because it means that with just
	# 2 strings we will get collisions
strhash:
	li a0 67
	ret


	# A boolean function test for equality for integers.
inteq:
	beq a0 a1 int_is_equal 
	li a0 0
	ret
int_is_equal:
	li a0 1
	ret


	# Dumb integer hash function, just return
	# the number
inthash:
	ret


	# A simple test function to assert equality of the two
	# arguments.  This will print a message if there is a
	# failure, And will return a0 and a1 as were passed in, which
	# means it can be used in the middle for testing purposes...
	
assert:
	bne a0 a1 problem
	ret
problem:
	addi sp sp -12
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	mv s0 a0
	mv s1 a1
	li a0 problemstring1
	call printstr
	mv a0 s0
	call printhex
	li a0 problemstring2
	call printstr
	mv a0 s1
	call printhex
	li a0 problemstring3
	call printstr
	mv a0 s0
	mv a1 s1
	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	addi sp sp 12
	ret
	
	

	
	# This is a primary test for the hash table.
	# You can add more tests here, but TBT this is designed to
	# be fairly comprehensive...
	
hashtabletest:
	addi sp sp -16
	sw ra 0(sp)
	sw s0 4(sp)		# Will contain the hashtable
	sw s1 8(sp)
	sw s2 12(sp)

				
	li a0 7
	la a1 strhash
	la a2 streq

	li a7 createHashTable
	jal campground
	mv s0 a0		# Save our hashtable

	mv a0 s0		# Insert the first entry
	la a1 teststr1
	li a2 0xdeadbeef
	li a7 insertData
	jal campground

	mv a0 s0		# make sure the second string can't be found
	la a1 teststr2
	li a7 findData
	jal campground
	li a1 0
	jal assert

	mv a0 s0		# and that the first string can
	la a1 teststr1
	li a7 findData
	jal campground
	li a1 0xdeadbeef
	jal assert

	mv a0 s0		# And a different pointer to the same string can
	la a1 teststr1dup
	li a7 findData
	jal campground
	li a1 0xdeadbeef
	jal assert

	mv a0 s0		# and now insert the second string
	la a1 teststr2
	li a2 0xcafef00d
	li a7 insertData
	jal campground

	mv a0 s0		# and make sure the first can still be found
	la a1 teststr1
	li a7 findData
	jal campground
	li a1 0xdeadbeef
	jal assert

	mv a0 s0
	la a1 teststr1dup
	la a7 findData
	jal campground
	li a1 0xdeadbeef
	jal assert
	
	mv a0 s0		# Along with the second..
	la a1 teststr2
	la a7 findData
	jal campground
	li a1 0xcafef00d
	jal assert



	# Much bigger loop, using integers instead of strings, putting 1-255 into the
	# table and making sure they are recorded properly.
	
	li a0 10
	la a1 inthash
	la a2 inteq
	la a7 createHashTable
	jal campground
	
	mv s0 a0
	li s1 1
	li s2 256

testloop_start:
	# check that data isn't in yet
	mv a0 s0
	mv a1 s1
	la a7 findData
	jal campground
	li a1 0
	jal assert

	# Now put it in, the same key and value
	mv a0 s0
	mv a1 s1
	mv a2 s1
	la a7 insertData
	jal campground

	# And make sure we can find it
	mv a0 s0
	mv a1 s1
	la a7 findData
	jal campground
	mv a1 s1
	jal assert

	addi s1 s1 1
	blt s1 s2 testloop_start

	# And now lets check again for everything.
	li s1 1
testloop2_start:	
	mv a0 s0
	mv a1 s1
	la a7 findData
	jal campground
	mv a1 s1
	jal assert

	addi s1 s1 1
	blt s1 s2 testloop2_start

	# Dummy malloc call to ensure things
	# are initialized for the malloc check
	li a0 8
	jal malloc
	
	jal malloccheck

	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	addi sp sp 16
	ret


testprint:
	addi sp sp -4
	sw ra 0(sp)
	jal printhex
	la a0 printmsg
	jal printstr
	lw ra 0(sp)
	addi sp sp 4
	ret
	
