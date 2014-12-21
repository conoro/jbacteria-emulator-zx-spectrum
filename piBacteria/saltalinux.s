.text
inicio: mov     r4, #0x8100
inici1: ldr     r3, [r4], #-4
        str     r3, [r4, #4-0x100]
        cmp     r4, #0x8000
        bne     inici1
        b       start-0x100
start:  ldr     r3, [r4, #292]
        str     r3, [r4], #4
        cmp     r4, #0x330000
        bne     start
        b       inicio+0x100


        