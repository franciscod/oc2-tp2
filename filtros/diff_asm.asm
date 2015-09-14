default rel
global _diff_asm
global diff_asm


section .data



section .text
;void diff_asm    (
	;unsigned char *src,
    ;unsigned char *src2,
	;unsigned char *dst,
	;int filas,
	;int cols)

_diff_asm:
diff_asm:
	and rcx, 0x0000000011111111
	imul ecx, r8d
	
	.ciclo:
		movups xmm1, [rdi]
		movups xmm2, [rsi]
		psubusb xmm1, xmm2
		pslld xmm2, xmm1
		pmaxub xmm1, xmm2
		
	loop .ciclo

    ret
