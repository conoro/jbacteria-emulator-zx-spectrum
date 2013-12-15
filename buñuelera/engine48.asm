        DEFINE  mapw  12              ; map width is 12
        DEFINE  maph  2               ; map height is 2, our demo has 12x2 screens
        DEFINE  scrw  15              ; screen width is 12
        DEFINE  scrh  10              ; screen height is 8, our window is 12x8 tiles (exactly half of the screen area)
        DEFINE  DMAP_BITSYMB 5        ; these 3 constants are for the map decompressor
        DEFINE  DMAP_BITHALF 1        ; BITSYMB and BITHALF declares 5.5 bits per symbol (16 tiles with 5 bits and 32 with 6 bits)
        DEFINE  DMAP_BUFFER  $5b01    ; BUFFER points to where is decoded the uncompressed screen

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

; First we clear the screen
; Note that ink=paper=0, this is to hide the sprites over the edges
start   ld      hl, $5800
        ld      de, $5801
        ld      bc, $02ff
        ld      (hl), l
        ldir
; These self modifying code saves the correct value of the stack
        ld      (drawd+1), sp
        pop     af
; Print the background
        call    print_screen

; This is the main loop
main_loop
        call    do_sprites
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
        ld      bc, $028e
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
; If main character croses an edge call to print_screen, else jump to main_loop
main6   call    c, print_screen
        jr      main_loop

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
key3    ld      (hl), 0
        ret

print_screen
        ld      (prin4+1), sp
        ld      a, do3-2-do2
        ld      (do2+1), a
        ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l
; Pass the calculated actual screen (from 0 to 23) to the decompressor (after this we have the actual screen at $5801)
        call    descom
; Points to screen point where we paint the tiles
        ld      hl, $4090-scrw
        ld      bc, $5890-scrw
        exx
; BC points to the uncompressed buffer
        ld      bc, DMAP_BUFFER 
; The count of tiles is saved in A and A' registers
        ld      a, scrh
prin1   ex      af, af'
        ld      a, scrw
; Read the tile number in HL
prin2   ld      h, b
        ld      l, c
        ld      l, (hl)
        ld      h, 0
; HL= HL*36
        add     hl, hl
        add     hl, hl
        ld      d, h
        ld      e, l
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, de
        ld      de, tiles
        add     hl, de
        ld      sp, hl
; Now SP points to the 36 bytes of the tile that we must to print
        exx
; Prints the first cell (there are 4 cells to print)
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
; Prints the second cell 
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
; Prints the third cell 
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
; Prints the fourth cell 
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
; Now we must print the 4 bytes of the attributes
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
; This code updates the attr pointer to the next position
        ld      bc, $ffe1
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
        exx
        inc     bc
; Repeat 12 times (12 tiles per line)
        dec     a
        jp      nz, prin2
        exx
        ex      de, hl
; When a line of tiles is printed, the attr pointer must point to the first row on the next line
        ld      bc, $40-(scrw*2)
        add     hl, bc
        ld      b, h
        ld      c, l
        ex      de, hl
; Do the same with the other pointer
        ld      de, $40-(scrw*2)
        add     hl, de
        bit     0, h
        jr      z, prin3
        ld      de, $0700
        add     hl, de
prin3   exx
        ex      af, af'
; Repeat 8 times (8 lines of tiles)
        dec     a
        jp      nz, prin1
prin4   ld      sp, 0
        ret

do_sprites
        ld      b, 20
do1     in      a, ($ff)
        inc     a
        jr      nz, do_sprites
        djnz    do1
do2     jr      delete_sprites
do3     ld      a, delete_sprites-2-do2
        ld      (do2+1), a
        jp      draw_sprites

delete_sprites
        ld      sp, 0
        pop     bc
        ld      ixl, b
del1    pop     hl
del2    pop     bc
        bit     3, c
        jr      z, del4
del3    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
        inc     l
        pop     de
        ld      (hl), e
        updremove
        dec     h
        ld      (hl), d
        dec     l
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del3
        jr      del9
del4    bit     2, c
        jr      z, del8
del5    updremove
        pop     de
        dec     h
        ld      (hl), e
        inc     l
        ld      (hl), d
        updremove
        dec     h
        pop     de
        ld      (hl), e
        dec     l
        ld      (hl), d
        djnz    del5
        jr      del9
del6    ld      (del7+1), a
del7    ld      hl, (lookt+$100)
        jr      draw4
del8    updremove
        pop     de
        dec     h
        ld      (hl), e
        updremove
        dec     h
        ld      (hl), d
        djnz    del8
del9    ld      a, c
        cpl
        and     $03
        add     a, l
        sub     2
        ld      l, a
        dec     ixl
        jp      nz, del2
        pop     bc
        ld      ixl, b
        inc     b
        jp      nz, del1

draw_sprites
        ld      a, 7
        ld      bc, lookt-2
draw1   ld      (drawc+1), a
        add     a, a
        add     a, a
        add     a, $40
        ld      l, a
        ld      h, ene0 >> 8
        ld      a, (hl)
        add     a, a
        jp      c, drawc
        add     a, a
        add     a, a
        inc     l
        ld      e, (hl)
        inc     l
        xor     e
        and     $f8
        xor     e
        add     a, a
        ld      (draw2+2), a
        ld      a, e
        ld      (draw4+1), a
draw2   ld      sp, (sprites)
        pop     de
        ld      a, (hl)
        add     a, d
        add     a, a
        jr      c, del6
        ld      (draw3+1), a
draw3   ld      hl, (lookt)
draw4   ld      a, 0
        and     $f8
        rra
        rra
        rra
        or      l
        ld      l, a
        ld      a, e
        ld      (drawb+1), a
draw5   ex      af, af'
        pop     de
        ld      ixl, d
        ld      iyh, d
        ld      iyl, e
        ld      a, e
        and     $03
        add     a, l
        dec     a
        ld      l, a
        bit     3, e
        jr      z, draw7
draw6   pop     de
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
        updpaint
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
        jr      nz, draw6
        jr      drawa
draw7   bit     2, e
        jr      z, draw9
draw8   pop     de
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
        updpaint
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
        jr      nz, draw8
        jr      drawa
draw9   pop     de
        ld      a, (hl)
        dec     bc
        ld      (bc), a
        and     d
        or      e
        ld      (hl), a
        inc     h
        updpaint
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
        jr      nz, draw9
drawa   ld      a, iyh
        dec     bc
        ld      (bc), a
        ld      a, iyl
        dec     c
        ld      (bc), a
        ex      af, af'
        dec     a
        jp      nz, draw5
        ld      a, h
        dec     bc
        ld      (bc), a
        ld      a, l
        dec     c
        ld      (bc), a
drawb   ld      a, 0
        dec     bc
        ld      (bc), a
        dec     c
drawc   ld      a, 0
        dec     a
        jp      p, draw1
drawd   ld      sp, 0
        ld      (delete_sprites+1), bc
        ret

; Some variables
x       db      0
y       db      0

; Look up table, from Y coordinate to memory address, 256 byte aligned
        block   $9bfe-$
        defb    $ff, $ff
lookt   incbin  table.bin

; Enemy table. For each item: X, Y, direction and sprite number, 256 byte aligned
        block   $9d40-$
ene0    db      $00, $42, $11, 0
        db      $08, $60, $60, %10
        db      $09, $a8, $48, %11
        db      $0a, $22, $02, %01
        db      $0b, $d0, $6e, %10
        db      $0c, $b6, $34, %11
        db      $0d, $32, $32, %01
        db      $04, $52, $5e, %00

; Sprites file. Generated externally with GfxBu.c from sprites.png
        block   $9e00-$
sprites incbin  sprites.bin

; Decompressor code
descom  include descom15.asm

; Tiles file. Generated externally with tilegen.c from tiles.png
tiles   incbin  tiles.bin

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
mapend
endd