global data
global posZorro
global posOcas
global posInvalidas
global ocasEnJuego
global ocasCapturadas
global jugadorActual
global jugadaValida
global inputValido
global ocaValida
global estadoJuego
global ocaActual
global posSiguiente
global tablero
global movimiento
global comio
global ocaAComer
global movPosibles
global movOca
global movZorro
global zorro
global ocas
global ganador
global estaGuardado
global posEstZorro
global estZorro
global rotacion
global contIvalidas
global cantMovZorro
global cantMovOca
global clearCmd
global fmt
global fmtEmoji, fmtLetra
global jugador1, jugador2

section .data
    ; jugadores
    jugador1        db "Zorro",0
    jugador2        db "Ocas",0
    ocas            db 'O',0        ; 6F
    zorro           db 'X',0        ; 58
    ; datos deafault
    movOca          db "a", "x", "d", 0
    cantMovOca      db 3
    movZorro        db "q", "w", "e", "a" ,"d", "z", "x" ,"c"
    estZorro        db 0, 0, 0, 0, 0, 0, 0, 0   ; estadisticas de movimiento del zorro
    cantMovZorro    db 8
    posZorro        db 34
    posOcas         db 20, 30, 40, 21, 31, 41, 02, 12, 22, 32, 42 ,52, 62, 03, 63, 04, 64
    posInvalidas    db 00, 10, 50, 60, 01, 11, 51, 61, 05, 15, 55, 65, 06, 16, 56, 66
    contIvalidas    db 16
    ocasEnJuego     db 17
    ocasCapturadas  db 0            ; ocas que ya se comieron 
    rotacion        db 0            ; 0 default, 1 180°, 2 izquierda, 3 derecha
    ; booleanos
    estaGuardado    db 0            ; indica si se guardo previamente el juego, 0 no 1 si
    comio           db 0            ; 0 si todavia no trato de comer; 1 si ya trato
    jugadorActual   db 0            ; 0 es zorro/1 es oca
    jugadaValida    db 1            ; 0 False/ 1 True
    inputValido     db 1            ; 0 False/ 1 True
    ocaValida       db 0            ; 0 False/ 1 True
    estadoJuego     db 0            ; 0 jugando, 1, gano el zorro, -1 gano ocas
    ; prints
    clearCmd        db "clear", 0   ; para usar system clear
    fmt             db "%s",0       ; formato de print sin salto de linea
    fmtLetra        db " %s",0      ; formato de print sin salto de linea con espacio
    fmtEmoji        db "%s",0       ; formato de print sin salto de linea de elementos del tablero
  
section .bss
    tablero         resw 49         ; 49 caracteres y el 0 al final --> "c", 0
    ocaActual       resb 100
    posSiguiente    resb 100
    movimiento      resb 100
    ocaAComer       resb 100
    movPosibles     resb 100
    ganador         resb 100
    posEstZorro     resb 100