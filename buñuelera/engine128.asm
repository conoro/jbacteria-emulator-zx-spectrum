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
        DEFINE  smooth  1
        DEFINE  clipup  1
        DEFINE  clipdn  1
        DEFINE  safeco  1
        DEFINE  initregs
        DEFINE  port    $5b97
        DEFINE  sprites $fe00
        DEFINE  tiladdr $5c50
        DEFINE  enems   $5c00
      IF  smooth=0
        DEFINE  final   $fd50
      ELSE
        DEFINE  final   $fc21
      ENDIF

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
        jp      nz, .upd&$ffff
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
        jp      nz, .upd&$ffff
        ld      de, $f820
        add     hl, de
.upd
      ENDM

      MACRO cellprint addition
        pop     de
        ld      (hl), e
        set     7, h
        ld      (hl), e
        inc     h
        ld      (hl), d
        res     7, h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        set     7, h
        ld      (hl), e
        inc     h
        ld      (hl), d
        res     7, h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        set     7, h
        ld      (hl), e
        inc     h
        ld      (hl), d
        res     7, h
        ld      (hl), d
        inc     h
        pop     de
        ld      (hl), e
        set     7, h
        ld      (hl), e
        inc     h
        ld      (hl), d
        res     7, h
        ld      (hl), d
        ld      de, addition
        add     hl, de
      ENDM

      MACRO ndjnz addr
        defb    $10, addr-.ndj
.ndj
      ENDM

; Paolo Ferraris' shortest loader, then we move all the code to $8000
        output  engine128.bin
        org     staspr+final-mapend-$
staspr  defb    $ff, $ff, $ff
do_sprites
        ld      (drawi+1&$ffff), sp
        ld      hl, flag&$ffff
        inc     (hl)
        xor     a
        ei
do1     cp      (hl)
        jr      nz, do1
        ld      bc, $7ffd
        ld      a, (port&$ffff)
        xor     $80
        ld      (port&$ffff), a
        ld      a, $1f
        jp      m, do15
        ld      a, $10
do15    out     (c), a
do2     jr      delete_sprites
do3     ld      a, delete_sprites-2-do2&$ff
        ld      (do2+1), a
        jp      draw_sprites&$ffff

delete_sprites
        ld      sp, 0
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
        ld      a, (port)
        rla
        jp      nc, draw_sprites&$ffff
        ld      hl, $5b00
        ld      a, (hl)
        cp      c
        jp      z, update_partial&$ffff
        ld      (hl), c
        ld      de, map&$ffff
        ld      hl, mapend+$ff&$ffff
desc1   sbc     hl, bc
        ex      de, hl
        ld      c, (hl)
        ex      de, hl
        inc     de
        dec     a
        jp      p, desc1

        ld      bc, $7ffd
        ld      a, $18
        out     (c), a
        xor     a
        ld      (do2+1), a
        ld      sp, (drawi+1&$ffff)
        ld      a, $1f
        out     (c), a
        
        ld      de, DMAP_BUFFER+149
        ld      b, $80          ; marker bit
desc2   ld      a, 256 >> DMAP_BITSYMB
desc3   call    gbit3&$ffff     ; load DMAP_BITSYMB bits (literal)
        jr      nc, desc3
      IF DMAP_BITHALF=1
        rrca                    ; half bit implementation (ie 48 tiles)
        call    c, gbit1&$ffff
      ELSE
        and     a
      ENDIF
        ld      (de), a         ; write literal
desc4   dec     e               ; test end of file (map is always 150 bytes)
        jr      z, desca
        call    gbit3&$ffff     ; read one bit
        rra
        jr      nc, desc2       ; test if literal or sequence
        push    de              ; if sequence put de in stack
        ld      a, 1            ; determine number of bits used for length
desc5   call    nc, gbit3&$ffff ; (Elias gamma coding)
        and     a
        call    gbit3&$ffff
        rra
        jr      nc, desc5       ; check end marker
        inc     a               ; adjust length
        ld      c, a            ; save lenth to c
        xor     a
        ld      de, 15          ; initially point to 15
        call    gbit3&$ffff     ; get two bits
        call    gbit3&$ffff
        jr      z, desc8        ; 00 = 1
        dec     a
        call    gbit3&$ffff
        jr      z, desc9        ; 010 = 15
        bit     2, a
        jr      nz, desc6
        add     a, $7c          ; [011, 100, 101] xx = from 2 to 13
        dec     e
desc6   dec     e               ; [110, 111] xxxxxx = 14 and from 16 to 142
desc7   call    gbit3&$ffff
        jr      nc, desc7
        jr      z, desc9
        add     a, e
desc8   inc     a
        ld      e, a
desc9   ld      a, b            ; save b (byte reading) on a
        ld      b, d            ; b= 0 because lddr moves bc bytes
        ex      (sp), hl        ; store source, restore destination
        ex      de, hl          ; HL = destination + offset + 1
        add     hl, de          ; DE = destination
        lddr
        pop     hl              ; restore source address (compressed data)
        ld      b, a            ; restore b register
        inc     e               ; prepare test of end of file
        jr      desc4           ; jump to main loop
desca   ld      a, scrh
        ld      (upba2-1), a
        ld      a, scrw
        ld      (upba3-1), a
        add     a, a
        cpl
        sub     $bf
        ld      (upba6+1&$ffff), a
        ld      (upba7+1&$ffff), a
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
        set     7, h
        ld      (hl), c
        inc     l
        ld      (hl), b
        res     7, h
        ld      (hl), b
        ld      bc, $001f
        add     hl, bc
        pop     bc
        ld      (hl), c
        set     7, h
        ld      (hl), c
        inc     l
        ld      (hl), b
        res     7, h
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
        jp      p, upba8&$ffff
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
        ld      bc, staspr+1&0xfffe
draw1   ld      (drawh+1&$ffff), a
        add     a, a
        add     a, a
        ld      l, a
        ld      h, enems >> 8
        ld      a, (hl)
        add     a, a
        jp      c, drawh&$ffff
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
        ld      (draw2+2&$ffff), a
        ld      a, e
        ld      (draw8+1&$ffff), a
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
        jp      nc, craw1&$ffff
    ENDIF
    IF clipup=0
      IF safeco=1
        cp      $58
        jr      nc, draw6
        ld      a, $58
      ENDIF
    ELSE
        cp      $58
        jp      c, braw1&$ffff
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
        cp      $58
        jr      nc, draw4
        ld      a, $58
      ENDIF
    ELSE
        cp      $58
        jp      c, braw1&$ffff
    ENDIF
draw4   add     a, a
        jr      nc, draw6
      IF clipdn=1
        cp      $d2
        jp      nc, craw1&$ffff
      ENDIF
        ld      (draw5+1), a
draw5   ld      hl, (lookt+$100&$ffff)
        jr      draw8
  ENDIF
draw6   ld      (draw7+1&$ffff), a
draw7   ld      hl, (lookt&$ffff)
draw8   ld      a, 0
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
      ld      a, (port)
      or      h
      ld      h, a
        ld      a, e
        ld      (drawg+1&$ffff), a
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
        jp      z, drawc&$ffff
      ENDIF
        jp      po, drawb&$ffff
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
        ld      (delete_sprites+1), bc
        ld      bc, $7ffd
        ld      a, (port)
        rla
        ld      a, $18
        jr      c, drawhh
        ld      a, $10
drawhh  out     (c), a
drawi   ld      sp, 0
        ret

    IF clipup=1
braw1   ld      (brawa+1&$ffff), bc  
      IF smooth=1
        add     a, a
      ENDIF
        ld      (braw2+1&$ffff), a
braw2   ld      hl, (lookt&$ffff)
        rrca
        cpl
      IF smooth=0
        sub     $d3
      ELSE
        sub     $a6
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
      ld      a, (port)
      or      h
      ld      h, a
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
        jp      po, braw5&$ffff
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
        ld      bc, (brawa+1&$ffff)
        jp      drawh
braw8   ld      a, e
        add     a, $20
        ld      e, a
        ndjnz   braw9
        ex      de, hl
        ld      bc, (brawa+1&$ffff)
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
craw1   ld      (craw2+1&$ffff), a
      IF smooth=0
craw2   ld      hl, (lookt&$ffff)
        cpl
        sub     $06
      ELSE
craw2   ld      hl, (lookt+$100&$ffff)
        rrca
        cpl
        sub     $87
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
      ld      a, (port)
      or      h
      ld      h, a
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
        jp      z, craw6&$ffff
        jp      po, craw5&$ffff
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
        jp      z, craw8&$ffff
        dec     ixl
        jr      nz, craw4
      IF smooth=0
        jr      craw7
      ELSE
        jp      craw7&$ffff
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
        jp      z, craw8&$ffff
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
        jp      z, craw8&$ffff
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

init    ld      (ini2+1&$ffff), sp
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
        xor     a
        ld      (do2+1), a
        ld      (port), a
        ld      hl, ini3&$ffff
        ld      de, $4000
        ld      c, inif-ini3
        ldir
        ld      hl, $db00
        call    $4000
;        ld      hl, $ffff
;        ld      ($feff), hl
;        ld      ($7ffe), hl
;        ld      bc, $7ffd
;        ld      a, $17
;        out     (c), a
;        ld      ($fffe), hl
;        ld      a, $10
;        out     (c), a
        ld      a, $fe
        ld      i, a
        im      2
ini2    ld      sp, 0
        ret

ini3    ld      bc, $ff+ini3-inif&$ff
        ldir
        ld      bc, $7ffd
        ld      a, $17
        out     (c), a
        ld      bc, $ff+ini3-inif&$ff
        ex      de, hl
        dec     e
        dec     l
        lddr
        inc     e
        inc     l
        ex      de, hl
        ld      c, $ff+ini3-inif&$ff
        add     hl, bc
        ld      bc, $7ffd
        ld      a, $10
        out     (c), a
        jr      nc, ini3
        ret
inif

      IF DMAP_BITHALF=1
gbit1   sub     $80 - (1 << DMAP_BITSYMB - 2)
        defb    $da             ; second part of half bit implementation
      ENDIF
gbit2   ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbit3   rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
mapend
      IF smooth=0
        block   $fd50-$&$ffff
lookt   incbin  table0.bin
        block   $fe80-$&$ffff
        incbin  dzx7b_rcs_0.bin
        defb    $ff
      ELSE
        block   $fc21-$&$ffff
        incbin  dzx7b_rcs_1.bin
lookt   incbin  table1.bin
      ENDIF
        block   $ff00-$&$ffff
        defb    $ff
        block   $fff1-$&$ffff
frame   jp      do_sprites
        push    af
        xor     a
        ld      (flag&$ffff), a
        pop     af
        ret
flag    defb    0
tinit   jp      init
        defb    $18


