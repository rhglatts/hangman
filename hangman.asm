# CS2640 Final Project - Hangman Game
# Team Member: Huijun Hu, Yvonne Li, Isaiah Hessler, Rebecca Glatts

# Bitmap Display Configuration:
# - Unit width in pixels: 4					     
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10010000

.data
 frameBuffer: .space 0x80000
 prompt: .asciiz "\nEnter 1 letter each time: "
 strArray: .asciiz "iceberg", "hangman", "ironman", "earplug", "cabbage", "adopter", "biznaga", "hackman", "mercury", "purpose"
 welcome_msg: .asciiz "*** Welcome to the Hangman Game ***"
 over_msg: .asciiz "*** Game Over!! ***"
 word_out:.asciiz "Hint: it is 7-letter long.\n"
 dash: .asciiz "_ "
 space: .asciiz " "
 hiddenStr: .space 7 
 
 # test only, delete in final
 s1: .asciiz "The word generated is: (display to test, not in final program): "
 s2: .asciiz "\ntest if we can access char in str: (display to test, not in final program): "
 
.text
main: 
li $v0, 55  # print welcome prompt with pop window
la $a0, welcome_msg
li $a1, 1
syscall
 
jal ranGen		# call ranGen, string return in $v0
move $t1, $v0		# the string now in $t1

la $a0, s1
jal print
move $a0, $t1
jal print		# print for test only


li $v0, 55  # print welcome prompt with pop window
la $a0, word_out
li $a1, 1
syscall
 
la $t0, hiddenStr
move $t0, $t1		# $t0 = $t1

la $a0, s2
jal print

li $t2, 0		# iterator
charLoop:

beq $t2, 7, endCharLoop
lb $a0, 0($t0)
beq $t8, $a0, equals
 la $a0, dash	# TEST correct input by adding a _ where a correct guess is made
 jal print

charMid:

add $t0, $t0, 1		# increment str[i]
add $t2, $t2, 1		# increment iterator
j charLoop

 equals:
 li $v0, 11
syscall


j charMid
 
 
endCharLoop:
addi $t0, $t0, -7		# increment str[i]
addi $t2, $t2, -7		# increment iterator
j loopReturn



li $t3, 1		# iterator

loop:

beq $t3, 10, game_over  	# when the amount of incorrect guesses reaches 10, it's gameover
 
la $a0, prompt			# prompt ask for input
jal print

li $v0, 12
syscall
move $t8, $v0		# store user char input in $t8

j charLoop

loopReturn:

 add $t3, $t3, 1
 j loop
 

 

##************ random string generator **************************************#
ranGen:
# get the time
li	$v0, 30		# get time in milliseconds - 64-bits
syscall

move	$t0, $a0	# save the lower 32-bits of time

# seed the random generator
li	$a0, 1		# random generator id
move 	$a1, $t0	# seed from time
li	$v0, 40		# seed random number generator syscall
syscall

li	$a0, 1		# random generator id
li	$a1, 10		# upper bound of the range
li	$v0, 42		# random int range
syscall

# $a0 now holds the random number
move $t1, $a0		# save the generated index into $t1

sll $t1, $t1, 3         # $t1 = $t2 * 8
la $v0, strArray	# initial addr of array -> $t0
add $v0, $v0, $t1	# locate element in array[index]

jr $ra
########## end load the string from array with generated index ################
	
print:
	li $v0, 4
	syscall
	jr $ra	
	
print_int:
	li $v0, 1
	syscall
	jr $ra	

######################### Initial Bitmap ###########################################
Bitmap:
	# fill background color
	la 	$t0, frameBuffer		# load frameBuffer addr
   	li 	$t1, 0x8000			# save 256x512 pixels
   	li 	$t2, 0x00A9C0AA			# load color 
   bg:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, bg

	# draw gallow
	la 	$t0, frameBuffer
	addi	$t0, $t0, 3908			# locate left top coner of gallow
	li	$t1, 35				# gallow horizontal wood width
	li	$t2, 0x00663300			# load gallow color

	jr 	$ra				# exit bitmap initializating
   gallow_top:
   	sw 	$t2, 0($t0)
   	sw 	$t2, 256($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_top
   
	la 	$t0, frameBuffer
	addi	$t0, $t0, 4208			# locate 1 pixel down left top coner of gallow
	li	$t1, 8 				# string  length
   gallow_string:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 256			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_string
	
	la 	$t0, frameBuffer
	addi	$t0, $t0, 4552			# locate 1 pixel down right top coner of gallow
	li	$t1, 92 			# stand wood length
   gallow_stand:
   	sw 	$t2, 0($t0)
   	sw 	$t2, 4($t0)
   	addi   	$t0, $t0, 256			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_stand

	sub 	$t0, $t0, 140			# locate start point of gallow base
	li	$t1, 37 			# base  length
   gallow_base1:
   	sw 	$t2, 0($t0)
   	sw 	$t2, 256($t0)
   	sw 	$t2, 256($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_base1
   	
   	add 	$t0, $t0, 516			# locate start point of gallow base
	li	$t1, 41 			# base  length
   gallow_base2:
   	sw 	$t2, 0($t0)
   	sw 	$t2, 256($t0)
   	sw 	$t2, 256($t0)
   	subi   	$t0, $t0, 4			# back to privious pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_base2
nop
nop
jr $ra
################################ End Initial Bitmap #######################################

################################ Hangman figure #######################################
   
   drawHead:				
   	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 6256		# line 1 centered at string position
	sw 	$t2, 0($t0)
	sw 	$t2, -4($t0)
	sw 	$t2, -8($t0)
	sw 	$t2, 4($t0)
	sw 	$t2, 8($t0)
	addi	$t0, $t0, 256		# line 2
	sw 	$t2, -16($t0)
	sw 	$t2, -12($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 16($t0)
	addi	$t0, $t0, 256		# line 3
	sw 	$t2, -20($t0)
	sw 	$t2, 20($t0)
	addi	$t0, $t0, 256		# line 4
	sw 	$t2, -24($t0)
	sw 	$t2, 24($t0)
	addi	$t0, $t0, 256		# line 5
	sw 	$t2, -28($t0)
	sw 	$t2, 28($t0)
	addi	$t0, $t0, 256		# line 6
	sw 	$t2, -28($t0)
	sw 	$t2, -16($t0)
	sw 	$t2, -8($t0)
	sw 	$t2, 8($t0)
	sw 	$t2, 16($t0)
	sw 	$t2, 28($t0)
	addi	$t0, $t0, 256		# line 7
	sw 	$t2, -32($t0)
	sw 	$t2, -12($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 32($t0)
	addi	$t0, $t0, 256		# line 8
	sw 	$t2, -32($t0)
	sw 	$t2, -16($t0)
	sw 	$t2, -8($t0)
	sw 	$t2, 8($t0)
	sw 	$t2, 16($t0)
	sw 	$t2, 32($t0)
	addi	$t0, $t0, 256		# line 9
	sw 	$t2, -32($t0)
	sw 	$t2, 32($t0)
	addi	$t0, $t0, 256		# line 10
	sw 	$t2, -32($t0)
	sw 	$t2, 32($t0)
	addi	$t0, $t0, 256		# line 11
	sw 	$t2, -32($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 32($t0)
	addi	$t0, $t0, 256		# line 12
	sw 	$t2, -28($t0)
	sw 	$t2, ($t0)
	sw 	$t2, 4($t0)
	sw 	$t2, 8($t0)
	sw 	$t2, 28($t0)
	addi	$t0, $t0, 256		# line 13
	sw 	$t2, -28($t0)
	sw 	$t2, -4($t0)
	sw 	$t2, 28($t0)
	addi	$t0, $t0, 256		# line 14
	sw 	$t2, -24($t0)
	sw 	$t2, 24($t0)
	addi	$t0, $t0, 256		# line 15
	sw 	$t2, -20($t0)
	sw 	$t2, 20($t0)
	addi	$t0, $t0, 256		# line 16
	sw 	$t2, -16($t0)
	sw 	$t2, -12($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 16($t0)
	addi	$t0, $t0, 256		# line 17
	sw 	$t2, -8($t0)
	sw 	$t2, -4($t0)
	sw 	$t2, ($t0)
	sw 	$t2, 4($t0)
	sw 	$t2, 8($t0)	
	nop				
	nop
	jr $ra				#j back where it left off
   
   drawBody:
   	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x2970	# line 1 centered at string position
	li	$t1, 20
	db_loop:
	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 0x100
   	sub 	$t1, $t1, 1
   	bnez 	$t1, db_loop
   	nop				
	nop
	jr $ra				#j back where it left off
   drawArm1:
   	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3070
	sw 	$t2, ($t0)
	sw 	$t2, -4($t0)
	sw 	$t2, -8($t0)
	sw 	$t2, -12($t0)
	sw 	$t2, -16($t0)
	sw 	$t2, -20($t0)
	sw 	$t2, -24($t0)
	sw 	$t2, -0x118($t0)
	sw 	$t2, -0x218($t0)
	sw 	$t2, -0x318($t0)
	sw 	$t2, -0x418($t0)
   	nop				
	nop
   	jr $ra				#j back where it left off
   	
   drawArm2:
   	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3170	
	sw 	$t2, ($t0)
	sw 	$t2, 4($t0)
	sw 	$t2, 8($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 16($t0)
	sw 	$t2, 20($t0)
	sw 	$t2, 24($t0)
	sw 	$t2, 0x118($t0)
	sw 	$t2, 0x218($t0)
	sw 	$t2, 0x318($t0)
	sw 	$t2, 0x418($t0)
   	nop				
	nop
   	jr $ra				#j back where it left off
   	
      	drawLeg1:
	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3C70	
	sw 	$t2, ($t0)
	sw 	$t2, -4($t0)
	sw 	$t2, -8($t0)
	sw 	$t2, -12($t0)
	sw 	$t2, -16($t0)
	sw 	$t2, -20($t0)
	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3C58	
	li	$t1, 10
	lg1_loop:
	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 0x100
   	sub 	$t1, $t1, 1
   	bnez 	$t1, lg1_loop
	nop
	nop
   	jr $ra				#j back where it left off
   drawLeg2:
   	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3C70	
	sw 	$t2, ($t0)
	sw 	$t2, 4($t0)
	sw 	$t2, 8($t0)
	sw 	$t2, 12($t0)
	sw 	$t2, 16($t0)
	sw 	$t2, 20($t0)
	sw 	$t2, 24($t0)
	la 	$t0, frameBuffer	# load frameBuffer addr
	li	$t2, 0x00FFFFFF		# load color white
	addi	$t0, $t0, 0x3C88	
	li	$t1, 15
	lg2_loop:
	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 0x100
   	sub 	$t1, $t1, 1
   	bnez 	$t1, lg2_loop
   	nop				
	nop
   	jr $ra				#j back where it left off
   	
#################################### End Draw Hangman ############################################## 

 #j loop
 	
#display some sort of text and end screen like "Game Over!"	
game_over:
	nop
	li $v0, 55		# print game over prompt with pop window
	la $a0, over_msg
	li $a1, 1
	syscall
	j Exit

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
