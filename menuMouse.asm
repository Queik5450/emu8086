; Menu sencillo con mouse en emu8086 (modo texto 80x25)
; int 33h (mouse) + int 10h (video) + int 21h (DOS)

.model small
.stack 100h

.data
menu db "========= M E N U =========", 0dh, 0ah, 
    db  "1. Opcion 1", 0dh, 0ah, 
    db  "2. Opcion 2", 0dh, 0ah, 
    db  "3. Salir", 0dh, 0ah, 
    db  "$"

msg1 db "Opcion 1: Hola$",0
msg2 db "Opcion 2: Adios$",0
msg3 db "Saliendo...$",0     
linea db "                          $",0

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Modo texto 80x25
    mov ax, 0003h
    int 10h

    ; Inicializar mouse
    mov ax, 0
    int 33h              ; AX=0 -> inicializa mouse
    mov ax, 1
    int 33h              ; AX=1 -> muestra puntero

    ; (Opcional pero recomendado) Definir rangos del mouse: X 0..639, Y 0..199
    ; Horizontal
    mov ax, 7
    mov cx, 0
    mov dx, 639
    int 33h
    ; Vertical
    mov ax, 8
    mov cx, 0
    mov dx, 199
    int 33h

    ; Posicionar cursor y mostrar el men� en filas conocidas
    ; Ponemos el menu desde la fila 5 (0-based), opciones en 6,7,8
    mov ah, 02h          ; set cursor position
    mov bh, 0            ; p�gina 0
    mov dh, 5            ; fila 5
    mov dl, 10           ; columna 10 (aj�stalo si quieres)
    int 10h

    mov dx, offset menu
    mov ah, 09h
    int 21h

    espera_click:
        ; Leer estado del mouse
        mov ax, 3
        int 33h              ; BX=botones, CX=X, DX=Y
    
        ; Comprobar boton izquierdo presionado (bit 0 de BX)
        test bx, 0001h
        jz espera_click
    
        ; Guardar Y en pixeles al momento de presionar
        mov si, dx
    
    espera_solta:
        ; Esperar hasta soltar para evitar rebotes
        mov ax, 3
        int 33h
        test bx, 0001h
        jnz espera_solta
    
        ; Convertir Y (pixeles) a fila de texto: fila = Y / 8
        mov ax, si           ; AX = Y en pixeles
        mov bl, 8
        div bl               ; AL = fila (0..24), AH = resto
    
        ; Comparar con filas de las opciones (6,7,8)
        cmp al, 6
        je opcion1
        cmp al, 7
        je opcion2
        cmp al, 8
        je opcion3
        jmp espera_click
    
    opcion1:
        call limpiar_linea
        
        ; Posicionar abajo y mostrar mensaje
        
        mov dx, offset msg1
        mov ah, 09h
        int 21h
        jmp espera_click
    
    opcion2:   
        call limpiar_linea
        
        mov dx, offset msg2
        mov ah, 09h
        int 21h
        jmp espera_click
    
    opcion3:   
        call limpiar_linea
        
        mov dx, offset msg3
        mov ah, 09h
        int 21h
        mov ax, 4C00h
        int 21h

main endp  

; --- Rutina para limpiar linea de mensajes ---
limpiar_linea proc  
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 0
    int 10h
    mov dx, offset linea
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov bh, 0
    mov dh, 12
    mov dl, 0
    int 10h
    
    ret
    
limpiar_linea endp
end main