        DEFINE  mapw  12
        DEFINE  maph  2
        DEFINE  scrw  12
        DEFINE  scrh  8
        DEFINE  DMAP_BITSYMB 5
        DEFINE  DMAP_BITHALF 1
        DEFINE  DMAP_BUFFER  $5b01

    MACRO   copy  to
        ld      sp, $401c+to*16
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
        di
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
        ld      (paint3+1), sp
        push    af
        ld      (paint4+1), sp
bucl    ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l
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
repet   in      a, ($ff)
        inc     a
        jr      z, repet
screen  copy    $00
        copy    $10
        copy    $20
        copy    $30
        copy    $40
        copy    $50
        copy    $60
        copy    $70
        copy    $02
        copy    $12
        copy    $22
        copy    $32
        copy    $42
        copy    $52
        copy    $62
        copy    $72
        copy    $04
        copy    $14
        copy    $24
        copy    $34
        copy    $44
        copy    $54
        copy    $64
        copy    $74
        copy    $06
        copy    $16
        copy    $26
        copy    $36
        copy    $46
        copy    $56
        copy    $66
        copy    $76
        copy    $08
        copy    $18
        copy    $28
        copy    $38
        copy    $48
        copy    $58
        copy    $68
        copy    $78
        copy    $0a
        copy    $1a
        copy    $2a
        copy    $3a
        copy    $4a
        copy    $5a
        copy    $6a
        copy    $7a
        copy    $0c
        copy    $1c
        copy    $2c
        copy    $3c
        copy    $4c
        copy    $5c
        copy    $6c
        copy    $7c
        copy    $0e
        copy    $1e
        copy    $2e
        copy    $3e
        copy    $4e
        copy    $5e
        copy    $6e
        copy    $7e
        copy    $80
        copy    $90
        copy    $a0
        copy    $b0
        copy    $c0
        copy    $d0
        copy    $e0
        copy    $f0
        copy    $82
        copy    $92
        copy    $a2
        copy    $b2
        copy    $c2
        copy    $d2
        copy    $e2
        copy    $f2
        copy    $84
        copy    $94
        copy    $a4
        copy    $b4
        copy    $c4
        copy    $d4
        copy    $e4
        copy    $f4
        copy    $86
        copy    $96
        copy    $a6
        copy    $b6
        copy    $c6
        copy    $d6
        copy    $e6
        copy    $f6
        copy    $88
        copy    $98
        copy    $a8
        copy    $b8
        copy    $c8
        copy    $d8
        copy    $e8
        copy    $f8
        copy    $8a
        copy    $9a
        copy    $aa
        copy    $ba
        copy    $ca
        copy    $da
        copy    $ea
        copy    $fa
        copy    $8c
        copy    $9c
        copy    $ac
        copy    $bc
        copy    $cc
        copy    $dc
        copy    $ec
        copy    $fc
        copy    $8e
        copy    $9e
        copy    $ae
        copy    $be
        copy    $ce
        copy    $de
        copy    $ee
        copy    $fe

; calculo origen sprite
paint3  ld      sp, 0
        ld      bc, (corx)
        xor     a
        call    ruti
        ld      hl, cory
        ld      ix, y
        ld      bc, $026e
        ld      de, $fd | maph<<8
        call    key_process
        jr      c, tbucl
        cp      $03
        jr      nz, pact
        ld      bc, $14dc
        dec     l
        dec     ixl
        ld      de, $df | mapw<<8
        call    key_process
tbucl   jp      c, bucl
pact    jp      repet


ruti    xor     c
        and     $f8
        xor     c
        ld      (cspr+2), a
cspr    ld      sp, (sprites)
        pop     de
        ld      a, b
        add     a, d
        ld      (clin+1), a
clin    ld      hl, (lookt)
        ld      a, c
        and     $f8
        rra
        rra
        rra
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
col24   pop     de
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
col16a  djnz    col16
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
paint4  ld      sp, 0
        ret

key_process:
        ld      a, e
        in      a, ($fe)
        and     $03
        cp      $02
        jr      z, key2
        ret     nc
        dec     (hl)
        dec     (hl)
        ld      a, (hl)
        cp      b
        ret     nc
        dec     (ix)
        jp      p, key1
        inc     (hl)
        inc     (hl)
        inc     (ix)
        and     a
        ret
key1    ld      (hl), c
        ret
key2    ld      a, c
        inc     (hl)
        inc     (hl)
        cp      (hl)
        ret     nc
        inc     (ix)
        ld      a, (ix)
        cp      d
        jr      nz, key3
        dec     (hl)
        dec     (hl)
        dec     (ix)
        and     a
        ret
key3    ld      (hl), 0
        ret

attr    dw      $5810-scrw
x       db      0
y       db      0
corx    db      32
cory    db      2
ene0x   db      12
ene0y   db      12


        block   $9c00-$
lookt   incbin  table.bin
        block   $9d00-$

;        display $

sprites incbin  salida.bin
descom  include descom12.asm
tiles   incbin  tiles.bin
map     incbin  mapa_comprimido.bin
fin