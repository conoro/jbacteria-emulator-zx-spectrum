      macro     table val0, val1, val2, val3
        defb    val0, 0, val0   ; 81 83
        defb    val0, 0, val0   ; 84 86
        defb    val0, 0, val0   ; 87 89
        defb    val1, 0, val1   ; 8a 8c
        defb    val1, 0, val1   ; 8d 8f
        defb    val1, 0, val1   ; 90 92
        defb    val1, 0, val1   ; 93 95
        defb    val1, 0, val2   ; 96 98
        defb    val2, 0, val2   ; 99 9b -
        defb    val2, 0, val2   ; 9c 9e
        defb    val2, 0, val2   ; 9f a1
        defb    val2, 0, val2   ; a2 a4
        defb    val2, 0, val3   ; a5 a7
        defb    val3, 0, val3   ; a8 aa
        defb    val3, 0, val3   ; ab ad
        defb    val3, 0, val3   ; ae b0
        defb    val3, 0, val3   ; b1 b3
        defb    val3            ; b4
      endm
        output  leches_normal.bin
        org     $8000
ruti:   ld      ix, $4000
        ld      de, $1b00
        ld      a, $12
        call    ultra
binf:   jr      binf

ultra:  ex      af, af'
        push    ix              ; 133 bytes
        pop     hl              ; pongo la direccion de comienzo en hl
        exx                     ; salvo de, en caso de volver al cargador estandar y para hacer luego el checksum
        ld      c, $00
ultr0:  defb    $2a
ultr1:  jr      nz, ultr3       ; return if at any time space is pressed.
ultr2:  ld      b,0
        call    $05ed           ; leo la duracion de un pulso (positivo o negativo)
        jr      nc, ultr1       ; si el pulso es muy largo retorno a bucle
        ld      a, b
        cp      40              ; si el contador esta entre 24 y 40
        jr      nc, ultr4       ; y se reciben 8 pulsos (me falta inicializar hl a 00ff)
        cp      24
        rl      l
        jr      nz, ultr4
ultr3:  exx
        ld      c, 2
        ret
ultr4:  cp      16              ; si el contador esta entre 10 y 16 es el tono guia
        rr      h               ; de las ultracargas, si los ultimos 8 pulsos
        cp      10              ; son de tono guia h debe valer ff
        jr      nc, ultr2
        inc     h
        inc     h
        jr      nz, ultr0       ; si detecto sincronismo sin 8 pulsos de tono guia retorno a bucle
        call    $05ed           ; leo pulso negativo de sincronismo
        ld      a, b
        cp      5
        ld      de, $00fc
        jr      nc, ultr5
        ld      e, $fe
ultr5:  ld      l, $01          ; hl vale 0001, marker para leer 16 bits en hl (checksum y byte flag)
get16:  ld      b, d            ; 16 bytes
        call    $05ed           ; esta rutina lee 2 pulsos e inicializa el contador de pulsos
        call    $05ed
        ld      a, b
        cp      12
        adc     hl, hl
        jr      nc, get16
        ex      af, af'         ; a es el byte flag que espero
        cp      l               ; lo comparo con el que me encuentro en la ultracarga
        ret     nz              ; salgo si no coinciden
        xor     h               ; xoreo el checksum con en byte flag, resultado en a
        exx                     ; guardo checksum por duplicado en h' y l'
        push    hl              ; pongo direccion de comienzo en pila
        ld      c, a
        exx
        ld      c, e            ; este valor es el que necesita b para entrar en raudo
        pop     de              ; recupero en de la direccion de comienzo del bloque
        dec     de
ultr7:  in      f, (c)
        jp      po, ultr7
        call    l9405           ; salto a raudo segun el signo del pulso en flag z
        exx                     ; ya se ha acabado la ultracarga (raudo)
        ld      b, e
        ld      e, c
        ld      c, d
        xor     a
        cp      b
        jr      z, ult10
        inc     c
ult10:  xor     (hl)
        inc     hl
        djnz    ult10
        dec     c
        jp      nz, ult10
        xor     e
ult11:  push    hl              ; ha ido bien
        ld      h, b
        ld      l, e
        ld      d, b
        ld      e, b
        pop     ix              ; ix debe apuntar al siguiente byte despues del bloque
        ret     nz              ; si no coincide el checksum salgo con carry desactivado
        scf
        ret

        block   $9081-$
        table   %10001000, %10001001, %10001010, %10001011
        block   $90bf-$
        ld      a, r            ;9  49
        ld      l, a            ;4
        ld      b, (hl)         ;7
        out     (c), b          ;12
        ld      a, c            ;4
        inc     h               ;4
        ld      r, a            ;9
        in      l, (c)        
        jp      (hl)        
        block   $90ff-$
        in      l, (c)        
        jp      (hl)        

        block   $9181-$
        table   %10001000, %10001100, %10000000, %10000100
        block   $91bf-$
        in      l, (c)        
        jp      (hl)        
        block   $91ff-$
        ld      a, r            ;9  50
        ld      l, a            ;4  
        ld      a, b            ;4
        xor     (hl)            ;7
        ret     m               ;5
        ex      af, af'         ;4
        ld      a, c            ;4
        inc     h               ;4
        ld      r, a            ;9
        in      l, (c)        
        jp      (hl)        

        block   $9281-$
        table   %00000000, %00010000, %00100000, %00110000
        block   $92bf-$
        ld      a, r            ;9  51
        ld      l, a            ;4
        inc     de              ;6
        ex      af, af'         ;4
        or      (hl)            ;7
        ex      af, af'         ;4
        ld      a, c            ;4
        inc     h               ;4
        ld      r, a            ;9
        in      l, (c)        
        jp      (hl)        
        block   $92ff-$
        in      l, (c)        
        jp      (hl)        

        block   $9381-$
        table   %00000000, %01000000, %10000000, %11000000
        block   $93bf-$
        in      l, (c)        
        jp      (hl)        
        block   $93ff-$
        ld      a, r            ;9  51
        ld      l, a            ;4  
        ex      af, af'         ;4
        or      (hl)            ;7
        ld      (de), a         ;7
l9405:  ld      a, c            ;4
        ld      h, $90          ;7
        ld      r, a            ;9
        in      l, (c)
        jp      (hl)
;1 33+16 49 inch/outc
;2 33+17 50 inch/lda,b/ex af/ret m
;3 33+18 51 inch/incde/ex af/ex af
;4 33+18 51 ld h/ex af/ld(de