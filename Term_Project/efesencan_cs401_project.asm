.data
inputFile:     .asciiz "C:/Users/efese/Desktop/efesencan_cs401_term_project/second_input.txt"
insertion_Out:    .asciiz "C:/Users/efese/Desktop/efesencan_cs401_term_project/insertion_sort_out.txt"
selection_Out:    .asciiz "C:/Users/efese/Desktop/efesencan_cs401_term_project/selection_sort_out.txt"
readBuffer:   .space 8192 # the space allocated for the array that hold all strings in the txt file (the size can be increased depending on the input txt file size)
tempElement:   .space 12 # the space allocated for storing single string (word)
.text
.globl main

main:
	move $s0,$zero # variable for checking which sort operation or whether program termination will be done
	jal openFile  # open the input txt file
	move $s1,$v0 # for syscall 13 (for opening file), file description is stored in $s1 (because we will need it in the read file part)
	jal allocateMemory # create space for the heap
	move $s2,$v0  # $s2 points to the starting point of the heap (always)(in case $s3 is updated we will need the beginning of the array)
	move $s3,$v0  # $s3 points to heap index (in other words, it will point ot eh starting address of the string words)
	move $s4,$zero  #position in char array (string words)
        
readFile:
	#read from file
	#set a0 a1 a2 , fileDescriptor, *buffer, bufferSize
	li $s7, 8192   # DEFINE THE HEAP SIZE IN TERMS OF BYTES (it should be equal to the readBuffer size) (the size can be increased depending on the input txt file size)
	move $a0,$s1 # # $s1 was previously storing the file descriptor 
        la $a1,readBuffer # adress of the input buffer
        move $a2, $s7 # number of bytes to read (number of bytes were initialized in $s7)
        li $v0,14   # syscall for read file, v0 contains number of characters read(0 if end of file)
        syscall
        
	move $s6,$v0 #s6 now has how many char to read (0 if end of file meaning that there is no character to read)
	bgt $s6,0,storeWordsinHeap # if you are not end of file (0) or if there is not any error (<0), then store the words in heap
	
	jal closeFile # close the file after reading is done
        j endOfHeapProcessing # end of the file reading part
        
storeWordsinHeap:
	# read the characters in the txt file and store it in the allocated heap
	move $t0,$zero  #loop counter for i in range(buffer_size)
	li $t4, 12 # assign the chunk size 12 bytes to $t4
	readBytesFromBuffer:
		lb $t1,readBuffer($t0) # $t2 is the byte loaded from the txt file (since all the bytes are stored in readBuffer)
		beq $t1,10,readNewWord   # check if we encounter /n (hexadecimal version in mips is 10)
		jal writeToHeap # write that byte to the corresponding index of the heap	
		addi $s4,$s4,1 # incrament 1 byte to get next character (heapte point edilen her kelimeyi başlangıcından itibaren itere ve point eder)
		
	checkEndCondition:	
		addi $t0,$t0,1       # incrament the loop counter
		bge $t0,$s7,endOfHeapProcessing # if we read 1024 characters (or more depending on the initial setup) end the loop (previously it was writing 1024 instead of $s7)
		j readBytesFromBuffer       # else continue the iteration
			
	readNewWord:
		jal writeToHeap    # write the \n character to the heap
		add $t2,$s3,$t4   # we also incrament the real index in the heap by 12 since we will be moving writing to the next chunk of the heap array
		move $s3,$t2   # $s3 points the index of the starting point of a word (therefore at the end of each line, it is incramented by 12(since our word block is 12 byte))
		move $s4,$zero 	  # since $s4 is pointing the starting point of the character (not the actual address in heap), we are setting it as zero
		j checkEndCondition
	
	endOfHeapProcessing:
	    beq $s0,0, insertionSort   # go to insertion sort function
            beq $s0,1, selectionSort   # go to selection sort function
            j terminateProgram         # if $s0 is 3, this measn that we are going to terminate the program

writeToHeap:
	add $t3,$s3,$s4  #byte address of next char in char array ($s3 is pointing to the index of the 2D array, $s4 is pointing the address the charArray (word))
	sb  $t1,($t3) # store the character to the heap ($t3 is the real index in heap)
	jr $ra

closeFile:
	move $a0,$s1 # a0 stores the file descriptor
	li $v0,16 # syscall for close file
	syscall
	jr $ra

allocateMemory: # we are also allocating memory in heap because when we perform sorting, it is easier for us to access index (since we allocate each word 12 bytes)
	#allocate memory in heap to store the string elements
	move $a0, $s7 #added this line, commented line above
	li $v0,9 # v0 points starting address of the array of size 1024 (or more depending on the initial setup)byte
	syscall
	jr $ra

allocateTempMemory:
	#allocate memory in heap for storing single element
	li $a0,12 # a0 stores the total number of allocated bytes
	li $v0,9 # v0 points starting address of the array of size 12 byte
	syscall
	jr $ra
	
openFile:
	# read the txt file
        la $a0,inputFile   #filename's address must be stored in a0
	li $a1,0           #flags must set in a1       
	li $a2,0           #mode must set in a2
	li $v0,13          # syscall for opening file
	syscall
	jr $ra

insertionSort:
	li $t4, 12  # store the byte chunk size in $t4
	move $t7,$s3 # store the pointer of the last word's starting address in $t7
    	add $s3,$s2,$t4 #$s3 points the first index now (i = 1) ($s2 was always pointing to the beginning of the heap (i = 0))
   	outerForLoop:
   		jal firstAssignment  #key = arr[i]
   		sub $t6, $s3, $t4 # j = i -1
   		innerWhileLoop:
   			blt $t6, $s2, endOfInnerWhileLoop #check if j >= 0
   			jal compare # check if arr[j] > key
   			beq $t8, 0, endOfInnerWhileLoop
   			jal secondAssignment  # arr[j + 1] = arr[j]
   			sub $t6, $t6, $t4     # j = j - 1 ($t4 was storing 12)
   			j innerWhileLoop
   			
   		endOfInnerWhileLoop:
   			jal thirdAssignment    # arr[j+1] = key
   		add $s3, $s3, $t4 # i++
   		move $t1,$s2      # $t1 is equal to the starting point of the heap array because we will be using that adress for file writing process
        	bge $s3,$t7,openInsertionOut # check if we are end of the array (i < n)
        	j outerForLoop # continue loop
   		
selectionSort:
	li $t4, 12  # store the byte chunk size in $t4
	move $t7,$s3   # $t7 points to the end position of the heap (which is size n)
	move $s3, $s2 # $s3 points to the starting point of the heap and it will simulating the loop variable i
	outerForLoopSelection:
		move $t0, $s3 #min index = i
		add $t6, $s3, $t4 # j = i + 1
		innerForLoop:
			bge  $t6, $t7, endInnerForLoop  # check if j < n
			jal compareSelection # check if arr[j] < arr[min-index]
			bne $t8, 0, ifStatement # check if a are going to enter the if condition
			add $t6, $t6, $t4 # j = i +1
			j innerForLoop # continue the inner loop
		ifStatement:
			move $t0, $t6 #min-idx = j
			j innerForLoop # continue inner loop
		endInnerForLoop:
			jal swap # do swap after the inner for loop
		add $s3, $s3, $t4 # i++
		move $t1,$s2      # $t1 is equal to the starting point of the heap array (we will be using $t1 for the starting address buffer for file writing process)
		sub $t9, $t7, $t4 # $t9 = n - 1
		bge $s3,$t9,openSelectionOut # check if we are end of the array (i < n - 1)
		j outerForLoopSelection	  # if it did not end (i < n), then go to outer loop 
			           
swap:
	# swap (&arr[min_idx], &arr[i])
	# min index is stored in $t1
	
	lw $t2, 0($t0) # store arr[min-idx] first
	lw $t3, 4($t0)
	lw $t5, 8($t0)
	
	lw $t4, 0($s3)
	sw $t4, 0($t0)
	lw $t4, 4($s3)
	sw $t4, 4($t0)
	lw $t4, 8($s3)
	sw $t4, 8($t0)
	
	sw $t2, 0($s3)
	sw $t3, 4($s3)
	sw $t5, 8($s3)
	
	li $t4, 12 # because $t4 was initalized 12 which represents the chunk size in the beginning of the selection sort function
	jr $ra
		
compareSelection:
	# check if arr[j] < arr[min-index]
	li $t4, 12 # store the chunk size in $t4
	move $t9, $zero # byte counter
	forEachByteSelection:
		add $t5,$t9, $t6  # $t6 was representing index j
		lb $t8, 0($t5) # $t8 = arr[j]
		add $t5, $t9, $t1 
		lb $s5, 0($t5)# $s5 = arr[min-index]
		bgt $t8, $s5, endCompareDontEnterIf
		bgt $s5, $t8, endCompareEnterIf
		
		addi $t9, $t9, 1
        	beq $t9, $t4, endCompareDontEnterIf  # check if are end of the byte chunk
        	j forEachByteSelection
        
	endCompareEnterIf:
		li $t8,1
        	jr $ra
	
	endCompareDontEnterIf:
		li $t8,0
        	jr $ra
firstAssignment:
	# key = arr[i]
	# since we have 12 bytes in total, we need 3 registers each stores 4 bytes
	addi $s5, $s7, -12 #  substract 12 from buffer size (1012 for 1024 bytes of buffer) $s7 is holding the total buffer size
	lw $t1, 0($s3)
	lw $t2, 4($s3)
	lw $t3, 8($s3)
	
	
	add $s5, $s2, $s5 # s5 = 1012($s2)
	sw $t1, ($s5)  # store words in key (key = arr[i])
	addi $s5, $s5, 4  # s5 = 1016($s2)
        sw $t2, ($s5)  # we store the key in the last element of the heap
        addi $s5, $s5, 4 # s5 = 1020($s2)
        sw $t3, ($s5)
        jr $ra

secondAssignment:
	#arr[j + 1] = arr[j]
	move $t0, $zero
	add $t0, $t0, $t6  # 12($t6)
        lw $t4, ($t0)
        addi $t0, $t0, 4
        lw $t5, ($t0)
        addi $t0, $t0, 4
        lw $t8, ($t0)    # we stored arr[j] at this point 
        
        addi $t0, $t0, 4
        sw $t4, ($t0)
        addi $t0, $t0, 4   
        sw $t5, ($t0)
        addi $t0, $t0, 4
        sw $t8, ($t0)   # we performed arr[j + 1] = arr[j] at the end of this point
        li $t4, 12 # because $t4 was initalized 12 which represents the chunk size in the beginning of the insertion sort function
        jr $ra
        
thirdAssignment:
	# arr[j + 1] = key
	# key was previously stored in $t1, $t2, $t3, therefore we directly use them
	li $t5,12
	add $t5, $t5, $t6  # 12($t6)
	sw $t1, ($t5)
	addi $t5, $t5, 4
	sw $t2, ($t5)
	addi $t5, $t5, 4
	sw $t3, ($t5)
	jr $ra
	
compare:
	li $t4, 12  # store the chunk size in $t4
	move $t9, $zero # byte counter
	forEachByte:
		sub $s5, $s7, $t4 #  substract 12 from buffer size (1012 for 1024 bytes of buffer) $s7 is holding the total buffer size
		add $t5,$t9, $t6   # add single byte to the byte chunk of index j
		lb $t8, 0($t5) # $t8 = arr[j]
		add $s5, $s2, $s5 # get address of the last element in the heap (key) (preivously it was wiritng 1024 işnstead of $s5)
		add $t5, $t9, $s5 
		lb $s5, 0($t5)# key
		
		bgt $t8, $s5, endCompareKeepWhileLoop  # check if arr[j] > key
		bgt $s5, $t8, endCompareStopWhileLoop  # check if key > arr[j]
		
		addi $t9, $t9, 1  #incrament byte counter by 1
        	beq $t9, $t4, endCompareStopWhileLoop   # if we reach the end of byte chunk
        	j forEachByte
	
	endCompareKeepWhileLoop:   # we will end the comparison and keep iterating the inner while loop
		li $t8,1
        	jr $ra
	endCompareStopWhileLoop:   # we will end the comparison and also stop the inner while loop
		li $t8,0
        	jr $ra
        		
terminateProgram:
    li   $v0, 16       # system call for close file
    move $a0, $t3      # file descriptor to close
    syscall            # close file
    addi $s0,$s0,1     # we add 1 to do selection sort 
    blt $s0, 2 ,readFile # if $s0 is less than 3, then we will create the heap again and use it for selection sort
    li $v0,10 # syscall for exiting the program
    syscall
    
openInsertionOut:
	# syscall for opening txt file for insertion out
        la $a0, insertion_Out # a0 holds address of the null terminated string
        li $a1, 1  #flag
        li $a2, 0  #mode
        li $v0,13	# syscall for open file (v0 contains file descriptor)
        syscall  
        move $t3,$v0   # we need these file descriptors to close the file in terminateProgram therefore we store them
        j writeToFile

openSelectionOut:
	# syscall for opening txt file for selection out     
        la $a0, selection_Out # a0 holds address of the null terminated string
        li $a1, 1        #flag    
        li $a2, 0 	 #mode
        li $v0,13	 # syscall for open file (v0 contains file descriptor)
        syscall  
        move $t3,$v0
        j writeToFile

writeToFile:
        move $a0,$t3   # a0 = file descriptor
	move $a1,$t1   # address of the input buffer (starting address of the heap array)
	jal getLength  # find the length of the to be written on that line
	move $a2, $t9  # the length of the word is stored in $t9
        li   $v0,15    # syscall for writing to file
	syscall
        addi $t1,$t1 12 # get the next index of the heap array
        bge $t1,$t7,terminateProgram # check if we are end of the heap array
        j writeToFile 

getLength:
	# find the length of the word that will be printed to the txt out file
	li $t9,0 #counter
	move $t8, $t1
	countLoop:
		lb $t2,0($t8) # t2 is responsible for checking which byte we are currently at
		beq $t2,10,finishCounter # check if $t2 = \n
		addi $t9, $t9, 1
		bge $t9, 12, noCharacters
		addi $t8,$t8, 1
		j countLoop
	finishCounter:
		addi $t9, $t9, 1  #this addtional one is for putting \n
		jr $ra
	noCharacters:
		li $t9, 0
		jr $ra
printString:
	# print the elements in the heap
	# $s2 points the starting position of the heap
	# $s3 points to the ending position of the heap
        la $a0,($s2)
        li $v0,4
        syscall
        addi $s2,$s2 12
        bge $s2,$s3,terminateProgram
        j printString

#assignment: (tried assigning array elements to temporary allocated heap of 12 bytes but something did not work)
	# key = arr[i]
#	jal allocateTempMemory
#	move $s5,$v0  #s5 points to the starting point of the temp chararray of 12 byte
#	move $t5, $s3 # $t5 points index location i of the heap array
#	li $s4,0
#	Process:
#		lb $t6,($t5) # t7 is responsible for checking which byte we are currently at
#		bne $t6,10,keepAssigning   # if we encounter /n (hexadecimal version in mips is 10)
#		jr $ra
#	keepAssigning:
#		add $t5,$t5,$s4  #byte address of next char in char array ($s3 is pointing to the index of the 2D array, $s4 is pointing the address the charArray (word))
#		sb  $t6,($s5) # store the character to the heap ($ t3 is the real index in heap)
#		addi $s4,$s4,1 # incrament 1 byte to get next character (heapte point edilen her kelimeyi başlangıcından itabern itere eder)
#		addi $s5,$s5,1 # incrament the byte address of the temp heap
#		j Process

       
	
