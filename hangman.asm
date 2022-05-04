# CS2640 Final Project - Hangman Game
# Team Member:
# Huijun Hu
# Yvonne Li
# Isaiah Hessler
# Rebecca Glatts

# Bitmap Display Configuration:
# - Unit width in pixels: 4					     
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10010000

.data
	frameBuffer:	.space	0x80000
	prompt: .asciiz "\nEnter a letter: "
	array: .space 500
	word: .asciiz "H", "A", "N", "G", "M", "A", "N"
	welcome_msg: .asciiz "*** Welcome to the Hangman Game ***"
	
.text
	
main:	
	li $v0, 55		# print welcome prompt with pop window
	la $a0, welcome_msg
	li $a1, 1
	syscall
	
	li $t4, 4
	loop:
	beq $t3, 10, game_over 	#when the amount of guesses reaches 10, it's gameover
	
    	#display message
    	li $v0, 4
    	la $a0, prompt
    	syscall

    	#read in the string 
    	li $v0, 12
    	la $a0, array
    	li $a1, 20
    	move $t0, $a0
    	syscall # <----- error happens right here
    	
    	#store the word in an array
    	sb      $a0, array($t5)
    	addi	$t3, $t3, 1  #iteration
    	addi    $t5, $t5,4           
    	addi    $s2, $s2,20   #amount of space needed for string

    	j loop
	
	
	######################### Initial Bitmap ###########################################
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
   	
################################ End Initial Bitmap #######################################


#display some sort of text and end screen like "Game Over!"	
game_over:


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
