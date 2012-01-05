
        DEFINE  OFFS  $80
        DEFINE  L05ED $05ed
        DEFINE  L2CB3 $2cb3
        DEFINE  L2DE3 $2de3
        DEFINE  L1F4F $1f4f
        DEFINE  SNAP1 $0000
        DEFINE  LEEBI $0000
        DEFINE  enram
;        DEFINE  sinborde

        output  "patrloader.bin"
        org     $b4bf-$55
        ld      de, $b4bf
        nop
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        ld      hl, $5ccb+$55
        ld      bc, L37FF+3-L34BF
        ldir
recar   ld      de, $1b00
        ld      hl, $4000
        ld      a, ($0567)
        cp      $cd
        ld      a, $ff
        scf
        jr      nz, ram
        call    $07f4        
        jr      cont
ram     call    $5ccb+$3e
cont    call    $10a8
        jr      nc, cont
        ld      hl, $4000
        ld      de, $4001
        ld      (hl), l
        ld      bc, $17ff
        ldir
        jr      recar

L0556:  push    hl
        pop     ix
        INC     D               ; reset the zero flag without disturbing carry.
        EX      AF,AF'          ; preserve entry flags.
        DEC     D               ; restore high byte of length.
        DI                      ; disable interrupts
        LD      A,$0F           ; make the border white and mic off.
        OUT     ($FE),A         ; output to port.
        LD      HL,$053F        ; Address: SA/LD-RET
        PUSH    HL              ; is saved on stack as terminating routine.
        IN      A,($FE)         ; read the ear state - bit 6.
        RRA                     ; rotate to bit 5.
        AND     $20             ; isolate this bit.
        CALL    L360D
loader  include ultra.asm


/*<?php require 'zx.inc.php';
  generate_basic('patrloader')?>*/