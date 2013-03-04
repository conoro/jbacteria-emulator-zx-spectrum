; pokemon ROM patch for ZX Spectrum 48, poke & save snapshot with NMI button
; developped by Antonio Villena and flopping, GPL license, January 2013
; assembled with sjasmplus

      macro bloque  addr, length        ;38b5 015c      0581 9c a4 +8
        defw    addr                    ;0002 0005      0590 c9 cc +3
        defb    length & 255            ;0066 000e      05a6 b0 b8 +8
      endm                              ;11b8 00cb      05c7 b2 ba +8
        define  CADEN   $3b00-6         ;1539 001c      05d4 b0 b8 +8
        output  pokemonRam.bin          ;3aff 00fd      04df a4 90 (leader)
                                        ;3cde 0006      04e9 2f (sync1)
                                        ;3c01 0086      04f1 37 (sync2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                      0519 42 (uno-cero)
                                                      ; 051f 3e (cero)
        bloque  poke, pokef-poke                      ; 052e 31 (051f)
        org     $38b5
poke    ld      bc, 11
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
        ld      ($3bec), a
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
        defb    $ca, $ff, $ff
pok00   ld      c, 5
        ldir
        ld      l, b
        inc     h
        bit     3, h
        jr      z, pok00
        sub     h
        ld      h, $58
        jr      c, pok00
        push    bc
        xor     a
        ld      hl, CADEN
pok01   ld      (hl), 1
        inc     l
        jr      nz, pok01
        or      a
pok02   ld      l, CADEN & $ff
        ld      (hl), l
pok03   ld      e, CADEN+1 & 255
        jr      z, pok04
        ld      (de), a
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
        inc     e
        djnz    pok05
        ld      hl, $5c3b
pok06   bit     5, (hl)
        jr      z, pok06
        res     5, (hl)
        ld      a, ($5c08)
        ld      hl, CADEN
        ld      c, (hl)
        cp      13
        jr      z, pok13
        jr      nc, pok07
        dec     (hl)
        jr      z, pok07
        xor     a
        dec     c
        dec     (hl)
pok07   inc     (hl)
        jp      m, pok01
        add     hl, bc
        ld      (hl), a
        xor     a
        jr      pok03
pok08   inc     l
pok09   sub     10
pok10   inc     (hl)
        jr      nc, pok09
        inc     l
pok11   add     a, 10+$30
pok12   ld      (hl), a
        xor     a
        inc     l
        jr      nz, pok12
        jr      pok02
pok13   dec     c
        jp      m, pok18
        ld      b, c
        ex      de, hl
        ld      h, l
pok14   inc     e
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
        djnz    pok14
        ld      a, (CADEN+1)
        sub     'q'
        jr      nz, pok145
        ccf
        jr      pok17
pok145  dec     a
        ret     z
        dec     a
        jr      z, pok17
        ld      a, l
        bit     2, c
        jr      z, pok16
        pop     bc
pok15   push    hl
        ld      a, (hl)
        ex      (sp), hl
        ld      hl, CADEN+2
        ld      (hl), $2f
        dec     l
        ld      (hl), $32
        sub     200
        jr      nc, pok08
        dec     (hl)
        add     a, 100
        jr      c, pok08
        dec     (hl)
        dec     (hl)
        add     a, 90
        jr      nc, pok11
        ccf
        jr      pok10
pok16   pop     hl
        ld      (hl), a
        inc     hl
        jr      pok15
pok17   halt
        di
        ex      af, af'
pok18   pop     hl
        ld      c, 11
        ld      hl, CADEN-13
        ld      de, $5c00
        ldir
        ld      de, $4000
        ld      l, $8c
pok19   ld      c, 5
        ldir
        ld      e, b
        inc     d
        bit     3, d
        jr      z, pok19
        bit     4, d
        ld      d, $58
        jr      z, pok19
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
        jp      pokkk
pokef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $0002, 5
        ld      hl, $ffff
        defb    $c3, $c8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $0066, 14
        ld      (CADEN-2), sp
        ld      sp, CADEN-13-1
        push    af
        push    bc
        push    de
        push    hl
        jp      poke

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  rplay, rplayf-rplay
        org     $11b8
rplay   ld      hl, ($5cb2)
        exx
        ld      bc, ($5cb4)
        ld      de, ($5c38)
        ld      hl, ($5c7b)
        exx
        ex      af, af'
        ld      a, $3f
        out     ($fe), a
        ld      i, a
l11cf   ld      (hl), $01
        dec     hl
        cp      h
        jr      nz, l11cf
l11d5   inc     hl
        dec     (hl)
        jr      z, l11d5
        inc     (hl)
        dec     hl
        ld      b,(hl)
        exx
        ld      ($5cb4), bc
        ld      ($5c38), de
        ld      ($5c7b), hl
        exx
        ex      af, af'
        ld      de, $3eaf
        jr      nz, l1201
        ld      ($5cb4), hl
        ld      c, $a7
        ex      de, hl
        lddr
        ex      de, hl
        ld      ($5c7b), hl
        dec     hl
        ld      c, $40
        ld      ($5c38), bc
l1201   ld      ($5cb2), hl
        ld      (hl), d
        dec     hl
        ld      sp, hl
        dec     hl
        dec     hl
        ld      ($5c3d), hl
        im      1
        ld      iy, $5c3a
        ei
        ld      (iy-3), $3c
        ld      hl, $5cb6
        ld      ($5c4f), hl
        ld      de, $15af
        ld      c, d
        ex      de, hl
        ldir
        ld      e, $0e
        ld      c, $10
        ldir
        ld      hl, $0523
        ld      c, h
        ld      (iy+$31), c
        ld      ($5c09), hl
        ld      hl, $5cca
        ld      ($5c57), hl
        inc     l
        ld      ($5c53), hl
        ld      ($5c4b), hl
        ld      (hl), $80
        inc     l
        ld      ($5c59), hl
        ld      de, loadcc
        ex      de, hl
        ldir
        ex      de, hl
        ld      ($5c61), hl
        ld      ($5c63), hl
        ld      ($5c65), hl
        ld      a, $38
        ld      ($5c8d), a
        ld      ($5c48), a
        dec     (iy-$3a)
        dec     (iy-$36)
        call    $164d
        call    $0edf
        ld      (iy+$01), $8c
        call    $0d6b
        ld      de, $1538
        call    $0c0a
        call    $0308+3
        jr      $1303-11
loadcc  defb    $ef, $22, $22, $0d, $80
rplayf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $1539, msgf-msg
msg     defb    "Press PLAY or SPACE to brea", 'k'+$80
msgf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        bloque  $33fb, 1
;        defb    0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  table, tablef-table
        org     $3aff
table   defb    $ff
tab01   defb    $ff, $00, $00, $00, $ff, $00, $00, $00, $00, $23, $05
tab02   defb    $00, $10, $01, 'snapshot'
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
tab03   defb    $3e, 0,   $ed, $47, $de, $c0, $37, $0e, $8f, $39
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
tab04   defb    $21, 0,   0,   $e5, $f1, $08, $01, 0,   0,   $11
        defb    0,   0,   $dd, $21, 0,   0,   $21, 0,   0,   $e5
        defb    $f1, $21, 0,   0,   $31, 0,   0,   $f3, $c9

;5800-3b00
;5700-3ae0
;56e0-3ac0
;56d9-3ab9
;9*5=45 (2d) 3a8c-3ab9

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
save    ld      sp, $3b00
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
        ld      a, ($3bec)
        or      a
        jr      nz, sav01
        set     3, (ix+$16)
sav01   ld      hl, ($3be2)
        ld      ($3ad2), hl
        sbc     a, a
        call    $04c6
        ld      de, $3adf
        ld      hl, tab04+$1c
        ld      c, $1d
        lddr
        pop     hl
        ld      ($3ad1), hl
        inc     e
        push    de
        ld      hl, $05cd
        push    hl
        ld      sp, $3ae0
        pop     hl
        ld      ($3ac4), hl   ;af'
        pop     hl
        pop     hl
        ld      ($3ad9), hl   ;hl
        pop     hl
        ld      ($3acd), hl   ;de
        pop     hl
        ld      ($3aca), hl   ;bc
        pop     hl
        ld      ($3ad4), hl   ;af
        ld      a, i
        jp      pe, sav02
        set     3, (ix-3)     ;iff
sav02   ld      hl, ($3bf8)
        ld      ($3adc), hl   ;sp
        ld      ix, $4000
        ld      de, $c000
        sbc     a, a
        call    $04c6
        ld      ix, ($3ad1)
        ld      hl, ($3ad4)   ;af
        ld      ($3bea), hl
quit    ld      sp, $3ae0
        jp      nz, pok20
        jr      sal01
tablef

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  salir, salirf-salir
        org     $3c01
salir   defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
        defb    $ff, $ff, $ff, $ff, $ff, $ff, $ff
sal01   pop     af
        ex      af, af'
        pop     iy
        ld      hl, $5b00
        ld      de, $3ac2
        ld      c, qui02-qui01
        push    hl
        ldir
        pop     de
        push    de
        ld      hl, qui01
        ld      c, qui02-qui01
        ldir
        ld      bc, $1ffd
        ld      a, $04
        ret
qui01   out     (c), a
        ld      bc, $4000
        ld      de, $8000
        ld      hl, $c000
        ldir
        ld      bc, $7ffd
        ld      de, $1305
        out     (c), d
        ld      b, $1f
        out     (c), e
        jp      qui02
qui02   ld      hl, $3ac2
        ld      de, $5b00
        ld      bc, qui02-qui01
        ldir
        ld      sp, (CADEN-2)
        ld      hl, $fff7
        add     hl, sp
        push    hl
        ld      (CADEN-2), sp
        ld      hl, $45ed               ; retn
        push    hl
        ld      hl, ($3be8)             ; bc
        push    hl
        ld      h, 1                    ; ld bc, xxxx
        push    hl
        inc     sp
        ld      hl, ($3bea)             ; af
        ld      l, $3e                  ; ld a, xx
        push    hl
        ld      sp, $3be4
        pop     hl
        pop     de
        pop     bc
        pop     af
        ld      bc, $1ffd
        ld      a, 4
        ld      sp, (CADEN-2)
        jp      $1e7d
pokkk   ex      af, af'
        jp      c, quit
        jp      z, save
pok20   pop     af
        ex      af, af'
        pop     iy
        pop     hl
        pop     de
        pop     bc
        pop     af
        ld      sp, (CADEN-2)
        retn
        
;5->4 guarda
;4->5 codigo
;salta 5
;R526
;6->2
;R523
;4563
;salta 4
;4->5 restaura
;R523 salta a ld a,x ld bc,xx retn sp-9 2+3+2+2

salirf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        bloque  $3cde, 6
        ld      ($3bec), a
        jp      $0038