
        DEFINE  mapw  12
        DEFINE  maph  2
        DEFINE  scrw  15
        DEFINE  scrh  10

        DEFINE  DMAP_BITSYMB 5
        DEFINE  DMAP_BITHALF 1
        DEFINE  DMAP_BUFFER  $5b01

    MACRO   copyline from, to
        ld      sp, WINDOW+12*from
        pop     bc
        pop     de
        pop     hl
        exx
        pop     bc
        pop     de
        pop     hl
        ld      sp, to+16
        pop     hl
        push    de
        push    bc
        exx
        push    hl
        push    de
        push    bc
    ENDM

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


        copyline $00, $000
        copyline $01, $00c
        copyline $02, $100
        copyline $03, $10c
        copyline $04, $200
        copyline $05, $20c
        copyline $06, $300
        copyline $07, $30c
        copyline $08, $400
        copyline $09, $40c
        copyline $0a, $500
        copyline $0b, $50c
        copyline $0c, $600
        copyline $0d, $60c
        copyline $0e, $700
        copyline $0f, $70c
        copyline $10, $000
        copyline $11, $00c
        copyline $12, $120
        copyline $13, $12c
        copyline $14, $220
        copyline $15, $22c
        copyline $16, $320
        copyline $17, $32c
        copyline $18, $420
        copyline $19, $42c
        copyline $1a, $520
        copyline $1b, $52c
        copyline $1c, $620
        copyline $1d, $62c
        copyline $1e, $720
        copyline $1f, $72c
        copyline $20, $040
        copyline $21, $04c
        copyline $22, $140
        copyline $23, $14c
        copyline $24, $240
        copyline $25, $24c
        copyline $26, $340
        copyline $27, $34c
        copyline $28, $440
        copyline $29, $44c
        copyline $2a, $540
        copyline $2b, $54c
        copyline $2c, $640
        copyline $2d, $64c
        copyline $2e, $740
        copyline $2f, $74c
        copyline $30, $060
        copyline $31, $06c
        copyline $32, $160
        copyline $33, $16c
        copyline $34, $260
        copyline $35, $26c
        copyline $36, $360
        copyline $37, $36c
        copyline $38, $460
        copyline $39, $46c
        copyline $3a, $560
        copyline $3b, $56c
        copyline $3c, $660
        copyline $3d, $66c
        copyline $3e, $760
        copyline $3f, $76c
        copyline $40, $080
        copyline $41, $08c
        copyline $42, $180
        copyline $43, $18c
        copyline $44, $280
        copyline $45, $28c
        copyline $46, $380
        copyline $47, $38c
        copyline $48, $480
        copyline $49, $48c
        copyline $4a, $580
        copyline $4b, $58c
        copyline $4c, $680
        copyline $4d, $68c
        copyline $4e, $780
        copyline $4f, $78c
        copyline $50, $0a0
        copyline $51, $0ac
        copyline $52, $1a0
        copyline $53, $1ac
        copyline $54, $2a0
        copyline $55, $2ac
        copyline $56, $3a0
        copyline $57, $3ac
        copyline $58, $4a0
        copyline $59, $4ac
        copyline $5a, $5a0
        copyline $5b, $5ac
        copyline $5c, $6a0
        copyline $5d, $6ac
        copyline $5e, $7a0
        copyline $5f, $7ac
        copyline $60, $0c0
        copyline $61, $0cc
        copyline $62, $1c0
        copyline $63, $1cc
        copyline $64, $2c0
        copyline $65, $2cc
        copyline $66, $3c0
        copyline $67, $3cc
        copyline $68, $4c0
        copyline $69, $4cc
        copyline $6a, $5c0
        copyline $6b, $5cc
        copyline $6c, $6c0
        copyline $6d, $6cc
        copyline $6e, $7c0
        copyline $6f, $7cc
        copyline $70, $0e0
        copyline $71, $0ec
        copyline $72, $1e0
        copyline $73, $1ec
        copyline $74, $2e0
        copyline $75, $2ec
        copyline $76, $3e0
        copyline $77, $3ec
        copyline $78, $4e0
        copyline $79, $4ec
        copyline $7a, $5e0
        copyline $7b, $5ec
        copyline $7c, $6e0
        copyline $7d, $6ec
        copyline $7e, $7e0
        copyline $7f, $7ec

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
        ld      hl, DMAP_BUFFER
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