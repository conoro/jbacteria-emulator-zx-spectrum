; Note: mapbase must be 256 byte aligned
; exomizer raw <input_file> -c -o <intermediate_file>
; exoopt <intermediate_file> <output_file>
; 0=159, 1=161, 2= 181, 3ram= 191, 3rom= 193, 4ram= 242, 4rom= 243
;        output  deexo_optimized_simple.bin
;        define  mapbase $5b00
;        define  speed   4
;        define  rom     0
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
      IF  rom=1
        ex      de, hl
        ld      ixl, e
        ld      ixh, d
      ELSE
        ld      (toklen+1), hl
        ex      de, hl
      ENDIF
        ld      b, d
    ELSE
        call    getpair
        push    de
        pop     ix
    ENDIF
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
        ld      b, d
      ELSE
        call    getpair
      ENDIF
        ld      c, e
        ex      (sp), hl
        ld      d, h
        ld      e, l
        sbc     hl, bc
    IF  speed=3
      IF  rom=1
        ld      c, ixl
        ld      b, ixh
      ELSE
toklen  ld      bc, 0
      ENDIF
    ELSE
        push    ix
        pop     bc
    ENDIF
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
        ld      iyl, a
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
        ld      (iy+0), c
        push    hl
        ld      hl, 1
        defb    210
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
        ld      c, b
        pop     de
litcop  inc     c
        ldi
mloop   add     a, a
        jr      z, gbm
        jr      c, litcop
gbmc    push    de
        ld      de, mapbase+255
getind  inc     e
        add     a, a
        jr      z, gbi
        jr      nc, getind
gbic    bit     4, e
        jr      nz, final
        and     a
        ex      de, hl
        ld      h, (hl)
        ex      de, hl
        dec     d
        jp      p, gbcon1
        jp      gbfin1
gb4     ld      a, (hl)
        inc     hl
        adc     a, a
        jp      gb4c
gbi     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      c, gbic
        jp      getind
gbm     ld      a, (hl)
        inc     hl
        adc     a, a
        jr      nc, gbmc
        jp      litcop
final   pop     de
        ret
gbg2    ld      a, (hl)
        inc     hl
        jp      gbcon2
gbg1    ld      a, (hl)
        inc     hl
gbcon1  adc     a, a
        jr      z, gbg1
        rl      c
        rl      b
        dec     d
        jp      p, gbcon1
gbfin1  ex      af, af'
        ld      d, (mapbase/256)+1
        ld      a, (de)
        inc     d
        add     a, c
        ld      c, a
        ld      a, (de)
        adc     a, b
        ld      b, a
      IF  rom=1
        ld      ixl, c
        ld      ixh, b
      ELSE
        ld      (toklen+1), bc
      ENDIF
        jr      nz, dontgo
        ld      de, 512+48        ;1?
        dec     c
        jr      z, goit
        dec     c                 ;2?
        ld      de, 1024+16
        jr      nz, goit
        ld      e, 32
goit    ld      c, b
goit2   ex      af, af'
gbcon2  adc     a, a
        jr      z, gbg2
        rl      c
        rl      b
        dec     d
        jp      nz, gbcon2
        ex      af, af'
        ld      a, e
        add     a, c
        ld      e, a
        ld      b, d
        ld      c, d
        ld      d, mapbase/256
        ld      a, (de)
        ld      d, a
        ex      af, af'
        dec     d
        jp      p, gbcon3
        jp      gbfin3
dontgo  ld      de, 1024+16
        ld      bc, 0
        jr      goit2
gbg3    ld      a, (hl)
        inc     hl
gbcon3  adc     a, a
        jr      z, gbg3
        rl      c
        rl      b
        dec     d
        jp      p, gbcon3
gbfin3  ex      af, af'
        ld      d, (mapbase/256)+1
        ld      a, (de)
        inc     d
        add     a, c
        ld      c, a
        ld      a, (de)
        adc     a, b
        ld      b, a
        ex      af, af'
        ex      (sp), hl
        ld      d, h
        ld      e, l
        sbc     hl, bc
      IF  rom=1
        ld      c, ixl
        ld      b, ixh
      ELSE
toklen  ld      bc, 0
      ENDIF
        ldir
        pop     hl
        jp      mloop
  ENDIF
