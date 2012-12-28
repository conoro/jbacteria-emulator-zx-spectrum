;Exomizer 2 Z80 decoder
; by Metalbrain 
;
; optimized by Antonio Villena and Urusergi (180 bytes)
;
; compression algorithm by Magnus Lind

;input:         hl=compressed data start
;               de=uncompressed destination start
;
;               you may change exo_mapbasebits to point to any free buffer

deexo:          ld      iy, exo_mapbasebits-16
                ld      a, (hl)
                dec     hl
                push    de
                ld      b, 52
                cp      a
exo_initbits:   ld      c, 16
                jr      nz, exo_get4bits
                ld      ixl, c
                ld      de, 1           ;DE=b2
exo_get4bits:   srl     a               ;get one bit
                call    z, exo_getbit
                rl      c
                jr      nc, exo_get4bits
                inc     c
                ld      (iy+16), c      ;bits[i]=b1
                push    hl
                ld      hl, 1
                defb    48              ;3 bytes nop (JP NC)
exo_setbit:     add     hl, hl
                dec     c
                jr      nz, exo_setbit
                ld      (iy+68), e
                ld      (iy+120), d     ;base[i]=b2
                add     hl, de
                ex      de, hl
                pop     hl
                inc     iy
                dec     ixl
                djnz    exo_initbits
                pop     de
                jr      exo_mainloop
gbg:            ld      a, (hl)
                dec     hl
exo_getbits:    rr      a               ;get one bit
                jr      z, gbg
exo_res_carry:  rl      e
                rl      d
                djnz    exo_getbits
                ret     nc
                ld      b, d
                ld      c, e
                pop     de
exo_literalcopy:lddr
exo_mainloop:   inc     c
                srl     a               ;get one bit
                call    z, exo_getbit   ;literal?
                jr      c, exo_literalcopy
                ld      c, 240-1
exo_getindex:   srl     a               ;get one bit
                call    z, exo_getbit
                inc     c
                jr      nc,exo_getindex
                jp      m, exo_continue
                ret     z
                push    de
                ld      d, b
                ld      e, b
                ld      b, 17
                defb    24
exo_continue:   push    de
                ld      d, b
                ld      iy, exo_mapbasebits-256
                call    exo_getpair
                push    de
                ld      bc, 512+32      ;2 bits, 48 offset
                dec     d
                jp      p, exo_dontgo
                dec     e
                jr      z, exo_goforit
                dec     e               ;2?
exo_dontgo:     ld      bc, 1024+16     ;4 bits, 32 offset
                jr      z, exo_goforit
                ld      c, 0            ;16 offset
                ld      e, c
exo_goforit:    ld      d, e            ;get D bits in BC
                call    exo_getbits
                ld      iy, exo_mapbasebits
                add     iy, de
                call    exo_getpair
                pop     bc
                ex      (sp), hl
                ex      de, hl
                add     hl, de
                lddr
                pop     hl
                jr      exo_mainloop    ;Next!

exo_getpair:    add     iy, bc
                ld      e, d
                ld      b, (iy+16)
                dec     b
                call    nz, exo_getbits
                ex      de, hl
                ld      c, (iy+68)
                ld      b, (iy+120)
                add     hl, bc          ;Always clear C flag
                ex      de, hl
                ret

exo_getbit:     ld      a, (hl)
                dec     hl
                rra
                ret

exo_mapbasebits:defs    156             ;tables for bits, baseL, baseH