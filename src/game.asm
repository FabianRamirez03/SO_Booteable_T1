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
gameWidth dw 096h ; Board width set to 150p

gamePaused dw 00h ; Flag to know if the game is paused

; player

player_x dw      05h   ; x position player 
player_y dw      05h   ; y position player 
temp_player_x dw 05h   ; temp x position player
temp_player_y dw 05h   ; temp y position player
player_speed dw  0ah   ; player speed
player_color dw  03h   ; player color
player_size dw   05h   ; player dimensions 
player_dir dw    00h   ; last direction of player (0 right, 1 down, 2 left, 3 up) 


; Walls ----------------------------------------------------------------------------------------------------
walls_color dw 150h ; walls color 
walls_size  dw 0ah ; walls width and height set 6p
walls_index dw 00h ; walls counter
wallx dw 00h ; x wall pos
wally dw 00h ; y wall pos

walls_x_l1 dw 37h, 41h, 4bh ; Walls's X positions for L1
walls_y_l1 dw 23h, 23h, 23bh ; Y positions for L1
walls_n_l1 dw 03h ; Number of walls for L1

walls_x times 3 dw 00h ; current walls positions
walls_y times 3 dw 00h ; current walls positions
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
    ;call renderWalls               ; function to draw the walls

    ;call renderTextHints           ; function to draw the hints for keyboard use

    jmp     gameLoop                ; Salta al incio de la funcion

; Render functions **************************************************************************************

renderWalls:
    mov cx, [walls_index] ; loading the index to loop the walls
    cmp cx, [walls_n] ; Comparing the counter with the number of walls
    je exitWalls    ; if counter == walls_n : exit

    mov ax, [walls_index] ; loading the walls index 
    mov bx, [walls_x] ; loading first wall element in Walls X positions array
    add bx, ax ; base_position + Index = current wall pointer
    mov ax, [bx] ; X position for first wall
    mov [walls_x], ax ; Store current X position
    mov cx, [walls_x] ; Loads first wall position

    mov ax, [walls_index] ; Loads walls index to AX

    mov bx, walls_y ; loads first Y position pointer
    add bx, ax ; base_Y_position + Index = current position
    mov ax, [bx] ; loads first Y position
    mov [walls_y], ax ; stores current Y position

    jmp renderWalls_Aux

renderWalls_Aux:
    mov ah, 0ch ; Render pixel function
    mov al, [walls_color] ; Walls color
    mov bh, 00h ; Page
    int 10h ; Execute interruption
    inc cx ; Increments CX
    mov ax, cx ; moves CX to AX
    sub ax, [walls_x] ; WALL_WIDTH - CURRENT_COLUMN = TMP_RESULT
    cmp ax, [walls_size] ; compares TMP_RESULT with wall width

    jng renderWalls_Aux ; If not greater than 
    jmp renderWalls_Aux2 ; else

renderWalls_Aux2: 
    mov cx, [walls_x] ; Reset number of columns
    inc dx ; Increments DX
    mov ax, dx ; moves DX to AX
    sub ax, [walls_y] ; CURRENT_ROW - WALL_Y_POS = TMP_RESULT
    cmp ax, [walls_size] ; compares TMP_RESULT with wall's height

    jng renderWalls_Aux ; if not greater 
    jmp renderWalls_Aux3 ; else

renderWalls_Aux3:
    mov cx, [walls_index] ; loads the walls index
    add cx, 02h ; walls_index + 2
    mov [walls_index], cs ; stores the new index

    jmp renderWalls ; jumps to root render function

exitWalls:
    mov ax, 00h ; 
    mov [walls_index], ax ; resets walls index

    ret ; go back and continue the game loop.

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
    mov     ax, 05h                 ; Moves 5 to ax
    cmp     [player_y], ax          ; compares the player_y to the up border
    je      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          ; Mueve la posicion y del alien a ax
    sub     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_y], ax     ; Almacena la nueva posicion en una variable temporal
    ;call    checkAlienColision     ; Llama a la funcion para detectar colisiones del alien

    ;cmp     ax, 00h                ; Verifica si ax es 0
    ;je      exitAlienMovement      ; En caso de serlo, significa que la nueva posicion es invalida, y salta a la funcion de salida

    mov     [player_y], ax            ; Updates pos y of player
    
    mov     ax, 03h                 ; Moves 3 to ax
    mov     [player_dir], ax        ; moves 3 to the player direction

    ret                             ; return


playerDown:                         ; Moves player down
    mov     ax, [gameHeight]        ; Moves the game height to ax
    add     ax, 05h                 ; add 5 to ax 
    cmp     [player_y], ax          ; compares the player_y to the up border
    je      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_y]          ; Mueve la posicion y del alien a ax
    add     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_y], ax     ; Almacena la nueva posicion en una variable temporal
    ;call    checkAlienColision     ; Llama a la funcion para detectar colisiones del alien

    ;cmp     ax, 00h                ; Verifica si ax es 0
    ;je      exitAlienMovement      ; En caso de serlo, significa que la nueva posicion es invalida, y salta a la funcion de salida

    mov     [player_y], ax            ; Updates pos y of player
    
    mov     ax, 03h                 ; Moves 1 to ax
    mov     [player_dir], ax        ; moves 1 to the player direction

    ret                             ; return

playerRight:                        ; Moves player right
    mov     ax, [gameWidth]         ; Moves the game height to ax
    add     ax, 05h                 ; add 5 to ax 
    cmp     [player_x], ax          ; compares the player_y to the right border
    je      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          ; Mueve la posicion x del alien a ax
    add     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_x], ax     ; Almacena la nueva posicion en una variable temporal
    ;call    checkAlienColision     ; Llama a la funcion para detectar colisiones del alien

    ;cmp     ax, 00h                ; Verifica si ax es 0
    ;je      exitAlienMovement      ; En caso de serlo, significa que la nueva posicion es invalida, y salta a la funcion de salida

    mov     [player_x], ax          ; Updates pos y of player
    
    mov     ax, 00h                 ; Moves 0 to ax
    mov     [player_dir], ax        ; moves 0 to the player direction

    ret                             ; return

playerLeft:                         ; Moves player left
    mov     ax, 05h                 ; Moves the game height to ax
    cmp     [player_x], ax          ; compares the player_y to the right border
    je      exitRoutine             ; if equal, return. Dont move

    call    deletePlayer            ; Deletes player from screen

    mov     ax, [player_x]          ; Mueve la posicion x del alien a ax
    sub     ax, [player_speed]      ; Resta la velocidad del alien a ax
    mov     [temp_player_x], ax     ; Almacena la nueva posicion en una variable temporal
    ;call    checkAlienColision     ; Llama a la funcion para detectar colisiones del alien

    ;cmp     ax, 00h                ; Verifica si ax es 0
    ;je      exitAlienMovement      ; En caso de serlo, significa que la nueva posicion es invalida, y salta a la funcion de salida

    mov     [player_x], ax          ; Updates pos y of player
    
    mov     ax, 00h                 ; Moves 0 to ax
    mov     [player_dir], ax        ; moves 0 to the player direction

    ret                             ; return



exitRoutine:                        ; Funcion encargada de retornar
    ret                             ; Retornar