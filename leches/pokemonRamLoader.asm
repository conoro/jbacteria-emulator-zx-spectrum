        output  pokemonRamLoader.bin
        org     $5ccb
        ld      de, $c000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96
        ld      sp, $8000
        ld      bc, $7ffd
        ld      a, $14
        out     (c), a
        ld      bc, $4000
        ld      h, c
        ld      l, c
        ldir
        ld      bc, $1ffd
        ld      a, $05
        out     (c), a
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
        rst     0
file    incbin  pokemonRam.bin