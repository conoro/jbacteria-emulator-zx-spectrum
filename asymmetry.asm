        output  "asymmetry.bin"
        org     $5ccb
        ld      d, $cf
        ldir
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        jp      $fec2
loopi   call    L3902
        jr      z, loopi
        dec     d
        jr      nz, loopi
        ld      b, d
        call    $05ed
        push    bc
        call    $05ed
        ld      e, b
        call    $2cb3           ; stk-(pulse0+pulse1)
        ld      d, b
        pop     bc
        ld      e, b
        call    $2cb3           ; stk-pulse0
        rst     28h             ; fp-calc      p0+p1, p0.
        defb    $01             ; exchange     p0, p0+p1.
        defb    $05             ; division     p0/(p0+p1).
        defb    $a2             ; stk-half     p0/(p0+p1), 0.5.
        defb    $03             ; subtract     p0/(p0+p1)-0.5.
        defb    $38             ; end-calc
        call    $2de3           ; routine print-fp outputs the number to
        ld      a, $0d
        rst     $10
        ld      d, a
        ld      c, 3
        jr      loopi

L3902:  LD      b,0         ; esta rutina lee 2 pulsos e inicializa el contador de pulsos
        call    $05ed
        call    $05ed
        ld      a,b
        ret

/*<?php require 'zx.inc.php';
  generate_basic('asymmetry', 'ASYMMETRY', 1)?>*/