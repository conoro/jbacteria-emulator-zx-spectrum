        output  test.bin
        ld      hl, juego+20
        ld      de, $8000
        push    de
        ld      bc, fin-juego-20
        ldir
        ret
juego   incbin  juego.bin
fin