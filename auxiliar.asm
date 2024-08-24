extern printf
extern gets
extern puts
extern system
extern sprintf

; para ejecutar rutinas alinieando el stack
%macro mCall 1
    sub     rsp, 8          ; Restar 8 de rsp para alinear el stack a 16 bytes
    call    %1              ; Llamar a la rutina pasada como parámetro
    add     rsp, 8          ; Agregar 8 a rsp para restaurar el stack
%endmacro

; Imprime un string hasta que encuentra un 0 y agrega \n
%macro mPrint 1
    mov     rdi, %1
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

; Convierte a string cada uno de los parámetros y los imprime con el formato indicado por pantalla.
%macro mPrintf 2
    mov     r12,rdi
    mov     r13,rsi
    mov     r14,rdx
    mov     r15,rcx
    mov     rdi, %1
    mov     rsi, %2
    sub     rsp,8
    call    printf
    add     rsp,8
    mov     rcx,r15
    mov     rdx,r14
    mov     rsi,r13
    mov     rdi,r12
%endmacro

; Ingreso por teclado
%macro mInput 1
    mov     r12,rdi
    mov     r13,rsi
    mov     r14,rdx
    mov     r15,rcx
    mov     rdi, %1
    sub     rsp,8
    call    gets
    add     rsp,8
    mov     rcx,r15
    mov     rdx,r14
    mov     rsi,r13
    mov     rdi,r12
%endmacro

; Limpieza de pantalla
%macro mClear 1
    mov     r12,rdi
    mov     r13,rsi
    mov     r14,rdx
    mov     r15,rcx
    mov     rdi, %1
    sub     rsp,8
    call    system
    add     rsp,8
    mov     rcx,r15
    mov     rdx,r14
    mov     rsi,r13
    mov     rdi,r12
%endmacro

%macro mToLower 1
    cmp     byte[%1],65
    jl      %%fin
    cmp     byte[%1],90
    jg      %%fin
    add     byte[%1],32
%%fin:
%endmacro

%macro mToUpper 1
    cmp     byte[%1],97
    jl      %%fin
    cmp     byte[%1],122
    jg      %%fin
    sub     byte[%1],32
%%fin:
%endmacro

section .bss
    numeroStr  resb 32

; conversion de entero a string y lo imprime 
%macro mSprintf 2
    mov     r12,rdi
    mov     r13,rsi
    mov     r14,rdx
    mov     r15,rcx

    mov     rdi, numeroStr
    mov     rsi, %1
    xor     rdx,rdx
    movzx   rdx, %2
    sub     rsp,8
    call    sprintf
    add     rsp,8
    mPrint  numeroStr
    
    mov     rcx,r15
    mov     rdx,r14
    mov     rsi,r13
    mov     rdi,r12
%endmacro


;f(x) = |x-66|
%macro mRotacion180 0
    ; Entrada --> ax: numero de posicion CF
    sub ax, 66
    cmp ax, 0
    jge positive   ; Si RAX es mayor o igual a 0, saltar a 'positive'

    ;Si RAX es negativo, cambiar el signo
    neg ax        ; Cambiar el signo de RAX
positive:
%endmacro

;f(x) = 60 + cociente de x/10 - resto de x/10 * 10
%macro mRotacionDerecha 0
    ; Entrada --> ax: numero de posicion CF
    mov     r9, 60
    mov     r8, 10
    idiv    r8b
    
    ;
    movzx   r11,al
    xchg    al, ah           
    movzx   r12, al
    ; r12  = ah, r11=al
    
    imul r12, 10
    add  r9, r11
    sub  r9, r12

    mov rax, r9
%endmacro


;f(x) = 6 - cociente x/10 + resto de x/10 * 10
%macro mRotacionIzquierda 0
    ; Entrada --> ax: numero de posicion CF
    mov r9, 6
    mov r8, 10
    idiv r8b
    ;
    movzx   r11,al
    xchg    al, ah           
    movzx   r12, al
    ; r12  = ah, r11=al
    ; ah resto, al cociente
    imul r12, 10
    sub r9, r11
    add r9, r12
    mov rax, r9
%endmacro

%macro mSwapb 2 ; (1) <--> (2) [byte]
    mov al, byte[%1]
    xchg al, byte[%2]
    mov byte[%1], al
%endmacro

%macro mMovb 2 ; (1) <-- (2) [byte]
    mov   al, byte[%2]
    mov   byte [%1],al
%endmacro

%macro mMovw 2 ; (1) <-- (2) [word]
    mov   ax, word[%2]
    mov   word[%1],ax
%endmacro

%macro mMovq 2 ; (1) <-- (2) [qword]
    mov   rax, [%2]
    mov   [%1],rax
%endmacro

%macro mMulb 3 ; (3) <-- (1) * (2) [byte]
    mov   al, byte [%1] 
    mov   ah, byte [%2]  
    mul   ah              
    mov   byte [%3], al   
%endmacro

%macro mAddb 3 ; (3) <-- (1) + (2) [byte]
    mov   al, byte[%1]
    add   al, byte[%2]
    mov   byte[%3], al
%endmacro

%macro mComparaLoop 4
    ;Itera la lista dada en rsi y cuando encuentra un elemento igual al comparado bifurca
    ; Entrada:
    ;1) rsi -> dirección del vector de posiciones
    ;2) rcx -> número de elementos
    ;3) r9  -> elemento que comparamos
    ;4) bifurcacion si encuentra un elemento igual
    mov rsi, %1
    movzx rcx, byte[%2]
    movzx r9, byte[%3]

%%saltoLoop:
    mov     bl, [rsi]     ; Cargar el elemento actual del vector en rbx
    cmp     r9b, bl       ; Comparar a la siguiente posicion con rbx (elemento del vector)
    jne      %%noIgual        ; Si NO son iguales sigue 
    mCall    %4           ; si son iguales , saltar a la etiqueta encontrado
%%noIgual:
    inc     rsi           ; Incrementar el índice rdi                    
    loop    %%saltoLoop     ; Saltar al inicio del bucle compara_loop
%endmacro

