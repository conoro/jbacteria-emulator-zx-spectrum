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

ruti    ld      a, iyl
        rrca
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
        ld      (p7ffd+1), a
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
mult    rlca
        djnz    mult
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
again   call    ruti
        jr      c, acab
        jr      z, copy
p7ffd   ld      a, 0
        or      $10
        ld      b, $7f
        out     (c), a
        ld      a, %00000100
        ld      b, $1f
        out     (c), a
        call    $07f4
        di
        jr      again
copy    ex      de, hl
        ld      b, h
        ld      c, a
        ld      h, a
        ldir
        jr      again
acab    ld      ix, msg
        ld      de, $4800
        ld      iyl, e
        call    print
        inc     e
        call    print
rdkey   in      a, ($fe)
        cpl
        and     $1f
        jr      z, rdkey
        ld      a, $ef
        in      a, ($fe)
        rrca
        jr      nc, salbe
        ld      b, 7
        rrca
        rrca
        rrca
        jr      nc, salbe
        dec     b
        rrca
        jr      nc, salbe
        ld      a, $f7
        in      a, ($fe)
        add     a, a
        add     a, a
rotat   add     a, a
        jr      nc, salbe
        djnz    rotat
salbe   ld      a, b
        add     a, a
        add     a, a
        ld      bc, $043b
        out     (c), a
esector ld      hl, $5555
        ld      a, l
        ld      de, $aaaa
        ld      (hl), e
        ld      (de), a
        ld      (hl), $80
        ld      (hl), e
        ld      (de), a
        ld      h, $30
        ld      (hl), h
wait1   bit     7, (hl)
        jr      nz, graba
        bit     5, (hl)
        jr      z, wait1
        bit     7, (hl)
        ld      ix, erfail
        jr      z, errs
graba   call    ruti
        ld      a, 4
        jr      c, binf
        ld      d, e
        call    blwrite
        jr      nc, graba
        ld      ix, wrfail
errs    ld      de, $4840
        call    print
        ld      a, 2
binf    out     ($fe), a
        halt

nxbyte  inc     de
        inc     l
        jr      nz, blwrite
        inc     h
        ret     z
blwrite ld      a, $aa
        ld      ($5555), a
        cpl
        ld      ($aaaa), a
        ld      a, $a0
        ld      ($5555), a
        ld      a, (hl)
        ld      (de), a
wait3   ld      a, (de)
        xor     (hl)
        jp      p, nxbyte
        xor     (hl)
        bit     5, a
        jr      z, wait3
        ld      a, (de)
        xor     (hl)
        jp      p, nxbyte
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
