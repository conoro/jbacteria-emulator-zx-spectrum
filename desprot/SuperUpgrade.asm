;SjASMPlus demo.asm
        output  SuperUpgrade.bin
        org     $8000-20
ini     ld      de, $8000-20
        push    bc
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        pop     hl
        ld      bc, fin-ini
        ldir
        jp      init

page    ld      a, iyl
page1   rrca
        rrca
        rrca
        ret     c
        rrca
        ld      l, a
        ld      a, iyl
        cp      2
        ccf
        adc     a, l
        and     %00010111
        ld      bc, $7ffd
        out     (c), a
        ld      a, l
        rrca
        rrca
        rrca
        and     %00000100
        ld      b, $1f
        out     (c), a
        inc     iyl
        ld      b, iyl
        ld      a, $80
page2   rlca
        djnz    page2
        and     0
        ld      hl, $c000
        ld      de, $4000
        ret

init    di
        ld      sp, $c000
        ld      hl, $3d00
        ld      de, $bd00
        ld      b, 3
        ldir
        ld      iyl, c
init1   call    page
        ld      h, $3d
        ld      d, $bd
init2   ld      a, (de)
        cp      (hl)
        jr      nz, init1
        inc     l
        inc     e
        djnz    init2
        ld      a, iyl
        dec     a
        ld      (init4+1), a
        ld      iyl, b
init3   call    page
        jr      c, init6
        jr      z, init5
        dec     iyl
init4   ld      a, 0
        call    page1
        call    $07f4
        di
        jr      init3
init5   ex      de, hl
        ld      b, h
        ld      c, a
        ld      h, a
        ldir
        jr      init3
init6   ld      ix, msg
        ld      de, $4800
        ld      iyl, e
        call    print
        inc     e
        call    print
init7   in      a, ($fe)
        cpl
        and     $1f
        jr      z, init7
        ld      a, $ef
        in      a, ($fe)
        rrca
        jr      nc, init9
        ld      b, 7
        rrca
        rrca
        rrca
        jr      nc, init9
        dec     b
        rrca
        jr      nc, init9
        ld      a, $f7
        in      a, ($fe)
        add     a, a
        add     a, a
init8   add     a, a
        jr      nc, init9
        djnz    init8
init9   ld      a, b
        add     a, a
        add     a, a
        ld      bc, $043b
        out     (c), a
        ld      hl, $0555
        ld      a, l
        ld      de, $02aa
        ld      (hl), e
        ld      (de), a
        ld      (hl), $80
        ld      (hl), e
        ld      (de), a
        ld      (hl), $30
init10  bit     7, (hl)
        jr      nz, init11
        bit     5, (hl)
        jr      z, init10
        bit     7, (hl)
        ld      ix, erfail
        jr      z, error
init11  call    page
        ld      a, 4
        jr      c, exit
        ld      d, e
        call    blwri
        jr      nc, init11
        ld      ix, wrfail
error   ld      de, $4840
        call    print
        ld      a, 2
exit    out     ($fe), a
        halt

blwri2  inc     de
        inc     l
        jr      nz, blwri
        inc     h
        ret     z
blwri   ld      a, $aa
        ld      ($0555), a
        cpl
        ld      ($02aa), a
        ld      a, $a0
        ld      ($0555), a
        ld      a, (hl)
        ld      (de), a
blwri1  ld      a, (de)
        xor     (hl)
        jp      p, blwri2
        xor     (hl)
        bit     5, a
        jr      z, blwri1
        ld      a, (de)
        xor     (hl)
        jp      p, blwri2
        scf
        ret

prchar  ld      l, a
        add     hl, hl
        ld      h, $2f
        add     hl, hl
        add     hl, hl
        ld      b, 8
prcha1  ld      a, (hl)
        ld      (de), a
        inc     d
        inc     l
        djnz    prcha1
        ld      hl, $f801
        add     hl, de
        ex      de, hl
print   ld      a, (ix)
        inc     ix
        and     a
        jr      nz, prchar
        ret

msg     defb    "Change jumper and press any key", 0
        defb    "or press 0-7 if you have add on", 0
erfail  defb    "Erase failed", 0
wrfail  defb    "Write failed", 0
fin
