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

        ldr     r0, const
        bl      hexs

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

@  bl regs
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
        mov     r0, defr, lsr #16
        bl      hexh
        mov     r0, #'H'
        bl      send
        mov     r0, #'L'
        bl      send
        mov     r0, #'='
        bl      send
        mov     r0, hlmp, lsr #16
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

@ piscina de constantes
const:  .word   0x1234a6d8

auxb:   .word   AUXBASE
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

