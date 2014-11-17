        .set    STCLO,      0x20003004
        .set    AUXBASE,    0x20215000
        .set    AMENABLES,  0x04
        .set    AMIOREG,    0x40
        .set    AMLCRREG,   0x4C
        .set    AMLSRREG,   0x54
        .set    AMBAUDREG,  0x68
        .set    GPBASE,     0x20200000
        .set    GPFSEL1,    0x04
        state   .req    r0
        recv    .req    r1
        send    .req    r1
        gpbas   .req    r2
        auxbas  .req    r2
        block   .req    r3
        addr    .req    r4
        crc     .req    r5
        counter .req    r6
        cnt     .req    r7
        timeout .req    r8
.text
start:  mov     addr, #0x8200
star1:  ldr     r1, [addr], #-4
        str     r1, [addr, #-4092]
        cmp     addr, #0x8000
        bne     star1
        b       star2-0x1000
star2:  ldr     gpbas, =GPBASE
        mov     r1, #0b00000000000000010010000000000000
        str     r1, [gpbas, #GPFSEL1]
        add     auxbas, #AUXBASE-GPBASE
        mov     block, #1
        str     block, [auxbas, #AMENABLES]
        mov     r1, #0x23
        str     r1, [auxbas, #AMLCRREG]
        add     r1, #270-0x23
        str     r1, [auxbas, #AMBAUDREG]
        ldr     counter, =STCLO
        ldr     cnt, [counter]
star3:  add     timeout, cnt, #0xa000
        mov     send, #0x15
        str     send, [auxbas, #AMIOREG]
star4:  ldr     cnt, [counter]
        cmp     cnt, timeout
        bcs     star3
        ldr     r1, [auxbas, #AMLSRREG]
        tst     r1, #1
        beq     star4
        ldr     recv, [auxbas, #AMIOREG]
        add     timeout, cnt, #0xa000
        cmp     state, #1
        bcs     star6
        cmp     recv, #0x01
        moveq   crc, #0
        beq     starc
        cmp     recv, #0x04
        bne     star8
        mov     send, #0x06
        str     send, [auxbas, #AMIOREG]
star5:  subs    addr, #1
        bne     star5
        b       start+0x1000
star6:  bne     stara
        mov     cnt, block
star7:  cmp     recv, cnt
        beq     starc
star8:  mov     send, #0x15
star9:  mov     state, #0
        str     send, [auxbas, #AMIOREG]
        b       star4
stara:  cmp     state, #2
        eoreq   cnt, block, #0xff
        beq     star7
        cmp     state, #131
        bne     starb
        cmp     recv, crc
        bne     star8
        mov     r1, #1
        uadd8   block, block, r1
        mov     send, #0x06
        b       star9
starb:  uadd8   crc, crc, recv
        strb    recv, [addr], #1
starc:  add     state, #1
        b       star4
