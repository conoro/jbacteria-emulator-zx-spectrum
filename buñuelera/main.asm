        DEFINE  mapw  12              ; map width is 12
        DEFINE  maph  2               ; map height is 2, our demo has 12x2 screens
        DEFINE  frame $fff1
        DEFINE  init  $fffc
        DEFINE  enems $5c00
      

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

        org     $8000
        output  main.bin
        ld      sp, $e0d2-$1a0
        ld      hl, ene0
        ld      de, enems
        ld      bc, 32
        ldir
        call    init
        xor     a
        ld      ($5b00), a

; This is the main loop
main_loop
        call    frame

aaaaa   ld      a, 0
        inc     a
        jr      nz, mmmmm
        ld      b, 150
        ld      hl, $5b01
main0   inc     (hl)
        res     4, (hl)
        inc     l
        djnz    main0
mmmmm   ld      (aaaaa+1), a

        ld      b, 7
        ld      hl, enems+4
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
        ld      hl, enems+2
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

; Some variables
x       db      0
y       db      0

ene0    db      $00, $42, $11, 0
        db      $08, $60, $60, %10
        db      $09, $a8, $48, %11
        db      $0a, $22, $02, %01
        db      $0b, $d0, $6e, %10
        db      $0c, $b6, $34, %11
        db      $0d, $32, $32, %01
        db      $04, $52, $5e, %00
