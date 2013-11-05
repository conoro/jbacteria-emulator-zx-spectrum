
        ld      (desc1+1), sp
        inc     a
        ld      b, a
        ld      sp, map-1
        ld      de, $ffff
        ld      hl, fin
suma    add     hl, de
        pop     af
        ld      e, a
        dec     sp
        djnz    suma
desc1:  ld      sp, 0
        ld      de, buffer+150

; descompresor
        ld      b, $80
byte_loop:
        ld      a, 256 >> bitsymbol
repet:  call    gbita
        jr      nc, repet
        ld      (de), a
        dec     de
conti:  ld      a, e
        or      a
        ret     z
        call    gbita
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
        jr      nc, noca
        call    gbita
        call    gbita
        sub     3
        jr      sale
noca:   dec     e
noce:   call    gbita
        jr      nc, noce
        jr      z, sale2
        add     14
sale:   ld      e, a
sale2:  xor     a
        ld      d, a
        ld      a, b
        ld      b, d
        inc     e
; copy previous sequence
        ex      (sp), hl                ; store source, restore destination
        ex      de, hl
        add     hl, de
        lddr
        pop     hl                      ; restore source address (compressed data)
        ld      b, a
        jr      conti

naaa:   ld      b, (hl)
        dec     hl
        db      $30
gbita:  and     a
        rl      b
        jr      z, naaa
        adc     a, a
        ret
