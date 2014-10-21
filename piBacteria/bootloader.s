        .set    STCLO,      0x20003004
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
        .set    GPBASE,     0x20200000
        .set    GPFSEL1,    0x04
.text
start:  mov     r7, #0x9000
star1:  ldr     r3, [r7], #-4
        str     r3, [r7, #-4092]
        cmp     r7, #0x8000
        bne     star1
        b       init-0x1000
init:   ldr     r0, =AUXBASE
        ldr     r1, =GPBASE
        mov     r8, #1
        str     r8, [r0, #AMENABLES]
        mov     r2, #0
        str     r2, [r0, #AMIERREG]
        str     r2, [r0, #AMCNTLREG]
        mov     r3, #3
        str     r3, [r0, #AMLCRREG]
        str     r2, [r0, #AMMCRREG]
        str     r2, [r0, #AMIERREG]
        mov     r4, #0xc6
        str     r4, [r0, #AMIIRREG]
        add     r4, #0x48
        str     r4, [r0, #AMBAUDREG]
        mov     r4, #0b00000000000000010010000000000000
        str     r4, [r1, #GPFSEL1]
        str     r3, [r0, #AMCNTLREG]
main:   add     r2, #1
main1:  ldr     lr, =STCLO
        ldr     lr, [lr]
        cmp     lr, r11
        addeq   r11, #0xa000
        moveq   r1, #0x15
        bleq    send
        ldr     r3, [r0, #AMLSRREG]
        tst     r3, #1
        beq     main1
        ldr     r1, [r0, #AMIOREG]
        ldr     r11, =STCLO
        ldr     r11, [r11]
        add     r11, #0xa000
        cmp     r2, #1
        bcs     main3
        cmp     r1, #0x01
        moveq   r9, #0
        beq     main
        cmp     r1, #0x04
        bne     main5
        mov     r1, #0x06
        bl      send
main2:  subs    r7, #1
        bne     main2
        b       start+0x1000
main3:  bne     main7
        cmp     r1, r8
main4:  beq     main
main5:  mov     r1, #0x15
main6:  mov     r2, #0
        bl      send
        b       main1
main7:  cmp     r2, #2
        bne     main8
        eor     lr, r8, #0xff
        cmp     r1, lr
        b       main4
main8:  cmp     r2, #131
        bne     main9
        cmp     r1, r9
        bne     main5
        mov     r1, #1
        uadd8   r8, r8, r1
        mov     r1, #6
        b       main6
main9:  uadd8   r9, r9, r1
        strb    r1, [r7], #1
        b       main

send:   ldr     r12, [r0, #AMLSRREG]
        tst     r12, #0x20
        beq     send
        str     r1, [r0, #AMIOREG]
        bx      lr
