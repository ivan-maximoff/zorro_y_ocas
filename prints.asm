%include "auxiliar.asm"
extern jugadorActual, ganador, posZorro, posOcas, posInvalidas, jugadaValida, ocaValida, ocaActual, posSiguiente, movimientom, inputValido, estadoJuego, tablero, fmt, ocasCapturadas, estZorro
extern ocas
extern fmtEmoji, fmtLetra
extern jugador1, jugador2
section .data
    ; informacion del juego
    msgTitulo       db "'El Zorro y las Ocas'",10,0
    msgValidas      db "El zorro se mueve en cualquier direccion",10,"Las ocas solo para adelante o a los costados",10, 0
    msgMovimientos  db "Las direcciones estan representadas por las teclas que rodeean la 's'", 0
    msgTeclas       db "'Y'para terminar la partida y 'L' para guardarla",10, 0
    msgTurno        db "Turno actual: %s", 10,0
    msgOcasCap      db "Ocas capturadas: %i",10, 0
    ; inputs
    msgPedirOca     db "Simbolo de la oca:",0
    msgPedirZorro   db "Simbolo del zorro:",0
    msgRotacion     db "Rotaciones validas: 0 (abajo), 1 (arriba), 2 (izquierda) y 3 (derecha)", 10, "Elegir rotacion: " ,0
    msgCasilla      db "Ocas ingrese la casilla a mover (ej. D5): ",0
    msgMovimiento   db "Movimiento a realizar: ", 0
    ; errores
    msgMovInv       db "Movimiento invalido. Intente nuevamente.", 10, 0
    msgOcaInvalida  db "Oca invalida.", 10, 0
    msgFinal        db "Juego terminado.", 10, 0
    msgOcaSinMov    db "La oca seleccionada no se puede mover.",10, 0
    msgRotacionInv  db "Rotacion invalida", 0
    ; imprimir tablero
    filas           db 7
    columnas        db 7
    saltoDeLinea    db 10,0
    numFila         db "1|", 0
    ; informacion de finalizacion del juego
    msgGanador      db "Gano %s!!!", 10, 0
    msgMovsZorro    db "Movimientos zorro:",0
    msgMovsArrIzq   db "Hacia arr-izq: %i  ",0
    msgMovsArriba   db "Hacia arriba: %i  ",0
    msgMovsArrDer   db "Hacia arr-der: %i",0
    msgMovsIzq      db "Hacia izquierda: %i",0
    msgMovsDerecha  db "Hacia derecha: %i",0
    msgMovsAbaIzq   db "Hacia aba-izq: %i",0
    msgMovsAbajo    db "Hacia abajo: %i",0
    msgMovsAbaDer   db "Hacia aba-der: %i",0
    letrasColumnas  db "_|",
    letras          db 0xE2, 0x92, 0xB6," ",        ; emoji A
                    db 0xE2, 0x92, 0xB7, " ",       ; emoji B
                    db 0xE2, 0x92, 0xB8, " ",       ; emoji C
                    db 0xE2, 0x92, 0xB9, " ",       ; emoji D
                    db 0xE2, 0x92, 0xBA, " ",       ; emoji E
                    db 0xE2, 0x92, 0xBB, " ",       ; emoji F
                    db 0xE2, 0x92, 0xBC, " ", 10, 0 ; emoji G
    emojiZorro      db 0xF0, 0x9F, 0xA6, 0x8A, 0
    emojiOca        db 0xF0, 0x9F, 0xA6, 0x86, 0
    emojiArbol      db 0xF0, 0x9F, 0x8C, 0xB3, 0 
    emojiPasto      db 0xF0, 0x9F, 0x9F, 0xA9, 0

section .text

global printTablero
printTablero:
    mPrint      msgTitulo
    mPrint      msgValidas
    mPrint      msgMovimientos
    mPrint      msgTeclas
    mPrintf     fmt, letrasColumnas

    mov         byte[numFila], 49       ; inicializa el numero de fila en 1
    mov         rsi, tablero            ; puntero al inicio del tablero
    movzx       rcx, byte [filas]       ; contador de filas restantes

_printLoop:
    mPrintf     fmt, numFila
    movzx       rdx, byte [columnas]    ; inicializa el contador de columnas restantes
    
_printRow:
    cmp         byte[rsi], 7Ah          ; compara con el simbolo de zorro (Z)
    je          _printZorro             ; si es zorro bifurca
    cmp         byte[rsi],35            ; compara con el simbolo de pared (#)
    je          _printPared             ; si es pared bifurca
    cmp         byte[rsi], 6Fh          ; compara con el simbolo de ocas (O)
    je          _printOca               ; si es pared bifurca
    cmp         byte[rsi], 20h          ; compara con el simbolo de vacio ( )
    je          _printVacio             ; si es vacio bifurca
    mPrintf     fmtLetra, rsi
    jmp         _avanzar

_printVacio:
    mPrintf     fmtEmoji, emojiPasto  ; si es vacio printea
    jmp         _avanzar

_printZorro:
    mPrintf     fmtEmoji, emojiZorro  ; si es zorro printea
    jmp         _avanzar                ; avanza

_printOca:
    mPrintf     fmtEmoji, emojiOca    ; si es oca printea
    jmp         _avanzar                ; avanza

_printPared:
    mPrintf     fmtEmoji, emojiArbol  ; si es pared printea
    
_avanzar:
    add         rsi, 2                  ; avanza al siguiente elemento
    dec         rdx                     ; decrementa contador de columnas restantes
    jnz         _printRow               ; repite mientras haya columnas restantes

    mPrintf     fmt, saltoDeLinea       ; imprime un salto de línea entre filas
    inc         byte[numFila]           ; aumenta e  numero de fila que se imprime      
    dec         ecx                     ; resta uno al contador de filas restantes
    jnz         _printLoop              ; repite mientras haya filas
    
_printDatos:
    mCall       printTurnoActual
    mCall       printOcasCapturadas
    ret                                 ; retorna del call printTablero

printTurnoActual:
    cmp         byte[jugadorActual],0
    je          _printTurnoZorro
    jne         _printTurnoOca
    
_printTurnoZorro:
    mPrintf     msgTurno, jugador1
    ret

_printTurnoOca:
    mPrintf     msgTurno, jugador2
    ret

printOcasCapturadas:
    mSprintf    msgOcasCap, byte[ocasCapturadas]
    ret

global printRealizarMovimiento
printRealizarMovimiento:
    mPrint      msgMovimiento
    ret

global printMensajeOca
printMensajeOca:
    mPrint      msgCasilla
    ret

global printMovimientoInvalido
printMovimientoInvalido:
    mPrint      msgMovInv
    ret

global printOcaInvalida
printOcaInvalida:
    mPrint      msgOcaInvalida
    ret

global printGanador
printGanador:
    mPrintf     msgGanador, ganador 
    ret

global printOcaSinMov
printOcaSinMov:
    mPrint      msgOcaSinMov
    ret

global printPedirOca
printPedirOca:
    mPrint      msgPedirOca
    ret

global printPedirZorro
printPedirZorro:
    mPrint      msgPedirZorro
    ret

global printEstadisticas
printEstadisticas:    
    mPrint      msgMovsZorro
    mSprintf    msgMovsArrIzq,  byte[estZorro]
    mSprintf    msgMovsArriba,  byte[estZorro + 1]
    mSprintf    msgMovsArrDer,  byte[estZorro + 2]
    mSprintf    msgMovsIzq,     byte[estZorro + 3]
    mSprintf    msgMovsDerecha, byte[estZorro + 4]
    mSprintf    msgMovsAbaIzq,  byte[estZorro + 5]
    mSprintf    msgMovsAbajo,   byte[estZorro + 6]
    mSprintf    msgMovsAbaDer,  byte[estZorro + 7]
    ret

global printPedirRotacion
printPedirRotacion:
    mPrint      msgRotacion
    ret

global printRotacionInvalida
printRotacionInvalida:
    mPrint      msgRotacionInv
    ret