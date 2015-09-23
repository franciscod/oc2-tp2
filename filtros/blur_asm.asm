default rel
global _blur_asm
global blur_asm

extern malloc
extern printf

%define DOUBLE_SIZE 8


section .data

    msg: db '%d', 10


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
    sub rsp, 8

    mov r12, rdi                                    ; r12 = puntero matriz entrada
    mov r13, rsi                                    ; r13 = puntero matriz salida
    mov r14, rdx                                    ; r14 = filas
    mov r15, rcx                                    ; r15 = columnas
    mov rbx, r8                                     ; rbx = radio

    ; Calculo el tamaño en bytes de la matriz = (radio * 2 + 1)^2 * tamaño_double
    mov rdi, rbx
    imul rdi, 2
    inc rdi
    mov r10, rdi                                    ; solo porque no funciona imul rdi, rdi
    imul rdi, r10
    imul rdi, DOUBLE_SIZE

    call malloc

    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp

    ret
