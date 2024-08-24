extern fopen
extern fread
extern fwrite
extern fputs
extern fclose

global importarDatos, guardarDatos, importarDefault, guardarDefault

extern estaGuardado, posZorro, posOcas, ocasEnJuego, ocasCapturadas, jugadorActual, zorro, ocas, rotacion, estZorro

%include "auxiliar.asm"

section .data
    datosGuardados  db  "datos_guardados.txt",0
    datosDefault    db  "datos_default.txt",0
    modoLectura     db  "rb",0
    modoEscritura   db  "wb",0

section .bss
    fileName        resb    20
    idArchivo       resq    1

section .text

%macro mLeer 2
    mov         rdi, %1
    mov         rsi, %2
    mCall       leer
%endmacro

%macro mEscribir 2
    mov         rdi, %1
    mov         rsi, %2
    mCall       escribir
%endmacro

%macro abrir 2 ; (1) modo, (2) id
    mov         rsi, %1             ; Abrir archivo en modo
    mCall       fopen

    cmp         rax, 0              ; Compara el resultado de fopen con 0
    jle         errorOPEN           ; Salta a 'errorOPEN' si fopen devuelve un número negativo (error)
    mov         qword [%2], rax     ; Almacena el descriptor de archivo devuelto por fopen
%endmacro

leerArchivo:
    ; Entrada 
    ; --> rdi: nombre del archivo
    abrir modoLectura, idArchivo    ; abrir en modo lectura

    mLeer       estaGuardado, 1     ; Leer estaGuardado
    mLeer       zorro, 2            ; Leer zorro
    mLeer       ocas, 2             ; Leer ocas
    mLeer       posZorro, 1         ; Leer posZorro
    mLeer       posOcas, 17         ; Leer posOcas
    mLeer       ocasEnJuego, 1      ; Leer ocasEnJuego
    mLeer       ocasCapturadas, 1   ; Leer ocasCapturadas
    mLeer       jugadorActual, 1    ; Leer jugadorActual
    mLeer       rotacion, 1         ; Leer rotacion
    mLeer       estZorro, 8         ; Leer estZorro

    mov         rdi, [idArchivo]    ; Cerrar archivo
    mCall       fclose
    ret

escribirArchivo:
    ; Entrada 
    ; --> rdi: nombre del archivo
    abrir modoEscritura, idArchivo  ; abrir en modo escritura

    mEscribir   estaGuardado, 1     ; Escribir estaGuardado
    mEscribir   zorro, 2            ; Escribir zorro
    mEscribir   ocas, 2             ; Escribir ocas
    mEscribir   posZorro, 1         ; Escribir posZorro
    mEscribir   posOcas, 17         ; Escribir posOcas
    mEscribir   ocasEnJuego, 1      ; Escribir ocasEnJuego
    mEscribir   ocasCapturadas, 1   ; Escribir ocasCapturadas
    mEscribir   jugadorActual, 1    ; Escribir jugadorActual
    mEscribir   rotacion, 1         ; Escribir rotacion
    mEscribir   estZorro, 8         ; Escribir estZorro

    mov         rdi, [idArchivo]    ; Cerrar archivo
    mCall       fclose
    ret

errorOPEN:
    ret

leer:
    ; Entrada 
    ; --> rdi: variable
    ; --> rsi: tamaño de cada elemento en bytes
    mov         rdx, 1              ; numero de elementos
    mov         rcx,[idArchivo]
    mCall       fread
    ret

escribir:
    ; Entrada 
    ; --> rdi: variable
    ; --> rsi: largo total de bytes
    mov         rdx, 1              ; numero de elementos
    mov         rcx,[idArchivo]
    mCall       fwrite
    ret

importarDefault:
    mov     rdi, datosDefault
    mCall   leerArchivo
    ret

importarDatos:
    mov     rdi, datosGuardados
    mCall   leerArchivo
    ret

guardarDefault:
    mov     rdi, datosDefault
    mCall   escribirArchivo
    ret

guardarDatos:
    mov     rdi, datosGuardados
    mCall   escribirArchivo
    ret