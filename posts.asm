.data
# --- Dados do Arquivo ---
filename:   .asciiz "posts.txt"      # Nome do seu arquivo de dados

# --- Mensagens e Prompts ---
prompt_option: .asciiz "\n-- REDE SOCIAL MIPS --\nEscolha uma opção:\n1: Ler post por ID (Simplificado)\n2: Escrever novo post\n3: Sair\n"
prompt_author: .asciiz "Digite o nome do Autor (max 30 caracteres): "
prompt_text: .asciiz "Digite o Texto do Post (max 200 caracteres): "
msg_opening: .asciiz "Abrindo arquivo...\n"
msg_closing: .asciiz "Fechando arquivo.\n"
msg_new_id: .asciiz "Novo ID calculado: "
msg_write_success: .asciiz "\nNovo post escrito com sucesso!\n"
msg_error_open: .asciiz "ERRO ao abrir o arquivo.\n"
msg_error_read: .asciiz "ERRO ao ler o arquivo.\n"
msg_error_write: .asciiz "ERRO ao escrever no arquivo.\n"
msg_id_not_found: .asciiz "\nAVISO: Nao foi possivel encontrar IDs. Iniciando em 1.\n"
msg_read_data: .asciiz "\nConteudo do arquivo (leitura simples):\n"
separator:  .asciiz "---\n"           # Separador entre posts
image_id:   .asciiz "555\n"           # ID de imagem fixo

# --- Buffers e Variáveis ---
BUFFER_SIZE: .word 256
fileDescriptor: .word 0              # Para armazenar o File Descriptor
buffer:     .space 256               # Buffer para leitura de arquivo
author_buffer: .space 32             # Buffer para o nome do autor (30 + \n + \0)
text_buffer: .space 202              # Buffer para o texto do post (200 + \n + \0)
id_str:     .space 16                # Buffer para armazenar o novo ID em formato string
current_char: .space 1               # Buffer para ler um caractere por vez
last_id:    .word 0                  # Armazena o último ID encontrado como inteiro
new_line:   .asciiz "\n"             # Caractere de nova linha para quebras de texto

.text
.globl main_post

# ----------------------------------------------------------------------
# ROTINAS PRINCIPAIS
# ----------------------------------------------------------------------

main_post:
    # 1. Menu Principal
    li $v0, 4
    la $a0, prompt_option
    syscall

    li $v0, 5        # Leitura de inteiro (opção)
    syscall
    move $t0, $v0    # Armazena a opção

    # 2. Lógica de Escolha
    beq $t0, 1, read_file_simple
    beq $t0, 2, handle_new_post
    beq $t0, 3, exit_program
    j main # Loop de volta se for opção inválida

# ----------------------------------------------------------------------

read_file_simple:
    # Abertura do arquivo (Modo: leitura = 0)
    li $v0, 13       # Syscall 'open'
    la $a0, filename # Nome do arquivo
    li $a1, 0        # Flag para leitura (read-only)
    li $a2, 0
    syscall

    move $s0, $v0    # Salva o File Descriptor (fd) em $s0
    bltz $s0, error_open # Verifica erro

    # Leitura de todo o arquivo (simplificado)
    li $v0, 14       # Syscall 'read'
    move $a0, $s0    # File Descriptor
    la $a1, buffer   # Buffer para armazenar os dados
    lw $a2, BUFFER_SIZE # Tamanho do buffer
    syscall
    
    # Exibe os dados lidos
    li $v0, 4
    la $a0, msg_read_data
    syscall
    
    li $v0, 4
    la $a0, buffer
    syscall
    
    # Fechamento do arquivo
    li $v0, 16       # Syscall 'close'
    move $a0, $s0
    syscall
    
    j main # Retorna ao menu

# ----------------------------------------------------------------------

handle_new_post:
    # 1. Encontra e Calcula o Novo ID
    jal find_last_id
    
    # O último ID está em $s1. O novo ID é ($s1 + 1)
    lw $s1, last_id
    addi $s2, $s1, 1 # $s2 = Novo ID

    # 2. Converte o Novo ID (número) para String (ASCII)
    move $a0, $s2    # Argumento: o inteiro a ser convertido
    la $a1, id_str   # Argumento: buffer de destino para a string
    li $a2, 16       # Argumento: tamanho do buffer
    jal int_to_ascii # Converte (resultado em id_str)

    # 3. Exibe o Novo ID Calculado
    li $v0, 4
    la $a0, msg_new_id
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    # 4. Solicita e Lê Autor
    li $v0, 4
    la $a0, prompt_author
    syscall
    
    li $v0, 8       # Syscall 'read_string'
    la $a0, author_buffer # Endereço do buffer
    li $a1, 32      # Tamanho máximo
    syscall

    # 5. Solicita e Lê Texto do Post
    li $v0, 4
    la $a0, prompt_text
    syscall
    
    li $v0, 8       # Syscall 'read_string'
    la $a0, text_buffer # Endereço do buffer
    li $a1, 202     # Tamanho máximo
    syscall

    # 6. Escreve o novo post no arquivo
    jal write_post_to_file
    
    j main # Retorna ao menu

# ----------------------------------------------------------------------
# FUNÇÕES DE MANIPULAÇÃO DE ARQUIVOS
# ----------------------------------------------------------------------

find_last_id:
    # Inicializa o último ID como 0
    li $s1, 0        # $s1 = last_id_value

    # Abertura do arquivo (Modo: leitura = 0)
    li $v0, 13
    la $a0, filename
    li $a1, 0
    li $a2, 0
    syscall
    
    move $s0, $v0    # $s0 = File Descriptor
    bltz $s0, error_open_file_id # Verifica erro de abertura

    li $t1, 0        # $t1 = Contador de linha (0, 1, 2, 3, 4)
    li $t2, 0        # $t2 = Contador de caracteres do ID
    li $t3, 0        # $t3 = ID atual (em formato numérico)

read_loop:
    # Leitura de 1 caractere por vez
    li $v0, 14       # Syscall 'read'
    move $a0, $s0    # File Descriptor
    la $a1, current_char # Buffer de 1 byte
    li $a2, 1        # Ler 1 byte
    syscall
    
    # $v0 contém o número de bytes lidos (0 = EOF)
    beqz $v0, end_of_file # Se $v0 == 0, fim do arquivo

    # Caractere lido está em $a1 (current_char)
    lb $t4, 0($a1)   # $t4 = caractere atual
    
    # ------------------------------------------
    # Lógica de Controle de Linha/ID
    # ------------------------------------------
    
    # Verifica se é separador "---" para resetar o contador de linha
    li $t5, '-'
    beq $t4, $t5, check_separator 
    j continue_reading
    
check_separator:
    # Para simplicidade, assumimos que se encontrou '-' está perto de '---'
    # No entanto, a lógica completa deveria verificar os 3 hifens e o \n.
    # Aqui, a heurística é mais simples: se for '-', estamos em uma linha de separador
    li $t1, 0        # Reset: Próxima linha é a linha 0 (ID)
    j read_loop

continue_reading:
    
    # 1. Se é a Linha de ID (Linha 0)
    bne $t1, 0, check_newline # Se não for linha 0, pule

    # Verifica se é dígito
    li $t5, '0'
    blt $t4, $t5, check_newline # Se char < '0' (não é dígito)
    li $t5, '9'
    bgt $t4, $t5, check_newline # Se char > '9' (não é dígito)

    # Se é dígito, converte ASCII para inteiro e acumula
    addi $t4, $t4, -48 # Converte caractere ASCII ('0'-'9') para inteiro (0-9)
    mul $t3, $t3, 10   # ID atual = ID atual * 10
    add $t3, $t3, $t4  # ID atual = ID atual + novo dígito
    addi $t2, $t2, 1   # Incrementa contador de dígitos
    j read_loop # Continua lendo
    
    
check_newline:
    # Verifica se é quebra de linha (0xA é '\n')
    li $t5, 0xA
    bne $t4, $t5, read_loop # Se não for '\n', continua lendo

    # Se é quebra de linha ('\n')
    
    # 2. Se a quebra de linha é da Linha de ID (Linha 0)
    beq $t1, 0, save_id_and_reset

    # 3. Para outras linhas, apenas incrementa o contador
    addi $t1, $t1, 1 # Linha 1 -> Linha 2 -> Linha 3 (Texto) -> Linha 4 (Imagem)
    j read_loop

save_id_and_reset:
    # Se encontramos um ID válido (t2 > 0), salvamos ele
    bgt $t2, 0, save_last_id
    j increment_line_and_reset_id # Se t2=0, a linha estava vazia, apenas pula

save_last_id:
    move $s1, $t3    # Salva o ID atual ($t3) como o último ID ($s1)

increment_line_and_reset_id:
    li $t3, 0        # Zera ID atual (numérico)
    li $t2, 0        # Zera contador de dígitos
    addi $t1, $t1, 1 # Linha 0 (ID) -> Linha 1 (Autor)
    j read_loop


end_of_file:
    # Fim do arquivo, fecha e salva o último ID encontrado
    li $v0, 16       # Syscall 'close'
    move $a0, $s0
    syscall
    
    sw $s1, last_id # Salva o último ID no endereço 'last_id'
    
    jr $ra           # Retorna para a função chamadora (handle_new_post)

error_open_file_id:
    # Se não puder abrir o arquivo, assumir ID inicial como 0 e continuar
    li $v0, 4
    la $a0, msg_id_not_found
    syscall
    li $s1, 0
    sw $s1, last_id
    jr $ra

# ----------------------------------------------------------------------

write_post_to_file:
    # Abertura do arquivo (Modo: 9 = O_APPEND | O_WRONLY)
    # 1 (WRONLY) + 8 (APPEND) = 9
    li $v0, 13
    la $a0, filename
    li $a1, 9
    li $a2, 0
    syscall
    
    move $s0, $v0 # $s0 = File Descriptor
    bltz $s0, error_open # Verifica erro

    # 1. Escreve o Separador "---"
    li $v0, 15       # Syscall 'write'
    move $a0, $s0    
    la $a1, separator 
    li $a2, 4        
    syscall
    
    bltz $v0, error_write # Verifica erro

    # 2. Escreve o Novo ID (já convertido para string e com '\n' dentro)
    li $v0, 15
    move $a0, $s0
    la $a1, id_str 
    li $t5, 0 # $t5 = índice
    
calc_id_str_size:
    lb $t6, id_str($t5)
    beqz $t6, write_id_final # Se for '\0', termina a string
    addi $t5, $t5, 1
    j calc_id_str_size

write_id_final:
    move $a2, $t5    # $a2 = Tamanho do ID string (+1 para o '\n')
    syscall
    
    # 3. Escreve o Novo Autor (string lida do usuário)
    li $v0, 15
    move $a0, $s0
    la $a1, author_buffer
    li $a2, 32       # Máximo de bytes a escrever (vai escrever até o \n)
    syscall

    # 4. Escreve o Texto do Post (string lida do usuário)
    li $v0, 15
    move $a0, $s0
    la $a1, text_buffer
    li $a2, 202      # Máximo de bytes a escrever (vai escrever até o \n)
    syscall

    # 5. Escreve o ID da Imagem (fixo)
    li $v0, 15
    move $a0, $s0
    la $a1, image_id
    li $a2, 4
    syscall
    
    # 6. Fechamento do arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    
    # 7. Mensagem de Sucesso
    li $v0, 4
    la $a0, msg_write_success
    syscall
    
    jr $ra

# ----------------------------------------------------------------------
# FUNÇÃO DE CONVERSÃO
# ----------------------------------------------------------------------

# int_to_ascii: Converte inteiro para string ASCII (com '\n' no final)
# Argumentos:
# $a0: Inteiro (new_id)
# $a1: Endereço do buffer de destino (id_str)
# $a2: Tamanho máximo do buffer
int_to_ascii:
    addi $sp, $sp, -4 # Aloca espaço na pilha
    sw $ra, 0($sp)    # Salva $ra
    
    li $t0, 0        # $t0 = contador do buffer (i)
    move $t1, $a0    # $t1 = número (cópia de $a0)
    
    # Caso especial: se o número for 0
    beqz $t1, is_zero

# Converte dígitos em ordem inversa
convert_loop:
    beqz $t1, done_converting # Se $t1 == 0, todos os dígitos foram processados
    li $t2, 10
    div $t1, $t2     # $t1 (quociente), $t2 (resto) - MIPS antigo: div $t1, $t1, 10
    mfhi $t3         # $t3 = resto (o dígito menos significativo)
    mflo $t1         # $t1 = quociente (o novo número)

    addi $t3, $t3, 48 # Converte dígito (0-9) para ASCII ('0'-'9')
    sb $t3, id_str($t0) # Armazena o caractere no buffer (temporariamente invertido)
    addi $t0, $t0, 1 # Incrementa contador
    j convert_loop

is_zero:
    li $t3, '0'
    sb $t3, id_str($t0)
    addi $t0, $t0, 1
    j done_converting
    
done_converting:
    # Adiciona a quebra de linha
    li $t3, 0xA      # 0xA é '\n'
    sb $t3, id_str($t0)
    addi $t0, $t0, 1

    # Adiciona o terminador de string ('\0')
    li $t3, 0
    sb $t3, id_str($t0)
    
    # Reverte a string no buffer (exceto '\n' e '\0')
    li $t1, 0        # $t1 = índice inicial
    addi $t2, $t0, -3 # $t2 = índice final (t0-2 para excluir \n e \0)
    
reverse_loop:
    bge $t1, $t2, reverse_done # Se inicial >= final, reverteu tudo
    
    lb $t3, id_str($t1) # $t3 = caractere inicial
    lb $t4, id_str($t2) # $t4 = caractere final
    
    sb $t4, id_str($t1) # Troca
    sb $t3, id_str($t2) # Troca
    
    addi $t1, $t1, 1 # Inicial++
    addi $t2, $t2, -1 # Final--
    j reverse_loop

reverse_done:
    lw $ra, 0($sp) # Restaura $ra
    addi $sp, $sp, 4 # Desaloca espaço na pilha
    jr $ra           # Retorna

# ----------------------------------------------------------------------
# ROTINAS DE ERRO E SAÍDA
# ----------------------------------------------------------------------

error_open:
    li $v0, 4
    la $a0, msg_error_open
    syscall
    j exit_program

error_write:
    li $v0, 4
    la $a0, msg_error_write
    syscall
    # Tenta fechar o arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    j exit_program

exit_program:
    li $v0, 10 # Syscall 'exit'
    syscall