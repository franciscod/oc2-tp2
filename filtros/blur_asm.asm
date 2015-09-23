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
    ; ; rcx = columnas
    ; ; xmm0 = sigma
    ; ; r8 = radio

    ; mov r12, rdi                                    ; r12 = puntero matriz entrada
    ; mov r13, rsi                                    ; r13 = puntero matriz salida
    ; mov r14, rdx                                    ; r14 = filas
    ; mov r15, rcx                                    ; r15 = columnas
    ; mov rbx, r8                                     ; rbx = radio
    ; ; push xmm0                                       ; Guardo sigma

    ; ; Calculo el tamaño en bytes de la matriz = (radio * 2 + 1)^2 * tamaño_double
    ; mov rdi, rbx
    ; add rdi, rdi
    ; inc rdi
    ; imul rdi, rdi
    ; imul rdi, DOUBLE_SIZE

    ; mov rsi, rdi
    ; mov rdi, msg
    ; mov rax, 1
    ; call printf

    ; call malloc

    ret
