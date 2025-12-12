.data
    posts_data: .asciiz "0\nJosé Requena\nFinalmente acabei meu projeto da bolsa de extensão, vejam o código!\n1\n---\n1\nEnzo Vidal\nBATI MEU RECORDE DE 3X3, 7.1 É INSANO, a solve completa esta no youtube\n2\n---\n2\nGabriel Delgado\nFiz um quadrinho do meu jogo favorito, mine é inspiração pra arte\n3\n---\n"
    prompt_id:  .asciiz "Digite o ID do post que deseja buscar: "
    not_found:  .asciiz "\nPost não encontrado.\n"
    newline:    .asciiz "\n"
    temp_buffer: .space 256 # Buffer temporário para copiar as linhas

.text
.globl main_post

main_post:
# Mesma coisa de salvar os registradores importantes antes pra não quebrar o pc
addi $sp, $sp, -16 
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    move $s0, $s7          # $s0 = ID desejado (Target ID)

    # 2. Inicializar ponteiro da string
    la $s1, posts_data     # $s1 = ponteiro para a string posts_data

loop_posts:
    # 1. Ler o ID do post atual (primeira linha)
    jal read_line           # Retorna $a0 = endereço do buffer (com \0)

    # Verifica o final da string (\0) no buffer
    lb $t0, 0($a0)
    beq $t0, $zero, post_not_found # Se buffer estiver vazio (fim da lista)

    # 2. Comparar ID (string para int)
    jal atoi                        # Converte string ID para inteiro, $v0 = valor int
    move $t1, $v0                   # $t1 = ID do post atual (Current ID)

    beq $t1, $s0, print_post        # Se ID atual == ID desejado, ir para impressão

    # 3. Se os IDs não forem iguais, pular para o próximo post
    li $t2, 4                       # Pular Autor, Texto, Img ID, 
    j skip_post_fields

# Rotina para Pular os Campos do Post 
skip_post_fields:
    beq $t2, $zero, loop_posts  # Pular 4 campos feitos, voltar ao loop principal
    subi $t2, $t2, 1
    
    jal read_line          # Simplesmente avança o ponteiro $s1
    
    j skip_post_fields

# Rotina para Imprimir o Post Encontrado
print_post:
    li $t2, 4              # $t2 = Contador para as 4 linhas (autor, texto, img_id
print_fields_loop:
    beq $t2, $zero, fim_main_post_success # Se deu sucesso
    subi $t2, $t2, 1
    
    jal read_line          # $a0 = endereço da linha lida (já com \0 no final)
    
    li $v0, 4              # syscall para imprimir a string
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall                # Imprime uma nova linha visual
    
    j print_fields_loop

# Rotina de Linha Não Encontrada 
post_not_found:
    li $v0, 4
    la $a0, not_found
    syscall
    j exit_program

# Rotina: Ler Linha e Atualizar Ponteiro ($s1) 
# Substitui o \n por \0 para permitir impressão isolada
# Entrada: $s1 = Ponteiro atual
# Retorna: $a0 = Endereço da linha lida
#          $s1 = Ponteiro atualizado para a proxima linha
read_line:
    # Salva os registradores
    addi $sp, $sp, -8
    sw $s2, 0($sp)
    sw $s3, 4($sp)

    la $s2, temp_buffer             # $s2 é o endereço de destino (buffer)
    move $a0, $s2                   # $a0 = endereço de retorno (buffer)
    
read_char_loop_copy:
    lb $t3, 0($s1)                  # Carrega o caractere da fonte ($s1)
    
    beq $t3, $zero, read_eos_copy   # Fim da string global
    
    li $t4, 10                      # Código ASCII para Line Feed (\n)
    beq $t3, $t4, finish_copy       # Encontrou \n

    # Copia o caractere
    sb $t3, 0($s2)           
    addi $s1, $s1, 1                # Avança ponteiro fonte
    addi $s2, $s2, 1                # Avança ponteiro destino
    j read_char_loop_copy

finish_copy:
    # 1. Termina a string no buffer com \0
    sb $zero, 0($s2)         
    
    # 2. Avança $s1 além do \n (o \n original permanece na string global!)
    addi $s1, $s1, 1         
    
    lw $s3, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 8
    
    jr $ra                   
    
read_eos_copy:
    # 1. Termina a string no buffer com \0 (para garantir que seja imprimível)
    sb $zero, 0($s2)
    
    lw $s3, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 8

    jr $ra

# Rotina: Conversão de ASCII para Inteiro (atoi)
# Entrada : $a0 = Endereço da string (o ID)
# Retorna: $v0 = Valor inteiro
atoi:
    li $v0, 0              # $v0 = Resultado
    
atoi_loop:
    lb $t0, 0($a0)         # Carrega o byte
    beq $t0, $zero, atoi_end # Se byte = 0 (final da string), sair
    
    # Verifica se é dígito
    li $t1, 48             # '0'
    blt $t0, $t1, atoi_end
    li $t1, 57             # '9'
    bgt $t0, $t1, atoi_end
    
    subi $t0, $t0, 48      # Converte ASCII para int
    
    mul $v0, $v0, 10       # v0 = v0 * 10
    add $v0, $v0, $t0      # v0 = v0 + digito
    
    addi $a0, $a0, 1       # Próximo char
    j atoi_loop
    
atoi_end:
    jr $ra

# Fim do Programa
exit_program:
   # Restaura os registradores pra não quebrar o pc
    lw $s1, 8($sp)    
    lw $s0, 4($sp)    
    lw $ra, 0($sp)   
    addi $sp, $sp, 12 # Libera a pilha

    jr $ra # Retorna para o next_post (ou main_loop)
fim_main_post_success:
# Restaura os registradores pra não quebrar o pc
    lw $s1, 8($sp)   
    lw $s0, 4($sp)    
    lw $ra, 0($sp)   
    addi $sp, $sp, 12 # Libera a pilha 

    jr $ra # Retorna para o next_post (ou main_loop)
    jr $ra # Retorna para o chamador (main)
