void unpack (unsigned int address, unsigned int destination) {
  #asm
        ld      hl,2
        add     hl,sp
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        inc     hl
        ld      a, (hl)
        inc     hl
        ld      h, (hl)
        ld      l, a
        jp      $5d44
  #endasm
}


#ifdef COMPRESSED_MAPS
void __FASTCALL__ descomprimir_map ( unsigned char pantalla) {
  #asm
        ld      (desc2+1), sp
        ld      b, l
        inc     b
        ld      sp, map-1
        ld      de, $ffff
        ld      hl, fin-1
desc1:  pop     af
        add     hl, de
        inc     hl
        ld      e, a
        dec     sp
        djnz    desc1
desc2:  ld      sp, 0
        ld      de, DMAP_BUFFER+149
        rr      b               ; b= $80 because carry=1
desc3:  ld      a, 256 / 2^DMAP_BITSYMB
desc4:  call    gbit3           ; load DMAP_BITSYMB bits (literal)
        jr      nc, desc4
#if   (DMAP_BITHALF==1)
        rrca                    ; half bit implementation (ie 48 tiles)
        call    c, gbit1
#else
        and     a
#endif
        ld      (de), a         ; write literal
desc5:  dec     e               ; test end of file (map is always 150 bytes)
        ret     z
        call    gbit3           ; read one bit
        rra
        jr      nc, desc3       ; test if literal or sequence
        push    de              ; if sequence put de in stack
        ld      a, 1            ; determine number of bits used for length
desc6:  call    nc, gbit3       ; (Elias gamma coding)
        and     a
        call    gbit3
        rra
        jr      nc, desc6       ; check end marker
        inc     a               ; adjust length
        ld      c, a            ; save lenth to c
        xor     a
        ld      de, 15          ; initially point to 15
        call    gbit3           ; get two bits
        call    gbit3
        jr      z, desc9        ; 00 = 1
        dec     a
        call    gbit3
        jr      z, descb        ; 010 = 15
        bit     2, a
        jr      nz, desc7
        call    gbit3           ; [011, 100, 101] xx = from 2 to 13
        dec     a
        call    gbit3
        jr      desca
desc7:  dec     e               ; [110, 111] xxxxxx = 14 and from 16 to 142
desc8:  call    gbit3
        jr      nc, desc8
        jr      z, descb
        add     e
desc9:  inc     a
desca:  ld      e, a
descb:  ld      a, b            ; save b (byte reading) on a
        ld      b, d            ; b= 0 because lddr moves bc bytes
        ex      (sp), hl        ; store source, restore destination
        ex      de, hl          ; HL = destination + offset + 1
        add     hl, de          ; DE = destination
        lddr
        pop     hl              ; restore source address (compressed data)
        ld      b, a            ; restore b register
        inc     e               ; prepare test of end of file
        jr      desc5           ; jump to main loop
#if   (DMAP_BITHALF==1)
gbit1:  sub     $80 - (2^(DMAP_BITSYMB-2))
        defb    $da             ; half bit implementation (ie 48 tiles)
#endif
gbit2:  ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbit3:  rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret
.map    BINARY "mapa_comprimido.bin"
.fin
  #endasm
}
#endif
