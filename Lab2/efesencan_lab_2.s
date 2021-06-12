##
## template for your assembly programs
##
##

#################################################
#					 	#
#		text segment			#
#						#
#################################################

	.text		
       .globl __start 
__start:		# execution starts here

	
	# say hello
	la $a0,starting
	li $v0,4
	syscall
	
		
	#############################
	# load the fp number in a fp register (just for printing)
	l.d $f0, X
	jal message5a
	# print X
	mov.d $f12, $f0
	li $v0, 3
	syscall
	

	# load the fp number in an integer register $t0 and $t1 (the operations must be performed on $t0 and $t1)
	mfc1 $t0, $f0
	mfc1 $t1, $f1
	
	# YOUR CODE GOES HERE
	
	srl  $t3,$t1,31   ## get the most significant bit of the t1, with the the following format x00000.... and assign it to t3
	addi $t3,$t3,1    ## make the t3 1 (negative) if it is 0 (positive), and vice versa..
	sll  $t3,$t3,11   ## get the udapted version of the t3 bit with the x00000... format
	
	sll $t4, $t1 ,1   # get rid of the initial most significant bit
	srl $t4, $t4, 21  # get the exponent bits 
	
	subi $t4 , $t4 ,3        # subtract 3 from the exponent bits, so that we divide the number by 8
	add $t4 ,$t4,$t3          # concatenate the negated most significant bit with exponent bits
	sll $t4 ,$t4,20           # hence we get the first 12 bit of our number
	
	sll $t2, $t1,12	
	srl $t2 , $t2,12 ## get the last 12 bits (fraction part of the t1
	add $t1, $t4, $t2        ## concatenate the updated first 12 bits (negated msb + updated exponent bits) with the intiial last 20 bit of the number 
	
	mtc1 $t0,$f0
	mtc1 $t1,$f1
	
	jal message5b
	
	# store the $f0 result in memory
	# print X/(-4)
	mov.d $f12, $f0
	li $v0, 3
	syscall
	
	
	#######################
	#######################
	# say good bye
	la $a0,endl
	li $v0,4
	syscall

	# exit call
	li $v0,10
	syscall		# au revoir...


############## messages


message5a:
	la $a0,mes5a
	j message	

message5b:
	la $a0,mes5b
	j message

message:
	li $v0,4
	syscall
	jr $ra

#################################################
#					 	#
#     	 	data segment			#
#						#
#################################################

	.data
starting:	.asciiz "\n\nProgram Starts Here ...\n"
endl:	.asciiz "\n\nexiting ..."


X: .double -8.8888888E230


mes5a:	.asciiz "\n\nX: "
mes5b:	.asciiz "\n\nX/4: "
##
## end of file fib.a
