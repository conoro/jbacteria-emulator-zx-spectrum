#include "defs.h"
#define INIT __asm__ ("call 0xfffc")
#define FRAME __asm__ ("call 0xfff1")
#define dzx7b(src, dst) \
    __asm               \
        ld      hl, src \
        ld      de, dst \
        call    0xfe80-smooth*0x25f \
    __endasm;
unsigned char __at (0x5b01) tiles[150];
unsigned char __at (0x5b00) screen;
unsigned char __at (0x5c00) sprites[8][4];
