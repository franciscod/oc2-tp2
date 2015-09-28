default rel
global _blur_asm
global blur_asm

extern malloc
extern printf
extern G_sigma
extern imprimir_mat

%define FLOAT_SIZE 4
%define PI         3.14159265358979323846


section .data

    msg: db '%f', 10


section .text
;void blur_asm    (
    ;unsigned char *src,
    ;unsigned char *dst,
    ;int filas,
    ;int cols,
    ;float sigma,
    ;int radius)

_blur_asm:
blur_asm:

    ; rdi = puntero matriz entrada
    ; rsi = puntero matriz salida
    ; rdx = filas
    ; rcx = columnas
    ; xmm0 = sigma
    ; r8 = radio

    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi                                    ; r12 = puntero matriz entrada
    mov r13, rsi                                    ; r13 = puntero matriz salida
    xor r14, r14
    mov r14d, edx                                   ; r14 = filas
    xor r15, r15
    mov r15d, ecx                                   ; r15 = columnas
    xor rbx, rbx
    mov ebx, r8d                                    ; rbx = radio
    sub rsp, 16
    movdqu [rsp], xmm0                              ; meto sigma en la pila 

    ; Calculo el tamaño en bytes de la matriz = (radio * 2 + 1)² * tamaño_double
    mov rdi, rbx
    imul rdi, 2
    inc rdi
    mov r10, rdi                                    ; solo porque no funciona imul rdi, rdi. r10 = (radio * 2) + 1
    push r10                                        ; lo guardo en la pila para usarlo en el futuro
    imul rdi, r10
    imul rdi, FLOAT_SIZE

    ; Reservo memoria para la matriz de convolucion
    call malloc                                     ; rax = puntero a la matriz de convolucion

    ; Seteo algunas variables que van a ser usadas
    pop r10                                         ; r10 = (radio * 2) + 1

    movdqu xmm0, [rsp]                              ; xmm0 = sigma (Lo recupero de la pila)
    add rsp, 16
    
    ; Genero la matriz de convolucion
    xor r8, r8                                      ; r8 = indice fila
    .filas:
        cmp r8, r10
        je .fin_convolucion

        xor r9, r9                                  ; r9 = indice columna
        .columnas:
            cmp r9, r10
            je .fin_fila

            mov rdi, rbx
            sub rdi, r8                             ; rdi = x = radio - fila

            mov rsi, rbx
            sub rsi, r9                             ; rsi = y = radio - columna

            sub rsp, 16
            movdqu [rsp], xmm0
            push rax
            push r8
            push r9
            push r10
            sub rsp, 8

            call G_sigma

            add rsp, 8
            pop r10
            pop r9
            pop r8
            pop rax

            mov r11, r8
            imul r11, r10
            add r11, r9                             ; r11 = fila * columnas + columna (indice)

            movdqu [rax + r11 * FLOAT_SIZE], xmm0  ; Asigno el resultado de G_sigma a la posicion correspondiente de la matriz

            movdqu xmm0, [rsp]                      ; xmm0 = sigma (Lo recupero de la pila)
            add rsp, 16

            inc r9
            jmp .columnas

        .fin_fila:

        inc r8
        jmp .filas


    .fin_convolucion:

    ; push rax
    ; mov rdi, rax
    ; mov rsi, r10
    ; mov rdx, r10
    ; call imprimir_mat
    ; pop rax

    ; Recorro la imagen
    mov rsi, r10
    imul rsi, r10                                   ; rsi = (radio * 2 + 1)^2 = cantidad de pixeles
    mov r8, rbx                                     ; r8 = indice fila empezando por radio
    mov r10, r14
    sub r10, rbx                                    ; r10 = filas - radio
    .filas_imagen: 
        cmp r8, r10
        je .fin

        mov r9, rbx                                 ; r9 = indice columna empezando por radio
        mov r11, r15
        sub r11, rbx                                ; r11 = columnas - radio
        .columnas_imagen:
            cmp r9, r11
            je .fin_columnas_imagen

            push r12                                ; Me guardo la dir de la imagen de entrada
            push rax                                ; Me guardo la dir de la mat de convolucion

            xor rdi, rdi                            ; rdi = indice de convolucion
            .recorer_conv:
            
                ; Tengo que tener en cuenta en que posicion estoy por la no-divisibilidad
                mov rdx, rsi
                sub rdx, rdi                        ; rdx = cantidad de pixeles - indice
                cmp rdx, 4
                jl .ultimos_pixeles

                ; Agarro de a 4 floats de la matriz de convolucion
                movups xmm0, [rax]                  ; xmm0 = vector convolucion

                ; Agarro 4 pixeles, 4 bytes cada uno. 1 byte por cada componente
                movups xmm1, [r12]                  ; xmm1 = vector imagen entrada

                ; Agrupo por componente (todos los azules por un lado...) usando un shuffle


                ; Avanzo de a 4 pixeles = 16 bytes
                add r12, 16
                add rax, 16
                add rdi, 4
                jmp .recorer_conv

            .ultimos_pixeles:

            pop rax
            pop r12
            
                ; Convierto a float
                ; Voy multiplicando 4 vs 4 entre convolucion y componente k de cada pixel
                ; Me quedan 4 vectores, uno con cada componente multiplicada
                ; Acumulo cada uno en un xmm que cuando termine voy a shiftear y sumar
                ; Termino la sumatoria y me quedan 3 xmm (el alpha ya se que es 255) con los valores
                ; Tengo que pasarlos a byte y asignarlos a la imagen destino

            inc r9
            jmp .columnas_imagen

        .fin_columnas_imagen:

        inc r8
        jmp .filas_imagen


    .fin:

    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret
