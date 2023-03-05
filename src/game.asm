org  0x8A00
bits 16

    jmp startProgram
    nop

; Variables 

time db  00h                        ; tiempo que representa los FPS del programa



; Constantes 

width dw  140h                      ; Ancho de la pantalla 320 p
height dw  0c8h                     ; Alto de la pantalla 200 p

menuDeco1 dw '------------------------------------', 0h
menuTitle dw '            MOBILE MAZE             ', 0h
menuWelc  dw '             Bienvenido             ', 0h
menuDeco2 dw '------------------------------------', 0h
menuSpace dw '   Presione ESPACIO para continuar  ', 0h

textColor     dw 09h


;Inicia el juego
startProgram:
        call initDisplay    ; Inicia el display que mostrara el contenido del juego
        call clearScreen    ; Limpia el contenido de la pantalla
        jmp  menuLoop       ; Luego de iniciar la pantalla y limpiarla con pixeles negros, se salta al menu inicial

    
; Inicia el display que mostrara el contenido del juego
initDisplay:
    mov ah, 00h     ;  activa el modo  video
    mov al, 13h     ;  320x200 con 256 colores
    int 10h         ;  Interrupcion
    ret




;  Ciclo del menu de bienvenida -----------------------------------------------------------------------

menuLoop:                           ; Ciclo principal del menu de bienvenida
    mov     ah, 00h                 ; Activa obtener el tiempo de la computadora
    int     1ah                     ; Ejecutar interrupcion

    cmp     dl, [time]              ; Compara el tiempo actual con el tiempo anterior
    je      menuLoop                ; Si son iguales vuelve a calcular el ciclo
    mov     [time], dl              ; Sino, almacena el nuevo tiempo
  
    call    checkPlayerMenuAction   ; Llama la funcion encargada de verificar teclas en el menu principal

    call    drawTextMenu            ; Llama a la funcion encargada de escribir texto del menu

    jmp     menuLoop                ; Salta al incio de la funcion


;  Limpia el contenido que haya en la pantalla ----------------------------------------------------------

clearScreen:                        ; Funcion encargada de limpiar la pantala
    mov     cx, 00h                 ; Posicion inicial x = 0
    mov     dx, 00h                 ; Posicion inicial = 0
    jmp     clearScreenAux          ; Salta a la funcion auxliar

clearScreenAux:
    mov     ah, 0ch                 ; Dibuja pixel
    mov     al, 00h                 ; Color negro
    mov     bh, 00h
    int     10h                     ; Ejecutar interrupcion
    inc     cx                      ; Suma uno a cx
    cmp     cx, [width]             ; Compara cx con el ancho la pantalla
    jng     clearScreenAux          ; Si cx no es mayor que el ancho de la pantalla, salta a dibujar en la siguiente columna
    jmp     clearScreenAux2         ; Sino, salta a la funcion auxiliar 2

clearScreenAux2:                  
    mov     cx, 00h                 ; Reinicia las columnas
    inc     dx                      ; Suma uno a dx
    cmp     dx, [height]            ; Compara dx con la altura de la pantalla
    jng     clearScreenAux          ; Si dx no es mayor que el ancho de la pantalla, salta a dibujar la siguiente fila
    ret                             ; Sino, Retornar


; Comprueba si el usuario presiona espacio en el menu de bienvenida ------------------------------------------

checkPlayerMenuAction:              ; Funcion encargada de verificar la tecla presionada en el menu
    mov     ah, 01h                 ; Consigue el estado del teclado
    int     16h                     ; Ejecutar interrupcion
    jz      exitRoutine             ; Si no se esta presionando nada, salta a salir
    
    mov     ah, 00h                 ; Lectura de tecla
    int     16h                     ; Ejecutar interrupcion

    cmp     ah, 39h                 ; Si la tecla presionada es Espacio
    je      startGame               ; Inicia el juego

    ret


; Dibuja el textp el texto en el menu de bienvenida ----------------------------------------------------------

drawTextMenu:                       ; Funcion encargada de escribir los textos del menu de bienvenida
    mov     bx, [textColor]         ; Mueve a bx el color del texto
    inc     bx                      ; Incrementa bx
    mov     [textColor], bx         ; Almacena el nuevo bx al color del texto

    ; Elemento decorativo de la pantalla de bienvenida
    mov     bx, menuDeco1           ; Mueve a bx el puntero del primer texto
    mov     dh, 07h                 ; Mueve a dh un 7
    mov     dl, 02h                 ; Mueve a dl un 2
    call    drawText                ; Llama a la funcion encargada de escribir texto

    ; Titulo de la pantalla de bienvenida
    mov     bx, menuTitle           ; Mueve a bx el puntero del segundo texto
    inc     dh                      ; Incrementa dh
    inc     dh                      ; Incrementa dh
    mov     dl, 02h                 ; Mueve a dl un 2
    call    drawText                ; Llama a la funcion encargada de escribir texto

    ; Texto de bienvenida de la pantalla de bienvenida
    mov     bx, menuWelc            ; Mueve a bx el puntero del tercer texto
    inc     dh                      ; Incrementa dh
    mov     dl, 02h                 ; Mueve a dl un 2
    call    drawText                ; Llama a la funcion encargada de escribir texto

    ; Elemento decorativo de la pantalla de bienvenida
    mov     bx, menuDeco2           ; Mueve a bx el puntero del cuarto texto
    inc     dh                      ; Incrementa dh
    inc     dh                      ; Incrementa dh
    mov     dl, 02h                 ; Mueve a dl un 2
    call    drawText                ; Llama a la funcion encargada de escribir texto

    ; Texto para indicarle al usuario que presione espacio de la pantalla de bienvenida
    mov     bx, menuSpace           ; Mueve a bx el puntero del quinta texto
    inc     dh                      ; Incrementa dh
    inc     dh                      ; Incrementa dh
    inc     dh                      ; Incrementa dh
    mov     dl, 02h                 ; Mueve a dl un 2
    call    drawText                ; Llama a la funcion encargada de escribir texto

    ret

; Funcion encargada de dibujar el texto en pantalla --------------------------------------------------

drawText:                           ; Funcion encargada de dibujar texto
    cmp     byte [bx],0             ; Compara el byte que contiene bx con 0
    jz      finishDraw              ; Si es igual a cero, salta a la funcion de salida. Es un ret
    jmp     drawChar                ; Sino salta a dibujar un caracter

drawChar:                           ; Funcion encargada de dibujar un caracter
    push    bx                      ; Hace un push de bx
    mov     ah, 02h                 ; Mueve a ah un 2
    mov     bh, 00h                 ; Mueve a bh un 0
    int     10h                     ; Ejecutar interrupcion
    pop     bx                      ; Hace pop a bx

    push    bx                      ; Hace push a bx
    mov     al, [bx]                ; Mueve el contenido de bx a al
    mov     ah, 0ah                 ; Mueve a ah un 10
    mov     bh, 00h                 ; Mueve a bh un 0
    mov     bl, [textColor]         ; Mueve el color de texto a bl
    mov     cx, 01h                 ; Mueve a cx un 1
    int     10h                     ; Ejecutar interrupcion
    pop     bx                      ; Hace pop a bx

    inc     bx                      ; Incrementa bx
    inc     dl                      ; Incrementa dl
    jmp     drawText                ; Salta a la funcion de dibujar texto

finishDraw:                         ; Funcion de salida de texto
    ret                             ; Retornar




; Funcion encargada de retornar --------------------------------------------------

exitRoutine:                        ; Funcion encargada de retornar
    ret                             ; Retornar