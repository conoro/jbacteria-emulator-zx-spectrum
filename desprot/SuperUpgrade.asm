;SjASMPlus demo.asm
;GenTape   stereoinv demo.wav basic 'demo.tap' 0 demo.bin data leches.rom
        output  SuperUpgrade.bin
        org     $8000-21
ini     ld      de, $8000-21
        push    bc
        db      $de, $c0, $37, $0e, $8f, $39, $96 ;OVER USR 7 ($5ccb)
        pop     hl
        ld      bc, fin-ini
        ldir
        jp      $8000

roms    defb    0

        di
        ld      sp, $c000
        ld      hl, $c000
        ld      de, $4000
        call    $07f4
        di
        ld      hl, msg
        call    print
rdkey   in      a, ($fe)
        cpl
        and     $1f
        jr      z, rdkey
        xor     a               ; ld      a, %00000000
        ld      bc, $7ffd
        out     (c), a          ; pongo ROMl=0 y RAMB=0
        ld      b, $1f
        out     (c), a          ; pongo ROMh=0 (ROM=0)
        call    esector
        ld      hl, erfail
        jr      z, errs
        ld      hl, $c000
        ld      de, $0000
        call    blwrite
        ld      hl, wrfail
        jr      c, errs
        ld      a, 4
        jr      binf
errs    ld      a, 0x04         ; ld      a, %00000100
        out     (c), a          ; pongo ROMh=1
        ld      a, 0x10         ; ld      a, %00010000
        ld      b, $7f
        out     (c), a          ; pongo ROMl=1 y RAMB=0 (ROM 3)
        call    print
        ld      a, 2
binf    out     ($fe), a
        halt

msg     defb    "Change jumper and press any key", 13, 0
erfail  defb    "Erase failed", 0
wrfail  defb    "Write failed", 0

esector ld      hl, 0x555
        ld      a, l
        ld      de, 0x2aa
        ld      (hl), e         ; unlock addr 1
        ld      (de), a         ; unlock addr 2
        ld      (hl), 0x80      ; erase cmd addr 1
        ld      (hl), e         ; erase cmd addr 2
        ld      (de), a         ; erase cmd addr 3
        ld      (hl), 0x30      ; erase sector address
wait1   bit     7, (hl)         ; test DQ7 - should be 1 when complete
        ret     nz
        bit     5, (hl)         ; test DQ5 - should be 1 to continue
        jr      z, wait1
        bit     7, (hl)         ; test DQ7 again
        ret

nxbyte  inc     de
        inc     l
        jr      nz, blwrite
        inc     h
        ret     z
blwrite ld      a, 0xaa         ; unlock 1
        ld      (0x555), a      ; unlock address 1
        cpl                     ; unlock 2
        ld      (0x2aa), a      ; unlock address 2
        ld      a, 0xa0         ; Program
        ld      (0x555), a      ; Program address
        ld      a, (hl)         ; retrieve A
        ld      (de), a         ; program it
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

print1  rst     $10
        inc     hl
print   ld      a, (hl)
        and     a
        jr      nz, print1
        ret
fin
