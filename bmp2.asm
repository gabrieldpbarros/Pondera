.data
Endereço_Base:   .word 0x10040000 # Endereço base do bitmap como heap
Tam_Pixel:       .word 4 # Cada pixel é composto por 4 bits
Largura_Display: .word 64 # 64 bits de largura

.text
.globl bmp2
bmp2:
addi $sp, $sp, -40        # Pra salvar registradores, pra não quebrar o program counter pelos jal
    sw   $ra, 36($sp)         # salvar $ra (offset 28)
    sw   $s0, 32($sp)
    sw   $s1, 28($sp)
    sw   $s2, 24($sp)
    sw   $s3, 20($sp)
    sw   $s4, 16($sp)
    sw   $s5, 12($sp)
    sw   $s6, 8($sp)
    sw $t9, 4($sp)
    sw $v0, 0($sp)
    li $s0, 0x10040000   # Endereço base do heap
    lw $s1, Tam_Pixel       # Tamanho do pixel
    lw $s2, Largura_Display # Largura da tela
    li $s4, 0               # Contagem pras colunas
    li $s5, 32              # Limite da tela

# ------------------ Pinta todo o quadro com dark blue -----------------------------------
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
        li $t8, 0x00005168
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
    
    li $a0, 17                   # Y_ALTURA = 17
    li $a1, 2                    # X_INICIO = 2
    li $a2, 8                    # X_FIM = 8
    li $a3, 0x00D3D3D3           # Cor cinza claro
    jal Desenha_Linha_Horizontal # Chama a sub-rotina de desenho
    
    li $a0, 19                   # Y_ALTURA = 19
    li $a1, 2                    # X_INICIO = 2
    li $a2, 8                    # X_FIM = 8
    li $a3, 0x00D3D3D3           # Cor cinza claro
    jal Desenha_Linha_Horizontal # Chama a sub-rotina de desenho
    
    # Assim por diante
    li $a0, 19            
    li $a1, 2              
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 21             
    li $a1, 2             
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 23            
    li $a1, 2              
    li $a2, 8             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal         
    
    li $a0, 25            
    li $a1, 2              
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 27             
    li $a1, 2              
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal        
    
    li $a0, 29             
    li $a1, 2              
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 11             
    li $a1, 18              
    li $a2, 21              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal        
    
    li $a0, 19            
    li $a1, 24              
    li $a2, 24             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 19             
    li $a1, 34              
    li $a2, 37             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 11            
    li $a1, 34             
    li $a2, 37              
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal          
    
    li $a0, 11             
    li $a1, 41              
    li $a2, 44              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal         
    
    li $a0, 15             
    li $a1, 41              
    li $a2, 44              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 19            
    li $a1, 41              
    li $a2, 44              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 0             
    li $a1, 0              
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 1             
    li $a1, 0             
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal          
    
    li $a0, 2             
    li $a1, 0              
    li $a2, 63             
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal         
    
    li $a0, 3             
    li $a1, 0             
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 4             
    li $a1, 0              
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 5             
    li $a1, 0              
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 6             
    li $a1, 0              
    li $a2, 63              
    li $a3, 0x00003451    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 4            
    li $a1, 16            
    li $a2, 56             
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 14            
    li $a1, 6              
    li $a2, 8              
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 12             
    li $a1, 6             
    li $a2, 8             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 10            
    li $a1, 6              
    li $a2, 8              
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 10             
    li $a1, 2              
    li $a2, 4              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 12             
    li $a1, 2              
    li $a2, 4              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 14            
    li $a1, 2             
    li $a2, 4              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 8             
    li $a1, 2              
    li $a2, 8              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 5             
    li $a1, 0              
    li $a2, 2              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal         
    
    li $a0, 6             
    li $a1, 0              
    li $a2, 2              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 5             
    li $a1, 7              
    li $a2, 9              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 6             
    li $a1, 7              
    li $a2, 9              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 0             
    li $a1, 7             
    li $a2, 9              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 1             
    li $a1, 7             
    li $a2, 9              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 0             
    li $a1, 0              
    li $a2, 2              
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 1             
    li $a1, 0              
    li $a2, 2             
    li $a3, 0x00BB8800     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 19             
    li $a1, 47             
    li $a2, 50           
    li $a3, 0x0000FF00     
    jal Desenha_Linha_Horizontal          
# --------------------------- Linhas Horizontais ------------------------------------    

# ------------------------ Chamada linhas verticais ---------------------------------
    li $a0, 22              # X_FIXO = 22 (Coluna)
    li $a1, 12              # Y_INICIO = 12
    li $a2, 14              # Y_FIM = 14
    li $a3, 0x00D3D3D3      # Cor cinza claro
    jal Desenha_Linha_Vertical    # Chama a sub-rotina de desenho
    
    li $a0, 22              # X_FIXO = 22 (Coluna)
    li $a1, 16              # Y_INICIO = 16
    li $a2, 18              # Y_FIM = 18
    li $a3, 0x00D3D3D3      # Cor cinza claro
    jal Desenha_Linha_Vertical    # Chama a sub-rotina de desenho
    
# Assim por diante
    li $a0, 31               
    li $a1, 12              
    li $a2, 14              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 31
    li $a1, 16              
    li $a2, 18              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 33               
    li $a1, 12              
    li $a2, 14             
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 33              
    li $a1, 16              
    li $a2, 18              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 38               
    li $a1, 12              
    li $a2, 14              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 38               
    li $a1, 16              
    li $a2, 18              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 40               
    li $a1, 12              
    li $a2, 14              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 45               
    li $a1, 12              
    li $a2, 14              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 45               
    li $a1, 16              
    li $a2, 18              
    li $a3, 0x00D3D3D3      
    jal Desenha_Linha_Vertical    
    
    li $a0, 10               
    li $a1, 7              
    li $a2, 32              
    li $a3, 0x00000000      
    jal Desenha_Linha_Vertical    
    
    j Fim_Programa
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

Fim_Programa: # Restaura os registradores pra não quebrar o program counter
    lw $v0, 0($sp)
    lw $t9,4($sp)
    lw $s6, 8($sp)
    lw $s5, 12($sp)
    lw $s4, 16($sp)
    lw $s3, 20($sp)
    lw $s2, 24($sp)
    lw $s1, 28($sp)
    lw $s0, 32($sp)
    lw $ra, 36($sp)
    addi $sp, $sp, 40
    jr $ra