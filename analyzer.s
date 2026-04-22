.data
    fmt_out: .asciz "Resultados (Variante A):\nRespuestas (2xx): %ld\nErrores Cliente (4xx): %ld\nErrores Servidor (5xx): %ld\n"

.bss
    buffer: .space 4096

.text
    .global main
    .align 2

main:
    stp x29, x30, [sp, -16]!
    mov x19, 0      // Contador 2xx
    mov x20, 0      // Contador 4xx
    mov x21, 0      // Contador 5xx
    mov x25, 1      // Bandera inicio de linea

read_buffer:
    mov x0, 0       // fd=0 (stdin)
    adrp x1, buffer
    add x1, x1, :lo12:buffer
    mov x2, 4096
    mov x8, 63      // sys_read
    svc 0

    cmp x0, 0
    ble end_read

    mov x22, x0     // bytes leidos
    adrp x23, buffer
    add x23, x23, :lo12:buffer

parse_char:
    cbz x22, read_buffer
    ldrb w24, [x23], 1
    sub x22, x22, 1
    cmp x25, 1
    b.ne check_newline

    cmp w24, '2'
    b.eq found_2xx
    cmp w24, '4'
    b.eq found_4xx
    cmp w24, '5'
    b.eq found_5xx
    b wait_newline

found_2xx: add x19, x19, 1; b wait_newline
found_4xx: add x20, x20, 1; b wait_newline
found_5xx: add x21, x21, 1; b wait_newline

wait_newline:
    mov x25, 0

check_newline:
    cmp w24, '\n'
    b.ne parse_char
    mov x25, 1
    b parse_char

end_read:
    adrp x0, fmt_out
    add x0, x0, :lo12:fmt_out
    mov x1, x19
    mov x2, x20
    mov x3, x21
    bl printf
    mov x0, 0
    ldp x29, x30, [sp], 16
    ret
