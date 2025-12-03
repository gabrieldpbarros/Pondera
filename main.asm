.data
filename: .asciiz "posts.txt"

.text
.globl main
main:
    la $a0, filename
    jal load_posts

    li $v0, 10
    syscall
