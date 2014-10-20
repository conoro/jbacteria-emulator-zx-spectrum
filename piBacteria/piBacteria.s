        .set    MBOXBASE,   0x2000B880
        .set    MBOXREAD,   0x00
        .set    MBOXSTATUS, 0x18
        .set    MBOXWRITE,  0x20
        .set    MEMORY,     endf
        .set    LTABLE,     endf+0x10000
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

        ldr     mem, memo

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

@ Esto es para crear las tablas de pintado rápido
        ldr     r6, ltabl
        add     r6, #0x20000
        mov     r0, #127
gent1:  mov     r7, #255
gent2:  and     r3, r0, #7
        tst     r0, #0b01000000
        orrne   r3, #8
        mov     r2, r0, lsr #3
        add     r4, r7, #0x00008000
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

@ Esto renderiza la imagen

        mov     pcff, #0
        mov     stlo, #224

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

        bl      execute
        add     stlo, #224

        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
        add     r2, #1
        cmp     r2, #264
        bne     drawr

        b       render

@ piscina de constantes
ltabl:  .word   LTABLE
memo:   .word   MEMORY

in:     mov     r0, #0xff
        bx      lr

out:    bx      lr

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

pinrap: .word   0
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
        .equ    opoint,   opinrap-40
        .equ    ofbinfo,  opoint-32

endf:   .incbin "48.rom"
@        .incbin "gameover.scr"

