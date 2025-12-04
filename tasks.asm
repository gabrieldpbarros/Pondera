.data
	buffer:	.space 250

.text
.globl write_tasks

# OBS: preciso corrigir a escrita, ela está escrevendo os caracteres que definimos e adiciona mais (100 - tamanho da frase) espaços
# em branco.
# Além disso, a penúltima frase está sendo repetida na última frase, por algum motivo

# att do zé: Resolvi o erro de escrita e deixei comentado seu codigo que tava errado, basicamente
# você estava jogando 100 bits direto do buffer, agora eu to considerando o tamanho real da entrada


write_tasks:
	# Definimos um contador para a escrita das tasks
	li $t0, 0

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
	beq $t0, 4, close
	
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
	
close:
	li $v0, 16 	# syscall de fechamento de arquivo
	move $a0, $s0
	syscall
	jr $ra
	
.data
newline: .asciiz "\n"
