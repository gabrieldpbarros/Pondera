.data
posts_filename: .asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
flag:	.word 0

.text
.globl main
main:
	la $a0, tasks_filename
	jal write_tasks

    	la $a0, posts_filename
    	jal load_posts

    	li $v0, 10
    	syscall
