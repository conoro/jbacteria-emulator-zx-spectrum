; 5b00      numero de pantalla a pintar (1 byte)
; 5b01-5b96 tiles (150 bytes)
; 5b97-5bfd libre (103 bytes)
; 5bfe-5bff coord repintado (2 bytes)
; 5c00-5c3f sprites (64 bytes)
; 5c40-5c4f balas (16 bytes) no implementado
; 5c50-5d00 tabla (176 bytes) 4 rotaciones
; 5c50-5db0 tabla (352 bytes) 8 rotaciones
        include define.asm
        DEFINE  mapw  12              ; map width is 12
        DEFINE  maph  2               ; map height is 2, our demo has 12x2 screens
        DEFINE  scrw  15              ; screen width is 12
        DEFINE  scrh  10              ; screen height is 8, our window is 12x8 tiles (exactly half of the screen area)
        DEFINE  DMAP_BITSYMB 6        ; these 3 constants are for the map decompressor
        DEFINE  DMAP_BITHALF 1        ; BITSYMB and BITHALF declares 5.5 bits per symbol (16 tiles with 5 bits and 32 with 6 bits)
        DEFINE  DMAP_BUFFER  $5b01    ; BUFFER points to where is decoded the uncompressed screen
        DEFINE  sylo  $66
        DEFINE  syhi  $c0
        DEFINE  smooth  1
        DEFINE  clipup  1
        DEFINE  clipdn  1
        DEFINE  safeco  1
        DEFINE  initregs

; This macro multiplies two 8 bits numbers (second one is a constant)
; Factor 1 is on E register, Factor 2 is the constant data (macro parameter)
; Result is returned on HL (Macro optimized by Metalbrain & Einar Saukas)

  MACRO multsub first, second
    IF  data & first
        add     hl, hl
      IF  data & second
        add     hl, de
      ENDIF
    ENDIF
  ENDM

  MACRO mult8x8 data
    IF  data = 0
        ld      hl, 0
    ELSE
        ld      h, 0
        ld      l, e
      IF  data != 1 && data != 2 && data != 4 && data != 8 && data != 16 && data != 32 && data != 64 && data != 128
        ld      d, h
      ENDIF
        multsub %10000000, %01000000
        multsub %11000000, %00100000
        multsub %11100000, %00010000
        multsub %11110000, %00001000
        multsub %11111000, %00000100
        multsub %11111100, %00000010
        multsub %11111110, %00000001
    ENDIF
  ENDM

      MACRO updremove
        ld      a, h
        and     $07
        jp      nz, .upd
        ld      a, l
        sub     $20
        ld      l, a
        jr      c, .upd
        ld      a, h
        add     a, $08
        ld      h, a
.upd
      ENDM

      MACRO updpaint
        ld      a, h
        and     $07
        jp      nz, .upd
        ld      a, l
        add     a, $20
        ld      l, a
        jr      c, .upd
        ld      a, h
        sub     $08
        ld      h, a
.upd
      ENDM

      MACRO updclip
        ld      a, h
        and     $07
        jp      nz, .upd
        ld      de, $f820
        add     hl, de
.upd
      ENDM

      MACRO cellprint addition
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
        ld      de, addition
        add     hl, de
      ENDM

; Paolo Ferraris' shortest loader, then we move all the code to $8000
        output  engine48.bin
        org     $8000-22
begin   ld      de, $8000+endd-start-1
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        ld      hl, $5ccb+endd-begin-1
        ld      bc, endd-start
        lddr
        jp      $8000

start   ld      sp, $fe00
        call    init
        xor     a
        ld      ($5b00), a

; Main loop. This loop is executed when the main character exits over the edge of the screen
; so we must generate the whole screen (into embed code) according to the map
; First we calculate 12*y+x
main_loop
        call    do_sprites

        ld      b, 150
        ld      hl, $5b01
main0   inc     (hl)
        res     4, (hl)
        inc     l
        djnz    main0

        ld      b, 7
        ld      hl, ene0+4
main1   inc     l
        inc     l
        inc     l
        bit     0, (hl)
        jr      nz, main2
        dec     l
        dec     (hl)
        set     0, l
        jr      nz, main3
        inc     (hl)
        jr      main3
main2   dec     l
        inc     (hl)
        ld      a, $90
        cp      (hl)
        set     0, l
        jr      nz, main3
        dec     (hl)
main3   bit     1, (hl)
        jr      nz, main4
        dec     l
        dec     l
        dec     (hl)
        ld      a, $08
        cp      (hl)
        set     1, l
        jr      nz, main5
        set     1, (hl)
        jr      main5
main4   dec     l
        dec     l
        inc     (hl)
        ld      a, $e8
        cp      (hl)
        set     1, l
        jr      nz, main5
        res     1, (hl)
main5   inc     l
        djnz    main1
; Points HL and IX to vertical variables, BC with upper and lower limits, DE with input port and vertical map dimension
        ld      hl, ene0+2
        ld      ix, y
        ld      bc, $01a0
        ld      de, $fd | maph<<8
        call    key_process
        jr      c, main6
        cp      $03
        jr      nz, main_loop
; Do the same with horizontal stuff
        ld      bc, $02ee
        dec     l
        dec     ixl
        ld      de, $df | mapw<<8
        call    key_process
main6   jr      nc, main_loop
        ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l
        ld      ($5b00), a
        jp      main_loop

; This routine tests the keys and moves the main character
key_process
        ld      a, e
        in      a, ($fe)
        and     $03
        cp      $02
        jr      z, key2
        ret     nc
        dec     (hl)
        ld      a, (hl)
        cp      b
        ret     nc
        dec     (ix)
        jp      p, key1
        inc     (hl)
        inc     (ix)
        and     a
        ret
key1    ld      (hl), c
        ret
key2    ld      a, c
        inc     (hl)
        cp      (hl)
        ret     nc
        inc     (ix)
        ld      a, (ix)
        cp      d
        jr      nz, key3
        dec     (hl)
        dec     (ix)
        and     a
        ret
key3    ld      (hl), b
        ret

do_sprites
        ld      (drawi+1), sp
delspr  ld      sp, 0
        ld      de, syhi | sylo<<8
do1     ld      b, 9
do2     in      a, ($ff)
        cp      d
        jp      nz, do2
do3     in      a, ($ff)
        cp      e
do4     jr      z, do5
        djnz    do3
        jr      do1
do5     ld      a, delete_sprites-2-do4
        ld      (do4+1), a
        jp      draw_sprites

delete_sprites
        pop     bc
        ld      ixl, b
        inc     b
      IF smooth=0
        jr      z, update_complete
      ELSE
        jp      z, update_complete
      ENDIF
del1    pop     hl
del2    pop     bc
        ld      a, c
        and     %00001100
        jr      z, del5
        jp      po, del4
del3    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
        inc     l
        pop     de
        ld      (hl), e
      IF smooth=1
        updremove
      ENDIF
        dec     h
        ld      (hl), d
        dec     l
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del3
        jr      del6
del4    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
      IF smooth=1
        updremove
      ENDIF
        dec     h
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del4
        jr      del6
del5    updremove
        pop     de
        dec     h
        ld      (hl), e
      IF smooth=1
        updremove
      ENDIF
        dec     h
        ld      (hl), d
        djnz    del5
del6    ld      a, c
        cpl
        and     $03
        add     a, l
        sub     2
        ld      l, a
        dec     ixl
      IF smooth=0
        jr      nz, del2
      ELSE
        jp      nz, del2
      ENDIF
        pop     bc
        ld      ixl, b
        inc     b
      IF smooth=0
        jr      nz, del1
      ELSE
        jp      nz, del1
      ENDIF

;Complete background update
update_complete
        ld      hl, $5b00
        ld      a, (hl)
        cp      c
        jp      z, update_partial
        ld      (hl), c
        ld      sp, (drawi+1)
        ld      de, map
        ld      hl, mapend+$ff
        call    descom
        ld      a, scrh
        ld      (upba2-1), a
        ld      a, scrw
        ld      (upba3-1), a
        add     a, a
        cpl
        sub     $bf
        ld      (upba6+1), a
        ld      (upba7+1), a
        ld      bc, $5810-scrw
        ld      hl, $4010-scrw
upba1   exx
      IF  tmode=3
        xor     a
        ld      (upba4+1), a
      ELSE
        ld      bc, DMAP_BUFFER 
      ENDIF
        ld      a, 0
upba2   ex      af, af'
        ld      a, 0
upba3 IF  tmode=3
        ld      hl, upba4+1
        inc     (hl)
upba4   ld      hl, DMAP_BUFFER 
      ELSE
        ld      h, b
        ld      l, c
      ENDIF
        ld      l, (hl)
        ld      h, 0
      IF  tmode=0
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        add     hl, hl
        add     hl, hl
        ld      de, tiladdr
        add     hl, de
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
      ENDIF
      IF  tmode=1
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiladdr
        add     hl, de
        ld      (upba5+1), hl
        ld      de, 4
        add     hl, de
        ld      l, (hl)
        ld      h, d
        ld      de, tiladdr+tiles*5
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
      IF  tmode=2
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiladdr
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      sp, hl
        ex      de, hl
        ld      h, 0
        add     hl, hl
        add     hl, hl
        ld      de, tiladdr+tiles*33
        add     hl, de
        ld      (upba5+1), hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
      IF  tmode=3
        add     hl, hl
        ld      de, tiladdr
        add     hl, de
        ld      e, (hl)
        inc     hl
        ld      l, (hl)
        ld      h, 0
        ld      d, h
        add     hl, hl
        add     hl, hl
        ld      bc, tiladdr+tiles*2+bmaps*32
        add     hl, bc
        ld      (upba5+1), hl
        ex      de, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ld      bc, tiladdr+tiles*2
        add     hl, bc
        ld      sp, hl
        exx
        cellprint $f901
        cellprint $f91f
        cellprint $f901
        cellprint $f8e1
upba5   ld      sp, 0
      ENDIF
        ex      de, hl
        ld      h, b
        ld      l, c
        pop     bc
        ld      (hl), c
        inc     l
        ld      (hl), b
        ld      bc, $001f
        add     hl, bc
        pop     bc
        ld      (hl), c
        inc     l
        ld      (hl), b
        ld      bc, $ffe1
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
        exx
      IF  tmode<3
        inc     c
      ENDIF
        dec     a
        jp      nz, upba3
        exx
        ex      de, hl
upba6   ld      bc, 0
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
upba7   ld      de, 0
        ld      a, l
        add     a, a
        jr      nc, upba8
        jp      p, upba8
        ld      d, 7
upba8   add     hl, de
        exx
        ex      af, af'
        dec     a
        jp      nz, upba2
        jr      draw_sprites

;Partial background update
uppa1   ld      b, a
        and     $0f
        inc     a
        ld      (upba3-1), a
        add     a, a
        cpl
        sub     $bf
        ld      (upba6+1), a
        ld      (upba7+1), a
        ld      a, b
        rlca
        rlca
        rlca
        rlca
        and     $0f
        inc     a
        ld      (upba2-1), a
        ld      a, c
        and     $f0
        ld      b, $58 >> 2
        rla
        rl      b
        rla
        rl      b
        ld      (hl), l
        rl      c
        xor     c
        and     %11100001
        xor     c
      IF  scrw=15
        inc     a
      ELSE
        add     a, $10-scrw
      ENDIF
        ld      c, a
        ld      l, a
        ld      a, b
        rlca
        rlca
        rlca
        and     %01111000
        ld      h, a
        jp      upba1
update_partial
        dec     l
        ld      a, (hl)
        dec     l
        ld      c, (hl)
        sub     c
        jr      nc, uppa1

draw_sprites
        ld      a, 7
        ld      bc, staspr
draw1   ld      (drawh+1), a
        add     a, a
        add     a, a
        ld      l, a
        ld      h, ene0 >> 8
        ld      a, (hl)
        add     a, a
        jp      c, drawh
        add     a, a
        add     a, a
        inc     l
        ld      e, (hl)
      IF smooth=0
        res     0, e
      ENDIF
        inc     l
        xor     e
        and     $f8
        xor     e
      IF smooth=1
        add     a, a
      ENDIF
        ld      (draw2+2), a
        ld      a, e
        ld      (draw8+1), a
draw2   ld      sp, (sprites)
        pop     de
        ld      a, (hl)
  IF smooth=0
        and     $fe
    IF clipdn=0
      IF safeco=1
        cp      $98+1
        jr      c, draw3
        ld      a, $98
      ENDIF
draw3   add     a, d
    ELSE
      IF safeco=1
        cp      $a0+1
        jr      c, draw3
        ld      a, $a0
      ENDIF
draw3   add     a, d
        cp      $ea
        jp      nc, craw1
    ENDIF
    IF clipup=0
      IF safeco=1
        cp      $58
        jr      nc, draw6
        ld      a, $58
      ENDIF
    ELSE
        cp      $58
        jp      c, braw1
    ENDIF
  ELSE
    IF safeco=1
      IF clipdn=0
        cp      $98+1
        jr      c, draw3
        ld      a, $98
      ELSE
        cp      $a0+1
        jr      c, draw3
        ld      a, $a0
      ENDIF
    ENDIF
draw3   add     a, d
    IF clipup=0
      IF safeco=1
        cp      $30
        jr      nc, draw4
        ld      a, $30
      ENDIF
    ELSE
        cp      $30
        jp      c, braw1
    ENDIF
draw4   add     a, a
        jr      nc, draw6
      IF clipdn=1
        cp      $82
        jp      nc, craw1
      ENDIF
        ld      (draw5+1), a
draw5   ld      hl, (lookt+$100)
        jr      draw8
  ENDIF
draw6   ld      (draw7+1), a
draw7   ld      hl, (lookt)
draw8   ld      a, 0
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
        ld      a, e
        ld      (drawg+1), a
draw9   ex      af, af'
        pop     de
        ld      ixl, d
        ld      iyh, d
        ld      iyl, e
        ld      a, e
        and     $03
        add     a, l
        dec     a
        ld      l, a
        ld      a, e
        and     %00001100
      IF smooth=0
        jr      z, drawc
      ELSE
        jp      z, drawc
      ENDIF
        jp      po, drawb
drawa   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawa
        jr      drawd
drawb   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawb
        jr      drawd
drawc   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updpaint
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
        dec     ixl
        jr      nz, drawc
drawd   ld      a, iyh
drawe   dec     bc
        ld      (bc), a
        ld      a, iyl
        dec     c
        ld      (bc), a
        ex      af, af'
        dec     a
        jp      nz, draw9
drawf   ld      a, h
        dec     bc
        ld      (bc), a
        ld      a, l
        dec     c
        ld      (bc), a
drawg   ld      a, 0
        dec     bc
        ld      (bc), a
        dec     c
drawh   ld      a, 0
        dec     a
        jp      p, draw1
drawi   ld      sp, 0
        ld      (delspr+1), bc
        ret

    IF clipup=1
braw1   ld      (brawa+1), bc  
      IF smooth=1
        add     a, a
      ENDIF
        ld      (braw2+1), a
braw2   ld      hl, (lookt)
        rrca
        cpl
      IF smooth=0
        sub     $d3
      ELSE
        sub     $ce
        rra
      ENDIF
        ld      ixh, a
        ld      a, (draw8+1)
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
        ld      a, e
        ex      de, hl
braw3   ex      af, af'
        pop     bc
        ld      a, c
        and     $03
        add     a, e
        dec     a
        ld      e, a
        ld      a, c
        and     %00001100
        jr      z, braw6
        jp      po, braw5
braw4   ld      hl, 12
        add     hl, sp
        ld      sp, hl
        inc     d
        inc     d
        dec     ixh
        jr      z, braw8
        djnz    braw4
        jr      braw7
braw5   ld      hl, 8
        add     hl, sp
        ld      sp, hl
        inc     d
        inc     d
        dec     ixh
        jr      z, braw8
        djnz    braw5
        jr      braw7
braw6   pop     hl
        pop     hl
        inc     d
        inc     d
        dec     ixh
        jr      z, braw8
        djnz    braw6
braw7   ex      af, af'
        dec     a
        jp      nz, braw3
        ld      bc, (brawa+1)
        jp      drawh
braw8   ld      a, e
        add     a, $20
        ld      e, a
        djnz    braw9
        ex      de, hl
        ld      bc, (brawa+1)
        ex      af, af'
        dec     a
        ld      (drawg+1), a
        jp      nz, draw9
        jp      drawh
braw9   ld      ixl, b
        ld      iyh, b
        ld      iyl, c
        ex      af, af'
        ld      (drawg+1), a
        ex      af, af'
        ex      de, hl
        ld      a, c
brawa   ld      bc, 0
        and     %00001100
        jp      z, drawc
        jp      po, drawb
        jp      drawa
    ENDIF

    IF clipdn=1
craw1   ld      (craw2+1), a
      IF smooth=0
craw2   ld      hl, (lookt)
        cpl
        sub     $06
      ELSE
craw2   ld      hl, (lookt+$100)
        rrca
        cpl
        sub     $af
      ENDIF
        rra
        ld      ixh, a
        ld      a, (draw8+1)
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
        ld      a, e
        ld      (drawg+1), a
craw3   ex      af, af'
        pop     de
        ld      ixl, d
        ld      iyh, d
        ld      iyl, e
        ld      a, e
        and     $03
        add     a, l
        dec     a
        ld      l, a
        ld      a, e
        and     %00001100
        jp      z, craw6
        jp      po, craw5
craw4   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updclip
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updclip
        dec     ixh
        jp      z, craw8
        dec     ixl
        jr      nz, craw4
      IF smooth=0
        jr      craw7
      ELSE
        jp      craw7
      ENDIF
craw5   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updclip
      ENDIF
        pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        dec     l
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updclip
        dec     ixh
        jp      z, craw8
        dec     ixl
        jr      nz, craw5
        jr      craw7
craw6   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
      IF smooth=1
        updclip
      ENDIF
        pop     de
        ld      a, (hl)
        dec     c
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updclip
        dec     ixh
        jp      z, craw8
        dec     ixl
        jr      nz, craw6
craw7   ld      a, iyh
        dec     bc
        ld      (bc), a
        ld      a, iyl
        dec     c
        ld      (bc), a
        ex      af, af'
        dec     a
        jp      nz, craw3
        jp      drawf
craw8   ld      a, 1
        ex      af, af'
        ld      e, a
        ld      a, (drawg+1)
        sub     e
        inc     a
        ld      (drawg+1), a
        ld      a, iyh
        sub     ixl
        inc     a
        jp      drawe
    ENDIF

init    ld      (ini7+1), sp
        ld      a, 20
        ld      de, $0020
        ld      b, d
        ld      c, d
        ld      hl, $5801
ini1    ld      sp, hl
        push    bc
        add     hl, de
        dec     a
        jp      p, ini1
        ld      ($5b00), a
        ld      ($5bfe), a
        ld      sp, $50a0
        ld      de, sylo | syhi<<8
        ld      h, e
        ld      l, e
        ld      b, 10
ini2    push    de
        djnz    ini2
        ld      b, 6
ini3    push    hl
        djnz    ini3
        ld      sp, $51a0
        push    de
        push    de
        push    de
        ld      e, d
        ld      b, 13
ini4    push    de
        djnz    ini4
        ld      sp, $52a0
        ld      b, 16
ini5    push    de
        djnz    ini5
        ld      sp, $5aa0
        ld      b, 16
ini6    push    de
        djnz    ini6
        ld      a, do5-2-do4
        ld      (do4+1), a
ini7    ld      sp, 0
        ret

; Some variables
x       db      0
y       db      0

; Look up table, from Y coordinate to memory address, 256 byte aligned
        block   $9bfe-$
staspr  defb    $ff, $ff

; Enemy table. For each item: X, Y, direction and sprite number, 256 byte aligned
        block   $9c00-$
ene0    db      $00, $44, $12, 0
        db      $88, $60, $60, %10
        db      $89, $a8, $48, %11
        db      $8a, $22, $02, %01
        db      $8b, $d0, $6e, %10
        db      $8c, $b6, $34, %11
        db      $8d, $32, $32, %01
        db      $8e, $52, $5e, %00

        block   $9c50-$
lookt   incbin  table.bin

; Sprites file. Generated externally with GfxBu.c from sprites.png
        block   $9e00-$
sprites incbin  sprites.bin

; Decompressor code
descom  include descom15.asm

; Tiles file. Generated externally with tilegen.c from tiles.png
tiladdr incbin  tiles.bin

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
mapend
endd