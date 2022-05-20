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
 prompt: .asciiz 		"\nEnter 1 letter each time: "
 strArray: .asciiz 		"iceberg", "hangman", "ironman", "earplug", "cabbage", "adopter", "biznaga", "hackman", "mercury", "purpose"
 welcome_msg: .asciiz 		"*** Welcome to the Hangman Game ***"
 over_msg: .asciiz 		"*** Game Over!! ***"
 over_msg2: .asciiz 		"*** Game Won!! ***"
 hint:.asciiz 			"Hint: it is 7-letter long.\n"
word_now: .asciiz 		"\nYour word is:\n"
 space: .asciiz 		" "
 hiddenStr: .space 7 
 charArray: .byte 		'_','_', '_', '_', '_', '_', '_'
 dash: .byte 			'_','_', '_', '_', '_', '_', '_'
 
 # test only, delete in final
 s1: .asciiz 			"The word generated is: (display to test, not in final program): "
 s2: .asciiz 			"\ntest if we can access char in str: (display to test, not in final program): "
 
.text 
main: 
li $v0, 55  			# print welcome prompt with pop window
la $a0, welcome_msg
li $a1, 1
syscall

j Bitmap			# draw bitmap setup
endBM:

jal ranGen			# call ranGen, string return in $v0
move $t4, $v0			# the string now in $t4

la $a0, s1
jal print
move $a0, $t4
jal print			# print for test only


li $v0, 55  			# print welcome prompt with pop window
la $a0, hint
li $a1, 1
syscall
 
la $s4, hiddenStr
move $s4, $t4			# $s4 = $t4; hiddenStr = generated str


li $s3, 0			# incorrect guess iterator
li $s7, 0			# loop iterator
li $s5, 0

loop:
beq $s3, 6, game_over		# 6 incorrect guess, end game
beq $s7, 20, game_over


la $a0, word_now
jal print

li $t6, 0			# charArray iterator
charPrintLoop:
beq $t5, 7, winCondition
beq $t6, 7, endCharPrintLoop
lb $a0, charArray($t6)
li $v0, 11
syscall
la $a0, space
jal print
lb $a0, charArray($t6)
lb $a1, dash($t6)
bne $a0, $a1, equals

midCharPrint:
add $t6, $t6, 1
j charPrintLoop

equals:
add $t5, $t5, 1
j midCharPrint

endCharPrintLoop:

la $a0, prompt
li $v0, 4
syscall
li $v0, 12
syscall
move $t8, $v0			# store user char input in $t8 

li $s5, 1			# boolean if match (true:0 false:1) defual false
li $t5, 0
j callMatch

indexOut:
add $s7, $s7, 1
addi $t7, $t7, -7
addi $s4, $s4, -7

beq $s5, 1, oneMoreWrongGuess
afterOneMoreWrongGuess:
beq $s3, 1, drawHead
beq $s3, 2, drawBody
beq $s3, 3, drawArm1
beq $s3, 4, drawArm2
beq $s3, 5, drawLeg1
beq $s3, 6, drawLeg2
endDraw:

j loop

callMatch:
la $t7, 0

checkMatch:
beq $t7, 7, indexOut		# index out of boundry, exit
lb $s0, 0($s4)
beq $t8, $s0, match
# if not match, increment t7, check next

afterMatch:
add $t7, $t7, 1
add $s4, $s4, 1
j checkMatch

match:
li $s5, 0			# ifMatch = true
sb $t8, charArray($t7) 		# charArray[i] = $t8

j afterMatch


##************ random string generator **************************************#
ranGen:
# get the time
li	$v0, 30			# get time in milliseconds - 64-bits
syscall

move	$s4, $a0		# save the lower 32-bits of time

# seed the random generator
li	$a0, 1			# random generator id
move 	$a1, $s4		# seed from time
li	$v0, 40			# seed random number generator syscall
syscall

li	$a0, 1			# random generator id
li	$a1, 10			# upper bound of the range
li	$v0, 42			# random int range
syscall

# $a0 now holds the random number
move $t4, $a0			# save the generated index into $t4

sll $t4, $t4, 3         	# $t4 = $t7 * 8
la $v0, strArray		# initial addr of array -> $s4
add $v0, $v0, $t4		# locate element in array[index]

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
print_char:
	li $v0, 11
	syscall
	jr $ra
oneMoreWrongGuess:
	add $s3, $s3, 1
	j afterOneMoreWrongGuess
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

j endBM
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
	j endDraw			#j back where it left off
   
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
	j endDraw			#j back where it left off
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
   	j endDraw			#j back where it left off
   	
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
   	j endDraw			#j back where it left off
   	
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
   	j endDraw			#j back where it left off
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
   	j game_over			#j back where it left off
   	
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

winCondition:
 	nop
 	li $v0, 55		# print game over prompt with pop window
 	la $a0, over_msg2
 	li $a1, 1
 	syscall
 	j Exit
Exit:
	li $v0, 10 		# terminate the program gracefully
	syscall
