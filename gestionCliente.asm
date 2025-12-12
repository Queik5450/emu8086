include 'emu8086.inc'

.model small
.stack 100h

.data
    ; --- VARIABLES DE ENTRADA (Formato 0Ah: Max, Leidos, Buffer) ---
    idBuf           db 11, ?, 11 dup('$')
    nameBuf         db 31, ?, 31 dup('$')
    addrBuf         db 51, ?, 51 dup('$')
    ageBuf          db 4, ?, 4 dup('$')
    priceBuf        db 7, ?, 7 dup('$')

    ; --- VARIABLES NUMERICAS ---
    wAge            dw 0
    wPrice          dw 0
    wDiscount       dw 0
    wFinal          dw 0

    ; --- TEXTOS PARA ARCHIVO Y PANTALLA ---
    txtId           db 'ID: $'
    txtName         db 'Nombre: $'
    txtAddr         db 'Direccion: $'
    txtAge          db 'Edad: $'
    txtPrice        db 'Compra: $'
    txtDisc         db 'Descuento: $'
    txtTotal        db 'Total: $'
    newline         db 13, 10, '$'
    
    ; --- BUFFER PARA CONVERSION NUMERO A STRING ---
    numStrBuf       db 10 dup('$')

    ; --- MENSAJES DE INTERFAZ ---
    menu_msg            db 13,10,13,10, '--- GESTION DE CLIENTES ---', 13,10
                        db '1. Ingresar datos del cliente', 13,10
                        db '2. Mostrar archivo de cliente', 13,10
                        db '3. Salir', 13,10
                        db 'Elija una opcion: $'
    
    msgId               db 13,10, 'Ingrese ID del cliente (max 10): $'
    msgName             db 13,10, 'Ingrese nombre del cliente (max 30): $'
    msgAddr             db 13,10, 'Ingrese direccion del cliente (max 50): $'
    msgAge              db 13,10, 'Ingrese edad del cliente (2 digitos): $'
    msgPrice            db 13,10, 'Ingrese monto de compra (max 5 digitos): $'
    
    msgSaved            db 13,10, 'Datos guardados exitosamente en cliente.txt', 13,10, '$'
    msgPressKey         db 13,10, 'Presione cualquier tecla para continuar...$'
    
    ; --- MENSAJES DE ERROR ---
    errCreate           db 13,10, 'Error: No se pudo crear el archivo.$'
    errOpen             db 13,10, 'Error: No se pudo abrir el archivo.$'
    errWrite            db 13,10, 'Error: No se pudo escribir en el archivo.$'
    errRead             db 13,10, 'Error: No se pudo leer el archivo.$'

    ; --- MANEJO DE ARCHIVO ---
    filename            db 'cliente.txt', 0
    filehandle          dw ?
    readBuffer          db 1000 dup('$')

.code
main proc
    mov ax, @data
    mov ds, ax
    mov es, ax

menu_loop:
    ; Limpiar pantalla
    mov ax, 03h
    int 10h

    lea dx, menu_msg
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je opcion_ingresar
    cmp al, '2'
    je opcion_mostrar
    cmp al, '3'
    je salir
    jmp menu_loop

opcion_ingresar:
    call ingresar_datos
    call calcular_descuento
    call guardar_archivo
    
    lea dx, msgSaved
    mov ah, 09h
    int 21h
    
    call esperar_tecla
    jmp menu_loop

opcion_mostrar:
    ; Limpiar pantalla antes de mostrar
    mov ax, 03h
    int 10h
    
    call leer_archivo
    
    call esperar_tecla
    jmp menu_loop

salir:
    mov ax, 4c00h
    int 21h

main endp

; ---------------------------------------------------------
; PROCEDIMIENTOS PRINCIPALES
; ---------------------------------------------------------

ingresar_datos proc
    ; --- ID ---
    lea dx, msgId
    mov ah, 09h
    int 21h
    
    lea dx, idBuf
    mov ah, 0Ah
    int 21h
    
    ; --- Nombre ---
    lea dx, msgName
    mov ah, 09h
    int 21h
    
    lea dx, nameBuf
    mov ah, 0Ah
    int 21h
    
    ; --- Direccion ---
    lea dx, msgAddr
    mov ah, 09h
    int 21h
    
    lea dx, addrBuf
    mov ah, 0Ah
    int 21h
    
    ; --- Edad ---
    lea dx, msgAge
    mov ah, 09h
    int 21h
    
    lea dx, ageBuf
    mov ah, 0Ah
    int 21h
    
    ; Convertir Edad a numero
    lea si, ageBuf + 2 ; Saltar bytes de control
    call str_to_num
    mov wAge, ax
    
    ; --- Precio ---
    lea dx, msgPrice
    mov ah, 09h
    int 21h
    
    lea dx, priceBuf
    mov ah, 0Ah
    int 21h
    
    ; Convertir Precio a numero
    lea si, priceBuf + 2
    call str_to_num
    mov wPrice, ax
    
    ret
ingresar_datos endp

calcular_descuento proc
    ; Si edad >= 60, 10%. Sino 5%.
    cmp wAge, 60
    jae desc_10
    
    ; 5% -> Precio / 20
    mov ax, wPrice
    mov bx, 20
    xor dx, dx
    div bx
    mov wDiscount, ax
    jmp calc_total
    
desc_10:
    ; 10% -> Precio / 10
    mov ax, wPrice
    mov bx, 10
    xor dx, dx
    div bx
    mov wDiscount, ax

calc_total:
    mov ax, wPrice
    sub ax, wDiscount
    mov wFinal, ax
    ret
calcular_descuento endp

guardar_archivo proc
    ; Crear archivo (o truncar si existe)
    mov ah, 3Ch
    mov cx, 0
    lea dx, filename
    int 21h
    jc error_crear_label
    mov filehandle, ax
    
    ; --- Escribir Datos ---
    
    ; ID
    lea dx, txtId
    call escribir_cadena
    lea bx, idBuf
    call escribir_buffer_input
    call escribir_newline
    
    ; Nombre
    lea dx, txtName
    call escribir_cadena
    lea bx, nameBuf
    call escribir_buffer_input
    call escribir_newline
    
    ; Direccion
    lea dx, txtAddr
    call escribir_cadena
    lea bx, addrBuf
    call escribir_buffer_input
    call escribir_newline
    
    ; Edad
    lea dx, txtAge
    call escribir_cadena
    mov ax, wAge
    call num_to_str_file
    call escribir_newline
    
    ; Precio
    lea dx, txtPrice
    call escribir_cadena
    mov ax, wPrice
    call num_to_str_file
    call escribir_newline
    
    ; Descuento
    lea dx, txtDisc
    call escribir_cadena
    mov ax, wDiscount
    call num_to_str_file
    call escribir_newline
    
    ; Total
    lea dx, txtTotal
    call escribir_cadena
    mov ax, wFinal
    call num_to_str_file
    call escribir_newline
    
    ; Cerrar archivo
    mov ah, 3Eh
    mov bx, filehandle
    int 21h
    ret

error_crear_label:
    lea dx, errCreate
    mov ah, 09h
    int 21h
    ret
guardar_archivo endp

leer_archivo proc
    ; Abrir archivo para lectura
    mov ah, 3Dh
    mov al, 0 ; Read only
    lea dx, filename
    int 21h
    jc error_abrir_label
    mov filehandle, ax
    
    ; Leer archivo
    mov ah, 3Fh
    mov bx, filehandle
    mov cx, 999 ; Leer hasta 999 bytes
    lea dx, readBuffer
    int 21h
    
    ; Asegurar terminador $
    mov bx, ax
    mov readBuffer[bx], '$'
    
    ; Mostrar contenido
    lea dx, readBuffer
    mov ah, 09h
    int 21h
    
    ; Cerrar
    mov ah, 3Eh
    mov bx, filehandle
    int 21h
    ret

error_abrir_label:
    lea dx, errOpen
    mov ah, 09h
    int 21h
    ret
leer_archivo endp

esperar_tecla proc
    lea dx, msgPressKey
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    ret
esperar_tecla endp

; ---------------------------------------------------------
; UTILIDADES DE ARCHIVO Y CONVERSION
; ---------------------------------------------------------

; Escribe una cadena terminada en $ al archivo abierto
escribir_cadena proc
    ; Input: DX apunta a la cadena
    push dx
    push si
    
    mov si, dx
    xor cx, cx
count_loop:
    cmp byte ptr [si], '$'
    je do_write
    inc si
    inc cx
    jmp count_loop
do_write:
    mov ah, 40h
    mov bx, filehandle
    ; CX tiene la longitud calculada
    int 21h
    
    pop si
    pop dx
    ret
escribir_cadena endp

; Escribe el contenido de un buffer de entrada (0Ah) al archivo
escribir_buffer_input proc
    ; Input: BX apunta al buffer (byte 0=max, byte 1=len)
    push bx
    push cx
    push dx
    
    mov cl, [bx+1] ; Longitud real
    xor ch, ch
    
    lea dx, [bx+2] ; Inicio de los datos
    
    mov bx, filehandle
    mov ah, 40h
    int 21h
    
    pop dx
    pop cx
    pop bx
    ret
escribir_buffer_input endp

escribir_newline proc
    push cx
    push dx
    push bx
    
    lea dx, newline
    mov cx, 2
    mov bx, filehandle
    mov ah, 40h
    int 21h
    
    pop bx
    pop dx
    pop cx
    ret
escribir_newline endp

; Convierte string numerico en SI a valor en AX
str_to_num proc
    xor ax, ax
    xor cx, cx
    mov bx, 10
next_digit_stn:
    mov cl, [si]
    cmp cl, 0Dh ; Enter
    je done_stn
    cmp cl, '$' ; Fin string
    je done_stn
    cmp cl, '0'
    jb done_stn
    cmp cl, '9'
    ja done_stn
    
    sub cl, '0'
    mul bx      ; AX = AX * 10
    add ax, cx
    inc si
    jmp next_digit_stn
done_stn:
    ret
str_to_num endp

; Convierte numero en AX a string y lo escribe al archivo
num_to_str_file proc
    ; Input: AX = numero
    push ax
    push bx
    push cx
    push dx
    push di
    
    lea di, numStrBuf
    mov cx, 0
    mov bx, 10
    
    cmp ax, 0
    jne push_digits_nts
    ; Caso 0
    mov byte ptr [di], '0'
    inc di
    jmp finish_nts

push_digits_nts:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne push_digits_nts
    
pop_digits_nts:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    loop pop_digits_nts

finish_nts:
    mov byte ptr [di], '$'
    
    lea dx, numStrBuf
    call escribir_cadena
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
num_to_str_file endp

end main
