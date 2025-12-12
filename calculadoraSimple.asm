; Calculadora simple que suma, resta, multiplica y divide dos nmeros de un solo digito
include 'libreria.inc'

.model small
.stack 64

.DATA  

  nl db 0Dh, 0Ah, '$' 
  buffer_nombre db 50, 0, 49 dup (0)

  menu db "========= C A L C U L A D O R A =========", 0dh, 0ah,
        db "ELIJA LA OPERACION A REALIZAR", 0dh, 0ah, 
        db "1. Suma", 0dh, 0ah, 
        db "2. Resta", 0dh, 0ah,
        db "3. Multiplicacion", 0dh, 0ah
        db "4. Division", 0dh, 0ah 
        db "5. Salir", 0dh, 0ah, 
        db   "$"

    num1 DB 0   ;  numero 1
    num2 DB 0   ;  numero 2

    ; r, almacena los digitos ASCII que representan el resultado de una operacion
    ; para que puedan ser mostrado en pantalla

    r DB 3 DUP(' '), '$'
                    
    mensaje1 DB "Ingrese numero 1:$", 0dh, 0ah
    mensaje2 DB "Ingrese numero 2:$", 0dh, 0ah   
    mensajeResultado DB "El resultado es: $", 0dh, 0ah
    mensajeSaltar DB "Presione cualquier tecla para continuar $", 0dh, 0ah
    suma DB 0
    resta DB 0
    mult DB 0
    divv DB 0
    salto_linea DB 0dh, 0ah, "$"
    
.code

main proc      
    mov ax, @data
    mov ds, ax

inicio:     
    mostrar_menu:
    mov ax,0600h ;limpiar pantalla
    mov bh,1fh ;1 color de fondo azul, f color de letra blanco
    mov cx,0000h
    mov dx,184Fh
    int 10h   
    

    
  ; colocar coordenada donde aparecera el Menu
    MOV AH, 02h   ; Funcion para mover el cursor
    MOV BH, 00h   ; Pagina de video (normalmente 0)
    MOV DH, 0     ; Fila (posicion vertical)
    MOV DL, 5     ; Columna (posicion horizontal)
    INT 10h       ; Llamada a la interrupci�n de video     
    
  ; Mostrar el menu
    
  
    imprimir menu  ;MACRO
    mov ah, 01h
    int 21h   

    sub al, '0'
    cmp al, 1
      je operacion_suma
    cmp al, 2
      je operacion_resta   
    cmp al, 3
      je operacion_multi
    cmp al, 4
      je operacion_div
    cmp al, 5
      je salir
      ;jmp mostrar_menu

operacion_suma:
    call pedir_numeros
    
    MOV AL, num1
    ADD AL, num2
    MOV suma, AL

    MOV DX, OFFSET mensajeResultado
    MOV AH, 09h
    INT 21h

    MOV AL, suma
    AAM  ; separar el contenido de un registro en decenas y unidades decimales.
    ;Cuando ejecutas AAM (sin operandos), toma el valor que esta en AL
    ; (normalmente el resultado de una multiplicaci�n), y lo convierte en 
    ; dos digitos decimales:  
    ;El valor en AL se divide entre 10
    ;Coloca el cociente en AH,representa las decenas.
    ;Coloca el residuo en AL, representa las unidades.
    ADD AX, 3030h ;convertir a ASCII
    MOV r[0], AH
    MOV r[1], AL
    MOV DX, OFFSET r ; se muestra como una cadena
    MOV AH, 09h
    INT 21h
    
    imprimir salto_linea
    PresioneTecla mensajeSaltar
    jmp mostrar_menu

operacion_resta:
    call pedir_numeros
    MOV AL, num1
    SUB AL, num2
    MOV resta, AL

    MOV DX, OFFSET mensajeResultado
    MOV AH, 09h
    INT 21h

    MOV AL, resta
    JNS resta_positiva

    NEG AL
    MOV AH , 00
    ADD AX, 3030h
    MOV r[0], AH
    MOV r[1], AL
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    MOV DX, OFFSET r
    MOV AH, 09h
    INT 21h
    
    imprimir salto_linea
    PresioneTecla mensajeSaltar
    jmp mostrar_menu
            
resta_positiva:
    AAM  
    MOV AH, 00   
    ADD AX, 3030h
    MOV r[0], AH
    MOV r[1], AL
    MOV DX, OFFSET r
    MOV AH, 09h 
    jmp mostrar_menu
    INT 21h
    
operacion_multi:
    call pedir_numeros
    MOV AL, num1
    MUL num2
    MOV mult, AL

    MOV DX, OFFSET mensajeResultado
    MOV AH, 09h
    INT 21h

    MOV AL, mult
    AAM
    ADD AX, 3030h
    MOV r[0], AH
    MOV r[1], AL
    MOV DX, OFFSET r
    MOV AH, 09h
    INT 21h
    
    imprimir salto_linea
    PresioneTecla mensajeSaltar
    jmp mostrar_menu
    
operacion_div:
    call pedir_numeros
    
    ; Resultado: AL = 4  (cociente)
    ;            AH = 1  (residuo)
    MOV AX, 0
    MOV AL, num1
    MOV BL, num2
    DIV BL
    MOV divv, AL

    MOV DX, OFFSET mensajeResultado
    MOV AH, 09h
    INT 21h

    MOV AL, divv
    AAM
    ADD AX, 3030h
    MOV r[0], AH
    MOV r[1], AL
    MOV DX, OFFSET r
    MOV AH, 09h
    INT 21h
    
    imprimir salto_linea
    PresioneTecla mensajeSaltar
    jmp mostrar_menu 
    
salir:
    mov ah, 4Ch
    int 21h

pedir_numeros PROC
    imprimir salto_linea ;Salto de linea
    ; Solicitar primer numero
    MOV DX, OFFSET mensaje1
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    SUB AL, 30h
    MOV num1, AL
    imprimir salto_linea ;Salto de linea
    
    ; Solicitar segundo numero
    MOV DX, OFFSET mensaje2
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    SUB AL, 30h
    MOV num2, AL
    imprimir salto_linea ;Salto de linea
    ret
    
pedir_numeros ENDP



