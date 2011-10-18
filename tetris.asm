        output "tetris.bin"
        org   $5ccb
inic    ld    b, 23
        ld    a, $11
        db    $d7, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb)
        db    $3a               ;xor   a
ini1    rst   $10
        ld    a, 13
        ld    (velo+1), a
        rst   $10
ini2    ld    a, 249
        djnz  ini1
        ld    hl, $0110
        ld    ($5c09), hl       ;REPDEL, REPPER
newp    ld    a, ($5c78)        ;FRAMES1
mod7    sub   $f9
        jr    c, mod7
        inc   a
        ld    l, a
        add   a, a
        add   a, a
        add   a, a
        add   a, l
        ex    af, af
        ld    de, 6 | 2<<5 | $5800
        ld    c, d
        push  de
        ld    h, $5d
        ld    l, (hl)
        ld    h, b
        jr    cont
        db    %01100110         ;-oo-
                                ;-oo-
        db    %00001111               ;----
                                      ;oooo
        db    %00101110         ;--o-
                                ;ooo-
        db    %01001110               ;-o--
                                      ;ooo-
        db    %01101100         ;-oo-
                                ;oo--
        db    %10001110               ;o---
                                      ;ooo-
        db    %11000110         ;oo--
                                ;-oo-
tlin    ld    hl, 31 | 21<<5 | $5800
tli1    ex    de, hl
        xor   a
        ld    hl, $ffe0
        adc   hl, de
        ld    c, 11
        push  hl
        cpir
        pop   hl
        jr    z, tli1
        ld    c, l
        ld    a, h
        sub   $58
        jr    c, newp
        ld    b, a
        lddr
        ld    hl, fin
        rrc   (hl)
        jr    nc, tlin
        ld    l, d                ; velo+1
        dec   (hl)
        jr    tlin
cont    add   hl, hl
        add   hl, hl
        add   hl, hl
        add   hl, hl
        push  hl
loop    ld    ixl, opc2
        call  pint-1              ; testeo antes de colocar pieza
        jr    z, ncol
        pop   hl
        pop   de
        ld    sp, $ff40
        bit   2, c
        jr    z, inic
        inc   c
ncol    ld    ixl, opc1
        ex    af, af
        call  pint-1              ; pinta pieza
        ex    af, af
        bit   1, c
        jr    nz, tlin
        push  de
rkey    ld    a, ($5c78)
time    sub   0
velo    sub   0
        jr    z, salt
        bit   5, (iy+1)
        jr    z, rkey
        ld    a, ($5c08)
salt    push  hl
        res   5, (iy+1)
        push  af
        xor   a
        call  pint-1              ; borra pieza
        pop   af
        sub   'o'
        jr    nz, nizq
        dec   e
nizq    dec   a
        jr    nz, nder
        inc   e
nder    dec   a
        ld    c, 1
        jr    z, rota
        add   'q'-'b'
tloo    ld    bc, $2004
        jr    c, loop
        inc   c
su32    inc   de
        djnz  su32
        ld    a, ($5c78)
        ld    (time+1), a
        jr    loop

opc1    ld    (de), a
        ret

rot2    djnz  rot1
        pop   hl
        rr    h
        rr    l
rota    ld    b, 4
        push  hl
rot1    add   hl, hl
        add   hl, hl
        add   hl, hl
        add   hl, hl
        rl    c
        rla
        jr    nc, rot2
        pop   hl
        ld    h, a
        ld    l, c
        jr    tloo

pint    push  bc
        push  hl
pin1    ld    b, 4
pin2    add   hl, hl
        jr    nc, pin3
        call  $03f4
pin3    dec   de
        djnz  pin2
        ld    b, 32-4
re28    dec   de
        djnz  re28
        dec   c
        jr    nz, pin1
pin4    pop   hl
        pop   bc
        pop   de
        ret

opc2    ld    a, (de)
        or    a
        ret   z
        pop   de
        jr    pin4
fin

/*<?php require 'zx.inc.php';
  exec('sjasmplus tetris.asm');
  $in= file_get_contents('tetris.bin');
  file_put_contents('tetris.tap',
      head("\26\1\0SA\261\264RI\263", strlen($in)).data($in));
  exec('tetris.tap')?>*/