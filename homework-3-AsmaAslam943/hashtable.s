	# Data section messages.
	.data
message:   .asciz "Need To Implement\n"
	
	## Code section
	.text
	.globl createHashTable
	.globl insertData
	.globl findData

#struct HashBucket {
#  void *key;
#  void *data;
#  struct HashBucket *next;
#};

#typedef struct HashTable {
#  unsigned int (*hashFunction)(void *);
#  int (*equalFunction)(void *, void *);
#  struct HashBucket **data;
#  int size;
#  int used;
#} HashTable;


#HashTable *createHashTable(int size,
#                           unsigned int (*hashFunction)(void *),
#                           int (*equalFunction)(void *, void *));
createHashTable:
	addi sp sp -24 			# We need to create a stack of size 24 bytes; this is because we need to ensure that the stack has enough space 
	sw ra, 0(sp)			# We need to stor word the return address 0 
	sw s0, 4(sp)			# Used s registers to save at 4, 8, 12, 16. 
	sw s1, 8(sp)			
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a0 				# Use the mv function to move s0 to a1; s0 = size 
	mv s1, a1				# Set s1 equal to hashfunction and s2 is equalfunction 
	mv s2, a2 

	li a0, 20 				# This loads the immediate 20 into a0; that's because that's what we need for this hash table 
	call malloc 			# Call on malloc to allocate 20 bytes of memory 
	beqz a0, malloc_failure 	# If the branch fails, then we branch to the malloc_failure 
	
	mv s3, a0 				# Sets s3 = a0 
	sw s1, 0(s3)			# Store hash function pointer from s1 to first element in hash table 
	sw s2, 4(s3)			# This stores the equal pointer in s2 in line 38 to 2nd field and so on 
	sw s3, 8(s3)			# This line stores s3 value into a mem address of s3 AND 8 
	sw s0, 12(s3)			# This basically stores the table into size 12
	sw zero, 16(s3)			# Initiates field to 0 

	mv a0, s0 				# Sets table size (aka s0 = a0)
	slli a0, a0, 2 			# I used value 2 here because it x4 to compute number of bytes for bucket array 
	call malloc				# Allocates memory 
	sw a0, 8(s3)			# This stores the pointer in an array with an offset of 8 hence why we use 8(s3)
	beqz a0, malloc_failure		#Use branches to branch to malloc_failure in line 83 

	sw a0, 8(s3)

	mv t0, a0 				# We move the bucket pointer into a temporary t0; a0=t0
	li t1, 0 				# Loading 0 into t1 

loop_buckets: 
	bge t1, s0, end_loop 	#Base case; branches to end_loop if the t1 <= s0 
	sw zero, 0(t0)			# Storing 0 at 0(t0) the beginning 

	addi t0, t0, 4			# Increment pointer by 4 
	addi t1, t1, 1 			# Increments loop counter by 1 
	j loop_buckets 


end_loop: 
	mv a0, s3 				# This moves into s3; so we can get a0 back  

	lw ra, 0(sp)			# VITAL; they restore the saved registers from stack 
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp, 24 		# Ensures the stack pointer is safe by deallocating 24 bytes
	ret 

malloc_failure: 
	li a0, 0				# This makes sure value is 0 
	addi sp, sp, 24 		# Ensure the stack pointer is at 24 because we need to ensure there is enough space on the stack 
	ret



# void insertData(HashTable *table, void *key, void *data);
insertData:
	addi sp sp -24				#This allocates space on the stack for 24 bytes 
	
	sw ra, 0(sp)				#This line saves the return address

	# The following lines save s0-s4 in their respective places on the hashtable 
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)

	mv s0, a0 				#This saves table pointer in s0 
	mv s1, a1 				#Makes sure key is saved in s1 
	mv s2, a2 				#Ensures data is in s2 

	li a0, 12 				# This works to load immediate 12 
	call malloc 			# Allocates the data into the 12 bytes 
	beqz a0, malloc_failure		#This branches to malloc_failure 
	mv s3, a0 				# This moves into register a0 --> s3 
	
	lw t0, 0(s0)			# This loads hashtable pointer into the HashTable 
	mv a0, s1 				# Moves key in a0 
	jalr ra, 0(t0)			# Calls on hash function 
	mv s4, a0 				# Saves hash index in s4 

	lw t0, 12(s0)			# Loads sixe of hash in t0 and calculates remainder 
	remu s4, s4, t0 		
	slli s4, s4, 2 
	lw t0, 8(s0)			# loading base address into t0 
	add s4, t0, s4 			#adding a byte address 

	lw t0, 0(s4)			# Indicates teh current s4 in t0 

	#Ensures s registers are saved
	sw s1, 0(s3)
	sw s2, 4(s3)
	sw t0, 8(s3)
	sw s3, 0(s4)

	lw t0, 16(s0)	
	addi t0, t0, 1
	sw t0, 16(s0)

 # This restores s0-s4 
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	addi sp, sp, 24 		# This frees teh stack space 

	ret 


# void *findData(HashTable *table, void *key);
findData:
	addi sp sp -24			# Adjusts stack pointer 
	sw ra, 0(sp)			# This saves the return address and callee registers  
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)

	mv s0, a0 				# This moves a0 and a1 into s1 and s0 
	mv s1, a1 

	lw t0, 0(s0)			# This loads value in s0 into t0 
	mv a0, s1 				# s1 = a0 
	jalr ra, 0(t0) 			# This does a jump 
	mv s4, a0

	lw t0, 12(s0)			# Load into hash t0 
	remu s4, s4, t0 		# Calculates remainder of s4 by table sixe 
	slli s4, s4, 2 			# Multiplies index by 4 to convert
	lw t0, 8(s0)			
	add s4, t0, s4 

	lw s3, 0(s4)			# Current head of the linked list 

finder: 
	beqz s3, unfound	# This branches into unfound if null 

	lw t0, 0(s3)		# Loads the key from bucket 
	mv a0, s1			# Moves search + current key into a0 and a1 
	mv a1, t0 
	lw t0, 4(s0)
	jalr ra, 0(t0)		# Calls on equal function 
	bnez a0, found 		# If keys are equal, branch to found 

	lw s3, 8(s3) 
	j finder 

unfound: 
	li a0, 0 			# If we reach the end of the list; then we set a0 t0 0 
	j final 

found: 
	lw a0, 4(s3)		# If a key is matching then value at offset 4 is stored in a0 

 #Final is just a function that ensures all my saved registers are stored
 #Restores, readjusts and returns a function 
final: 
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)

	addi sp, sp, 24 
	ret 

