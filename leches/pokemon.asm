        define  CADEN   $5800-6
        output  pokemon.bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $0066, 10
L0066   ld      (CADEN-2), sp
        ld      sp, CADEN-13-1 ;sobra 1 byte
        jp      poke
L0066f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    poke, pokef-poke
        org     $38b5
poke    push    af
        push    de
        push    bc
        ld      bc, 11
        push    hl
        push    iy
        ld      iy, $5c3a
        ex      af, af'
        push    af
        ld      hl, $5c78
        ld      sp, $5700
        ld      e, (hl)
        inc     l
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, $8f
        ld      e, (hl)
        ld      (hl), $39
        inc     l
        ld      d, (hl)
        ld      (hl), b
        push    de
        inc     l
        ld      a, i
        ld      e, a
        ld      a, $18
        ld      i, a
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, $3b
        ld      e, (hl)
        ld      (hl), 8
        ld      l, $41
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, b
        ld      de, CADEN-13
        ldir
        ex      de, hl
        ld      hl, pok19+10
        ld      c, e
        dec     e
        lddr
pokm1   push    bc
        xor     a
        ei
        defb    $c2, $ff, $ff
pok01   ld      hl, CADEN
pok02   ld      (hl), 1
        inc     l
        jr      nz, pok02
        or      a
pok03   ld      de, CADEN+1
        jr      z, pok04
        ld      (de), a
        ld      l, CADEN & $ff
        ld      (hl), 2
pok04   ld      hl, $4000
        ld      b, $5
pok05   ld      a, (de)
        push    de
        ex      de, hl
        ld      l, a
        ld      h, 7
        add     hl, hl
        inc     h
        add     hl, hl
        add     hl, hl
        ex      de, hl
        call    $0B99
        pop     de
        inc     de
        djnz    pok05
        ld      hl, $5c3b
pok06   bit     5, (hl)
        jr      z, pok06
        res     5, (hl)
        ld      a, ($5C08)
        ld      hl, CADEN
        ld      c, (hl)
        cp      13
        jr      z, pok14
        jr      nc, pok07
        dec     (hl)
        jr      z, pok07
        xor     a
        dec     c
        dec     (hl)
pok07   cp      'i'
        jr      z, pok14
        inc     (hl)
        jp      m, pok01
        add     hl, bc
        ld      (hl), a
        xor     a
        jr      pok03
pok08   ld      a, (hl)
        ex      (sp), hl
        ld      hl, CADEN+2
        ld      (hl), $2f
        dec     l
        ld      (hl), $32
        sub     200
        jr      nc, pok09
        dec     (hl)
        add     a, 100
        jr      c, pok09
        dec     (hl)
        dec     (hl)
        add     a, 90
        jr      nc, pok12
        ccf
        jr      pok11
pok09   inc     l
pok10   sub     10
pok11   inc     (hl)
        jr      nc, pok10
        inc     l
pok12   ld      (CADEN), a
        add     a, 10+$30
pok13   ld      (hl), a
        xor     a
        inc     l
        jr      nz, pok13
        jr      pok03
pok14   dec     c
        jp      m, pok17
        ld      b, c
        rlca
        rlca
        rl      c
        ex      de, hl
        ld      h, l
pok15   inc     e
        ld      a, (de)
        and     $0f
        push    bc
        add     hl, hl
        ld      b, h
        ld      c, l
        add     hl, hl
        add     hl, hl
        add     hl, bc
        ld      b, 0
        ld      c, a
        add     hl, bc
        pop     bc
        djnz    pok15
        bit     0, c
        jr      z, pok16
        ld      a, l
        pop     bc
        ld      (bc), a
        inc     bc
        jp      pokm1
pok16   bit     3, c
        jr      nz, pok08
        di
        ld      a, (CADEN+1)
        sub     'r'
        ret     z
        dec     a
        jr      z, save
        ld      a, l
pok17   pop     hl
        jr      nz, pok18
        ld      (hl), a
pok18   ld      c, 11
        ld      hl, CADEN-13
        ld      de, $5c00
        ldir
        ld      hl, $5805
        ld      a, (hl)
        and     $f8
        ld      c, a
        rra
        rra
        rra
        and     $07
        or      c
        dec     l
        ld      c, l
        ld      (hl), a
        ld      de, $5803
        lddr
        pop     de
        ld      hl, $5c41
        ld      (hl), d
        ld      l, $3b
        ld      (hl), e
        pop     de
        ld      l, $91
        ld      a, e
        ld      i, a
        ld      (hl), d
        pop     de
        dec     l
        ld      (hl), d
        dec     l
        ld      (hl), e
        pop     hl
        ld      ($5c78), hl
        ld      sp, $57e0
        pop     af
        ex      af, af'
        pop     iy
        pop     hl
        pop     bc
        pop     de
        pop     af
        ld      sp, (CADEN-2)
        retn
pok19   defb    $ff, $00, $00, $00, $ff, $00, $00, $00, $00, $23, $05
save
pokef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3c00, 16
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3cde, 3
        jp      $0038
