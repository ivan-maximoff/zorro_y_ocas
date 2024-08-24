# zorro_y_ocas
Programa en assembler Intel 80x86 que implementa el juego de “El zorro y las ocas”.

## Requisitos del Sistema
- **Sistema Operativo**: Linux
- **Arquitectura**: x86_64
- **Herramientas Necesarias**:
  - `nasm` (Netwide Assembler) para ensamblar el código fuente.
  - `gcc` (GNU Compiler Collection) para enlazar los archivos objeto.
  - `build-essential` (opcional, pero útil para herramientas de construcción adicionales).

 
## Compilación
Para compilar el programa, usa los siguientes comandos:
```bash
nasm main.asm -f elf64
nasm validaciones.asm -f elf64
nasm prints.asm -f elf64
nasm tablero.asm -f elf64
nasm auxiliar.asm -f elf64
nasm data.asm -f elf64
nasm movimientos.asm -f elf64
nasm archivo.asm -f elf64
nasm jugadas.asm -f elf64
nasm juego.asm -f elf64
gcc -g main.o archivo.o validaciones.o prints.o tablero.o auxiliar.o data.o movimientos.o jugadas.o juego.o -o main.out -no-pie
./main.out
