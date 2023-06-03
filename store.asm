#print the table
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
#
s1 is used to store remaining violation of player1
s2 is used to store remaining violation of player2
s3 is used to store remaining undo of player1
s4 is used to store remaining undo of player2
s5 is used to store 1 turn remove arbitrary piece of player 1
s6 is used to store 1 turn remove arbitrary piece of player 2
#
v1 is used to show the round nth
#
t0 is used to store the column chosen by the player
t1 is used to store the address of one of 6 rows
t4 is used to store the value of t1 (temporary)
t5 is used to store the temporary address of a slot to use for checking winner
t6 is used to count as i
t7 is used to store the right position in each row
t8 is used to store the row player wants to delete from the opponent
t9 is used to store the column player wants to delete from the opponent
#
s0 is used to store X and O
# 
k0 is used to store the remaining block of player 1
k1 is used to store the remaining block of player 2
#
a1 use to store if the player 1 have 3 adjacent pieces or not
a2 use to store if the player 2 have 3 adjacent pieces or not
beq $t8,5,delete_5th_and_fall_1
beq $t8,4,delete_4th_and_fall_1
beq $t8,3,delete_3rd_and_fall_1
beq $t8,2,delete_2nd_and_fall_1
beq $t8,1,delete_1st_and_fall_1
