.data
instrucao_inicial:	.asciiz "------ Digite suas 4 tarefas ------\n"	
texto_opcoes:	.asciiz "\nO que voce deseja fazer?"
opcoes_post:	.asciiz "\n1: Proximo post\n2: Comentarios\n3: Perfil do autor\n4: Concluir tarefa\n5: Sair\n------------------\n"
mensagem_falta_task: 	.asciiz	"\nERRO: Voce deve completar uma tarefa para poder avancar.\n"
mensagem_fim_tasks:	.asciiz	"\nERRO: Voce ja completou todas as tarefas do dia. Talvez seja uma boa ideia sair, nao?\n"
mensagem_numero_fora: .asciiz "\nERRO: Digite um número de 1 a 5 para prosseguir com uma opção válida"
posts_filename:	.asciiz "posts.txt"
tasks_filename:	.asciiz "tasks.txt"
breakline:	.asciiz "\n"
flag:	.byte 0
ver_conclusao:	.byte 0	# marcador se podemos avancar para o proximo post
qt_tasks:	.byte 0 # quantidade de tasks concluidas

.text
.globl main
.globl main_loop
main:
	li $s7, 0
	li $v0, 4
	la $a0, instrucao_inicial
	syscall
	
	la $a0, tasks_filename
	jal write_tasks
	# Quebra de linha para preservar a estética
	li $v0, 4
	la $a0, breakline
	syscall
	
	# Chama o primeiro post sem precisar terminar tarefa
	jal bmp1
	jal main_post

main_loop:
	# Loop que descreve a escolha de atividade do usuário (seguir para o próximo post, completar uma tarefa, etc)
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
	beq $t0, 3, ver_autor
	beq $t0, 4, complete_task
	beq $t0, 5, end_pondera
	
	li $v0, 4
	la $a0, mensagem_numero_fora
	syscall
	
	j main_loop

next_post:
	# Verificacao se podemos ir para o proximo post
	lb $t0, ver_conclusao
	beq $t0, 0, precisa_task
	# Atualizamos o valor do marcador
	subi $t0, $t0, 1
	sb $t0, ver_conclusao
	
	# 1. Incrementa o indice do Post
	addi $s7, $s7, 1
	
	# 2. Verifica se $s7 e maior que o numero maximo de posts (3)
	li $t1, 3
	beq $s7, $t1, reset_post_index # Se for 3, reseta para 0
	
	j seleciona_bitmaps # Continua o fluxo se for 1 ou 2

reset_post_index:
	li $s7, 0 # Reseta o indice para o Post 0


seleciona_bitmaps:
	beq $s7, 0, chama_bitmap1
	beq $s7, 1, chama_bitmap2
	beq $s7, 2, chama_bitmap3
    
# 4. Rotinas de chamada e retorno
chama_bitmap1: 
	jal bmp1
	j continua_display
chama_bitmap2: 
	jal bmp2
	j continua_display
chama_bitmap3: 
	jal bmp3
	j continua_display

continua_display:
    	# 5. Chama main_post para exibir o Autor/Legenda (usando o $s7 atual)
	jal main_post
    
    	# 6. Retorna ao Loop Principal (menu)
	j main_loop

complete_task:
	# Verificacao se existem tasks a serem concluidas
	lb $t0, qt_tasks
	beq $t0, 4, fim_tasks
	# Atualizamos o tracker de quantidade de tasks e podemos avançar +1 post
	lb $t1, ver_conclusao
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	sb $t1, ver_conclusao
	sb $t0, qt_tasks
	
	# --- Impressao das tarefas atuais ---
	# Quebra de linha inicial
	li $v0, 4
	la $a0, breakline
	syscall
	la $a0, tasks_filename
	jal show_tasks
	
	# --- Escolha da tarefa a ser concluida ---
	jal choose_task
	
	# --- Alteracao da flag da task ---
	la $a0, tasks_filename
	jal finish_task
	
	# --- Alteracao do arquivo de tasks ---
	la $a0, tasks_filename
	jal update_arch
	
	j main_loop

reset_post:
li $s7, 0

precisa_task:
	# Imprime o texto de erro
	li $v0, 4
	la $a0, mensagem_falta_task
	syscall
	
	j main_loop
	
fim_tasks:
	# Imprime o texto de erro
	li $v0, 4
	la $a0, mensagem_fim_tasks
	syscall
	
	j main_loop

end_pondera:
    	li $v0, 10
    	syscall
