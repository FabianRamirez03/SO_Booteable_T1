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


menuLoop:                           ; Ciclo principal del menu
    mov     ah, 00h                 ; Activa obtener el tiempo de la computadora
    int     1ah                     ; Ejecutar interrupcion

    cmp     dl, [time]              ; Compara el tiempo actual con el tiempo anterior
    je      menuLoop                ; Si son iguales vuelve a calcular el ciclo
    mov     [time], dl              ; Sino, almacena el nuevo tiempo
  
    call    checkPlayerMenuAction   ; Llama la funcion encargada de verificar teclas en el menu principal

    call    drawTextMenu            ; Llama a la funcion encargada de escribir texto del menu

    jmp     menuLoop                ; Salta al incio de la funcion