        output  unkatris.p
        define  _SP     $00
        define  _0      $1c
        define  _1      _0+1
        define  _2      _1+1
        define  _3      _2+1
        define  _4      _3+1
        define  _5      _4+1
        define  _6      _5+1
        define  _7      _6+1
        define  _8      _7+1
        define  _9      _8+1
        define  _A      _9+1
        define  _B      _A+1
        define  _C      _B+1
        define  _D      _C+1
        define  _E      _D+1
        define  _F      _E+1
        define  _G      _F+1
        define  _H      _G+1
        define  _I      _H+1
        define  _J      _I+1
        define  _K      _J+1
        define  _L      _K+1
        define  _M      _L+1
        define  _N      _M+1
        define  _O      _N+1
        define  _P      _O+1
        define  _Q      _P+1
        define  _R      _Q+1
        define  _S      _R+1
        define  _T      _S+1
        define  _U      _T+1
        define  _V      _U+1
        define  _W      _V+1
        define  _X      _W+1
        define  _Y      _X+1
        define  _Z      _Y+1
        define  _NL     $76

        org     $4009

VERSN   defb    1, 0
        defb    $12
D_FILE  defw    dfile

inic    call    $02bb
        inc     l
        jr      z, inic

E_LINE  defw    eline

        ld      (iy+2), c
        ld      hl, $1d1c
        ld      (level+6-1), hl
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
CDFLAG  db      %10001110             ;o---
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
        ld      (score+6-2), hl
        ld      (score+6-4), hl
        ld      hl, map-1
        ld      (desc+1), hl
        ld      (iy+3), 13

nxtl    ld      de, screen+11*20-1
desc    ld      hl, map-1
desc1   ld      bc, $8000       ; marker bit
desc2   xor     a
        call    gbit            ; load bitsym bits (literal)
        add     a, 7
        ld      (de), a         ; write literal
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
        ccf
desc8   adc     a, 10
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

tutia   xor     a
        call    gbitd
        ld      (iy+desc1+2-$4000), b
        ld      (desc+1), hl
        ld      b, 3
        ld      h, $40
ripi    ld      c, (hl)
        ld      l, b
        rrca
        jr      nc, ndvel
        dec     (hl)
ndvel   djnz    ripi
        ld      (hl), c

; Rutina que se ejecuta cada vez
; que una pieza toca el suelo y
; antes de generar una pieza nueva
tutin   ld      a, (LAST_K+1)
        inc     a
        jr      nz, tutin
        ld      (iy), 1

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
        ld      c, l
        bit     0, h
        jr      nz, nnwp         ; Si me salgo de la zona de atributos es que ya he llegado a la primera línea y por tanto salgo del bucle (a generar una nueva pieza)
        ld      d, h
        sbc     hl, hl
        ld      e, h
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
        ld      c, h            ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        ld      l, (hl)         ; Leo byte de la tabla de piezas
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ret
nnwp    lddr                    ; Hago el corrimiento de líneas
        ld      h, $40
        ld      a, (hl)
        sla     (hl)
        ld      hl, score+6-1
        call    incr
        inc     (iy+1)
        jr      nz, tlin
        ld      de, nxtl
        push    de
        ld      l, level+6+1 & 255
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
        bit     2, c            ; Compruebo si en punto de entrada del bucle es haber
        jp      z, inic         ; generado la pieza, en tal caso (con una colisión nada más generar la pieza) reinicio el juego
        pop     hl              ; Si hay colisión, recupero los valores de posición
        pop     de              ; y pieza anteriores a la colisión
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
velo    add     a, (iy+3)       ; Aplico un retardo (número de frames que tarda la pieza en descender)
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

        incbin  unkatris.bin
map

        block   $4300-44-$, $fe

dfile   defb    _NL,49,42,59,42,49,0,135,131,131,4
level   defb    _NL,0,0,0,0,0,0,133,30,28,5
        defb    _NL,56,40,52,55,42,0,133,29,32,5
score   defb    _NL,0,0,0,0,0,28,2,3,3,1
screen  defb    _NL,132,4,0,27,0,5,0,0,132,1
        defb    _NL,131,0,0,0,0,5,27,0,135,129
        defb    _NL,5,0,27,0,0,5,0,27,0,131
        defb    _NL,4,0,0,27,133,132,27,0,0,3
        defb    _NL,132,27,0,0,129,133,131,131,0,133
        defb    _NL,0,0,135,0,5,0,0,133,0,133
        defb    _NL,27,0,133,0,5,133,0,129,4,27
        defb    _NL,0,0,133,3,1,129,4,5,5,0
        defb    _NL,0,0,7,5,0,5,5,1,132,0
        defb    _NL,0,7,5,5,0,5,5,0,133,0
        defb    _NL,133,1,1,1,0,0,0,0,2,5
        defb    _NL,2,137,137,137,137,137,137,137,137,1
        defb    _NL,0,4,4,4,135,135,135,135,131,0
        defb    _NL,0,5,5,7,129,133,6,133,129,0
        defb    _NL,0,130,5,5,133,133,133,133,133,0
        defb    _NL,0,135,131,0,131,135,135,131,0,0
        defb    _NL,136,0,5,2,129,133,133,131,0,136
        defb    _NL,136,0,5,133,133,133,135,129,0,136
        defb    _NL,39,62,0,38,51,57,52,51,46,52
        defb    _NL,22,22,0,59,46,49,49,42,51,38
        defb    _NL

        block   $43fc-$
        defw    inic

; Start of the variables area used by BASIC.
        nop
        defb    $80
eline
