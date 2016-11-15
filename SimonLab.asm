# Author   : Christian Dunn
# Date     : October 10th, 2016
# Purpose  : To create a simple bitmap display for a game to act as Simon
#			Part 1 -> Create simple text based version
#			Part 2 -> Implement bitmap display
#			Part 3 -> Update graphics to higher resolution and add timeout on input
# Compiler : MARS 4.4


# ************** BITMAP OPTIONS **************
# Unit width in pixels     : 1
# Unit height in pixels    : 1
# Display width in pixels  : 256
# Display height in pixels : 256
# Base address             : heap
# ********************************************

.data 
msg_endl      : .asciiz "\n"
msg_stars     : .asciiz "\n****************************************************"
msg_line      : .asciiz "\n______________________________________________________"
msg_welcome   : .asciiz "\nWelcome to Simon! A game to truly test your memory!"
msg_rules     : .asciiz "\nRules:\n1. Possible entries 1-4\n2. Enter as many as you remember"
msg_numOutput : .asciiz "\nOutput : "
msg_numInput  : .asciiz "\nInput  : "
msg_winner    : .asciiz "\nCongratulations! You win!"
msg_loser     : .asciiz "\nInvalid Input! You Lose!"
msg_error     : .asciiz "\nArgument data error!"
msg_continue  : .asciiz "\nContinue (y/n)? "
endl          : .asciiz "\n"
space         : .asciiz " "
num1          : .asciiz "1"
num2          : .asciiz "2"
num3          : .asciiz "3"
num4          : .asciiz "4"
lost_disp     : .asciiz "U 5UK K1D U 5UK K1D U 5UK"
welcome_bit   : .asciiz "WELCOME! TO 5IMON"
begin_bit     : .asciiz "PRE55 [1] TO 5TART"
begin_bit2    : .asciiz "PRE55 [2] TO END"
begin_bit3    : .asciiz "PRE55 [3] TO JAM OUT"

StackBeg   : .word 0:40
StackEnd   : 
RandsBeg   : .word 0:20
Rands      :
seed       : .word 0
hex        : .word 0x10040000
ColorTable :
	.word 0x000000
	.word 0x0000ff
	.word 0x00ff00
	.word 0xff0000
	.word 0x00ffff
	.word 0xff00ff
	.word 0xffff00
	.word 0xffffff
Colors: 
	.word   0x000000        
        .word   0xffffff 
DigitTable:
	.byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f
        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60
        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00
        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   '!', 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x00,0x00,0x18,0x18
        .byte   '[', 0xf0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xf0
        .byte   ']', 0x0f,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x0f
        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00
        .byte   '/', 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3
        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e
        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'G', 0xff,0xc3,0xc3,0xc0,0xc0,0xc0,0xc0,0xcf,0xc3,0xc3,0xc3,0xff
        .byte   'H', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'I', 0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0xff
        .byte   'J', 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0xe3,0xc3,0xc3,0xff
        .byte   'K', 0xc0,0xc3,0xc3,0xc6,0xcc,0xd8,0xf0,0xd8,0xcc,0xc6,0xc3,0xc3
        .byte   'L', 0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xff
        .byte   'M', 0xc3,0xc3,0xc3,0xe7,0xdb,0xdb,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'N', 0x00,0x00,0xc3,0xe3,0xe3,0xd3,0xd3,0xcb,0xcb,0xc7,0xc7,0xc3
        .byte   'O', 0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff
        .byte   'P', 0xff,0xc3,0xc3,0xc3,0xc3,0xff,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'R', 0xff,0xc3,0xc3,0xc3,0xc3,0xff,0xf0,0xd8,0xcc,0xc6,0xc3,0xc3
        .byte   'T', 0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'U', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff
        .byte   'W', 0x00,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xdb,0xdb,0xe7,0x66
        .byte   'X', 0x18,0x24,0x42,0x42,0x24,0x24,0x24,0x24,0x24,0xe7,0xbd,0xe7
DegreeTable:
	.word  25, 25, 25, 25, 24, 24, 24, 23, 23, 22, 22, 21, 21, 20, 19, 18, 17, 16, 15, 13, 12, 10, 7, 3, 0
	
.text
pre_main:
	b    MenuPage
	postmenu:
	la   $a0, msg_numInput
	jal  DisplayStr
	jal  GetChar
	beq  $v0, '1', main_re
	beq  $v0, '2', exit
	beq  $v0, '3', Mario
main:
	jal  Title
	li   $a0, 0
	li   $a1, 0
	li   $a2, 7
	li   $a3, 255
	jal  LtoRLine
	li   $a0, 255
	li   $a1, 0
	li   $a2, 7
	li   $a3, 255
	jal  RtoLLine
	b    main_op

main_re:
	la  $a0, msg_line
	jal DisplayStr
	li  $s7, 1
	loop_re:
		li   $a0, 1
		move $a1, $s7
		li   $a2, 0
		li   $a3, 255
		jal  HorzLine
		addi $s7, $s7, 1
		bne  $s7, 256, loop_re
	li   $a0, 0
	li   $a1, 0
	li   $a2, 7
	li   $a3, 255
	jal  LtoRLine
	li   $a0, 255
	li   $a1, 0
	li   $a2, 7
	li   $a3, 255
	jal  RtoLLine
	
main_op:
	jal  Seed
	li   $s0, 0
	la   $s6, Rands
	la   $sp, StackEnd
	
	Rand5:
		
		lw   $a1, seed
		jal  RandNum
		jal  Push
		addi $s0, $s0, 1
		bne  $s0,   5, Rand5 
		
	Output:
		li   $s0, 0
		
		out_loop:
			li   $s1, 0
			la   $s6, Rands
			addi $s6, $s6, -20
			la   $a0, msg_numOutput
			jal  DisplayStr
			
			pop_loop:
				jal  Pop
				jal  DisplayInt
				move $s2, $a0
				beq  $a0, 1, LT_box
				beq  $a0, 2, RT_box
				beq  $a0, 3, LB_box
				beq  $a0, 4, RB_box
				back:
				la   $a0, space
				jal  DisplayStr
				addi $s1, $s1, 1
				ble  $s1, $s0, pop_loop
				
				la   $s6, Rands
				addi $s6, $s6, -20
				li   $s1, 0
				la   $a0, msg_numInput
				jal  DisplayStr
				get_loop:
					jal  Pop
					move $s2, $a0
					jal  GetInput
					bne  $s2, $a1, error_main
					addi $sp, $sp, 4
					addi $s1, $s1, 1
					la   $a0, space
					jal  DisplayStr
					ble  $s1, $s0, get_loop
				
				jal  Endls	
				addi $s0, $s0, 1
				blt  $s0,   5, out_loop
				
	la  $a0, msg_winner
	jal DisplayStr
	b   WinnerGraphics
	AS_back:
		b   continue
	
	error_main:
		jal Endls
		la  $a0, msg_loser
		jal DisplayStr
		b   LoserGraphics
		DM_back:
			b   continue
		
	continue:
		la  $a0, msg_continue
		jal DisplayStr
		jal GetChar
		beq $v0, 'n', exit
		beq $v0, 'y', main_re

	exit:
		li $v0, 10
		syscall

# Procedure : Title
# Purpose   : To display a title screen that can easily be cleared and displayed
# Inputs    : $a0 -> Memory location of prompts to be displayed
Title:
	la  $a0, msg_stars
	li  $v0, 4
	syscall
	la  $a0, msg_welcome
	li  $v0, 4
	syscall
	la  $a0, msg_stars
	li  $v0, 4
	syscall
	la  $a0, msg_rules
	li  $v0, 4
	syscall
	la  $a0, msg_endl
	li  $v0, 4
	syscall
	jr  $ra
	
# Procedure : Push
# Purpose   : To push specified element onto the stack
# Inputs    : $a0 -> Value to save to stack
Push:
	addi $s6, $s6, -4
	sw   $a0, 0($s6)
	jr   $ra
	
# Procedure : Pop
# Purpose   : To pop last element in stack out
# Outputs   : $a0 -> Value you popped out from stack
Pop:
	lw   $a0, 0($s6)
	addi $s6, $s6, 4
	jr   $ra  
	
# Procedure : GetInput
# Purpose   : To get input from user for number guess
# Inputs    : $a0 -> Input prompt
# Outputs   : $a1 -> Holds user input
GetInput:
	subi $sp, $sp, 4
	sw   $ra, 0($sp) 
	jal  GetChar
	subi $v0, $v0, 48
	move $a1, $v0
	move $t0, $a1
	beq  $a1, 1, one
	beq  $a1, 2, two
	beq  $a1, 3, three
	beq  $a1, 4, four
		one: 
			li   $a0, 70
			li   $a1, 250
			li   $a2, 82
			li   $a3, 100
			li   $v0, 31
			syscall
			b   endInput
		two:
			li  $a0, 70
			li  $a1, 250
			li  $a2, 63
			li  $a3, 100
			li  $v0, 31
			syscall
			b   endInput
		three:
			li  $a0, 70
			li  $a1, 250
			li  $a2, 45
			li  $a3, 100
			li  $v0, 31
			syscall
			b   endInput
		four:
			li  $a0, 70
			li  $a1, 250
			li  $a2, 75
			li  $a3, 100
			li  $v0, 31
			syscall
			b   endInput
	endInput:
		move $a1, $t0
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr   $ra

# Procedure : GetChar
# Purpose   : Get character value from keyboard simulator and store in register
# Outputs   : $v0 -> Returns character value in $v0 if entered 
GetChar:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $t2, 0
	j check
	cloop:
		addi $t2, $t2, 1
		beq  $t2, 500000, endProgram
	check:
		jal  IsCharThere
		beq  $v0, $0, cloop
		lui  $t0, 0xffff
		lw   $v0, 4($t0)
		move $k0, $v0
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr   $ra
	endProgram:
		li   $v0, 10
		syscall

# Procedure : IsCharThere
# Purpose   : To check and see if character has been entered within keyboard simulator
# Outputs   : $v0 -> returns either 1 or 0 depending on if value has been entered 
IsCharThere:
	lui $t0, 0xffff
	lw  $t1, 0($t0)
	and $v0, $t1, 1
	jr  $ra
	
# Procedure : DisplayStr
# Purpose   : Display string input pre-defined in data alignment
# Inputs    : $a0 -> memory location of desired string
DisplayStr:
	li $v0, 4
	syscall
	jr $ra
	
# Procedure : DisplayInt
# Purpose   : To display random integer to user for part 1 of Simon lab
# Inputs    : $a0 -> memory location of integer value
DisplayInt:
	li $v0, 1
	syscall
	jr $ra
	
# Procedure : Endls
# Purpose   : To endl line multiple times to space out data
Endls:
	la  $a0, endl
	li  $v0, 4
	syscall
	la  $a0, endl
	li  $v0, 4
	syscall
	
# Procedure : Seed
# Purpose   : To generate seed used in random number generator
# Inputs    : seed -> memory location to store high order of system time
# Outputs   : 
Seed:
	li   $v0, 30
	syscall
	sw   $a0, seed
	jr   $ra
	
# Procedure : RandNum
# Purpose   : To generate random number to determine from which color to choose
# Inputs    : $a0 -> id of generator
#	      $a1 -> seed for that generator
# Outputs   : $a0 -> id of generator
#	      $a1 -> upper bound
RandNum:
	lw   $a1, seed
	li   $v0, 40
	syscall
	li   $t0, 4
	abs  $a0, $a0
	div  $a0, $t0
	mfhi $a0
	addi $a0, $a0, 1
	jr   $ra
	
# Procedure : Pause
# Purpose   : To pause system operations using syscall timing methods
# Inputs    : $a0 -> number of milliseconds to wait
Pause:
	move $t0, $a0
	li   $v0, 30
	syscall
	move $t1, $a0
	pause_Loop:
		syscall
		subu $t2, $a0, $t1
		bltu $t2, $t0, pause_Loop
		jr   $ra

# Procedure : CalcAddr
# Purpose   : To calculate address based upon given x and y coordinates
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
# Outputs   : $v0 -> memory address
CalcAddress:
	lw      $t0, hex
	sll     $t1, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t0, $t0, $t1   # and 1 pixel width, 1 pixel height
        sll     $t1, $a1, 10    # (a0 * 4) + (a1 * 4 * 256)
        addu    $v0, $t0, $t1   # t9 = memory address for this pixel
	jr  $ra

# Procedure : GetColor
# Purpose   : Returns color used to write to display
# Inputs    : $a2 -> color number (0-7)
# Outputs   : $v1 -> actual number to write to the display
GetColor:
	la   $t0, ColorTable
	sll  $a2, $a2, 2
	add  $a2, $a2, $t0
	lw   $v1, 0($a2)
	jr   $ra
	
# Procedure : DrawDot
# Purpose   : To draw dot on bitmap display given x and y coordinates
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
DrawDot:
	addiu $sp, $sp, -12
	sw    $ra, 4($sp)
	sw    $a2, 0($sp)
	jal   CalcAddress
	lw    $a2, 0($sp)
	sw    $v0, 0($sp)
	jal   GetColor
	lw    $v0, 0($sp)
	sw    $v1, 0($v0)
	lw    $ra, 4($sp)
	addiu $sp, $sp, 12
	jr    $ra
	
# Procedure : HorzLine
# Purpose   : To draw horizontal line on bitmap display
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
HorzLine:
	sub $sp, $sp, 24
	sw  $a1, 4($sp)
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	HorzLoop:
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, 1
		subi $a3, $a3, 1
		bnez $a3, HorzLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : RtoLHorzLine
# Purpose   : To draw horizontal line in reverse order as originally intended
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
RtoLHorzLine:
	sub $sp, $sp, 24
	sw  $a1, 4($sp)
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	RtoLHorzLoop:
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, -1
		subi $a3, $a3, 1
		bnez $a3, RtoLHorzLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
	
# Procedure : VertLine
# Purpose   : To draw vertical line on bitmap display
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
VertLine:
	sub $sp, $sp, 24
	sw  $a0, 4($sp)
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	VertLoop:
		sw   $a1, 0($sp)
		jal  DrawDot
		lw   $a1, 0($sp)
		lw   $a0, 4($sp)
		lw   $a2, 8($sp)
		addi $a1, $a1, 1
		subi $a3, $a3, 1
		bnez $a3, VertLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : LtoRLine
# Purpose   : To draw digonal line going from left corner to right corner
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
LtoRLine:
	sub $sp, $sp, 24
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	LtoRLoop:
		sw   $a1, 4($sp)
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		subi $a3, $a3, 1
		bnez $a3, LtoRLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : RtoLLine
# Purpose   : To draw a diagonal line that starts from right and moves to left x coordinate
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
RtoLLine:
	sub $sp, $sp, 24
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	RtoLLoop:
		sw   $a1, 4($sp)
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, -1
		addi $a1, $a1, 1
		subi $a3, $a3, 1
		bnez $a3, RtoLLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : DrawCircle
# Purpose   : Using methods defined to draw dots, create a circle within the BitMap display
# Inputs    : $a0 -> x coordinate (0-255)
# 	      $a1 -> y coordinate (0-255)
#             $a2 -> color (0-7)
DrawCircle:
	sub $sp, $sp, 24
	sw  $ra, 16($sp)
	la  $s4, DegreeTable
	lw  $a3, 0($s4)
	li  $s5, 0
	
	CircleLoop1:
		sw  $a0, 0($sp)
		sw  $a1, 4($sp)
		sw  $a2, 8($sp)
		sw  $a3, 12($sp)
		jal HorzLine
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $s4, $s4, 4
		lw   $a3, 0($s4)
		subi $a1, $a1, 1
		addi $s5, $s5, 1
		bne  $s5, 24, CircleLoop1
		la   $s4, DegreeTable
		lw   $a3, 0($s4)
		li   $s5, 0
		addi $a1, $a1, 24
	CircleLoop2:
		sw   $a0, 0($sp)
		sw   $a1, 4($sp)
		sw   $a2, 8($sp)
		sw   $a3, 12($sp)
		jal  RtoLHorzLine
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $s4, $s4, 4
		lw   $a3, 0($s4)
		subi $a1, $a1, 1
		addi $s5, $s5, 1
		bne  $s5, 24, CircleLoop2
		la   $s4, DegreeTable
		lw   $a3, 0($s4)
		li   $s5, 0
		addi $a1, $a1, 24
	CircleLoop3:
		sw  $a0, 0($sp)
		sw  $a1, 4($sp)
		sw  $a2, 8($sp)
		sw  $a3, 12($sp)
		jal HorzLine
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $s4, $s4, 4
		lw   $a3, 0($s4)
		addi $a1, $a1, 1
		addi $s5, $s5, 1
		bne  $s5, 24, CircleLoop3
		la   $s4, DegreeTable
		lw   $a3, 0($s4)
		li   $s5, 0
		addi $a1, $a1, -24
	CircleLoop4:
		sw   $a0, 0($sp)
		sw   $a1, 4($sp)
		sw   $a2, 8($sp)
		sw   $a3, 12($sp)
		jal  RtoLHorzLine
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $s4, $s4, 4
		lw   $a3, 0($s4)
		addi $a1, $a1, 1
		addi $s5, $s5, 1
		bne  $s5, 24, CircleLoop4
		lw   $ra, 16($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-255)
# $a1 = vertical pixel co-ordinate (0-255)
# $a2 = pointer to asciiz text (to be displayed)
OutText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 10    # (a0 * 4) + (a1 * 4 * 256)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        la      $t7, Colors
        lw      $t7, 0($t7)     # assume black
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        la      $t7, Colors     # else it is white
        lw      $t7, 4($t7)
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra
		
#################################################################################

LT_box:
	jal TopCircle
	j   back

RT_box:
	jal RightCircle
	j   back
	
LB_box:
	jal BottomCircle
	j   back
	
RB_box:
	jal LeftCircle
	j   back
	
#################################################################################

TopCircle:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $a0, 128
	li   $a1, 45
	li   $a2, 2
	jal  DrawCircle
	li   $a0, 124
	li   $a1, 39
	la   $a2, num1
	jal  OutText
	li   $a0, 70
	li   $a1, 250
	li   $a2, 82
	li   $a3, 100
	li   $v0, 31
	syscall
	li   $a0, 250
	jal  Pause
	li   $a0, 128
	li   $a1, 45
	li   $a2, 0
	jal  DrawCircle
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
RightCircle:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li  $a0, 201
	li  $a1, 128
	li  $a2, 3
	jal DrawCircle
	li  $a0, 197
	li  $a1, 122
	la  $a2, num2
	jal OutText
	li  $a0, 70
	li  $a1, 250
	li  $a2, 63
	li  $a3, 100
	li  $v0, 31
	syscall
	li  $a0, 250
	jal Pause
	li  $a0, 201
	li  $a1, 128
	li  $a2, 0
	jal DrawCircle
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
BottomCircle:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li  $a0, 128
	li  $a1, 211
	li  $a2, 4
	jal DrawCircle
	li  $a0, 124
	li  $a1, 205
	la  $a2, num3
	jal OutText
	li  $a0, 70
	li  $a1, 250
	li  $a2, 45
	li  $a3, 100
	li  $v0, 31
	syscall
	li  $a0, 250
	jal Pause
	li  $a0, 128
	li  $a1, 211
	li  $a2, 0
	jal DrawCircle
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
LeftCircle:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li  $a0, 45
	li  $a1, 128
	li  $a2, 5
	jal DrawCircle
	li  $a0, 39
	li  $a1, 122
	la  $a2, num4
	jal OutText
	li  $a0, 70
	li  $a1, 250
	li  $a2, 75
	li  $a3, 100
	li  $v0, 31
	syscall
	li  $a0, 250
	jal Pause
	li  $a0, 45
	li  $a1, 128
	li  $a2, 0
	jal DrawCircle
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
#################################################################################
MenuPage:
	li      $a0, 1         
        li      $a1, 2
        la      $a2, welcome_bit
        jal     OutText
        li      $a0, 1         
        li      $a1, 18
        la      $a2, begin_bit
        jal     OutText
        li      $a0, 1         
        li      $a1, 34
        la      $a2, begin_bit2
        jal     OutText
        li      $a0, 1         
        li      $a1, 50
        la      $a2, begin_bit3
        jal     OutText	
        b       postmenu
	
#################################################################################

LoserGraphics:
	li      $a0, 1         
        li      $a1, 2
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 18
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 34
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 50
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 66
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 82
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 98
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 114
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 130
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 146
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 162
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 178
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 194
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 210
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 226
        la      $a2, lost_disp
        jal     OutText
        li      $a0, 1         
        li      $a1, 242
        la      $a2, lost_disp
        jal     OutText
        b       DeathMarch
	
#################################################################################
	
WinnerGraphics:
		li   $a0, 0
		li   $a1, 0
		li   $a2, 7
		li   $a3, 255
		jal  LtoRLine
		li   $a0, 255
		li   $a1, 0
		li   $a2, 7
		li   $a3, 255
		jal  RtoLLine
		li   $a0, 128
		li   $a1, 45
		li   $a2, 2
		jal  DrawCircle
		li   $a0, 124
		li   $a1, 39
		la   $a2, num1
		jal  OutText
		li   $a0, 250
		jal  Pause
		li   $a0, 128
		li   $a1, 45
		li   $a2, 0
		jal  DrawCircle
		li   $a0, 100
		jal  Pause
		li   $a0, 0
		li   $a1, 0
		li   $a2, 6
		li   $a3, 255
		jal  LtoRLine
		li   $a0, 255
		li   $a1, 0
		li   $a2, 6
		li   $a3, 255
		jal  RtoLLine
		li  $a0, 201
		li  $a1, 128
		li  $a2, 3
		jal DrawCircle
		li  $a0, 197
		li  $a1, 122
		la  $a2, num2
		jal OutText
		li  $a0, 250
		jal Pause
		li  $a0, 201
		li  $a1, 128
		li  $a2, 0
		jal DrawCircle
		li   $a0, 100
		jal  Pause
		li   $a0, 0
		li   $a1, 0
		li   $a2, 2
		li   $a3, 255
		jal  LtoRLine
		li   $a0, 255
		li   $a1, 0
		li   $a2, 2
		li   $a3, 255
		jal  RtoLLine
		li  $a0, 128
		li  $a1, 211
		li  $a2, 4
		jal DrawCircle
		li  $a0, 124
		li  $a1, 205
		la  $a2, num3
		jal OutText
		li  $a0, 250
		jal Pause
		li  $a0, 128
		li  $a1, 211
		li  $a2, 0
		jal DrawCircle
		li   $a0, 100
		jal  Pause
		li   $a0, 0
		li   $a1, 0
		li   $a2, 4
		li   $a3, 255
		jal  LtoRLine
		li   $a0, 255
		li   $a1, 0
		li   $a2, 4
		li   $a3, 255
		jal  RtoLLine
		li  $a0, 45
		li  $a1, 128
		li  $a2, 5
		jal DrawCircle
		li  $a0, 39
		li  $a1, 122
		la  $a2, num4
		jal OutText
		li  $a0, 250
		jal Pause
		li  $a0, 45
		li  $a1, 128
		li  $a2, 0
		jal DrawCircle
		li   $a0, 100
		jal  Pause
		li   $a0, 0
		li   $a1, 0
		li   $a2, 7
		li   $a3, 255
		jal  LtoRLine
		li   $a0, 255
		li   $a1, 0
		li   $a2, 7
		li   $a3, 255
		jal  RtoLLine
		li   $a0, 100
		jal  Pause
		b    AllStar
	
#################################################################################
	
Mario:
	jal m_Bbhalf
	li  $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Dhalf
	li $a0, 250
	jal Pause
	jal m_Ehalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 500
	jal Pause
	
	jal m_Ehalf
	li $a0, 250
	jal Pause
	jal m_Dhalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Chalf
	li $a0, 250
	jal Pause
	jal m_Bbhalf
	li $a0, 250
	jal Pause
	jal m_Ahalf
	li $a0, 500
	jal Pause
	
	jal m_Dhalf
	li $a0, 250
	jal Pause
	jal m_Bbhalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Dhalf
	li $a0, 250
	jal Pause
	jal m_Ehalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 500
	jal Pause
	
	jal m_Ehalf
	li $a0, 250
	jal Pause
	jal m_Dhalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	jal m_Chalf
	li $a0, 250
	jal Pause
	jal m_Bbhalf
	li $a0, 250
	jal Pause
	jal m_Ahalf
	li $a0, 250
	jal Pause
	jal m_Ghalf
	li $a0, 250
	jal Pause
	b   pre_main

m_D2:
	li $a0, 62
	li $a1, 2000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra

m_D1:
	li $a0, 62
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Dhalf:
	li $a0, 62
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Fhalf:
	li $a0, 65
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Ehalf:
	li $a0, 64
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_E2:
	li $a0, 64
	li $a1, 1000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Ahalf:
	li $a0, 69
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_A1:
	li $a0, 69
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Chalf:
	li $a0, 72
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_C1:
	li $a0, 72
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Chalflow:
	li $a0, 61
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Ghalf:
	li $a0, 67
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_G1:
	li $a0, 67
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Bbhalf:
	li $a0, 70
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
m_Bb1:
	li $a0, 70
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
#################################################################################

AllStar:
	jal G1
	li $a0, 500
	jal Pause
	
	jal Chalf
	li $a0, 250
	jal Pause
	jal Bbhalf
	li $a0, 250
	jal Pause
	jal Bb1
	li $a0, 500
	jal Pause
	
	jal Ahalf
	li $a0, 250
	jal Pause
	jal Ghalf
	li $a0, 250
	jal Pause
	jal Ghalf
	li $a0, 250
	jal Pause
	jal C1
	li $a0, 500
	jal Pause
	jal Bbhalf
	li $a0, 250
	jal Pause
	jal Bbhalf
	li $a0, 250
	jal Pause
	jal Ahalf
	li $a0, 250
	jal Pause
	jal Ahalf
	li $a0, 250
	jal Pause
	jal Ghalf
	li $a0, 500
	jal Pause
	
	jal Ghalf
	li $a0, 250
	jal Pause
	
	jal Chalf
	li $a0, 250
	jal Pause
	jal Bbhalf
	li $a0, 250
	jal Pause
	jal Bbhalf
	li $a0, 250
	jal Pause
	jal Ahalf
	li $a0, 250
	jal Pause
	jal Ahalf
	li $a0, 250
	jal Pause
	jal Ghalf
	li $a0, 250
	jal Pause
	jal Ghalf
	li $a0, 250
	jal Pause
	jal Ehalf
	li $a0, 250
	jal Pause
	jal E2
	li $a0, 1000
	jal Pause
	b   AS_back
	
D2:
	li $a0, 62
	li $a1, 2000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra

D1:
	li $a0, 62
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Dhalf:
	li $a0, 62
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Fhalf:
	li $a0, 65
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Ehalf:
	li $a0, 64
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
E2:
	li $a0, 64
	li $a1, 1000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Ahalf:
	li $a0, 69
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
A1:
	li $a0, 69
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Chalf:
	li $a0, 72
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
C1:
	li $a0, 72
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Ghalf:
	li $a0, 67
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
G1:
	li $a0, 67
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Bbhalf:
	li $a0, 70
	li $a1, 250
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
Bb1:
	li $a0, 70
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
#################################################################################
	
DeathMarch:
	jal DM_D1
	li  $a0, 1000
	jal Pause
	
	jal DM_Dhalf
	li  $a0, 500
	jal Pause
	jal DM_Dhalf
	li  $a0, 500
	jal Pause
	
	jal DM_D1
	li  $a0, 1000
	jal Pause
	
	jal DM_Fhalf
	li $a0, 500
	jal Pause
	jal DM_Ehalf
	li $a0, 500
	jal Pause
	jal DM_Ehalf
	li $a0, 500
	jal Pause
	jal DM_Dhalf
	li  $a0, 500
	jal Pause
	jal DM_Dhalf
	li  $a0, 500
	jal Pause
	jal DM_Dhalf
	li  $a0, 500
	jal Pause
	
	jal DM_D2
	li $a0, 2000
	jal Pause
	b   DM_back

DM_D2:
	li $a0, 62
	li $a1, 2000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra

DM_D1:
	li $a0, 62
	li $a1, 1000
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
DM_Dhalf:
	li $a0, 62
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
DM_Fhalf:
	li $a0, 65
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra
	
DM_Ehalf:
	li $a0, 64
	li $a1, 500
	li $a2, 58
	li $a3, 75
	li $v0, 31
	syscall
	jr $ra

#################################################################################	

	########################################################################
	#   Description:
	#       Example SPIM exception handler
	#       Derived from the default exception handler in the SPIM S20
	#       distribution.
	#
	#   History:
	#       Dec 2009    J Bacon
	
	########################################################################
	# Exception handling code.  This must go first!
	
			.kdata
	__start_msg_:   .asciiz "  Exception "
	__end_msg_:     .asciiz " occurred and ignored\n"
	
	# Messages for each of the 5-bit exception codes
	__exc0_msg:     .asciiz "  [Interrupt] "
	__exc1_msg:     .asciiz "  [TLB]"
	__exc2_msg:     .asciiz "  [TLB]"
	__exc3_msg:     .asciiz "  [TLB]"
	__exc4_msg:     .asciiz "  [Address error in inst/data fetch] "
	__exc5_msg:     .asciiz "  [Address error in store] "
	__exc6_msg:     .asciiz "  [Bad instruction address] "
	__exc7_msg:     .asciiz "  [Bad data address] "
	__exc8_msg:     .asciiz "  [Error in syscall] "
	__exc9_msg:     .asciiz "  [Breakpoint] "
	__exc10_msg:    .asciiz "  [Reserved instruction] "
	__exc11_msg:    .asciiz ""
	__exc12_msg:    .asciiz "  [Arithmetic overflow] "
	__exc13_msg:    .asciiz "  [Trap] "
	__exc14_msg:    .asciiz ""
	__exc15_msg:    .asciiz "  [Floating point] "
	__exc16_msg:    .asciiz ""
	__exc17_msg:    .asciiz ""
	__exc18_msg:    .asciiz "  [Coproc 2]"
	__exc19_msg:    .asciiz ""
	__exc20_msg:    .asciiz ""
	__exc21_msg:    .asciiz ""
	__exc22_msg:    .asciiz "  [MDMX]"
	__exc23_msg:    .asciiz "  [Watch]"
	__exc24_msg:    .asciiz "  [Machine check]"
	__exc25_msg:    .asciiz ""
	__exc26_msg:    .asciiz ""
	__exc27_msg:    .asciiz ""
	__exc28_msg:    .asciiz ""
	__exc29_msg:    .asciiz ""
	__exc30_msg:    .asciiz "  [Cache]"
	__exc31_msg:    .asciiz ""
	
	__level_msg:    .asciiz "Interrupt mask: "
	
	
	#########################################################################
	# Lookup table of exception messages
	__exc_msg_table:
		.word   __exc0_msg, __exc1_msg, __exc2_msg, __exc3_msg, __exc4_msg
		.word   __exc5_msg, __exc6_msg, __exc7_msg, __exc8_msg, __exc9_msg
		.word   __exc10_msg, __exc11_msg, __exc12_msg, __exc13_msg, __exc14_msg
		.word   __exc15_msg, __exc16_msg, __exc17_msg, __exc18_msg, __exc19_msg
		.word   __exc20_msg, __exc21_msg, __exc22_msg, __exc23_msg, __exc24_msg
		.word   __exc25_msg, __exc26_msg, __exc27_msg, __exc28_msg, __exc29_msg
		.word   __exc30_msg, __exc31_msg
	
	# Variables for save/restore of registers used in the handler
	save_v0:    .word   0
	save_a0:    .word   0
	save_at:    .word   0
	
	
	#########################################################################
	# This is the exception handler code that the processor runs when
	# an exception occurs. It only prints some information about the
	# exception, but can serve as a model of how to write a handler.
	#
	# Because this code is part of the kernel, it can use $k0 and $k1 without
	# saving and restoring their values.  By convention, they are treated
	# as temporary registers for kernel use.
	#
	# On the MIPS-1 (R2000), the exception handler must be at 0x80000080
	# This address is loaded into the program counter whenever an exception
	# occurs.  For the MIPS32, the address is 0x80000180.
	# Select the appropriate one for the mode in which SPIM is compiled.
	
		.ktext  0x80000180
	
		# Save ALL registers modified in this handler, except $k0 and $k1
		# This includes $t* since the user code does not explicitly
		# call this handler.  $sp cannot be trusted, so saving them to
		# the stack is not an option.  This routine is not reentrant (can't
		# be called again while it is running), so we can save registers
		# to static variables.
		sw      $v0, save_v0
		sw      $a0, save_a0
	
		# $at is the temporary register reserved for the assembler.
		# It may be modified by pseudo-instructions in this handler.
		# Since an interrupt could have occurred during a pseudo
		# instruction in user code, $at must be restored to ensure
		# that that pseudo instruction completes correctly.
		.set    noat
		sw      $at, save_at
		.set    at
	
		# Determine cause of the exception
		mfc0    $k0, $13        # Get cause register from coprocessor 0
		srl     $a0, $k0, 2     # Extract exception code field (bits 2-6)
		andi    $a0, $a0, 0x1f
		
		# Check for program counter issues (exception 6)
		bne     $a0, 6, ok_pc
		nop
	
		mfc0    $a0, $14        # EPC holds PC at moment exception occurred
		andi    $a0, $a0, 0x3   # Is EPC word-aligned (multiple of 4)?
		beqz    $a0, ok_pc
		nop
	
		# Bail out if PC is unaligned
		# Normally you don't want to do syscalls in an exception handler,
		# but this is MARS and not a real computer
		li      $v0, 4
		la      $a0, __exc3_msg
		syscall
		li      $v0, 10
		syscall
	
	ok_pc:
		mfc0    $k0, $13
		srl     $a0, $k0, 2     # Extract exception code from $k0 again
		andi    $a0, $a0, 0x1f
		bnez    $a0, non_interrupt  # Code 0 means exception was an interrupt
		nop
	
		# External interrupt handler
		# Don't skip instruction at EPC since it has not executed.
		# Interrupts occur BEFORE the instruction at PC executes.
		# Other exceptions occur during the execution of the instruction,
		# hence for those increment the return address to avoid
		# re-executing the instruction that caused the exception.
	
	     # check if we are in here because of a character on the keyboard simulator
		 # go to nochar if some other interrupt happened
		 
		 # get the character from memory
		 # store it to a queue somewhere to be dealt with later by normal code

		j	return
	
nochar:
		# not a character
		# Print interrupt level
		# Normally you don't want to do syscalls in an exception handler,
		# but this is MARS and not a real computer
		li      $v0, 4          # print_str
		la      $a0, __level_msg
		syscall
		
		li      $v0, 1          # print_int
		mfc0    $k0, $13        # Cause register
		srl     $a0, $k0, 11    # Right-justify interrupt level bits
		syscall
		
		li      $v0, 11         # print_char
		li      $a0, 10         # Line feed
		syscall
		
		j       return
	
	non_interrupt:
		# Print information about exception.
		# Normally you don't want to do syscalls in an exception handler,
		# but this is MARS and not a real computer
		li      $v0, 4          # print_str
		la      $a0, __start_msg_
		syscall
	
		li      $v0, 1          # print_int
		mfc0    $k0, $13        # Extract exception code again
		srl     $a0, $k0, 2
		andi    $a0, $a0, 0x1f
		syscall
	
		# Print message corresponding to exception code
		# Exception code is already shifted 2 bits from the far right
		# of the cause register, so it conveniently extracts out as
		# a multiple of 4, which is perfect for an array of 4-byte
		# string addresses.
		# Normally you don't want to do syscalls in an exception handler,
		# but this is MARS and not a real computer
		li      $v0, 4          # print_str
		mfc0    $k0, $13        # Extract exception code without shifting
		andi    $a0, $k0, 0x7c
		lw      $a0, __exc_msg_table($a0)
		nop
		syscall
	
		li      $v0, 4          # print_str
		la      $a0, __end_msg_
		syscall
	
		# Return from (non-interrupt) exception. Skip offending instruction
		# at EPC to avoid infinite loop.
		mfc0    $k0, $14
		addiu   $k0, $k0, 4
		mtc0    $k0, $14
	
	return:
		# Restore registers and reset processor state
		lw      $v0, save_v0    # Restore other registers
		lw      $a0, save_a0
	
		.set    noat            # Prevent assembler from modifying $at
		lw      $at, save_at
		.set    at
	
		mtc0    $zero, $13      # Clear Cause register
	
		# Re-enable interrupts, which were automatically disabled
		# when the exception occurred, using read-modify-write cycle.
		mfc0    $k0, $12        # Read status register
		andi    $k0, 0xfffd     # Clear exception level bit
		ori     $k0, 0x0001     # Set interrupt enable bit
		mtc0    $k0, $12        # Write back
	
		# Return from exception on MIPS32:
		eret
	
#################################################################################
