default rel
global _diff_asm
global diff_asm


section .data

	mask db 15,15,15,15,11,11,11,11,7,7,7,7,3,3,3,3


section .text

;void diff_asm(unsigned char *src, unsigned char *src2, unsigned char *dst, int filas, int cols)
_diff_asm:
diff_asm:

	and rcx, 0x0000000011111111
	imul ecx, r8d
	mov eax, 255	

	.ciclo:
		movups xmm1, [rdi]
		movups xmm2, [rsi]
		psubb xmm1, xmm2 ;TENGO QUE VER EL CASO EN QUE RESTO ALGO MAS GRANDE A ALGO MAS CHICO
		
		;Copio xmm1 en xmm2 para poder buscar el maximo
		movups xmm2, xmm1
		
		;Comparo el canal R con el canal G y luego el resultado lo comparo con el canal B
		pslldq xmm2, 1		; Me muevo un byte a la izquierda
		pmaxub xmm1, xmm2
		pslldq xmm2, 1		; Me muevo un byte a la izquierda
		pmaxub xmm1, xmm2
		
		;Pongo el maximo que hasta ahora tengo en el canal R de cada pixel en todos los canales
		movups xmm2, [mask]
		pshufb xmm1, xmm2
		
		;Pongo los alfa en 255
		pinsrb xmm1, eax, 3
		pinsrb xmm1, eax, 7
		pinsrb xmm1, eax, 11
		pinsrb xmm1, eax, 15
	loop .ciclo

	ret
