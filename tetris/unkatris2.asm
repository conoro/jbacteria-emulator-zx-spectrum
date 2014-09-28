        output  unkatris2.p
        org     $4009

        define  multi   $4000   ; temporal para multiplicar por 2 los puntos en multilíneas
        define  lncnt   $4001   ; temporal que lleva la cuenta de líneas que faltan
        define  lnini   $4002   ; variable que lleva la cuenta inicial de líneas que faltan
        define  speed   $4003   ; variable que lleva la velocidad de caída de la pieza

VERSN   defb    0
E_PPC   defb    0, 0
D_FILE  defw    dfile
DF_CC   defw    0
VARS    defw    0
DEST    defw    0
E_LINE  defw    eline
CH_ADD  defw    0
X_PTR   defw    0
STKBOT  defw    0
STKEND  defw    0
BERG    defb    0
MEM     defw    0
SPARE1  defb    0
DF_SZ   defb    0
S_TOP   defw    0
LAST_K  defw    $ffff
DB_ST   defb    0
MARGIN  defb    55
NXTLIN  defw    line01
OLDPPC  defw    0
FLAGX   defb    0
STRLEN  defw    0
T_ADDR  defw    0
SEED    defw    0
FRAMES  defw    0               ; Updated once for every TV frame displayed.
; Tabla de piezas
tabla
        db      %01100110       ;-oo-
                                ;-oo-
        db      %00001111             ;----
                                      ;oooo
        db      %01001110       ;-o--
                                ;ooo-
        db      %11000110             ;oo--
                                      ;-oo-
        db      %01101100       ;-oo-
                                ;oo--
CDFLAG  db      %10001110             ;o---
                                      ;ooo-
        db      %00101110       ;--o-
                                ;ooo-

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

inic    ld      l, 2
repet   ld      a, (LAST_K+1)
        inc     a
        jr      z, repet
        sub     11
        ld      h, a
        ld      (lnini), hl     ; speed
        ld      b, $85
        ld      hl, $1c1c
        ld      (score+6-2), hl
        ld      (score+6-4), hl
        ld      (level+6-1), hl
        ld      hl, map-1
        jr      desc2
nxtl    ld      hl, 0
desc1   ld      b, 0
desc2   ld      de, screen+11*20-1
desc3   xor     a
        call    gbit            ; load bitsym bits (literal)
        add     a, 7
        ld      (de), a         ; write literal
desc4   xor     a
        dec     e               ; test end of file (map is always 150 bytes)
        jr      z, tutia
        call    gbit            ; read one bit
        rra
        jr      c, desc3        ; test if literal or sequence
        call    gbitd           ; get two bits
        jr      z, desc6        ; 00 = 1
        dec     a
        call    gbit
        jr      z, desc5        ; 010 = -11
        call    gbitd           ; [011, 100, 101, 110, 111] xx
        add     -13
        jr      z, desc4
desc5   adc     a, 10
desc6   inc     a
        push    de
        ld      e, a
        xor     a
        ld      d, a
        ld      a, 1
desc7   call    nz, gbit        ; (Elias gamma coding)
        call    gbit
        rra
        jr      nc, desc7       ; check end marker
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
        jr      desc4           ; jump to main loop

nnwp    lddr                    ; Hago el corrimiento de líneas
        ld      h, $40
        ld      a, (hl)         ; multi
        sla     (hl)
        ld      l, nxtl & 255
        push    hl
        ld      hl, score+6-1
        call    incr
        dec     (iy+1)          ; lncnt
        jr      nz, tlin
        ld      l, level+6+1 & 255
incrr   dec     l
inc1    ld      a, b
incr    adc     a, (hl)
        cp      28+10
        ld      (hl), a
        ret     c
        add     a, -10
        ld      (hl), a
        jr      incrr

tutia   call    gbitd
        ld      (nxtl+1), hl
        ld      hl, desc1+1
        ld      (hl), b
        ld      b, 3
ripi    ld      c, (hl)
        ld      l, b
        rrca
        jr      nc, ndvel
        inc     (hl)            ; lnini, speed
ndvel   djnz    ripi
        ld      (hl), c         ; lncnt

; Rutina que se ejecuta cada vez
; que una pieza toca el suelo y
; antes de generar una pieza nueva
tutin   ld      a, (LAST_K+1)
        inc     a
        jr      nz, tutin
        ld      (iy), 1         ; multi

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
        jr      z, nnwp         ; Si me salgo de la zona de atributos es que ya he llegado a la primera línea y por tanto salgo del bucle (a generar una nueva pieza)
        ld      d, h
        sbc     hl, hl
        ld      e, h
        call    pint
rand    ld      a, (FRAMES)
        and     7
        jr      z, rand
        call    leep
        call    pint
        sub     $8c
        ld      l, a
        ld      a, (lastp)
        ld      (lastp), hl
        ld      de, screen+1+2*11+6 ; La primera pieza parte de la coordenada (x, y)= (6, 2), en el registro DE guardo la posición
        call    leep

; Bucle principal del juego

loop    ld      a, (FRAMES)     ; Leo contador de frames
        ld      (time+1), a     ; Pongo FRAMES1 (antes guardada en A) como referencia en time (variable incrustada en código)
salop   set     1, (iy+copc+1-$4000)
        call    pint            ; Llamo a la función pint para testear la pieza (con -1 ahorro un byte porque PUSH DE coincide con el último byte de la instrucción anterior)
        res     1, (iy+copc+1-$4000)
        jr      z, ncol         ; Si no hay colisión, salto a ncol
        bit     2, c            ; Compruebo si en punto de entrada del bucle es haber
        jp      z, inic         ; generado la pieza, en tal caso (con una colisión nada más generar la pieza) reinicio el juego
        pop     hl              ; Si hay colisión, recupero los valores de posición
        pop     de              ; y pieza anteriores a la colisión
        inc     c               ; Señalizo la colisión poniendo a 1 el bit 1 del registro C
ncol    ld      sp, eline       ; Equilibro la pila, ya que la estaba desequilibrando con muchos PUSH HL,DE y un sólo POP HL,DE
mico    ld      a, 0
        call    pint            ; pinto la pieza
        bit     1, c            ; Compruebo si ha habido colisión (del tipo colisión contra el suelo, no vale contra paredes ni tras rotar)
        jr      nz, tutin       ; Salto a tlin en caso de ese tipo de colisión
        push    de              ; Guardo posición en pila
        push    hl              ; Guardo pieza en pila
rkey    ld      a, (FRAMES)     ; Leo contador de frames
time    sub     0               ; Comparo con referencia (valor de frames que tenía la pieza antes de descender)
velo    sub     (iy+3)          ; speed Aplico un retardo (número de frames que tarda la pieza en descender)
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
        jr      c, nder         ; No, pues salto y no hago nada
        inc     e               ; Sí, pues incremento posición
nder    sub     $fd
        ld      c, 1            ; Inicializo A y C a cero y uno respectivamente, independientemente de si salto o no
        jr      z, rota         ; Sí, pues salto a rota (con A y C inicializadas)
        add     a, $fd
tloo    ld      bc, $0b04       ; Inicializo B a 11 (bajo posición una fila completa) y C a 4 indicando que entro al bucle principal vía pieza no acelerada
        jr      c, salop        ; Si la pieza cae por su peso (ninguna tecla pulsada), cierro bucle principal
        inc     c               ; Si se ha pulsado 'a' o equivalente, señalizo pieza acelerada en registro C
su32    inc     e               ; Avanza la posición en una fila (32 caracteres)
        djnz    su32
        jr      loop            ; Cierro bucle principal

leep    add     a, tabla-1&255
        ld      l, a            ; Paso dicho valor al registro L para leer pieza de la tabla
        add     a, $8c-tabla+1&255
        ld      (mico+1), a     ; Guardo color generado en A'
        ld      h, tabla>>8     ; Posición alta de la tabla de piezas
        ld      c, h            ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        ld      l, (hl)         ; Leo byte de la tabla de piezas
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ret

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
line01  jr      tloo            ; Salto al bucle principal (con indicador de pieza no acelerada)

        defw    gbit2-line01-4
        defb    $f9, $d4, $25, $7e, $8f, $00, $bc   ; RAND USR $405e

gbit2   ld      b, (hl)         ; load another group of 8 bits
        dec     hl
gbitd   call    nc, gbit
gbit    rl      b               ; get next bit
        jr      z, gbit2        ; no more bits left?
        adc     a, a            ; put bit in a
        ret

        incbin  unkatris.map
map
        block   $4a00-44-$

dfile   defb    $76,49,42,59,42,49,0,135,137,137,132
level   defb    $76,0,0,0,0,31,37,133,136,136,133
        defb    $76,56,40,52,55,42,0,0,3,3,132
score   defb    $76,0,0,135,131,4,28,0,0,135,129
screen  defb    $76,128,5,133,128,5,133,128,5,133,128
        defb    $76,128,5,133,128,5,133,128,5,133,128
        defb    $76,128,186,179,176,166,185,183,174,184,128
        defb    $76,130,4,131,131,4,131,131,4,131,129
        defb    $76,128,5,128,128,5,128,128,5,128,128
        defb    $76,130,131,131,135,131,131,135,131,131,129
        defb    $76,128,128,128,133,128,128,133,128,128,128
        defb    $76,130,4,131,131,4,131,131,4,131,129
        defb    $76,128,5,128,173,166,183,169,5,157,128
        defb    $76,130,131,131,135,131,131,135,131,131,129
        defb    $76,128,158,128,133,159,128,133,128,160,128
        defb    $76,130,4,131,131,4,131,131,4,131,129
        defb    $76,128,5,128,170,166,184,190,5,161,128
        defb    $76,130,131,131,131,131,131,131,131,131,129
        defb    $76,138,128,138,128,1,2,128,128,138,128
        defb    $76,128,138,128,7,0,0,132,138,128,138
        defb    $76,138,128,138,5,27,27,133,128,138,128
        defb    $76,128,138,128,5,0,0,133,138,128,138
        defb    $76,0,0,38,51,57,52,51,46,52,0
        defb    $76,0,0,59,46,49,49,42,51,38,0
        defb    $76

lastp   defw    1

        block   $4afb-$
        defb    $80
eline
