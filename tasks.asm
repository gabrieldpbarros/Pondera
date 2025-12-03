.data
	buffer:	.space 100

.text
.globl write_tasks

# OBS: preciso corrigir a escrita, ela está escrevendo os caracteres que definimos e adiciona mais (100 - tamanho da frase) espaços
# em branco.
# Além disso, a penúltima frase está sendo repetida na última frase, por algum motivo

write_tasks:
	# Definimos um contador para a escrita das tasks
	li $t0, 0

	# Abre o arquivo
	li $v0, 13
	move $a0, $a0
	li $a1, 1 	# write-only (sem append)
	syscall
	move $s0, $v0 	# salvamos o file descriptor
	
writing_loop:
	beq $t0, 4, close
	
	# Escrita no buffer
	li $v0, 8
	la $t1, buffer
	la $a0, ($t1)
	li $a1, 100
	syscall
	
	# Escrita no arquivo
	li $v0, 15
	move $a0, $s0
	la $a1, ($t1)
	la $a2, 100
	syscall
	
	# Incrementa o contador e reinicia o loop
	add $t0, $t0, 1 
	j writing_loop
	
close:
	li $v0, 16 	# syscall de fechamento de arquivo
	move $a0, $s0
	syscall