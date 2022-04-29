.data 
frameBuffer: .space 0x80000			# 512 width x 256 height
m: .word 80
n: .word 40

.text
main:
   ## whait background
   la   $t0, frameBuffer				# load frameBuffer addr
   li   $t1, 0x20000				    # save 512x256 pixels
   li   $t2, 0x00FFFFFF				  # load color white
   
label1:
   sw   $t2, 0($t0)
   addi $t0, $t0, 4				    # advance to next pixel position
   sub  $t1, $t1, 1				    # decrement number of pixel
   bnez $t1, label1
   
   li $v0, 10
   syscall
