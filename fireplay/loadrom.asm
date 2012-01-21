        output  "loadrom.bin"
        org     $5ccb
        ld      de, $d800
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        ld      sp, $8000-rom+deexo
        ld      bc, $7ffd
        ld      a, $07
        push    bc
        out     (c), a
        ld      hl, $5800
        ld      bc, $2801
        ldir
        ld      ($5c44+$8000), hl
        ld      hl, $5cd1
        ld      ($5c61+$8000), hl
        ld      ($5c65+$8000), hl
        dec     l
        dec     l
        ld      ($5c5b+$8000), hl
        ld      l, $cc
        ld      ($5c59+$8000), hl
        ld      ($5c5e+$8000), hl
        dec     l
        ld      ($5c4b+$8000), hl
        ld      hl, $5c3d+$8000
        ld      (hl), $54
        ld      hl, $ef80
        ld      ($5ccb+$8000), hl
        ld      hl, $2222
        ld      ($5ccd+$8000), hl
        ld      hl, $800d
        ld      ($5ccf+$8000), hl
        ld      hl, $4000
        ld      ($ff54), hl
 ld hl,parche
 ld de,$dc00
 ld bc,deexo-parche
 ldir
        pop     bc
        ld      a, $10
        out     (c), a
        ld      hl, $0000
        ld      de, $8000-rom+deexo
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
        jp      $0066
parche  incbin  loadr.bin
deexo   include depack.asm
rom     incbin  comprimido.bin

/*<?php require 'zx.inc.php';
  generate_basic('loadrom')?>*/