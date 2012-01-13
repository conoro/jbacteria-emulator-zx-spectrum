
        DEFB    $FF, $FF;
        DEFB    $FF, $FF; 2 bytes

L3C03:  LD      (DE),A          ; Una de las dos opciones de subfuncion a llamar (En este caso pinta/borra pieza)
        RET

        DEFB    $FF, $FF, $FF, $FF; 4 bytes

L3C09:  AND     D
        RST     $10
        DEC     (IY+$02)
        LD      IXH,B
L3C10:  LD      B,23            ; Dibujar 22 lineas (el primer CR se salta) con "RANDOMIZE " en tinta y fondo negros (se ve una columna negra de 10 caracteres de ancho)
        LD      A,$11           ; Funcion que cambia el color de fondo
        RST     $10
        DB      $3A             ; xor   a, Opcode para LD A, (NN). En la primera pasada se salta el CR y carga A con el valor 0 (fondo negro)
L3C16:  RST     $10             ; Funcion imprime caracter por pantalla, el codigo ASCII se introduce en el registro A
        LD      A,13            ; Codigo ASCII para CR (retorno de carro)
        LD      (IY-$0B),A      ; Pongo inicialmente a 13 la variable velo (velocidad) que en realidad es el retardo en frames de la caida de una pieza. Es necesario inicializarla porque durante el juego se decrementa y pierde su valor inicial (variable incrustada en codigo)
        RST     $10             ; Envio por pantalla el retorno de carro (fondo negro en primera iteracion)
        LD      A,249           ; Codigo ASCII para RANDOMIZE, lo uso porque es el token mas largo, que ademas me da el ancho de 10 cuadros que necesito (contando con el espacio del final)
        DJNZ    L3C16           ; Repito el bucle 23 veces (dibujo 22 lineas). Si lo hago tras perder una partida se produce scroll (y la tipica pregunta scroll? mas?)
        LD      HL,$0110        ; Inicializo las variables REPDEL, REPPER (frames para detectar una pulsacion continua y cadencia en frames del envio de la misma tecla) a unos valores mas optimos para jugar
        LD      ($5C09),HL      ; Los que usa la ROM por defecto son muy lentos para la dinamica del juego
L3C27:  LD      A,R             ; Leo un numero pseudoaleatorio del registro R
L3C29:  SUB     7               ; Estas dos lineas equivalen a un MOD 7
        JR      NC,L3C29        ; o resto de dividir el byte entre 7, ya que necesito elegir una pieza al azar de entre las 7
        LD      L,A             ; Paso dicho valor al registro L para leer pieza de la tabla
        INC     A
        ADD     A,A             ; Multiplico por 9 (para usar el color tanto en tinta como en fondo, de lo contrario se verian los caracteres del RANDOMIZE)
        ADD     A,A
        ADD     A,A
        ADD     A,L
        AND     $3F
        EX      AF,AF'          ; Guardo color generado en A'
        LD      DE,$5846        ; La primera pieza parte de la coordenada (x, y)= (6, 2), en el registro DE guardo la posicion
        LD      H,$3C           ; Posicion alta de la tabla de piezas
        LD      L,(HL)          ; Leo byte de la tabla de piezas
        LD      H,B             ; Pongo H a cero, con lo que inicialmente la pieza (almacenada en HL) contiene algo asi 00000000XXXXXXXX
        CALL    $0E94           ; Multiplico por 16 o desplazo 4 bits para tener la pieza centrada y que no resulten extranas las rotaciones
        LD      C,D             ; Pongo C a un valor mayor de 4 con los bits 1 y 2 a cero (que indican que entro en el bucle principal desde nueva pieza)
L3C41:  LD      IXL,$F3         ; IX apunta a la subfuncion a llamar (dentro de la funcion L3CDC), en este caso es la que comprueba si hay colision antes de pintar la pieza
        CALL    L3CDC           ; Llamo a la funcion L3CDC para testear la pieza (con -1 ahorro un byte porque PUSH DE coincide con el ultimo byte de la instruccion anterior)
        JR      Z,L3C53         ; Si no hay colision, salto a ncol
        POP     HL              ; Si hay colision, recupero los valores de posicion
        POP     DE              ; y pieza anteriores a la colision
        LD      SP,$FF40        ; Equilibro la pila, ya que la estaba desequilibrando con muchos PUSH HL,DE y un solo POP HL,DE
        BIT     2,C             ; Compruebo si en punto de entrada del bucle es haber
        JR      Z,L3C10         ; generado la pieza, en tal caso (con una colision nada mas generar la pieza) reinicio el juego
        INC     C               ; Senalizo la colision poniendo a 1 el bit 1 del registro C
L3C53:  LD      IXL,$03         ; IX apunta a la subfuncion pintar/borrar
        EX      AF,AF'          ; recupero el color de A'
        CALL    L3CDC           ; pinto la pieza
        EX      AF,AF'          ; vuelvo a guardar el color en A'
        BIT     1,C             ; Compruebo si ha habido colision (del tipo colision contra el suelo, no vale contra paredes ni tras rotar)
        JR      NZ,L3C9E        ; Salto a L3C9E en caso de ese tipo de colision
        PUSH    DE              ; Guardo posicion en pila
L3C60:  LD      A,($5C78)       ; Leo contador de frames
        LD      B,A             ; Lo guardo temporalmente en B
        SUB     (IY)            ; Comparo con referencia (valor de frames que tenia la pieza antes de descender)
        SUB     (IY-$0B)        ; Aplico un retardo (numero de frames que tarda la pieza en descender)
        JR      Z,L3C75         ; Si se agota el tiempo, la pieza cae por gravedad, salto a "salt"
        BIT     5,(IY+1)        ; Mientras tanto voy leyendo si se ha pulsado una tecla
        JR      Z,L3C60         ; En tal caso, rompo el bucle de tiempo
        LD      A,($5C08)       ; Con el registro A conteniendo el codigo ASCII de la tecla pulsada
L3C75:  PUSH    HL              ; Guardo pieza en pila
        CALL    L1F4F           ; res   5, (iy+1). Senalizo tecla leida. En este punto si A vale cero es que no se ha pulsado nada y la pieza cae por si sola
        PUSH    AF              ; Guardo tecla pulsada
        XOR     A               ; Borrar es pintar con color 0 (negro)
        CALL    L3CDC           ; Borra pieza
        POP     AF              ; Recupero tecla pulsada
        SUB     $6F             ; He pulsado izquierda?
        JR      NZ,L3C84        ; No, pues salto y no hago nada
        DEC     E               ; Si, pues decremento posicion
L3C84:  DEC     A               ; He pulsado derecha? seria caracter 'p' justo despues de 'o', por eso basta con un decremento para comparar
        JR      NZ,L3C88        ; No, pues salto y no hago nada
        INC     E               ; Si, pues incremento posicion
L3C88:  DEC     A               ; He pulsado arriba (rotar)? seria caracter 'q', despues de 'p'
        LD      C,1             ; Inicializo A y C a cero y uno respectivamente, independientemente de si salto o no
        JR      Z,L3CCB         ; Si, pues salto a rota (con A y C inicializadas)
        ADD     $0F             ; Se ha pulsado una tecla que cae fuera del rango 'b'-'q'? Como por ejemplo 'a', acelerar caida
        LD      A,B             ; Pongo la actual variable FRAMES1 de B a A
L3C90:  LD      BC,$2004        ; Inicializo B a 32 (bajo posicion una fila completa) y C a 4 indicando que entro al bucle principal via pieza no acelerada
        JR      C,L3C41         ; Si la pieza cae por su peso (ninguna tecla pulsada), cierro bucle principal
        INC     C               ; Si se ha pulsado 'a' o equivalente, senalizo pieza acelerada en registro C
L3C96:  INC     DE              ; Avanza la posicion en una fila (32 caracteres)
        DJNZ    L3C96
        LD      (IY),A          ; Pongo FRAMES1 (antes guardada en A) como referencia en time (variable incrustada en codigo)
        JR      L3C41           ; Cierro bucle principal
L3C9E:  LD      HL,$5ABF        ; Parto desde una coordenada (31, 21) que es la parte inferior derecha de la pantalla
L3CA1:  EX      DE,HL           ; Almaceno posicion en DE
        XOR     A               ; Pongo A a cero (lo usare en la instruccion CPIR)
        LD      HL,$FFE0        ; Hago que HL apunte 32 bytes por debajo de DE
        ADD     HL,DE
        LD      C,11            ; Comparo 11 caracteres (el primero es siempre blanco ya que es el situado en la columna 31)
        PUSH    HL              ; Si alguno de los 11 caracteres es negro (linea no rellena)
        CPIR                    ; lo detecto activando el flag Z tras la instruccion CPIR
        POP     HL              ; Recupero HL, ya que CPIR modifica su valor
        JR      Z,L3CA1         ; Bucle que voy repitiendo (probando con lineas que estan por encima) hasta detectar una falsa linea completa en la ROM (debajo de $4000)
        LD      C,L             ; Pongo BC con el valor justo para que el desplazamiento (machacar la linea completada con las lineas superiores) solo ocurra en la zona de la memoria de video que corresponde a atributos
        LD      A,H
        SUB     $58
        JP      C,L3C27         ; Si me salgo de la zona de atributos es que ya he llegado a la primera linea y por tanto salgo del bucle (a generar una nueva pieza)
        LD      B,A
        LDDR                    ; Hago el corrimiento de lineas
        RLC     (IY-$22)        ; Esto me permite aumentar el nivel de velocidad cada 8 lineas completadas
        JR      NC,L3C9E
        DEC     (IY-$0B)        ; Decremento retardo de caida de piezas (aumento por tanto la velocidad)
        JR      L3C9E           ; Cierro bucle
L3CC4:  DJNZ    L3CCE           ; Repito bucle interior 4 veces
        POP     HL              ; Recupero HL de pila
        RR      H               ; Desplazo HL hacia la derecha
        RR      L
L3CCB:  LD      B,4             ; Pongo contador a 4
        PUSH    HL              ; Guardo HL en pila, ya que no quiero que pierda su valor al desplazarlo 4 veces
L3CCE:  ADD     HL,HL           ; Desplazo 4 veces HL a la izquierda
        ADD     HL,HL
        ADD     HL,HL
        ADD     HL,HL
        RL      C               ; Propago el contenido al par de registros (A, C)
        RLA
        JR      NC,L3CC4        ; Como inicialmente (A, C) valia 1, esto me indica que he llegado al bit marcador, por tanto ya he movido 16 bits
        POP     HL              ; Salgo del bucle, pero necesito equilibrar pila (no me importa el valor)
        LD      H,A             ; Finalmente la pieza rotada queda en (A, C), que la muevo a HL
        LD      L,C
        JR      L3C90           ; Salto al bucle principal (con indicador de pieza no acelerada)
L3CDC:  PUSH    DE              ; Guardo DE, HL y BC en pila
        PUSH    HL
        PUSH    BC
L3CDF:  LD      B,4             ; El bucle interior es de 4 y el exterior es de C, por tanto se repite 4xC veces, siendo C siempre mayor que 4. Como HL no puede tener mas de 16 bits solo se pinta/borra/comprueba colision en una reticula de 4x4
L3CE1:  ADD     HL,HL           ; Siguiente bit dentro de la reticula 4x4 a comparar
        CALL    C,$03F4         ; Si esta a 1 realizo una subfuncion (pintar/borra o comprobar si hay colision). La subfuncion esta apuntada por el registro IX. Como $03f4 en ROM es una instruccion JP (IX), esta instruccion equivaldria a CALL C, (IX)
        DEC     DE              ; Voy pintando hacia atras y de abajo hacia arriba (decrementando DE)
        DJNZ    L3CE1           ; Cierro bucle interior
        LD      B,28            ; Como ya he completado 4 bytes de la linea, necesito 28 mas para posicionarme en la siguiente linea (en este caso la de arriba)
L3CEA:  DEC     DE              ; Hago la resta via bucle con djnz, que equivaldria a SUB DE, 28
        DJNZ    L3CEA
        DEC     C               ; Cierro bucle exterior
        JR      NZ,L3CDF
L3CF0:  POP     BC              ; Recupero BC, HL y DE de la pila
        JP      $1A45
        OR      A               ; Compruebo si el color es negro (color 0)
        RET     Z               ; Si es negro, retorno de subfuncion con carry Z activado (indica no que hay colision)
        POP     DE              ; Si no es negro, hay colision, lo indico con carry Z desactivo y salgo de la subfuncion y de la funcion L3CDC
        JR      L3CF0

L3CF9:  DEFB    $66, $0F, $2E, $4E, $6C, $8E, $C6;
