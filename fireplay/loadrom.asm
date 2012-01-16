        output  "loadrom.bin"
        org     $5ccb
        ld      de, $8000-rom+deexo
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        ld      sp, $8000-rom+deexo
        ld      bc, $7ffd
        ld      a, $10
        out     (c), a
        ld      hl, $0000
        ld      bc, $4000
        ldir
        ld      c, rom-deexo
        ld      hl, deexo
        ldir
        call    deexo
        ld      hl, $4000
        ld      b, h
        ld      c, l
        ld      d, $80
        add     hl, de
        push    bc
        ldir
        ld      a, $14
        ld      bc, $7ffd
        out     (c), a
        pop     bc
        ld      h, $80
        ldir
        ld      a, 5
        ld      bc, $1ffd
        out     (c), a
        rst     0
deexo   include depack.asm
rom     incbin  comprimido.bin

/*<?php require 'zx.inc.php';
  generate_basic('loadrom')?>*/