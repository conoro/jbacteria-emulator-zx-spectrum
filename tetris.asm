        output "tetris.bin"
        org   $5ccb
ini     ld    b, 23
        ld    a, $11
        db    $d7, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb)
        db    $3a               ;xor   a
tet1    rst   $10
        ld    a, 13
        ld    (time-1), a
        rst   $10
ini2    ld    a, 249
        djnz  tet1
        ld    hl, $0110
        ld    ($5c09), hl       ;REPDEL, REPPER
bpgs    ld    a, ($5c78)
resi    sub   $f9
        jr    c, resi
        inc   a
        ld    l, a
        add   a, a
        add   a, a
        add   a, a
        add   a, l
        ld    (opc0+1), a
        ld    de, 6 | 2<<5 | $5800
        ld    c, d
        push  de
        ld    h, $5d
        jr    tttt
        db    %11101000
        db    %01100011
        db    %01100110
        db    %00110110
        db    %01001110
        db    %00001111
        db    %10001110
disi    ld    de, 31 | 22<<5 | $5800
dis2    ld    a, $38+10
        ld    hl, $ffe0
        adc   hl, de
        jr    nc, bpgs
        ex    de, hl
        xor   (hl)
        jr    nz, dis2
        ld    c, e
        ld    a, d
        sub   $58
        ld    b, a
        ex    de, hl
        lddr
        ld    hl, fin
        rrc   (hl)
        jr    nc, disi
        ld    l, time-1
        dec   (hl)
        jr    disi-1
tttt    ld    l, (hl)
        ld    h, b
        add   hl, hl
        add   hl, hl
        add   hl, hl
        add   hl, hl
        push  hl
lejo    ld    ixl, opc2
        call  pint
        jr    z, delg
        pop   hl
        pop   de
        ld    sp, $ff40
        bit   2, c
        jr    z, ini
        inc   c
delg    ld    ixl, opc0
        dec   (ix+opci-opc0)
        call  pint              ; pinta pieza
        inc   (ix+opci-opc0)
teal    bit   1, c
        jr    nz, disi
ted     ld    a, ($5c78)
        sub   0
time    sub   0
        jr    z, salt
        bit   5, (iy+1)
        jr    z, ted
        ld    a, ($5c08)
salt    push  de
        push  hl
        res   5, (iy+1)
        ld    ixl, opc1
        ex    af, af
        call  pint              ; borra pieza
        ex    af, af
        cp    'p'
        jr    nz, nrigh
        inc   e
nrigh   cp    'o'
        jr    nz, nleft
        dec   e
nleft   sub   'q'
        jr    z, rota
        add   'q'-'b'
tlejo   ld    bc, $2004
        jr    c, lejo
        inc   c
noca    inc   de
        djnz  noca
        ld    a, ($5c78)
        ld    (time+1), a
        jr    lejo

nfina   djnz  akir
        pop   hl
        rr    h
        rr    l
        db    $ca               ; jr    akia
rota    ld    c, a
        inc   a
akia    ld    b, 4
        push  hl
akir    add   hl, hl
        add   hl, hl
        add   hl, hl
        add   hl, hl
        rla
        rl    c
        jr    nc, nfina
        pop   hl
        ld    h, c
        ld    l, a
        jr    tlejo

pint    push  bc
        push  de
        push  hl
pint1   ld    b, 4
pint2   add   hl, hl
        jr    nc, pint4
        xor   a
pint3   call  $03f4
pint4   dec   de
        djnz  pint2
        ld    b, 32-4
sum28   dec   de
        djnz  sum28
        dec   c
        jr    nz, pint1
        jr    pint5

opc0    ld    a, 0
opc1    ld    (de), a
        push  hl
        ld    h, d
        ld    a, e
        or    a, $1f
        ld    l, a
opci    dec   (hl)
        pop   hl
        ret

opc2    ex    de, hl
        add   a, (hl)
        ex    de, hl
        ret   z
        pop   de
pint5   pop   hl
        pop   de
        pop   bc
        ret
fin

/*<?php require 'zx.inc.php';
  exec('sjasmplus tetris.asm');
  $in= file_get_contents('tetris.bin');
  file_put_contents('tetris.tap',
      head("\26\1\0SA\261\264RI\263", strlen($in)).data($in));
  exec('tetris.tap')?>*/