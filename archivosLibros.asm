; Programa en ensamblador para crear archivos con datos de un libro, se guardan en la carpeta de "MyBuild" de emu8086

.model small
.stack 64
.data 
     
    bookTitle            DB 30 DUP('$')   
    bookAuthor           DB 30 DUP('$')     
    publicationYear  DB 30 DUP('$')  
         
    titleMessage             DB 10,13, "Ingrese titulo del libro: $"
    authorMessage            DB 10,13, "Ingrese autor del libro: $"
    publicationYearMessage   DB 10,13, "Ingrese ano de publicacion: $"
                                    
    mensajeSalto        DB 10,13, "$"  
    
    titleInfo     DB 10,13, "Titulo del libro: $"  
    authorInfo    DB 10,13, "Autor del libro: $"
    publicationYearInfo  DB 10,13, "Publicado en el ano: $"
    
    bookInfoTitle  DB 10,13, "*** Informacion del libro ***$"
    subrayado      DB 10,13, "========================$"  
    
    filename db 'libro.txt', 0  ; Nombre del archivo
    handle dw ? ;Identificador del archivo a nivel de s.o
    length dw ?
                                 
.code 
main proc    

    MOV AX, @DATA
    MOV DS, AX
    mov es, ax     
    
    ; ---------------------------------------------
    ; Solicitar Datos Iniciales
    ; ---------------------------------------------    

    
    
    ; Solicitar titulo   
    MOV DX, OFFSET titleMessage
    MOV AH, 09h
    INT 21h
    
    MOV AH, 0Ah  
    LEA DX, bookTitle
    INT 21h  

    ; Solicitar autor
    MOV DX, OFFSET authorMessage
    MOV AH, 09h
    INT 21h

    MOV AH, 0Ah
    LEA DX, bookAuthor
    INT 21h
    
       
    ; Solicitar ano publicacion   
    MOV DX, OFFSET publicationYearMessage
    MOV AH, 09h
    INT 21h

    MOV AH, 0Ah
    LEA DX, publicationYear
    INT 21h
    
    
        
    ; ---------------------------------------------
    ; Escritura de los datos en el archivo
    ; ---------------------------------------------    
    
    lea dx, filename  ; Nombre del archivo
    mov ah, 3Ch       ; Funcion 3Ch: Crear archivo
    mov cx, 0         ; Atributo del archivo: Normal
    int 21h
    mov [handle], ax  ; Guardar el identificador del archivo
    
    ; Escribir en el archivo
    
    lea dx, bookTitle + 2   
    mov ah, 40h       
    mov bx, [handle] 
    mov cl, [bookTitle + 1]  
    int 21h
    
    lea dx, bookAuthor + 2     
    mov ah, 40h       
    mov bx, [handle]  
    mov cl, [bookAuthor + 1]  
    int 21h
   
    
    lea dx, publicationYear + 2     
    mov ah, 40h       
    mov bx, [handle]  
    mov cl, [publicationYear + 1]  
    int 21h
   
    
       
    ; Cerrar el archivo
    mov ah, 3Eh       ; Funcion 3Eh: Cerrar archivo
    mov bx, [handle]  ; Identificador del archivo
    int 21h 
    
    ; ---------------------------------------------
    ; Leer los datos
    ; ---------------------------------------------
    
    ; Abrir el archivo
    mov dx, offset filename
    mov ah, 3dh
    int 21h
    mov handle, ax
    mov bx, handle
    
    
    ; Leer titulo
    mov dx, offset bookTitle + 2
    mov cl, [bookTitle + 1]
    mov ah, 3fh
    int 21h
    mov [bookTitle + 1], al
    
    ; Leer autor
    mov dx, offset bookAuthor + 2   ; Espacio donde se leera la cadena
    mov cl, [bookAuthor + 1]        ; Maximo de caracteres a leer
    mov ah, 3fh
    int 21h
    mov [bookAuthor + 1], al        ; Guardar longitud de la cadena leida
    
    
    
    ; Leer ano publicacion
    mov dx, offset publicationYear + 2
    mov cl, [publicationYear + 1]
    mov ah, 3fh
    int 21h
    mov [publicationYear + 1], al
    
    
    
    ; ---------------------------------------------
    ; Mostrar los datos
    ; ---------------------------------------------
    
    ; Mostrar Salto de Linea
    MOV DX, OFFSET mensajeSalto
    MOV AH, 09h
    INT 21h
    
    ; Mostrar subrayado
    MOV DX, OFFSET subrayado
    MOV AH, 09h
    INT 21h 
        
    ; Mostrar titulo    
    MOV DX, OFFSET bookInfoTitle
    MOV AH, 09h
    INT 21h         
            
    ; Mostrar subrayado
    MOV DX, OFFSET subrayado
    MOV AH, 09h
    INT 21h   
    
    ; Mostrar Salto de Linea
    MOV DX, OFFSET mensajeSalto
    MOV AH, 09h
    INT 21h   
    
    ; Mostrar numeroCedula
    MOV DX, OFFSET titleInfo
    MOV AH, 09h
    INT 21h
    mov dl, [bookTitle + 1] 
    mov cl, dl
    lea si, bookTitle + 2
    call printCharacters
    
    ; Mostrar nombre1
    MOV DX, OFFSET authorInfo
    MOV AH, 09h
    INT 21h
    mov dl, [bookAuthor + 1]       
    mov cl, dl
    lea si, bookAuthor + 2
    call printCharacters
    
        
    ; Mostrar apellido1
    MOV DX, OFFSET publicationYearInfo
    MOV AH, 09h
    INT 21h
    mov dl, [publicationYear + 1]   
    mov cl, dl
    lea si, publicationYear + 2
    call printCharacters
    
        
    ; Cerrar el archivo
    mov bx, handle
    mov ah, 3eh
    int 21h
      
    ; Finalizar el programa
    MOV AH, 4Ch
    INT 21h 
                       
main endp   

; ---------------------------------------------
; Procedimientos
; ---------------------------------------------                                          

printCharacters proc
    printLoop:
        MOV AL, [SI]       ; Cargar el siguiente caracter en AL 
        MOV AH, 0Eh        ; Funcion de INT 10h para imprimir un solo caracter
        INT 10h            ; Imprimir el caracter 
        INC SI             ; Incrementar SI para avanzar al siguiente caracter
        DEC CL             ; Decrementar el contador de caracteres
        JNZ printLoop   ; Si no ha terminado, repetir el ciclo
    ret
printCharacters endp

end main