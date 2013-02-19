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
        ld      l, $01          ; hl vale 0001, marker para leer 16 bits en hl (checksum y byte flag)
get16:  ld      b, 0            ; 16 bytes
        call    $05ed           ; esta rutina lee 2 pulsos e inicializa el contador de pulsos
        call    $05ed
        ld      a, b
        cp      12
        adc     hl, hl
        jr      nc, get16
        pop     af              ; machaco la direccion de retorno de la carga estandar
        ex      af, af'         ; a es el byte flag que espero
        cp      l               ; lo comparo con el que me encuentro en la ultracarga
        ret     nz              ; salgo si no coinciden
        xor     h               ; xoreo el checksum con en byte flag, resultado en a
        exx                     ; guardo checksum por duplicado en h' y l'
        push    hl              ; pongo direccion de comienzo en pila
        ld      c, a
        exx
        pop     de              ; recupero en de la direccion de comienzo del bloque
        ld      bc, $effe       ; este valor es el que necesita b para entrar en raudo
        ld      h, $37
ultr7:  in      f, (c)
        jp      pe, ultr7
        call    l90bf           ; salto a raudo segun el signo del pulso en flag z
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


        block   $90bf-$
l90bf:  ret

fin: