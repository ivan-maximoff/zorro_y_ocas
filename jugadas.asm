global zorroLoop
global ocaLoop

%include "auxiliar.asm"

;"data.asm"
extern rotacion, ocasCapturadas, ocasEnJuego, posZorro, posOcas, posInvalidas, jugadaValida, ocaValida, ocaActual, posSiguiente, movimiento, inputValido, estadoJuego, jugadorActual, validarInput, validarMovimiento, validarOca, ocaAComer, clearCmd, zorro, ocas, estaGuardado

;"prints.asm"
extern printPedirRotacion ,printTablero, printRealizarMovimiento, printMensajeOca, printMovimientoInvalido, printOcaInvalida, printGanador, printPedirZorro, printPedirOca, printEstadisticas

;"validaciones.asm"
extern tieneMovimientos,validarInput, validarMovimiento, validarOca, definirActual, comio, zorro_gana

;"tablero.asm"
extern actualizarTablero

;"archivo.asm"
extern importarDatos, guardarDatos, importarDefault, guardarDefault

;"movimientos.asm"
extern movimientoSumar, setearMovimientos

;"juego.asm"
extern guardarPartida, terminarPartida

section .text

; JUGADAS ZORRO
zorroLoop:

    mCall       pedirMovimiento         ; pido movimiento y se guarda en posSiguiente
    mCall       moverZorro              ; realiza el movimiento
    
    cmp         byte[ocasCapturadas],12 ; caso en el que el zorro comio 12 ocas
    je          zorro_gana              ; gana el zorro

    cmp         byte[comio], 1          
    je          finLoop                 ; si comio tiene otro movimiento
    mov         byte [jugadorActual],1  ; cambio jugador a Oca
    
finLoop:
    ret

moverZorro:
    mCall       movimientoSumar
    mMovb       posZorro, posSiguiente  ; posZorro <-- posSiguiente
    cmp         byte[comio],1           ; si el zorro comio
    je          comer
    ret

comer: 
    mComparaLoop posOcas, ocasEnJuego, ocaAComer, eliminarOca
    dec         byte[ocasEnJuego]
    inc         byte[ocasCapturadas]
    ret
    
eliminarOca:    
    movzx       r15, byte[ocasEnJuego]   ; n
    dec         r15                      ; n-1
    mov         r11, posOcas
    add         r11, r15                 ; en r11 tenemos la dir de la ultima oca
    mMovb       rsi, r11                
    ret
; JUGADAS OCA
ocaLoop:
    mCall       pedirOca                 ; pido oca y se guarda en ocaActual
    mCall       pedirMovimiento          ; pido movimiento y se guarda en posSiguiente
    mCall       moverOca                 ; realiza el movimiento

    mov         byte [jugadorActual],0   ; cambio jugador a Zorro
    mCall       tieneMovimientos         ; si despues de que movio la oca encerraron al zorro
    jmp         finLoop

pedirOca:
    mCall       printMensajeOca         
    mInput      ocaActual                ; pide casilla (ej. D5)

    cmp         byte [ocaActual], "y"
    je          terminarPartida          ; terminar partida
    cmp         byte [ocaActual], "l"
    je          guardarPartida           ; guardar partida

    mCall       leerCoordenada
    mCall       validarOca               ; valida input y la transforma en 
    mov         byte [jugadaValida], 1   ; inicializa como valido

    cmp         byte [ocaValida], 0     ; si es invalido:
    je          ocaInvalido             ; printea error y vuelve a pedir
    mov         byte [ocaValida],0      ; vuelvo a invalidar
    ret

leerCoordenada:
    mToUpper    ocaActual
    movzx       rax, byte [ocaActual]   ; Cargar el primer carácter en rax
    sub         rax, 'A'                ; Convertir 'A' a 0, 'B' a 1, ..., 'G' a 6
    imul        rax, 10                 ; Multiplicar por 10 para obtener 00, 10, ..., 60

    ; Convertir el número
    movzx       rcx, byte[ocaActual+1]  ; Cargar el segundo carácter en rcx
    sub         rcx, '1'
    ; Sumar ambos valores
    add         rax, rcx                ; Sumar los valores para obtener el resultado final

    mCall       traducir
    ret
;traducido:
;    mov [ocaActual], ax             ;Pisamos el valor con el nuevo transformado
;    ret

moverOca:
    mComparaLoop posOcas, ocasEnJuego, ocaActual, actualizar_oca
    ret
    
actualizar_oca:
    movzx       r10, byte[posSiguiente] ; cargamos la nueva posicion
    mov         [rsi], r10b             ; Si son iguales, actualiza el valor de la oca
    ret


; GENERALES
pedirMovimiento:
    mCall       printRealizarMovimiento
    mInput      movimiento              ; pide movimiento (Q,W,E,D,C,X,Z,A)
    mToLower    movimiento

    cmp         byte [movimiento], "y"  
    je          terminarPartida         ; terminar partida
    cmp         byte [movimiento], "l"
    je          guardarPartida          ; guardar partida

    mov         byte [inputValido], 1   ; inicializa como valido
    mCall       definirActual
    mCall       validarInput            ; valida input y la transforma en nueva pos


    cmp         byte [inputValido], 0   ; si es invalido:
    Je          movimientoInvalido      ; printea error y vuelve a pedir
    
    mov         byte [jugadaValida], 1  ; inicializa como valido
    
    mCall       validarMovimiento       ; valida nueva posicion
    
    cmp         byte [jugadaValida], 0  ; si es invalido:
    Je          movimientoInvalido      ; printea error y vuelve a pedir
    ret

movimientoInvalido:
    mCall       printMovimientoInvalido ; print
    mCall       pedirMovimiento         ; repite
    ret

ocaInvalido:
    mov         byte [jugadaValida], 1  ; inicializa como valido
    mCall       printOcaInvalida        ; print
    jmp         pedirOca                ; repite

; TRADUCTOR
traducir:
    cmp         byte[rotacion], 0       ; si no hay ninguna rotacion
    je          traducido

    ; Entrada --> ax: numero de posicion CF
    cmp         byte[rotacion],2
    je          traducirIzq             ; si es 2 es rotacion Izquierda
    jg          traducirDer             ; si es > 2 (3) es rotacion Derecha
    jl          traducir180             ; si es < 2 (1) es rotación 180°

traducirIzq:
    mRotacionDerecha                    ; si tenemos rotacion Izquierda, rotamos a la derecha para llegar a la default
    jmp         traducido

traducirDer:
    mRotacionIzquierda                  ; si tenemos rotacion Derecha, rotamos a la izquierda para llegar a la default
    jmp         traducido

traducir180:
    mRotacion180

traducido:
    mov         [ocaActual], ax         ; Pisamos el valor con el nuevo transformado
    ret