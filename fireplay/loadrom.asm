        output  "loadrom.bin"
        org     $5ccb
        ld      de, $8000-rom+deexo
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        ld      sp, $8000-rom+deexo
        ld      bc, $7ffd
        xor     $5e                 ;a=$4a. ld a, $14 y clear carry
        out     (c), a
        sbc     hl, hl
        ld      bc, $4000
        ldir
        ld      c, rom-deexo
        ld      hl, deexo
        ldir
        call    deexo
        ld      a, 5
        ld      bc, $1ffd
        out     (c), a
        jp      $0000
deexo   include depack.asm
rom     incbin  comprimido.bin

/*<?php require 'zx.inc.php';
  generate_basic('loadrom')?>*/