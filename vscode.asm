.data
Endereço_Base: .word 0x10010000 # Endereço base do bitmap como heap
Tam_Pixel:   .word 4 # Cada pixel é composto por 4 bits
Largura_Display: .word 64 # 32 bits de largura

X_Divisoria: .word 16 # Divisão pra linha cinza

.text
.globl bmp1
bmp1:
    lw $s0, Endereço_Base   # Endereço base do heap
    lw $s1, Tam_Pixel       # Tamanho do pixel
    lw $s2, Largura_Display # Largura da tela
    lw $s3, X_Divisoria     # Divisão da linha cinza
    li $s4, 0               # Contagem pras colunas cinzas
    li $s5, 32              # Limite da tela

# ------------------ Divisão da parte preta e cinza escuro -----------------------------------

# Loop que percorre todas as linhas
Loop_Y:
    bge $s4, $s5, Linhas_Coloridas # Se Y >= 32, começa as linhas coloridas
    li $s6, 0                      # Contador da coluna que reinicia em 0 para cada nova linha

    # Loop que percorre todos os pixels da linha Y
    Loop_X:
        bge $s6, $s2, Fim_Loop_X # Se chegou no fim da linha pula pra próxima

        # Escolhe a cor
        # Se x esta pra direita de x = 8 pinta de cinza, se nao segue e pinta de preto
        bge $s6, $s3, Seleciona_Direita # Se X >= 8, escolhe a direita e pinta de cinza escuro

        # Cor da esquerda: preto
        li $t7, 0x00000000        # Guarda em $t7 a cor preta
        j Calcula_Endereço   # Pula a seleção da cor da direita

        Seleciona_Direita: # Guarda em t7 o cinza
        li $t7, 0x00202020

        # Endereço
        Calcula_Endereço: # Offset = (Y * Largura) + X
        mul $t0, $s4, $s2
        add $t0, $t0, $s6

        # Endereço_Final = endereço base + offset * tamanho do pixel
        mul $t0, $t0, $s1
        add $t1, $s0, $t0

        # 4. DESENHO (STORE WORD)
        sw $t7, 0($t1)          # cor em $t7, 0(endereço final)

        # Incrementa X e continua o loop interno
        addi $s6, $s6, 1 # X == 1
        j Loop_X         # Retorna pro começo do loop interno
    
    	Fim_Loop_X:      # Incrementa Y e continua o loop externo
    	addi $s4, $s4, 1 # Y += 1
    	j Loop_Y         # Retorna pro começo do loop externo
    
# ------------------ Divisão da parte preta e cinza escuro -------------------------

# ------------------ Linhas coloridas ----------------------------------------------

Linhas_Coloridas: 
    li $a0, 1              # Y_ALTURA = 1
    li $a1, 18              # X_INICIO = 9
    li $a2, 22             # X_FIM = 11
    li $a3, 0x993399       # Cor roxa
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 1              # Y_ALTURA = 1
    li $a1, 24             # X_INICIO = 13
    li $a2, 28             # X_FIM = 15
    li $a3, 0x00FFA500     # Cor laranja
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 5              # Y_ALTURA = 5
    li $a1, 18              # X_INICIO = 9
    li $a2, 20             # X_FIM = 10
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 5              # Y_ALTURA = 5
    li $a1, 22             # X_INICIO = 12
    li $a2, 24             # X_FIM = 13
    li $a3, 0x00FFFF00     # Cor amarela
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 7              # Y_ALTURA = 7
    li $a1, 20             # X_INICIO = 10
    li $a2, 22             # X_FIM = 11
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 7              # Y_ALTURA = 7
    li $a1, 24             # X_INICIO = 13
    li $a2, 24             # X_FIM = 13
    li $a3, 0x007070FF     # Cor azul claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 9              # Y_ALTURA = 9
    li $a1, 20             # X_INICIO = 10
    li $a2, 22             # X_FIM = 11
    li $a3, 0x00993399     # Cor roxa
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 9              # Y_ALTURA = 9
    li $a1, 24             # X_INICIO = 13
    li $a2, 24             # X_FIM = 13
    li $a3, 0x00FFFF00     # Cor amarela
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 11             # Y_ALTURA = 11
    li $a1, 22             # X_INICIO = 11
    li $a2, 30             # X_FIM = 14
    li $a3, 0x00FFFF00     # Cor amarela
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 13             # Y_ALTURA = 13
    li $a1, 22             # X_INICIO = 11
    li $a2, 30             # X_FIM = 14
    li $a3, 0x005353ec     # Cor azul escura
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 15             # Y_ALTURA = 15
    li $a1, 22             # X_INICIO = 13
    li $a2, 24             # X_FIM = 14
    li $a3, 0x993399       # Cor roxa
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 15             # Y_ALTURA = 15
    li $a1, 26             # X_INICIO = 16
    li $a2, 27             # X_FIM = 16
    li $a3, 0x005353ec     # Cor azul escura
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 24             # X_INICIO = 14
    li $a2, 26             # X_FIM = 15
    li $a3, 0x005353ec     # Cor azul escura
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 28             # X_INICIO = 17
    li $a2, 28             # X_FIM = 17
    li $a3, 0x005353ec     # Cor azul escura
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 29             # X_INICIO = 18
    li $a2, 29             # X_FIM = 18
    li $a3, 0x00FFFFFF     # Cor branca
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 30             # X_INICIO = 19
    li $a2, 30             # X_FIM = 19
    li $a3, 0x0000ac20     # Cor verde claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 19             # Y_ALTURA = 19
    li $a1, 24             # X_INICIO = 15
    li $a2, 28             # X_FIM = 18
    li $a3, 0x00FFFF00     # Cor amarela
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 21             # Y_ALTURA = 21
    li $a1, 24             # X_INICIO = 14
    li $a2, 24             # X_FIM = 14
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 23             # Y_ALTURA = 23
    li $a1, 22             # X_INICIO = 13
    li $a2, 22             # X_FIM = 13
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 25             # Y_ALTURA = 25
    li $a1, 20             # X_INICIO = 10
    li $a2, 20             # X_FIM = 10
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 27             # Y_ALTURA = 27
    li $a1, 20             # X_INICIO = 10
    li $a2, 23             # X_FIM = 11
    li $a3, 0x00993399     # Cor roxa
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 27             # Y_ALTURA = 27
    li $a1, 25             # X_INICIO = 13
    li $a2, 25             # X_FIM = 13
    li $a3, 0x0000ac20     # Cor verde claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 27             # Y_ALTURA = 27
    li $a1, 26             # X_INICIO = 14
    li $a2, 26             # X_FIM = 14
    li $a3, 0x00FFFFFF     # Cor branca
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 29             # Y_ALTURA = 29
    li $a1, 18             # X_INICIO = 9
    li $a2, 18             # X_FIM = 9
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 0              # Y_ALTURA = 0
    li $a1, 60             # X_INICIO = 29
    li $a2, 60             # X_FIM = 29
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 0              # Y_ALTURA = 0
    li $a1, 58             # X_INICIO = 29
    li $a2, 58             # X_FIM = 29
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 0              # Y_ALTURA = 0
    li $a1, 62             # X_INICIO = 30
    li $a2, 63             # X_FIM = 31
    li $a3, 0x00FF0000     # Cor vermelha
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 3              # Y_ALTURA = 3
    li $a1, 1              # X_INICIO = 1
    li $a2, 12              # X_FIM = 4
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 5              # Y_ALTURA = 5
    li $a1, 1              # X_INICIO = 1
    li $a2, 2              # X_FIM = 1
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 5              # Y_ALTURA = 5
    li $a1, 3              # X_INICIO = 2
    li $a2, 5              # X_FIM = 2
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 7              # Y_ALTURA = 7
    li $a1, 1              # X_INICIO = 1
    li $a2, 10              # X_FIM = 5
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 9              # Y_ALTURA = 9
    li $a1, 1              # X_INICIO = 1
    li $a2, 2              # X_FIM = 1
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 9              # Y_ALTURA = 9
    li $a1, 3              # X_INICIO = 2
    li $a2, 5              # X_FIM = 2
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 11             # Y_ALTURA = 11
    li $a1, 1              # X_INICIO = 1
    li $a2, 13              # X_FIM = 3
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 13             # Y_ALTURA = 13
    li $a1, 1              # X_INICIO = 1
    li $a2, 1              # X_FIM = 1
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 13             # Y_ALTURA = 13
    li $a1, 2              # X_INICIO = 2
    li $a2, 5              # X_FIM = 3
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 15             # Y_ALTURA = 15
    li $a1, 1              # X_INICIO = 1
    li $a2, 4              # X_FIM = 4
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 1              # X_INICIO = 1
    li $a2, 2              # X_FIM = 1
    li $a3, 0x005353ec     # Cor azul escuro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 3              # X_INICIO = 2
    li $a2, 6              # X_FIM = 2
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    Desenha_Linha_Horizontal:
    # $a1 (X_INICIO) é o contador do loop.
    # $a2 (X_FIM) é o limite do loop.
    
Loop_Desenho:
    # Se x > X_FIM retorna
    bgt $a1, $a2, Finaliza_Desenho 

    # Endereço
    # Offset em unidades = (Y_fixo * largura) + X_atual
    # Y_fixo = $a0, largura = $s2, X_atual = $a1
    mul $t0, $a0, $s2   
    add $t0, $t0, $a1      

    # Endereço_Final = BaseAddress ($s0) + Offset ($t0) * tamanho do pixel ($s1)
    mul $t0, $t0, $s1   
    add $t1, $s0, $t0    

    # Desenho em si
    sw $a3, 0($t1)          # sw Cor ($a3), 0(Endereço Final)

    # Incrementa o x e retorna pro loop
    addi $a1, $a1, 1        # X_atual += 1
    j Loop_Desenho

Finaliza_Desenho:
    jr $ra
    
# ------------------ Linhas coloridas ----------------------------------------------

Fim_Programa:
    li $v0, 10
    syscall
