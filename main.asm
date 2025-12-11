.data
instrucao_inicial:	.asciiz "------ Digite suas 4 tarefas ------\n"	
texto_opcoes:	.asciiz "\nO que você deseja fazer?"
opcoes_post:	.asciiz "\n1: próximo post\n2: comentários\n3: perfil do autor\n4: concluir tarefa\n5: Ver o tempo desde a ultima troca de post\n6:sair\n"
posts_filename:	.asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
breakline:	.asciiz "\n"
last_post_time_file: .asciiz "last_post_time.txt" # Nome do arquivo de registro
time_buffer: .space 8                           # Buffer para 64 bits (8 bytes) do tempo
time_msg_prefix: .asciiz "\nTempo desde a última troca de post: "
time_msg_sufix: .asciiz " segundos.\n"
flag:	.byte 0

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
	jal record_post_time
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
		
	lb $t0, flag
	beq $t0, 1, next_post
	beq $t0, 2, comentarios
	#beq $t0, 2, ver_autor
	beq $t0, 4, complete_task # precisa adicionar as outras flags antes dessa
	beq $t0, 5, show_time_since_last_post
	beq $t0, 6, end_pondera
	
	j main_loop

next_post:
	# 1. Incrementa o índice do Post
	addi $s7, $s7, 1
	
	# 2. Verifica se $s7 é maior que o número máximo de posts (3)
	li $t1, 3
	beq $s7, $t1, reset_post_index # Se for 3, reseta para 0
	
	j Seleciona_bitmaps # Continua o fluxo se for 1 ou 2

reset_post_index:
	li $s7, 0 # Reseta o índice para o Post 0

Seleciona_bitmaps:
beq $s7, 0, Chama_bitmap1
beq $s7, 1, Chama_bitmap2
beq $s7, 2, Chama_bitmap3
    
	# 4. Rotinas de chamada e retorno
Chama_bitmap1: 
jal bmp1
j Continua_display
Chama_bitmap2: 
jal bmp2
j Continua_display
Chama_bitmap3: 
jal bmp3
j Continua_display

Continua_display:
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
	
	j main_loop

reset_post:
li $s7, 0

show_time_since_last_post: # <<-- NOVO ROTEAMENTO
    jal calculate_time_diff
    j main_loop

end_pondera:
    	li $v0, 10
    	syscall