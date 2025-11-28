.model small
.stack 100h

.data
    ; --- DEFINICION DE MENSAJES ---
    menu_msg    db 13, 10, '--- MENU PRINCIPAL ---', 13, 10
                db '1. Mostrar mensaje fijo', 13, 10
                db '2. Ingresar texto personalizado', 13, 10
                db '3. Salir', 13, 10
                db 'Elija una opcion: $'
                
    msg_fijo    db 13, 10, 13, 10, '>> Aprendiendo Ensamblador <<', 13, 10, '$'
    
    msg_pedir   db 13, 10, 'Escriba su texto y presione ENTER: $'
    msg_res     db 13, 10, 'Usted escribio: $'
    msg_cont    db 13, 10, 13, 10, 'Presione cualquier tecla para volver al menu...$'
    
    ; --- VARIABLES ---
    buffer      db 50 dup('$') ; Espacio para guardar el texto (inicializado con '$')

.code
main proc
    ; Inicializar segmento de datos
    mov ax, @data
    mov ds, ax

menu_loop:
    ; --- LIMPIAR PANTALLA ---
    mov ah, 00h
    mov al, 03h
    int 10h

    ; --- MOSTRAR MENU ---
    lea dx, menu_msg
    mov ah, 09h
    int 21h

    ; --- LEER OPCION ---
    ; La INT 16h lee directo del BIOS (hardware del teclado)
    mov ah, 00h     ; Funcion: Leer caracter del teclado
    int 16h         ; Retorna: AL = Codigo ASCII de la tecla
    
    ; Comparar la tecla presionada (guardada en AL)
    cmp al, '1'
    je opcion_1
    cmp al, '2'
    je opcion_2
    cmp al, '3'
    je salir
    
    ; Si no es 1, 2 o 3, repite el ciclo
    jmp menu_loop

; =============== OPCION 1: MENSAJE FIJO =================

opcion_1:
    lea dx, msg_fijo
    mov ah, 09h
    int 21h
    
    jmp esperar_tecla

; ======== OPCION 2: LECTURA CARACTER POR CARACTER ========

opcion_2:
    lea dx, msg_pedir
    mov ah, 09h
    int 21h
    
    mov si, 0       ; Indice para el buffer (empezamos en 0)
    mov cx, 49      ; Limite de caracteres para no desbordar buffer

ciclo_lectura:
    mov ah, 00h
    int 16h         ; AL tiene el caracter
    
    cmp al, 13
    je fin_lectura  ; Si es Enter, terminamos de leer
    
    ; Guardar caracter en memoria (buffer)
    mov buffer[si], al
    inc si          ; Mover indice a la siguiente posicion
    
    ; ============= ECO EN PANTALLA (INT 10h) =============
    ; INT 16h no muestra lo que escribes, asi que debemos
    ; dibujarlo manualmente con INT 10h, funcion 0Eh (Teletype)
    mov ah, 0Eh
    int 10h
    
    loop ciclo_lectura ; Repetir hasta que CX sea 0 o se presione Enter

fin_lectura:
    mov buffer[si], '$' ; Agregar terminador de cadena al final

    lea dx, msg_res
    mov ah, 09h
    int 21h
    
    lea dx, buffer
    mov ah, 09h
    int 21h
    
    ; Limpiar buffer para la proxima vez

    jmp esperar_tecla

; ============= RUTINA DE ESPERA Y SALIDA =============

esperar_tecla:
    lea dx, msg_cont
    mov ah, 09h
    int 21h
    
    mov ah, 00h
    int 16h
    jmp menu_loop

salir:
    mov ax, 4c00h
    int 21h

main endp
end main