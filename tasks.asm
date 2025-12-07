.data
	buffer:	.space 2048
	flag_task:	.byte 0		# utilizamos para selecionar qual será a task concluída

.text
.globl write_tasks
.globl show_tasks

# att do zé: Resolvi o erro de escrita e deixei comentado seu codigo que tava errado, basicamente
# você estava jogando 100 bits direto do buffer, agora eu to considerando o tamanho real da entrada


write_tasks:
	# Definimos um contador para a escrita das tasks (começamos em 1 para facilitar a impressão mais abaixo)
	li $t0, 1

	# Abre o arquivo
	li $v0, 13
	
	#----------------------------------
	# o $a0 já vai ter o arquivo n precisa do move
	# move $a0, $a0
	# ---------------------------------
	
	li $a1, 1 	# write-only (sem append)
	li $a2, 0
	
	syscall
	move $s0, $v0 	# salvamos o file descriptor
	
writing_loop:
	beq $t0, 5, close
	
	# Imprime um marcador visual que facilita a interação
	li $v0, 4
	la $a0, tarefa
	syscall
	li $v0, 1
	la $a0, ($t0)
	syscall
	li $v0, 4
	la $a0, dois_pontos
	syscall
	
	# sobrescrevi a escrita do buffer para ler a entrada do usuario primeiro
	li $v0, 8
	la $a0, buffer
	li $a1, 100
	syscall 
	
	# Calcular o tamanho real do texto
	la $t1, buffer # ponteiro
	li $t2, 0 # tamanho real
	
	# Escrita no buffer
	#li $v0, 8
	#la $t1, buffer 
	#la $a0, ($t1)
	#li $a1, 100
	#syscall
	
	# Escrita no arquivo
	#li $v0, 15
	#move $a0, $s0
	#la $a1, ($t1)
	#la $a2, 100
	#syscall
	
	# Incrementa o contador e reinicia o loop
	#add $t0, $t0, 1 
	#j writing_loop

len_loop:
	lb $t3, 0($t1)
	beqz $t3, write     # se achar '\0', fim
	beq $t3, 10, write # se achar '\n', fim
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	j len_loop
	
write:
	# Insere a flag inicial
	li $v0, 15
	move $a0, $s0
	la $a1, flag_arquivo
	li $a2, 2
	syscall

	# Escreve somente os t2 bytes
	li $v0, 15
	move $a0, $s0  # descrever o arquivo
	la $a1, buffer # endereço da string
	move $a2, $t2  # esse é o tamanho real
	syscall
	
	# coloca o quebra linha
	li $v0, 15
	move $a0, $s0 # descrevendo arquivo
	la $a1, newline
	li $a2, 1
	syscall
	
	addi $t0, $t0, 1
	j writing_loop
	
show_tasks:
	# --- ABERTURA DO ARQUIVO ---
	li $v0, 13	# abertura do arquivo de tasks
	# $a0 já contém o nome do arquivo
	la $a1, 0
	syscall
	
	move $s0, $v0	# resultado (file descriptor) que é armazenado em $v0 é levado para $a0
	bltz $s0, erro_leitura	# verificação de erro (se o registrador estiver vazio, houve erro)
	
	# --- LEITURA DO ARQUIVO ---
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 2048
	syscall
	# Limpeza do buffer
	la $t1, buffer       # Pega o endereço inicial do buffer
	add $t1, $t1, $v0    # Soma a quantidade de letras lidas ($v0)
	sb $zero, 0($t1)     # Store Byte: Coloca o número 0 (NULL) nessa posição

	# --- IMPRESSÃO DAS TAREFAS ---
	li $v0, 4
	la $a0, mensagem_tarefas
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 4
	
	# Devido à formatação da impressão, precisamos fazer algumas manipulações com o buffer
	la $t1, buffer # registrador temporário, que utilizaremos para percorrer o buffer completo
	
reading_loop:
	lb $t2, 0($t1)	# leitura do caractere atual
	
	beqz $t2, end_print # situação que chegamos ao fim do arquivo (NULL)
	
	li $t3, '1' # task concluída
	beq $t2, $t3, full_print
	
	# Task não foi concluída
	li $v0, 4
	la $a0, prefixo_incompleta
	syscall
	
	j skip_flag
	
full_print:
	# Situação em que a tarefa já foi concluída
	li $v0, 4
	la $a0, prefixo_completa
	syscall
	
skip_flag:
	addi $t1, $t1, 2 # texto = "<flag> + \n => 2 bytes"
	
partial_print_loop:
	# Continuação do full_print ou situação em que já imprimimos o elemento visual
	lb $a0, 0($t1)
	
	li $t4, 10 # 10 é o ASCII da quebra de linha
	beq $a0, $t4, print_end_line 
	
	# Impressão caractere por caractere
	li $v0, 11
	syscall
	
	addi $t1, $t1, 1 # avançamos 1 posição
	j partial_print_loop
	
print_end_line:
	li $v0, 4
    	la $a0, newline
    	syscall
    
    	addi $t1, $t1, 1    # avança o ponteiro para a próxima flag
    	j reading_loop

end_print:
	# Impressão da quebra de linha, antes de fechar o arquivo
	li $v0, 4
	la $a0, newline
	syscall
	
	j close	

choose_task:
	# Mensagem de interface
	li $v0, 4
	la $a0, mensagem_apagar
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	
	# --- LEITURA DA FLAG ---
	li $v0, 5
	syscall
	sb $v0, flag_task
	jr $ra
	
close:
	li $v0, 16 	# syscall de fechamento de arquivo
	move $a0, $s0
	syscall
	jr $ra
	
erro_leitura:
	li $v0, 4
	la $a0, erro_arquivo
	syscall
	li $v0, 4
	la $a0, newline
	syscall
	jr $ra
	
.data
	tarefa:	.asciiz "Tarefa "
	dois_pontos:	.asciiz ": "
	mensagem_tarefas:	.asciiz "Tarefas atuais:"
	mensagem_apagar:	.asciiz "Quais tarefas deseja apagar?"
	prefixo_incompleta:	.asciiz	"[ ] "
	prefixo_completa:	.asciiz "[X] "
	flag_arquivo:	.asciiz "0\n"	# utilizamos para salvar flags de incompleta no arquivo de tasks
	erro_arquivo:	.asciiz	"ERRO: Não foi possível abrir o arquivo "
	erro_flag:	.asciiz "ERRO: Insira uma flag válida para exclusão de uma tarefa.\n"
	newline: .asciiz "\n"
