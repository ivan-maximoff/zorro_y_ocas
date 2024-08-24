global validarInput
global validarMovimiento
global validarOca
global definirActual
global zorro_gana
global tieneMovimientos

%include "auxiliar.asm"

;"data.asm"
extern contIvalidas, ganador, movOca, movZorro
extern movPosibles, ocaAComer, comio, jugadorActual
extern posZorro, posOcas, posInvalidas, jugadaValida
extern ocaValida, ocaActual, posSiguiente, movimiento
extern inputValido, estadoJuego, ocasEnJuego
extern cantMovOca, cantMovZorro

;"movimientos.asm"
extern movimientoArrIzq, movimientoArriba ,movimientoArrDer ,movimientoIzq
extern movimientoDer, movimientoAbjIzq, movimientoAbajo, movimientoAbjDer

extern arr, abj, izq, der, ar_der, ab_der, ar_izq, ab_izq

;"prints.asm"
extern printOcaSinMov, printGanador, jugador1, jugador2
section .text

; AUXILIARES GENERALES

invalidarTodo:
    mCall   invalidarJugada
    mCall   invalidarComio
    ret
     
invalidarJugada:
    mov     byte [inputValido], 0       ; invalida la jugada
    mov     byte [jugadaValida], 0      ; invalida la jugada
    ret

invalidarComio:
    mov     byte[comio], 0
    ret

actual_zorro:
    mMovb   posSiguiente, posZorro      ; posSiguiente <- posZorro
    ret

actual_oca:
    mMovb   posSiguiente, ocaActual     ; posSiguiente <- ocaActual
    ret

definirActual:
    cmp     byte [jugadorActual],0
    jz      actual_zorro                ; si es zorro 
    jnz     actual_oca                  ; si es oca
    ret



; VALIDACION OCA SELECCIONADA
aprobarOca:
    mov     byte [ocaValida], 1
    ret

desaprobarOca:
    mov     byte [ocaValida], 0
    ret

validarOca:
    mComparaLoop    posOcas, ocasEnJuego, ocaActual, aprobarOca
    mCall           tieneMovimientos  
    ret


; VALIDACION INPUT
%macro mValidarInput 2
    mov     al, byte[%1]                    ; comparo movimiento (ej: "q"), con la entrada
    cmp     byte [movimiento], al           ; si es el movimiento indicado salta a la funcion de mov indicada
    je      %2                              ; (ej: je movimientoArrIzq)
%endmacro

validarInput:
    ; switch que calcula posSiguiente| oca solo puede abajo, izq o der | zorro puede todas 
    cmp     byte[jugadorActual], 1          ; si es oca
    je      mov_ocas                        ; solo se fija si es alguno de sus movimientos posibles

    mValidarInput ar_izq, movimientoArrIzq  ; si parametro1 es el movimiento, bifurca a parametro 2
    mValidarInput arr,    movimientoArriba  ; ...
    mValidarInput ar_der, movimientoArrDer  ; ...
    mValidarInput ab_der, movimientoAbjDer  ; ...
    mValidarInput ab_izq, movimientoAbjIzq  ; ...
    
mov_ocas:
    mValidarInput izq, movimientoIzq        ; ...
    mValidarInput abj, movimientoAbajo      ; ...
    mValidarInput der, movimientoDer        ; ...
    
    mCall invalidarJugada                   ; si no cumple ninguna invalido
    ret

;VALIDACION MOVIMIENTO 
validarMovimiento:                          ; invalida si:..
    cmp     byte[posSiguiente], 0
    jl      invalidarTodo                   ; ..si es < 0
    cmp     byte[posSiguiente],66
    jg      invalidarTodo                   ; ..si es > 66

    movzx   rax, byte[posSiguiente]
    mov     cl, 10
    idiv    cl
    cmp     ah, 7
    je      invalidarTodo                   ; ..si es igual a 7
    cmp     ah, 9
    je      invalidarTodo                   ; ..si es igual a 9

    mCall   validarPosicion
    ret

validarPosicion:
    ; verifica si moviendote pisas una oca
    mComparaLoop posOcas, ocasEnJuego, posSiguiente, invalidarJugada
    cmp     byte[jugadaValida], 0           ; si la jugada se invalido fue por pisar una oca y chequea si se pued come
    jne     vueltaDeComer                   ; si es valida no come
    
validarComer:
    cmp     byte[jugadorActual], 1
    je      vueltaDeComer                   ; si es oca no puede comer

    cmp     byte[comio],1                   ; si ya trato de comer:
    je      invalidarComio                  ; vuelve a resetear comio
    je      vueltaDeComer                   ; vuelve
     
    mov     byte[comio], 1                  ; si es la primera vez que intenta comer, pisa 
    mov     byte[jugadaValida], 1

    mMovb   ocaAComer, posSiguiente         ; ocaAComer <- posSiguiente
    
    mCall   validarInput                    ; recalcula donde caer dps de saltar
    mCall   validarMovimiento
    
vueltaDeComer:
    ; verifica si moviendote pisas una pared
    mComparaLoop posInvalidas, contIvalidas, posSiguiente, invalidarJugada
    cmp     byte[jugadaValida], 0           ; si hay pared invalida 
    je      invalidarComio           

    mov     al, byte[posZorro]              
    cmp     al, byte[posSiguiente]          ; si esta el zorro invalida
    je      invalidarJugada
    ret

; CALCULADORA DE MOVIMIENTOS POSIBLES
%macro mCargarMovimientos 2     ; (1): vector de movimientos (ej: "a","x","d"), (2): largo del vector
    mov     rsi, %1
    movzx   rcx, byte[%2]
%endmacro

tieneMovimientos:
    mov     byte[movPosibles], 0              ; inicializamos contador en 0

    mCargarMovimientos movZorro, cantMovZorro ; inicializamos para el zorro

    cmp     byte [jugadorActual],0
    jz      loopMovimientosValidos            ; si es zorro salta y verifica para el zorro
    
    mCargarMovimientos movOca, cantMovOca     ; si es oca, lo pisa al zorro y verifica para oca

loopMovimientosValidos:
    mov     byte [jugadaValida], 1            ; inicializa como valido

    mMovb   movimiento, rsi                   ; [movimiento]<-[rsi] 
    push    rcx
    push    rsi
    mCall   definirActual
    mCall   validarInput
    mCall   validarMovimiento
    pop     rsi
    pop     rcx
    cmp     byte[jugadaValida],1              ; si es una jugada valida, tiene al menos 1 movimiento
    je      fin                               ; bifurca a fin
    inc     rsi
    loop    loopMovimientosValidos            ; si no sigue buscando

    mCall   jugadorSinMovimientos               

fin:
    mov     byte[jugadaValida],1               ; vuelvo a dejarla valida
    ret

jugadorSinMovimientos:
    cmp     byte [jugadorActual],0
    jz      ocas_gana                          ; si es zorro 
    jnz     ocaSinMovimientos                  ; si es oca
    ret

ocaSinMovimientos:
    mCall   printOcaSinMov
    mCall   desaprobarOca
    ret

ocas_gana:
    mov     byte[estadoJuego], -1
    mMovq   ganador, jugador2                  ; [ganador]<-[jugador2]
    ret

zorro_gana:
    mov     byte[estadoJuego], 1
    mMovq   ganador, jugador1                  ; [ganador]<-[jugador1]
    ret
