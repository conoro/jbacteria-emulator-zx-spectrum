        output  "loadrom.bin"
        org     $5ccb
        ld      de, $c000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        ld      sp, $c000
        ld      bc, $7ffd
        ld      a, $14
        out     (c), a
        ld      hl, rom
        ld      bc, $4000
        ldir
        ld      a, 5
        ld      bc, $1ffd
        out     (c), a
        jp      $0000
rom     incbin  48.rom

/*<?php require 'zx.inc.php';
  generate_basic('loadrom', 'LOADROM', 1)?>*/