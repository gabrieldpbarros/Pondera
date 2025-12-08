.data
tasks_filename:	.asciiz "tasks.txt"
flag:	.word 0

.text
.globl main
main:
	la $a0, tasks_filename
	jal write_tasks

    	jal main_post

    	li $v0, 10
    	syscall
