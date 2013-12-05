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
ini     ld      de, $8000+fin-empe-1
        nop
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     ld      hl, $5ccb+fin-ini-1
        ld      bc, fin-empe
        lddr
        jp      $8000
empe    ld      hl, $0110        ; The keyboard repeat and delay values are 
        ld      ($5c09), hl      ; loaded to REPDEL and REPPER.
        ld      hl, $5800
        ld      de, $5801
        ld      bc, $01ff
        ld      (hl), l
        ldir
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

; calculo origen sprite
        ld      a, (corx)
        and     $03
        add     a, a
        ld      c, a
        ld      b, 0
        ld      hl, sprites
        add     hl, bc
        ld      sp, hl
        pop     hl
        ld      sp, hl
        pop     de

  ; cline
        ld      a, (cory)
        add     a, a
        add     a, d
        ld      b, a
        and     $c0
        srl     a
        srl     a
        srl     a
        or      $40
        ld      h, a
        ld      a, b
        and     $38
        add     a, a
        add     a, a
        ld      l, a
        ld      a, b
        and     $06
        or      h
        ld      h, a
        ld      a, (corx)
        add     a, a
        and     $f8
        srl     a
        srl     a
        srl     a
        or      l
        ld      l, a
        ld      a, e
spr1    ex      af, af'
        pop     bc
        ld      a, c
        and     $03
        add     a, l
        dec     a
        ld      l, a
        bit     3, c
        jr      z, ncol24
col24:  pop     de          ; 00= 8   01=16   1x=24 
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col24a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col24a
        ld      a, h
        sub     $08
        ld      h, a
col24a  djnz    col24
        jr      fini
ncol24  bit     2, c
        jr      z, col8
col16   pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col16a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col16a
        ld      a, h
        sub     $08
        ld      h, a
col16a: djnz    col16
        jr      fini
col8    pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        pop     de
        ld      a, (hl)
        and     d
        or      e
        ld      (hl), a
        inc     h
        ld      a, h
        and     $06
        jr      nz, col8a
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, col8a
        ld      a, h
        sub     $08
        ld      h, a
col8a   djnz    col8
fini    ex      af, af'
        dec     a
        jp      nz, spr1
spkb    ld      sp, 0  
        ei
here    call    $10a8
        jr      nc, here
        ld      a, ($5c08)
        ld      hl, cory
        ld      ix, y
        ld      c, $37
cona    cp      'q'
        jr      nz, noq
        dec     (hl)
        jp      p, pact
        dec     (ix)
        jp      p, cres
        inc     (hl)
        inc     (ix)
        jr      pact
cres    ld      (hl), c
        jr      tbucl
noq     cp      'a'
        jr      nz, noa
        ld      a, c
        inc     (hl)
        cp      (hl)
        jr      nc, pact
        inc     (ix)
        ld      a, (ix)
        cp      maph
        jr      nz, bpes
        dec     (hl)
        dec     (ix)
        jr      pact
bpes    ld      (hl), 0
        jr      tbucl
noa     ld      bc, $0a6e
        dec     l
        dec     ixl
        cp      'o'
        jr      nz, noo
        dec     (hl)
        ld      a, (hl)
        cp      b
        jr      nc, pact
        dec     (ix)
        jp      p, pres
        inc     (hl)
        inc     (ix)
pact    jp      repet
pres    ld      (hl), c
        jr      tbucl
noo     cp      'p'
        jr      nz, pact
        ld      a, c
        inc     (hl)
        cp      (hl)
        jr      nc, pact
        inc     (ix)
        ld      a, (ix)
        cp      mapw
        jr      nz, apes
        dec     (hl)
        dec     (ix)
        jr      pact
apes    ld      (hl), b
tbucl   jp      bucl


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

attr    dw      $5810-scrw
x       db      0
y       db      0
corx    db      16
cory    db      0

        block   $9c00-$
;        display $

sprites incbin  salida.bin
descom  include descom12.asm
tiles   incbin  tiles.bin
map     incbin  mapa_comprimido.bin
fin