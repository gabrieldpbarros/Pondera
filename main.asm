.data
instrucao_inicial:	.asciiz "------ Digite suas 4 tarefas ------\n"	
posts_filename:	.asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
flag:	.word 0

.text
.globl main
main:
	li $v0, 4
	la $a0, instrucao_inicial
	syscall
	
	la $a0, tasks_filename
	jal write_tasks

    	la $a0, posts_filename
    	jal load_posts

    	li $v0, 10
    	syscall
