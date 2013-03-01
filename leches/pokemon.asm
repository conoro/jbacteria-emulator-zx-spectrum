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
        ld      hl, sav03+10
        ld      c, e
        dec     e
        lddr
pok01   push    bc
        xor     a
        ei
        defb    $c2, $ff, $ff
pok02   ld      hl, CADEN
pok03   ld      (hl), 1
        inc     l
        jr      nz, pok03
        or      a
pok04   ld      de, CADEN+1
        jr      z, pok05
        ld      (de), a
        ld      l, CADEN & $ff
        ld      (hl), 2
pok05   ld      hl, $4000
        ld      b, $5
pok06   ld      a, (de)
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
        djnz    pok06
        ld      hl, $5c3b
pok07   bit     5, (hl)
        jr      z, pok07
        res     5, (hl)
        ld      a, ($5C08)
        ld      hl, CADEN
        ld      c, (hl)
        cp      13
        jr      z, pok15
        jr      nc, pok08
        dec     (hl)
        jr      z, pok08
        xor     a
        dec     c
        dec     (hl)
pok08   cp      'i'
        jr      z, pok15
        inc     (hl)
        jp      m, pok02
        add     hl, bc
        ld      (hl), a
        xor     a
        jr      pok04
pok09   ld      a, (hl)
        ex      (sp), hl
        ld      hl, CADEN+2
        ld      (hl), $2f
        dec     l
        ld      (hl), $32
        sub     200
        jr      nc, pok10
        dec     (hl)
        add     a, 100
        jr      c, pok10
        dec     (hl)
        dec     (hl)
        add     a, 90
        jr      nc, pok13
        ccf
        jr      pok12
pok10   inc     l
pok11   sub     10
pok12   inc     (hl)
        jr      nc, pok11
        inc     l
pok13   ld      (CADEN), a
        add     a, 10+$30
pok14   ld      (hl), a
        xor     a
        inc     l
        jr      nz, pok14
        jr      pok04
pok15   dec     c
        jp      m, pok18
        ld      b, c
        rlca
        rlca
        rl      c
        ex      de, hl
        ld      h, l
pok16   inc     e
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
        djnz    pok16
        bit     0, c
        jr      z, pok17
        ld      a, l
        pop     bc
        ld      (bc), a
        inc     bc
        jp      pok01
pok17   bit     3, c
        jr      nz, pok09
        ld      a, (CADEN+1)
        sub     'r'
        halt
        di
        ret     z
        ex      af, af'
        ld      c, l
pok18   pop     hl
        jr      nz, pok19
        ld      (hl), c
pok19   ld      c, 11
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
pok20   ld      sp, $57e0
        pop     af
        jr      pok21
        block   $3a01-$, $ff
pok21   pop     iy
        pop     hl
        pop     de
        pop     bc
        pop     af
        ld      sp, (CADEN-2)
        retn

pok22   defb    $00, $10, $01, 'snapshot'
        defb    $27, $00, $00, $00, $27, $00

;56d9   $3e, 0                            i     ld  a, i
;56db   $ed, $47                                ld  i, a
;56dd   $de, $c0, $37, $0e, $8f, $39, $96       over usr 5ccb
;56e4   $01, 0,   0                       bc'   ld  bc, 0
;56e7   $11, 0,   0                       de'   ld  de, 0
;56ea   $21, 0,   0                       hl'   ld  hl, 0
;56ed   $d9                                     exx
;56ee   $ed, $56                          im    im  1
;56f0   $fd, $21, 0,   0                  iy    ld  iy, 0
;56f4   $11, $00, $c0                           ld  hl, $4000
;56f7   $21, $00, $40                           ld  de, $c000
;56fa   $31, $00, $58                           ld  sp, $5800
;56fd   $c3, $f4, $07                           jp  $07f4
pok23   defb    $3e, 0,   $ed, $47, $de, $c0, $37, $0e, $8f, $39
        defb    $96, $01, 0,   0,   $11, 0,   0,   $21, 0,   0
        defb    $d9, $ed, $56, $fd, $21, 0,   0,   $11, $00, $c0
        defb    $21, $00, $40, $31, $00, $58, $c3, $f4, $07

;56e3   $21, 0,   0,   $e5, $f1, $08      af'   ld  hl, 0 / push hl / pop af / ex af,af'
;56e9   $01, 0,   0                       bc    ld  bc, 0
;56ec   $11, 0,   0                       de    ld  de, 0
;56ef   $dd, $21, 0,   0                  ix    ld  ix, 0
;56f3   $21, 0,   0,   $e5, $f1           af    ld  hl, 0 / push hl / pop af
;56f8   $21, 0,   0                       hl    ld  hl, 0
;56fb   $31, 0,   0                       sp    ld  sp, 0
;56fe   $f3                               iff   di
;56ff   $c9                                     ret
pok24   defb    $21, 0,   0,   $e5, $f1, $08, $01, 0,   0,   $11
        defb    0,   0,   $dd, $21, 0,   0,   $21, 0,   0,   $e5
        defb    $f1, $21, 0,   0,   $31, 0,   0,   $f3, $c9

;57fb-57ff  string                        56e3  <-57fe
;57fa       string length                 05cd  <-57fc
;57f8       sp
;57ed-57f7  keyboard variables
;57ec       unused                        im
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
;56e0       call 02bf                   bloque2 <-56e3
;56de       call 028e                   bloque1 <-56d9
save    ld      sp, $5800
        push    ix
        ld      ix, pok22
        ld      de, $0011
        call    $04c6
        ld      hl, pok23
        ld      de, $56d9
        push    de
        ld      c, $27
        push    bc
        ldir
        ld      a, i
        ld      ($56da), a
        exx
        ld      ($56e5), bc
        ld      ($56e8), de
        ld      ($56eb), hl
        exx
        pop     de
        pop     ix
        ld      a, ($57ec)
        dec     a
        jr      nz, sav01
        set     3, (ix+$16)
sav01   ld      hl, ($57e2)
        ld      ($56f2), hl
        sbc     a, a
        call    $04c6
        ld      d, $56
        ld      hl, pok24+$1c
        ld      c, $1d
        lddr
        pop     hl
        ld      ($56f1), hl
        inc     e
        push    de
        ld      hl, $05cd
        push    hl
        ld      sp, $57e0
        pop     hl
        ld      ($56e4), hl   ;af'
        pop     hl
        pop     hl
        ld      ($56f9), hl   ;hl
        pop     hl
        ld      ($56ed), hl   ;de
        pop     hl
        ld      ($56ea), hl   ;bc
        pop     hl
        ld      ($56f4), hl   ;af
        ld      a, i
        jp      pe, sav02
        set     3, (ix-3)     ;iff
sav02   ld      hl, ($57f8)
        ld      ($56fc), hl   ;sp
        ld      ix, $4000
        ld      de, $c000
        sbc     a, a
        call    $04c6
        ld      ix, ($56f1)
        ld      hl, ($56f4)   ;af
        ld      ($57ea), hl
        jp      pok20
        block   $3b00-$, $ff
sav03   defb    $ff, $00, $00, $00, $ff, $00, $00, $00, $00, $23, $05

pokef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3c00, 16
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        defw    $3cde, 6
        ld      ($57ec), a
        jp      $0038
