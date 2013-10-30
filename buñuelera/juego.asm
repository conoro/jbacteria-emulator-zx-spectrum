
        DEFINE  mapw  8
        DEFINE  maph  3
        DEFINE  scrw  15
        DEFINE  scrh  10

    MACRO   mult8x8 data
        ld      d, 0
        ld      l, d
        add     hl, hl
      IF  data & %10000000
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %01000000
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00100000
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00010000
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00001000
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00000100
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00000010
        add     hl, de
      ENDIF
        add     hl, hl
      IF  data & %00000001
        add     hl, de
      ENDIF
    ENDM

        output  juego.bin
        org     $8000-20
ini     ld      de, $8000-20
        push    bc
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     pop     hl
        ld      bc, fin-ini
        ldir
        jp      $8000
bucl    ld      a, 5
        call    paint_map
inf     jr      inf

;       a=      numero pantalla
paint_map:
        ld      hl, $4010-scrw
        exx
        ld      e, a
        mult8x8 scrw*scrh
        ld      de, map
        add     hl, de
        ld      a, scrh
paint1  ex      af, af'
        ld      a, scrw
paint2  push    hl
        ld      l, (hl)
        ld      h, 0
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ld      bc, tiles_left
        add     hl, bc
        ld      sp, hl
        exx
        pop     de
        ld      (hl), e
        inc     hl
        ld      (hl), d
        inc     h

        pop     de
        ld      (hl), e
        dec     hl
        ld      (hl), d
        inc     h

 


        ld      (hl), d
        inc     h



        pop     hl
        inc     hl
        dec     a
        jr      nz, paint2
        ex      af, af'
        dec     a
        jr      nz, paint1
        ret

tiles   include tiles.asm
map     incbin  mapa.bin
fin