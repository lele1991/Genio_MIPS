.data

vetor: .word 0:1024 #inicializados com zero

.text
main:
	jal desenha_jogo
	#fazer menu com entrada do usuario para a quantidade de numeros no vetor
	la $a0, vetor	#vetor random
	#mostra opcao de ativacao
	#0 - 5n;  1 - 15n;  3 - 45;
	#pega do teclado 0, 1, 2
	li $a1,5		#quantidade de numero no vetor (ativacao) -  dado pelo usuario
	
	jal gera			#gera vetor random
	jal sequencia
	
	li $v0, 10
	syscall
	#512/16 -  pixel maior - 32 espacos 
########################################################################
gera:
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $a0, 4($sp)		#vetor 
	sw $a1, 8($sp)		#n de ativacao 
	
	move $t0, $a1		#t0 é o n de ativacao 
	move $s1, $a0		# s1 endereco do vetor 
	
	random:
	beqz $t0, sai_gera		#t0 = 0 qtdd
   	li $a1, 4       	 	#ate 3 pra gerar valor
	li $v0, 42				#random
	syscall
	
	#imprime o numero que gerou APAGAR DEPOIS
	li $v0, 1
	syscall
   	
   	#faz vetor
   	sw $a0, 0($s1)      	#vetor
   	addi $s1, $s1, 4    	#anda pelo vetor
   	addi $t0, $t0, -1    	#qtd -1
 	j random
		
	sai_gera:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 24
	jr $ra
########################################################################	
sequencia:
#----------------------
#sequencia		8(sp) //multiplo de 8
#----------------------
#espaco			------
#---------------------		
#ra				24(sp)	
#---------------------
#t6				 20(sp)
#t2				 16(sp)
#t1				 12(sp)
#t0 			 8(sp)
#a1				 4(sp)
#a0				 0(sp)
#---------------------
	addi $sp, $sp, -32
	sw  $a0, 0($sp)				#vetor
	sw  $a1, 4($sp)				#n de ativacao
	sw  $ra, 24($sp)			#retorno
	
	move $t0, $a0				#vetor é igual t0
	li   $t1, 0					#i = 0
	move $t2, $a1				#numero de ativacao recebido pelo usuario
	li   $t3, 0					#j = 0
	
	for_maxativacao:
		bge $t3, $t2, sai_formax	#if j = num de ativacao
		la  $t0, vetor 
		
		for_sequencia:
			bgt $t1, $t3, sai_sequencia		#for(i=0; i<=j; i++)  se t1>t3, sai
				#salva e guarda por causa do ACENDE
				sw $t0, 8($sp)				#salva  local onde ta o vetor antes para usar depois 
				sw $t1, 12($sp)				#salva t1 = i 
				sw $t2, 16($sp)				#salva t2 = num de tivacao
				sw $t3, 20($sp)				#salva t3 = j 
				
				lw $a0, 0($t0)
				jal acende
				lw 	 $t0, 8($sp)			#carrego vetor	
				lw 	 $t1, 12($sp)			#carrego i
				lw 	 $t2, 16($sp)			#num ativacao
				lw   $t3, 20($sp)			#carrego j
				
				#salva e guarda por causa do COMPARA
				sw $t0, 8($sp)				#salva  local onde ta o vetor antes para usar depois 
				sw $t1, 12($sp)				#salva t1 = i 
				sw $t2, 16($sp)				#salva t2 = num de tivacao
				sw $t3, 20($sp)				#salva t3 = j 
				
				jal compara
				
				lw 	 $t0, 8($sp)			#carrego vetor	
				lw 	 $t1, 12($sp)			#carrego i
				lw 	 $t2, 16($sp)			#num ativacao
				lw   $t3, 20($sp)			#carrego j				
				
				
				add  $t0, $t0, 4			#anda pelo vetor
				addi $t1, $t1, 1			#i++
				j for_sequencia
				
		sai_sequencia:
			addi $t3, $t3, 1		#j++
			li   $t1, 0				#i = 0
	j for_maxativacao
			
	sai_formax:
	lw  $ra, 24($sp)
	lw 	$a1, 4 ($sp)
	lw 	$a0, 0 ($sp)
	addi $sp, $sp, 32
	jr $ra
########################################################################	
acende:
	addi $sp, $sp, -24
	sw   $ra, 8($sp)
	sw   $a0, 0($sp)    	# elemento vetor
	
	verde_0:
		bne $a0, 0, azul_1	#acende verde claro
		li $a3, 0x00FF00	#verde claro
		jal verde_claro
		jal sleep
		li $a3, 0x135C0A	#verde escuro
		jal verde_claro				
			
	azul_1:
		bne $a0, 1, amarelo_2	#acende azul claro 
		li $a3, 0x00BFFF	#azul claro
		jal azul_claro
		jal sleep
		li $a3, 0x0C0273	#azul escuro
		jal azul_claro	
						
	amarelo_2:
		bne $a0, 2, vermelho_3	#acende amarelo claro 
		li $a3, 0xFFFF00	#amarelo claro
		jal amarelo_claro
		jal sleep
		li $a3, 0x80730D	#amrelo escuro
		jal amarelo_claro	
	vermelho_3:
		bne $a0, 3, sai_acende	#acende vermelho claro 		
		li $a3, 0xFF4500	#vermelho claro
		jal vermelho_claro
		jal sleep
		li $a3, 0x800303	#vermelho escuro
		jal vermelho_claro
		
	sai_acende:
	lw   $a0, 0($sp)
	lw   $ra, 8($sp)
	addi $sp, $sp, 24
	jr $ra	
########################################################################
compara:
addi $sp, $sp, -24
	sw   $ra, 8($sp)
	sw   $a0, 0($sp)  #o que é?  	

#codigo a ser feito


	lw   $a0, 0($sp)
	lw   $ra, 8($sp)
	addi $sp, $sp, 24
	jr $ra	
########################################################################	
desenha_jogo:	
	addi $sp, $sp, -24
	sw $ra, 0($sp)			#salva retorno do desenho
	#QUADRADO VERDE - CIMA
	li $a3, 0x135C0A			#verde escuro
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 0				#anda na vertical
	li $a1, 10				#anda na horizontal
	li $a2, 12				#quanidade de pixel
	retangulo_verdeescuro:
	beq $a0, 7, amarelo_escuro
		addi $a0, $a0, 1
		jal linha
		
	j retangulo_verdeescuro
	
	#QUADRADO AMARELO ESQ
	amarelo_escuro:
	li $a3, 0x80730D		#amarelo escuro
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 10				#anda na vertical		y
	li $a1, 1				#anda na horizontal		x
	li $a2, 8				#quanidade de pixel
	retangulo_amareloescuro:
	beq $a0, 20, azul_escuro
		addi $a0, $a0, 1
		jal linha
	j retangulo_amareloescuro
	
	#QUADRADO AZUL - BAIXO
	azul_escuro:
	li $a3, 0x0C0273		#verde escuro
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 23				#anda na vertical 		y
	li $a1, 10				#anda na horizontal		X
	li $a2, 12				#quanidade de pixel
	retangulo_azulescuro:
	beq $a0, 30, vermelho_escuro
		addi $a0, $a0, 1
		jal linha
	j retangulo_azulescuro
	
	#QUADRADO VERMELHO DIR
	vermelho_escuro:
	li $a3, 0x800303		#amarelo escuro
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 10				#anda na vertical
	li $a1, 23				#anda na horizontal
	li $a2, 8				#quanidade de pixel
	retangulo_vermelhoescuro:
	beq $a0, 20, sai_vermelho_escuro
		addi $a0, $a0, 1
		jal linha
	j retangulo_vermelhoescuro
	
	sai_vermelho_escuro:
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra
########################################################################
#PINTANDO CLARO
verde_claro:
	addi $sp, $sp, -24
	sw   $ra, 0($sp)
	
	#QUADRADO VERDE CLARO - CIMA
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 0				#anda na vertical
	li $a1, 10				#anda na horizontal
	li $a2, 12				#quanidade de pixel
	retangulo_verdeclaro:
	beq $a0, 7, sai_verde_claro
		addi $a0, $a0, 1
		jal linha
	j retangulo_verdeclaro
	
	sai_verde_claro:
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra

amarelo_claro:
	addi $sp, $sp, -24
	sw   $ra, 0($sp)
	#QUADRADO AMARELO ESQ
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 10				#anda na vertical		y
	li $a1, 1				#anda na horizontal		x
	li $a2, 8				#quanidade de pixel
	retangulo_amareloclaro:
	beq $a0, 20, sai_amarelo_claro
		addi $a0, $a0, 1
		jal linha
	j retangulo_amareloclaro
	
	sai_amarelo_claro:
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra
	
azul_claro:
	addi $sp, $sp, -24
	sw   $ra, 0($sp)
	#QUADRADO AZUL - BAIXO
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 23				#anda na vertical 		y
	li $a1, 10				#anda na horizontal		X
	li $a2, 12				#quanidade de pixel
	retangulo_azulclaro:
	beq $a0, 30, sai_azul_claro
		addi $a0, $a0, 1
		jal linha
	j retangulo_azulclaro
	
	sai_azul_claro:
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra

vermelho_claro:
	addi $sp, $sp, -24
	sw   $ra, 0($sp)
	#QUADRADO VERMELHO DIR
	li $a2, 32				#tamanho da linha/coluna
	li $a0, 10				#anda na vertical
	li $a1, 23				#anda na horizontal
	li $a2, 8				#quanidade de pixel
	retangulo_vermelhoclaro:
	beq $a0, 20, sai_vermelho_claro
		addi $a0, $a0, 1
		jal linha
	j retangulo_vermelhoclaro
	
	sai_vermelho_claro:
	lw   $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra
	
########################################################################
sleep:	
	#sleep:
	li $v0, 32 			#sleep
	li $a0, 1000 		#1000ms
	syscall
	jr $ra 
			
#########################################################################desenha
linha:  
	li   $t0, 0x10010000	#t3 = endereco base
	sll  $t1, $a0, 5		#y = y * 512/16  -  vertical -2^5=16 -> 16+16 -> 16x16 bloco de 32
	addu $t1, $a1, $t1		# adds x, y to the first pixel (t0)- horizontal
	sll  $t1, $t1, 2		#1 pixel - 4 bytes	
	add  $t0, $t0, $t1	 	#endereco base
	li $t2, 0
escreve_l:
	beq $t2, $a2, return_l 
		sw    $a3, 0($t0)   #put the color  ($a3) in $t0
		addi  $t0, $t0, 4	#anda pelo vetor
		addi  $t2, $t2, 1	#int unidades do vetor
	j escreve_l
	return_l:
	jr $ra
coluna:
	li   $t0, 0x10010000	#t3 = endereco base
	sll  $t1, $a0, 5		#y = y * 512/16  -  vertical -2^5=16 -> 16+16 -> 16x16 bloco de 32
	addu $t1, $a1, $t1		# adds x, y to the first pixel (t0)- horizontal
	sll  $t1, $t1, 2		#1 pixel - 4 bytes	
	add  $t0, $t0, $t1	 	#endereco base
	li $t2, 0
escreve_c:
	beq $t2, $a2, return_c
		#escreve
		sw   $a3, 0($t0)    #put the color branc ($a2) in $t0
		addi $t0, $t0, 128	#anda pelo vetor 4*tl -> tl = 32 
		addi $t2, $t2, 1	#int posicao do pixel
	j escreve_c
	return_c:
	jr $ra
########################################################################



#esperando tempo para desligar DELAY
	#sleep:
	#	li $v0, 32 			#sleep
	#	li $a0, 1000 			#1000ms
	#	syscall 			#do the sleep

#	#setando o pixel -apagando o pixel 
#	setpixel:
#	li $t0, 0x10000500 
#	sll   $t1, $a0, 9        #y = y * 512
#	addu  $t1, $t0, $t1      # adds xy to the first pixel ( t3 )
#	sw    $a1, ($t1)         # put the color branc ($a2) in $t0
