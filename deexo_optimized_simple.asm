; Note: mapbase must be 256 byte aligned
; exomizer raw <input_file> -c -o <intermediate_file>
; exoopt <intermediate_file> <output_file>
; 0=154, 1=156, 2= 176, 3= 185, 4= 224
;        output  deexo_optimized_simple.bin
;        define  mapbase $5b00
;        define  speed   4
  IF  speed<4
        ld      iy, mapbase
        ld      a, 128
        ld      b, 52
        push    de
        cp      a
init    ld      c, 16
        jr      nz, get4
        ld      de, 1
        ld      ixl, c
get4
      IF  speed=0
        call    getbit
      ENDIF
      IF  speed=1
        add     a, a
        call    z, getbit
      ENDIF
      IF  speed=2
        add     a, a
        jr      z, gb4
      ENDIF
      IF  speed=3
        add     a, a
        jp      nz, gb4c
        ld      a, (hl)
        inc     hl
        adc     a, a
      ENDIF
gb4c    rl      c
        jr      nc, get4
      IF  speed=2 OR speed=3
        inc     c
      ENDIF
        ld      (iy+0), c
        push    hl
        ld      hl, 1
      IF  speed=2 OR speed=3
        defb    48
      ELSE
        defb    210
      ENDIF
setbit  add     hl, hl
        dec     c
        jr      nz, setbit
        ld      (iy+52), e
        ld      (iy+104), d
        add     hl, de
        ex      de, hl
        inc     iyl
        pop     hl
        dec     ixl
        djnz    init
        pop     de
litcop  ldi
mloop 
      IF  speed=0
        call    getbit
        jr      c, litcop
gbmc    ld      bc, 3072
getind  call    getbit
        jr      nc, getind-1
      ENDIF
      IF  speed=1
        add     a, a
        call    z, getbit
        jr      c, litcop
gbmc    ld      bc, 3072
getind  add     a, a
        call    z, getbit
        jr      nc, getind-1
      ENDIF
      IF  speed=2
        add     a, a
        jr      z, gbm
        jr      c, litcop
gbmc    ld      bc, 3072
getind  add     a, a
        jr      z, gbi
        jr      nc, getind-1
      ENDIF
      IF  speed=3
        add     a, a
        jr      z, gbm
        jr      c, litcop
gbmc    ld      bc, 255
getind  inc     c
        add     a, a
        jr      z, gbi
        jr      nc, getind
      ENDIF

gbic    bit     4, c
        ret     nz
        push    de
        ld      iyl, c
      IF  speed=2 OR speed=3
        and     a
      ENDIF
    IF  speed=3
        ld      e, b
        ld      d, b
        ld      b, (iy+0)
        call    getbits
        ex      de, hl
        ld      c, (iy+52)
        ld      b, (iy+104)
        add     hl, bc
        ex      de, hl
        ld      b, d
    ELSE
        call    getpair
    ENDIF
        push    de
        inc     b
        djnz    dontgo
      IF  speed=2 OR speed=3
        ld      bc, 768+48
      ELSE
        ld      bc, 512+48
      ENDIF
        dec     e
        jr      z, goit
        dec     e
      IF  speed=2 OR speed=3
dontgo  ld      bc, 1280+32
      ELSE
dontgo  ld      bc, 1024+32
      ENDIF
        jr      z, goit
        ld      c, 16
goit
      IF  speed=2 OR speed=3
        ld      de, 0
      ENDIF
        call    getbits
        ld      iyl, c
        add     iy, de
      IF  speed=3
        ld      b, (iy+0)
        ld      de, 0
        call    getbits
        ex      de, hl
        ld      c, (iy+52)
        ld      b, (iy+104)
        add     hl, bc
        ex      de, hl
      ELSE
        call    getpair
      ENDIF
        pop     bc
        ex      (sp), hl
        push    hl
        sbc     hl, de
        pop     de
        ldir
        pop     hl
        jr      mloop

      IF  speed=2
gb4     ld      a, (hl)
        inc     hl
        adc     a, a
        jp      gb4c
      ENDIF
    IF  speed=2 OR speed=3
gbm     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      nc, gbmc
        jp      litcop

gbi     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      c, gbic
      IF  speed=2
        jp      getind-1
      ELSE
        jp      getind
      ENDIF
    ENDIF

    IFN speed=3
getpair ld      b, (iy+0)
      IF  speed=2
        ld      de, 0
      ENDIF
        call    getbits
        ex      de, hl
        ld      c, (iy+52)
        ld      b, (iy+104)
        add     hl, bc
        ex      de, hl
        ld      b, d
        ret
    ENDIF

    IF  speed=0 OR speed=1
getbits ld      de, 0
gbcont  dec     b
        ret     m
      IF  speed=0
        call    getbit
      ELSE
        add     a, a
        call    z, getbit
      ENDIF
        rl      e
        rl      d
        jr      gbcont

      IF  speed=0
getbit  add     a, a
        ret     nz
        ld      a, (hl)
        inc     hl
        adc     a, a
        ret
      ELSE
getbit  ld      a, (hl)
        inc     hl
        adc     a, a
        ret
      ENDIF
    ENDIF
    IF  speed=2 OR speed=3
gbg     ld      a, (hl)
        inc     hl
gbcont  adc     a, a
        jr      z, gbg
        rl      e
        rl      d
getbits djnz    gbcont
        ret
    ENDIF
  ELSE
        xor     a
        ld      iyl, 240
        ld      a, 128
        ld      b, 52
        push    de
init    ld      c, 16
        jr      nz, get4
        ld      de, 1
        ld      ixl, c
get4    add     a, a
        jr      z, gb4
gb4c    rl      c
        jr      nc, get4
        ld      iyh, mapbase/256
        inc     c
        ld      (iy+0), c
        push    hl
        ld      hl, 1
        defb    48
setbit  add     hl, hl
        dec     c
        jr      nz, setbit
        inc     iyh
        ld      (iy+0), e
        inc     iyh
        ld      (iy+0), d
        add     hl, de
        ex      de, hl
        inc     iyl
        pop     hl
        dec     ixl
        djnz    init
        pop     de
litcop  ldi
mloop   add     a, a
        jr      z, gbm
        jr      c, litcop
gbmc    push    de
        ld      bc, mapbase+240-1
getind  add     a, a
        jr      z, gbi
geti2   inc     c
        jr      nc, getind
        jr      z, final
gbic    ld      d, a
        xor     a
        ld      e, a
        ld      a, (bc)
        ld      b, a
        ld      a, d
        ld      d, e
        jp      gbfin1        ;gbfin1+2
gb4     ld      a, (hl)
        inc     hl
        adc     a, a
        jp      gb4c
gbi     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      nc, geti2
        inc     c
        jp      nz, gbic
final   pop     de
        ret
gbm     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      nc, gbmc
        jp      litcop
gbg2    ld      a, (hl)
        inc     hl
        jp      gbcon2
gbg1    ld      a, (hl)
        inc     hl
gbcon1  adc     a, a
        jr      z, gbg1
        rl      e
        rl      d                   ; se puede quitar
gbfin1  djnz    gbcon1
        ex      af, af'
        ld      b, (mapbase/256)+1
        ld      a, (bc)
        inc     b
        add     a, e
        ld      e, a
        ld      a, (bc)
        adc     a, d
        ld      d, a
        push    de
        jr      nz, dontgo
        ld      bc, 512+32
        dec     e
        jr      z, goit
        dec     e
        ld      bc, 1024+16
        jr      z, goit
        ld      c, d
        ld      e, d
goit    ex      af, af'
gbcon2  adc     a, a
        jr      z, gbg2
        rl      e
        rl      d             ; se puede quitar
        djnz    gbcon2
        ex      af, af'
        ld      a, e
        add     a, c
        ld      c, a
        ld      e, b
        ld      d, b          ; se puede quitar
        ld      b, mapbase/256
        ld      a, (bc)
        ld      b, a
        ex      af, af'
        jp      gbfin3
dontgo  ld      bc, 1024
        ld      d, c
        ld      e, c
        jp      goit
gbg3    ld      a, (hl)
        inc     hl
gbcon3  adc     a, a
        jr      z, gbg3
        rl      e
        rl      d
gbfin3  djnz    gbcon3
        ex      af, af'
        ld      b, (mapbase/256)+1
        ld      a, (bc)
        inc     b
        add     a, e
        ld      e, a
        ld      a, (bc)
        adc     a, d
        ld      d, a
        ex      af, af'
        pop     bc
        ex      (sp), hl
        push    hl
        sbc     hl, de
        pop     de
        ldir
        pop     hl
        jp      mloop
  ENDIF