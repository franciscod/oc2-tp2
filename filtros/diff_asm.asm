default rel
global _diff_asm
global diff_asm
extern printf

section .data

	mask db 15,15,15,15,11,11,11,11,7,7,7,7,3,3,3,3
	fmt db '%ld', 10, 0

section .text

;void diff_asm(unsigned char *src, unsigned char *src2, unsigned char *dst, int filas, int cols)
_diff_asm:
diff_asm:

	mov r9, rdx

	xor rax, rax
	xor rdx, rdx
	mov eax, ecx
	mul r8d
	mov rcx, rdx
	shl rcx, 32
	mov ecx, eax
	shr rcx, 2

	mov eax, 255

	pxor xmm5, xmm5
	movups xmm7, [mask]

	.ciclo:
		movups xmm1, [rdi]
		movups xmm2, [rsi]
		
		movups xmm3, xmm1
		movups xmm4, xmm2

		punpcklbw xmm1, xmm5
		punpckhbw xmm3, xmm5

		punpcklbw xmm2, xmm5
		punpckhbw xmm4, xmm5

		psubw xmm1, xmm2
		psubw xmm3, xmm4

		pabsw xmm1, xmm1
		pabsw xmm2, xmm2
		pabsw xmm3, xmm3
		pabsw xmm4, xmm4
		
		packuswb xmm1, xmm3

		;Copio xmm1 en xmm2 para poder buscar el maximo
		movups xmm2, xmm1
		
		;Comparo el canal R con el canal G y luego el resultado lo comparo con el canal B
		pslldq xmm2, 1		; Me muevo un byte a la izquierda
		pmaxub xmm1, xmm2
		pslldq xmm2, 1		; Me muevo un byte a la izquierda
		pmaxub xmm1, xmm2

		;Pongo el maximo que hasta ahora tengo en el canal R de cada pixel en todos los canales
		pshufb xmm1, xmm7
		
		;Pongo los alfa en 255
		pinsrb xmm1, eax, 3
		pinsrb xmm1, eax, 7
		pinsrb xmm1, eax, 11
		pinsrb xmm1, eax, 15
		
		movups [r9], xmm1
		add r9, 16
		add rdi, 16
		add rsi, 16
		
		dec rcx
	jnz .ciclo
	ret
