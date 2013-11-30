;  aaa-bbbb   a=longitud b=skip
;  -cccddee   c=repeticion, dd=offset, ee=ancho
;
; sprite 0 rotacion 0
; sprite 0 rotacion 1
; sprite 0 rotacion 2
; sprite 0 rotacion 3
; sprite 1 rotacion 0
; sprite 1 rotacion 1
; sprite 1 rotacion 2
; sprite 1 rotacion 3
; sprite 2 rotacion 0
;...
; sprite 15 rotacion 0
; sprite 15 rotacion 1
; sprite 15 rotacion 2
; sprite 15 rotacion 3


        DEFINE  mapw  12
        DEFINE  maph  2
        DEFINE  scrw  12
        DEFINE  scrh  8

        DEFINE  DMAP_BITSYMB 5
        DEFINE  DMAP_BITHALF 1
        DEFINE  DMAP_BUFFER  $5b01

    MACRO   copy  to
        ld      sp, to+$4010
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
        ld      hl, 0
        push    hl
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
        org     $8000-22
ini     ld      de, $8000+fin-bucl-1
        nop
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     ld      hl, $5ccb+fin-ini-1
        ld      bc, fin-bucl
        lddr
        jp      $8000
bucl    ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l
        halt
        di
        call    paint_map
        ld      (spkb+1), sp

repet   in      a, ($ff)
        inc     a
        jr      z, repet

screen  copy $00c
        copy $10c
        copy $20c
        copy $30c
        copy $40c
        copy $50c
        copy $60c
        copy $70c
        copy $02c
        copy $12c
        copy $22c
        copy $32c
        copy $42c
        copy $52c
        copy $62c
        copy $72c
        copy $04c
        copy $14c
        copy $24c
        copy $34c
        copy $44c
        copy $54c
        copy $64c
        copy $74c
        copy $06c
        copy $16c
        copy $26c
        copy $36c
        copy $46c
        copy $56c
        copy $66c
        copy $76c
        copy $08c
        copy $18c
        copy $28c
        copy $38c
        copy $48c
        copy $58c
        copy $68c
        copy $78c
        copy $0ac
        copy $1ac
        copy $2ac
        copy $3ac
        copy $4ac
        copy $5ac
        copy $6ac
        copy $7ac
        copy $0cc
        copy $1cc
        copy $2cc
        copy $3cc
        copy $4cc
        copy $5cc
        copy $6cc
        copy $7cc
        copy $0ec
        copy $1ec
        copy $2ec
        copy $3ec
        copy $4ec
        copy $5ec
        copy $6ec
        copy $7ec
        copy $80c
        copy $90c
        copy $a0c
        copy $b0c
        copy $c0c
        copy $d0c
        copy $e0c
        copy $f0c
        copy $82c
        copy $92c
        copy $a2c
        copy $b2c
        copy $c2c
        copy $d2c
        copy $e2c
        copy $f2c
        copy $84c
        copy $94c
        copy $a4c
        copy $b4c
        copy $c4c
        copy $d4c
        copy $e4c
        copy $f4c
        copy $86c
        copy $96c
        copy $a6c
        copy $b6c
        copy $c6c
        copy $d6c
        copy $e6c
        copy $f6c
        copy $88c
        copy $98c
        copy $a8c
        copy $b8c
        copy $c8c
        copy $d8c
        copy $e8c
        copy $f8c
        copy $8ac
        copy $9ac
        copy $aac
        copy $bac
        copy $cac
        copy $dac
        copy $eac
        copy $fac
        copy $8cc
        copy $9cc
        copy $acc
        copy $bcc
        copy $ccc
        copy $dcc
        copy $ecc
        copy $fcc
        copy $8ec
        copy $9ec
        copy $aec
        copy $bec
        copy $cec
        copy $dec
        copy $eec
        copy $fec

        call    cline
; calculo origen sprite
        ld      a, (corx)
        and     06h
        add     a, a
        ld      c, a
        ld      b, 0
        ld      hl, sprmeta
        add     hl, bc
        ld      sp, hl
        pop     hl
        ld      sp, hl
        pop     hl
          ld      b, l
          ld      l, 0
          add     hl, de
          ex      de, hl
;        dec     sp
;        pop     af
;        and     $f
;        add     a, d
;        ld      d, a
;        ld      a, (hl)
;        rlca
;        rlca
;        rlca
;        and     $7
;        inc     a

spkb    ld      sp, 0  
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
        ld      hl, $5810-scrw
        ld      (attr), hl
        ld      hl, screen+12*4
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
        ld      bc, 51
        
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
        ld      de, -357+1
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
        ld      de, 51-1
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
        ld      de, -357+1
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
        ld      de, -765-5
        add     hl, de
        ex      de, hl
        ld      hl, (attr)
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
        ld      de, 816+48
        add     hl, de
        exx
        ex      af, af'
        dec     a
        jp      nz, paint1
paint4  ld      sp, 0
        ret

; calculo línea
cline:  ld      a,(cory)
        ld      h,a
        and     0c0h
        srl     a
        srl     a
        srl     a
        or      40h
        ld      d,a
        ld      a,h
        and     38h
        add     a,a
        add     a,a
        ld      e,a
        ld      a,h
        and     06h
        or      d
        ld      d,a
        ld      a,(corx)
        and     0f8h
        srl     a
        srl     a
        srl     a
        or      e
        ld      e,a
        ret     

attr    dw      $5810-scrw
x       db      0
y       db      0
corx    db      0
cory    db      0


sprmeta dw      spr0r0
        dw      spr0r1
        dw      spr0r2
        dw      spr0r3
        dw      spr1r0

spr0r0  db      $e0         ; longitud=8, skip= 0
        db      %11100001   ; rep=8, offset=0, ancho=16
        db      %11111111, %00000000, %11111111, %00000000
        db      %00001111, %00000000, %11111100, %00000000
        db      %11111000, %00000011, %00000111, %11110000
        db      %00000011, %11111000, %11110000, %00000111
        db      %11110000, %00000100, %00000011, %11001000
        db      %00000011, %11101000, %11110000, %00000101
        db      %11100000, %00000011, %00000111, %00110000
        db      %00000001, %11110000, %11000000, %00011101
        db      %10000000, %00100001, %00000000, %01010110
        db      %00000000, %10100110, %10000000, %00100010
        db      %11000000, %00011001, %00000001, %11011000
        db      %00100111, %10000000, %11000010, %00011000
        db      %11100110, %00000000, %00110111, %10000000
        db      %00000011, %11001000, %11110000, %00000001
        db      %11100000, %00001110, %00000011, %00111000
        db      %00000111, %00000000, %11100001, %00001000

spr0r1
spr0r2
spr0r3
spr1r0



descom  include descom12.asm
tiles   incbin  tiles.bin
map     incbin  mapa_comprimido.bin
fin