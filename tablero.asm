
extern rotacion, posZorro, posOcas, posInvalidas, tablero, ocasEnJuego, ocas, zorro
extern puts
%include "auxiliar.asm"

section .data
    pared           db '#', 0
    vacio           db ' ', 0
    divisor         db 10
    cantParedes     db 16
    longFila        db 7
    largoElemento   db 2

section .bss
    fila            resb 1      ; fila del elemento actual
    columna         resb 1      ; columna del elemento actual
    posicion        resb 1      ; posicion del elemento actual

section .text

%macro mCargarVector 3          ; rsi <-- (1), dx <-- (2), cl <-- (3)
    mov     rsi, %1             ; (1) Dirección 
    mov     dx, word[%2]        ; (2) Símbolo 
    mov     cl, %3              ; (3) numero de elementos
    mCall   cargarPosiciones    ; carga las posiciones dadas
%endmacro

global actualizarTablero
actualizarTablero:
    mCall   tableroVacio

    ; Dirección posOcas, Símbolo oca, numero de ocas
    mCargarVector   posOcas, ocas , byte [ocasEnJuego]

    ; Dirección posParedes, Símbolo '#', numero de paredes
    mCargarVector   posInvalidas, pared , byte [cantParedes]

    ; Dirección zorro, Símbolo zorro, numero de zorro
    mCargarVector   posZorro, zorro , 1

    ret

; Rellena el tablero de espacios vacios
tableroVacio:
    mov     rcx, 49             ; Cargar la longitud del tablero en rcx
    mov     rsi, tablero        ; Cargar la dirección base del tablero en rsi
    mov     rdi, 0              ; Inicializar el índice rdi a 0

    mCall    _asignarEspacios   ; Llamar a la función para asignar espacios
    ret

_asignarEspacios:
    mMovw   rsi+rdi, vacio      ; Asignar ' ' al elemento actual del tablero

    add     rdi, 2              ; Incrementar el índice rdi
    loop    _asignarEspacios    ; Saltar al inicio de la función para continuar asignando
    ret

cargarPosiciones:
    ; Entrada:
    ;   rsi -> dirección del vector de posiciones
    ;   dx -> símbolo a colocar
    ;   cl -> número de elementos
    mov       rbx, 0                            ; Inicializar el índice a 0
    mov       r8b, byte[divisor]                ; Cargar el divisor en r8b (registro de 8 bits)

_cargarLoop:
    cmp     rcx, 0                              ; Comparar rcx con 0 para verificar si terminamos
    je      terminarFuncion                     ; Si rcx es 0, salir de la función

    ; Obtener el primer y segundo dígito
    movzx   rax, byte [rsi+rbx]                 ; ax = CF siendo C la columna y F la fila
    mCall   rotar                               ; cambia CF segùn la rotaciòn actual
    idiv    r8b                                 ; al = ax / r8b (columna), ah = ax % r8b (fila)
    mov     byte[columna], al                   ; columna <-- al
    mov     byte[fila],ah                       ; fila <-- ah

    ; Posicion = fila * longFila + columna
    mMulb   fila, longFila, posicion            ; posicion = fila * longFila
    mAddb   posicion, columna, posicion         ; posicion = fila * longFila + columna
    mov     r10, tablero                        ; r10 <-- direcc del tabler
    mMulb   posicion, largoElemento, posicion   ; posicion = posicion * largoElemeto

    ; asigna el simbolo en tablero + posicion
    add     r10b, byte[posicion]                ; r10 + posicion
    mov     [r10], dx                           ; Asignar el símbolo dx en la posición calculada
    
    ; actualiza el loop y repite hasta que se vean todos los elementos
    inc     rbx
    dec     ecx
    cmp     ecx, 0
    jne     _cargarLoop
    ret
    
rotar:
    ; Entrada
    ; --> ax: numero de posicion CF
    cmp     byte[rotacion], 0   ; si no hay rotacion, vuelve
    je      terminarFuncion
    cmp     byte[rotacion], 2
    je      _rotIzquierda       ; si es 2 es rotacion Izquierda
    jg      _rotDerecha         ; si es < 2 (3) es rotacion Derecha
    jl      _rot180             ; si es > 2 (1) es rotación 180°

_rot180:
    mRotacion180
    ret

_rotIzquierda:
    mRotacionIzquierda
    ret

_rotDerecha:
    mRotacionDerecha

terminarFuncion:
    ret
