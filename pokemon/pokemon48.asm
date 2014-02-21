        output  pokemon48.bin
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
        ld      a, $05
        ld      bc, $1ffd
        out     (c), a
        xor     a
        ld      ($33fb), a
        rst     0