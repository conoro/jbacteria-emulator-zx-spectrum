; -----------------------------------------------------------------------------
; ZX7 mini by Einar Saukas, Antonio Villena
; "Standard" version (43/39 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------
        DEFINE  back  1

dzx7    ld      a, $80
      IF  back=1
copyby  ldd
      ELSE
copyby  ldi
      ENDIF
mainlo  call    getbit
        jr      nc, copyby
        ld      bc, 1
lenval  call    getbit
        rl      c
        ret     c
        call    getbit
        jr      nc, lenval
        push    hl
        ld      l, (hl)
        ld      h, b
      IF  back=1
        add     hl, de
        lddr
        pop     hl
        dec     hl
      ELSE
        push    de
        ex      de, hl
        sbc     hl, de
        pop     de
        ldir
        pop     hl
        inc     hl
      ENDIF
        jr      mainlo
getbit  add     a, a
        ret     nz
        ld      a, (hl)
      IF  back=1
        dec     hl
      ELSE
        inc     hl
      ENDIF
        adc     a, a
        ret