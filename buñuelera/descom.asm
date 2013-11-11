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
        call    c, gbit1
      ENDIF
        ld      (de), a
desc5:  dec     e
        ret     z
        call    gbit3
        rra
        jr      nc, desc3
        push    de
        ld      a, 1
desc6:  call    nc, gbit3
        and     a
        call    gbit3
        rra
        jr      nc, desc6
        inc     a
        ld      c, a
        xor     a
        ld      de, 15
        call    gbit3
        call    gbit3
        jr      z, desc9    ;00 = -1
        dec     a
        call    gbit3
        jr      z, descb    ;010 = -15
        bit     2, a
        jr      nz, desc7
        call    gbit3       ;[011, 100, 101] xx
        dec     a
        call    gbit3
        jr      desca
desc7:  dec     e           ;[110, 111] xxxxxx
desc8:  call    gbit3
        jr      nc, desc8
        jr      z, descb
        add     e
desc9:  inc     a
desca:  ld      e, a
descb:  ld      a, b
        ld      b, d
        ex      (sp), hl
        ex      de, hl
        add     hl, de
        lddr
        pop     hl
        ld      b, a
        inc     e
        jr      desc5
      IF DMAP_BITHALF=1
gbit1:  sub     $80 - (1 << DMAP_BITSYMB - 2)
        defb    $da
      ENDIF
gbit2:  ld      b, (hl)
        dec     hl
gbit3:  rl      b
        jr      z, gbit2
        adc     a, a
        ret
