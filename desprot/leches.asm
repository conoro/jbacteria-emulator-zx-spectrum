        output  leches.bin
        org     $8000-21
        ld      de, $8000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; OVER USR 7 ($5ccb)
        ld      hl, $5ccb+21
        push    de
        ld      bc, fin-ruti
        ldir
        ret
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
        ld      e, $fe
        jr      nc, ultr5
        ld      e, $fc
ultr5:  ld      l, $01          ; hl vale 0001, marker para leer 16 bits en hl (checksum y byte flag)
get16:  ld      b, 0            ; 16 bytes
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



        block   $9083-$
        defb          %00001000 ; 83
        defb    0, 0, %00001000 ; 86
        defb    0, 0, %00001000 ; 89
        defb    0, 0, %00001001 ; 8c
        defb    0, 0, %00001001 ; 8f
        defb    0, 0, %00001001 ; 92
        defb    0, 0, %00001001 ; 95
        defb    0, 0, %00001001 ; 98
        defb    0, 0, %00001010 ; 9b
        defb    0, 0, %00001010 ; 9e --
        defb    0, 0, %00001010 ; a1
        defb    0, 0, %00001010 ; a4
        defb    0, 0, %00001010 ; a7
        defb    0, 0, %00001011 ; aa
        defb    0, 0, %00001011 ; ad
        defb    0, 0, %00001011 ; b0
        defb    0, 0, %00001011 ; b3
        defb    0, 0, %00001011 ; b6
        defb    0, 0, 0         ; b9
        defb    0, 0, 0         ; bc
        defb    0, 0            ; be
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

        block   $9183-$
        defb          %00001000 ; 83
        defb    0, 0, %00001000 ; 86
        defb    0, 0, %00001000 ; 89
        defb    0, 0, %00001100 ; 8c
        defb    0, 0, %00001100 ; 8f
        defb    0, 0, %00001100 ; 92
        defb    0, 0, %00001100 ; 95
        defb    0, 0, %00001100 ; 98
        defb    0, 0, %00000000 ; 9b
        defb    0, 0, %00000000 ; 9e --
        defb    0, 0, %00000000 ; a1
        defb    0, 0, %00000000 ; a4
        defb    0, 0, %00000000 ; a7
        defb    0, 0, %00000100 ; aa
        defb    0, 0, %00000100 ; ad
        defb    0, 0, %00000100 ; b0
        defb    0, 0, %00000100 ; b3
        defb    0, 0, %00000100 ; b6
        defb    0, 0, 0         ; b9
        defb    0, 0, 0         ; bc
        defb    0, 0            ; be
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

        block   $9283-$
        defb          %00000000 ; 83
        defb    0, 0, %00000000 ; 86
        defb    0, 0, %00000000 ; 89
        defb    0, 0, %00010000 ; 8c
        defb    0, 0, %00010000 ; 8f
        defb    0, 0, %00010000 ; 92
        defb    0, 0, %00010000 ; 95
        defb    0, 0, %00010000 ; 98
        defb    0, 0, %00100000 ; 9b
        defb    0, 0, %00100000 ; 9e --
        defb    0, 0, %00100000 ; a1
        defb    0, 0, %00100000 ; a4
        defb    0, 0, %00100000 ; a7
        defb    0, 0, %00110000 ; aa
        defb    0, 0, %00110000 ; ad
        defb    0, 0, %00110000 ; b0
        defb    0, 0, %00110000 ; b3
        defb    0, 0, %00110000 ; b6
        defb    0, 0, 0         ; b9
        defb    0, 0, 0         ; bc
        defb    0, 0            ; be
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

        block   $9383-$
        defb          %00000000 ; 83
        defb    0, 0, %00000000 ; 86
        defb    0, 0, %00000000 ; 89
        defb    0, 0, %01000000 ; 8c
        defb    0, 0, %01000000 ; 8f
        defb    0, 0, %01000000 ; 92
        defb    0, 0, %01000000 ; 95
        defb    0, 0, %01000000 ; 98
        defb    0, 0, %10000000 ; 9b
        defb    0, 0, %10000000 ; 9e --
        defb    0, 0, %10000000 ; a1
        defb    0, 0, %10000000 ; a4
        defb    0, 0, %10000000 ; a7
        defb    0, 0, %11000000 ; aa
        defb    0, 0, %11000000 ; ad
        defb    0, 0, %11000000 ; b0
        defb    0, 0, %11000000 ; b3
        defb    0, 0, %11000000 ; b6
        defb    0, 0, 0         ; b9
        defb    0, 0, 0         ; bc
        defb    0, 0            ; be
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
fin:

;1 33+16 49 inch/outc
;2 33+17 50 inch/lda,b/ex af/ret m
;3 33+18 51 inch/incde/ex af/ex af
;4 33+18 51 ld h/ex af/ld(de