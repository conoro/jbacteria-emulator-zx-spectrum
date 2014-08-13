        output  str.p
        define  _SP     $00
        define  _0      $1c
        define  _1      $1d
        define  _2      $1e
        define  _3      $1f
        define  _4      $20
        define  _5      $21
        define  _6      $22
        define  _7      $23
        define  _8      $24
        define  _9      $25
        define  _A      $26
        define  _B      $27
        define  _C      $28
        define  _D      $29
        define  _E      $2a
        define  _F      $2b
        define  _G      $2c
        define  _H      $2d
        define  _I      $2e
        define  _J      $2f
        define  _K      $30
        define  _L      $31
        define  _M      $32
        define  _N      $33
        define  _O      $34
        define  _P      $35
        define  _Q      $36
        define  _R      $37
        define  _S      $38
        define  _T      $39
        define  _U      $3a
        define  _V      $3b
        define  _W      $3c
        define  _X      $3d
        define  _Y      $3e
        define  _Z      $3f
        define  _NL     $76

        org     $4009

VERSN   defb    1, 0
        defb    $12
D_FILE  defw    dfile

inic    call    $02bb
        inc     l
;        ld      a, (LAST_K+1)
;        inc     a
        jr      z, inic

E_LINE  defw    eline

        ld      (iy+2), c
        ld      hl, $1d1c
        ld      (level-1), hl
        ld      (iy+desc1+2-$4000), $80
        jr      inca

LAST_K  defw    $ffff
DB_ST   defb    0
MARGIN  defb    55

gbit2   ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbitd   call    nc, gbit
gbit    rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret

FRAMES  defw    0               ; Updated once for every TV frame displayed.
; Tabla de piezas
tabla
        db      %01100110       ;-oo-
                                ;-oo-
        db      %00001111             ;----
                                      ;oooo
        db      %00101110       ;--o-
                                ;ooo-
        db      %01001110             ;-o--
                                      ;ooo-
        db      %01101100       ;-oo-
                                ;oo--
        db      %10001110             ;o---
                                      ;ooo-
        db      %11000110       ;oo--
                                ;-oo-

; Función polivalente. Se llama tres veces dentro del bucle principal.
; La primera para comprobar si hay algo que obstruya la pieza (suelo, pared, otra pieza).
; La segunda pinta la pieza. La tercera, en caso de no tocar suelo, borra la pieza.

pint    push    de              ; Guardo DE, HL y BC en pila
        push    hl
        push    bc
pin1    ld      b, 4            ; El bucle interior es de 4 y el exterior es de C, por tanto se repite 4xC veces, siendo C siempre mayor que 4. Como HL no puede tener más de 16 bits sólo se pinta/borra/comprueba colisión en una retícula de 4x4
pin2    add     hl, hl          ; Siguiente bit dentro de la retícula 4x4 a comparar
copc    call    c, opc1         ; Si está a 1 realizo una subfunción (pintar/borra o comprobar si hay colisión). La subfunción está apuntada por el registro IX. Como $007c en ROM es una instrucción JP (IX), esta instrucción equivaldría a CALL C, (IX)
        dec     e               ; Voy pintando hacia atrás y de abajo hacia arriba (decrementando DE)
        djnz    pin2            ; Cierro bucle interior
        ld      b, 11-4         ; Como ya he completado 4 bytes de la línea, necesito 7 más para posicionarme en la siguiente línea (en este caso la de arriba)
re28    dec     e               ; Hago la resta vía bucle con djnz, que equivaldría a SUB DE, 7
        djnz    re28
        dec     c               ; Cierro bucle exterior
        jr      nz, pin1
pin4    pop     bc              ; Recupero BC, HL y DE de la pila
        pop     hl
        pop     de
        ret

; Una de las dos opciones de subfunción a llamar (En este caso pinta/borra pieza)

opc1    ld      (de), a         ; Pone color A en posición DE
        ret

; La segunda de las dos opciones de subfunción a llamar
; En este caso comprueba si la pieza colisiona con otras piezas, las paredes o el suelo

opc2    ld      a, (de)         ; Leo el color (en A) de la posición actual (desde DE)
        cp      8               ; Compruebo si el color es negro (color 0)
        ret     z               ; Si es negro, retorno de subfunción con carry Z activado (indica no que hay colisión)
        pop     de              ; Si no es negro, hay colisión, lo indico con carry Z desactivo y salgo de la subfunción y de la función pint
        jr      pin4

inca    dec     h
        ld      (score-1), hl
        ld      (score-3), hl
;        ld      (iy+desc+1-$4000), map-1 & 255
        ld      hl, map-1
        ld      (desc+1), hl
        ld      hl, velo+1
        ld      (hl), 13

nxtl    ld      de, screen+11*20-1
desc      ld      hl, map-1 ;& 255
desc1   ld      bc, $8000       ; marker bit
desc2   xor     a
desc3   call    gbit            ; load bitsym bits (literal)
        ld      a, $08
        jr      z, desc4
        dec a;ld      a, $9b
desc4   ld      (de), a         ; write literal
desc5   dec     e               ; test end of file (map is always 150 bytes)
        jr      z, tutia
        call    gbit            ; read one bit
        rra
        jr      nc, desc2       ; test if literal or sequence
        xor     a
        call    gbitd           ; get two bits
        jr      z, desc9        ; 00 = 1
        dec     a
        call    gbit
        jr      z, desc8        ; 010 = -11
        call    gbitd           ; [011, 100, 101, 110, 111] xx
        sub     13
        jr      z, desc5
desc8   add     a, 10
desc9   inc     a
        push    de
        ld      d, c
        ld      e, a
        xor     a
        inc     a
        defb    $da
desc6   call    gbit            ; (Elias gamma coding)
        call    gbit
        rra
        jr      nc, desc6       ; check end marker
        inc     a               ; adjust length
        ld      c, a            ; save lenth to c
        ld      a, b            ; save b (byte reading) on a
        ld      b, d            ; b= 0 because lddr moves bc bytes
        ex      (sp), hl        ; store source, restore destination
        ex      de, hl          ; HL = destination + offset + 1
        add     hl, de          ; DE = destination
        lddr
        pop     hl              ; restore source address (compressed data)
        ld      b, a            ; restore b register
        inc     e               ; prepare test of end of file
        jr      desc5           ; jump to main loop

tutia  xor     a
        call    gbitd
        ld      (iy+desc1+2-$4000), b
        ld      (desc+1), hl
        ld      b, 2
       ld      hl, velo+1 ;&255
ripi    rrca
        jr      nc, ndvel
        dec     (hl)
ndvel   ld      c, (hl)
    ; dec     h
      ld  h, $40
        ld      l, b
        djnz    ripi
        ld      (hl), c

; Rutina que se ejecuta cada vez
; que una pieza toca el suelo y
; antes de generar una pieza nueva
tutin   ld      a, (LAST_K+1)
        inc     a
        jr      nz, tutin

tlin    ld      hl, screen+20*11  ; Parto desde una coordenada (31, 21) que es la parte inferior derecha de la pantalla
tli1    ex      de, hl          ; Almaceno posición en DE
        ld      a, 8            ; Pongo A a cero (lo usaré en la instrucción CPIR)
        ld      hl, $fff5       ; Hago que HL apunte 32 bytes por debajo de DE
        add     hl, de
        ld      c, 11           ; Comparo 11 caracteres (el primero es siempre blanco ya que es el situado en la columna 31)
        push    hl              ; Si alguno de los 11 caracteres es negro (línea no rellena)
        cpir                    ; lo detecto activando el flag Z tras la instrucción CPIR
        pop     hl              ; Recupero HL, ya que CPIR modifica su valor
        jr      z, tli1         ; Bucle que voy repitiendo (probando con líneas que están por encima) hasta detectar una falsa línea completa en la ROM (debajo de $4000)
;        ld      a, l
;        sub     screen & 255
;        ld      c, a
        ld      c, l
        bit     0, h
;        ld      a, h
;        sbc     a, screen >> 8
        jr      nz, nnwp         ; Si me salgo de la zona de atributos es que ya he llegado a la primera línea y por tanto salgo del bucle (a generar una nueva pieza)
        ;ld hl,  $ffff
       sbc     hl, hl
        ld      de, dfile+4*11-1
        call    pint
rand    ld      a, (FRAMES)
        and     7
        jr      z, rand
        call    leep
        call    pint
        sub     156
        ld      l, a
        ld      a, (VERSN)
        ld      (VERSN), hl
        ld      hl, kaka
        push    hl
        ld      de, screen+1+2*11+6 ;& 255 ; La primera pieza parte de la coordenada (x, y)= (6, 2), en el registro DE guardo la posición
leep    add     a, tabla-1&255
        ld      l, a            ; Paso dicho valor al registro L para leer pieza de la tabla
        add     a, 156-tabla+1&255
        ld      (mico+1), a     ; Guardo color generado en A'
        ld      h, tabla>>8     ; Posición alta de la tabla de piezas
       ld      c, h         ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        ld      l, (hl)         ; Leo byte de la tabla de piezas
        ld      h, b            ; Pongo H a cero, con lo que inicialmente la pieza (almacenada en HL) contiene algo así 00000000XXXXXXXX
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
;        ld      c, 8         ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        ret
nnwp    lddr                    ; Hago el corrimiento de líneas
        ld      hl, score
        ld      a, 6
        call    incr
        inc     (iy+1)
        jr      nz, tlin
        ld      l, level+1 & 255
        ld      de, nxtl
        push    de
incrr   dec     l
inc1    ld      a, 1
incr    add     a, (hl)
        cp      28+10
        ld      (hl), a
        ret     c
        sub     10
        ld      (hl), a
        jr      incrr

; Bucle principal del juego

loop    set     1, (iy+copc+1-$4000)
        call    pint            ; Llamo a la función pint para testear la pieza (con -1 ahorro un byte porque PUSH DE coincide con el último byte de la instrucción anterior)
        res     1, (iy+copc+1-$4000)
        jr      z, ncol         ; Si no hay colisión, salto a ncol
        pop     hl              ; Si hay colisión, recupero los valores de posición
        pop     de              ; y pieza anteriores a la colisión
        bit     2, c            ; Compruebo si en punto de entrada del bucle es haber
       jp      z, inic         ; generado la pieza, en tal caso (con una colisión nada más generar la pieza) reinicio el juego
        inc     c               ; Señalizo la colisión poniendo a 1 el bit 1 del registro C
ncol    ld      sp, $43fe       ; Equilibro la pila, ya que la estaba desequilibrando con muchos PUSH HL,DE y un sólo POP HL,DE
mico    ld      a, 0
        call    pint            ; pinto la pieza
        bit     1, c            ; Compruebo si ha habido colisión (del tipo colisión contra el suelo, no vale contra paredes ni tras rotar)
       jp      nz, tutin       ; Salto a tlin en caso de ese tipo de colisión
        push    de              ; Guardo posición en pila
        push    hl              ; Guardo pieza en pila
rkey    ld      a, (FRAMES)     ; Leo contador de frames
time    sub     0               ; Comparo con referencia (valor de frames que tenía la pieza antes de descender)
velo    add     a, 13           ; Aplico un retardo (número de frames que tarda la pieza en descender)
        jr      z, salt         ; Si se agota el tiempo, la pieza cae por gravedad, salto a "salt"
        ld      a, (LAST_K+1)
        inc     a
        jr      z, trke
        cp      $f8
        jr      z, salt
cmpa    cp      0
trke    ld      (cmpa+1), a
        jr      z, rkey

salt    dec     a
        rrca
        push    af              ; Guardo tecla pulsada
        ld      a, 8            ; Borrar es pintar con color 0 (negro)
        call    pint            ; Borra pieza
        pop     af              ; Recupero tecla pulsada
        rrca
        jr      c, nizq         ; No, pues salto y no hago nada
        dec     e               ; Sí, pues decremento posición
nizq    rrca
        jr      c, nder        ; No, pues salto y no hago nada
        inc     e               ; Sí, pues incremento posición
nder    sub     $fd
        ld      c, 1            ; Inicializo A y C a cero y uno respectivamente, independientemente de si salto o no
        jr      z, rota         ; Sí, pues salto a rota (con A y C inicializadas)
        add     a, $fd
tloo    ld      bc, $0b04       ; Inicializo B a 11 (bajo posición una fila completa) y C a 4 indicando que entro al bucle principal vía pieza no acelerada
        jr      c, loop         ; Si la pieza cae por su peso (ninguna tecla pulsada), cierro bucle principal
        inc     c               ; Si se ha pulsado 'a' o equivalente, señalizo pieza acelerada en registro C
su32    inc     e               ; Avanza la posición en una fila (32 caracteres)
        djnz    su32
kaka    ld      a, (FRAMES)     ; Leo contador de frames
        ld      (time+1), a     ; Pongo FRAMES1 (antes guardada en A) como referencia en time (variable incrustada en código)
        jr      loop            ; Cierro bucle principal

; Función rotar pieza, el punto de entrada es la etiqueta rota

rot2    djnz    rot1            ; Repito bucle interior 4 veces
        pop     hl              ; Recupero HL de pila
        rr      h               ; Desplazo HL hacia la derecha
        rr      l
rota    ld      b, 4            ; Pongo contador a 4
        push    hl              ; Guardo HL en pila, ya que no quiero que pierda su valor al desplazarlo 4 veces
rot1    add     hl, hl          ; Desplazo 4 veces HL a la izquierda
        add     hl, hl
        add     hl, hl
        add     hl, hl
        rl      c               ; Propago el contenido al par de registros (A, C)
        rla
        jr      nc, rot2        ; Como inicialmente (A, C) valía 1, esto me indica que he llegado al bit marcador, por tanto ya he movido 16 bits
        pop     hl              ; Salgo del bucle, pero necesito equilibrar pila (no me importa el valor)
        ld      h, a            ; Finalmente la pieza rotada queda en (A, C), que la muevo a HL
        ld      l, c
        jr      tloo            ; Salto al bucle principal (con indicador de pieza no acelerada)

        incbin  maptetris.bin
map

        block   $4300-44-$, $fe

dfile   defb    _NL
        defb    _L,_E,_V,_E,_L,_SP,_SP,_SP,_SP,_SP
        defb    _NL
        defb    _SP,_SP,_SP,_SP,_0
level   defb    _1,_SP,_SP,_SP,_SP
        defb    _NL
        defb    _S,_C,_O,_R,_E,_SP,_SP,_SP,_SP,_SP
        defb    _NL
        defb    _SP,_0,_0,_0,_0
score   defb    _0,_SP,_SP,_SP,_SP
screen  defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL
    .10 defb    8
        defb    _NL

        display /D, $-$4000
        block   $43fc-$, $fe
        defw    inic

; Start of the variables area used by BASIC.
        nop
        defb    $80
eline


; 1234567890
; level oooo
;       oooo
; score oooo
;       oooo