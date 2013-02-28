        define  CADEN   $5800-6
        output  pokemon.bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $0066, 10
L0066   ld      (CADEN-2), sp
        ld      sp, CADEN-13-1 ;sobra 1 byte
        jp      poke
L0066f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    poke, pokef-poke
        org     $38b5
poke    push    af
        push    bc
        ld      bc, 11
        push    de
        push    hl
        push    iy
        ld      iy, $5c3a
        ex      af, af'
        push    af
        ld      hl, $5c78
        ld      sp, $5700
        ld      e, (hl)
        inc     l
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, $8f
        ld      e, (hl)
        ld      (hl), $39
        inc     l
        ld      d, (hl)
        ld      (hl), b
        push    de
        inc     l
        ld      a, i
        ld      e, a
        ld      a, $18
        ld      i, a
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, $3b
        ld      e, (hl)
        ld      (hl), 8
        ld      l, $41
        ld      d, (hl)
        ld      (hl), b
        push    de
        ld      l, b
        ld      de, CADEN-13
        ldir
        ex      de, hl
        ld      hl, pok19+10
        ld      c, e
        dec     e
        lddr
pokm1   push    bc
        xor     a
        ei
        defb    $c2, $ff, $ff
pok01   ld      hl, CADEN
pok02   ld      (hl), 1
        inc     l
        jr      nz, pok02
        or      a
pok03   ld      de, CADEN+1
        jr      z, pok04
        ld      (de), a
        ld      l, CADEN & $ff
        ld      (hl), 2
pok04   ld      hl, $4000
        ld      b, $5
pok05   ld      a, (de)
        push    de
        ex      de, hl
        ld      l, a
        ld      h, 7
        add     hl, hl
        inc     h
        add     hl, hl
        add     hl, hl
        ex      de, hl
        call    $0B99
        pop     de
        inc     de
        djnz    pok05
        ld      hl, $5c3b
pok06   bit     5, (hl)
        jr      z, pok06
        res     5, (hl)
        ld      a, ($5C08)
        ld      hl, CADEN
        ld      c, (hl)
        cp      13
        jr      z, pok14
        jr      nc, pok07
        dec     (hl)
        jr      z, pok07
        xor     a
        dec     c
        dec     (hl)
pok07   cp      'i'
        jr      z, pok14
        inc     (hl)
        jp      m, pok01
        add     hl, bc
        ld      (hl), a
        xor     a
        jr      pok03
pok08   ld      a, (hl)
        ex      (sp), hl
        ld      hl, CADEN+2
        ld      (hl), $2f
        dec     l
        ld      (hl), $32
        sub     200
        jr      nc, pok09
        dec     (hl)
        add     a, 100
        jr      c, pok09
        dec     (hl)
        dec     (hl)
        add     a, 90
        jr      nc, pok12
        ccf
        jr      pok11
pok09   inc     l
pok10   sub     10
pok11   inc     (hl)
        jr      nc, pok10
        inc     l
pok12   ld      (CADEN), a
        add     a, 10+$30
pok13   ld      (hl), a
        xor     a
        inc     l
        jr      nz, pok13
        jr      pok03
pok14   dec     c
        jp      m, pok17
        ld      b, c
        rlca
        rlca
        rl      c
        ex      de, hl
        ld      h, l
pok15   inc     e
        ld      a, (de)
        and     $0f
        push    bc
        add     hl, hl
        ld      b, h
        ld      c, l
        add     hl, hl
        add     hl, hl
        add     hl, bc
        ld      b, 0
        ld      c, a
        add     hl, bc
        pop     bc
        djnz    pok15
        bit     0, c
        jr      z, pok16
        ld      a, l
        pop     bc
        ld      (bc), a
        inc     bc
        jp      pokm1
pok16   bit     3, c
        jr      nz, pok08
        ld      a, (CADEN+1)
        sub     'r'
        halt
        di
        ret     z
        ex      af, af'
        ld      c, l
pok17   pop     hl
        jr      nz, pok18
        ld      (hl), c
pok18   ld      c, 11
        ld      hl, CADEN-13
        ld      de, $5c00
        ldir
        ld      hl, $5805
        ld      a, (hl)
        and     $f8
        ld      c, a
        rra
        rra
        rra
        and     $07
        or      c
        dec     l
        ld      c, l
        ld      (hl), a
        ld      de, $5803
        lddr
        pop     de
        ld      hl, $5c41
        ld      (hl), d
        ld      l, $3b
        ld      (hl), e
        pop     de
        ld      l, $91
        ld      a, e
        ld      i, a
        ld      (hl), d
        pop     de
        dec     l
        ld      (hl), d
        dec     l
        ld      (hl), e
        pop     hl
        ld      ($5c78), hl
        ex      af, af'
        dec     a
        jr      z, save
        ld      sp, $57e0
        pop     af
        pop     iy
        pop     hl
        pop     de
        pop     bc
        pop     af
        ld      sp, (CADEN-2)
        retn
pok19   defb    $ff, $00, $00, $00, $ff, $00, $00, $00, $00, $23, $05
pok20   defb    $00, $73, $6e, $61, $70, $73, $68, $6f, $74, $34
        defb    $38, $27, $00, $0a, $00, $27, $00
pok21   defb    $3e, 0,   $ed, $47, $de, $c0, $37, $0e, $8f, $39
        defb    $96, $01, 0,   0,   $11, 0,   0,   $21, 0,   0
        defb    $d9, $ed, $56, $fd, $21, 0,   0,   $11, $00, $c0
        defb    $21, $00, $40, $31, $00, $58, $c3, $f4, $07
pok22   defb    $21, 0,   0,   $e5, $f1, $08, $01, 0,   0,   $11
        defb    0,   0,   $dd, $21, 0,   0,   $21, 0,   0,   $e5
        defb    $f1, $21, 0,   0,   $31, 0,   0,   $f3, $ed, $45

;56e2   $21, 0,   0,   $e5, $f1, $08      af'
;56e8   $01, 0,   0                       bc
;56eb   $11, 0,   0                       de
;56ee   $dd, $21, 0,   0                  ix
;56f2   $21, 0,   0,   $e5, $f1           af
;56f7   $21, 0,   0                       hl
;56fa   $31, 0,   0                       sp
;56fd   $f3                               iff
;56fe   $ed, $45

;00 6D 61 72 69 6F 20 20 20 20 20 2B 00 0A 00 2B 00
;57fb-57ff  string
;57fa       string length 5+1          56e2
;57f8       sp
;57ed-57f7  keyboard variables 11
;57ec       unused
;57ea       af
;57e8       bc
;57e6       de
;57e4       hl
;57e2       iy
;57e0       af'
;56fe       FRAMES1
;56fc       ATTR_T MASK-T     
;56fa       I P_FLAG
;56f8       FLAGS MODE
;56f6       poke addr
;56f4       push de
;56f2       call 0b99
;56f0       push bc
;56ee       push hl
;56ec       call 0bdb
;56ea       interrup addr
;56e8       push af
;56e6       push hl
;56e4       push bc
;56e2       push de
;56e0       call 02bf    56e2 bloque2
;56de       call 028e
;56d9                         bloque1
;56d5                         
; o mover de 57b9 a 56d9 (39 bytes)
; 3e xx ed 47 de c0 37 0e 8f 39 96 01 xx xx 11 xx xx 21 xx xx d9 ed 56/5e
;     i iy                            bc'      de'      hl'         im
; fd 21 xx xx 11 00 c0 21 00 40 31 08 80 c3 f4 07  (39 bytes)

save    ld      sp, $5800
        ld      ($56ef), ix
        ld      ix, pok20
        ld      de, $0011
        call    $04c6
        ld      hl, pok21
        ld      de, $56d9
        push    de
        ld      c, $27 ;push bc
        ldir
        ld      a, i
        ld      ($56da), a
        exx
        ld      ($56e5), bc
        ld      ($56e8), de
        ld      ($56eb), hl
        ld      a, ($57ec)
        dec     a
        ld      a, $5e
        jr      nz, sav01
        ld      ($56ef), a
sav01   ld      hl, ($57e2)
        ld      ($56f2), hl
        ld      de, $0027 ;pop de
        pop     ix
        ld      a, $ff
        call    $04c6
        ld      de, $56e2
        push    de
        ld      hl, $05cd
        push    hl
        ld      hl, pok22
        ld      c, $1e
        ldir
        ld      sp, $57e0
        pop     hl
        ld      ($56e3), hl   ;af'
        pop     hl
        pop     hl
        ld      ($56f8), hl   ;hl
        pop     hl
        ld      ($56ec), hl   ;de
        pop     hl
        ld      ($56e9), hl   ;bc
        pop     hl
        ld      ($56f3), hl   ;af
        ld      hl, ($57f8)
        ld      a, i
        jp      pe, sav02
        ld      a, $fb
        ld      ($56fd), a    ;iff
sav02   ld      ($56fb), hl   ;sp
        ld      ix, $4000
        ld      de, $c000
        ld      a, $ff
        call    $04c6
        halt
pokef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3c00, 16
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3cde, 6
        ld      ($57ec), a
        jp      $0038
