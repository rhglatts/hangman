# CS2640 Final Project - Hangman Game
# Team Member:
# Huijun Hu
# Yvonne Li
# Isaiah Hessler
# Rebecca Glatts

# Bitmap Display Configuration:
# - Unit width in pixels: 4					     
# - Unit height in pixels: 4
# - Display width in pixels: 512
# - Display height in pixels: 256
# - Base Address for Display: 0x10010000

.data
	frameBuffer:	.space	0x80000
	prompt: .asciiz "\nEnter a letter: "
	array: .space 40
	word: .asciiz "H", "A", "N", "G", "M", "A", "N"
	
.text
	
main:	
	
	li $t4, 4
	loop:
	beq $t3, 10, game_over 	#when the amount of guesses reaches 10, it's gameover
	
    	#display message
    	li      $v0, 4
    	la      $a0, prompt
    	syscall

    	#read in the string 
   	move    $a0, $s2           
    	li      $a1, 20
    	li      $v0, 8
    	syscall
    	
    	#store the word in an array
    	sw      $a0,a rray($t5)
    	addi	$t4, $t4, 1  #iteration
    	addi    $t5, $t5,4           
    	addi    $s2, $s2,20   #amount of space needed for string

    	j loop
	
	
	######################### Initial Bitmap ###########################################
	# fill background color
	la 	$t0, frameBuffer		# load frameBuffer addr
   	li 	$t1, 0x2000			# save 512x256 pixels
   	li 	$t2, 0x004A613D			# load color 
   bg:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, bg

	# draw gallow
	la 	$t0, frameBuffer
	addi	$t0, $t0, 5492			# locate left top coner of gallow
	li	$t1, 20				# gallow horizontal wood width
	li	$t2, 0x00AC672E			# load gallow color
	
   gallow_top:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_top
   
	la 	$t0, frameBuffer
	addi	$t0, $t0, 6004			# locate 1 pixel down left top coner of gallow
	li	$t1, 5 				# string  length
   gallow_string:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 512			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_string
	
	la 	$t0, frameBuffer
	addi	$t0, $t0, 6080			# locate 1 pixel down right top coner of gallow
	li	$t1, 40 			# stand wood length
   gallow_stand:
   	sw 	$t2, 0($t0)
   	addi   	$t0, $t0, 512			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_stand

	sub 	$t0, $t0, 100			# locate start point of gallow base
	li	$t1, 30 			# base  length
   gallow_base:
   	sw 	$t2, 0($t0)
   	sw 	$t2, 512($t0)
   	sw 	$t2, 512($t0)
   	addi   	$t0, $t0, 4			# advance to next pixel position
   	sub 	$t1, $t1, 1			# decrement number of pixel
   	bnez 	$t1, gallow_base
################################ End Initial Bitmap #######################################

#display some sort of text and end screen like "Game Over!"	
game_over:


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
