        .set    debug,      0

        .set    GPBASE,     0x20200000
        .set    GPFSEL0,    0x00
        .set    GPFSEL1,    0x04
        .set    GPFSEL2,    0x08
        .set    GPCLR0,     0x28
        .set    GPLEV0,     0x34
        .set    GPPUD,      0x94
        .set    GPPUDCLK0,  0x98

        .set    MBOXBASE,   0x2000B880
        .set    MBOXREAD,   0x00
        .set    MBOXSTATUS, 0x18
        .set    MBOXWRITE,  0x20
        .set    MEMORY,     endf
        .set    LTABLE,     endf+0x10000

        .set    AUXBASE,    0x20215000
        .set    AMENABLES,  0x04
        .set    AMIOREG,    0x40
        .set    AMIERREG,   0x44
        .set    AMIIRREG,   0x48
        .set    AMLCRREG,   0x4C
        .set    AMMCRREG,   0x50
        .set    AMLSRREG,   0x54
        .set    AMCNTLREG,  0x60
        .set    AMBAUDREG,  0x68

        .set    STCLO,      0x20003004

.text
        iyi     .req      r0
        mem     .req      r1
        stlo    .req      r2
        pcff    .req      r3
        spfa    .req      r4
        bcfb    .req      r5
        defr    .req      r6
        hlmp    .req      r7
        arvpref .req      r8
        ix      .req      r9

        mov     sp, #0x8000
        ldr     mem, memo


        mrc     p15, 0, r0, c1, c0, 0 @ read control register
        orr     r0, r0, #(1 << 22)    @ set the U bit (bit 22)
        mcr     p15, 0, r0, c1, c0, 0 @ write control register

@ Esto es para configurar el buffer de video a 352x264x4
        add     r0, mem, #ofbinfo+1
        orr     r0, #0x40000000
        ldr     r2, mboxb
wait1:  ldr     r3, [r2, #MBOXSTATUS]
        tst     r3, #0x80000000
        bne     wait1
        str     r0, [r2, #MBOXWRITE]
wait2:  ldr     r3, [r2, #MBOXSTATUS]
        tst     r3, #0x40000000
        bne     wait2
        ldr     r3, [r2, #MBOXREAD]
        and     r3, #0x0000000f
        cmp     r3, #1
        bne     wait2

@ Pongo a cero las filas y a pull up las columnas (y el puerto EAR)
        ldr     r0, gpbas
        mov     r2, #2
        str     r2, [r0, #GPPUD]
        bl      wait
        ldr     r2, filt
        str     r2, [r0, #GPPUDCLK0]
        bl      wait
        str     r2, [r0, #GPPUD]
        ldr     r2, rows
        str     r2, [r0, #GPCLR0]

@ Esto es para crear las tablas de pintado rápido
        ldr     r6, [mem, #opinrap]
        add     r6, #0x40000
        mov     r0, #255
gent1:  mov     r7, #255
gent2:  and     r3, r0, #7
        tst     r0, #0b01000000
        orrne   r3, #8
        movs    r2, r0, lsl #25
        mov     r2, r2, lsr #28
        add     r4, r7, #0x00008000
        eorcs   r4, #0xff     
gent3:  tst     r4, #0x02
        mov     r5, r5, lsl #4
        addeq   r5, r2
        addne   r5, r3
        tst     r4, #0x01
        mov     r5, r5, lsl #4
        addeq   r5, r2
        addne   r5, r3
        mov     r4, r4, lsr #2
        tst     r4, #0x0000ff00
        bne     gent3
        str     r5, [r6, #-4]!
        subs    r7, #1
        bpl     gent2
        subs    r0, #1
        bpl     gent1
        str     r6, [mem, #opinrap]

  .if debug==1
    ldr     r0, const
    bl      hexs
  .endif

@ Esto renderiza la imagen

        mov     pcff, #0
        mov     stlo, #224

        ldr     lr, stclo
        ldr     lr, [lr]
        add     lr, #64
        str     lr, [mem, #ocontad]

render: mov     r2, #0
drawr:  mov     r3, #0
        ldr     r10, [mem, #opoint]
        mov     r11, #176
        smlabb  r10, r11, r2, r10
drawp:  sub     r11, r3, #6
        cmp     r11, #32
        bcs     aqui
        sub     r12, r2, #36
        cmp     r12, #192
        bcs     aqui
        and     lr, r12, #0b11111000
        orr     lr, r11, lr, lsl #2
        add     lr, #0x5800
        ldrb    lr, [mem, lr]
        add     r11, r12, lsl #5
        eor     r11, r12, lsl #2
        bic     r11, #0b0000011100000
        eor     r11, r12, lsl #2
        eor     r11, r12, lsl #8
        bic     r11, #0b0011100000000
        eor     r11, r12, lsl #8
        add     r11, #0x4000
        ldrb    r11, [mem, r11]
        tst     lr, #0x80
        tstne   iyi, #0x80
        eorne   lr, #0x80
        add     r11, r11, lr, lsl #8
 
        ldr     r12, [mem, #opinrap]
        ldr     r11, [r12, r11, lsl #2]
aqui:   ldrcs   r11, [mem, #oborder]
        str     r11, [r10], #4
        add     r3, #1
        cmp     r3, #44
        bne     drawp
        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]

@        bl      regs

        bl      execute
        add     stlo, #224

        ldr     r11, [mem, #ocontad]
        ldr     r10, stclo
again:  ldr     lr, [r10]
        cmp     lr, r11
        bne     again
        add     r11, #64
        str     r11, [mem, #ocontad]

        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
        add     r2, #1
        cmp     r2, #264
        bne     drawr
        mov     r11, #4
        uadd8   iyi, iyi, r11


        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
        tst     arvpref, #0x00000400
        beq     exec5
        bic     arvpref, #0x00000400
        tst     arvpref, #0x00000800
        bicne   arvpref, #0x00000800
        addne   pcff, #0x00010000
        mov     r11, pcff, lsr #16
        sub     spfa, #0x00020000
        mov     r10, spfa, lsr #16
        strh    r11, [mem, r10]
        mov     r11, #0x00010000
        uadd8   arvpref, arvpref, r11
        movs    r11, arvpref, lsl #22
        beq     exec3
        bmi     exec4
        sub     stlo, #1
exec3:  mov     r11, #0x00380000
        pkhbt   pcff, pcff, r11
        sub     stlo, #12
        b       exec5
exec4:  and     r11, iyi, #0x0000ff00
        orr     r11, #0x000000ff
        ldrh    r10, [mem, r11]
        pkhbt   pcff, pcff, r10, lsl #16
        sub     stlo, #19
exec5:  
        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]


        b       render

  .if debug==1
regs:   push    {r0, r12, lr}
        mov     r0, #'P'
        bl      send
        mov     r0, #'C'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, pcff, lsr #16
        bl      hexh
        mov     r0, #'B'
        bl      send
        mov     r0, #'C'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, bcfb, lsr #16
        bl      hexh
        mov     r0, #'D'
        bl      send
        mov     r0, #'E'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, defr
        bl      hexs
        mov     r0, #'H'
        bl      send
        mov     r0, #'L'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, hlmp, lsr #16
        bl      hexh
        mov     r0, #'A'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, arvpref, lsr #16
        bl      hexh
        mov     r0, #13
        bl      send
        pop     {r0, r12, pc}

hexs:   push    {r11, r12, lr}
        mov     r11, r0
        mov     r12, #8
hexs1:  mov     r11, r11, ror #28
        and     r0, r11, #0x0f
        cmp     r0, #10
        addcs   r0, #7
        add     r0, #0x30
        bl      send
        subs    r12, #1
        bne     hexs1
        mov     r0, #0x20
        bl      send
        pop     {r11, r12, pc}

hexh:   push    {r11, r12, lr}
        mov     r11, r0, ror #16
        mov     r12, #4
hexh1:  mov     r11, r11, ror #28
        and     r0, r11, #0x0f
        cmp     r0, #10
        addcs   r0, #7
        add     r0, #0x30
        bl      send
        subs    r12, #1
        bne     hexh1
        mov     r0, #0x20
        bl      send
        pop     {r11, r12, pc}

send:   push    {r12, lr}
        ldr     lr, auxb
send1:  ldr     r12, [lr, #AMLSRREG]
        tst     r12, #0x20
        beq     send1
        str     r0, [lr, #AMIOREG]
        pop     {r12, pc}
  .endif

@ piscina de constantes

  .if debug==1
const:  .word   0x1234a6d8
  .endif

auxb:   .word   AUXBASE
gpbas:  .word   GPBASE
stclo:  .word   STCLO
memo:   .word   MEMORY
rows:   .word   0b00001000010000100000111000011000
filt:   .word   0b00000011100000000000000110000100
_table: .word   table
table:  .word   0b001000000000000001001000000000
        .word   0b001000000000000000001000000000
        .word   0b001000000000000001000000000000
        .word   0b001000000000000000000000000000
        .word   0b000000000000000001001000000000
        .word   0b000000000000000000001000000000
        .word   0b000000000000000001000000000000
        .word   0b000000000000000000000000000000
        .word   0b000000001000010010000000001001
        .word   0b000000001000010010000000000001
        .word   0b000000000000010010000000001001
        .word   0b000000000000010010000000000001
        .word   0b000000001000010010000000001000
        .word   0b000000001000010010000000000000
        .word   0b000000000000010010000000001000
        .word   0b000000000000010010000000000000
        .word   0b000000001000000000000001000000
        .word   0b000000001000000000000000000000
        .word   0b000000000000000000000001000000
        .word   0b000000000000000000000000000000
        .byte   0b10100000
        .byte   0b10110000
        .byte   0b10101000
        .byte   0b10111000
        .byte   0b11100000
        .byte   0b11110000
        .byte   0b11101000
        .byte   0b11111000
        .byte   0b10100001
        .byte   0b10110001
        .byte   0b10101001
        .byte   0b10111001
        .byte   0b11100001
        .byte   0b11110001
        .byte   0b11101001
        .byte   0b11111001
        .byte   0b10100010
        .byte   0b10110010
        .byte   0b10101010
        .byte   0b10111010
        .byte   0b11100010
        .byte   0b11110010
        .byte   0b11101010
        .byte   0b11111010
        .byte   0b10100011
        .byte   0b10110011
        .byte   0b10101011
        .byte   0b10111011
        .byte   0b11100011
        .byte   0b11110011
        .byte   0b11101011
        .byte   0b11111011
        .byte   0b10100100
        .byte   0b10110100
        .byte   0b10101100
        .byte   0b10111100
        .byte   0b11100100
        .byte   0b11110100
        .byte   0b11101100
        .byte   0b11111100
        .byte   0b10100101
        .byte   0b10110101
        .byte   0b10101101
        .byte   0b10111101
        .byte   0b11100101
        .byte   0b11110101
        .byte   0b11101101
        .byte   0b11111101
        .byte   0b10100110
        .byte   0b10110110
        .byte   0b10101110
        .byte   0b10111110
        .byte   0b11100110
        .byte   0b11110110
        .byte   0b11101110
        .byte   0b11111110
        .byte   0b10100111
        .byte   0b10110111
        .byte   0b10101111
        .byte   0b10111111
        .byte   0b11100111
        .byte   0b11110111
        .byte   0b11101111
        .byte   0b11111111
in:     tst     r0, #1
        movne   r0, #0xff
        bxne    lr
        ldr     r2, gpbas
        ldr     r11, _table
        and     r3, r0, #0b1100010000000000
        orr     r3, r3, lsr #6
        and     r3, #0b11100000000
        ldr     r3, [r11, r3, lsr #6]
        str     r3, [r2, #GPFSEL0]
        add     r11, #32
        and     r3, r0, #0b101100000000
        orr     r3, r3, lsr #4
        and     r3, #0b1110000000
        ldr     r3, [r11, r3, lsr #5]
        str     r3, [r2, #GPFSEL1]
        and     r3, r0, #0b11000000000000
        add     r11, #32
        ldr     r3, [r11, r3, lsr #10]
        str     r3, [r2, #GPFSEL2]
        add     r11, #16
        push    {r2, lr}
        bl      wait
        pop     {r2, lr}
        ldr     r3, [r2, #GPLEV0]
        ldr     r0, filt
        and     r3, r0
        orr     r3, r3, lsr #7
        orr     r3, r3, lsr #13
        and     r3, #0b111111
        ldrb    r0, [r11, r3]
        bx      lr

out:    tst     r0, #1
        bxne    lr
        and     r1, #0x7
        ldr     r0, c1111
        mul     r1, r0, r1
        ldr     r0, memo
        str     r1, [r0, #oborder]
        bx      lr
c1111:  .word   0x11111111

wait:   mov     r2, #50
waita:  subs    r2, #1
        bne     waita
        bx      lr

        .include  "z80.s"

        .balign 16
fbinfo: .word   1024    @0 Width
        .word   768     @4 Height
        .word   352     @8 vWidth
        .word   264     @12 vHeight
        .word   0       @16 GPU - Pitch
        .word   4       @20 Bit Dpeth
        .word   0       @24 X
        .word   0       @28 Y
point:  .word   0       @32 GPU - Pointer
        .word   0       @36 GPU - Size
                 @rrrrrggggggbbbbb
        .hword  0b0000000000000000
        .hword  0b0000000000010111
        .hword  0b1011100000000000
        .hword  0b1011100000010111
        .hword  0b0000010111100000
        .hword  0b0000010111110111
        .hword  0b1011110111100000
        .hword  0b1011110111110111
        .hword  0b0000000000000000
        .hword  0b0000000000011111
        .hword  0b1111100000000000
        .hword  0b1111100000011111
        .hword  0b0000011111100000
        .hword  0b0000011111111111
        .hword  0b1111111111100000
        .hword  0b1111111111111111

contad: .word   0
pinrap: .word   LTABLE
tmpr2:  .word   0
tmpr3:  .word   0
border: .word   0x77777777
        .byte   0, 0, 0
a_:     .byte   0
fa_:    .short  0
fb_:    .short  0
ff_:    .short  0
fr_:    .short  0
c_:     .byte   0
b_:     .byte   0
e_:     .byte   0
d_:     .byte   0
dummy1: .short  0
l_:     .byte   0
h_:     .byte   0

        .equ    oc_,      -8
        .equ    off_,     oc_-4
        .equ    ofa_,     off_-4
        .equ    oa_,      ofa_-1
        .equ    oborder,  oa_-7
        .equ    otmpr3,   oborder-4
        .equ    otmpr2,   otmpr3-4
        .equ    opinrap,  otmpr2-4
        .equ    ocontad,  opinrap-4
        .equ    opoint,   ocontad-40
        .equ    ofbinfo,  opoint-32

endf:
@        .incbin "ManicMiner.rom"
        .incbin "48.rom"

/*  GPIO23  D0
    GPIO24  D1
    GPIO25  D2
    GPIO8   D3
    GPIO7   D4

    GPIO3   A15
    GPIO4   A14
    GPIO17  A8
    GPIO27  A13
    GPIO22  A12
    GPIO10  A9
    GPIO9   A10
    GPIO11  A11

    GPIO2   EAR */
