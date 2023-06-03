.data
# for creating the table
number_of_column: .asciiz "   1 2 3 4 5 6 7\n"
first: .asciiz "1 |_|_|_|_|_|_|_|\n"
second: .asciiz "2 |_|_|_|_|_|_|_|\n"
third: .asciiz "3 |_|_|_|_|_|_|_|\n"
fourth: .asciiz "4 |_|_|_|_|_|_|_|\n"
fifth: .asciiz "5 |_|_|_|_|_|_|_|\n"
sixth: .asciiz "6 |_|_|_|_|_|_|_|\n"
#################
#menu of the game to choose name
player1: .asciiz "player 1's name: "
player2: .asciiz "\nplayer 2's name: "
name1: .space 81 #store the name of player1
size1: .word 80  #store the name of player2
name2: .space 81
size2: .word 80
#################
#The game starts
start: .asciiz "\nNOW THE GAME STARTS\n"
turn: .asciiz "\nTurn of "
pieceX: .asciiz "The player starts the game with piece X is "
pieceO: .asciiz "The player starts the game with piece O is "
violation: .asciiz "Remaining violation possible: "
undo: .asciiz "Remaining undo possible: "
round: .asciiz "Round "
winner: .asciiz "The winner is "
loser1: .asciiz "Player 1 have violated over 3 times"
loser2: .asciiz "Player 2 have violated over 3 times"
#some text in-game
sentence: .asciiz "Please pick a column (to drop a piece): "
pickagain: .asciiz "Please pick a column again: "
choosemiddlecolumn: .asciiz "You cannot select other column besides the middle one since it is the first round (counted as a violation) \n"
outofrange: .asciiz "The column you chose is invalid (counted as a violation) \n"
selectoption: .asciiz "\nSelect option in this round (1.drop a piece; 2. block opponent; 3.remove one opponent's piece: "
fullcolumn: .asciiz "The column selected is full (counted as a violation)\n"
undo_action: .asciiz "If you want to undo your move then press 1, if not then press 0: "
invalid: .asciiz "Invalid option\n"
arbitrary: .asciiz "If you want to remove one piece of the opponent then press 1, if not then press 0 (one time only) : "
row: .asciiz "Input the row of the piece you want to remove from the opponent: "
column: .asciiz "Input the column of the piece you want to remove from the opponent: "
notexist: .asciiz "This spot does not contain the opponent's piece (please choose again the coordinates)\n"
block: .asciiz "If you want to block your opponent's next turn then press 1, if not then press 0 (one time only): "
cannot_block: .asciiz "Since your opponent already had 3 adjacent pieces, you cannot block the next move\n"
.text
main:
#################
###This is the game interface
#enter name for player1
li $v0,4
la $a0, player1
syscall
li $v0,8
la $a0,name1
lw $a1,size1
syscall
#enter name for player 2
li $v0,4
la $a0, player2
syscall
li $v0,8
la $a0,name2
lw $a1,size2
syscall
###########The game starts
#Randomly assign X and O to 2 players
li $v0,4
la $a0,start
syscall
li $v0,4
la $a0,pieceX
syscall
li $v0,4
la $a0,name1
syscall
li $v0,4
la $a0,pieceO
syscall
li $v0,4
la $a0,name2
syscall
#actual start
li $s1,3
li $s2,3
li $s3,3
li $s4,3
li $v1,0
li $s5,1
li $s6,1
li $k0,1
li $k1,1
Loop:
#cout the rount nth
addi $v1,$v1,1 # increase the round
li $v0,11	
la $a0,'\n'
syscall
li $v0,4
la $a0,round
syscall
li $v0,1
move $a0,$v1
syscall
######################player 1's turn
li $v0,4
la $a0,turn
syscall
li $v0,4
la $a0,name1
syscall
#cout the remaining violation of player1
li $v0,4
la $a0,violation
syscall
li $v0,1
move $a0,$s1
syscall
li $v0,11	
la $a0,'\n'
syscall
#cout the remaining undo of player1
li $v0,4
la $a0,undo
syscall
li $v0,1
move $a0,$s3
syscall
li $v0,11
la $a0,'\n'
syscall
#print the table
li $v0,,4
la $a0,number_of_column
syscall
li $v0,4
la $a0,first
syscall
li $v0,4
la $a0,second
syscall 
li $v0,4
la $a0,third
syscall 
li $v0,4
la $a0,fourth
syscall 
li $v0,4
la $a0,fifth
syscall 
li $v0,4
la $a0,sixth
syscall
# if this is not the first row then ask player whether they want to remove an arbitrary piece of opponent
bne $v1,1,remove_1
#print the sentence to ask the player to pick a column
normal_1:
li $a1,0 # use for check 3 adjacent pieces of player 1
li $a2,0 # use for check 3 adjacent pieces of player 2
li $s7,0     # this use for when deleting a piece, the others fall down then we have to check win condition, and then s7 use to escape to next player's turn without cout the undo
li $gp,0
li $v0,4
la $a0,sentence
syscall
#this piece of codes used for the first row where players have to drop a piece in the middle column
	Chooseagain1:
	bne $v1,1,else1	#if this is  not the first round then go to else1
	li $v0,5	# read a number from the player
	syscall
	move $t0,$v0
	beq $t0,4,continue1 #to check whether the player choose the middle column or not,if not then decrease the violation by 1
	addi $s1,$s1,-1 #reduce the remaining violation possible
	beq $s1,-1,win_2
	li $v0,4
	la $a0,choosemiddlecolumn
	syscall
	li $v0,4
	la $a0,pickagain
	syscall
	j Chooseagain1
#read the column given by the player
else1:
li $v0,5
syscall
move $t0,$v0
slti $t2,$t0,1 # check if the number chosen is <1
bne $t2,1,check_if_larger_than_7_1 #then go to check if the number is >7
li $v0,4
la $a0,outofrange
syscall
addi $s1,$s1,-1 # reduce the remaining violation possible
beq $s1,-1,win_2
li $v0,4
la $a0,pickagain
syscall
j else1
check_if_larger_than_7_1:
	li $t2,7
	slt $t2,$t2,$t0
	bne $t2,1,continue_after_round_1_1
	li $v0,4
	la $a0,outofrange
	syscall
	addi $s1,$s1,-1 # reduce the remaining violation possible
	beq $s1,-1,win_2
	li $v0,4
	la $a0,pickagain
	syscall
	j else1
	continue_after_round_1_1:
	j add_to_column_by_player_1
#insert X to the table in first round
continue1:
la $t1,sixth
li $s0,'X'
addi $t1,$t1,9
sb $s0,0($t1)
######################player 2's turn
player_2:
li $v0,11	
la $a0,'\n'
syscall
li $v0,4
la $a0,round
syscall
li $v0,1
move $a0,$v1
syscall
li $v0,4
la $a0,turn
syscall
li $v0,4
la $a0,name2
syscall
#cout the remaining violation of player1
li $v0,4
la $a0,violation
syscall
li $v0,1
move $a0,$s2
syscall
li $v0,11	
la $a0,'\n'
syscall
#cout the remaining undo of player1
li $v0,4
la $a0,undo
syscall
li $v0,1
move $a0,$s4
syscall
li $v0,11
la $a0,'\n'
syscall
#print the table
li $v0,,4
la $a0,number_of_column
syscall
li $v0,4
la $a0,first
syscall
li $v0,4
la $a0,second
syscall 
li $v0,4
la $a0,third
syscall 
li $v0,4
la $a0,fourth
syscall 
li $v0,4
la $a0,fifth
syscall 
li $v0,4
la $a0,sixth
syscall
# to check if player 2 wants to remove a piece from player 1 or not
bne $v1,1,remove_2
#print the sentence to ask the player to pick a column
normal_2:
li $a1,0 # use for checking 3 adjacent pieces of player 1
li $a2,0 # use for check 3 adjacent pieces of player 2
li $s7,0
li $gp,0
li $v0,4
la $a0,sentence
syscall
#this piece of codes used for the first row where players have to drop a piece in the middle column
	Chooseagain2:
	bne $v1,1,else2 # if this is not the first round then go to else2
	li $v0,5	# read a number from the player
	syscall
	move $t0,$v0
	beq $t0,4,continue2 #to check whether the player choose the middle column or not,if not then decrease the violation by 1
	addi $s2,$s2,-1 #reduce the remaining violation possible
	beq $s2,-1,win_1
	li $v0,4
	la $a0,choosemiddlecolumn
	syscall
	li $v0,4
	la $a0,pickagain
	syscall
	j Chooseagain2
	#read the column given by the player
else2:
li $v0,5
syscall
move $t0,$v0
slti $t2,$t0,1 # check if the number chosen is <1
bne $t2,1,check_if_larger_than_7_2 #then go to check if the number is >7
li $v0,4
la $a0,outofrange
syscall
addi $s2,$s2,-1 # reduce the remaining violation possible
beq $s2,-1,win_1
li $v0,4
la $a0,pickagain
syscall
j else2
check_if_larger_than_7_2:
	li $t2,7
	slt $t2,$t2,$t0
	bne $t2,1,continue_after_round_1_2	#if the input is valid then process
	li $v0,4
	la $a0,outofrange
	syscall
	addi $s2,$s2,-1 # reduce the remaining violation possible
	beq $s2,-1,win_1
	li $v0,4
	la $a0,pickagain
	syscall
	j else2
	continue_after_round_1_2:
	j add_to_column_by_player_2
continue2:	#this is used for the first round
la $t1,fifth
li $s0,'O'
addi $t1,$t1,9
sb $s0,0($t1)
j Loop

####################### 
#proceed to add to other columns
add_to_column_by_player_1:
la $t1,sixth #load address of 6th row
	bne $t0,1,column_2_1	#each bne check the column that player chose so that we can add t1 with the right number
	addi $t1,$t1,3
	addi $t7,$zero,3
	j add_X
	column_2_1:
	bne $t0,2,column_3_1
	addi $t1,$t1,5
	addi $t7,$zero,5
	j add_X
	column_3_1:
	bne $t0,3,column_4_1
	addi $t1,$t1,7
	addi $t7,$zero,7
	j add_X
	column_4_1:
	bne $t0,4,column_5_1
	addi $t1,$t1,9
	addi $t7,$zero,9
	j add_X
	column_5_1:
	bne $t0,5,column_6_1
	addi $t1,$t1,11
	addi $t7,$zero,11
	j add_X
	column_6_1:
	bne $t0,6,column_7_1
	addi $t1,$t1,13
	addi $t7,$zero,13
	j add_X
	column_7_1:
	addi $t1,$t1,15
	addi $t7,$zero,15
	j add_X
add_X:
	lb $t2,0($t1) #load the address of the right position
	li $t3,'_'
	bne $t2,$t3,row_5_1
	li $s0,'X'	#else insert X to it
	sb $s0,0($t1)
	j endmove_1
	row_5_1:
	la $t1,fifth
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_4_1
	li $s0,'X'
	sb $s0,0($t1)
	j endmove_1
	row_4_1:
	la $t1,fourth
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_3_1
	li $s0,'X'
	sb $s0,0($t1)
	j endmove_1
	row_3_1:
	la $t1,third
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_2_1
	li $s0,'X'
	sb $s0,0($t1)
	j endmove_1
	row_2_1:
	la $t1,second
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_1_1
	li $s0,'X'
	sb $s0,0($t1)
	j endmove_1
	row_1_1:
	la $t1,first
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,the_column_is_full_1
	li $s0,'X'
	sb $s0,0($t1)
	j endmove_1

	#if the column chosen is full
	the_column_is_full_1:
	li $v0,4
	la $a0,fullcolumn
	syscall
	addi $s1,$s1,-1 #if the violation is -1 then player 1 loses due to overviolation
	beq $s1,-1,win_2
	li $v0,4
	la $a0,pickagain
	syscall
	
	j Chooseagain1
	
	endmove_1:
	#print the table
li $v0,4
la $a0,number_of_column
syscall
li $v0,4
la $a0,first
syscall
li $v0,4
la $a0,second
syscall 
li $v0,4
la $a0,third
syscall 
li $v0,4
la $a0,fourth
syscall 
li $v0,4
la $a0,fifth
syscall 
li $v0,4
la $a0,sixth
syscall
	jal check_1 # important part: check if there is a winner or not
	undo_1:
	beq $s3,0,cannot_undo_1 # check if the player can still undo or not
	li $v0,4
	la $a0,undo_action
	syscall
	li $v0,5
	syscall
	move $s0,$v0
		# check if the selection is either 0 or 1
		slti $t5,$s0,0
		beq $t5,0,continue_checking_undo_1 #if the selection is >0 then check <1
		li $v0,4
		la $a0,invalid
		syscall
		j undo_1
		continue_checking_undo_1:
		sgt $t5,$s0,1
		beq $t5,0,proceed_undo_1
		li $v0,4
		la $a0,invalid
		syscall
		j undo_1
	proceed_undo_1:
	beq $s0,0,cannot_undo_1 #if s0=0 then we will continue to check if player wants to block
	li $s0,'_'
	sb $s0,0($t1)
	addi $s3,$s3,-1 # decrease the remaining undo of player 1
	#print the table
	li $v0,,4
	la $a0,number_of_column
	syscall
	li $v0,4
	la $a0,first
	syscall
	li $v0,4
	la $a0,second
	syscall 
	li $v0,4
	la $a0,third
	syscall 
	li $v0,4
	la $a0,fourth
	syscall 
	li $v0,4
	la $a0,fifth
	syscall 
	li $v0,4
	la $a0,sixth
	syscall
	li $v0,4
	la $a0,pickagain
	syscall
	j Chooseagain1
	cannot_undo_1:
	block_1:
	beq $k0,0,cannot_do_anything_1 # check if this player still has 1 move to block
	li $v0,4
	la $a0,block # ask player to block their opponent next move
	syscall
	li $v0,5
	syscall
	move $s0,$v0
	slti $t5,$s0,0
	beq $t5,0,continue_check_block_1
	li $v0,4
	la $a0,invalid
	syscall
	j block_1
		continue_check_block_1:
		sgt $t5,$s0,1
		beq $t5,0,proceed_block_1
		li $v0,4
		la $a0,invalid
		syscall
		j block_1
		proceed_block_1:
		bne $s0,1,cannot_do_anything_1	# if the selection is 1 then we will skip next player's turn
		beq $a2,1,cannot_block_because_3_1  # if a1 is 1 which means there is 3 adjacent pieces
		addi $k0,$k0,-1	
		j Loop
			cannot_block_because_3_1:
			li $v0,4
			la $a0,cannot_block
			syscall
	cannot_do_anything_1:
	j player_2
	
add_to_column_by_player_2:
la $t1,sixth #load address of 6th row
	bne $t0,1,column_2_2	#each bne check the column that player chose so that we can add t1 with the right number
	addi $t1,$t1,3
	addi $t7,$zero,3
	j add_O
	column_2_2:
	bne $t0,2,column_3_2
	addi $t1,$t1,5
	addi $t7,$zero,5
	j add_O
	column_3_2:
	bne $t0,3,column_4_2
	addi $t1,$t1,7
	addi $t7,$zero,7
	j add_O
	column_4_2:
	bne $t0,4,column_5_2
	addi $t1,$t1,9
	addi $t7,$zero,9
	j add_O
	column_5_2:
	bne $t0,5,column_6_2
	addi $t1,$t1,11
	addi $t7,$zero,11
	j add_O
	column_6_2:
	bne $t0,6,column_7_2
	addi $t1,$t1,13
	addi $t7,$zero,13
	j add_O
	column_7_2:
	addi $t1,$t1,15
	addi $t7,$zero,15
	j add_O
add_O:
	lb $t2,0($t1) #load the address of the first position
	li $t3,'_'
	bne $t2,$t3,row_5_2
	li $s0,'O'	#else insert X to it
	sb $s0,0($t1)
	j endmove_2
	row_5_2:
	la $t1,fifth
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_4_2
	li $s0,'O'
	sb $s0,0($t1)
	j endmove_2
	row_4_2:
	la $t1,fourth
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_3_2
	li $s0,'O'
	sb $s0,0($t1)
	j endmove_2
	row_3_2:
	la $t1,third
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_2_2
	li $s0,'O'
	sb $s0,0($t1)
	j endmove_2
	row_2_2:
	la $t1,second
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,row_1_2
	li $s0,'O'
	sb $s0,0($t1)
	j endmove_2
	row_1_2:
	la $t1,first
	add $t1,$t1,$t7
	lb $t2,0($t1)
	li $t3,'_'
	bne $t2,$t3,the_column_is_full_2
	li $s0,'O'
	sb $s0,0($t1)
	j endmove_2

	#if the column chosen is full
	the_column_is_full_2:
	li $v0,4
	la $a0,fullcolumn
	syscall
	addi $s2,$s2,-1
	beq $s2,-1,win_1 #if the remaining violation is -1 then the player 1 wins
	li $v0,4
	la $a0,pickagain
	syscall
	j Chooseagain2
	
	endmove_2:
	#print the table
li $v0,,4
la $a0,number_of_column
syscall
li $v0,4
la $a0,first
syscall
li $v0,4
la $a0,second
syscall 
li $v0,4
la $a0,third
syscall 
li $v0,4
la $a0,fourth
syscall 
li $v0,4
la $a0,fifth
syscall 
li $v0,4
la $a0,sixth
syscall
	jal check_1
	undo_2:
	beq $s4,0,cannot_undo_2
	li $v0,4
	la $a0,undo_action
	syscall
	li $v0,5
	syscall
	move $s0,$v0
		# check if the selection is either 0 or 1
		slti $t5,$s0,0
		beq $t5,0,continue_checking_undo_2 #if the selection is >0 then check <1
		li $v0,4
		la $a0,invalid
		syscall
		j undo_2
		continue_checking_undo_2:
		sgt $t5,$s0,1
		beq $t5,0,proceed_undo_2
		li $v0,4
		la $a0,invalid
		syscall
		j undo_2
	proceed_undo_2:
	beq $s0,0,cannot_undo_2 #if s0=0 then we will continue to block selection
	Try:
	li $s0,'_'
	sb $s0,0($t1)
	addi $s4,$s4,-1 # decrease the remaining undo of player 2
	#print the table
	li $v0,,4
	la $a0,number_of_column
	syscall
	li $v0,4
	la $a0,first
	syscall
	li $v0,4
	la $a0,second
	syscall 
	li $v0,4
	la $a0,third
	syscall 
	li $v0,4
	la $a0,fourth
	syscall 
	li $v0,4
	la $a0,fifth
	syscall 
	li $v0,4
	la $a0,sixth
	syscall
	li $v0,4
	la $a0,pickagain
	syscall
	j Chooseagain2
	cannot_undo_2:
	block_2:
	beq $k1,0,cannot_do_anything_2 # check if this player still has 1 move to block
	li $v0,4
	la $a0,block # ask player to block their opponent next move
	syscall
	li $v0,5
	syscall
	move $s0,$v0
	slti $t5,$s0,0
	beq $t5,0,continue_check_block_2
	li $v0,4
	la $a0,invalid
	syscall
	j block_2
		continue_check_block_2:
		sgt $t5,$s0,1
		beq $t5,0,proceed_block_2
		li $v0,4
		la $a0,invalid
		syscall
		j block_1
		proceed_block_2:
		bne $s0,1,cannot_do_anything_2	# if the selection is 1 then we will skip next player's turn
		beq $a1,1,cannot_block_because_3_2  # if a1 is 1 which means there is 3 adjacent pieces
		addi $k1,$k1,-1
		addi $v1,$v1,1 # increase the round	
		j player_2
			cannot_block_because_3_2:
			li $v0,4
			la $a0,cannot_block
			syscall
	cannot_do_anything_2:
	j Loop



############# force a player to lose if they violate >3 times
win_1:
li $v0,4
la $a0,winner
syscall
li $v0,4
la $a0,name1
syscall
li $v0,4
la $a0,loser2
syscall
li $v0,10
syscall

win_2:
li $v0,4
la $a0,winner
syscall
li $v0,4
la $a0,name2
syscall
li $v0,4
la $a0,loser1
syscall
li $v0,10
syscall

########## remove arbitrary piece
remove_1:
beq $s5,1,execute_remove_1 # to check if player still has 1 round to remove
j normal_1
execute_remove_1:
li $v0,4
la $a0,arbitrary
syscall
li $v0,5
syscall
move $s0,$v0
slti $t5,$v0,0  # to check the input is either 0 or 1
beq $t5,0,continue_checking_arbitrary_1
li $v0,4
la $a0,invalid
syscall
j execute_remove_1
	continue_checking_arbitrary_1:
	sgt $t5,$v0,1
	beq $t5,0,proceed_remove_1
	li $v0,4
	la $a0,invalid
	syscall
	j execute_remove_1
proceed_remove_1:
	beq $s0,0,normal_1
	li $v0,4
	la $a0,row  # choose the row of the piece
	syscall
	li $v0,5
	syscall
	move $t8,$v0
	slti $t5,$v0,1
	beq $t5,0,check_arbitrary_larger_than_6_1
	li $v0,4
	la $a0,invalid
	syscall
	j proceed_remove_1
	check_arbitrary_larger_than_6_1:
	sgt $t5,$v0,6
	beq $t5,0,choose_column_1
	li $v0,4
	la $a0,invalid
	syscall
	j proceed_remove_1
	choose_column_1:
		li $v0,4
		la $a0,column  # choose the column of the piece
		syscall
		li $v0,5
		syscall
		move $t9,$v0
		slti $t5,$v0,1
		beq $t5,0,check_arbitrary_larger_than_7_1
		li $v0,4
		la $a0,invalid
		syscall
		j choose_column_1
		check_arbitrary_larger_than_7_1:
		sgt $t5,$v0,7
		beq $t5,0,delete_and_fall_1
		li $v0,4
		la $a0,invalid
		syscall
		j choose_column_1

delete_and_fall_1:
addi $s5,$s5,-1
li $s7,1 # later use
li $gp,0
li $t3,'O'
beq $t8,6,delete_6th_and_fall_1
beq $t8,5,delete_5th_and_fall_1
beq $t8,4,delete_4th_and_fall_1
beq $t8,3,delete_3rd_and_fall_1
beq $t8,2,delete_2nd_and_fall_1
beq $t8,1,delete_1st_and_fall_1
	delete_6th_and_fall_1:
	la $t5,sixth
	bne $t9,1,delete_6_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_2_1:
	bne $t9,2,delete_6_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_3_1:
		bne $t9,3,delete_6_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_4_1:
		bne $t9,4,delete_6_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_5_1:
		bne $t9,5,delete_6_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_6_1:
		bne $t9,6,delete_6_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_6_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_6_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
		# end delete row sixth
	delete_5th_and_fall_1:
	la $t5,fifth
	bne $t9,1,delete_5_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_2_1:
	bne $t9,2,delete_5_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_3_1:
		bne $t9,3,delete_5_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_4_1:
		bne $t9,4,delete_5_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_5_1:
		bne $t9,5,delete_5_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_6_1:
		bne $t9,6,delete_5_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_5_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_5_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
		# end delete row fifth
	delete_4th_and_fall_1:
	la $t5,fourth
	bne $t9,1,delete_4_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_2_1:
	bne $t9,2,delete_4_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_3_1:
		bne $t9,3,delete_4_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_4_1:
		bne $t9,4,delete_4_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_5_1:
		bne $t9,5,delete_4_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_6_1:
		bne $t9,6,delete_4_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_4_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_4_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
		# end delete row fourth
	delete_3rd_and_fall_1:
	la $t5,third
	bne $t9,1,delete_3_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_2_1:
	bne $t9,2,delete_3_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_3_1:
		bne $t9,3,delete_3_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_4_1:
		bne $t9,4,delete_3_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_5_1:
		bne $t9,5,delete_3_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_6_1:
		bne $t9,6,delete_3_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
	delete_3_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_3_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_1
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_1
		# end delete row third
	delete_2nd_and_fall_1:
	la $t5,second
	bne $t9,1,delete_2_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_2_1:
	bne $t9,2,delete_2_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_3_1:
		bne $t9,3,delete_2_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_4_1:
		bne $t9,4,delete_2_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_5_1:
		bne $t9,5,delete_2_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_6_1:
		bne $t9,6,delete_2_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
	delete_2_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_1   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_1
		# end delete row second
	delete_1st_and_fall_1:
	la $t5,first
	bne $t9,1,delete_1_column_2_1
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_1_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_1_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_2_1:
	bne $t9,2,delete_1_column_3_1
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_2_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_2_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_3_1:
		bne $t9,3,delete_1_column_4_1
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_3_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_3_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_4_1:
		bne $t9,4,delete_1_column_5_1
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_4_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_4_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_5_1:
		bne $t9,5,delete_1_column_6_1
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_5_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_5_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_6_1:
		bne $t9,6,delete_1_column_7_1
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_6_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_6_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
	delete_1_column_7_1:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_7_1 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_1_column_7_1:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_1
		# end delete row first
	#### end delete for player 1

remove_2:
beq $s6,1,execute_remove_2 # to check if player still has 1 round to remove
j normal_2
execute_remove_2:
li $v0,4
la $a0,arbitrary
syscall
li $v0,5
syscall
move $s0,$v0
slti $t5,$v0,0  # to check the input is either 0 or 1
beq $t5,0,continue_checking_arbitrary_2
li $v0,4
la $a0,invalid
syscall
j execute_remove_2
	continue_checking_arbitrary_2:
	sgt $t5,$v0,1
	beq $t5,0,proceed_remove_2
	li $v0,4
	la $a0,invalid
	syscall
	j execute_remove_2
proceed_remove_2:
	beq $s0,0,normal_2
	li $v0,4
	la $a0,row  # choose the row of the piece
	syscall
	li $v0,5
	syscall
	move $t8,$v0
	slti $t5,$v0,1
	beq $t5,0,check_arbitrary_larger_than_6_2
	li $v0,4
	la $a0,invalid
	syscall
	j proceed_remove_2
	check_arbitrary_larger_than_6_2:
	sgt $t5,$v0,6
	beq $t5,0,choose_column_2
	li $v0,4
	la $a0,invalid
	syscall
	j proceed_remove_2
	choose_column_2:
		li $v0,4
		la $a0,column  # choose the column of the piece
		syscall
		li $v0,5
		syscall
		move $t9,$v0
		slti $t5,$v0,1
		beq $t5,0,check_arbitrary_larger_than_7_2
		li $v0,4
		la $a0,invalid
		syscall
		j choose_column_2
		check_arbitrary_larger_than_7_2:
		sgt $t5,$v0,7
		beq $t5,0,delete_and_fall_2
		li $v0,4
		la $a0,invalid
		syscall
		j choose_column_2

delete_and_fall_2:
addi $s6,$s6,-1
li $gp,1 # later use
li $s7,0
li $t3,'X'
beq $t8,6,delete_6th_and_fall_2
beq $t8,5,delete_5th_and_fall_2
beq $t8,4,delete_4th_and_fall_2
beq $t8,3,delete_3rd_and_fall_2
beq $t8,2,delete_2nd_and_fall_2
beq $t8,1,delete_1st_and_fall_2
	delete_6th_and_fall_2:
	la $t5,sixth
	bne $t9,1,delete_6_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_2_2:
	bne $t9,2,delete_6_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_3_2:
		bne $t9,3,delete_6_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_4_2:
		bne $t9,4,delete_6_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_5_2:
		bne $t9,5,delete_6_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_6_2:
		bne $t9,6,delete_6_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_6_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_6_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_6_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fifth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 5 col 1 to rows 6 col 1
		sb $t3,0($t6)
		la $t5,fourth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,fourth
		la $t5,third
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
		# end delete row sixth
	delete_5th_and_fall_2:
	la $t5,fifth
	bne $t9,1,delete_5_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_2_2:
	bne $t9,2,delete_5_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_3_2:
		bne $t9,3,delete_5_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_4_2:
		bne $t9,4,delete_5_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_5_2:
		bne $t9,5,delete_5_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_6_2:
		bne $t9,6,delete_5_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_5_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_5_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_5_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,fourth  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 4 col 1 to rows 5 col 1
		sb $t3,0($t6)
		la $t5,third
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,third
		la $t5,second
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
		# end delete row fifth
	delete_4th_and_fall_2:
	la $t5,fourth
	bne $t9,1,delete_4_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,3
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_2_2:
	bne $t9,2,delete_4_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,5
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_3_2:
		bne $t9,3,delete_4_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,7
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_4_2:
		bne $t9,4,delete_4_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,9
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_5_2:
		bne $t9,5,delete_4_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,11
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_6_2:
		bne $t9,6,delete_4_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,13
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_4_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_4_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_4_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,third  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 3 col 1 to rows 4 col 1
		sb $t3,0($t6)
		la $t5,second
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		la $t6,second
		la $t5,first
		addi $t6,$t6,15
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
		# end delete row fourth
	delete_3rd_and_fall_2:
	la $t5,third
	bne $t9,1,delete_3_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_2_2:
	bne $t9,2,delete_3_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_3_2:
		bne $t9,3,delete_3_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_4_2:
		bne $t9,4,delete_3_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_5_2:
		bne $t9,5,delete_3_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_6_2:
		bne $t9,6,delete_3_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
	delete_3_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_3_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_3_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,second  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 2 col 1 to rows 3 col 1
		sb $t3,0($t6)
		la $t5,first
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,endmove_2
		sb $t2,0($t6)
		sb $t3,0($t5)
		j endmove_2
		# end delete row third
	delete_2nd_and_fall_2:
	la $t5,second
	bne $t9,1,delete_2_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,3
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_2_2:
	bne $t9,2,delete_2_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_1
		erase_2_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,5
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_3_2:
		bne $t9,3,delete_2_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,7
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_4_2:
		bne $t9,4,delete_2_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,9
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_5_2:
		bne $t9,5,delete_2_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,11
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_6_2:
		bne $t9,6,delete_2_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,13
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
	delete_2_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_2_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_2_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		la $t6,first  # to check upper rows so that those pieces can fall down
		addi $t6,$t6,15
		lb $t2,0($t6) # get the piece to check
		beq $t2,$t3,endmove_2   # if the piece is _ then nothings happen
		sb $t2,0($t5)         # else drop the piece from rows 1 col 1 to rows 2 col 1
		sb $t3,0($t6)
		j endmove_2
		# end delete row second
	delete_1st_and_fall_2:
	la $t5,first
	bne $t9,1,delete_1_column_2_2
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_1_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_1_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_2_2:
	bne $t9,2,delete_1_column_3_2
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_2_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_2_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_3_2:
		bne $t9,3,delete_1_column_4_2
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_3_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_3_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_4_2:
		bne $t9,4,delete_1_column_5_2
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_4_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_4_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_5_2:
		bne $t9,5,delete_1_column_6_2
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_5_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_5_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_6_2:
		bne $t9,6,delete_1_column_7_2
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_6_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_6_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
	delete_1_column_7_2:
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,erase_1_column_7_2 #to check the given coordinate has a piece of the opponent
		li $v0,4
		la $a0,notexist
		syscall
		j proceed_remove_2
		erase_1_column_7_2:
		li $t3,'_'
		sb $t3,0($t5) # delete the piece
		j endmove_2
		# end delete row first
	#### end delete for player 2	
############ check for the winner each round
check_1:
li $t3,'X'
check_horizontal_1:
		check_horizontal_6_1_1:
		la $t5,sixth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_2_1
		j check_horizontal_6_2_1
		check_horizontal_6_1_2_1:
		la $t5,sixth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_3_1
		j check_horizontal_6_2_1
		check_horizontal_6_1_3_1:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_4_1
		j check_horizontal_6_2_1
		check_horizontal_6_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_6_2_1
		# end check horizontal 6_1
		check_horizontal_6_2_1:
		la $t5,sixth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_2_1
		j check_horizontal_6_3_1
		check_horizontal_6_2_2_1:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_3_1
		j check_horizontal_6_3_1
		check_horizontal_6_2_3_1:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_4_1
		j check_horizontal_6_3_1
		check_horizontal_6_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_6_3_1
		# end check horizontal 6_2
		check_horizontal_6_3_1:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_2_1
		j check_horizontal_6_4_1
		check_horizontal_6_3_2_1:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_3_1
		j check_horizontal_6_4_1
		check_horizontal_6_3_3_1:
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_4_1
		j check_horizontal_6_4_1
		check_horizontal_6_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_6_4_1
		# end check horizontal 6_3
		check_horizontal_6_4_1:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_2_1
		j check_horizontal_5_1_1
		check_horizontal_6_4_2_1:
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_3_1
		j check_horizontal_5_1_1
		check_horizontal_6_4_3_1:
		la $t5,sixth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_4_1
		j check_horizontal_5_1_1
		check_horizontal_6_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_5_1_1
		# end check horizontal 6_4
		# end check the sixth row
		check_horizontal_5_1_1:
		la $t5,fifth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_2_1
		j check_horizontal_5_2_1
		check_horizontal_5_1_2_1:
		la $t5,fifth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_3_1
		j check_horizontal_5_2_1
		check_horizontal_5_1_3_1:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_4_1
		j check_horizontal_5_2_1
		check_horizontal_5_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_5_2_1
		# end check horizontal 5_1
		check_horizontal_5_2_1:
		la $t5,fifth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_2_1
		j check_horizontal_5_3_1
		check_horizontal_5_2_2_1:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_3_1
		j check_horizontal_5_3_1
		check_horizontal_5_2_3_1:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_4_1
		j check_horizontal_5_3_1
		check_horizontal_5_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_5_3_1
		# end check horizontal 5_2
		check_horizontal_5_3_1:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_2_1
		j check_horizontal_5_4_1
		check_horizontal_5_3_2_1:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_3_1
		j check_horizontal_5_4_1
		check_horizontal_5_3_3_1:
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_4_1
		j check_horizontal_5_4_1
		check_horizontal_5_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_5_4_1
		# end check horizontal 5_3
		check_horizontal_5_4_1:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_2_1
		j check_horizontal_4_1_1
		check_horizontal_5_4_2_1:
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_3_1
		j check_horizontal_4_1_1
		check_horizontal_5_4_3_1:
		la $t5,fifth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_4_1
		j check_horizontal_4_1_1
		check_horizontal_5_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_4_1_1
		# end check horizontal 5_4
		#end check the fifth row
		check_horizontal_4_1_1:
		la $t5,fourth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_2_1
		j check_horizontal_4_2_1
		check_horizontal_4_1_2_1:
		la $t5,fourth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_3_1
		j check_horizontal_4_2_1
		check_horizontal_4_1_3_1:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_4_1
		j check_horizontal_4_2_1
		check_horizontal_4_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_4_2_1
		# end check horizontal 4_1
		check_horizontal_4_2_1:
		la $t5,fourth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_2_1
		j check_horizontal_4_3_1
		check_horizontal_4_2_2_1:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_3_1
		j check_horizontal_4_3_1
		check_horizontal_4_2_3_1:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_4_1
		j check_horizontal_4_3_1
		check_horizontal_4_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_4_3_1
		# end check horizontal 4_2
		check_horizontal_4_3_1:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_2_1
		j check_horizontal_4_4_1
		check_horizontal_4_3_2_1:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_3_1
		j check_horizontal_4_4_1
		check_horizontal_4_3_3_1:
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_4_1
		j check_horizontal_4_4_1
		check_horizontal_4_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_4_4_1
		# end check horizontal 4_3
		check_horizontal_4_4_1:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_2_1
		j check_horizontal_3_1_1
		check_horizontal_4_4_2_1:
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_3_1
		j check_horizontal_3_1_1
		check_horizontal_4_4_3_1:
		la $t5,fourth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_4_1
		j check_horizontal_3_1_1
		check_horizontal_4_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_3_1_1
		# end check horizontal 5_4
		#end check the fifth row
		check_horizontal_3_1_1:
		la $t5,third
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_2_1
		j check_horizontal_3_2_1
		check_horizontal_3_1_2_1:
		la $t5,third
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_3_1
		j check_horizontal_3_2_1
		check_horizontal_3_1_3_1:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_4_1
		j check_horizontal_3_2_1
		check_horizontal_3_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_3_2_1
		# end check horizontal 3_1
		check_horizontal_3_2_1:
		la $t5,third
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_2_1
		j check_horizontal_3_3_1
		check_horizontal_3_2_2_1:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_3_1
		j check_horizontal_3_3_1
		check_horizontal_3_2_3_1:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_4_1
		j check_horizontal_3_3_1
		check_horizontal_3_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_3_3_1
		# end check horizontal 3_2
		check_horizontal_3_3_1:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_2_1
		j check_horizontal_3_4_1
		check_horizontal_3_3_2_1:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_3_1
		j check_horizontal_3_4_1
		check_horizontal_3_3_3_1:
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_4_1
		j check_horizontal_3_4_1
		check_horizontal_3_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_3_4_1
		# end check horizontal 3_3
		check_horizontal_3_4_1:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_2_1
		j check_horizontal_2_1_1
		check_horizontal_3_4_2_1:
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_3_1
		j check_horizontal_2_1_1
		check_horizontal_3_4_3_1:
		la $t5,third
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_4_1
		j check_horizontal_2_1_1
		check_horizontal_3_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_2_1_1
		# end check horizontal 3_4
		#end check the third row
		check_horizontal_2_1_1:
		la $t5,second
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_2_1
		j check_horizontal_2_2_1
		check_horizontal_2_1_2_1:
		la $t5,second
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_3_1
		j check_horizontal_2_2_1
		check_horizontal_2_1_3_1:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_4_1
		j check_horizontal_2_2_1
		check_horizontal_2_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_2_2_1
		# end check horizontal 2_1
		check_horizontal_2_2_1:
		la $t5,second
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_2_1
		j check_horizontal_2_3_1
		check_horizontal_2_2_2_1:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_3_1
		j check_horizontal_2_3_1
		check_horizontal_2_2_3_1:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_4_1
		j check_horizontal_2_3_1
		check_horizontal_2_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_2_3_1
		# end check horizontal 2_2
		check_horizontal_2_3_1:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_2_1
		j check_horizontal_2_4_1
		check_horizontal_2_3_2_1:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_3_1
		j check_horizontal_2_4_1
		check_horizontal_2_3_3_1:
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_4_1
		j check_horizontal_2_4_1
		check_horizontal_2_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_2_4_1
		# end check horizontal 2_3
		check_horizontal_2_4_1:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_2_1
		j check_horizontal_1_1_1
		check_horizontal_2_4_2_1:
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_3_1
		j check_horizontal_1_1_1
		check_horizontal_2_4_3_1:
		la $t5,second
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_4_1
		j check_horizontal_1_1_1
		check_horizontal_2_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_1_1_1
		# end check horizontal 2_4
		#end check the second row
		check_horizontal_1_1_1:
		la $t5,first
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_2_1
		j check_horizontal_1_2_1
		check_horizontal_1_1_2_1:
		la $t5,first
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_3_1
		j check_horizontal_1_2_1
		check_horizontal_1_1_3_1:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_4_1
		j check_horizontal_1_2_1
		check_horizontal_1_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_1_2_1
		# end check horizontal 1_1
		check_horizontal_1_2_1:
		la $t5,first
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_2_1
		j check_horizontal_1_3_1
		check_horizontal_1_2_2_1:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_3_1
		j check_horizontal_1_3_1
		check_horizontal_1_2_3_1:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_4_1
		j check_horizontal_1_3_1
		check_horizontal_1_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_1_3_1
		# end check horizontal 1_2
		check_horizontal_1_3_1:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_2_1
		j check_horizontal_1_4_1
		check_horizontal_1_3_2_1:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_3_1
		j check_horizontal_1_4_1
		check_horizontal_1_3_3_1:
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_4_1
		j check_horizontal_1_4_1
		check_horizontal_1_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_horizontal_1_4_1
		# end check horizontal 1_3
		check_horizontal_1_4_1:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_2_1
		j check_vertical_1
		check_horizontal_1_4_2_1:
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_3_1
		j check_vertical_1
		check_horizontal_1_4_3_1:
		la $t5,first
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_4_1
		j check_vertical_1
		check_horizontal_1_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_vertical_1
		# end check horizontal 1_4
		#end check the first row
		# end checking horizontally
check_vertical_1:
		beq $s7,0,not_remove_1 #to check if there is vertical win after delete then we have to update t7
			bne $t9,1,add_t7_to_5_1
			addi $t7,$zero,3
			j not_remove_1
			add_t7_to_5_1:
			bne $t9,2,add_t7_to_7_1
			addi $t7,$zero,5
			j not_remove_1
			add_t7_to_7_1:
			bne $t9,3,add_t7_to_9_1
			addi $t7,$zero,7
			j not_remove_1
			add_t7_to_9_1:
			bne $t9,4,add_t7_to_11_1
			addi $t7,$zero,9
			j not_remove_1
			add_t7_to_11_1:
			bne $t9,5,add_t7_to_13_1
			addi $t7,$zero,11
			j not_remove_1
			add_t7_to_13_1:
			bne $t9,6,add_t7_to_15_1
			addi $t7,$zero,13
			j not_remove_1
			add_t7_to_15_1:
			addi $t7,$zero,15
			j not_remove_1
		not_remove_1:
		rows_6_5_4_3_1: # check 4 rows 6th,5th,4th,3rd
		la $t5,sixth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_2_1
		j rows_5_4_3_2_1
		rows_6_5_4_3_2_1:
		la $t5,fifth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_3_1
		j rows_5_4_3_2_1
		rows_6_5_4_3_3_1:
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_4_1
		j rows_5_4_3_2_1
		rows_6_5_4_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j rows_5_4_3_2_1
		
		rows_5_4_3_2_1: #check 4 rows 5th,4th,3rd,2nd
		la $t5,fifth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_2_1
		j rows_4_3_2_1_1
		rows_5_4_3_2_2_1:
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_3_1
		j rows_4_3_2_1_1
		rows_5_4_3_2_3_1:
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_4_1
		j rows_4_3_2_1_1
		rows_5_4_3_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j rows_4_3_2_1_1
		
		rows_4_3_2_1_1: #check 4 rows 4th,3rd,2nd,1st
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_2_1
		j check_diagonal_right_1
		rows_4_3_2_1_2_1:
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_3_1
		j check_diagonal_right_1
		rows_4_3_2_1_3_1:
		la $t5,second
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_4_1
		j check_diagonal_right_1
		rows_4_3_2_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_1
		# end checking vertically
check_diagonal_right_1:
		check_diagonal_right_1_1:
		la $t5,fourth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_2_1
		j check_diagonal_right_2_1
		check_diagonal_right_1_2_1:
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_3_1
		j check_diagonal_right_2_1
		check_diagonal_right_1_3_1:
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_4_1
		j check_diagonal_right_2_1
		check_diagonal_right_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		#end check diagonal_1 right
		check_diagonal_right_2_1:
		la $t5,fifth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_2_1
		j check_diagonal_right_3_1
		check_diagonal_right_2_2_1:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_3_1
		j check_diagonal_right_3_1
		check_diagonal_right_2_3_1:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_4_1
		j check_diagonal_right_3_1
		check_diagonal_right_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_3_1
		#end check diagonal right_2
		check_diagonal_right_3_1:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_2_1
		j check_diagonal_right_4_1
		check_diagonal_right_3_2_1:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_3_1
		j check_diagonal_right_4_1
		check_diagonal_right_3_3_1:
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_4_1
		j check_diagonal_right_4_1
		check_diagonal_right_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_4_1
		# end check diagonal right_3
		check_diagonal_right_4_1:
		la $t5,sixth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_2_1
		j check_diagonal_right_5_1
		check_diagonal_right_4_2_1:
		la $t5,fifth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_3_1
		j check_diagonal_right_5_1
		check_diagonal_right_4_3_1:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_4_1
		j check_diagonal_right_5_1
		check_diagonal_right_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_5_1
		# end check diagonal right_4
		check_diagonal_right_5_1:
		la $t5,fifth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_2_1
		j check_diagonal_right_6_1
		check_diagonal_right_5_2_1:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_3_1
		j check_diagonal_right_6_1
		check_diagonal_right_5_3_1:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_4_1
		j check_diagonal_right_6_1
		check_diagonal_right_5_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_6_1
		# end check diagonal right_5
		check_diagonal_right_6_1:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_2_1
		j check_diagonal_right_7_1
		check_diagonal_right_6_2_1:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_3_1
		j check_diagonal_right_7_1
		check_diagonal_right_6_3_1:
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_4_1
		j check_diagonal_right_7_1
		check_diagonal_right_6_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_7_1
		# end check diagonal right_6
		check_diagonal_right_7_1:
		la $t5,sixth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_2_1
		j check_diagonal_right_8_1
		check_diagonal_right_7_2_1:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_3_1
		j check_diagonal_right_8_1
		check_diagonal_right_7_3_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_4_1
		j check_diagonal_right_8_1
		check_diagonal_right_7_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_8_1
		# end check diagonal right_7
		check_diagonal_right_8_1:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_2_1
		j check_diagonal_right_9_1
		check_diagonal_right_8_2_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_3_1
		j check_diagonal_right_9_1
		check_diagonal_right_8_3_1:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_4_1
		j check_diagonal_right_9_1
		check_diagonal_right_8_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_9_1
		# end check diagonal right_8
		check_diagonal_right_9_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_2_1
		j check_diagonal_right_10_1
		check_diagonal_right_9_2_1:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_3_1
		j check_diagonal_right_10_1
		check_diagonal_right_9_3_1:
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_4_1
		j check_diagonal_right_10_1
		check_diagonal_right_9_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_10_1
		# end check diagonal right_9
		check_diagonal_right_10_1:
		la $t5,sixth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_2_1
		j check_diagonal_right_11_1
		check_diagonal_right_10_2_1:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_3_1
		j check_diagonal_right_11_1
		check_diagonal_right_10_3_1:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_4_1
		j check_diagonal_right_11_1
		check_diagonal_right_10_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_11_1
		# end check diagonal right_10
		check_diagonal_right_11_1:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_2_1
		j check_diagonal_right_12_1
		check_diagonal_right_11_2_1:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_3_1
		j check_diagonal_right_12_1
		check_diagonal_right_11_3_1:
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_4_1
		j check_diagonal_right_12_1
		check_diagonal_right_11_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_right_12_1
		# end check diagonal right_11
		check_diagonal_right_12_1:
		la $t5,sixth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_2_1
		j check_diagonal_left_1
		check_diagonal_right_12_2_1:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_3_1
		j check_diagonal_left_1
		check_diagonal_right_12_3_1:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_4_1
		j check_diagonal_left_1
		check_diagonal_right_12_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_1
		# end check diagonal_right_12
		# end check diagonal right
check_diagonal_left_1:
		check_diagonal_left_1_1:
		la $t5,fourth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_2_1
		j check_diagonal_left_2_1
		check_diagonal_left_1_2_1:
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_3_1
		j check_diagonal_left_2_1
		check_diagonal_left_1_3_1:
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_4_1
		j check_diagonal_left_2_1
		check_diagonal_left_1_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		#end check diagonal_1 left
		check_diagonal_left_2_1:
		la $t5,fifth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_2_1
		j check_diagonal_left_3_1
		check_diagonal_left_2_2_1:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_3_1
		j check_diagonal_left_3_1
		check_diagonal_left_2_3_1:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_4_1
		j check_diagonal_left_3_1
		check_diagonal_left_2_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_3_1
		#end check diagonal left_2
		check_diagonal_left_3_1:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_2_1
		j check_diagonal_left_4_1
		check_diagonal_left_3_2_1:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_3_1
		j check_diagonal_left_4_1
		check_diagonal_left_3_3_1:
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_4_1
		j check_diagonal_left_4_1
		check_diagonal_left_3_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_4_1
		# end check diagonal left_3
		check_diagonal_left_4_1:
		la $t5,sixth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_2_1
		j check_diagonal_left_5_1
		check_diagonal_left_4_2_1:
		la $t5,fifth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_3_1
		j check_diagonal_left_5_1
		check_diagonal_left_4_3_1:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_4_1
		j check_diagonal_left_5_1
		check_diagonal_left_4_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_5_1
		# end check diagonal left_4
		check_diagonal_left_5_1:
		la $t5,fifth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_2_1
		j check_diagonal_left_6_1
		check_diagonal_left_5_2_1:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_3_1
		j check_diagonal_left_6_1
		check_diagonal_left_5_3_1:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_4_1
		j check_diagonal_left_6_1
		check_diagonal_left_5_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_6_1
		# end check diagonal left_5
		check_diagonal_left_6_1:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_2_1
		j check_diagonal_left_7_1
		check_diagonal_left_6_2_1:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_3_1
		j check_diagonal_left_7_1
		check_diagonal_left_6_3_1:
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_4_1
		j check_diagonal_left_7_1
		check_diagonal_left_6_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_7_1
		# end check diagonal left_6
		check_diagonal_left_7_1:
		la $t5,sixth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_2_1
		j check_diagonal_left_8_1
		check_diagonal_left_7_2_1:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_3_1
		j check_diagonal_left_8_1
		check_diagonal_left_7_3_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_4_1
		j check_diagonal_left_8_1
		check_diagonal_left_7_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_8_1
		# end check diagonal left_7
		check_diagonal_left_8_1:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_2_1
		j check_diagonal_left_9_1
		check_diagonal_left_8_2_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_3_1
		j check_diagonal_left_9_1
		check_diagonal_left_8_3_1:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_4_1
		j check_diagonal_left_9_1
		check_diagonal_left_8_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_9_1
		# end check diagonal left_8
		check_diagonal_left_9_1:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_2_1
		j check_diagonal_left_10_1
		check_diagonal_left_9_2_1:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_3_1
		j check_diagonal_left_10_1
		check_diagonal_left_9_3_1:
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_4_1
		j check_diagonal_left_10_1
		check_diagonal_left_9_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_10_1
		# end check diagonal left_9
		check_diagonal_left_10_1:
		la $t5,sixth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_2_1
		j check_diagonal_left_11_1
		check_diagonal_left_10_2_1:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_3_1
		j check_diagonal_left_11_1
		check_diagonal_left_10_3_1:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_4_1
		j check_diagonal_left_11_1
		check_diagonal_left_10_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_11_1
		# end check diagonal left_10
		check_diagonal_left_11_1:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_2_1
		j check_diagonal_left_12_1
		check_diagonal_left_11_2_1:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_3_1
		j check_diagonal_left_12_1
		check_diagonal_left_11_3_1:
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_4_1
		j check_diagonal_left_12_1
		check_diagonal_left_11_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j check_diagonal_left_12_1
		# end check diagonal left_11
		check_diagonal_left_12_1:
		la $t5,sixth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_2_1
		j end_check_1
		check_diagonal_left_12_2_1:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_3_1
		j end_check_1
		check_diagonal_left_12_3_1:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_4_1
		j end_check_1
		check_diagonal_left_12_4_1:
		li $a1,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_1
		j end_check_1
		# end check diagonal_left_12
		# end check diagonal left
end_check_1:

check_2:
li $t3,'O'
check_horizontal_2:
		check_horizontal_6_1_2:
		la $t5,sixth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_2_2
		j check_horizontal_6_2_2
		check_horizontal_6_1_2_2:
		la $t5,sixth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_3_2
		j check_horizontal_6_2_2
		check_horizontal_6_1_3_2:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_1_4_2
		j check_horizontal_6_2_2
		check_horizontal_6_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_6_2_2
		# end check horizontal 6_1
		check_horizontal_6_2_2:
		la $t5,sixth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_2_2
		j check_horizontal_6_3_2
		check_horizontal_6_2_2_2:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_3_2
		j check_horizontal_6_3_2
		check_horizontal_6_2_3_2:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_2_4_2
		j check_horizontal_6_3_2
		check_horizontal_6_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_6_3_2
		# end check horizontal 6_2
		check_horizontal_6_3_2:
		la $t5,sixth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_2_2
		j check_horizontal_6_4_2
		check_horizontal_6_3_2_2:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_3_2
		j check_horizontal_6_4_2
		check_horizontal_6_3_3_2:
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_3_4_2
		j check_horizontal_6_4_2
		check_horizontal_6_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_6_4_2
		# end check horizontal 6_3
		check_horizontal_6_4_2:
		la $t5,sixth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_2_2
		j check_horizontal_5_1_2
		check_horizontal_6_4_2_2:
		la $t5,sixth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_3_2
		j check_horizontal_5_1_2
		check_horizontal_6_4_3_2:
		la $t5,sixth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_6_4_4_2
		j check_horizontal_5_1_2
		check_horizontal_6_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,sixth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_5_1_2
		# end check horizontal 6_4
		# end check the sixth row
		check_horizontal_5_1_2:
		la $t5,fifth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_2_2
		j check_horizontal_5_2_2
		check_horizontal_5_1_2_2:
		la $t5,fifth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_3_2
		j check_horizontal_5_2_2
		check_horizontal_5_1_3_2:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_1_4_2
		j check_horizontal_5_2_2
		check_horizontal_5_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_5_2_2
		# end check horizontal 5_1
		check_horizontal_5_2_2:
		la $t5,fifth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_2_2
		j check_horizontal_5_3_2
		check_horizontal_5_2_2_2:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_3_2
		j check_horizontal_5_3_2
		check_horizontal_5_2_3_2:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_2_4_2
		j check_horizontal_5_3_2
		check_horizontal_5_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_5_3_2
		# end check horizontal 5_2
		check_horizontal_5_3_2:
		la $t5,fifth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_2_2
		j check_horizontal_5_4_2
		check_horizontal_5_3_2_2:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_3_2
		j check_horizontal_5_4_2
		check_horizontal_5_3_3_2:
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_3_4_2
		j check_horizontal_5_4_2
		check_horizontal_5_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_5_4_2
		# end check horizontal 5_3
		check_horizontal_5_4_2:
		la $t5,fifth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_2_2
		j check_horizontal_4_1_2
		check_horizontal_5_4_2_2:
		la $t5,fifth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_3_2
		j check_horizontal_4_1_2
		check_horizontal_5_4_3_2:
		la $t5,fifth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_5_4_4_2
		j check_horizontal_4_1_2
		check_horizontal_5_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fifth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_4_1_2
		# end check horizontal 5_4
		#end check the fifth row
		check_horizontal_4_1_2:
		la $t5,fourth
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_2_2
		j check_horizontal_4_2_2
		check_horizontal_4_1_2_2:
		la $t5,fourth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_3_2
		j check_horizontal_4_2_2
		check_horizontal_4_1_3_2:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_1_4_2
		j check_horizontal_4_2_2
		check_horizontal_4_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_4_2_2
		# end check horizontal 4_1
		check_horizontal_4_2_2:
		la $t5,fourth
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_2_2
		j check_horizontal_4_3_2
		check_horizontal_4_2_2_2:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_3_2
		j check_horizontal_4_3_2
		check_horizontal_4_2_3_2:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_2_4_2
		j check_horizontal_4_3_2
		check_horizontal_4_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_4_3_2
		# end check horizontal 4_2
		check_horizontal_4_3_2:
		la $t5,fourth
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_2_2
		j check_horizontal_4_4_2
		check_horizontal_4_3_2_2:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_3_2
		j check_horizontal_4_4_2
		check_horizontal_4_3_3_2:
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_3_4_2
		j check_horizontal_4_4_2
		check_horizontal_4_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_4_4_2
		# end check horizontal 4_3
		check_horizontal_4_4_2:
		la $t5,fourth
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_2_2
		j check_horizontal_3_1_2
		check_horizontal_4_4_2_2:
		la $t5,fourth
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_3_2
		j check_horizontal_3_1_2
		check_horizontal_4_4_3_2:
		la $t5,fourth
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_4_4_4_2
		j check_horizontal_3_1_2
		check_horizontal_4_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,fourth
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_3_1_2
		# end check horizontal 5_4
		#end check the fifth row
		check_horizontal_3_1_2:
		la $t5,third
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_2_2
		j check_horizontal_3_2_2
		check_horizontal_3_1_2_2:
		la $t5,third
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_3_2
		j check_horizontal_3_2_2
		check_horizontal_3_1_3_2:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_1_4_2
		j check_horizontal_3_2_2
		check_horizontal_3_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_3_2_2
		# end check horizontal 3_1
		check_horizontal_3_2_2:
		la $t5,third
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_2_2
		j check_horizontal_3_3_2
		check_horizontal_3_2_2_2:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_3_2
		j check_horizontal_3_3_2
		check_horizontal_3_2_3_2:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_2_4_2
		j check_horizontal_3_3_2
		check_horizontal_3_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_3_3_2
		# end check horizontal 3_2
		check_horizontal_3_3_2:
		la $t5,third
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_2_2
		j check_horizontal_3_4_2
		check_horizontal_3_3_2_2:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_3_2
		j check_horizontal_3_4_2
		check_horizontal_3_3_3_2:
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_3_4_2
		j check_horizontal_3_4_2
		check_horizontal_3_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_3_4_2
		# end check horizontal 3_3
		check_horizontal_3_4_2:
		la $t5,third
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_2_2
		j check_horizontal_2_1_2
		check_horizontal_3_4_2_2:
		la $t5,third
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_3_2
		j check_horizontal_2_1_2
		check_horizontal_3_4_3_2:
		la $t5,third
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_3_4_4_2
		j check_horizontal_2_1_2
		check_horizontal_3_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_2_1_2
		# end check horizontal 3_4
		#end check the third row
		check_horizontal_2_1_2:
		la $t5,second
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_2_2
		j check_horizontal_2_2_2
		check_horizontal_2_1_2_2:
		la $t5,second
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_3_2
		j check_horizontal_2_2_2
		check_horizontal_2_1_3_2:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_1_4_2
		j check_horizontal_2_2_2
		check_horizontal_2_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_2_2_2
		# end check horizontal 2_1
		check_horizontal_2_2_2:
		la $t5,second
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_2_2
		j check_horizontal_2_3_2
		check_horizontal_2_2_2_2:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_3_2
		j check_horizontal_2_3_2
		check_horizontal_2_2_3_2:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_2_4_2
		j check_horizontal_2_3_2
		check_horizontal_2_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_2_3_2
		# end check horizontal 2_2
		check_horizontal_2_3_2:
		la $t5,second
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_2_2
		j check_horizontal_2_4_2
		check_horizontal_2_3_2_2:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_3_2
		j check_horizontal_2_4_2
		check_horizontal_2_3_3_2:
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_3_4_2
		j check_horizontal_2_4_2
		check_horizontal_2_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_2_4_2
		# end check horizontal 2_3
		check_horizontal_2_4_2:
		la $t5,second
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_2_2
		j check_horizontal_1_1_2
		check_horizontal_2_4_2_2:
		la $t5,second
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_3_2
		j check_horizontal_1_1_2
		check_horizontal_2_4_3_2:
		la $t5,second
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_2_4_4_2
		j check_horizontal_1_1_2
		check_horizontal_2_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_1_1_2
		# end check horizontal 2_4
		#end check the second row
		check_horizontal_1_1_2:
		la $t5,first
		add $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_2_2
		j check_horizontal_1_2_2
		check_horizontal_1_1_2_2:
		la $t5,first
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_3_2
		j check_horizontal_1_2_2
		check_horizontal_1_1_3_2:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_1_4_2
		j check_horizontal_1_2_2
		check_horizontal_1_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_1_2_2
		# end check horizontal 1_1
		check_horizontal_1_2_2:
		la $t5,first
		add $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_2_2
		j check_horizontal_1_3_2
		check_horizontal_1_2_2_2:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_3_2
		j check_horizontal_1_3_2
		check_horizontal_1_2_3_2:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_2_4_2
		j check_horizontal_1_3_2
		check_horizontal_1_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_1_3_2
		# end check horizontal 1_2
		check_horizontal_1_3_2:
		la $t5,first
		add $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_2_2
		j check_horizontal_1_4_2
		check_horizontal_1_3_2_2:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_3_2
		j check_horizontal_1_4_2
		check_horizontal_1_3_3_2:
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_3_4_2
		j check_horizontal_1_4_2
		check_horizontal_1_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_horizontal_1_4_2
		# end check horizontal 1_3
		check_horizontal_1_4_2:
		la $t5,first
		add $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_2_2
		j check_vertical_2
		check_horizontal_1_4_2_2:
		la $t5,first
		add $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_3_2
		j check_vertical_2
		check_horizontal_1_4_3_2:
		la $t5,first
		add $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_horizontal_1_4_4_2
		j check_vertical_2
		check_horizontal_1_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_vertical_2
		# end check horizontal 1_4
		#end check the first row
		# end checking horizontally
check_vertical_2:
		beq $gp,0,not_remove_2 #to check if there is vertical win after delete then we have to update t7
			bne $t9,1,add_t7_to_5_2
			addi $t7,$zero,3
			j not_remove_2
			add_t7_to_5_2:
			bne $t9,2,add_t7_to_7_2
			addi $t7,$zero,5
			j not_remove_2
			add_t7_to_7_2:
			bne $t9,3,add_t7_to_9_2
			addi $t7,$zero,7
			j not_remove_2
			add_t7_to_9_2:
			bne $t9,4,add_t7_to_11_2
			addi $t7,$zero,9
			j not_remove_2
			add_t7_to_11_2:
			bne $t9,5,add_t7_to_13_2
			addi $t7,$zero,11
			j not_remove_2
			add_t7_to_13_2:
			bne $t9,6,add_t7_to_15_2
			addi $t7,$zero,13
			j not_remove_2
			add_t7_to_15_2:
			addi $t7,$zero,15
			j not_remove_2
		not_remove_2:
		rows_6_5_4_3_2: # check 4 rows 6th,5th,4th,3rd
		la $t5,sixth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_2_2
		j rows_5_4_3_2_2
		rows_6_5_4_3_2_2:
		la $t5,fifth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_3_2
		j rows_5_4_3_2_2
		rows_6_5_4_3_3_2:
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_6_5_4_3_4_2
		j rows_5_4_3_2_2
		rows_6_5_4_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j rows_5_4_3_2_2
		
		rows_5_4_3_2_2: #check 4 rows 5th,4th,3rd,2nd
		la $t5,fifth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_2_2
		j rows_4_3_2_1_2
		rows_5_4_3_2_2_2:
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_3_2
		j rows_4_3_2_1_2
		rows_5_4_3_2_3_2:
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_5_4_3_2_4_2
		j rows_4_3_2_1_2
		rows_5_4_3_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j rows_4_3_2_1_2
		
		rows_4_3_2_1_2: #check 4 rows 4th,3rd,2nd,1st
		la $t5,fourth
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_2_2
		j check_diagonal_right_2
		rows_4_3_2_1_2_2:
		la $t5,third
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_3_2
		j check_diagonal_right_2
		rows_4_3_2_1_3_2:
		la $t5,second
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,rows_4_3_2_1_4_2
		j check_diagonal_right_2
		rows_4_3_2_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		add $t5,$t5,$t7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_2
		# end checking vertically
check_diagonal_right_2:
		check_diagonal_right_1_2:
		la $t5,fourth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_2_2
		j check_diagonal_right_2_2
		check_diagonal_right_1_2_2:
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_3_2
		j check_diagonal_right_2_2
		check_diagonal_right_1_3_2:
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_1_4_2
		j check_diagonal_right_2_2
		check_diagonal_right_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		#end check diagonal_1 right
		check_diagonal_right_2_2:
		la $t5,fifth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_2_2
		j check_diagonal_right_3_2
		check_diagonal_right_2_2_2:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_3_2
		j check_diagonal_right_3_2
		check_diagonal_right_2_3_2:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_2_4_2
		j check_diagonal_right_3_2
		check_diagonal_right_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_3_2
		#end check diagonal right_2
		check_diagonal_right_3_2:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_2_2
		j check_diagonal_right_4_2
		check_diagonal_right_3_2_2:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_3_2
		j check_diagonal_right_4_2
		check_diagonal_right_3_3_2:
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_3_4_2
		j check_diagonal_right_4_2
		check_diagonal_right_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_4_2
		# end check diagonal right_3
		check_diagonal_right_4_2:
		la $t5,sixth
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_2_2
		j check_diagonal_right_5_2
		check_diagonal_right_4_2_2:
		la $t5,fifth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_3_2
		j check_diagonal_right_5_2
		check_diagonal_right_4_3_2:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_4_4_2
		j check_diagonal_right_5_2
		check_diagonal_right_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_5_2
		# end check diagonal right_4
		check_diagonal_right_5_2:
		la $t5,fifth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_2_2
		j check_diagonal_right_6_2
		check_diagonal_right_5_2_2:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_3_2
		j check_diagonal_right_6_2
		check_diagonal_right_5_3_2:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_5_4_2
		j check_diagonal_right_6_2
		check_diagonal_right_5_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_6_2
		# end check diagonal right_5
		check_diagonal_right_6_2:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_2_2
		j check_diagonal_right_7_2
		check_diagonal_right_6_2_2:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_3_2
		j check_diagonal_right_7_2
		check_diagonal_right_6_3_2:
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_6_4_2
		j check_diagonal_right_7_2
		check_diagonal_right_6_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_7_2
		# end check diagonal right_6
		check_diagonal_right_7_2:
		la $t5,sixth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_2_2
		j check_diagonal_right_8_2
		check_diagonal_right_7_2_2:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_3_2
		j check_diagonal_right_8_2
		check_diagonal_right_7_3_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_7_4_2
		j check_diagonal_right_8_2
		check_diagonal_right_7_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_8_2
		# end check diagonal right_7
		check_diagonal_right_8_2:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_2_2
		j check_diagonal_right_9_2
		check_diagonal_right_8_2_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_3_2
		j check_diagonal_right_9_2
		check_diagonal_right_8_3_2:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_8_4_2
		j check_diagonal_right_9_2
		check_diagonal_right_8_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_9_2
		# end check diagonal right_8
		check_diagonal_right_9_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_2_2
		j check_diagonal_right_10_2
		check_diagonal_right_9_2_2:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_3_2
		j check_diagonal_right_10_2
		check_diagonal_right_9_3_2:
		la $t5,second
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_9_4_2
		j check_diagonal_right_10_2
		check_diagonal_right_9_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_10_2
		# end check diagonal right_9
		check_diagonal_right_10_2:
		la $t5,sixth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_2_2
		j check_diagonal_right_11_2
		check_diagonal_right_10_2_2:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_3_2
		j check_diagonal_right_11_2
		check_diagonal_right_10_3_2:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_10_4_2
		j check_diagonal_right_11_2
		check_diagonal_right_10_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_11_2
		# end check diagonal right_10
		check_diagonal_right_11_2:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_2_2
		j check_diagonal_right_12_2
		check_diagonal_right_11_2_2:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_3_2
		j check_diagonal_right_12_2
		check_diagonal_right_11_3_2:
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_11_4_2
		j check_diagonal_right_12_2
		check_diagonal_right_11_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_right_12_2
		# end check diagonal right_11
		check_diagonal_right_12_2:
		la $t5,sixth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_2_2
		j check_diagonal_left_2
		check_diagonal_right_12_2_2:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_3_2
		j check_diagonal_left_2
		check_diagonal_right_12_3_2:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_right_12_4_2
		j check_diagonal_left_2
		check_diagonal_right_12_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_2
		# end check diagonal_right_12
		# end check diagonal right
check_diagonal_left_2:
		check_diagonal_left_1_2:
		la $t5,fourth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_2_2
		j check_diagonal_left_2_2
		check_diagonal_left_1_2_2:
		la $t5,third
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_3_2
		j check_diagonal_left_2_2
		check_diagonal_left_1_3_2:
		la $t5,second
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_1_4_2
		j check_diagonal_left_2_2
		check_diagonal_left_1_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		#end check diagonal_1 left
		check_diagonal_left_2_2:
		la $t5,fifth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_2_2
		j check_diagonal_left_3_2
		check_diagonal_left_2_2_2:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_3_2
		j check_diagonal_left_3_2
		check_diagonal_left_2_3_2:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_2_4_2
		j check_diagonal_left_3_2
		check_diagonal_left_2_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_3_2
		#end check diagonal left_2
		check_diagonal_left_3_2:
		la $t5,fourth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_2_2
		j check_diagonal_left_4_2
		check_diagonal_left_3_2_2:
		la $t5,third
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_3_2
		j check_diagonal_left_4_2
		check_diagonal_left_3_3_2:
		la $t5,second
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_3_4_2
		j check_diagonal_left_4_2
		check_diagonal_left_3_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_4_2
		# end check diagonal left_3
		check_diagonal_left_4_2:
		la $t5,sixth
		addi $t5,$t5,15
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_2_2
		j check_diagonal_left_5_2
		check_diagonal_left_4_2_2:
		la $t5,fifth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_3_2
		j check_diagonal_left_5_2
		check_diagonal_left_4_3_2:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_4_4_2
		j check_diagonal_left_5_2
		check_diagonal_left_4_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_5_2
		# end check diagonal left_4
		check_diagonal_left_5_2:
		la $t5,fifth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_2_2
		j check_diagonal_left_6_2
		check_diagonal_left_5_2_2:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_3_2
		j check_diagonal_left_6_2
		check_diagonal_left_5_3_2:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_5_4_2
		j check_diagonal_left_6_2
		check_diagonal_left_5_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_6_2
		# end check diagonal left_5
		check_diagonal_left_6_2:
		la $t5,fourth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_2_2
		j check_diagonal_left_7_2
		check_diagonal_left_6_2_2:
		la $t5,third
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_3_2
		j check_diagonal_left_7_2
		check_diagonal_left_6_3_2:
		la $t5,second
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_6_4_2
		j check_diagonal_left_7_2
		check_diagonal_left_6_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_7_2
		# end check diagonal left_6
		check_diagonal_left_7_2:
		la $t5,sixth
		addi $t5,$t5,13
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_2_2
		j check_diagonal_left_8_2
		check_diagonal_left_7_2_2:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_3_2
		j check_diagonal_left_8_2
		check_diagonal_left_7_3_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_7_4_2
		j check_diagonal_left_8_2
		check_diagonal_left_7_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_8_2
		# end check diagonal left_7
		check_diagonal_left_8_2:
		la $t5,fifth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_2_2
		j check_diagonal_left_9_2
		check_diagonal_left_8_2_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_3_2
		j check_diagonal_left_9_2
		check_diagonal_left_8_3_2:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_8_4_2
		j check_diagonal_left_9_2
		check_diagonal_left_8_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_9_2
		# end check diagonal left_8
		check_diagonal_left_9_2:
		la $t5,fourth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_2_2
		j check_diagonal_left_10_2
		check_diagonal_left_9_2_2:
		la $t5,third
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_3_2
		j check_diagonal_left_10_2
		check_diagonal_left_9_3_2:
		la $t5,second
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_9_4_2
		j check_diagonal_left_10_2
		check_diagonal_left_9_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,first
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_10_2
		# end check diagonal left_9
		check_diagonal_left_10_2:
		la $t5,sixth
		addi $t5,$t5,11
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_2_2
		j check_diagonal_left_11_2
		check_diagonal_left_10_2_2:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_3_2
		j check_diagonal_left_11_2
		check_diagonal_left_10_3_2:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_10_4_2
		j check_diagonal_left_11_2
		check_diagonal_left_10_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_11_2
		# end check diagonal left_10
		check_diagonal_left_11_2:
		la $t5,fifth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_2_2
		j check_diagonal_left_12_2
		check_diagonal_left_11_2_2:
		la $t5,fourth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_3_2
		j check_diagonal_left_12_2
		check_diagonal_left_11_3_2:
		la $t5,third
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_11_4_2
		j check_diagonal_left_12_2
		check_diagonal_left_11_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,second
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j check_diagonal_left_12_2
		# end check diagonal left_11
		check_diagonal_left_12_2:
		la $t5,sixth
		addi $t5,$t5,9
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_2_2
		j end_check_2
		check_diagonal_left_12_2_2:
		la $t5,fifth
		addi $t5,$t5,7
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_3_2
		j end_check_2
		check_diagonal_left_12_3_2:
		la $t5,fourth
		addi $t5,$t5,5
		lb $t2,0($t5)
		beq $t2,$t3,check_diagonal_left_12_4_2
		j end_check_2
		check_diagonal_left_12_4_2:
		li $a2,1 # use for check 3 adjacent pieces
		la $t5,third
		addi $t5,$t5,3
		lb $t2,0($t5)
		beq $t2,$t3,there_is_a_winner_2
		j end_check_2
		# end check diagonal_left_12
		# end check diagonal left
end_check_2:
beq $s7,1,cannot_undo_1
beq $gp,1,cannot_undo_2
jr $ra

############ there is a winner by default
there_is_a_winner_1:
li $v0,4
la $a0,winner
syscall
li $v0,4
la $a0,name1
syscall
li $v0,10
syscall

there_is_a_winner_2:
li $v0,4
la $a0,winner
syscall
li $v0,4
la $a0,name2
syscall
li $v0,10
syscall
