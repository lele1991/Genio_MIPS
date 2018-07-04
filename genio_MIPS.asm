.data
#excecao
flag: .word 0
tecla: .word 0

vetor: 			.word 0:1024 	#inicializados com zero 
menu:			 .asciiz "\n Menu: 1- Iniciar o jogo     2- Encerrar o programa.\n" 
ERRO: 			.asciiz "\n ERRO: O número digitado não corresponde à nenhuma opção.\n" 
ativacao: 		.asciiz "\n Digite o número de ativação:  " 
velocidade: 		.asciiz "\n Digite o número de velocidade:  " 
score: 			.asciiz "\n ACERTOU"
loser: 			.asciiz "\n ERROU"
.align 2
ringbuffer: .space 32

.text
main:
	la $a0, ringbuffer 
	jal init
	menu_jogo:
	#imprimir MENU
		li $v0, 4			#string
		la $a0, menu		#le mensagem
		syscall
	#le entrada - numero
		li $v0, 5 			#int
		syscall				#int 
	
	bne $v0, 1, sai_encerra
<<<<<<< HEAD
=======
		jal desenha_jogo
		
>>>>>>> c4d3d27d28ac4b4d55e193a5196c7ad2bf6cc971
		#imprime mensagem de ativacao
		li $v0, 4				#string
		la $a0, ativacao		#mensagem
		syscall
		#512/16 -  pixel maior - 32 espacos 
<<<<<<< HEAD
		
		jal desenha_jogo
		la $a0, vetor				#vetor random
=======

>>>>>>> c4d3d27d28ac4b4d55e193a5196c7ad2bf6cc971
		#le entrada - numero
		li $v0, 5 				#int
		syscall					#int 
		
		move $a1, $v0			#numero de ativacao
		move $s1, $a1			#s1 = numero no vetor (ativacao) pra usar na sequencia
		la 	 $a0, vetor			#vetor random
		jal gera				#gera vetor random
		
		#imprimir VELOCIDADE
		li $v0, 4				#string
		la $a0, velocidade		#le mensagem
		syscall
		
		#le entrada - numero
		li $v0, 5 				#int
		syscall					#int 
		
		move $s7, $v0			#velocidade
		move $a1, $s1			#a1 = numero no vetor (ativacao)
		jal sequencia
				
		j menu_jogo
		
	sai_encerra:
		bne $v0, 2, erro
		li $v0, 10
		syscall
	
	erro:
		li $v0, 4				#string
		la $a0, ERRO				#mensagem
		syscall
		j menu_jogo
########################################################################
gera:
	move $t0, $a1		#t0 é o n de ativacao 
	move $t1, $a0		#t1 endereco do vetor 
	
	random:
	beqz $t0, sai_gera		#t0 = 0 qtdd
   	li $a1, 4       	 	#ate 3 pra gerar valor
	li $v0, 42				#random
	syscall
	
	#imprime o numero que gerou APAGAR DEPOIS
#	li $v0, 1
#	syscall
   	
   	#faz vetor
   	sw $a0, 0($t1)      	#vetor
   	addi $t1, $t1, 4    	#anda pelo vetor
   	addi $t0, $t0, -1    	#qtd -1
 	j random
		
	sai_gera:
	jr $ra
########################################################################	
sequencia:
	addi $sp, $sp, -40
	sw  $a0, 0($sp)				#vetor
	sw  $a1, 4($sp)				#n de ativacao
	sw  $ra, 24($sp)			#retorno
	
	move $t0, $a0				#vetor é igual t0
	li   $t1, 0					#i = 0
	move $t2, $a1				#numero de ativacao recebido pelo usuario
	li   $t3, 0					#j = 0
	
	for_maxativacao:
	bge $t3, $t2, sai_formax_toca	#if j = num de ativacao
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
			li $t1, 0				#i = 0
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
				sw $v0, 32($sp)
				beqz $v0, sai_formax_toca
				lw $t0, 8($sp)			#carrego vetor	
				lw $t1, 12($sp)			#carrego i
				lw $t2, 16($sp)			#num ativacao
				lw $t3, 20($sp)			#carrego j
			add  $t0, $t0, 4			#anda pelo vetor
			addi $t1, $t1, 1			#i++
			jal sleep_espera
			j for_sequencia2
		
		sai_sequencia:
		addi $t3, $t3, 1		#j++
		li   $t1, 0			#i = 0
	j for_maxativacao
	
	sai_formax_toca:
	lw $v0, 32($sp)
	bne $v0, 1, sai_formax
		#venceu
		li $v0, 31
		li $a0, 54
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall
		jal sleep_espera
		li $v0, 31
		li $a0, 52
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall
		jal sleep_espera
		li $v0, 31
		li $a0, 59
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall
		jal sleep_espera
		li $v0, 31
		li $a0, 54
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall
		jal sleep_espera
		li $v0, 31
		li $a0, 52
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall
		jal sleep_espera
		li $v0, 31
		li $a0, 59
		li $a1, 500
		li $a2, 24
		li $a3, 100
		syscall	
		
	sai_formax:
	lw  $ra, 24($sp)
	lw  $a1, 4 ($sp)
	lw  $a0, 0 ($sp)
	addi $sp, $sp, 40
	jr $ra
########################################################################
compara:
addi $sp, $sp, -24
sw  $a0, 0($sp)			#vetor
sw  $ra, 4($sp)			#retorno
	
	#move $t3, $a0		#VETOR
	#CHAR
	li $t0,2				# pra habilitar interrupcao
	sw $t0,0xffff0000			#habilitar teclado
	#checar ring buffer vazio ou nao
	empty_ring_loop:
		la $a0, ringbuffer
		jal rbuf_empty
		bnez $v0, empty_ring_loop
			sw $zero, 0xffff0000
			jal read
	
	lw $t1, 0($sp)
	if_0:
	bne $t1, 0, if_1
		bne $v0, 'w', else_0
			li $a0, 0
			jal acende
			#imprimir score
			li $v0, 4				#string
			la $a0, score				#le mensagem
			syscall
			li $t2, 1				#flag
			j sai_compara			
		else_0:
			#imprimir ERROU
			li $v0, 4				#string
			la $a0, loser				#le mensagem
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
			li $v0, 4			#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1			#flag
			j sai_compara
		else_2:
			#imprimir ERROU
			li $v0, 4			#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0			#flag
			j sai_compara
	if_3:
	bne $t1, 3, sai_compara
		bne $v0, 'd', else_3
			li $a0, 3
			jal acende
			#imprimir score
			li $v0, 4			#string
			la $a0, score			#le mensagem
			syscall
			li $t2, 1			#flag
			j sai_compara
		else_3:
			#imprimir ERROU
			li $v0, 4			#string
			la $a0, loser			#le mensagem
			syscall
			li $t2, 0			#flag
			j sai_compara
	
	sai_compara:
	bne $t2, 0, continua
		#perdeu
		li $v0, 31
		li $a0, 67
		li $a1, 1000
		li $a2, 96
		li $a3, 100
		syscall
		li $v0, 31
		li $a0, 66
		li $a1, 1000
		li $a2, 96
		li $a3, 100
		syscall
		li $v0, 31
		li $a0, 65
		li $a1, 1000
		li $a2, 96
		li $a3, 100
		syscall
		li $v0, 31
		li $a0, 64
		li $a1, 1000
		li $a2, 96
		li $a3, 100
		syscall
		li $v0, 31
		li $a0, 63
		li $a1, 1000
		li $a2, 96
		li $a3, 100
		syscall
	
	continua:
	lw   $ra, 4($sp)
	lw   $a0, 0 ($sp)
	addi $sp, $sp, 24
	move $v0, $t2
	jr $ra
########################################################################
acende:
	addi $sp, $sp, -24
	sw   $ra, 8($sp)
	sw   $a0, 0($sp)    	#elemento vetor

	verde_0:
		lw $a0, 0($sp)
		bne $a0, 0, azul_1	#acende verde claro
		
		#TOCANDO MUSICA
		li $a0, 61			#tom
		move $a1, $s7		#velocidade
		li $a2, 24			#instrumento
		li $a3, 50			#volume
		li $v0, 31
		syscall
		
		lw $a0, 0($sp)
		li $a3, 0x00FF00	#verde claro
		jal verde_claro
		jal sleep
		li $a3, 0x135C0A	#verde escuro
		jal verde_claro				
		jal sleep
				
	azul_1:
		
		lw $a0, 0($sp)
		bne $a0, 1, amarelo_2	#acende azul claro 
		
		#TOCANDO MUSICA
		
		li $a0, 62
		move $a1, $s7		#velocidade
		li $a2, 24
		li $a3, 50
		li $v0, 31
		syscall
		
		lw $a0, 0($sp)
		li $a3, 0x00BFFF	#azul claro
		jal azul_claro
		jal sleep
		li $a3, 0x0C0273	#azul escuro
		jal azul_claro	
		jal sleep

						
	amarelo_2:
		
		lw $a0,  0($sp)
		bne $a0, 2, vermelho_3	#acende amarelo claro
		
		#TOCANDO MUSICA
		
		li $a0, 63
		move $a1, $s7		#velocidade
		li $a2, 24
		li $a3, 50
		li $v0, 31
		syscall
		
		lw $a0, 0($sp)		 
		li $a3, 0xFFFF00	#amarelo claro
		jal amarelo_claro
		jal sleep
		li $a3, 0x80730D	#amrelo escuro
		jal amarelo_claro	
		jal sleep
	
	vermelho_3:
		
		lw $a0,  0($sp)
		bne $a0, 3, sai_acende	#acende vermelho claro 
		#TOCANDO MUSICA
		
		li $a0, 64
		move $a1, $s7		#velocidade
		li $a2, 24
		li $a3, 50
		li $v0, 31
		syscall
		
		lw $a0, 0($sp)		
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
sleep:	#sleep:
	li $v0, 32 			#sleep
	move $a0, $s7	 	#velocidade
	syscall
	jr $ra 
#########################################################################
sleep_espera:	
	li $v0, 32 			#sleep
	li $a0, 500	 		#velocidade
	syscall
	jr $ra 
#ESCREVE##################################################################
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
	li   $t0, 0x10010000		#t3 = endereco base
	sll  $t1, $a0, 5		#y = y * 512/16  -  vertical -2^5=16 -> 16+16 -> 16x16 bloco de 32
	addu $t1, $a1, $t1		# adds x, y to the first pixel (t0)- horizontal
	sll  $t1, $t1, 2		#1 pixel - 4 bytes	
	add  $t0, $t0, $t1	 	#endereco base
	li $t2, 0
escreve_c:
	beq $t2, $a2, return_c
		#escreve
		sw   $a3, 0($t0)    	#put the color branc ($a2) in $t0
		addi $t0, $t0, 128	#anda pelo vetor 4*tl -> tl = 32 
		addi $t2, $t2, 1	#int posicao do pixel
	j escreve_c
	return_c:
	jr $ra
###################################################################################
#RING BUFFER
init:
	sw $zero, 0($a0)		#rbuf[size]
	sw $zero, 4($a0)		#rbuf[wr]
	sw $zero, 8($a0)		#rbuf[rd]
	jr $ra

read:
	addi $sp, $sp, -8
	sw $ra, 0($sp)

 	li $t0, 0      			#tmp = 0
 	jal rbuf_empty     		#rbuf_empty(rbuf)
  	move $t1, $v0      		#t1 = v0
 	bnez  $t1, rbuf_empty_c   	#continua - verdadeiro(1) se tiver vazio
 		move $v0, $t0    
    		lw   $t2, 0($a0)      	#t2 = size
    		subi $t2, $t2, 1    	#t2 = size--
    		sw   $t2, 0($a0)
    		
    		#tmp = rbuf->buf[rbuf->rd]
    		lw   $t1, 8($a0)      	#acesso - rbuf->rd
    		addi $t3, $a0, 12    	#endereco do buf - &rbuf->buf[0]
    		add  $t4, $t3, $t1    	#&rbuf->buf[rbuf->rd]
    		lbu  $t5, 0($t4)    	#rbuf->buf[rbuf->rd] - CHAR
    		add  $t0, $zero, $t5    #tmp = rbuf->buf[rbuf->rd]
    		#rbuf->rd = (rbuf->rd + 1) % MAX_SIZE
    		addi $t1, $t1, 1    	#rbuf->rd + 1
    		li   $t6, 16      	#MAX_SIZE
    		remu $t4, $t3, $t6    	#(rbuf->rd + 1) % MAX_SIZE
    		sw   $t4, 8($a0)      	#rbuf->rd = (rbuf->rd + 1) % MAX_SIZE
    		move $v0, $t0      	#v0 = tmp
   	rbuf_empty_c:
   	lw $ra, 0($sp)
   	addi $sp, $sp, 8
    	jr $ra
    	
rbuf_empty:
	lw   $t0, 0($a0)		#t0 = size
	beqz $t0, if_empty		#rbuf->size == 0
		li  $v0, 0		#return 0
		jr  $ra
	if_empty:
	li $v0, 1			#return 1
	jr $ra

rbuf_full:
	lw $t0, 0($a0)
	beq $t0, 16, if_full	#rbuf->size == MAX_SIZE
	li, $v0, 0				#return 0
	jr $ra
	
	if_full:
	li $v0, 1				#return 1
	jr $ra
	
write_ring:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	
  	move $t0, $a0    #t0 = *rbuf
	move $t1, $a1    #t1 = byte
  
  	jal rbuf_full      #rbuf_empty(rbuf)
  	move  $t2, $v0      #v0 = t2
  	beqz  $t2, rbuf_full_c    #continua
 	li    $v0, 0      # return 0
 	
	lw $ra, 0($sp)
	addi $sp, $sp, 8
  	jr    $ra
  
  		rbuf_full_c:
    		lw $t2, 0($a0)      #t2 = size
    		addi $t2, $t2, 1    #t2 = size++
    		sw $t2, 0($a0)      #t2 = size
  
  
   		 #rbuf->buf[rbuf->wr] = byte
    		lw  $t2, 4($a0)      #rbuf->wr
   		add $t3, $a0, 12     #&rbuf->buf[0]
		# sll $t2, $t2, 2      #rbuf->wr = t2 => t2*4 - CHAR
    		add $t4, $t3, $t2    #&rbuf->buf[rbuf->wr]
    		sb  $a1, 0($t4)      #rbuf->wr[rbuf->wr] = byte
  
   		 #rbuf->wr = (rbuf->wr + 1) % MAX_SIZE
    		addi $t2, $t2, 1    #rbuf->wr + 1
    		li   $t6, 16      #MAX_SIZE
   		remu $t4, $t3, $t6    #(rbuf->wr + 1) % MAX_SIZE
   		sw   $t4, 4($a0)    #rbuf->wr = (rbuf->wr + 1) % MAX_SIZE
    		li $v0, 1      #return 1
    		lw $ra, 0($sp)
		addi $sp, $sp, 8
    		jr $ra

############################################################################
.ktext 0x80000180

addi $sp, $sp, -8
sw $ra, 0($sp)
sw $s0, 4($sp)

	lb $a1, 0xffff0004
	la $a0, ringbuffer			# space 32
	la $s0, write_ring
	jalr $s0

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp,8
	li $t0, 2
	sw $zero, 0xffff0004
	sw $t0, 0xffff0000
	li $t0, 0x0000ff11
eret					#seta o coprocessador 0 para 0
######################################################################################

	
