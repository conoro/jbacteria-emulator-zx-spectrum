        output "tetris.bin"
        org   $5ccb
ini     ld    b, 23
        ld    a, $11
        db    $d7, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        db    $3a ;xor   a
tet1    rst   $10
        ld    a, 13
        rst   $10
ini2    ld    a, 249
        djnz  tet1
        ld    hl, $0110
        ld    ($5c09), hl       ; loaded to REPDEL and REPPER.

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
        ld    h, $5d
        ld    l, (hl)
        ld    h, $10
        ld    de, 6  | 2<<5 | $5800
        push  de
otve    add   hl, hl
        jr    tttt
        db    %11101000 ;7l
        db    %01100011 ;z
        db    %01100110 ;cu
        db    %00110110 ;s
        db    %01001110 ;t
        db    %10001110; 0010 ;es
        db    %00001111 ;ba
tttt    jr    nc, otve
        push  hl
        ld    c, $04

lejo    ld    ix, opc2
        call  pint
        jr    z, delg     ;si no final, bien
        pop   hl
        pop   de
        ld    sp, $ff40
        bit   2, c
        jr    nz, ini
        inc   c
; compuebo final

delg    ld    ixl, opci
        dec   (ix)
        ld    ixl, opc0
        call  pint        ; pinta pieza
        ld    ixl, opci
        inc   (ix)
teal    bit   1, c
        jr    z, ted
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
        push  hl
        ex    de, hl
        lddr
        pop   de
        jr    dis2
; compruebo linea hecha
ted     ld    a, ($5c78)
        sub   12
time    sub   0
        jr    z, salt
        bit   5, (iy+1)
        jr    z, ted
        ld    a, ($5c08)
salt    push  de
        push  hl
        res   5, (iy+1)
        ld    ixl, opc1
        ex    af, af'
        call  pint        ; borra pieza
        ex    af, af'
        cp    'p'
        jr    nz, nrigh
        inc   e
nrigh   cp    'o'
        jr    nz, nleft
        dec   e
nleft   cp    'q'
        jr    z, rota
        cp    'b'
        ld    bc, $2008
        jr    nc, lejo
        inc   c
noca    inc   de
        djnz  noca
        ld    a, ($5c78)
        ld    (time+1), a
tlejo   jp    lejo

rota    ld    c, 0
        ld    a, 1
akia    ld    b, 4
        push  hl
akir    add   hl, hl
        add   hl, hl
        add   hl, hl
        add   hl, hl
        rla
        rl    c
        jr    c, fina
        djnz  akir
        pop   hl
        rr    h
        rr    l
        jr    akia
fina    pop   hl
        ld    h, c
        ld    l, a
        ld    c, 8
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
        ld    b, 28
sum28   dec   de
        djnz  sum28
        dec   c
        jr    nz, pint1
pint5   pop   hl
        pop   de
        pop   bc
        ret

opc2    ex    de, hl
        add   a, (hl)
        ex    de, hl
        ret   z
        pop   de
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

/*<?php require 'zx.inc.php';
  exec('sjasmplus tetris.asm');
  $in= file_get_contents('tetris.bin');
  file_put_contents('tetris.tap',
      head("\26\1\0\262TETAS\350", strlen($in)).data($in));
  exec('tetris.tap')?>*/