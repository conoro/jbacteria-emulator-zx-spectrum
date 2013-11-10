
        DEFINE  mapw  12
        DEFINE  maph  2
        DEFINE  scrw  15
        DEFINE  scrh  10

        DEFINE  bitsym  5
        DEFINE  bithalf 1
        DEFINE  buffer  $5b01

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
bucl    ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l
        di
        call    paint_map
        ei
here    call    $10a8
        jr      nc, here
        ld      a, ($5c08)
        cp      'q'
        ld      hl, y
        jr      nz, noq
        dec     (hl)
        jp      p, noq
        inc     (hl)
noq     cp      'a'
        jr      nz, noa
        ld      a, maph
        inc     (hl)
        cp      (hl)
        jr      nz, bucl
        dec     (hl)
        jr      bucl
noa     dec     hl
        cp      'o'
        jr      nz, noo
        dec     (hl)
        jp      p, noo
        inc     (hl)
noo     cp      'p'
        jr      nz, bucl
        ld      a, mapw
        inc     (hl)
        cp      (hl)
        jr      nz, bucl
        dec     (hl)
pact    jr      bucl

;       a=      numero pantalla
paint_map:
        ld      (paint4+1), sp
        call    descom
        ld      hl, $4010-scrw
        ld      bc, $5810-scrw
        exx
        ld      hl, buffer
        ld      bc, hl
        ld      a, scrh
paint1  ex      af, af'
        ld      a, scrw
paint2  ld      hl, bc
        ld      l, (hl)
        ld      h, 0
        add     hl, hl
        add     hl, hl
        ld      de, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiles
        add     hl, de
        ld      sp, hl
        exx
  ;celda 1
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        ld      de, $f901
        add     hl, de
  ;celda 2
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        ld      de, $f91f
        add     hl, de
  ;celda 3
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        ld      de, $f901
        add     hl, de
  ;celda 4
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        inc     h
        ld      (hl), d
        ld      de, $f8e1
        add     hl, de
        ex      de, hl
        ld      hl, bc
        pop     bc
        ld      (hl), c
        inc     hl
        ld      (hl), b
        ld      bc, $001f
        add     hl, bc
        pop     bc
        ld      (hl), c
        inc     hl
        ld      (hl), b
        ld      bc, $ffe1
        add     hl, bc
        ld      bc, hl
        ex      de, hl
        exx
        inc     bc
        dec     a
        jp      nz, paint2
        exx
        ex      de, hl
        ld      bc, $40-(scrw*2)
        add     hl, bc
        ld      bc, hl
        ex      de, hl
        ld      de, $40-(scrw*2)
        add     hl, de
        bit     0, h
        jr      z, paint3
        ld      de, $0700
        add     hl, de
paint3  exx
        ex      af, af'
        dec     a
        jp      nz, paint1
paint4  ld      sp, 0
        ret

x       db      0
y       db      0
descom  include descom.asm
tiles   incbin  tiles.bin
map     incbin  mapa_comprimido.bin
fin