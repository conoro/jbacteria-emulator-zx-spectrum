        .set    STCLO,      0x20003004
        .set    AUXBASE,    0x20215000
        .set    AMENABLES,  0x04
        .set    AMIOREG,    0x40
        .set    AMLCRREG,   0x4C
        .set    AMLSRREG,   0x54
        .set    AMBAUDREG,  0x68
        .set    GPBASE,     0x20200000
        .set    GPFSEL0,    0x00
        .set    GPFSEL1,    0x04
        .set    GPSET0,     0x1c
        .set    GPCLR0,     0x28
        state   .req    r0
        recv    .req    r3
        send    .req    r3
        gpbas   .req    r4
        auxbas  .req    r4
        block   .req    r5
        addr    .req    r6
        crc     .req    r7
        cntadr  .req    r8
        cnt     .req    r9
        timeout .req    r10
.text
start:  mov     addr, #0x8200
star1:  ldr     r3, [addr], #-4
        str     r3, [addr, #4-0x200]
        cmp     addr, #0x8000
        bne     star1
        ldr     gpbas, =GPBASE
        sub     cntadr, gpbas, #GPBASE-0x20004000
        mov     r3, #0b00000000000000010010000000000000
        str     r3, [gpbas, #GPFSEL1]
        ldr     cnt, =0b10101010101010101010101010101010
        mov     timeout, #0b0000000000010000
beep:   strcc   timeout, [gpbas, #GPSET0]
        strcs   timeout, [gpbas, #GPCLR0]
        mov     crc, #0b00000000000000000001000000000000
        str     crc, [gpbas, #GPFSEL0]
beep1:  subs    crc, #1
        bne     beep1
        lsrs    cnt, #1
        bne     beep
        add     auxbas, #AUXBASE-GPBASE
        mov     block, #1
        str     block, [auxbas, #AMENABLES]
        mov     timeout, #3
        str     timeout, [auxbas, #AMLCRREG]
        mov     r3, #15 @ 2Mbps
        str     r3, [auxbas, #AMBAUDREG]
        b       star4-0x200
star2:  uadd8   crc, crc, recv
        strb    recv, [addr], #1
star3:  add     state, #1
star4:  ldr     cnt, [cntadr, #STCLO-0x20004000]
        cmp     cnt, timeout
        addcs   timeout, cnt, #0xa000
        movcs   send, #0x15
        strcs   send, [auxbas, #AMIOREG]
        ldr     r3, [auxbas, #AMLSRREG]
        tst     r3, #1
        beq     star4
        ldr     recv, [auxbas, #AMIOREG]
        add     timeout, cnt, #0xa000
        cmp     state, #1
        bcs     star6
        cmp     recv, #0x01
        moveq   crc, #0
        beq     star3
        cmp     recv, #0x04
        bne     star8
        mov     send, #0x06
        str     send, [auxbas, #AMIOREG]
star5:  subs    addr, #1
        bne     star5
        b       start+0x200
star6:  bne     stara
        mov     cnt, block
star7:  cmp     recv, cnt
        beq     star3
star8:  mov     send, #0x15
star9:  mov     state, #0
        str     send, [auxbas, #AMIOREG]
        b       star4
stara:  cmp     state, #2
        eoreq   cnt, block, #0xff
        beq     star7
        cmp     state, #131
        bne     star2
        cmp     recv, crc
        bne     star8
        mov     r3, #1
        uadd8   block, block, r3
        mov     send, #0x06
        b       star9
