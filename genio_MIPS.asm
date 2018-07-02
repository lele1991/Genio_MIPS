.data
#excecao
flag: .word 0
tecla: .word 0

vetor: 			.word 0:1024 	#inicializados com zero 
menu:			 .asciiz "\n Menu: 1- Iniciar o jogo     2- Encerrar o programa.\n" 
ERRO: 			.asciiz "\n ERRO: O número digitado não corresponde à nenhuma opção.\n" 
ativacao: 		.asciiz "\n Digite o número de ativação:  " 
score: 			.asciiz "\n ACERTOU"
loser: 			.asciiz "\n ERROU"
	#512/16 -  pixel maior - 32 espacos 
.text
main:
	menu_jogo:
	#imprimir MENU
		li $v0, 4				#string
		la $a0, menu			#le mensagem
		syscall
	#le entrada - numero
		li $v0, 5 				#int
		syscall					#int 
	
	bne $v0, 1, sai_encerra
	#imprime mensagem de ativacao
		li $v0, 4				#string
		la $a0, ativacao		#mensagem
		syscall

		jal desenha_jogo
		
		la $a0, vetor			#vetor random
		#le entrada - numero
		li $v0, 5 				#int
		syscall					#int 
		move  $a1, $v0
		move  $s1, $v0			#s1 = numero no vetor (ativacao)
		jal gera				#gera vetor random
		move $a1, $s1			#a1 = numero no vetor (ativacao)
		jal sequencia
		
		#musica
		#tempo - duracao q o jogador escolhe
		#interrupçAo
		
		j menu_jogo
		
	sai_encerra:
		bne $v0, 2, erro
		li $v0, 10
		syscall
	
	erro:
		li $v0, 4					#string
		la $a0, ERRO				#mensagem
		syscall
		j menu_jogo
########################################################################
gera:
	move $t0, $a1		#t0 é o n de ativacao 
	move $t1, $a0		# s1 endereco do vetor 
	
	random:
	beqz $t0, sai_gera		#t0 = 0 qtdd
   	li $a1, 4       	 	#ate 3 pra gerar valor
	li $v0, 42				#random
	syscall
	
	#imprime o numero que gerou APAGAR DEPOIS
	li $v0, 1
	syscall
   	
   	#faz vetor
   	sw $a0, 0($t1)      	#vetor
   	addi $t1, $t1, 4    	#anda pelo vetor
   	addi $t0, $t0, -1    	#qtd -1
 	j random
		
	sai_gera:
	jr $ra
########################################################################	
sequencia:
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
		
		for_sequencia1:
		bgt $t1, $t3, inicializa_for2		#for(i=0; i<=j; i++)  se t1>t3, sai
			#salva e guarda por causa do ACENDE
			sw $t0, 8($sp)				#salva  local onde ta o vetor antes para usar depois 
			sw $t1, 12($sp)				#salva t1 = i 
			sw $t2, 16($sp)				#salva t2 = num de tivacao
			sw $t3, 20($sp)				#salva t3 = j 
			lw $a0, 0($t0)
			#acende a sequencia
			jal acende
			lw 	 $t0, 8($sp)			#carrego vetor	
			lw 	 $t1, 12($sp)			#carrego i
			lw 	 $t2, 16($sp)			#num ativacao
			lw   $t3, 20($sp)			#carrego j
		add  $t0, $t0, 4				#anda pelo vetor
		addi $t1, $t1, 1				#i++
		j for_sequencia1
		
		inicializa_for2:
			la  $t0, vetor 
			li $t1, 0						#i = 0
			for_sequencia2:					
			bgt $t1, $t3, sai_sequencia		#for(i=0; i<=j; i++)  se t1>t3, sai
				#salva e guarda por causa do ACENDE
				sw $t0, 8($sp)				#salva  local onde ta o vetor antes para usar depois 
				sw $t1, 12($sp)				#salva t1 = i 
				sw $t2, 16($sp)				#salva t2 = num de tivacao
				sw $t3, 20($sp)				#salva t3 = j 
				lw $a0, 0($t0)
			#acende a sequencia
				jal compara
				beqz $v0, sai_formax
				lw 	 $t0, 8($sp)			#carrego vetor	
				lw 	 $t1, 12($sp)			#carrego i
				lw 	 $t2, 16($sp)			#num ativacao
				lw   $t3, 20($sp)			#carrego j
			add  $t0, $t0, 4			#anda pelo vetor
			addi $t1, $t1, 1			#i++
			j for_sequencia2
		
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
compara:
addi $sp, $sp, -24
sw  $a0, 0($sp)			#vetor
sw  $ra, 4($sp)			#retorno
	
	move $t3, $a0
	
	lui	 $a0, 0xFFFF			#carrega endereço
	get_char:
	lw	 $t0, 0($a0)			#controle
	andi $t0, $t0, 0x00000001	#esperar
	beq  $t0, $zero, get_char	#enquanto nao houver comunicacao 
	lw   $v0, 4($a0)			#salva os dados
	
	lw $t1, 0($sp)
	if_0:
	bne $t1, 0, if_1
		bne $v0, 'w', else_0
			li $a0, 0
			jal acende
			#imprimir score
			li $v0, 4				#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1				#flag
			j sai_compara			
		else_0:
			#imprimir ERROU
			li $v0, 4				#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0				#flag
			j sai_compara
	if_1:
	bne $t1, 1, if_2
		bne $v0, 's', else_1
			li $a0, 1
			jal acende
			#imprimir score
			li $v0, 4				#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1				#flag
			j sai_compara
		else_1:
			#imprimir ERROU
			li $v0, 4				#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0				#flag
			j sai_compara
	if_2:
	bne $t1, 2, if_3
		bne $v0, 'a', else_2
			li $a0, 2
			jal acende
			#imprimir score
			li $v0, 4				#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1				#flag
			j sai_compara
		else_2:
			#imprimir ERROU
			li $v0, 4				#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0				#flag
			j sai_compara
	if_3:
	bne $t1, 3, sai_compara
		bne $v0, 'd', else_3
			li $a0, 3
			jal acende
			#imprimir score
			li $v0, 4				#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1				#flag
			j sai_compara
		else_3:
			#imprimir ERROU
			li $v0, 4				#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0				#flag
			j sai_compara
	
	sai_compara:
	lw  $ra, 4($sp)
	lw 	$a0, 0 ($sp)
	addi $sp, $sp, 24
	move $v0, $t2
	jr $ra
########################################################################
acende:
	addi $sp, $sp, -24
	sw   $ra, 8($sp)
	sw   $a0, 0($sp)    	#elemento vetor
	
	verde_0:
		bne $a0, 0, azul_1	#acende verde claro
		li $a3, 0x00FF00	#verde claro
		jal verde_claro
		jal sleep
		li $a3, 0x135C0A	#verde escuro
		jal verde_claro				
		jal sleep
				
	azul_1:
		lw $a0, 0($sp)
		bne $a0, 1, amarelo_2	#acende azul claro 
		li $a3, 0x00BFFF	#azul claro
		jal azul_claro
		jal sleep
		li $a3, 0x0C0273	#azul escuro
		jal azul_claro	
		jal sleep
						
	amarelo_2:
		lw $a0,  0($sp)
		bne $a0, 2, vermelho_3	#acende amarelo claro 
		li $a3, 0xFFFF00	#amarelo claro
		jal amarelo_claro
		jal sleep
		li $a3, 0x80730D	#amrelo escuro
		jal amarelo_claro	
		jal sleep
		
	vermelho_3:
		lw $a0,  0($sp)
		bne $a0, 3, sai_acende	#acende vermelho claro 		
		li $a3, 0xFF4500	#vermelho claro
		jal vermelho_claro
		jal sleep
		li $a3, 0x800303	#vermelho escuro
		jal vermelho_claro
		jal sleep
		
	sai_acende:
	lw   $a0, 0($sp)
	lw   $ra, 8($sp)
	addi $sp, $sp, 24
	jr $ra	


########################################################################	
#PINTA ESCURO
desenha_jogo:	
	addi $sp, $sp, -24
	sw $ra, 0($sp)			#salva retorno do desenho
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
	li $a0, 500 		#1000ms
	syscall
	jr $ra 
			
#########################################################################desenha
#ESCREVE
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
