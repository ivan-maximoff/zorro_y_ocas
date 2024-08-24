extern posZorro, ocaActual, posSiguiente, jugadorActual, estZorro, posEstZorro, rotacion, movOca
%include "auxiliar.asm"
global movimientoIzq, movimientoAbjDer, movimientoDer, movimientoArrDer, movimientoArrIzq, movimientoArriba, movimientoAbajo, movimientoAbjIzq, movimientoSumar, setearMovimientos
global arr, abj, izq, der, ar_der, ab_der, ar_izq, ab_izq


section .data
    movArrIzq    db -11
    movArr       db -1
    movArrDer    db 9
    movIzq       db -10
    movDer       db 10
    movAbjIzq    db -9
    movAbj       db 1
    movAbjDer    db 11

    arr         db "w"
    abj         db "x"
    izq         db "a"
    der         db "d" 
    ar_der      db "e" 
    ab_der      db "c" 
    ab_izq      db "z" 
    ar_izq      db "q" 

    movOca180   db "a", "w", "d"
    movOcaIzq   db "w", "d", "x"
    movOcaDer   db "w", "a", "x"

    estArr      db 1
    estAbj      db 6
    estIzq      db 3
    estDer      db 4
    estArrDer   db 2
    estAbjDer   db 7
    estArrIzq   db 0
    estAbjIzq   db 5

section .text

setearMovimientos:
    cmp         byte[rotacion], 0       ; si no hay rotacion, vuelve
    je          finFuncion
    cmp         byte[rotacion],2
    je          setearMovIzq            ; si es 2 es rotacion Izquierda
    jg          setearMovDer            ; si es > 2 (3) es rotacion Derecha
    jl          setearMov180            ; si es < 2 (1) es rotación 180°
finFuncion:
    ret

setearMovIzq:
    mov eax, dWord[movOcaIzq]
    mov dWord[movOca], eax

    ; Cambia las variables de los controles
    mSwapb izq, arr
    mSwapb izq, der
    mSwapb izq, abj
    mSwapb ab_izq, ar_izq
    mSwapb ab_izq, ar_der
    mSwapb ab_izq, ab_der

    ; Cambia las variables de las estadisticas
    mSwapb estIzq, estArr
    mSwapb estIzq, estDer
    mSwapb estIzq, estAbj
    mSwapb estAbjIzq, estArrIzq
    mSwapb estAbjIzq, estArrDer
    mSwapb estAbjIzq, estAbjDer
    ret
    
setearMovDer:
    mov eax, dWord[movOcaDer]
    mov dWord[movOca], eax

    ; Cambia las variables de los controles
    mSwapb der, arr
    mSwapb der, izq
    mSwapb der, abj
    mSwapb ab_der, ar_der
    mSwapb ab_der, ar_izq
    mSwapb ab_der, ab_izq

    ; Cambia las variables de las estadisticas
    mSwapb estDer, estArr
    mSwapb estDer, estIzq
    mSwapb estDer, estAbj
    mSwapb estAbjDer, estArrDer
    mSwapb estAbjDer, estArrIzq
    mSwapb estAbjDer, estAbjIzq
    ret
    
setearMov180:
    mov eax, dWord[movOca180]
    mov dWord[movOca], eax
    
    ; Cambia las variables de los controles
    mSwapb arr, abj
    mSwapb izq, der
    mSwapb ar_der, ab_izq
    mSwapb ar_izq, ab_der

    ; Cambia las variables de las estadisticas
    mSwapb estArr, estAbj
    mSwapb estDer, estIzq
    mSwapb estArrDer, estAbjIzq
    mSwapb estArrIzq, estAbjDer
    ret
    
%macro mMovimiento 2    ; (1): movmiento con numero(ej:movArrIzq -9), (2): estadistica de movimiento
    mAddb posSiguiente, %1, posSiguiente  ; posSiguiente = posSiguiente + mov  (calcula la pos siguiente)
    mMovb posEstZorro, %2                 ; actualiza la estadistica del movimiento realizado
%endmacro
    
movimientoArrIzq:
    mMovimiento movArrIzq, estArrIzq
    ret
movimientoArriba:
    mMovimiento movArr, estArr
    ret
movimientoArrDer:
    mMovimiento movArrDer, estArrDer
    ret
movimientoIzq:
    mMovimiento movIzq, estIzq
    ret
movimientoDer:
    mMovimiento movDer, estDer
    ret
movimientoAbjIzq:
    mMovimiento movAbjIzq, estAbjIzq
    ret
movimientoAbajo:
    mMovimiento movAbj, estAbj
    ret
movimientoAbjDer:
    mMovimiento movAbjDer, estAbjDer
    ret

movimientoSumar:
    cmp       byte [jugadorActual], 0
    jnz       finMovSumar ;si el jugador es oca no sumo movimientos
    mov       r13, estZorro
    movzx     r14, byte[posEstZorro]
    add       r13, r14
    inc       byte[r13]
finMovSumar:
    ret
