        .set    qemu,       1
        .set    debug,      1

        .set    GPBASE,     0x20200000
        .set    GPFSEL0,    0x00
        .set    GPFSEL1,    0x04
        .set    GPFSEL2,    0x08
        .set    GPSET0,     0x1c
        .set    GPCLR0,     0x28
        .set    GPLEV0,     0x34
        .set    GPPUD,      0x94
        .set    GPPUDCLK0,  0x98

        .set    MBOXBASE,   0x2000B880
        .set    MBOXREAD,   0x00
        .set    MBOXSTATUS, 0x18
        .set    MBOXWRITE,  0x20

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

        .set    STBASE,   0x20003000
        .set    STCS,           0x00
        .set    STCLO,          0x04
        .set    STC1,           0x10
        .set    INTBASE,  0x2000b000
        .set    INTENIRQ1,     0x210

        .set    UART0_DR, 0x20201000

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

@ Permito lecturas/escrituras desalineadas y cargo puntero a memoria
        mrc     p15, 0, r0, c1, c0, 0 @ read control register
        orr     r0, r0, #(1 << 22)    @ set the U bit (bit 22)
        mcr     p15, 0, r0, c1, c0, 0 @ write control register
        ldr     mem, memo

@ Esto es para configurar el buffer de video a 352x264x4
        ldr     r2, mboxb
        add     r0, mem, #ogetrev+8
        mov     r4, #8
        bl      mbox
        ldr     r3, [mem, #ogetrev+20]
        cmp     r3, #4
        bcs     nrev1
nrev1:  mov     r4, #1
        add     r0, mem, #ofbinfo+1
        orr     r0, #0x40000000
        bl      mbox

@ Pongo a cero las filas y a pull up las columnas (y el puerto EAR)
        ldr     r0, gpbas
        mov     r2, #0b001000001        @ configuro altavoz salida
        str     r2, [r0, #GPFSEL0]
        mov     r2, #2
        str     r2, [r0, #GPPUD]
        bl      wait
        ldr     r2, filt
        str     r2, [r0, #GPPUDCLK0]
        bl      wait
        str     r2, [r0, #GPPUD]
        ldr     r3, rows
        str     r3, [r0, #GPCLR0]

@ Configuro interrupciones y temporizador
        ldr     r0, irqh        @IRQ vector
        lsr     r0, #2
        orr     r0, #0xea000000
        str     r0, [r2, #0x18]
        ldr     r0, stbas
        ldr     r2, [r0, #STCLO]
        add     r2, #0x100
        str     r2, [r0, #STC1]
        ldr     r0, intbas
        mov     r2, #0b0010
        str     r2, [r0, #INTENIRQ1]
        mov     r0, #0xd2       @IRQ mode, FIQ&IRQ disable
        msr     cpsr_c, r0
        mov     sp, #0x4000
        mov     r0, #0x53       @SVC mode, IRQ enable
    .if qemu==0
        msr     cpsr_c, r0
    .endif
        mov     sp, #0x8000

@ Esto es para crear las tablas de pintado rápido
        ldr     r6, [mem, #opinrap]
        add     r6, #0x40000+qemu*0xc0000
        mov     r0, #255
gent1:  mov     r7, #255              @ 256x256 tabla look up byte atributo + byte bitmap
gent2:  and     r3, r0, #7            @ r3= color tinta
        tst     r0, #0b01000000       @ brillo activado?
        orrne   r3, #8                @ traspaso brillo a r3
        movs    r2, r0, lsl #25       @ carry=flash
        mov     r2, r2, lsr #28       @ r2= color de fondo
        add     r4, r7, #0x00008000   @ r4= byte bitmap con marker bit en bit15
        eorcs   r4, #0xff             @ si hay flash invierto byte bitmap
    .if qemu==0
gent3:  tst     r4, #0x02             @ leo bit 1 del bitmap y lo pongo e flag zero
        mov     r5, r5, lsl #4        @ desplazo nible
        addeq   r5, r2                @ escribo color de fondo en nibble
        addne   r5, r3                @ escribo color de tinta en nibble
        tst     r4, #0x01             @ leo bit 0 del bitmap y lo pongo e flag zero
        mov     r5, r5, lsl #4        @ desplazo nible
        addeq   r5, r2                @ escribo color de fondo en nibble
        addne   r5, r3                @ escribo color de tinta en nibble
        mov     r4, r4, lsr #2        @ desplazo 2 bits a la derecha el byte de bitmap
        tst     r4, #0x0000ff00       @ repito 4 veces comprobando el marker bit
        bne     gent3
        str     r5, [r6, #-4]!        @ escribo los 32 bits (8 píxeles) calculados en tabla
    .else
        add     r5, mem, #opaleta
        lsl     r2, #1
        ldrh    r2, [r5, r2]
        ldr     r3, [r5, r3, lsl #1]
        orr     r2, r3, lsl #16
gent3:  tst     r4, #0x01             @ leo bit 0 del bitmap y lo pongo e flag zero
        moveq   r5, r2
        movne   r5, r2, lsr #16
        strh    r5, [r6, #-2]!        @ escribo pixel calculado en tabla
        lsr     r4, #1                @ desplazo 1 bit a la derecha el byte de bitmap
        tst     r4, #0x0000ff00       @ repito 8 veces comprobando el marker bit
        bne     gent3
    .endif
        subs    r7, #1                @ cierro bucle 256x256 veces
        bpl     gent2
        subs    r0, #1
        bpl     gent1
        str     r6, [mem, #opinrap]   @ guardo el puntero tabla (he ido hacia atrás) en opinrap

  .if debug==1
@    ldr     r0, const
@    bl      hexs
  .endif

@ Esto renderiza la imagen

        mov     pcff, #0
        mov     stlo, #224

render: mov     r2, #0
drawr:  cmp     r2, #264
        bcs     alli
        tst     r2, #0x1f
        tsteq   r2, #0x100
        bne     noscan
        ldr     r11, _table
        ldr     r12, gpbas
        add     r10, r11, r2, lsr #5
        ldr     r3, [r12, #GPLEV0]
        and     lr, r3, #0b0011100000000000000000000000
        tst     r3, #0b100000000
        orrne   lr,     #0b0100000000000000000000000000
        tst     r3, #0b010000000
        orrne   lr,     #0b1000000000000000000000000000
        lsr     lr, #23
        strb    lr, [r10, #8]
        ldrb    r10, [r11, #-1]     @ last row
gf1:    add     r12, #4
        subs    r10, #10
        bcs     gf1
        sub     r10, r10, lsl #2
        add     r10, #2
        mov     r3, #0b111
        ldr     lr, [r12, #-4]
        bic     lr, r3, ror r10
        str     lr, [r12, #-4]
        ldrb    r10, [r11, r2, lsr #5]
        strb    r10, [r11, #-1]     @ last row
        ldr     r12, gpbas
gf2:    add     r12, #4
        subs    r10, #10
        bcs     gf2
        sub     r10, r10, lsl #2
        add     r10, #2
        ldr     lr, [r12, #-4]
        bic     lr, r3, ror r10
        mov     r3, #0x001
        orr     lr, r3, ror r10
        str     lr, [r12, #-4]
noscan: mov     r3, #0
        ldr     r10, [mem, #opoint]
        mov     r11, #176+528*qemu
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
    .if qemu==0
        ldr     r11, [r12, r11, lsl #2]
aqui:   ldrcs   r11, border
    .else
        add     r12, r11, lsl #4
        ldr     r11, [r12], #4
        str     r11, [r10], #4
        ldr     r11, [r12], #4
        str     r11, [r10], #4
        ldr     r11, [r12], #4
        str     r11, [r10], #4
        ldr     r11, [r12], #4
        b       faqui
aqui:   ldr     r11, border
        str     r11, [r10], #4
        str     r11, [r10], #4
        str     r11, [r10], #4
    .endif
faqui:  str     r11, [r10], #4
        add     r3, #1
        cmp     r3, #44
        bne     drawp
alli:   add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
@        bl      regs
        bl      execute
        add     stlo, #224
again:  ldr     lr, flag
        subs    lr, #2
    .if qemu==0
        bne     again
    .endif
        str     lr, flag
        add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
        add     r2, #1

        cmp     r2, #312
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
exec5:  add     lr, mem, #otmpr2
        swp     r2, r2, [lr]
        add     lr, #4
        swp     r3, r3, [lr]
        b       render

irqhnd: push    {r0, r1}
        ldr     r0, stbas
        mov     r1, #0b0010
        str     r1, flag
        str     r1, [r0, #STCS]
        ldr     r1, [r0, #STCLO]
        add     r1, #64
        str     r1, [r0, #STC1]
        pop     {r0, r1}
        subs    pc, lr, #4

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
    .if qemu==0
send:   push    {r12, lr}
        ldr     lr, auxb
send1:  ldr     r12, [lr, #AMLSRREG]
        tst     r12, #0x20
        beq     send1
        str     r0, [lr, #AMIOREG]
        pop     {r12, pc}
    .else
send:   push    {lr}
        ldr     lr, uart
        str     r0, [lr]
        pop     {pc}
    .endif
  .endif

@ piscina de constantes

  .if debug==1
const:  .word   0x1234a6d8
  .endif

flag:   .word   0
auxb:   .word   AUXBASE
gpbas:  .word   GPBASE
stbas:  .word   STBASE
intbas: .word   INTBASE
uart:   .word   UART0_DR
irqh:   .word   irqhnd-0x20
memo:   .word   MEMORY
_table: .word   table
_keys:  .word   keys
@                   7654321098765432109876543210
rows:   .word   0b001000011001100000111000010101
lastrw: .byte   17
table:  .byte   10, 9, 11, 22, 27, 4, 15, 17     @15->18
keys:   .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
filt:   .word   0b001011111001100000111110011101

in:     tst     r0, #1
        movne   r0, #0xff
        bxne    lr
        lsr     r3, r0, #8
        mov     r0, #0x1f
    .if qemu==0
        ldr     r11, _keys
        orr     r3, #0x100
in1:    ldrb    r2, [r11], #1
        lsrs    r3, #1
        andcc   r0, r2
        bne     in1
        ldr     r2, gpbas
        ldr     r3, [r2, #GPLEV0]
        orr     r3, #0b10100
    .endif
        and     r3, #0b11100
        orr     r0, r3, lsl #3        
        bx      lr

out:    tst     r0, #1
        bxne    lr
        and     r3, r1, #0x7
    .if qemu==0
        ldr     r2, c1111
        mul     r3, r2, r3
    .else
        ldr     r2, memo
        add     r2, r3, lsl #1
        ldrh    r3, [r2, #opaleta]
        orr     r3, r3, lsl #16
    .endif
        str     r3, border
        ldr     r2, gpbas
        mov     r3, #0b0101
        tst     r1, #0x10
        strne   r3, [r2, #GPSET0]
        streq   r3, [r2, #GPCLR0]
        bx      lr
    .if qemu==0
c1111:  .word   0x11111111
border: .word   0x77777777
    .else
border: .word   0b10111101111101111011110111110111
    .endif

wait:   mov     r2, #100
waita:  subs    r2, #1
        bne     waita
        bx      lr

mbox:   ldr     r3, [r2, #MBOXSTATUS]
        tst     r3, #0x80000000
        bne     mbox
        str     r0, [r2, #MBOXWRITE]
mbox1:  ldr     r3, [r2, #MBOXSTATUS]
        tst     r3, #0x40000000
        bne     mbox1
        ldr     r3, [r2, #MBOXREAD]
        and     r3, #0x0000000f
        cmp     r3, r4
        bne     mbox1
        bx      lr

        .include  "z80.s"

        .balign 16

getrev: .word   7*4
        .word   0
        .word   0x00010002
        .word   4
        .word   0
        .word   0
        .word   0
        .word   0

fbinfo: .word   1024-672*qemu @0 Width
        .word   768-504*qemu  @4 Height
        .word   352           @8 vWidth
        .word   264           @12 vHeight
        .word   0             @16 GPU - Pitch
        .word   4+12*qemu     @20 Bit Dpeth
        .word   0             @24 X
        .word   0             @28 Y
point:  .word   0             @32 GPU - Pointer
        .word   0             @36 GPU - Size

                 @rrrrrggggggbbbbb
paleta: .hword  0b0000000000000000
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

pinrap: .word   LTABLE
tmpr2:  .word   0
tmpr3:  .word   0
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
        .equ    otmpr3,   oa_-7
        .equ    otmpr2,   otmpr3-4
        .equ    opinrap,  otmpr2-4
        .equ    opaleta,  opinrap-32
        .equ    opoint,   opaleta-8
        .equ    ofbinfo,  opoint-32
        .equ    ogetrev,  ofbinfo-32

endf:
        .incbin "ManicMiner.rom"
@        .incbin "ktest.rom"

/*  GPIO23  D0
    GPIO24  D1
    GPIO25  D2
    GPIO8   D3
    GPIO7   D4

    GPIO18  A15
    GPIO4   A14
    GPIO17  A8
    GPIO27  A13
    GPIO22  A12
    GPIO10  A9
    GPIO9   A10
    GPIO11  A11

    GPIO3   EAR
    GPIO2   SPEAKER */
