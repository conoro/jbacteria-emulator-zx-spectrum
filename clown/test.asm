        output  test.bin
        org     $0000
        di
        xor     a
        ld      hl, $5800
start   ld      (hl), 0
        inc     hl
        inc     a
        jr      nz, start
bucle   jr      bucle