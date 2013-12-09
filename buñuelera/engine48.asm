        DEFINE  mapw  12              ; map width is 12
        DEFINE  maph  2               ; map height is 2, our demo has 12x2 screens
        DEFINE  scrw  12              ; screen width is 12
        DEFINE  scrh  8               ; screen height is 8, our window is 12x8 tiles (exactly half of the screen area)
        DEFINE  DMAP_BITSYMB 5        ; these 3 constants are for the map decompressor
        DEFINE  DMAP_BITHALF 1        ; BITSYMB and BITHALF declares 5.5 bits per symbol (16 tiles with 5 bits and 32 with 6 bits)
        DEFINE  DMAP_BUFFER  $5b01    ; BUFFER points to where is decoded the uncompressed screen

; This macro multiplies two 8 bits numbers (second one is a constant)
; Factor 1 is on E register, Factor 2 is the constant data (macro parameter)
; Result is returned on HL

    MACRO   mult8x8 data
        ld      hl, 0
        ld      d, l
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

; Paolo Ferraris' shortest loader, then we move all the code to $8000
        output  engine48.bin
        org     $8000-22
ini     ld      de, $8000+fin-empe-1
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
aki     ld      hl, $5ccb+fin-ini-1
        ld      bc, fin-empe
        lddr
        jp      $8000

; First we clear the 2 upper thirds of the screen (our game area)
; Note that ink=paper=0, this is to hide the sprites over the edges

empe    ld      hl, $5800
        ld      de, $5801
        ld      bc, $01ff
        ld      (hl), l
        ldir
        ld      hl, $5000
        ld      de, $5001
        ld      c, $1f
        ld      (hl), $66
        ldir
        ld      hl, $5100
        ld      de, $5101
        ld      c, $1f
        ld      (hl), $99
        ldir
        ld      hl, $5a00
        ld      de, $5a01
        ld      c, $5
        ld      (hl), $66
        ldir
        ld      hl, $5a06
        ld      de, $5a07
        ld      c, $19
        ld      (hl), $99
        ldir

; These self modifying code saves the correct value of the stack (out an into the routine)
        ld      (paint3+1), sp
        push    af
        ld      (paint4+1), sp

; Main loop. This loop is executed when the main character exits over the edge of the screen
; so we must generate the whole screen (into embed code) according to the map
; First we calculate 12*y+x
bucl    ld      a, (y)
        ld      e, a
        mult8x8 mapw
        ld      a, (x)
        add     a, l

; Pass the calculated actual screen (from 0 to 23) to the decompressor (after this we have the actual screen at $5801)
        call    descom

; Points to screen point where we paint the tiles
        ld      hl, $4010-scrw
        ld      bc, $5810-scrw
        exx
; BC points to the uncompressed buffer
        ld      bc, DMAP_BUFFER 
; The count of tiles is saved in A and A' registers
        ld      a, scrh
paint1  ex      af, af'
        ld      a, scrw
; Read the tile number in HL
paint2  ld      h, b
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
        jp      nz, paint2
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
        jr      z, pain25
        ld      de, $0700
        add     hl, de
pain25  exx
        ex      af, af'
; Repeat 8 times (8 lines of tiles)
        dec     a
        jp      nz, paint1

;raca    ld      b, 32
;raca1   in      a, ($ff)
;        inc     a
;        jr      nz, raca
;        djnz    raca1

; Second main loop, in this case we only redraw the actual screen for erasing all the sprites
; Wait to cycle 14400 (approx), when the electron beam points the first non-border pixel
repet   ld      de, $6699
repet1  ld      b, 9
repet2  in      a, ($ff)      ;11
        cp      d             ;4
        jp      nz, repet2    ;10   25
repet3  in      a, ($ff)      ;11
        cp      e             ;4
        jr      z, repet4     ;7
        djnz    repet3        ;13   35
        jr      repet1
repet4

;11110000111100001111000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000
;abcd    ijkl    qrst    y       h       p       x       g       o       w       f       n       v       e       m       u       
;                         c       k       s       1       9ab     hij     pqr     xy0     678    defg    lmno    tuvw    2345    
;10100000101000001010000011110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000

; Restores the stack, we need it for do CALLs
paint3  ld      sp, 0
; Paint the main character sprite
        ld      bc, (corx)
        xor     a
        call    put_sprite
; Points HL and IX to vertical variables, BC with upper and lower limits, DE with input port and vertical map dimension
        ld      hl, cory
        ld      ix, y
        ld      bc, $026e
        ld      de, $fd | maph<<8
        call    key_process
        jr      c, tbucl
        cp      $03
        jr      nz, pact
; Do the same with horizontal stuff
        ld      bc, $14dc
        dec     l
        dec     ixl
        ld      de, $df | mapw<<8
        call    key_process
; If main character croses an edge jump to bucl (main loop), else jump to repet (2nd main loop)
tbucl   jp      c, bucl
pact    jp      repet

; Paint a sprite
; A register is the sprite number (must be multiple of 8)
; BC register is X and Y coordinates
put_sprite:
        xor     c
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

; This routine tests the keys and moves the main character
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

; Some variables
x       db      0
y       db      0
corx    db      32
cory    db      2

; Look up table, from Y coordinate to memory address, 256 byte aligned
        block   $9c00-$
lookt   incbin  table.bin

; Enemy table. For each item: X, Y, direction and sprite number, 256 byte aligned
        block   $9d00-$
ene0    db      $42, $12, %01, 0<<3 | $40
        db      $60, $60, %10, 1<<3 | $40
        db      $a8, $48, %11, 2<<3 | $40
        db      $22, $02, %01, 3<<3 | $40
        db      $d0, $6e, %10, 4<<3 | $40
        db      $b6, $34, %11, 5<<3 | $40
        db      $32, $32, %01, 6<<3 | $40
        db      $52, $5e, %00, 7<<3 | $40
        db      $72, $04, %11, $38
        db      $12, $42, %01, 0<<3 | $40
        db      $40, $60, %10, 1<<3 | $40
        db      $a8, $10, %11, 2<<3 | $40

; Sprites file. Generated externally with GfxBu.c from sprites.png
        block   $9e00-$
sprites incbin  sprites.bin

; Decompressor code
descom  include descom12.asm

; Tiles file. Generated externally with tilegen.c from tiles.png
tiles   incbin  tiles.bin

; Map file. Generated externally with TmxCompress.c from map.tmx
map     incbin  map_compressed.bin
fin