        output  descompresor.bin
        org     $8000-20
ini     ld      de, $8000-20
        push    bc
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     pop     hl
        ld      bc, fin-ini
        ldir
        jp      $8000

        ld      hl, datos+24
        ld      de, $c000

dzx7_standard:
        ld      b, $80
byte_loop:
        ld      a, $10
repet:  call    gbita
        jr      nc, repet
        ld      (de), a
        inc     de
conti:  call    gbita
        rra
        jr      nc, byte_loop

patro:  push    de
        ld      a, 1

; determine length
elias_gamma:
        call    nc, gbita
        call    gbita
        rra
        jr      nc, elias_gamma
        inc     a
        ld      c, a

        xor     a
        ld      e, 14
        call    gbita
        call    gbita
        jr      z, sale
        dec     a
        call    gbita
        jr      z, sale2
        cp      4
        set     6, a
        jr      c, noca
        or      4
noca:   call    gbita
        jr      nc, noca

sale:   ld      e, a
sale2:  xor     a
        ld      d, a
        ld      a, b
        ld      b, d
        inc     e
; copy previous sequence
        ex      (sp), hl                ; store source, restore destination
        push    hl                      ; store destination
        sbc     hl, de                  ; HL = destination - offset - 1
        pop     de                      ; DE = destination
        ldir
dzx7s_exit:
        pop     hl                      ; restore source address (compressed data)
        ld      b, a
        jr      conti

naaa:   ld      b, (hl)
        inc     hl
gbita:  and     a
        rl      b
        jr      z, naaa
        adc     a, a
        ret


naaa:   ld      b, (hl)
        inc     hl
        db      $30
gbita:  and     a
        rl      b
        jr      z, naaa
        adc     a, a
        ret


; -----------------------------------------------------------------------------

datos   incbin  salida.bin
fin