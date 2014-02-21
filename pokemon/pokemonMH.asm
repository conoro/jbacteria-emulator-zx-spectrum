; pokemon ROM patch for ZX Spectrum 48, poke & save snapshot with NMI button
; developped by Antonio Villena and flopping, GPL license, January 2013
; assembled with sjasmplus

      macro bloque  addr, length
        defw    addr
        defb    length & 255
      endm
        define  CADEN   $3b00-6
        output  pokemonMH.bin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                
                                                  
        bloque  poke, pokef-poke                  
        org     $3900
poke    push    af
        push    bc
        push    de
        push    hl
        ld      bc, 11
        push    iy
        ld      iy, $5c3a
        ex      af, af'
        push    af
        ld      hl, $5c78
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
        ld      ($3aec), a
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
        ld      hl, tab01+10
        ld      c, e
        dec     e
        lddr
        ld      hl, $4000
        ld      de, $3a8c
        ei
pok01   ld      c, 5
        ldir
        ld      l, b
        inc     h
        bit     3, h
        jr      z, pok01
        sub     h
        ld      h, $58
        jr      c, pok01
        push    bc
        xor     a
        ld      hl, CADEN
pok02   ld      (hl), 1
        inc     l
        jr      nz, pok02
        or      a
pok03   ld      l, CADEN & $ff
        ld      (hl), l
pok04   ld      e, CADEN+1 & 255
        jr      z, pok05
        ld      (de), a
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
        call    $0b99
        pop     de
        inc     e
        djnz    pok06
        ld      hl, $5c3b
pok07   bit     5, (hl)
        jr      z, pok07
        res     5, (hl)
        ld      a, ($5c08)
        or      $20
        ld      hl, CADEN
        ld      c, (hl)
        cp      $2d
        jr      z, pok14
        jr      nc, pok08
        dec     (hl)
        jr      z, pok08
        xor     a
        dec     c
        dec     (hl)
pok08   inc     (hl)
        jp      m, pok02
        add     hl, bc
        ld      (hl), a
        xor     a
        jr      pok04
pok09   inc     l
pok10   sub     10
pok11   inc     (hl)
        jr      nc, pok10
        inc     l
pok12   add     a, 10+$30
pok13   ld      (hl), a
        xor     a
        inc     l
        jr      nz, pok13
        jr      pok03
pok14   dec     c
        jp      m, pok20
        ld      b, c
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
        ld      a, (CADEN+1)
        sub     'r'
        ret     z
        dec     a
        jr      z, pok19
        ld      a, l
        bit     2, c
        jr      z, pok18
        pop     bc
pok17   push    hl
        ld      a, (hl)
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
        jr      $+2
        defb    $ff, $ff
        add     a, 90
        jr      nc, pok12
        ccf
        jr      pok11
pok18   pop     hl
        ld      (hl), a
        inc     hl
        jr      pok17
pok19   halt
        ex      af, af'
pok20   di
        pop     hl
        ld      c, 11
        ld      hl, CADEN-13
        ld      de, $5c00
        ldir
        ld      de, $4000
        ld      l, $8c
pok21   ld      c, 5
        ldir
        ld      e, b
        inc     d
        bit     3, d
        jr      z, pok21
        bit     4, d
        ld      d, $58
        jr      z, pok21
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
        ex      af, af'
        jp      sal01
pokef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $0066, 10
        ld      (CADEN-2), sp
        ld      sp, CADEN-13-1
        jp      poke

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  table, tablef-table
        org     $3aff
table   defb    $ff
tab01   defb    $ff, $00, $00, $00, $ff, $00, $00, $00, $00, $23, $05
tab02   defb    $00, $10, $01, 'snapshot'
        defb    $27, $00, $00, $00, $27, $00

;3ab9   $3e, 0                            i     ld  a, i
;3abb   $ed, $47                                ld  i, a
;3abd   $de, $c0, $37, $0e, $8f, $39, $96       over usr 5ccb
;3ac4   $01, 0,   0                       bc'   ld  bc, 0
;3ac7   $11, 0,   0                       de'   ld  de, 0
;3aca   $21, 0,   0                       hl'   ld  hl, 0
;3acd   $d9                                     exx
;3ace   $ed, $56                          im    im  1
;3ad0   $fd, $21, 0,   0                  iy    ld  iy, 0
;3ad4   $11, $00, $c0                           ld  hl, $4000
;3ad7   $21, $00, $40                           ld  de, $c000
;3ada   $31, $00, $58                           ld  sp, $5800
;3add   $c3, $f4, $07                           jp  $07f4
tab03   defb    $3e, 0,   $ed, $47, $de, $c0, $37, $0e, $8f, $39
        defb    $96, $01, 0,   0,   $11, 0,   0,   $21, 0,   0
        defb    $d9, $ed, $56, $fd, $21, 0,   0,   $11, $00, $c0
        defb    $21, $00, $40, $31, $00, $58, $c3, $f4, $07

;57db   $21, 0,   0,   $e5, $f1, $08      af'   ld  hl, 0 / push hl / pop af / ex af,af'
;57e1   $01, 0,   0                       bc    ld  bc, 0
;57e4   $11, 0,   0                       de    ld  de, 0
;57e7   $dd, $21, 0,   0                  ix    ld  ix, 0
;57eb   $21, 0,   0,   $e5, $f1           af    ld  hl, 0 / push hl / pop af
;57f0   $21, 0,   0                       hl    ld  hl, 0
;57f3   $31, 0,   0                       sp    ld  sp, 0
;57f6   $f3                               iff   di
;57f7   $c9                                     ret
;57f8   dummy
;57fa   dummy
;57fc   $05cd
;57fe   $57db
tab04   defb    $21, 0,   0,   $e5, $f1, $08, $01, 0,   0,   $11
        defb    0,   0,   $dd, $21, 0,   0,   $21, 0,   0,   $e5
        defb    $f1, $21, 0,   0,   $31, 0,   0,   $f3, $c9
        defw    0, $05cd, $57db

;3afb-3aff  string                        3ac3  <-3afe
;3afa       string length                 05cd  <-3afc
;3af8       sp
;3aed-3af7  keyboard variables
;3aec       unused                        im
;3aea       af
;3ae8       bc
;3ae6       de
;3ae4       hl
;3ae2       iy
;3ae0       af'
;3ade       FRAMES1
;3adc       ATTR_T MASK-T     
;3ada       I P_FLAG
;3ad8       FLAGS MODE
;3ad6       poke addr
;3ad4       push de
;3ad2       call 0b99
;3ad0       push bc
;3ace       push hl
;3acc       call 0bdb
;3aca       interrup addr
;3ac8       push af
;3ac6       push hl
;3ac4       push bc
;3ac2       push de
;3ac0       call 02bf                   bloque2 <-3ac3
;3abe       call 028e                   bloque1 <-3ab9
tab05   ld      sp, $3b00
        push    ix
        ld      ix, tab02
        ld      de, $0011
        call    $04c6
        ld      hl, tab03
        ld      de, $3ab9
        push    de
        ld      c, $27
        push    bc
        ldir
        ld      a, i
        ld      ($3aba), a
        exx
        ld      ($3ac5), bc
        ld      ($3ac8), de
        ld      ($3acb), hl
        exx
        pop     de
        pop     ix
        ld      a, ($3aec)
        or      a
        jr      nz, tab06
        set     3, (ix+$16)
tab06   ld      hl, ($3ae2)
        ld      ($3ad2), hl
        ld      a, $ff
        call    $04c6
        ld      de, $57ff
        ld      hl, tab04+$24
        ld      c, $25
        lddr
        pop     hl
        ld      ($57e9), hl
        ld      sp, $3ae0
        pop     hl
        ld      ($57dc), hl   ;af'
        pop     hl
        pop     hl
        ld      ($57f1), hl   ;hl
        pop     hl
        ld      ($57e5), hl   ;de
        pop     hl
        ld      ($57e2), hl   ;bc
        pop     hl
        ld      ($57ec), hl   ;af
        pop     hl
        ld      a, i
        jp      pe, tab07
        ld      a, $fb
        ld      ($57f6), a    ;iff
tab07   ld      hl, ($3af8)
        ld      ($57f4), hl   ;sp
        ld      ix, $4000
        ld      de, $c000
        sbc     a, a
        call    $04c6
        ld      ix, ($57e9)
        jp      sal05
tablef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $3cde, 6
        ld      ($3aec), a
        jp      $0038

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  salir, salirf-salir
        org     $3c01
salir   defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff
sal01   ld      ($5c78), hl
        jp      z, tab05
sal05   ld      sp, $3ae0
        pop     af
        ex      af, af'
        pop     iy
        pop     hl
        pop     de
        pop     bc
        pop     af
        ld      sp, (CADEN-2)
        retn
salirf
