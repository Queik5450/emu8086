; Archivo con procedimientos y macros para emu8086

; leer_cadena PROC 
;   dx debe contener la dirección del buffer
;    mov ah, 0Ah
 ;    int 21h
  ; ret
; leer_cadena ENDP

imprimir MACRO msg
    lea dx, msg
    mov ah, 09h
    int 21h
ENDM

PresioneTecla MACRO mensaje
    ;Mostrar mensaje de presione cualquier tecla para continuar   
    lea dx,mensaje
    mov ah, 09h
    int 21h   
    ;Realiza una pausa
    mov ah, 00h  ; Espera hasta que se presione una tecla
    int 16h      ; Llamada a la interrupción del teclado
ENDM



