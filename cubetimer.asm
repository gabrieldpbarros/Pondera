.data
Endereço_Base: .word 0x10040000 # Endereço base do bitmap como heap
Tam_Pixel:   .word 4 # Cada pixel é composto por 4 bits
Largura_Display: .word 32 # 32 bits de largura

.text
.globl bmp2
bmp2:
    lw $s0, Endereço_Base   # Endereço base do heap
    lw $s1, Tam_Pixel       # Tamanho do pixel
    lw $s2, Largura_Display # Largura da tela
    li $s4, 0               # Contagem pras colunas cinzas
    li $s5, 32              # Limite da tela

# ------------------ Pinta todo o quadro com dark blue -----------------------------------
LOOP_Y_PREENCHIMENTO:
    bge $s4, $s5, Linhas_Coloridas # Se Y >= 32, segue para as linhas
    li $s6, 0                      # $s6 = X (Contador da Coluna) - Reinicia em 0
    
    # LOOP_INTERNO_X (Percorre todos os pixels da linha Y)
    LOOP_X_PREENCHIMENTO:
        bge $s6, $s2, FIM_LOOP_X_PREENCHIMENTO # Se X >= 32 ($s2), termina a linha

        # 2. CÁLCULO DO ENDEREÇO DE MEMÓRIA (Fórmula Chave)
        
        # Offset = (Y * Largura) + X
        mul $t0, $s4, $s2       # $t0 = Y * Largura
        add $t0, $t0, $s6       # $t0 = (Y * Largura) + X (Offset em Unidades)

        # Endereço_Final = BaseAddress + Offset * Tamanho do Pixel
        mul $t0, $t0, $s1       # $t0 = Offset * Tamanho do Pixel (Offset em Bytes)
        add $t1, $s0, $t0       # $t1 = Endereço Base + Offset em Bytes

        # 3. DESENHO (STORE WORD)
        li $t8, 0x00005168
        sw $t8, 0($t1)          # sw Cor ($t8), 0(Endereco_Final)

        # Incrementa X e continua o Loop Interno
        addi $s6, $s6, 1        # X = X + 1
        j LOOP_X_PREENCHIMENTO
    
    FIM_LOOP_X_PREENCHIMENTO:
    # Incrementa Y e continua o Loop Externo
    addi $s4, $s4, 1            # Y = Y + 1
    j LOOP_Y_PREENCHIMENTO
# ------------------ Divisão da parte preta e cinza escuro -------------------------

# ------------------ Linhas coloridas ----------------------------------------------

Linhas_Coloridas: 
    
    li $a0, 17             # Y_ALTURA = 17
    li $a1, 2              # X_INICIO = 2
    li $a2, 2              # X_FIM = 2
    li $a3, 0x00D3D3D3     # Cor cinza claro
    jal Desenha_Linha_Horizontal           # Chama a sub-rotina de desenho
    
    li $a0, 6               # X_FIXO = 5 (Coluna)
    li $a1, 10              # Y_INICIO = 10
    li $a2, 12              # Y_FIM = 25
    li $a3, 0xFFFFFFFF      # COR = Branco
    jal DrawVerticalLine    # Chama a sub-rotina
    
    Desenha_Linha_Horizontal:
    # $a1 (X_INICIO) é o contador do loop.
    # $a2 (X_FIM) é o limite do loop.
    
Loop_Desenho_Horizontal:
    # Se x > X_FIM retorna
    bgt $a1, $a2, Finaliza_Desenho_Horizontal 

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
    j Loop_Desenho_Horizontal

Finaliza_Desenho_Horizontal:
    jr $ra
    
# ------------------- horizontal --------------------    
    DrawVerticalLine:
    # $a1 (Y_INICIO) será o contador do loop.
    # $a2 (Y_FIM) será o limite do loop.
    
LOOP_DRAW_V:
    # Condição de Parada: Se Y_atual ($a1) > Y_FIM ($a2), retorna.
    bgt $a1, $a2, END_DRAW_V 

    # 1. CÁLCULO DO ENDEREÇO (Fórmula Geral)

    # Offset em Unidades = (Y_atual * Largura) + X_fixo
    # Y_atual = $a1, Largura = $s2, X_fixo = $a0
    mul $t0, $a1, $s2       # $t0 = Y_atual * Largura (Offset na Linha)
    add $t0, $t0, $a0       # $t0 = Offset na Linha + X_fixo (Offset em Unidades)

    # Endereço_Final = BaseAddress ($s0) + Offset ($t0) * Tamanho do Pixel ($s1)
    mul $t0, $t0, $s1       # $t0 = Offset em Bytes
    add $t1, $s0, $t0       # $t1 = Endereço Final (Base + Offset)

    # 2. DESENHO
    sw $a3, 0($t1)          # sw Cor ($a3), 0(Endereço Final)

    # 3. Incrementa Y e Repete
    addi $a1, $a1, 1        # Y_atual = Y_atual + 1
    j LOOP_DRAW_V

END_DRAW_V:
    jr $ra                  # Retorna
# ------------------ Linhas coloridas ----------------------------------------------

Fim_Programa:
    li $v0, 10
    syscall
