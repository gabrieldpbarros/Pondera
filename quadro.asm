.data
Endereço_Base:   .word 0x10010000 # Endereço base do bitmap como heap
Tam_Pixel:       .word 4 # Cada pixel é composto por 4 bits
Largura_Display: .word 64 # 64 bits de largura

.text
.globl bmp2
bmp2:
    lw $s0, Endereço_Base   # Endereço base do static
    lw $s1, Tam_Pixel       # Tamanho do pixel
    lw $s2, Largura_Display # Largura da tela
    li $s4, 0               # Contagem pras colunas
    li $s5, 32              # Limite da tela

# ------------------ Pinta todo o quadro com branco -----------------------------------
Loop_Y_Preenchimento:
    bge $s4, $s5, Linhas_Coloridas # Se Y >= 32, segue para as linhas
    li $s6, 0                      # Contador da coluna que reinicia em 0 para cada nova linha
    
    # Loop que percorre todos os pixels da linha Y
    Loop_X_Preenchimento:
        bge $s6, $s2, Fim_Loop_X_Preenchimento # Se chegou no fim da linha, pula pra próxima

        # Endereço de memória
        
        # Offset = (Y * largura) + X
        mul $t0, $s4, $s2       # $t0 = Y * largura
        add $t0, $t0, $s6       # $t0 = (Y * largura) + X (Offset em unidades)

        # Endereço_Final = BaseAddress + Offset * tamanho do pixel
        mul $t0, $t0, $s1       # $t0 = Offset * tamanho do pixel (Offset em bytes)
        add $t1, $s0, $t0       # $t1 = endereço base + Offset em bytes

        # Desenho em si
        li $t8, 0x00FFFFFF
        sw $t8, 0($t1)          # sw Cor ($t8), 0(Endereco_Final)

        # Incrementa x e continua o loop interno
        addi $s6, $s6, 1        # X += 1
        j Loop_X_Preenchimento
    
    Fim_Loop_X_Preenchimento:
    # Incrementa Y e continua o loop interno
    addi $s4, $s4, 1            # Y += 1
    j Loop_Y_Preenchimento
# ---------------------- Pinta todo o quadro com dark blue -------------------------------

# ------------------------------ Linhas coloridas ----------------------------------------

Linhas_Coloridas: 
    
# -------------------------- Chamada linhas horizontais ----------------------------------
    
    li $a0, 8                    # Y_ALTURA = 8
    li $a1, 4                    # X_INICIO = 4
    li $a2, 36                   # X_FIM = 36
    li $a3, 0x008B4513           # Cor marrom
    jal Desenha_Linha_Horizontal 
    
    li $a0, 23                   # Y_ALTURA = 23
    li $a1, 4                    # X_INICIO = 4
    li $a2, 36                   # X_FIM = 36
    li $a3, 0x008B4513           # Cor marrom
    jal Desenha_Linha_Horizontal 
    
# Assim por diante
    li $a0, 22                   
    li $a1, 5                    
    li $a2, 35                    
    li $a3, 0x00F7E9A3           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 21                   
    li $a1, 5                    
    li $a2, 35                    
    li $a3, 0x00F7E9A3           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 20                   
    li $a1, 5                    
    li $a2, 35                    
    li $a3, 0x00F7E9A3           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 9                   
    li $a1, 8                    
    li $a2, 32                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 10                   
    li $a1, 8                    
    li $a2, 32                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 11                   
    li $a1, 8                    
    li $a2, 32                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 12                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 13                   
    li $a1, 8                   
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 14                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 15                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 16                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 17                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 18                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 19                   
    li $a1, 8                    
    li $a2, 22                    
    li $a3, 0x006EB1FF           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 12                   
    li $a1, 23                    
    li $a2, 30                    
    li $a3, 0x000db50d           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 13                   
    li $a1, 23                    
    li $a2, 30                    
    li $a3, 0x000db50d           
    jal Desenha_Linha_Horizontal 
    
    li $a0, 19                   
    li $a1, 23                    
    li $a2, 30                    
    li $a3, 0x000db50d           
    jal Desenha_Linha_Horizontal
   
# --------------------------- Linhas Horizontais ------------------------------------    

# ------------------------ Chamada linhas verticais ---------------------------------
    li $a0, 4                  # X_fixo = 4
    li $a1, 8                  # Y_inicio = 8
    li $a2, 23                 # Y_fim = 23
    li $a3, 0x008B4513         # Cor marrom
    jal Desenha_Linha_Vertical # Chama a subrotina de desenho
    
    li $a0, 36                 # X_fixo = 36
    li $a1, 8                  # Y_inicio = 8
    li $a2, 23                 # Y_fim = 23
    li $a3, 0x008B4513         # Cor marrom
    jal Desenha_Linha_Vertical # Chama a sub-rotina de desenho
    
# Assim por diante
    li $a0, 5              
    li $a1, 9              
    li $a2, 22             
    li $a3, 0x00F7E9A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 6             
    li $a1, 9              
    li $a2, 19             
    li $a3, 0x00E5D8A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 7              
    li $a1, 9              
    li $a2, 19             
    li $a3, 0x00E5D8A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 35              
    li $a1, 9              
    li $a2, 22             
    li $a3, 0x00F7E9A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 34              
    li $a1, 9              
    li $a2, 22             
    li $a3, 0x00F7E9A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 33              
    li $a1, 9              
    li $a2, 22             
    li $a3, 0x00F7E9A3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 23              
    li $a1, 14              
    li $a2, 19             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 30              
    li $a1, 14              
    li $a2, 19             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 24              
    li $a1, 15              
    li $a2, 18             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 29              
    li $a1, 15              
    li $a2, 18             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 28              
    li $a1, 16              
    li $a2, 16             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 25              
    li $a1, 16              
    li $a2, 16             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 26              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 27              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x000db50d      
    jal Desenha_Linha_Vertical    
    
    li $a0, 25              
    li $a1, 17              
    li $a2, 19             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 28              
    li $a1, 17              
    li $a2, 19             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 27              
    li $a1, 16              
    li $a2, 18             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 26              
    li $a1, 16              
    li $a2, 18             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 25              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 24              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 28              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 29              
    li $a1, 14              
    li $a2, 15             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    li $a0, 31              
    li $a1, 12              
    li $a2, 19             
    li $a3, 0x006EB1FF      
    jal Desenha_Linha_Vertical    
    
     li $a0, 32              
    li $a1, 12              
    li $a2, 19             
    li $a3, 0x006EB1FF      
    jal Desenha_Linha_Vertical    
    
    li $a0, 45              
    li $a1, 15              
    li $a2, 25             
    li $a3, 0x00FFFF00      
    jal Desenha_Linha_Vertical    
    
    li $a0, 45              
    li $a1, 13              
    li $a2, 14             
    li $a3, 0x00c0c0c0      
    jal Desenha_Linha_Vertical    
    
    li $a0, 45              
    li $a1, 11              
    li $a2, 12             
    li $a3, 0x006EB1FF      
    jal Desenha_Linha_Vertical
    
    li $a0, 48              
    li $a1, 15              
    li $a2, 25             
    li $a3, 0x00FFFF00      
    jal Desenha_Linha_Vertical    
    
    li $a0, 48              
    li $a1, 13              
    li $a2, 14             
    li $a3, 0x00c0c0c0      
    jal Desenha_Linha_Vertical    
    
    li $a0, 48              
    li $a1, 11              
    li $a2, 12             
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical
    
    li $a0, 51              
    li $a1, 15              
    li $a2, 25             
    li $a3, 0x00FFFF00      
    jal Desenha_Linha_Vertical    
    
    li $a0, 51              
    li $a1, 13              
    li $a2, 14             
    li $a3, 0x00c0c0c0      
    jal Desenha_Linha_Vertical    
    
    li $a0, 51              
    li $a1, 11              
    li $a2, 12             
    li $a3, 0x00F7E9A3       
    jal Desenha_Linha_Vertical
    
    li $a0, 54              
    li $a1, 15              
    li $a2, 25             
    li $a3, 0x00FFFF00      
    jal Desenha_Linha_Vertical    
    
    li $a0, 54              
    li $a1, 13              
    li $a2, 14             
    li $a3, 0x00c0c0c0      
    jal Desenha_Linha_Vertical    
    
    li $a0, 54              
    li $a1, 11              
    li $a2, 12             
    li $a3, 0x000db50d        
    jal Desenha_Linha_Vertical
    
# -------------------------- Linhas verticais ---------------------------------------

# ------------------------ Desenho das linhas em si ---------------------------------
# ------------------------------- Horizontais ---------------------------------------
    Desenha_Linha_Horizontal:
    # $a1 (X_INICIO) é o contador do loop
    # $a2 (X_FIM) é o limite do loop
    
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
    
# ------------------------------- Horizontais ---------------------------------------

# -------------------------------- Verticais ----------------------------------------
    Desenha_Linha_Vertical:
    # $a1 (Y_INICIO) é o contador do loop
    # $a2 (Y_FIM) é o limite do loop
    
Loop_Desenho_Vertical:
    # Se Y_atual ($a1) > Y_FIM ($a2) retorna
    bgt $a1, $a2, Finaliza_Desenho_Vertical 

    # Endereço
    # Offset em unidades = (Y_atual * Largura) + X_fixo
    # Y_atual = $a1, Largura = $s2, X_fixo = $a0
    mul $t0, $a1, $s2       # $t0 = Y_atual * largura (Offset na linha)
    add $t0, $t0, $a0       # $t0 = Offset na linha + X_fixo (Offset em unidades)

    # Endereço_Final = BaseAddress ($s0) + Offset ($t0) * tamanho do pixel ($s1)
    mul $t0, $t0, $s1       # $t0 = Offset em bytes
    add $t1, $s0, $t0       # $t1 = endereço final (base + offset)

    # Desenho em si
    sw $a3, 0($t1)          # sw cor ($a3), 0(endereço final)

    # Incrementa Y e segue
    addi $a1, $a1, 1        # Y_atual += 1
    j Loop_Desenho_Vertical

Finaliza_Desenho_Vertical:
    jr $ra 
    
# -------------------------------- Verticais ----------------------------------------

# ---------------------------- Linhas coloridas -------------------------------------

Fim_Programa:
    li $v0, 10
    syscall
