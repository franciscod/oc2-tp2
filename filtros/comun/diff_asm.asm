default rel
global _diff_asm
global diff_asm

;;;; Diff en ASM:
;; Lo primero que hacemos es calcular la cantidad de veces que se va a
;; recorrer el ciclo. Para esto, multiplicamos las columnas por las filas.
;; Esto nos da la cantidad de pixeles que tiene la imagen. Luego, como vamos
;; a procesar 4 pixeles por ciclo, dividimos este numero por 4 para obtener asi
;; la cantidad de vueltas que debemos dar.
;;
;;;; Ciclo:
;; Traigo 4 pixeles de cada imagen a un registro xmm y luego desempaqueto cada
;; coordenada (byte a word) para poder hacer la resta sin perder informacion.
;; Tomo valor absoluto de cada pixel y vuelvo a empaquetar el resultado
;; en un solo registro.
;; Ahora copio el registro a otro que voy a shiftear para poder calcular la
;; componente maxima de cada pixel. Tengo que hacer 2 veces el shift y luego
;; la comparacion para asi quedarme con el maximo de las 3 componentes.
;; Ahora utilizo una mascara creada previamente para poner los maximos obtenidos
;; en todas las componentes de cada pixel.
;; Por ultimo pongo en 255 las componentes alfa.
;; Guardo los pixeles en la memoria donde se va a devolver el resultado, avanzo
;; los en 4 pixeles (16 bytes).

section .data

	; Mascara para poner el resultado del maximo de las componentes en todas ellas
	;mask db 15,15,15,15,11,11,11,11,7,7,7,7,3,3,3,3
	mask db 0,0,0,0,4,4,4,4,8,8,8,8,12,12,12,12

section .text

;void diff_asm(unsigned char *src, unsigned char *src2, unsigned char *dst, int filas, int cols)
_diff_asm:
diff_asm:

	; Guardo en r9 la cantidad de filas porque voy a necesitar rdx para la multiplicacion
	mov r9, rdx

	; Muevo las columnas a eax para multiplicarlas por las filas
	mov eax, ecx

	; Multiplico las columnas por las filas para obtener la cantidad de pixeles
	mul r8d

	; Muevo a ecx la parte alta del resultado de la multiplicacion
	mov ecx, edx

	; Shifteo la parte alta del resultado de la multiplicacion a la parte alta de rcx
	shl rcx, 32

	; Pongo en la parte baja de rcx la parte baja del resultado de la multiplicacion
	mov ecx, eax

	; Divido la cantidad de pixeles por 4. Dado por cada ciclo voy a procesar 4 pixeles
	shr rcx, 2

	; Lo voy a usar mas adelante dentro del ciclo para poner las coordenadas alfa de cada pixel en 255
	mov eax, 255

	; Limpio xmm5. Lo voy a usar para desempaquetar los pixeles mas adelante dentro del ciclo
	pxor xmm5, xmm5

	; pongo en xmm7 la mascara que voy a usar para poner el valor de la maxima coordenada en todas
	movups xmm7, [mask]

	.ciclo:
		; Traigo 4 pixeles de cada imagen desde la memoria
		movups xmm1, [rdi]
		movups xmm2, [rsi]

		; Desempaqueto los pixeles (cada componente pasa a ocupar una word) para poder hacer la resta sin perder informacion
		movups xmm3, xmm1
		movups xmm4, xmm2

		punpcklbw xmm1, xmm5
		punpckhbw xmm3, xmm5

		punpcklbw xmm2, xmm5
		punpckhbw xmm4, xmm5

		; Resto los pixeles de ambas imagenes. El resultado queda en xmm1 y xmm3
		psubw xmm1, xmm2
		psubw xmm3, xmm4

		; Obtengo el valor absoluto de la resta de los pixeles
		pabsw xmm1, xmm1
		pabsw xmm3, xmm3

		; Empaqueto el resultado nuevamente en un solo registro.
		packuswb xmm1, xmm3

		; Copio xmm1 en xmm2 para poder buscar el maximo
		movups xmm2, xmm1

		; Comparo el canal R con el canal G y luego el resultado lo comparo con el canal B
		psrldq xmm2, 1		; Me muevo un byte a la derecha
		pmaxub xmm1, xmm2
		psrldq xmm2, 1		; Me muevo un byte a la derecha
		pmaxub xmm1, xmm2

		; Pongo el maximo que hasta ahora tengo en el canal R de cada pixel en todos los canales
		pshufb xmm1, xmm7

		; Pongo los alfa en 255
		pinsrb xmm1, eax, 3
		pinsrb xmm1, eax, 7
		pinsrb xmm1, eax, 11
		pinsrb xmm1, eax, 15

		; Muevo los pixeles con el filtro aplicado a dst
		movups [r9], xmm1

		; Incremento los punteros a src, src2 y dst
		add r9, 16
		add rdi, 16
		add rsi, 16

		; Repito lo mismo para todos los pixeles de mis imagenes
		loop .ciclo
	ret
