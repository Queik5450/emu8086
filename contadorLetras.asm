; Cuenta el numero de palabras en una cadena ingresada por el usuario.

.model small
.stack 64
.data 
; --- DATOS ---          
    cadena  DB 100 DUP(' '),'$'   
    prompt_msg      db 'Ingrese una cadena (max 100 chars):$'
    result_msg      db 0ah, 0dh, 'El numero de palabras es: $' ; Salto de linea.
    result2_msg     db 0ah, 0dh, 'El numero de letras es: $' ; Salto de linea.

.code  
main proc 
    MOV AX, @DATA
    MOV DS, AX

    start:
        ; MENSAJE DE SOLICITUD 
        mov ah, 9
        lea dx, prompt_msg
        int 21h
    
        ; LEER LA CADENA DE ENTRADA
        mov ah, 0ah
        lea dx, cadena
        int 21h
        
        ; OBTENER LA LONGITUD Y PUNTERO
        lea si, cadena   ; SI apunta al inicio de la cadena .
        mov cl, [si + 1]       ; CL = Longitud real de la cadena (N).
        mov ch, 0              ; CX = N (contador para el bucle).
        
        mov di, cx
        
        mov bx, 0              ; BX = 0. Usaremos BX como contador de PALABRAS.
        
        ; Inicializar puntero de cadena (comienza en el byte 2 de la cadena)
        add si, 2              ; SI ahora apunta al primer caracter real de la cadena.
    
        ; Inicializar 'flag' de estado: 1 = en un espacio, 0 = en una palabra
        ; Asumimos que la cadena comienza con un espacio (o el final de un espacio).
        mov ah, 1              ; AH = 1 (es_espacio = TRUE/verdadero).
    
        
    ; --- CONTEO DE PALABRAS ---
    word_count_loop:
        cmp cx, 0              ; Hemos llegado al final de la cadena?
        je done_counting_words ; Si CX=0, saltar a imprimir.
    
        mov al, [si]           ; AL = Caracter actual.
        
        ; 1. ES ESPACIO (ASCII 32)
        cmp al, ' '            ; Comparar AL con el codigo ASCII del espacio.
        je is_space            ; si es igual va 
        
        ; 2. NO ES ESPACIO (estamos en un car�cter de palabra)
        ; Estabamos en un espacio antes? (AH = 1)
        cmp ah, 1     ; si es igual va 
        je new_word
        
        ; Si NO es espacio y NO estabamos en un espacio, seguimos en la misma palabra.
        jmp continue_loop
    
    is_space:
        dec di                 ; Espacio no es una palabra
        mov ah, 1              ; Establecer flag AH = 1 (Estamos ahora en un ESPACIO).
        jmp continue_loop
    
    new_word:
        inc bx                 ; �Incrementar el contador de PALABRAS! (BX)
        mov ah, 0              ; Establecer flag AH = 0 (Estamos ahora en una PALABRA).
        
    continue_loop:
        inc si                 ; Avanzar al siguiente car�cter.
        loop word_count_loop   ; Decrementar CX y saltar si CX != 0.
    
    
    
    ; --- MUESTRA RESULTADO PALABRAS ---
    done_counting_words:
        ; 4. IMPRIMIR MENSAJE DE RESULTADO PALABRAS
        mov ah, 9
        lea dx, result_msg
        int 21h
    
        ; 5. CONVERTIR E IMPRIMIR EL RESULTADO DE PALABRAS EN DECIMAL
        ; El resultado (contador de palabras) esta en BX. Mover a AX para la division.
        mov ax, bx             ; AX = Contador de Palabras
        
        mov bx, 10             ; Divisor (base 10).
        mov cx, 0              ; Contador de digitos.
        
    convert_words:
        mov dx, 0
        div bx                 ; AX = AX / 10; DX = AX % 10 (Resto).
        
        push dx
        inc cx
        
        cmp ax, 0
        jnz convert_words        
        
        
    print_decimal_words:
        pop dx
        add dl, '0'            ; Convertir a caracter ASCII.
        
        mov ah, 2
        int 21h
        
        loop print_decimal_words

    ; --- MUESTRA RESULTADO LETRAS ---
    done_counting_letters:
        ; 4. IMPRIMIR MENSAJE DE RESULTADO LETRAS
        mov ah, 9
        lea dx, result2_msg
        int 21h
    
        ; 5. CONVERTIR E IMPRIMIR EL RESULTADO DE LETRAS EN DECIMAL
        ; El resultado (contador de palabras) esta en BX. Mover a AX para la division.
        mov ax, bx             ; AX = Contador de Palabras
        lea ax,di
        mov bx, 10             ; Divisor (base 10).
        mov cx, 0              ; Contador de digitos.
        
    convert_letters:
        mov dx, 0
        div bx                 ; AX = AX / 10; DX = AX % 10 (Resto).
        
        push dx
        inc cx
        
        cmp ax, 0
        jnz convert_words        
        
        
    print_decimal_letters:
        pop dx
        add dl, '0'            ; Convertir a caracter ASCII.
        
        mov ah, 2
        int 21h
        
        loop print_decimal_words
    
main endp   