.data
Endereço_Base: .word 0x10040000 # Endereço base do bitmap como heap
Tam_Pixel:   .word 4 # Cada pixel é composto por 4 bits
Largura_Display: .word 64 # 64 bits de largura

X_Divisoria: .word 16 # Divisão pra linha cinza

.text
.globl bmp1
bmp1:
# Salva os registradores pra não quebrar pc
    addi $sp, $sp, -40        
    sw   $ra, 36($sp)         
    sw   $s0, 32($sp)
    sw   $s1, 28($sp)
    sw   $s2, 24($sp)
    sw   $s3, 20($sp)
    sw   $s4, 16($sp)
    sw   $s5, 12($sp)
    sw   $s6, 8($sp)
    sw $t9, 4($sp)
    sw $v0, 0($sp)
    li $s0, 0x10040000      # Endereço base como heap
    li $s1, 4               # Tamanho do pixel
    li $s2, 64              # Largura da tela
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
        bge $s6, $s3, Seleciona_Direita # Se X >= 16, escolhe a direita e pinta de cinza escuro

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
    li $a0, 1                    # Y_ALTURA = 1
    li $a1, 18                   # X_INICIO = 18
    li $a2, 22                   # X_FIM = 22
    li $a3, 0x993399             # Cor roxa
    jal Desenha_Linha_Horizontal # Chama a sub-rotina de desenho
    
    li $a0, 1                    # Y_ALTURA = 1
    li $a1, 24                   # X_INICIO = 24
    li $a2, 28                   # X_FIM = 28
    li $a3, 0x00FFA500           # Cor laranja
    jal Desenha_Linha_Horizontal # Chama a sub-rotina de desenho
    
    # Assim por diante
    li $a0, 5              
    li $a1, 18              
    li $a2, 20             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 5              
    li $a1, 22             
    li $a2, 24             
    li $a3, 0x00FFFF00     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 7            
    li $a1, 20             
    li $a2, 22             
    li $a3, 0x005353ec    
    jal Desenha_Linha_Horizontal         
    
    li $a0, 7              
    li $a1, 24             
    li $a2, 24             
    li $a3, 0x007070FF     
    jal Desenha_Linha_Horizontal  
    
    li $a0, 9             
    li $a1, 20             
    li $a2, 22             
    li $a3, 0x00993399     
    jal Desenha_Linha_Horizontal        
    
    li $a0, 9          
    li $a1, 24             
    li $a2, 24             
    li $a3, 0x00FFFF00     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 11             
    li $a1, 22             
    li $a2, 30             
    li $a3, 0x00FFFF00     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 13          
    li $a1, 22            
    li $a2, 30             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal        
    
    li $a0, 15             
    li $a1, 22             
    li $a2, 24          
    li $a3, 0x993399       
    jal Desenha_Linha_Horizontal     
    
    li $a0, 15            
    li $a1, 26           
    li $a2, 27           
    li $a3, 0x005353ec    
    jal Desenha_Linha_Horizontal       
    
    li $a0, 17             
    li $a1, 24            
    li $a2, 26             
    li $a3, 0x005353ec    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 17          
    li $a1, 28            
    li $a2, 28             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal        
    
    li $a0, 17            
    li $a1, 29             
    li $a2, 29            
    li $a3, 0x00FFFFFF     
    jal Desenha_Linha_Horizontal         
    
    li $a0, 17            
    li $a1, 30            
    li $a2, 30             
    li $a3, 0x0000ac20    
    jal Desenha_Linha_Horizontal         
    
    li $a0, 19            
    li $a1, 24           
    li $a2, 28            
    li $a3, 0x00FFFF00     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 21            
    li $a1, 24          
    li $a2, 24            
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 23             
    li $a1, 22            
    li $a2, 22             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 25            
    li $a1, 20            
    li $a2, 20             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 27             
    li $a1, 20             
    li $a2, 23             
    li $a3, 0x00993399   
    jal Desenha_Linha_Horizontal           
    
    li $a0, 27             
    li $a1, 25           
    li $a2, 25             
    li $a3, 0x0000ac20    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 27             
    li $a1, 26             
    li $a2, 26             
    li $a3, 0x00FFFFFF     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 29             
    li $a1, 18             
    li $a2, 18             
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 0              
    li $a1, 60             
    li $a2, 60             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 0              
    li $a1, 58             
    li $a2, 58             
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 0              
    li $a1, 62             
    li $a2, 63             
    li $a3, 0x00FF0000     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 3              
    li $a1, 1              
    li $a2, 12              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 5              
    li $a1, 1             
    li $a2, 2            
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 5             
    li $a1, 3              
    li $a2, 5              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 7              
    li $a1, 1             
    li $a2, 10             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 9              
    li $a1, 1              
    li $a2, 2              
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 9              
    li $a1, 3              
    li $a2, 5              
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal          
    
    li $a0, 11             
    li $a1, 1              
    li $a2, 13              
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal          
    
    li $a0, 13            
    li $a1, 1              
    li $a2, 1              
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 13            
    li $a1, 2              
    li $a2, 5             
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal           
    
    li $a0, 15             
    li $a1, 1              
    li $a2, 4              
    li $a3, 0x00D3D3D3    
    jal Desenha_Linha_Horizontal          
    
    li $a0, 17             
    li $a1, 1             
    li $a2, 2              
    li $a3, 0x005353ec     
    jal Desenha_Linha_Horizontal           
    
    li $a0, 17             
    li $a1, 3              
    li $a2, 6             
    li $a3, 0x00D3D3D3     
    jal Desenha_Linha_Horizontal           
    
    j Fim_Programa
    
    Desenha_Linha_Horizontal:
    addi $sp, $sp, -12  # Alocar espaço para $a1, $a2, $a3 (3 palavras)
    sw $a1, 8($sp)      # Salva $a1 (contador/X_INICIO)
    sw $a2, 4($sp)      # Salva $a2 (limite/X_FIM)
    sw $a3, 0($sp)
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
lw $a3, 0($sp)
    lw $a2, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12   # Desalocar o espa
    jr   $ra
    
# ------------------ Linhas coloridas ----------------------------------------------
Fim_Programa: # Restaura os registradores
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
