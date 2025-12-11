.data
Nome_arquivo1:       .asciiz "comentarios1.txt"
Nome_arquivo2:       .asciiz "comentarios2.txt"
Nome_arquivo3:       .asciiz "comentarios3.txt"
Opcoes:    .asciiz "Escolha a operacao:\n1 - Ver Comentarios\n2 - Adicionar Comentario\n3 - Sair\n"
Mensagem_adicionar_comentario:     .asciiz "Digite o seu comentário: (max 255 chars):\n"
Quebra_comentarios:  .asciiz "--- Comentarios ---\n"
Confirmacao_adicao_comentario:    .asciiz "\nComentario adicionado!\n"
Numero_invalido:  .asciiz "\n Opcao invalida. Digite 1, 2 ou 3.\n"
Texto_erro_leitura:     .asciiz "\nErro: Falha na leitura\n"
Mensagem_erro_tamanho:       .asciiz "\nO comentário deve ter pelo menos 15 caracteres, faça um comentário construtivo!\n"
Buffer_arquivo:    .space 4096   # Buffer para guardar o conteúdo do arquivo (Não tem como adicionar, então faz uma copia e coloca o novo comentario no final)
Buffer_entrada:   .space 256     # Buffer para a string do comentario lido do terminal

.text
.globl comentarios

# Registradores usados:
# $s0: File Descriptor (FD)
# $s1: Opcao do usuario (1, 2 ou 3)
# $s2: Comprimento da string de comentario
# $s3: Comprimento do conteudo original do arquivo (necessario pra adicionar)

comentarios: # 1 - Usuario digita o que quer fazer: 1: ler comentarios, 2: add comentario, 3: sair do programa
    # Salva os registradores importantes pra que os jal não quebrem o program counter
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    # Imprime o menu
    jal Seleciona_Nome_Arquivo
    move $s4, $v0       # $s4 agora armazena o endereço do nome do arquivo (comentarios1/2/3)

menu_comentarios:
    # Imprime o menu
    li $v0, 4
    la $a0, Opcoes
    syscall

    # Leitura da opção do usuário
    li $v0, 5
    syscall
    
    move $s1, $v0
    
# 2 - Definicao do que fazer baseado na escolha

    # Se $s1 = 1, mostra os comentarios, se $s1 = 2, add comentario, $s3 retorna pro loop do main
    li $t0, 1
    beq $s1, $t0, Exibe_Arquivo
    
    li $t0, 2
    beq $s1, $t0, Add_no_Arquivo
    
    li $t0, 3
    beq $s1, $t0, Fim_Comentarios
    
    # Se não for 1, 2 ou 3:
    j Entrada_invalida

Seleciona_Nome_Arquivo:
    # Salva $ra e $s7 pra não quebrar o pc
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s7, 4($sp) 
    
    # Usa $s7 (ID) para decidir qual arquivo abrir
    li $t0, 0
    beq $s7, $t0, Seleciona_Arq_1
    
    li $t0, 1
    beq $s7, $t0, Seleciona_Arq_2
    
    li $t0, 2
    beq $s7, $t0, Seleciona_Arq_3
    
    # Se o ID for maior que 2 chama o arquivo 1 pra nao dar problema
    j Seleciona_Arq_1 
    
Seleciona_Arq_1:
    la $v0, Nome_arquivo1
    j Retorna_Selecao
    
Seleciona_Arq_2:
    la $v0, Nome_arquivo2
    j Retorna_Selecao
    
Seleciona_Arq_3:
    la $v0, Nome_arquivo3
    j Retorna_Selecao
    
Retorna_Selecao:
    # Restaura $s7 e $ra
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# Opcao 1: Mostrar comentarios
Exibe_Arquivo:
    
    # 1.1 Abrir arquivo no modo só leitura ($a1 = 0)
    li $v0, 13          # syscall 13: Abre o arquivo
    move $a0, $s4
    li $a1, 0           # Só leitura
    li $a2, 0
    syscall
    
    move $s0, $v0       # $s0 = File Descriptor
    
    # 1.2 Lê todo o conteúdo do arquivo para o Buffer_arquivo
    li $v0, 14          # syscall 14: Read from File
    move $a0, $s0       # $a0 = File Descriptor
    la $a1, Buffer_arquivo # $a1 = Endereço do buffer de destino
    li $a2, 4096        # $a2 = Tamanho máximo a ler
    syscall
    
    move $s3, $v0       # $s3 = Comprimento da leitura. Se < 0, erro de leitura.
    bltz $s3, Erro_leitura
    
    # 1.3 Fecha o arquivo
    li $v0, 16          # syscall 16: Fecha o arquivo
    move $a0, $s0
    syscall
    
    # 1.4 Prepara buffer para impressão (garantir \0 no final)
    la $t0, Buffer_arquivo
    add $t0, $t0, $s3   # Move o ponteiro para o final do conteúdo lido
    sb $zero, 0($t0)    # Adiciona o terminador NULL (\0)
    
    # 1.5 Imprime no terminal
    li $v0, 4
    la $a0, Quebra_comentarios # Cabeçalho de quebra
    syscall
    
    li $v0, 4
    la $a0, Buffer_arquivo   # Conteúdo
    syscall
    
    li $v0, 4
    la $a0, Quebra_comentarios # Cabeçalho de quebra
    syscall
    
    j menu_comentarios       # Volta pro loop da opcao do usuario

# 2: Adiciona comentario
Add_no_Arquivo:
    
    # 2.1 Pede pra digitar e lê a string
    li $v0, 4           # Printar msg
    la $a0, Mensagem_adicionar_comentario
    syscall

    li $v0, 8           # syscall 8: leitura de string
    la $a0, Buffer_entrada
    li $a1, 256         
    syscall
    
    # 2.2 Calcular o comprimento da string lida em $s2
    la $t0, Buffer_entrada 
    li $s2, 0            # $s2 = Comprimento da nova string
    
Loop_tamanho:
    lb $t2, 0($t0)       
    beqz $t2, Finaliza_tamanho  
    addi $s2, $s2, 1     
    addi $t0, $t0, 1     
    j Loop_tamanho
    
Finaliza_tamanho:
    
    li $t0, 15          # Limite mínimo de 15 caracteres
    blt $s2, $t0, Erro_tamanho # Se $s2 < 15, pula para o erro e tenta novamente.
    
    # 2.3 Leitura do que tem no arquivo pra copiar
    li $v0, 13          
    move $a0, $s4
    li $a1, 0           # Só leitura
    li $a2, 0
    syscall
    
    move $s0, $v0       
    
    li $v0, 14          
    move $a0, $s0       
    la $a1, Buffer_arquivo 
    li $a2, 4096        
    syscall
    
    move $s3, $v0       # $s3 = Comprimento do conteúdo original
    
    li $v0, 16          # Fechar arquivo depois de ler
    move $a0, $s0
    syscall
    
    # 2.4 Concatena o que tem no arquivo com o comentario digitado
    # Copia a nova string (Buffer_entrada) para o final do conteúdo antigo (Buffer_arquivo + $s3)
    
    la $t0, Buffer_arquivo  # $t0: Ponteiro de destino
    add $t0, $t0, $s3    # Move $t0 para o fim do conteúdo antigo
    
    la $t1, Buffer_entrada # $t1: Ponteiro de origem
    li $t2, 0            # Contador de bytes copiados
    
Loop_copia:
    bge $t2, $s2, Finaliza_copia # Se contador >= Comprimento da nova string, termina
    
    lb $t3, 0($t1)       
    sb $t3, 0($t0)       
    
    addi $t0, $t0, 1     
    addi $t1, $t1, 1     
    addi $t2, $t2, 1     
    j Loop_copia
    
Finaliza_copia:
    # Atualiza o comprimento total a ser escrito
    add $s3, $s3, $s2   # Comprimento Total = (Antigo) + (Novo)

    # 2.5 reescreve o arquivo com a concatenacao
    li $v0, 13
    move $a0, $s4
    li $a1, 1           # Só escrita
    li $a2, 0
    syscall
    
    move $s0, $v0       
    
    li $v0, 15          # syscall 15: Escrita em arquivo
    move $a0, $s0       
    la $a1, Buffer_arquivo # Endereço do conteúdo combinado
    move $a2, $s3       # Comprimento total
    syscall
    
    li $v0, 16          # Fecha o arquivo
    move $a0, $s0
    syscall
    
    # Mensagem de sucesso
    li $v0, 4
    la $a0, Confirmacao_adicao_comentario
    syscall
    
    j menu_comentarios

# Erro e saidas

Erro_tamanho: # Exibe a mensagem de erro e retorna para Add_no_Arquivo pra tentar novamente
    li $v0, 4
    la $a0, Mensagem_erro_tamanho
    syscall
    j Add_no_Arquivo

Entrada_invalida:
    li $v0, 4
    la $a0, Numero_invalido
    syscall
    j comentarios

Erro_leitura:
    li $v0, 4
    la $a0, Texto_erro_leitura
    syscall
    # Tenta fechar o descritor
    li $v0, 16
    move $a0, $s0
    syscall
    j Finaliza_Programa
    
Fim_Comentarios: # Salto para sair e retornar ao main_loop
    # Restaura os registradores pra não quebrar o programa
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    
    jr $ra # Retorna para o main_loop
    
Finaliza_Programa:
    li $v0, 10          # syscall 10: Finaliza
    syscall