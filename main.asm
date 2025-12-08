.data
instrucao_inicial:	.asciiz "------ Digite suas 4 tarefas ------\n"	
texto_opcoes:	.asciiz "\nO que você deseja fazer?"
opcoes_post:	.asciiz "\n0: próximo post\n1: comentários\n2: perfil do autor\n3: concluir tarefa\n"
posts_filename:	.asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
breakline:	.asciiz "\n"
flag:	.byte 0

.text
.globl main
main:
	li $v0, 4
	la $a0, instrucao_inicial
	syscall
	
	la $a0, tasks_filename
	jal write_tasks

main_loop:
	# LOOP QUE DESCREVE UMA ESCOLHA DE ATIVIDADE DO USUÁRIO (ir para um post, completar uma tarefa, etc)
	li $v0, 4
	la $a0, texto_opcoes
	syscall
	li $v0, 4
	la $a0, opcoes_post
	syscall
	
	li $v0, 5
	syscall
	sb $v0, flag
	
	# --------------------------------------------------
	# VERIFICAÇÃO SE A FLAG FOI ARMAZENADA CORRETAMENTE
	# li $v0, 1
	# lb $a0, flag
	# syscall
	# --------------------------------------------------
		
	lb $t0, flag
	beq $t0, 0, next_post
	beq $t0, 3, complete_task # precisa adicionar as outras flags antes dessa
	
	j main_loop

next_post:		
    	la $a0, posts_filename
    	jal load_posts
    	
    	j end_pondera

complete_task:
	# --- Impressão das tarefas atuais ---
	# Quebra de linha inicial
	li $v0, 4
	la $a0, breakline
	syscall
	la $a0, tasks_filename
	jal show_tasks
	
	# --- Escolha da tarefa a ser concluída ---
	jal choose_task
	
	# --- Alteração da flag da task ---
	la $a0, tasks_filename
	jal finish_task
	
	# --- Alteração do arquivo de tasks ---
	la $a0, tasks_filename
	jal update_arch
	
	# --------------------------------------------------
	# VERIFICAÇÃO SE O ARQUIVO FOI ALTERADO CORRETAMENTE
	# la $a0, tasks_filename
	# jal show_tasks
	# --------------------------------------------------
	
	j main_loop

end_pondera:
    	li $v0, 10
    	syscall
