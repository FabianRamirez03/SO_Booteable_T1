org  0x8000
bits 16

jmp startProgram
nop

; Variables ------------------------------------------------------------------------------------------------

time db  00h                        ; tiempo que representa los FPS del programa
level dw 01h                        ; Nivel del juego


; Constantes -----------------------------------------------------------------------------------------------

width dw  140h                      ; screen width 320 p
height dw  0c8h                     ; screen height 200 p

gameHeight dw 8ch ; Board height set to 100p
gameWidth dw 8ch ; Board width set to 150p

gamePaused dw 00h ; Flag to know if the game is paused

; player

player_x dw      09h   ; x position player 
player_y dw      10h   ; y position player 
temp_player_x dw 09h   ; temp x position player
temp_player_y dw 10h   ; temp y position player
player_speed dw  06h   ; player speed
player_color dw  03h   ; player color
player_size dw   05h   ; player dimensions 
player_dir dw    00h   ; last direction of player (0 right, 1 down, 2 left, 3 up) 


; Walls ----------------------------------------------------------------------------------------------------
walls_color dw 09h ; walls color 
walls_size  dw 0ah ; walls width and height set 6p
walls_index dw 00h ; walls counter
wallx dw 00h ; x wall pos
wally dw 00h ; y wall pos

walls_x_start_l1  dw 09h, 3fh, 45h, 09h, 33h, 39h ; Walls's X positions for L1
walls_y_start_l1  dw 0ah, 10h, 34h, 16h, 1ch, 40h ; Y positions for L1

walls_x_end_l1    dw 44h, 44h, 50h, 38h, 38h, 50h ; Walls's X positions for L1
walls_y_end_l1    dw 0fh, 39h, 39h, 1bh, 45h, 45h ; Number of walls for L1

total_walls_lvl_1 dw 06h  



walls_n dw 00h ; current walls number

; Texts ---------------------------------------------------------------------------------------------------

menuDeco1 dw '************************************', 0h
menuTitle dw '            MOBILE MAZE             ', 0h
menuWelc  dw '            BIENVENIDO              ', 0h
menuDeco2 dw '************************************', 0h
menuSpace dw '   Presione ESPACIO para continuar  ', 0h

textColor     dw 150h


; GAME LOGIC ****************************************************************************************************

;Inicia el programa completo. El usuario ve la pantalla de bienvenida -----------------------------------------------
startProgram:
        call initDisplay    ; Inicia el display que mostrara el contenido del juego
        call clearScreen    ; Limpia el contenido de la pantalla
        jmp  menuLoop       ; Luego de iniciar la pantalla y limpiarla con pixeles negros, se salta al menu inicial

;Inicia el programa completo. El usuario ve la pantalla del primer nivel -----------------------------------------------  
startGame:                          ; Funcion de inicio del juego
    call    setLevel1               ; Llama a la funcion para colocar los parametros del primer nivel
    call    clearScreen             ; Llama a la funcion para limpiar la pantalla
    jmp     gameLoop                ; Salta a la funcion principal del programa


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

; Loop principal del juego 

gameLoop:                           ; Ciclo principal del juego
    mov     ah, 00h                 ; Activa obtener el tiempo de la computadora
    int     1ah                     ; Ejecutar interrupcion

    ;call clearScreen

    cmp     dl, [time]              ; Compara el tiempo actual con el tiempo anterior
    je      gameLoop                ; Si son iguales vuelve a calcular el ciclo
    mov     [time], dl              ; Sino, almacena el nuevo tiempo

    call checkPlayerGameInput       ; function to check whether the keys have been clicked or not  

    call renderPlayer               ; function to draw the player
    call renderWalls               ; function to draw the walls

    ;call renderTextHints           ; function to draw the hints for keyboard use

    jmp     gameLoop                ; Salta al incio de la funcion

; Render functions **************************************************************************************

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

; Define el nivel 1 y sus variables ----------------------------------------------------------------

setLevel1:                          ; Funcion encargada de iniciar el primer nivel del juego
    mov     ax, 01h                 ; Mueve 1 a ax
    mov     [level], ax             ; Mueve ax al nivel actual

    mov     ax, 09h                       ; Mueve 09 a ax
    mov     [player_x], ax                ; Mueve el 09 a la posicion inicial x del alien
    mov     [temp_player_x], ax           ; Mueve el 09 a la posicion inicial temporal x del alien
    mov     ax, 10h                       ; Mueve 10 a ax
    mov     [player_y], ax                ; Mueve el 10 a la posicion inicial y del alien
    mov     [temp_player_y], ax           ; Mueve el 10 a la posicion inicial temporal y del alien

    mov     ax, 00h                       ; Mueve 0 a ax
    mov     [gamePaused], ax              ; Mueve el contenido de ax a la variable de pausa


; Funcion encargada de retornar --------------------------------------------------

; Render player  **************************************************************************************

renderPlayer:
    mov     cx, [player_x]            ; Posicion inicial x del alien
    mov     dx, [player_y]            ; Posicion inicial y del alien
    jmp     renderPlayerAux           ; Salta a la funcion auxliar

renderPlayerAux:
    mov     ah, 0ch                 ; Draw pixel
    mov     al, [player_color]      ; player color 
    mov     bh, 00h                 ; Page
    int     10h                     ; Interrupt 
    inc     cx                      ; cx +1
    mov     ax, cx                  
    sub     ax, [player_x]          ; Substract player width with the current column
    cmp     ax, [player_size]       ; compares if ax is greater than player size
    jng     renderPlayerAux         ; if not greater, draw next column
    jmp     renderPlayerAux2        ; Else, jump to next aux function

renderPlayerAux2:
    mov     cx, [player_x]            ; reset columns
    inc     dx                        ; dx +1
    mov     ax, dx                  
    sub     ax, [player_y]            ; Substract player height with the current row
    cmp     ax, [player_size]         ; compares if ax is greater than player size
    jng     renderPlayerAux           ; if not greater, draw next row
    ret                               ; Else, return


deletePlayer:                       ; Funtion to erase player from screen
    mov     al, 00h                 ; Move color black to al
    mov     [player_color], al      ; Updates player color to black 
    call    renderPlayer            ; Render player in color black
    mov     al, 03h                 ; Set al as the original player color
    mov     [player_color], al      ; Updates player color to black
    ret                             ; return


; Checks player inputs -----------------------------------------------------------------------------------------------------------

checkPlayerGameInput:
    mov     ax, 00h                   ; Reset reg ax
    cmp     ax, [gamePaused]           ; move the gamePaused Flag to ax
    je      makeMovements             ; If the game is not paused, player can move 
    ;jmp     checkPlayerPausedAction   ; If the game is paused, checks if the input is to unpaused the game


makeMovements:
    mov     ah, 01h                 ; gets keyboard status
    int     16h                     ; interrupt 

    jz      exitRoutine             ; if not pushed key, exit

    mov     ah, 00h                 ; Read key
    int     16h                     ; interrupt

    cmp     ah, 48h                 ; If the key pushed is arrow up
    je      playerUp                ; Moves player up
    
    cmp     ah, 50h                 ; If the key pushed is arrow down
    je      playerDown              ; Moves player down

    cmp     ah, 4dh                 ; If the key pushed is arrow right 
    je      playerRight             ; Moves player right

    cmp     ah, 4bh                 ; If the key pushed is arrow left 
    je      playerLeft              ; Moves player left

    ret

playerUp:                           ; Moves player up
    mov     ax, 06h                 ; Moves 6 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          ; Mueve la posicion y del alien a ax
    sub     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_y], ax     ; Almacena la nueva posicion en una variable temporal
    
    call    checkPlayerColision     ; Llama a la funcion para detectar colisiones del alien

    mov     [player_y], ax            ; Updates pos y of player


    ret                             ; return


playerDown:                         ; Moves player down
    mov     ax, [gameHeight]        ; Moves the game height to ax
    add     ax, 06h                 ; add 6 to ax 
    cmp     [player_y], ax          ; compares the player_y to the up border
    jge      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          ; Mueve la posicion y del alien a ax
    add     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_y], ax     ; Almacena la nueva posicion en una variable temporal
    call    checkPlayerColision     ; Llama a la funcion para detectar colisiones del alien

    mov     [player_y], ax            ; Updates pos y of player

    ret                             ; return

playerRight:                        ; Moves player right
    mov     ax, [gameWidth]         ; Moves the game height to ax
    add     ax, 06h                 ; add 5 to ax 
    cmp     [player_x], ax          ; compares the player_y to the right border
    jge      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          ; Mueve la posicion x del alien a ax
    add     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_x], ax     ; Almacena la nueva posicion en una variable temporal
    call    checkPlayerColision     ; Llama a la funcion para detectar colisiones del alien

    mov     [player_x], ax          ; Updates pos y of player

    ret                             ; return

playerLeft:                         ; Moves player left
    mov     ax, 06h                 ; Moves the game height to ax
    cmp     [player_x], ax          ; compares the player_y to the right border
    jle      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          ; Mueve la posicion x del alien a ax
    sub     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_x], ax     ; Almacena la nueva posicion en una variable temporal
    call    checkPlayerColision     ; Llama a la funcion para detectar colisiones del alien

    mov     [player_x], ax          ; Updates pos y of player
    

    ret                             ; return

; Render walls------------------------------------------------------------------------------

renderWalls:
    mov    ax, 01h
    cmp    ax, [level]
    je     renderWallsLvl1Main
    jmp    renderWallsLvl2

renderWallsLvl1Main:
    mov esi, 0 ; initialize i to 0
    jmp renderWallsLvl1Loop

renderWallsLvl1Loop:
    cmp     esi, [total_walls_lvl_1]  ; Compara el contador i con el total de muros en el nivel 2
    je      exitRoutine
    mov     cx, [walls_x_start_l1 + 2*esi]            
    mov     dx, [walls_y_start_l1 + 2*esi]
    jmp     renderWallsLvl1Aux


renderWallsLvl1Aux:
    mov     ah, 0ch                           ; Draw pixel
    mov     al, [walls_color]                 ; player color 
    mov     bh, 00h                           ; Page
  
    int     10h                               ; Interrupt 
    inc     cx                                ; cx +1
    mov     ax, cx                            ; mno
    cmp     ax, [walls_x_end_l1 + 2*esi]      ; compares if ax is greater than the wall x limit 
    jng     renderWallsLvl1Aux                ; if not greater, draw next column
    jmp     renderWallsLvl1Aux2               ; Else, jump to next aux function


renderWallsLvl1Aux2:
    mov     cx, [walls_x_start_l1 + 2*esi]    ; reset columns
    inc     dx                                ; dx +1
    mov     ax, dx                  
    cmp     ax, [walls_y_end_l1 + 2*esi]      ; compares if ax is greater than player size
    jng     renderWallsLvl1Aux                ; if not greater, draw next row
    jmp     renderWallsLvl1Aux3               ; Else, return

renderWallsLvl1Aux3:
    inc esi  ; +=1 to i counter of the walls 
    jmp renderWallsLvl1Loop


renderWallsLvl2:
    ret


;-----------------------Check colisions-------------------------------------------------

checkPlayerColision:
    push ax

    mov cx, [temp_player_x]
    mov dx, [temp_player_y]
    mov ah, 0dh
    mov bh, 00h
    int 10h

    cmp al, [walls_color]
    je exitPlayerMovement

    pop ax

    ret


exitPlayerMovement:
    mov     ax, [player_x]            ; Mueve la posicion x del alien a ax
    mov     [temp_player_x], ax           ; Almacena ax a la posicion temporal x del alien
    mov     ax, [player_y]            ; Mueve la posicion y del alien a ax
    mov     [temp_player_y], ax           ; Almacena ax a la posicion temporal y del alien

    call resetGame 




; Util functions --------------------------------------------------------------------------------------

resetGame:
    call clearScreen
    jmp menuLoop

exitRoutine:                        ; Funcion encargada de retornar
    ret                             ; Retornar