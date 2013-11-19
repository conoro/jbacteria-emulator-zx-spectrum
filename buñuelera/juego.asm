
        DEFINE  mapw  12
        DEFINE  maph  2
        DEFINE  scrw  12
        DEFINE  scrh  8

        DEFINE  DMAP_BITSYMB 5
        DEFINE  DMAP_BITHALF 1
        DEFINE  DMAP_BUFFER  $5b01
        DEFINE  WINDOW       $c000

    MACRO   copyline from, to
        ld      sp, WINDOW+12*from
        pop     bc
        pop     de
        pop     hl
        exx
        pop     bc
        pop     de
        pop     hl
        ld      sp, to+$4010
        push    hl
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

      IF 0=0
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
        copyline $10, $020
        copyline $11, $02c
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
        copyline $b0, $040
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

        copyline $80, $800
        copyline $81, $80c
        copyline $82, $900
        copyline $83, $90c
        copyline $84, $a00
        copyline $85, $a0c
        copyline $86, $b00
        copyline $87, $b0c
        copyline $88, $c00
        copyline $89, $c0c
        copyline $8a, $d00
        copyline $8b, $d0c
        copyline $8c, $e00
        copyline $8d, $e0c
        copyline $8e, $f00
        copyline $8f, $f0c
        copyline $90, $800
        copyline $91, $80c
        copyline $92, $920
        copyline $93, $92c
        copyline $94, $a20
        copyline $95, $a2c
        copyline $96, $b20
        copyline $97, $b2c
        copyline $98, $c20
        copyline $99, $c2c
        copyline $9a, $d20
        copyline $9b, $d2c
        copyline $9c, $e20
        copyline $9d, $e2c
        copyline $9e, $f20
        copyline $9f, $f2c
        copyline $a0, $840
        copyline $a1, $84c
        copyline $a2, $940
        copyline $a3, $94c
        copyline $a4, $a40
        copyline $a5, $a4c
        copyline $a6, $b40
        copyline $a7, $b4c
        copyline $a8, $c40
        copyline $a9, $c4c
        copyline $aa, $d40
        copyline $ab, $d4c
        copyline $ac, $e40
        copyline $ad, $e4c
        copyline $ae, $f40
        copyline $af, $f4c
        copyline $b0, $860
        copyline $b1, $86c
        copyline $b2, $960
        copyline $b3, $96c
        copyline $b4, $a60
        copyline $b5, $a6c
        copyline $b6, $b60
        copyline $b7, $b6c
        copyline $b8, $c60
        copyline $b9, $c6c
        copyline $ba, $d60
        copyline $bb, $d6c
        copyline $bc, $e60
        copyline $bd, $e6c
        copyline $be, $f60
        copyline $bf, $f6c
        copyline $c0, $880
        copyline $c1, $88c
        copyline $c2, $980
        copyline $c3, $98c
        copyline $c4, $a80
        copyline $c5, $a8c
        copyline $c6, $b80
        copyline $c7, $b8c
        copyline $c8, $c80
        copyline $c9, $c8c
        copyline $ca, $d80
        copyline $cb, $d8c
        copyline $cc, $e80
        copyline $cd, $e8c
        copyline $ce, $f80
        copyline $cf, $f8c
        copyline $d0, $8a0
        copyline $d1, $8ac
        copyline $d2, $9a0
        copyline $d3, $9ac
        copyline $d4, $aa0
        copyline $d5, $aac
        copyline $d6, $ba0
        copyline $d7, $bac
        copyline $d8, $ca0
        copyline $d9, $cac
        copyline $da, $da0
        copyline $db, $dac
        copyline $dc, $ea0
        copyline $dd, $eac
        copyline $de, $fa0
        copyline $df, $fac
        copyline $e0, $8c0
        copyline $e1, $8cc
        copyline $e2, $9c0
        copyline $e3, $9cc
        copyline $e4, $ac0
        copyline $e5, $acc
        copyline $e6, $bc0
        copyline $e7, $bcc
        copyline $e8, $cc0
        copyline $e9, $ccc
        copyline $ea, $dc0
        copyline $eb, $dcc
        copyline $ec, $ec0
        copyline $ed, $ecc
        copyline $ee, $fc0
        copyline $ef, $fcc
        copyline $f0, $8e0
        copyline $f1, $8ec
        copyline $f2, $9e0
        copyline $f3, $9ec
        copyline $f4, $ae0
        copyline $f5, $aec
        copyline $f6, $be0
        copyline $f7, $bec
        copyline $f8, $ce0
        copyline $f9, $cec
        copyline $fa, $de0
        copyline $fb, $dec
        copyline $fc, $ee0
        copyline $fd, $eec
        copyline $fe, $fe0
        copyline $ff, $fec
      ENDIF

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
        jp      nz, bucl
        dec     (hl)
        jp      bucl
noa     dec     hl
        cp      'o'
        jr      nz, noo
        dec     (hl)
        jp      p, noo
        inc     (hl)
noo     cp      'p'
        jp      nz, bucl
        ld      a, mapw
        inc     (hl)
        cp      (hl)
        jp      nz, bucl
        dec     (hl)
pact    jp      bucl

;       a=      numero pantalla
paint_map:
        ld      (paint4+1), sp
        call    descom
        ld      hl, WINDOW
;        ld      bc, $5810-scrw
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
        ld      bc, 24
        
  ;celda 1
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -167
        add     hl, de
  ;celda 2
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, 23
        add     hl, de
  ;celda 3
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -167
        add     hl, de
  ;celda 4
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        add     hl, bc
        pop     de
        ld      (hl), e
        add     hl, bc
        ld      (hl), d
        ld      de, -359
        add     hl, de
        ex      de, hl
        ld      hl, (attr)
        pop     bc
;        ld      (hl), c
        inc     hl
;        ld      (hl), b
        ld      bc, $001f
        add     hl, bc
        pop     bc
;        ld      (hl), c
        inc     hl
;        ld      (hl), b
        ld      bc, $ffe1
        add     hl, bc
        ld      (attr), hl
        ex      de, hl
        exx
        inc     bc
        dec     a
        jp      nz, paint2
        exx
        ex      de, hl
        ld      bc, $40-(scrw*2)
        add     hl, bc
        ld      (attr), hl
        ex      de, hl
        ld      de, $168
        add     hl, de
        exx
        ex      af, af'
        dec     a
        jp      nz, paint1
paint4  ld      sp, 0
        ret


attr    dw      0
x       db      0
y       db      0
descom  include descom12.asm
tiles   incbin  tiles.bin
map     incbin  mapa_comprimido.bin
fin