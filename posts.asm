.data
    posts_data: .asciiz "0\njoserequena\nHoje comecei o projeto de rede social em Assembly MIPS!\nimg_001\n---\n1\nmaria\ntrabalhando no projeto da faculdade :)\nimg_002\n---\n2\nadmin\nBem-vindos à rede social feita em Assembly!\nimg_003\n---\n"
    prompt_id:  .asciiz "Digite o ID do post que deseja buscar: "
    not_found:  .asciiz "\nPost não encontrado.\n"
    newline:    .asciiz "\n"

.text
.globl main_post

main_post:
    # 1. Obter o ID do usuário
    li $v0, 4              # syscall para printar string
    la $a0, prompt_id      # carrega o prompt
    syscall

    li $v0, 5              # syscall para ler inteiro
    syscall
    move $s0, $v0          # $s0 = ID desejado (Target ID)

    # 2. Inicializar ponteiro da string
    la $s1, posts_data     # $s1 = ponteiro para a string posts_data

loop_posts:
    # Verifica o final da string (\0)
    lb $t0, 0($s1)
    beq $t0, $zero, post_not_found # Se byte = 0, fim da lista

    # 3. Ler o ID do post atual (primeira linha)
    jal read_line          # Lê a linha, retorna endereço em $a0

    # 4. Comparar ID (string para int)
    jal atoi               # Converte string ID para inteiro, $v0 = valor int
    move $t1, $v0          # $t1 = ID do post atual (Current ID)

    beq $t1, $s0, print_post # Se ID atual == ID desejado, ir para impressão

    # 5. Se os IDs não forem iguais, pular para o próximo post
    # Precisamos pular as 4 linhas restantes (autor, texto, img_id, ---)
    li $t2, 4              # $t2 = Contador para as 4 linhas restantes
    j skip_post_fields

# --- Rotina para Pular os Campos do Post ---
skip_post_fields:
    beq $t2, $zero, loop_posts  # Pular 4 campos feitos, voltar ao loop principal
    subi $t2, $t2, 1
    
    jal read_line          # Simplesmente avança o ponteiro $s1
    
    j skip_post_fields

# --- Rotina para Imprimir o Post Encontrado ---
print_post:
    li $t2, 4              # $t2 = Contador para as 4 linhas (autor, texto, img_id, ---)
print_fields_loop:
    beq $t2, $zero, exit_program # Imprimiu tudo
    subi $t2, $t2, 1
    
    jal read_line          # $a0 = endereço da linha lida (já com \0 no final)
    
    li $v0, 4              # syscall para imprimir a string
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall                # Imprime uma nova linha visual
    
    j print_fields_loop

# --- Rotina de Linha Não Encontrada ---
post_not_found:
    li $v0, 4
    la $a0, not_found
    syscall
    j exit_program

# --- Rotina: Ler Linha e Atualizar Ponteiro ($s1) ---
# Substitui o \n por \0 para permitir impressão isolada
# Argumentos: $s1 = Ponteiro atual
# Retorna: $a0 = Endereço da linha lida
#          $s1 = Ponteiro atualizado para a PRÓXIMA linha
read_line:
    move $a0, $s1          # $a0 marca o início da string para retorno
    
read_char_loop:
    lb $t3, 0($s1)         # Carrega o caractere
    beq $t3, $zero, read_eos # Se for \0 (fim total da string data), retorna
    
    li $t4, 10             # Código ASCII para Line Feed (\n)
    beq $t3, $t4, replace_nl # Encontrou \n, vai substituir
    
    addi $s1, $s1, 1       # Avança para próximo char
    j read_char_loop

replace_nl:
    sb $zero, 0($s1)       # Substitui \n por \0 (IMPORTANTE PARA O SYSCALL 4)
    addi $s1, $s1, 1       # Avança $s1 para o início da próxima linha
    jr $ra                 # Retorna

read_eos:
    jr $ra                 # Retorna sem avançar (já está no fim)

# --- Rotina: Conversão de ASCII para Inteiro (atoi) ---
# Argumentos: $a0 = Endereço da string (o ID)
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

# --- Fim do Programa ---
exit_program:
    li $v0, 10
    syscall