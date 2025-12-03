.data
filename: .asciiz "posts.txt"

.text
main:
    li $v0, 13          # open
    la $a0, filename    # filename
    li $a1, 0           # read-only
    li $a2, 0           # ignored
    syscall

    move $t0, $v0       # file descriptor
    bltz $t0, erro

    li $v0, 4
    la $a0, ok_msg
    syscall
    j exit

erro:
    li $v0, 4
    la $a0, err_msg
    syscall

exit:
    li $v0, 10
    syscall

.data
ok_msg: .asciiz "OK: abriu o arquivo\n"
err_msg: .asciiz "ERRO: nao abriu o arquivo\n"
