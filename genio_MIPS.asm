.data

vetor: .word 0:1024 #inicializados com zero

.text
main:
	jal desenha_jogo
	#mostra opcao de ativacao
	#0 - 5n;  1 - 15n;  3 - 45;
	#pega do teclado 0, 1, 2
	#move s0
	la $s1, vetor		#vetor random
	li $s0,5		#quantidade de numero no vetor (ativacao)
	jal gera
	
	#vetor ta em t0
	lw $
	jal acende
	
	li $v0, 10
	syscall
#512/16 -  pixel maior - 32 espacos 
	#sorteia array(random)
	
	#bota na pilha
	
	#entrada do teclado
	
	#compara entrada - roda o jogo

	
desenha_jogo:	
	#QUADRADO VERDE - CIMA
	li $a3, 0x135C0A		#verde escuro
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
	beq $a0, 20, sai
		addi $a0, $a0, 1
		jal linha
	j retangulo_vermelhoescuro
	
	sai:
	jr $ra

gera:
	
	random:
	beqz $s0, sai_gera		#t6 = 0 qtdd
   	li $a1, 3       	 	#ate 3 pra gerar valor
	li $v0, 42			#random
	syscall
   	#faz vetor
   	sw $a0, 0($s1)      #vetor
   	addi $s1, $s1, 4    #anda pelo vetor
   	addi $s0, $s0, -1    #qtd -1
 	j random
		move $t0, $a0
		
	sai_gera:
		jr $ra
	
	
acende:
	lw $t0,0($s1)		# primeiro elemento do vetor 
	
	verde_0:
		bne $t0, 0, azul_1
		#acende verde claro
		
	azul_1:
		bne $t0, 1, amarelo_2
		#acende azul claro 
		
	amarelo_2:
		bne $t0, 2, vermelho_3
		#acende amarelo claro 
	vermelho_3:
		bne $t0, 2, ????????
		#acende vermelho claro 		
	
			
	
	
	
			
					
#desenha
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
