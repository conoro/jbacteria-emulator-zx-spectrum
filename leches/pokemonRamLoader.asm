        output  pokemonRamLoader.bin
        org     $5ccb
        ld      de, $c000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96
        ld      sp, $8000
        ld      bc, $7ffd
        push    bc
        ld      a, $14
        out     (c), a
        ld      bc, $4000
        ld      h, c
        ld      l, c
        ldir
        pop     bc
        ld      de, $1605
        out     (c), d
        ld      b, $1f
        out     (c), e
        ld      b, 1
        ld      hl, file
poralo  ld      e, (hl)
        ld      a, e
        inc     hl
        ld      d, (hl)
        inc     hl
        ld      c, (hl)
        inc     hl
        ldir
        dec     a
        jr      nz, poralo
        ld      ($33fb), a
        ld      b, 11
        ld      de, $04df
gamofa  ld      a, (hl)
        inc     hl
        ld      (de), a
        ld      a, (hl)
        inc     hl
        add     a, e
        ld      e, a
        jr      nc, potipo
        inc     d
potipo  djnz    gamofa
        rst     0
file    incbin  pokemonRam.bin