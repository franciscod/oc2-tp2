default rel
global _blur_asm
global blur_asm

extern malloc, free
extern printf
extern G_sigma
extern imprimir_mat

%define FLOAT_SIZE  4
%define PIXEL_SIZE  4

; %define DEBUG       1


section .data

    mask_blue:          db 0x0C, 0xFF, 0xFF, 0xFF, 0x08, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF
    mask_green:         db 0x0D, 0xFF, 0xFF, 0xFF, 0x09, 0xFF, 0xFF, 0xFF, 0x05, 0xFF, 0xFF, 0xFF, 0x01, 0xFF, 0xFF, 0xFF
    mask_red:           db 0x0E, 0xFF, 0xFF, 0xFF, 0x0A, 0xFF, 0xFF, 0xFF, 0x06, 0xFF, 0xFF, 0xFF, 0x02, 0xFF, 0xFF, 0xFF
    ;format_hex:         db 'ESTE ES TU ENTERO PIBE %x', 10, 0

section .text
;void blur_asm    (
    ;unsigned char *src,
    ;unsigned char *dst,
    ;int COLUMNAS,
    ;int FILAS,
    ;float sigma,
    ;int radius)

_blur_asm:
blur_asm:

    ; rdi = puntero matriz entrada
    ; rsi = puntero matriz salida
    ; rdx = COLUMNAS
    ; rcx = FILAS
    ; xmm0 = sigma
    ; r8 = radio

	push rbp
	mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
	sub rsp, 8

    xor r14, r14
    xor r15, r15
    xor rbx, rbx

    mov r12, rdi                                    ; r12 = puntero matriz entrada
    mov r13, rsi                                    ; r13 = puntero matriz salida
    mov r14d, ecx                                   ; r14 = FILAS
    mov r15d, edx                                   ; r15 = COLUMNAS
    mov ebx, r8d                                    ; rbx = radio

	mov rdi, rbx
	; el sigma ya esta en xmm0
	call generar_matriz_convolucion
	mov r11, rax                                    ; r11 = matriz de convolucion

	; rdi puntero al inicio de la conv en imagen original
    ; rsi inicio matriz convolucion
	; rdx cant columnas imagen
    ; rcx lado mat convolucion
	; mov rdi, r12
	; mov rsi, rax
	; mov rdx, r15
	; mov rcx, rbx
	; imul rcx, 2
	; inc rcx
	; call calcular_pixel

	; en rax esta la convolucion del principio

	;recorro filas adentro del marquito
    mov r8, rbx                                      ; r8 = y            radio hasta filas - radio
    .filas:

        mov r10, r14
        sub r10, rbx
        cmp r8, r10                                 ; me fijo si llego a filas - radio
        je .fin_filas

		; ;recorro columnas adentro del marquito
        mov r9, rbx                                 ; r9 = x             radio hasta columnas - radio
        .columnas:

            mov r10, r15
            sub r10, rbx
            cmp r9, r10                             ; me dijo si llego a columnas - radio
            je .fin_columnas

            push r8
            push r9
            push r11
            sub rsp, 8

            ; rdi puntero al inicio de la conv en imagen original
            ; rsi inicio matriz convolucion
            ; rdx cant columnas imagen
            ; rcx lado mat convolucion

            mov r10, r8
			sub r10, rbx
			; r10 es y-r
            imul r10, r15
			; r10 es (y-r) * cols
            add r10, r9                             ; hasta aca r10 tiene la posicion en la imagen, me falta restarle restarle el radio en x e y, para obtener la posicion al inicio de la con en la imagen original
			; r10 es (y-r) * cols + x
            sub r10, rbx                            ; resto en x
			; r10 es (y-r) * cols + x - r

            imul r10, PIXEL_SIZE                    ; r10 = offset para el inicio de la conv en imagen original
			; r10 es ((y - r) * cols + x - r) * 4

            mov rdi, r12
            add rdi, r10

            mov rsi, r11
            mov rdx, r15
            mov rcx, rbx
            imul rcx, 2
            inc rcx

            call calcular_pixel                     ; devuelve en rax el pixel resultante como 4 bytes BGRA

            add rsp, 8
            pop r11
            pop r9
            pop r8

            ; guardo el pixel resultante en la matriz destino

            mov r10, r8
            imul r10, r15
            add r10, r9                             ; r10 = posicion en la matriz destino

            shl r10, 2

            mov [r13 + r10], eax       ; guardo el pixel en: inicioMatDest + (y * columnas + x) * tamaño_pixel

            inc r9
            jmp .columnas

        .fin_columnas:

        inc r8
        jmp .filas

    .fin_filas:

	add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
	pop rbp
	ret


calcular_pixel:
	; rdi puntero al inicio de la conv en imagen original
    ; rsi inicio matriz convolucion
	; rdx cant columnas imagen
    ; rcx lado mat convolucion

	; devuelve en rax el pixel resultante como 4 bytes BGRA

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	mov r12, rdi ; puntero al inicio de la conv en imagen original
	mov r13, rsi ; inicio matriz convolucion
	mov r14, rdx ; cant columnas imagen
	mov r15, rcx ; lado mat convolucion (2r+1)


	; %ifdef DEBUG
	; 		mov rdi, r13
	; 		mov rsi, r15
	; 		mov rdx, r15
	; 		call imprimir_mat
	; %endif

	;                                                       0123
	; devuelve en rax el valor de la convolucion como pixel BGRA

	; Voy a usar estos registros para acumular las componentes
	pxor xmm0, xmm0        ; xmm0 = acumulador float :  azul | verde | rojo | 0


    ; Seteo unas mascaras para separar las componentes
    movdqu xmm13, [mask_blue]
    movdqu xmm14, [mask_green]
    movdqu xmm15, [mask_red]

    xor r8, r8                                  ; r8 = indice fila
    .filas:
	; esto procesa 1 fila
        cmp r8, r15
        je .fin_filas

        xor r9, r9                                  ; r9 = indice columna
        .columnas:
		; esto procesa 4 pixels de una fila (o 3 o 1)

			mov r10, r8
			imul r10, r14 ; cant columnas imagen
			add r10, r9
			shl r10, 2 ; multiplicamos por 16 el offset

			mov r11, r8
			imul r11, r15 ; lado mat convolucion
			add r11, r9
			shl r11, 2 ; multiplicamos por 4 el offset

			movdqu xmm3, [r12+r10]                  ; xmm1 = vector imagen entrada
			.pepito:
			movups xmm4, [r13+r11]                  ; lee 4 floats de convolucion desalineado


			; Agrupo por componente (todos los azules por un lado...) usando un shuffle
			movdqu xmm5, xmm3                   ; xmm5 va a contener solo las componentes azules
			movdqu xmm6, xmm3                   ; xmm6 va a contener solo las componentes verdes
			movdqu xmm7, xmm3                   ; xmm7 va a contener solo las componentes rojas

			pshufb xmm5, xmm13                   ; xmm5 = B0 | 0 | 0 | 0 | B1 | 0 | 0 | 0 | B2 | 0 | 0 | 0 | B3 | 0 | 0 | 0
			pshufb xmm6, xmm14                   ; xmm6 = G0 | 0 | 0 | 0 | G1 | 0 | 0 | 0 | G2 | 0 | 0 | 0 | G3 | 0 | 0 | 0
			pshufb xmm7, xmm15                   ; xmm7 = R0 | 0 | 0 | 0 | R1 | 0 | 0 | 0 | R2 | 0 | 0 | 0 | R3 | 0 | 0 | 0

			; Convierto a float
			cvtdq2ps xmm5, xmm5
			cvtdq2ps xmm6, xmm6
			cvtdq2ps xmm7, xmm7

			mov rax, r15
			sub rax, r9
            cmp rax, 4
            jge .dpps_4
			cmp rax, 3
			je .dpps_3
			jl .dpps_1

			; ahora llamamos a esta funcion que tiene toda la posta (?)
			; hace el producto interno entre los dos parametros y segun el inmediato que le pasas
			; despues definis que componentes se usan y a donde manda el resultado

			.dpps_4:
				; Voy multiplicando 4 vs 4 entre convolucion y componente k de cada pixel
				dpps xmm5, xmm4, 0xF1
				dpps xmm6, xmm4, 0xF2
				dpps xmm7, xmm4, 0xF4
				jmp .dpps_fin

			.dpps_3:
				dpps xmm5, xmm4, 0x71
				dpps xmm6, xmm4, 0x72
				dpps xmm7, xmm4, 0x74
				jmp .dpps_fin

			.dpps_1:
				dpps xmm5, xmm4, 0x11
				dpps xmm6, xmm4, 0x12
				dpps xmm7, xmm4, 0x14
				jmp .dpps_fin

			.dpps_fin:
				addps xmm0, xmm5
				addps xmm0, xmm6
				addps xmm0, xmm7

			mov rax, r15
			sub rax, r9
            cmp rax, 4
            jl .fin_col

			add r9, 4
			jmp .columnas

        .fin_col:

        inc r8
        jmp .filas

	.fin_filas:

	; Los redondeo a byte
	cvtps2dq xmm0, xmm0

	; empaquetamos
	pxor xmm1, xmm1
	packusdw xmm0, xmm1
	packuswb xmm0, xmm1

	xor rax, rax
	movd eax, xmm0
	or eax, 0xFF000000 ; clava el alpha en 255

	%ifdef DEBUG
			push rax
			push rax

			mov rdi, format_hex
			mov rsi, rax
;			call printf

			pop rax
			pop rax
	%endif

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


%define SIGMA_PILA rbp-16
generar_matriz_convolucion:

    ; rdi = radio
    ; xmm0 = sigma

	push rbp
	mov rbp, rsp
	sub rsp, 24
	movdqu [SIGMA_PILA], xmm0
	push rbx
	push r12	; 2r+1
	push r13    ; radio
	push r14    ; indice y (filas)
	push r15    ; indice x (columnas)
	mov r13, rdi

    ; Calculo el tamaño en bytes de la matriz = (radio * 2 + 1)² * tamaño_float
    imul rdi, 2
    inc rdi
	mov r12, rdi
    ; solo porque no funciona imul rdi, rdi. r10 = (radio * 2) + 1
    imul rdi, r12
    imul rdi, FLOAT_SIZE

    ; Reservo memoria para la matriz de convolucion
    call malloc
	mov rbx, rax	; rbx = puntero a la matriz de convolucion


    ; Genero la matriz de convolucion

    xor r14, r14                                      ; r14 = indice fila
    .filas:
        cmp r14, r12
        je .fin_convolucion

        xor r15, r15                                  ; r15 = indice columna
        .columnas:
            cmp r15, r12
            je .fin_fila


            mov rdi, r13
            sub rdi, r14                             ; rdi = y = radio - fila

            mov rsi, r13
            sub rsi, r15                             ; rsi = x = radio - columna

			movdqu xmm0, [SIGMA_PILA]				; xmm0 = sigma
            call G_sigma							; xmm0 = coeficiente

            mov r11, r14  ; r11 = y
            imul r11, r12 ; r11 = y * (2r+1)
            add r11, r15                            ; r11 = y * filas + x (indice)

            movd [rbx + r11 * FLOAT_SIZE], xmm0  ; Asigno el resultado de G_sigma a la posicion correspondiente de la matriz

            inc r15
            jmp .columnas

        .fin_fila:

        inc r14
        jmp .filas

	.fin_convolucion:

	mov rax, rbx ; devuelve base de la matriz

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	add rsp, 24
	pop rbp
	ret
