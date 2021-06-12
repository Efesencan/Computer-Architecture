.data

array1: .word 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return TRUE for this array
array2: .word 8, 9, 6, 7, 5, 4, 3, 2, 1, 0 # final 0 indicates the end of the array; 0 is excluded; it should return FALSE for this array

true: .asciiz "TRUE\n"
false: .asciiz "FALSE\n"
default: .asciiz "This is just a template. It always returns "

.text

main:
      la $a0, array2 # $a0 has the address of the A[0]
      jal lenArray   # Find the lenght of the array
      
      move $a1, $v0  # $a1 has the length of A
      
      jal Descending

      bne $v0, 0,  yes
      la  $a0, false
      li $v0, 4
      syscall
      j exit

yes:  la    $a0, true
      li $v0, 4
      syscall

exit:
      li $v0, 10
      syscall


Descending:
###############################################
#   Your code goes here
###############################################
      sub $sp, $sp, 12   # we adjust the stack for saving return address and 2 arguments
      sw  $ra, 8($sp)   # stores the return address in stack
      sw  $a1, 4($sp)   # stores the length of array in stack
      sw  $a0, 0($sp)   # stores the array address in stack
      sle $t0, $a1, 1 # t0 1 if lenA <= 1, else 0
      beq $t0, $zero, First_check # go to the first check (A[0] > A[1])
      li $v0, 1       # if array has only one element return 1
      addi $sp, $sp, 12        # pops 3 items off the stack
      jr $ra                   # return backs to caller program
      
First_check: # checking if A[1] < A[0]
      lw $t1 0($a0) # get A[0]
      lw $t2 4($a0) # get A[1]
      slt $t3, $t2, $t1 # if A[1] < A[0]
      bne $t3, $zero, Second_check # if A[1] < A[0], then go to recursive check
      li $v0, 0  # if A[0] <= A[1], return 0
      jr $ra              # return backs to caller program
          
Second_check: # we have the recursive call here
	subi $a1, $a1, 1 # lenA - 1
	addi $a0, $a0, 4 # &A[1]
	jal Descending   # call the function recursively
	lw $ra, 8($sp)   #restore return adress
	addi $sp, $sp, 12 # pops 3 items off the stack
	jr $ra # return backs to caller program
        
###############################################
# Everything in between should be deleted
###############################################
      	

lenArray:       #Fn returns the number of elements in an array
      addi $sp, $sp, -8
      sw $ra,0($sp)
      sw $a0,4($sp)
      li $t1, 0

laWhile:       
      lw $t2, 0($a0)
      beq $t2, $0, endLaWh
      addi $t1,$t1,1
      addi $a0, $a0, 4
      j laWhile

endLaWh:
      move $v0, $t1
      lw $ra, 0($sp)
      lw $a0, 4($sp)
      addi $sp, $sp, 8
      jr $ra
