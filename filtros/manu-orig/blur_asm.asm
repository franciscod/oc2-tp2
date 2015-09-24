default rel
global _blur_asm
global blur_asm

extern malloc
extern printf

%define DOUBLE_SIZE 8
%define PI          3.14159265358979323846


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
    mov r14, rdx                                    ; r14 = filas
    mov r15, rcx                                    ; r15 = columnas
    mov rbx, r8                                     ; rbx = radio
    sub rsp, 16
    movdqu [rsp], xmm0                              ; meto sigma en la pila 

    ; mov rdi, msg
    ; push r10
    ; call printf
    ; pop r10

    ; Calculo el tamaño en bytes de la matriz = (radio * 2 + 1)² * tamaño_double
    mov rdi, rbx
    imul rdi, 2
    inc rdi
    mov r10, rdi                                    ; solo porque no funciona imul rdi, rdi. r10 = (radio * 2) + 1
    push r10                                        ; lo guardo en la pila para usarlo en el futuro
    imul rdi, r10
    imul rdi, DOUBLE_SIZE

    ; Reservo memoria para la matriz de convolucion
    call malloc                                     ; rax = puntero a la matriz de convolucion

    ; Seteo algunas variables que van a ser usadas
    pop r10                                         ; r10 = (radio * 2) + 1

    movdqu xmm0, [rsp]                              ; xmm0 = sigma (Lo recupero de la pila)
    add rsp, 16

    movdqu xmm1, xmm0
    ; imul xmm0, xmm1
    ; add xmm0, xmm0                                  ; xmm0 = 2 * sigma²

    movdqu xmm1, xmm0
    ; imul xmm1, PI                                   ; xmm1 = 2 * sigma² * pi

    ; mov rdi, msg
    ; push r10
    ; call printf
    ; pop r10
    
    ; Genero la matriz de convolucion
    xor r8, r8                                      ; r8 = indice fila
    filas:
        cmp r8, r10
        je fin_convolucion

        xor r9, r9                                  ; r9 = indice columna
        columnas:
            cmp r9, r10
            je fin_fila

            mov rdi, rbx
            sub rdi, r8                             ; rdi = x = radio - fila
            mov r11, rdi
            imul rdi, r11                           ; rdi = x² = (radio - fila)²

            mov rsi, rbx
            sub rsi, r9                             ; rsi = y = radio - columna
            mov r11, rsi
            imul rsi, r11                           ; rsi = x² = (radio - columna)²

            add rdi, rsi                            ; rsi = x² + y²

            inc r9
            jmp columnas

        fin_fila:

        inc r8
        jmp filas


    fin_convolucion:

    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret
