        output  test.bin
        org     $0000
        di
        ld      hl, $8000
        ld      de, $4000
        ld      bc, $1800
        ldir
        ld      bc, $300
        ld      hl, $5800
        ld      (hl), 7
        inc     de
        ldir
bucle   jr      bucle