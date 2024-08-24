global pedirDatosIniciales, terminarPartida, guardarPartida

%include "auxiliar.asm"

;"data.asm"
extern printRotacionInvalida, rotacion, zorro, ocas, estaGuardado, estadoJuego

;"prints.asm"
extern printPedirRotacion, printGanador, printPedirZorro, printPedirOca, printEstadisticas

;"archivo.asm"
extern guardarDatos

section .data
    input       db 0

section .text

pedirDatosIniciales:
    mCall       printPedirZorro
    mInput      input
    mMovb       zorro, input            ; zorro <-- input

    mCall       printPedirOca
    mInput      input
    mMovb       ocas, input             ; ocas <-- input
    
_pedirRotacion:
    mCall       printPedirRotacion
    mInput      input
    cmp         byte[input], "0"
    je          _asignarRotacion
    cmp         byte[input], "1"
    je          _asignarRotacion
    cmp         byte[input], "2"
    je          _asignarRotacion
    cmp         byte[input], "3"
    je          _asignarRotacion
    mCall       printRotacionInvalida
    jmp         _pedirRotacion

_asignarRotacion:
    mov         al, byte[input]
    sub         al, "0"
    mov         byte[rotacion], al
    ret

terminarPartida:
    mov         byte[estaGuardado],0    
    mCall       guardarDatos
    cmp         byte[estadoJuego],0
    je          _sinGanador
    mCall       printGanador
    
_sinGanador:
    mCall       printEstadisticas
    mCall       finalizar
    
guardarPartida:
    mov         byte[estaGuardado],1    
    mCall       guardarDatos
    mCall       finalizar

finalizar:
    mov         eax, 60     ; Número de syscall para exit
    xor         edi, edi    ; Código de retorno 0
    syscall                 ; Realizar la syscall para salir del programa