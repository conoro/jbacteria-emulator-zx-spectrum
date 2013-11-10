        ld      (desc2+1), sp
        inc     a
        ld      b, a
        ld      sp, map-1
        ld      de, $ffff
        ld      hl, fin
desc1:  pop     af
        add     hl, de
        ld      e, a
        dec     sp
        djnz    desc1
desc2:  ld      sp, 0
        ld      de, DMAP_BUFFER+149
        rr      b
desc3:  ld      a, 256 >> DMAP_BITSYMB
desc4:  call    gbit3
        jr      nc, desc4
      IF DMAP_BITHALF=1
        rrca
        jr      nc, desc5
        add     8
        call    gbit3
      ENDIF
desc5:  ld      (de), a
        dec     de
desc6:  ld      a, e
        or      a
        ret     z
        call    gbit3
        rra
        jr      nc, desc3
        push    de
        ld      a, 1
desc7:  call    nc, gbit3
        call    gbit2
        rra
        jr      nc, desc7
        inc     a
        ld      c, a
        xor     a
        ld      de, 15
        call    gbit3
        call    gbit3
        jr      z, desca    ;00 = -1
        dec     a
        call    gbit3
        jr      z, descc    ;010 = -15
        cp      4
        jr      nc, desc8
        call    gbit2       ;[011, 100, 101] xx
        dec     a
        call    gbit3
        jr      descb
desc8:  dec     e           ;[110, 111] xxxxxx
desc9:  call    gbit3
        jr      nc, desc9
        jr      z, descc
        add     e
desca:  inc     a
descb:  ld      e, a
descc:  ld      a, b
        ld      b, d
        ex      (sp), hl
        ex      de, hl
        add     hl, de
        lddr
        pop     hl
        ld      b, a
        jr      desc6
gbit1:  ld      b, (hl)
        dec     hl
        defb    $30
gbit2:  and     a
gbit3:  rl      b
        jr      z, gbit1
        adc     a, a
        ret
