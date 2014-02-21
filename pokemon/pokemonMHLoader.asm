        output  pokemonMHLoader.bin
        org     $5ccb
        ld      de, file
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96
        ld      b, 1
        ex      de, hl
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
        rst     0
file    incbin  pokemonMH.bin