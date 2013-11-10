
        ld      (desc1+1), sp
        inc     a
        ld      b, a
        ld      sp, map-1
        ld      de, $ffff
        ld      hl, fin
suma    pop     af
        add     hl, de
        ld      e, a
        dec     sp
        djnz    suma
desc1:  ld      sp, 0
        ld      de, buffer+149

; descompresor
        rr      b
byte_loop:
        ld      a, 256 >> bitsymbol
repet:  call    gbitb
        jr      nc, repet
        ld      (de), a
        dec     de
conti:  ld      a, e
        cp      buffer-1 & 255
        ret     z
        call    gbita
        rra
        jr      nc, byte_loop

patro:  push    de
        ld      a, 1

; determine length
elias_gamma:
        call    nc, gbitb
        call    gbita
        rra
        jr      nc, elias_gamma
        inc     a
        ld      c, a

        xor     a
        ld      de, 15
        call    gbitb
        call    gbitb
        jr      z, sale     ;00 = -1
        dec     a
        call    gbitb
        jr      z, sale3    ;010 = -15
        cp      4
        jr      nc, noca
        call    gbita       ;[011, 100, 101] xx
        dec     a
        call    gbitb
        jr      sale2
noca:   dec     e           ;[110, 111] xxxxxx
noce:   call    gbitb
        jr      nc, noce
        jr      z, sale3
        add     e
sale:   inc     a
sale2:  ld      e, a
sale3:  ld      a, b
        ld      b, d
        ex      (sp), hl
        ex      de, hl
        add     hl, de
        lddr
        pop     hl
        ld      b, a
        jr      conti

naaa:   ld      b, (hl)
        dec     hl
        db      $30
gbita:  and     a
gbitb:  rl      b
        jr      z, naaa
        adc     a, a
        ret
