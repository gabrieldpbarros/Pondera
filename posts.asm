.data
buffer: .space 512

.text
.globl load_posts

load_posts:
    # abrir arquivo
    li $v0, 13
    move $a0, $a0      # filename recebido do main
    li $a1, 0          # flags = leitura
    li $a2, 0
    syscall
    move $s0, $v0      # file descriptor

    bltz $s0, error     # se deu erro, fd < 0

    # ler arquivo
    li $v0, 14
    move $a0, $s0       # fd
    la $a1, buffer      # buffer
    li $a2, 512         # qnt bytes
    syscall

    # imprimir conteúdo
    la $a0, buffer
    li $v0, 4
    syscall

    jr $ra

error:
    la $a0, errMsg
    li $v0, 4
    syscall
    jr $ra

.data
errMsg: .asciiz "Erro ao abrir posts.txt\n"
