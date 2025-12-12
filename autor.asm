.data
Arquivo_autor1:       .asciiz "autor1.txt"
Arquivo_autor2:       .asciiz "autor2.txt"
Arquivo_autor3:       .asciiz "autor3.txt"
Quebra_autor:  .asciiz "\n--- Autor e bio ---\n"
Texto_erro_leitura:     .asciiz "\nErro: Falha na leitura\n"
Buffer_arquivo_autor:    .space 4096   # Buffer para guardar o conteúdo do arquivo

.text
.globl ver_autor

# Registradores usados:
# $s0: File Descriptor (FD)
# $s3: Comprimento do conteudo original do arquivo

ver_autor:
    # Salva os registradores importantes pra que os jal não quebrem o program counter
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    jal Seleciona_Nome_Arquivo_autor
    move $s4, $v0       # $s4 agora armazena o endereço do nome do arquivo (autor1/2/3)

Continua_autor:
    jal Printa_autorebio
    jal Fim_ver_autor
    
Seleciona_Nome_Arquivo_autor:
    # Salva $ra e $s7 pra não quebrar o pc
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s7, 4($sp) 
    
    # Usa $s7 (ID) para decidir qual arquivo abrir
    li $t0, 0
    beq $s7, $t0, Seleciona_Arq_autor1
    
    li $t0, 1
    beq $s7, $t0, Seleciona_Arq_autor2
    
    li $t0, 2
    beq $s7, $t0, Seleciona_Arq_autor3
    
    # Se o ID for maior que 2 chama o arquivo 1 pra nao dar problema
    j Seleciona_Arq_autor1 
    
Seleciona_Arq_autor1:
    la $v0, Arquivo_autor1
    j Restaura
    
Seleciona_Arq_autor2:
    la $v0, Arquivo_autor2
    j Restaura
    
Seleciona_Arq_autor3:
    la $v0, Arquivo_autor3
    j Restaura
    
Restaura:
    # Restaura $s7 e $ra
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# Opcao 1: Mostrar o autor e a bio
Printa_autorebio:
    # 1.1 Abrir arquivo no modo só leitura ($a1 = 0)
    li $v0, 13           # syscall 13: Abre o arquivo
    move $a0, $s4        # $a0 = Nome do arquivo (Endereço em $s4)
    li $a1, 0            # Só leitura
    li $a2, 0
    syscall
    
    move $s0, $v0        # $s0 = File Descriptor
    
    # Se $s0 for negativo, a abertura falhou.
    bltz $s0, Erro_abertura 
    # 1.2 Lê todo o conteúdo do arquivo para o Buffer_arquivo_autor
    li $v0, 14           # syscall 14: Read from File
    move $a0, $s0        # $a0 = File Descriptor (agora sabemos que é válido)
    la $a1, Buffer_arquivo_autor 
    li $a2, 4096         
    syscall
    
    move $s3, $v0        # $s3 = Comprimento da leitura.
    
    # Se a leitura falhar (ou ler 0 bytes), vá para Erro_leitura
    bltz $s3, Erro_leitura
    
    # 1.3 Fecha o arquivo
    li $v0, 16           # syscall 16: Fecha o arquivo
    move $a0, $s0
    syscall
    
    # 1.4 Prepara buffer para impressão (garantir \0 no final)
    la $t0, Buffer_arquivo_autor
    add $t0, $t0, $s3    
    sb $zero, 0($t0)     # Adiciona o terminador NULL (\0)
    
    # 1.5 Imprime no terminal
    li $v0, 4
    la $a0, Quebra_autor 
    syscall
    
    li $v0, 4
    la $a0, Buffer_arquivo_autor # Conteúdo
    syscall
    
    li $v0, 4
    la $a0, Quebra_autor 
    syscall
    
    j Fim_ver_autor

Erro_leitura:
    li $v0, 4
    la $a0, Texto_erro_leitura
    syscall
    # Tenta fechar o descritor
    li $v0, 16
    move $a0, $s0
    syscall
    j Finaliza_Programa
    
Fim_ver_autor: # Salto para sair e retornar ao main_loop
    # Restaura os registradores pra não quebrar o programa
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    
    jr $ra # Retorna para o main_loop
   
Erro_abertura:
    # Não precisa fechar, pois o descritor nunca foi aberto com sucesso (FD é negativo)
    # Apenas imprime a mensagem de erro e finalize
    li $v0, 4
    la $a0, Texto_erro_leitura
    syscall
    j Fim_ver_autor 
 
Finaliza_Programa:
    li $v0, 10          # syscall 10: Finaliza
    syscall
