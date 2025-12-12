; Muestra la Fecha del Sistema 
.model small
.data
.code

main proc near
    mov ax, @data
    mov ds, ax

    ; Obtener la fecha del sistema
    mov ah, 2Ah ; return: CX = anno (1980-2099). DH = mes. DL = dia.
    int 21h

    ; Convertir y mostrar la fecha en formato dd/mm/yyyy
    mov al, dl ; Dia
    aam
    mov bx,ax 
    call disp

    mov dl, '/' ; Separador
    mov ah, 02h
    int 21h

    mov al, dh ; Mes
    aam 
    mov bx,ax 
    call disp

    mov dl, '/' ; Separador
    mov ah, 02h
    int 21h

    ;Limpia los registros ax,bx y dx
    sub ax,ax
    sub bx,bx
    sub dx,dx

    mov ax,cx  ;muevo el valor de anno

    mov bx,0ah ; mueve 10 a bx
    
    ;separa cada digito de anno, haciendo divisiones sucesiva, cuando el  operand es una palabra:
    ;AX = (DX AX) / operand
    ;AX= coefiente y  DX = residuo (modulus)
    
    mov cx,3
    
    ciclo1: 
        div bx
        or dx,3030h  
        push dx
        sub dx,dx 
  
        dec cx
        cmp cx,0
        jnz ciclo1:

   ;El ultimo digito queda en ax
        or ax,3030h
        push ax

   ;Mostrar ano en pantalla
        mov cx,4
    
    ciclo2: 
    pop dx
    mov ah,02h
    int 21h
   
    dec cx
    cmp cx,0
    jnz ciclo2:



   ;Terminar el programa
    mov ah, 4Ch
    mov al, 00
    int 21h
   
   ;Convertir valor a ascii
    disp proc 
        mov dl, bh
        add dl, 30h
        mov ah, 02h
        int 21h

        mov dl, bl
        add dl, 30h
        mov ah, 02h
        int 21h
        ret
    disp endp

endp main