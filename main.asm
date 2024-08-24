global main

%include "auxiliar.asm"

;"data.asm"
extern clearCmd, jugadorActual, estaGuardado, estadoJuego

;"prints.asm"
extern printTablero

;"validaciones.asm"
extern comio

;"tablero.asm"
extern actualizarTablero

;"archivo.asm"
extern importarDatos, importarDefault, guardarDefault

;"movimientos.asm"
extern setearMovimientos 

;"jugadas.asm"
extern zorroLoop, ocaLoop

;"juego.asm"
extern pedirDatosIniciales, terminarPartida

section .data
    input       db 0

section .text

main:
    mClear      clearCmd
    mCall       guardarDefault
    mCall       importarDatos

    cmp         byte[estaGuardado],1    ; si ya estaba guardado juega con esos datos
    je          setearMovs              
         
    mCall       importarDefault         ; si no importa los datos default
    mCall       pedirDatosIniciales     
       
setearMovs:
    mCall       setearMovimientos

juegoLoop:        
    mClear      clearCmd
    mCall       actualizarTablero
    mCall       printTablero

    cmp         byte[estadoJuego], 0    ; si hay un ganador termina el juego
    jne         terminarPartida    
    
    mov         byte[comio], 0
    cmp         byte [jugadorActual], 0
    jz          zorro                   ; si es zorro llamo zorro loop
    jnz         oca                     ; si es oca llamo oca loop             
zorro:
    mCall       zorroLoop
    jmp         juegoLoop
oca:
    mCall       ocaLoop
    jmp         juegoLoop

