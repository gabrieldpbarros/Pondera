.data
instrucao_inicial:	.asciiz "------ Digite suas 4 tarefas ------\n"	
texto_opcoes:	.asciiz "\nO que você deseja fazer?"
opcoes_post:	.asciiz "\n0: próximo post\n1: comentários\n2: perfil do autor\n3: concluir tarefa\n4: sair\n"
mensagem_falta_task: 	.asciiz	"\nERRO: Você deve completar uma tarefa para poder avançar.\n"
mensagem_fim_tasks:	.asciiz	"\nERRO: Você já completou todas as tarefas do dia. Talvez seja uma boa ideia sair, não?\n"
posts_filename:	.asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
breakline:	.asciiz "\n"
flag:	.byte 0
ver_conclusao:	.byte 1	# marcador se podemos avançar para o próximo post
qt_tasks:	.byte 0 # quantidade de tasks concluidas

.text
.globl main
.globl main_loop
main:
	li, $s7, 0
	li $v0, 4
	la $a0, instrucao_inicial
	syscall
	
	la $a0, tasks_filename
	jal write_tasks
	
	jal bmp1
	jal main_post

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
	beq $t0, 1, next_post
	beq $t0, 2, comentarios
	# beq $t0, 2, next_post
	beq $t0, 4 complete_task
	beq $t0, 5 end_pondera
	
	j main_loop

next_post:
	# 1. Incrementa o índice do Post
	addi $s7, $s7, 1
	
	# 2. Verifica se $s7 é maior que o número máximo de posts (3)
	li $t1, 3
	beq $s7, $t1, reset_post_index # Se for 3, reseta para 0
	
	j select_bitmap_and_display # Continua o fluxo se for 1 ou 2

reset_post_index:
	li $s7, 0 # Reseta o índice para o Post 0

select_bitmap_and_display:
	beq $s7, 0, call_bmp1
	beq $s7, 1, call_bmp2
	beq $s7, 2, call_bmp3
    
	# 4. Rotinas de chamada e retorno
call_bmp1: 
	jal bmp1
	j continue_display
call_bmp2: 
	jal bmp2
	j continue_display
call_bmp3: 
	jal bmp3
	j continue_display

continue_display:
    	# 5. Chama main_post para exibir o Autor/Legenda (usando o $s7 atual)
	jal main_post
    
    	# 6. Retorna ao Loop Principal (menu)
	j main_loop

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

reset_post:
li $s7, 0

end_pondera:
    	li $v0, 10
    	syscall
