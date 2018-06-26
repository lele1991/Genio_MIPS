.data

vetor: .word 0:1024 #inicializados com zero

.text
main:
	jal desenha_jogo
	#mostra opcao de ativacao
	#0 - 5n;  1 - 15n;  3 - 45;
	#pega do teclado 0, 1, 2
	#move s0
	la $s1, vetor	#vetor random
	#fazer menu com entrada do usuario para a quantidade de numeros no vetor
	li $s2,5		#quantidade de numero no vetor (ativacao) -  dado pelo usuario
	
	
	jal gera			#gera vetor random
	move $a0, $s1	#parametro pra sequencia a0 = vetor
	move $a1, $s2		# '' 	a1 = num ativacao
	jal sequencia
	
	li $v0, 10
	syscall
	#512/16 -  pixel maior - 32 espacos 
	#entrada do teclado
	#compara entrada - roda o jogo
########################################################################
gera:
	addi $sp, $sp, -24
	sw $ra, 0($sp)

	move $t0, $a0
	random:
	beqz $t0, sai_gera		#t0 = 0 qtdd
   	li $a1, 3       	 	#ate 3 pra gerar valor
	li $v0, 42				#random
	syscall
   	#faz vetor
   	sw $a0, 0($s1)      	#vetor
   	addi $s1, $s1, 4    	#anda pelo vetor
   	addi $t0, $t0, -1    	#qtd -1
 	j random
		move $t0, $a0
		
	sai_gera:
	lw $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra
########################################################################	
sequencia:
	addi $sp, $sp, -24
	sw  $s0, 0($sp)				#vetor
	sw	$a1, 4($sp)				#n de ativacao
	sw  $ra, 8($sp)
	move $s0, $a0
	
	move $t2, $a1				#numero de ativacao recebido pelo usuario
	li 	$t1, 0					#i = 0
	for_sequencia:
	bge $t1, $t2, sai_sequencia	#for(i=0; i<n; i++)
		lw $a0, 0($s0)
		jal acende
		add $s0, $s0, 4			#anda pelo vetor
		addi $t1, $t1, 1		#i++
	j for_sequencia
	
	sai_sequencia:
	lw  $ra, 8($sp)
	lw 	$a1, 4 ($sp)
	lw 	$s0, 0 ($sp)
	addi $sp, $sp, 24
########################################################################	
acende:
	addi $sp, $sp, -24
	sw   $ra, 8($sp)
	sw   $a0, 0($sp)    	#vetor
	
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
		bne $a0, 2, sai_acende	#acende vermelho claro 		
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
