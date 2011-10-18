        output "tetris.bin"
        org   $5ccb
inic    ld    b, 23             ; Dibujar 22 líneas (el primer CR se salta) con "RANDOMIZE " en tinta y fondo negros (se ve una columna negra de 10 caracteres de ancho)
        ld    a, $11            ; Función que cambia el color de fondo
        db    $d7, $c0, $37, $0e, $8f, $39, $96 ; BEEP USR 7 ($5ccb), salta de Basic a CM a inic, el primer rst $10 está incluido en el BEEP, las demas instrucciones no hacen nada útil en CM
        db    $3a               ; xor   a, Opcode para LD A, (NN). En la primera pasada se salta el CR y carga A con el valor 0 (fondo negro)
ini1    rst   $10               ; Función imprime carácter por pantalla, el código ASCII se introduce en el registro A
        ld    a, 13             ; Código ASCII para CR (retorno de carro)
        ld    (velo+1), a       ; Pongo inicialmente a 13 la variable velo (velocidad) que en realidad es el retardo en frames de la caída de una pieza. Es necesario inicializarla porque durante el juego se decrementa y pierde su valor inicial (variable incrustada en código)
        rst   $10               ; Envío por pantalla el retorno de carro (fondo negro en primera iteración)
ini2    ld    a, 249            ; Código ASCII para RANDOMIZE, lo uso porque es el token más largo, que además me da el ancho de 10 cuadros que necesito (contando con el espacio del final)
        djnz  ini1              ; repito el bucle 23 veces (dibujo 22 líneas). Si lo hago tras perder una partida se produce scroll (y la típica pregunta scroll? mas?)
        ld    hl, $0110         ; Inicializo las variables REPDEL, REPPER (frames para detectar una pulsación continua y cadencia en frames del envío de la misma tecla) a unos valores más óptimos para jugar
        ld    ($5c09), hl       ; Los que usa la ROM por defecto son muy lentos para la dinámica del juego

; Aquí saltamos cada vez que necesito
; generar una nueva pieza, porque la
; anterior haya hecho contacto con el suelo.

newp    ld    a, ($5c78)        ; Leo la variable FRAMES1 (byte bajo del contador de frames del sistema, formado por 3 bytes)
mod7    sub   $f9               ; Estas dos líneas equivalen a un MOD 7
        jr    c, mod7           ; o resto de dividir el byte entre 7, ya que necesito elegir una pieza al azar de entre las 7
        inc   a                 ; Le sumo 1 para pasar de rangos 0..6 a 1..7 y así evitar el color negro (que es el fondo)
        ld    l, a              ; Paso dicho valor al registro L para leer pieza de la tabla
        add   a, a              ; Multiplico por 9 (para usar el color tanto en tinta como en fondo, de lo contrario se verían los caracteres del RANDOMIZE)
        add   a, a
        add   a, a
        add   a, l
        ex    af, af            ; Guardo color generado en A'
        ld    de, 6 | 2<<5 | $5800  ; La primera pieza parte de la coordenada (x, y)= (6, 2), en el registro DE guardo la posición
        ld    c, d              ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
        push  de                ; Guardo posición en pila. También guardaré la pieza generada para recuperar en caso de colisión
        ld    h, $5d            ; Posición alta de la tabla de piezas
        ld    l, (hl)           ; Leo byte de la tabla de piezas
        ld    h, b              ; Pongo H a cero, con lo que inicialmente la pieza (almacenada en HL) contiene algo así 00000000XXXXXXXX
        jr    cont              ; Salto la tabla de piezas para no ejecutar datos aleatorios

; Tabla de piezas

        db    %01100110         ;-oo-
                                ;-oo-
        db    %00001111               ;----
                                      ;oooo
        db    %00101110         ;--o-
                                ;ooo-
        db    %01001110               ;-o--
                                      ;ooo-
        db    %01101100         ;-oo-
                                ;oo--
        db    %10001110               ;o---
                                      ;ooo-
        db    %11000110         ;oo--
                                ;-oo-

; Rutina que se ejecuta cada vez
; que una pieza toca el suelo y
; antes de generar una pieza nueva

tlin    ld    hl, 31 | 21<<5 | $5800  ; Parto desde una coordenada (31, 21) que es la parte inferior derecha de la pantalla
tli1    ex    de, hl            ; Almaceno posición en DE
        xor   a                 ; Pongo A a cero (lo usaré en la instrucción CPIR)
        ld    hl, $ffe0         ; Hago que HL apunte 32 bytes por debajo de DE
        add   hl, de
        ld    c, 11             ; Comparo 11 caracteres (el primero es siempre blanco ya que es el situado en la columna 31)
        push  hl                ; Si alguno de los 11 caracteres es negro (línea no rellena)
        cpir                    ; lo detecto activando el flag Z tras la instrucción CPIR
        pop   hl                ; Recupero HL, ya que CPIR modifica su valor
        jr    z, tli1           ; Bucle que voy repitiendo (probando con líneas que están por encima) hasta detectar una falsa línea completa en la ROM (debajo de $4000)
        ld    c, l              ; Pongo BC con el valor justo para que el desplazamiento (machacar la línea completada con las líneas superiores) solo ocurra en la zona de la memoria de video que corresponde a atributos
        ld    a, h
        sub   $58
        jr    c, newp           ; Si me salgo de la zona de atributos es que ya he llegado a la primera línea y por tanto salgo del bucle (a generar una nueva pieza)
        ld    b, a
        lddr                    ; Hago el corrimiento de líneas
        ld    hl, fin           ; Roto el byte marcador (justo al final del código) que inicialmente está a $80
        rrc   (hl)              ; Esto me permite aumentar el nivel de velocidad cada 8 líneas completadas
        jr    nc, tlin
        ld    l, d              ; L apunta a velo+1 (lo he hecho coincidir con D=$58 para ahorrar 1 byte) que es la variable que indica la velocidad de caída de la pieza
        dec   (hl)              ; Decremento retardo de caída de piezas (aumento por tanto la velocidad)
        jr    tlin              ; Cierro bucle

; Continúo tras haber saltado la tabla

cont    add   hl, hl            ; Multiplico por 16 o desplazo 4 bits para tener la
        add   hl, hl            ; pieza centrada y que no resulten extrañas las rotaciones            0000
        add   hl, hl            ; Ahora HL será 0000XXXXXXXX0000, que puesto en retícula queda así--> XXXX
        add   hl, hl            ;                                                                     XXXX
        push  hl                ; Guardo pieza generada en pila                                       0000

; Bucle principal del juego

loop    ld    ixl, opc2         ; IX apunta a la subfunción a llamar (dentro de la función pint), en este caso es la que comprueba si hay colisión antes de pintar la pieza
        call  pint-1            ; Llamo a la función pint para testear la pieza (con -1 ahorro un byte porque PUSH DE coincide con el último byte de la instrucción anterior)
        jr    z, ncol           ; Si no hay colisión, salto a ncol
        pop   hl                ; Si hay colisión, recupero los valores de posición
        pop   de                ; y pieza anteriores a la colisión
        ld    sp, $ff40         ; Equilibro la pila, ya que la estaba desequilibrando con muchos PUSH HL,DE y un sólo POP HL,DE
        bit   2, c              ; Compruebo si en punto de entrada del bucle es haber
        jr    z, inic           ; generado la pieza, en tal caso (con una colisión nada más generar la pieza) reinicio el juego
        inc   c                 ; Señalizo la colisión poniendo a 1 el bit 1 del registro C
ncol    ld    ixl, opc1         ; IX apunta a la subfunción pintar/borrar
        ex    af, af            ; recupero el color de A'
        call  pint-1            ; pinto la pieza
        ex    af, af            ; vuelvo a guardar el color en A'
        bit   1, c              ; Compruebo si ha habido colisión (del tipo colisión contra el suelo, no vale contra paredes ni tras rotar)
        jr    nz, tlin          ; Salto a tlin en caso de ese tipo de colisión
        push  de                ; Guardo posición y pieza en pila
        push  hl
rkey    ld    a, ($5c78)        ; Leo contador de frames
time    sub   0                 ; Comparo con referencia (valor de frames que tenía la pieza antes de descender)
velo    sub   0                 ; Aplico un retardo (número de frames que tarda la pieza en descender)
        jr    z, salt           ; Si se agota el tiempo, la pieza cae por gravedad, salto a "salt"
        bit   5, (iy+1)         ; Mientras tanto voy leyendo si se ha pulsado una tecla
        jr    z, rkey           ; En tal caso, rompo el bucle de tiempo
        ld    a, ($5c08)        ; Con el registro A conteniendo el código ASCII de la tecla pulsada
salt    res   5, (iy+1)         ; Señalizo tecla leída. En este punto si A vale cero es que no se ha pulsado nada y la pieza cae por sí sola
        push  af                ; Guardo tecla pulsada
        xor   a                 ; Borrar es pintar con color 0 (negro)
        call  pint-1            ; Borra pieza
        pop   af                ; Hecupero tecla pulsada
        sub   'o'               ; He pulsado izquierda?
        jr    nz, nizq          ; No, pues salto y no hago nada
        dec   e                 ; Sí, pues decremento posición
nizq    dec   a                 ; He pulsado derecha? sería carácter 'p' justo después de 'o', por eso basta con un decremento para comparar
        jr    nz, nder          ; No, pues salto y no hago nada
        inc   e                 ; Sí, pues incremento posición
nder    dec   a                 ; He pulsado arriba (rotar)? sería carácter 'q', después de 'p'
        ld    c, 1              ; Inicializo A y C a cero y uno respectivamente, independientemente de si salto o no
        jr    z, rota           ; Sí, pues salto a rota (con A y C inicializadas)
        add   'q'-'b'           ; Se ha pulsado una tecla que cae fuera del rango 'b'-'q'? Como por ejemplo 'a', acelerar caída
tloo    ld    bc, $2004         ; Inicializo B a 32 (bajo posición una fila completa) y C a 4 indicando que entro al bucle principal vía pieza no acelerada
        jr    c, loop           ; Si la pieza cae por su peso (ninguna tecla pulsada), cierro bucle principal
        inc   c                 ; Si se ha pulsado 'a' o equivalente, señalizo pieza acelerada en registro C
su32    inc   de                ; Avanza la posición en una fila (32 caracteres)
        djnz  su32
        ld    a, ($5c78)        ; Pongo la actual variable FRAMES1 como referencia en time (variable incrustada en código)
        ld    (time+1), a
        jr    loop              ; Cierro bucle principal

; Una de las dos opciones de subfunción a llamar (En este caso pinta/borra pieza)

opc1    ld    (de), a           ; Pone color A en posición DE
        ret

; Función rotar pieza, el punto de entrada es la etiqueta rota

rot2    djnz  rot1              ; Repito bucle interior 4 veces
        pop   hl                ; Recupero HL de pila
        rr    h                 ; Desplazo HL hacia la derecha
        rr    l
rota    ld    b, 4              ; Pongo contador a 4
        push  hl                ; Guardo HL en pila, ya que no quiero que pierda su valor al desplazarlo 4 veces
rot1    add   hl, hl            ; Desplazo 4 veces HL a la izquierda
        add   hl, hl
        add   hl, hl
        add   hl, hl
        rl    c                 ; Propago el contenido al par de registros (A, C)
        rla
        jr    nc, rot2          ; Como inicialmente (A, C) valía 1, esto me indica que he llegado al bit marcador, por tanto ya he movido 16 bits
        pop   hl                ; Salgo del bucle, pero necesito equilibrar pila (no me importa el valor)
        ld    h, a              ; Finalmente la pieza rotada queda en (A, C), que la muevo a HL
        ld    l, c
        jr    tloo              ; Salto al bucle principal (con indicador de pieza no acelerada)

pint    push  bc                ; Guardo DE, BC y HL en pila (el primer push está oculto en el último byte de la instrucción anterior
        push  hl
pin1    ld    b, 4              ; El bucle interior es de 4 y el exterior es de C, por tanto se repite 4xC veces, siendo C siempre mayor que 4. Como HL no puede tener más de 16 bits sólo se pinta/borra/comprueba colisión en una retícula de 4x4
pin2    add   hl, hl            ; Siguiente bit dentro de la retícula 4x4 a comparar
        jr    nc, pin3          ; Si está a 0 dicho bit, me lo salto
        call  $03f4             ; Si está a 1 realizo una subfunción (pintar/borra o comprobar si hay colisión). La subfunción está apuntada por el registro IX. Como $03f4 en ROM es una instrucción JP (IX), esta instrucción equivaldría a CALL (IX)
pin3    dec   de                ; Voy pintando hacia atrás y de abajo hacia arriba (decrementando DE)
        djnz  pin2              ; Cierro bucle interior
        ld    b, 32-4           ; Como ya he completado 4 bytes de la línea, necesito 28 más para posicionarme en la siguiente línea (en este caso la de arriba)
re28    dec   de                ; Hago la resta vía bucle con djnz, que equivaldría a SUB DE, 28
        djnz  re28
        dec   c                 ; Cierro bucle exterior
        jr    nz, pin1
pin4    pop   hl                ; Si he acabado, recupero HL, BC y DE de la pila y retorno de la subrutina
        pop   bc
        pop   de
        ret

; La segunda de las dos opciones de subfunción a llamar
; En este caso comprueba si la pieza colisiona con otras piezas, las paredes o el suelo

opc2    ld    a, (de)           ; Leo el color (en A) de la posición actual (desde DE)
        or    a                 ; Compruebo si el color es negro (color 0)
        ret   z                 ; Si es negro, retorno de subfunción con carry Z activado (indica no que hay colisión)
        pop   de                ; Si no es negro, hay colisión, lo indico con carry Z desactivo y salgo de la subfunción y de la función pint
        jr    pin4
fin

/*<?php                                 // Estas líneas en PHP generan el archivo TAP, tan sólo hay que ejecutar "PHP ejemplo.asm" desde la línea de comandos y tener php.exe y sjasmplus.exe en el mismo directorio
  require 'zx.inc.php';                 // Librería, extraer desde aquí http://jbacteria.antoniovillena.es/taps/desprot.zip
  exec('sjasmplus tetris.asm');         // Compila la parte ASM del archivo (el código PHP está oculto para SjAsmPlus con comentarios /* */)
  $in= file_get_contents('tetris.bin'); // Leo el binario ya ensamblado
  file_put_contents('salentan.tap',     // Genero y escribo en el archivo .TAP
      head("\26\1\0SA\261\264RI\263", strlen($in)).data($in));
  exec('salentan.tap');                 // Ejecuto el .TAP resultante (lanza emulador tras generar el .TAP)
?>*/