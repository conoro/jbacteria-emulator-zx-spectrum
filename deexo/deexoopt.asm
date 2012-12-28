; Original code by Metalbrain
; Optimizations by Antonio Villena and Urusergi
; normal:   exomizer raw <input_file> -c -o <intermediate_file>
;           exoopt <intermediate_file> <output_file>
; reverse:  exomizer raw <input_file> -b -r -c -o <intermediate_file>
;           exoopt <intermediate_file> <output_file> -r
; SIZE  speed 0   speed 1   speed 2   speed 3
; forw      148       150       166       203
; back      146       148       164       201
;        output  deexoopt.bin
;        define  mapbase  $5b00
;        define  speed    3
;        define  back     0
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      iy, 256+mapbase/256*256
      ELSE
        ld      iy, (mapbase+16)/256*256+112
      ENDIF
        ld      a, 128
        ld      b, 52
        push    de
        cp      a
init    ld      c, 16
        jr      nz, get4
        ld      de, 1
        ld      ixl, c
      IF  speed=0
get4    call    getbit
      ENDIF
      IF  speed=1
get4    add     a, a
        call    z, getbit
      ENDIF
      IF  speed=2 OR speed=3
        defb    218
gb4     ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
get4    adc     a, a
        jr      z, gb4
      ENDIF
        rl      c
        jr      nc, get4
    IF  speed=0 OR speed=1
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-256+mapbase-mapbase/256*256), c
      ELSE
        ld      (iy-112+mapbase-(mapbase+16)/256*256), c
      ENDIF
        push    hl
        ld      hl, 1
        defb    210
    ENDIF
    IF  speed=2
        inc     c
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-256+mapbase-mapbase/256*256), c
      ELSE
        ld      (iy-112+mapbase-(mapbase+16)/256*256), c
      ENDIF
        push    hl
        ld      hl, 1
        defb    48
    ENDIF
    IF  speed=3
        ex      af, af'
        ld      a, c
        cp      8
        jr      c, get5
        xor     136
get5    inc     a
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-256+mapbase-mapbase/256*256), a
      ELSE
        ld      (iy-112+mapbase-(mapbase+16)/256*256), a
      ENDIF
        push    hl
        ld      hl, 1
        ex      af, af'
        defb    210
    ENDIF
setbit  add     hl, hl
        dec     c
        jr      nz, setbit
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-204+mapbase-mapbase/256*256), e
        ld      (iy-152+mapbase-mapbase/256*256), d
      ELSE
        ld      (iy-60+mapbase-(mapbase+16)/256*256), e
        ld      (iy-8+mapbase-(mapbase+16)/256*256), d
      ENDIF
        add     hl, de
        ex      de, hl
        inc     iyl
        pop     hl
        dec     ixl
        djnz    init
        pop     de
litcop  
      IF  back=1
        ldd
      ELSE
        ldi
      ENDIF
mloop 
    IF  speed=0
        call    getbit
        jr      c, litcop
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, 256-1
      ELSE
        ld      c, 112-1
      ENDIF
getind  call    getbit
    ENDIF
    IF  speed=1
        add     a, a
        call    z, getbit
        jr      c, litcop
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, 256-1
      ELSE
        ld      c, 112-1
      ENDIF
getind  add     a, a
        call    z, getbit
    ENDIF
    IF  speed=2 OR speed=3
        add     a, a
        jr      z, gbm
        jr      c, litcop
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
gbmc    ld      c, 256-1
      ELSE
gbmc    ld      c, 112-1
      ENDIF
getind  add     a, a
        jr      z, gbi
    ENDIF
gbic    inc     c
        jr      c, getind
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        bit     4, c
        ret     nz
      ELSE
        ret     m
      ENDIF
        push    de
        ld      iyl, c
    IF  speed=2 OR speed=3
        ld      de, 0
    ENDIF
    IF  speed=3
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      b, (iy-256+mapbase-mapbase/256*256)
      ELSE
        ld      b, (iy-112+mapbase-(mapbase+16)/256*256)
      ENDIF
        dec     b
        call    nz, getbits
        ex      de, hl
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, (iy-204+mapbase-mapbase/256*256)
        ld      b, (iy-152+mapbase-mapbase/256*256)
      ELSE
        ld      c, (iy-60+mapbase-(mapbase+16)/256*256)
        ld      b, (iy-8+mapbase-(mapbase+16)/256*256)
      ENDIF
        add     hl, bc
        ex      de, hl
    ELSE
        call    getpair
    ENDIF
        push    de
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      bc, 512+48
        dec     e
        jr      z, goit
        dec     e
        ld      bc, 1024+32
        jr      z, goit
        ld      c, 16
      ELSE
        ld      bc, 512+160
        dec     e
        jr      z, goit
        dec     e
        ld      bc, 1024+144
        jr      z, goit
        ld      c, 128
      ENDIF
    IF  speed=0 OR speed=1
goit    call    getbits
    ENDIF
    IF  speed=2
        ld      e, 0
goit    ld      d, e
        call    getbits
    ENDIF
    IF  speed=3
        ld      e, 0
goit    ld      d, e
        call    lee8
    ENDIF
        ld      iyl, c
        add     iy, de
    IF  speed=2 OR speed=3
        ld      e, d
    ENDIF
    IF  speed=3
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      b, (iy-256+mapbase-mapbase/256*256)
      ELSE
        ld      b, (iy-112+mapbase-(mapbase+16)/256*256)
      ENDIF
        dec     b
        call    nz, getbits
        ex      de, hl
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, (iy-204+mapbase-mapbase/256*256)
        ld      b, (iy-152+mapbase-mapbase/256*256)
      ELSE
        ld      c, (iy-60+mapbase-(mapbase+16)/256*256)
        ld      b, (iy-8+mapbase-(mapbase+16)/256*256)
      ENDIF
        add     hl, bc
        ex      de, hl
    ELSE
        call    getpair
    ENDIF
        pop     bc
        ex      (sp), hl
      IF  back=1
        ex      de, hl
        add     hl, de
        lddr
      ELSE
        push    hl
        sbc     hl, de
        pop     de
        ldir
      ENDIF
        pop     hl
        jr      mloop
    IF  speed=2 OR speed=3
gbm     ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
        adc     a, a
        jr      nc, gbmc
        jp      litcop
gbi     ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
        adc     a, a
        jp      gbic
    ENDIF
    IF  speed=3
getbits jp      p, lee8
        ld      e, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
        rl      b
        ret     z
        srl     b
        defb    250
xopy    ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
lee16   adc     a, a
        jr      z, xopy
        rl      d
        djnz    lee16
        ret
copy    ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
lee8    adc     a, a
        jr      z, copy
        rl      e
        djnz    lee8
        ret
    ELSE
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
getpair ld      b, (iy-256+mapbase-mapbase/256*256)
      ELSE
getpair ld      b, (iy-112+mapbase-(mapbase+16)/256*256)
      ENDIF
      IF speed=2
        dec     b
        call    nz, getbits
      ELSE
        call    getbits
      ENDIF
        ex      de, hl
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, (iy-204+mapbase-mapbase/256*256)
        ld      b, (iy-152+mapbase-mapbase/256*256)
      ELSE
        ld      c, (iy-60+mapbase-(mapbase+16)/256*256)
        ld      b, (iy-8+mapbase-(mapbase+16)/256*256)
      ENDIF
        add     hl, bc
        ex      de, hl
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
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
        adc     a, a
        ret
      ELSE
getbit  ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
        adc     a, a
        ret
      ENDIF
    ENDIF
    IF  speed=2
gbg     ld      a, (hl)
        IF  back=1
        dec     hl
        ELSE
        inc     hl
        ENDIF
getbits adc     a, a
        jr      z, gbg
        rl      e
        rl      d
        djnz    getbits
        ret
    ENDIF