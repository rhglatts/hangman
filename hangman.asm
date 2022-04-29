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
.text

main:

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
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
