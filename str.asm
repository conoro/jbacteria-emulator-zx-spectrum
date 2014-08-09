        output  str.p
_SPC    equ     $00
_0      equ     $1c
_1      equ     $1d
_2      equ     $1e
_3      equ     $1f
_4      equ     $20
_5      equ     $21
_6      equ     $22
_7      equ     $23
_8      equ     $24
_9      equ     $25
_A      equ     $26
_B      equ     $27
_C      equ     $28
_D      equ     $29
_E      equ     $2a
_F      equ     $2b
_G      equ     $2c
_H      equ     $2d
_I      equ     $2e
_J      equ     $2f
_K      equ     $30
_L      equ     $31
_M      equ     $32
_N      equ     $33
_O      equ     $34
_P      equ     $35
_Q      equ     $36
_R      equ     $37
_S      equ     $38
_T      equ     $39
_U      equ     $3a
_V      equ     $3b
_W      equ     $3c
_X      equ     $3d
_Y      equ     $3e
_Z      equ     $3f
_NL     equ     $76

                org     $4009

VERSN:          defb    1, 0
                defb    $12
D_FILE:         defw    dfile
DF_CC:          defw    $1234
VARS:           defw    $1234

DEST:           defw    $1234
E_LINE:         defw    eline
CH_ADD:         defw    $1234
X_PTR:          defw    $1234
STKBOT:         defw    $1234
STKEND:         defw    $1234
BERG:           defb    $12
MEM:            defw    $1234
SPARE1:         defb    $12
DF_SZ:          defb    $12
S_TOP:          defw    $1234
LAST_K:         defw    $ffff
DB_ST:          defb    0
MARGIN:         defb    55
NXTLIN:         defw    $1234           ; Memory address of next program line to be executed.
OLDPPC:         defw    $1234
FLAGX:          defb    $12
STRLEN:         defw    $1234
T_ADDR:         defw    $1234
SEED:           defw    $1234
FRAMES:         defw    0               ; Updated once for every TV frame displayed.
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
MEMBOT: push    hl
        push    bc
pin1    ld      b, 4            ; El bucle interior es de 4 y el exterior es de C, por tanto se repite 4xC veces, siendo C siempre mayor que 4. Como HL no puede tener más de 16 bits sólo se pinta/borra/comprueba colisión en una retícula de 4x4
pin2    add     hl, hl          ; Siguiente bit dentro de la retícula 4x4 a comparar
copc    call    c, opc1         ; Si está a 1 realizo una subfunción (pintar/borra o comprobar si hay colisión). La subfunción está apuntada por el registro IX. Como $007c en ROM es una instrucción JP (IX), esta instrucción equivaldría a CALL C, (IX)
        dec     de              ; Voy pintando hacia atrás y de abajo hacia arriba (decrementando DE)
        djnz    pin2            ; Cierro bucle interior
        ld      b, 11-4         ; Como ya he completado 4 bytes de la línea, necesito 7 más para posicionarme en la siguiente línea (en este caso la de arriba)
re28    dec     de              ; Hago la resta vía bucle con djnz, que equivaldría a SUB DE, 7
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

inic:   ld      a, (LAST_K+1)
        inc     a
        jr      z, inic
        ld      hl, screen+1
        ld      c, 20
isylp:  ld      b, 10
isxlp:  ld      (hl), 8
        inc     hl
        djnz    isxlp
        inc     hl
        dec     c
        jr      nz, isylp

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
        ld      a, l
        sub     screen & 255
        ld      c, a
        ld      a, h
        sbc     a, screen >> 8
        jr      c, newp         ; Si me salgo de la zona de atributos es que ya he llegado a la primera línea y por tanto salgo del bucle (a generar una nueva pieza)
        lddr                    ; Hago el corrimiento de líneas
;        rrc     (iy-$3e)        ; Esto me permite aumentar el nivel de velocidad cada 8 líneas completadas
;        jr      nc, tlin
;        dec     (iy+velo+1-opc1); Decremento retardo de caída de piezas (aumento por tanto la velocidad)
        jr      tlin            ; Cierro bucle


newp    
        push    de
        ld      hl, $0ef0
        xor     a
        ld      de, dfile+3*11-1
        call    pint

rand    ld      a, (FRAMES)
        and     7
        jr      z, rand

        call    leep
        ld      e, dfile+3*11-1 & 255
        call    pint
        pop     de

        sub     156
        ld      l, a
        ld      a, (VERSN)
        ld      (VERSN), hl
        ld      hl, kaka
        push    hl
leep    add     a, tabla-1&255
        ld      l, a            ; Paso dicho valor al registro L para leer pieza de la tabla
        add     a, 156-tabla+1&255
        ld      (mico+1), a     ; Guardo color generado en A'
        ld      de, screen+1+2*11+6 ; La primera pieza parte de la coordenada (x, y)= (6, 2), en el registro DE guardo la posición
        ld      h, $40          ; Posición alta de la tabla de piezas
        ld      l, (hl)         ; Leo byte de la tabla de piezas
        ld      h, b            ; Pongo H a cero, con lo que inicialmente la pieza (almacenada en HL) contiene algo así 00000000XXXXXXXX
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, hl
        ld      c, 8            ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        ret

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
su32    inc     de              ; Avanza la posición en una fila (32 caracteres)
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

dfile   defb    _NL
        defb    _L,_E,_V,_E,_L,_SPC,_SPC,_SPC,_SPC,_SPC
        defb    _NL
        defb    _SPC,_SPC,_SPC,_SPC,_1,_SPC,_SPC,_SPC,_SPC,_SPC
        defb    _NL
        defb    _S,_C,_O,_R,_E,_SPC,_SPC,_SPC,_SPC,_SPC
        defb    _NL
        defb    _SPC,_SPC,_SPC,_SPC,_0,_SPC,_SPC,_SPC,_SPC,_SPC
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
     .5 defb    _NL

        display /D, $-$4000
        block   $43fc-$, $fe
        defw    inic

; Start of the variables area used by BASIC.

        defb    $80
eline:


; 1234567890
; level oooo
;       oooo
; score oooo
;       oooo