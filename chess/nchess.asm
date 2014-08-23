        output  nchess.bin
        org     $4000

        define  MOVCNT  PRBUFF+10

        defb    0, $80

POINTS  defs    5
BEST    defs    5

D_FILE  defw    _dfile
PIECE   defw    0
PPC     defw    0

DEST    defw    0
E_LINE  defw    $4401

        defs    15

LAST_K  defw    $ffff
DB_ST   defb    0
MARGIN  defb    55

TKING   defb    1, 11, -1, -11, -10, -12, 12, 10
TPAWN   defb    11, 10, 12
FRAMES  defw    0
TKNGHT  defb    13, -13, 21, -21, 23, -23, -9, 9

PRBUFF  defs    28

MOVBUF  defs    28

; 66 bytes
DRIVER  ld      b, 5            ; borra el último movimiento
        ld      a, 8            ; introducido por teclado
        ld      hl, ultlin
DRIVER1 inc     hl
        ld      (hl), a
        djnz    DRIVER1
        call    KYBD            ; lee coordenada inicio
        cp      3               ; si color pieza inválido
        jr      nz, DRIVER      ; salto a DRIVER borrando movimiento
        ld      (PPC), hl       ; almaceno posición pieza en PPC
        ld      e, l            ; también en E
        call    MOVE            ; hacer la lista de movimientos legales
        ld      hl, ultlin+2    ; apunto a la zona para imprimir coordenada final
        call    KYBD            ; leo coordenada final
        cp      2               ; si posición inválida o pieza negra (de mi color)
        ex      de, hl          ; salto a DRIVER borrando movimiento
        jr      nc, DRIVER      ; en caso contrario pongo en E la posición de la pieza
DRIVER2 call    TL              ; Comprueba si hay más movimientos en la lista y
        jr      z, DRIVER       ; extrae el último, si no quedan movimientos salto a DRIVER
        cp      c               ; veo si la posición final está en la lista de movimientos
        jr      nz, DRIVER2     ; si no está repito hasta vaciar la lista
        xor     a               ; poner mejor puntuación del tablero
        ld      (BEST), a       ; inicialmente a cero
        call    PMOVE           ; hacer tentativa de movimiento
        ld      a, (BEST)       ; leer puntuación
        cp      0               ; comparo si vale cero (hay jaque) y salto a DRIVER
        jr      z, DRIVER       ; si no resuelvo el jaque la jugada es inválida
        call    CHGSQ           ; realizar movimiento y cambiar turno
        call    MPSCAN          ; juega la máquina
        jr      DRIVER          ; repito bucle (ahora le toca al jugador)

; 30 bytes
TKP     push    hl              ; rutina que lee tecla
TKP1    push    bc
TKP2    call    $02bb           ; leo filas y columnas en HL
        ld      b, h            ; las paso a BC
        ld      c, l
        ld      d, l            ; comparo columna con $ff
        inc     d               ; para ver si se hay una tecla pulsada
        jr      z, TKP2         ; sino, salto a TKP2 y vuelvo a escanear teclado
        call    $07bd           ; decodifica en (HL) la tecla leída
        ld      a, (hl)         ; leo tecla decodificada en A
        pop     bc              ; leo margen a aceptar
        push    bc
TKP3    cp      c               ; si estoy dentro de margen (de 1 a 8 o de A a H)
        jr      z, TKP4         ; salto a TKP4
        inc     c
        djnz    TKP3
        pop     bc              ; si estoy fuera de margen recupero BC de pila
        jr      TKP1            ; y sigo escaneando teclas
TKP4    pop     bc
        pop     hl              ; si la tecla es válida
        ld      (hl), a         ; la almaceno en (HL) y salgo
        ret

; 75 bytes
KYBD    ld      bc, $081d       ; margen de tecla leída entre '1' y '8'
        call    TKP             ; leo el número
        dec     hl              ; apunto hacia abajo para guardar la letra
        ld      c, $26          ; margen de tecla leída entre 'A' y 'H'
        call    TKP             ; leo el número
        inc     hl              ; apunto hacia arriba donde está el número
        ld      a, (hl)         ; leo el número
        sub     $1c             ; hago que '1' se corresponda con 1 y sucesivamente
        ld      b, a            ; guardo el número (fila) introducida en B
        ld      c, 11           ; quiero multiplicar fila*11, pongo C a 11
        xor     a               ; inicialmente parto de 0
KYBD1   add     a, c            ; añado 11 "fila" veces, por lo que obtengo
        djnz    KYBD1           ; fila*11 en A
        add     a, $2d-11+seglin+3 & 255 ;añado offset necesario para apuntar
        dec     hl              ; a la pieza, apunto a la letra
        sub     (hl)            ; resto letra (están numeradas en orden inverso)
STR     ld      b, 2            ; valor de retorno por defecto 2 (coordenada o pieza inválida)
        cp      seglin+3 & 255
        jr      c, STR3
        cp      seglin+8*11 & 255
        jr      nc, STR3        ; si la pieza apunta fuera del tablero salto a STR3
        ld      c, a            ; guardo posición de pieza en C
        ld      l, c            ; guardo posición de pieza en L
        ld      h, seglin>>8
STR2    ld      a, (hl)         ; leo contenido de pieza
        ld      b, 1            ; valor de retorno 1 (cuadro vacío)
        and     $7f             ; le quito el color a la pieza
        cp      0
        jr      z, STR3         ; si es un cuadro vacío salto a STR3
        inc     b               ; valor de retorno 2 (coordenada o pieza inválida)
        cp      $76
        jr      z, STR3         ; si encuentro retorno de carro salgo con STR3
        cp      $27
        jr      c, STR3         ; salgo si caracter rejilla (8) o numérico (entre $1d y $24)
        ld      a, (hl)         ; leo de nuevo, con color
        inc     b               ; valor de retorno 3 (color de pieza negra)
        ld      l, prilin & 255 ; leo turno (color del carácter arriba izquierda)
        add     a, (hl)         ; esto equivale a un XOR, turno XOR color pieza
        bit     7, a            ; si intento mover una pieza que no es de mi color
        jr      z, STR3         ; salto a STR3 con error 3
        ld      b, 0            ; en cualquier otro caso retorno 0 (color pieza blanca)
STR3    ld      a, b            ; devuelvo el error en A
        ld      l, c            ; y la posición de la pieza en L
        ret

; 79+64
MOVE    xor     a               ; vacío la lista de movimientos
        ld      (MOVCNT), a
        ld      a, (hl)         ; leo pieza
        and     $7f             ; quito color
        cp      $35             ; 'P', si es un peón salto a PAWN
        jr      z, PAWN
        ld      c, 1            ; número de desplazamientos inicialmente a 1
        ld      b, 8            ; cargo a 8 el número de movimientos legales
        ld      hl, TKNGHT      ; apunto al movimiento del caballo
        cp      $33             ; 'N', si es un caballo
        jr      z, MOVE1        ; salto a MOVE1
        ld      l, TKING & 255  ; Apunto tabla a movimiento de rey
        cp      $30             ; 'K'
        jr      z, MOVE1        ; salto a MOVE1 si rey
        ld      c, b            ; resto de piezas pueden hacer hasta 8 desplazamientos
        cp      $36             ; 'Q'
        jr      z, MOVE1        ; la reina puede hacer hasta 8 movimientos de rey
        ld      b, 4            ; limitamos a 4 el número de movimientos
        cp      $37             ; 'R'
        jr      z, MOVE1        ; los 4 primeros corresponden a la torre
        ld      l, TKING+4 & 255; apunto a los 4 últimos, movimientos en diagonal
MOVE1   ld      a, e            ; lo que queda por descarte es un alfil
MOVE2   add     a, (hl)         ; añado posición de pieza a valor tabla
        push    af              ; guardo posición nuevo movimiento
        push    hl              ; guardo posición de tabla
        push    bc              ; guardo número de movimiento y desplazamientos a probar
        call    STR             ; veo contenido nueva posición
        cp      2               ; si posición inválida o pieza negra (de mi color)
        jr      nc, MOVE3       ; salto a MOVE3
        push    af              ; añado movimiento a lista de movimientos posibles
        call    ALIST
        pop     af
        cp      0               ; si hay una pieza del enemigo (blanca) salta a MOVE3
        jr      z, MOVE3        ; porque no podemos atravesarla
        pop     bc              ; en caso contrario (cuadro vacío) seguir por aquí
        pop     hl              ; pasamos al siguiente desplazamiento
        ld      a, c
        cp      1               ; si es pieza de un único desplazamiento saltamos a MOVE4
        jr      z, MOVE4
        pop     af              ; si no probamos otro desplazamiento (en realidad
        jr      MOVE2           ; no se repite 8 veces sino hasta que no haya cuadros vacíos
MOVE3   pop     bc              ; descartamos el resto de desplazamientos
        pop     hl              ; de la pieza
MOVE4   pop     af              ; y vamos al siguiente movimiento de la tabla
        inc     hl              ; incremento puntero en la tabla
        djnz    MOVE1           ; decremento hasta probar con todos los movimientos
        ret

PAWN    ld      a, (hl)         ; leo el color de pieza
        and     $80
        ld      hl, TKING+5     ; si es blanca los movimientos posibles son 11, 10, 12
        jr      nz, PAWN1
        ld      l, TPAWN+2 & 255; si es negra, -11, -10, -12
PAWN1   ld      d, 3            ; número movimientos posibles del peón
PAWN2   ld      a, e            ; muevo peón
PAWN3   add     a, (hl)         ; calculando en A la nueva posición
        push    hl
        push    af
        call    STR             ; leo estado de la casilla
        cp      0               ; si es del color oponente saltar a PAWN5
        jr      z, PAWN5
        cp      1               ; si no es cuadro vacío saltar a PAWN4 (descarto)
        jr      nz, PAWN4
        ld      a, d            ; si es cuadro vacío compruebo si voy por
        cp      1               ; movimiento en vertical (avance del peón)
        jr      nz, PAWN4       ; si el movimiento es diagonal salto a PAWN4 (descarto)
        call    ALIST           ; añado movimiento a la lista (avance del peón)
        ld      a, e            ; si estoy en fila 2 o en fila 7 
        cp      seglin+11*2 & 255 ; añadir también el doble avance saltando a PAWN6
        jr      c, PAWN6
        cp      seglin+11*6 & 255
        jr      nc, PAWN6
PAWN4   pop     af              ; probar el siguiente movimiento posible del peón
        pop     hl              ; y decrementar puntero a tabla
        dec     hl
        dec     d
        jr      nz, PAWN2       ; si he acabado de probarlos todos salgo de la función
        ret
PAWN5   ld      a, d            ; sólo me puedo comer la pieza
        cp      1               ; si el movimiento es diagonal
        call    nz, ALIST       ; si es vertical, no se ejecuta el CALL
        jr      PAWN4           ; voy al siguiente movimiento
PAWN6   pop     af              ; esto produce el avance doble del peón
        pop     hl              ; repitiendo movimiento con la posición
        ld      e, a            ; actualizada en E
        jr      PAWN3

; 62 bytes
CHK     ld      a, (prilin)     ; leo turno ($00 ó $80)
        add     a, $30          ; convierto pieza en rey (el del color del turno)
        ld      hl, seglin+2    ; voy al comienzo del tablero
        ld      b, a            ; pongo BC a $30xx para asegurarme que es mayor que 8*11
        cpir                    ; busco el rey (del color del turno) en el tablero
        dec     hl              ; en HL localizo su posición
        ld      (PIECE), hl     ; guardo en PIECE dicha posición
SQAT    ld      b, 8*11-2       ; número de posiciones del tablero (sobran 3 posiciones por fila)
        ld      hl, seglin+2    ; dirección inicial del tablero
SQAT1   inc     hl              ; incremento posición
        push    hl              ; guardo posición y BC
        push    bc
        ld      e, l            ; guardo posición en E
        call    STR2            ; testeo si el cuadro tiene pieza de color opuesto
        cp      0               ; si no lo tiene está salto a SQAT3 (ir a siguiente posición)
        jr      nz, SQAT3
        call    CHGMV           ; invierte turno 
        ld      l, e            ; recupero posición guardada
        call    MOVE            ; calcular los posibles movimientos de la pieza de color opuesto
        call    CHGMV           ; invierte turno (recupero el anterior)
SQAT2   call    TL              ; veo si en la lista de posibles
        jr      z, SQAT3        ; movimientos de dicha pieza
        ld      hl, (PIECE)     ; está el rey de mi color
        cp      l
        jr      nz, SQAT2
        pop     bc              ; si hay jaque salgo con Carry activo
        pop     hl              ; el jaque es si entro por CHK, en otro caso (SQAT)
        scf                     ; veo si le hacen "jaque" a otra pieza
        ret
SQAT3   pop     bc
        pop     hl
        djnz    SQAT1           ; si he comprobado todo el tablero es que
        and     a               ; no hay jaque y salgo con Carry desactivo
        ret

; 8 bytes
CHGMV   ld      hl, prilin      ; invierte turno
CHG     ld      a, (hl)
        add     a, $80
        ld      (hl), a
        ret

; 92 bytes
SCORE   push    hl              ; guardo posición inicial
        push    bc              ; guardo piezas inicial y final
        push    de              ; guardo posición final
        push    hl              ; guardo posición inicial
        push    bc              ; guardo piezas inicial y final
        ld      d, l            ; guardo en D posición inicial
        ld      hl, POINTS+4    ; resumo en 4 bytes y los guardo en POINTS+4
        call    $0724           ; esto equivale a las siguientes instrucciones
                                ; ld      (hl),b / dec     hl
                                ; ld      (hl),c / dec     hl
                                ; ld      (hl),e / dec     hl
                                ; ld      (hl),d
        call    PSC             ; puntúo pieza posición inicial en B
        ld      a, b            ; añado $42 ? a la puntuación y la guardo en C
        add     a, h
        ld      c, a
        pop     af              ; leo pieza posición final
        call    PSC             ; calculo puntuación
        pop     hl              ; recupero posición inicial
        call    INC             ; si está siendo atacada
        jr      nc, SCORE1      ; la posición inicial, sumar
        add     a, b            ; el valor de la pieza final a la puntuación
SCORE1  ld      c, a            ; y volver a grabar en C
        pop     hl              ; recupero en HL posición final
        pop     de              ; recupero en DE piezas inicial y final
        ld      (hl), d         ; guardo pieza inicial en posición final (hago movimiento)
        push    hl              ; vuelvo a meter en pila en orden inverso
        push    de
        call    INC             ; miro si está siendo atacada la posición final
        jr      nc, SCORE2
        sub     b               ; resto puntuación de la pieza si lo está
SCORE2  ld      c, a            ; y lo vuelvo a grabar en C
        call    CHGMV           ; invierto turno
        call    CHK             ; compruebo jaque
        jr      nc, SCORE3
        inc     c
        inc     c
SCORE3  pop     de              ; si hay jaque incremento puntuación en 2
        pop     hl
        ld      (hl), e         ; guardo pieza final en posición final (retrocedo movimiento)
        pop     hl              ; recupero posición inicial
        call    CHG             ; invierto el color de la pieza en posición inicial
        call    INC             ; miro si está siendo atacada
        jr      nc, SCORE4      ; si lo está decremento puntuación en 1
        dec     c
SCORE4  call    CHG             ; restauro el color de la pieza
        call    CHGMV           ; restauro turno
        ld      a, (FRAMES)     ; leo bit bajo de variable FRAMES 
        and     1               ; y se lo añado a la puntuación
        add     a, c
        ld      hl, POINTS      ; guardo puntuación calculada en POINTS
        ld      (hl), a
        ex      de, hl
        ld      hl, BEST        ; comparo con la puntuación que hay en BEST
        cp      (hl)            ; que sería el mejor movimiento
        ret     c
        ld      bc, 5           ; si mi movimiento es mejor, lo copio como mejor movimiento
        jr      SHIFT1

; 9 bytes
ALIST   ld      hl, MOVCNT      ; apunto al comienzo de la lista
        inc     (hl)            ; incremento longitud de lista en uno
        ld      a, (hl)         ; leo longitud de lista en A
        add     a, l            ; añado longitud a posición comienzo
        ld      l, a            ; apunto al nuevo elemento (después del último elemento)
        ld      (hl), c         ; escribo el nuevo elemento
        ret

; 15 bytes
SHIFT   ld      hl, MOVBUF      ; muevo la lista de movimientos posibles
        ld      de, MOVCNT      ; a un buffer donde antes estaba la tabla y código 
        ld      bc, 28          ; de inicialización
        jr      c, SHIFT2       ; si está desactivo flag C hacer movimiento inverso
SHIFT1  ex      de, hl
SHIFT2  ldir
        ret

; 14 bytes
PSC     and     $7f             ; quita color
        ld      hl, TABPIE      ; tabla de puntuaciones según pieza
        ld      b, 5            ; 5 tipos de piezas puntuables
PSC1    cp      (hl)            ; si mi pieza coincide
        ret     z               ; salgo de subrutina teniendo en B la puntuación
        inc     hl
        djnz    PSC1
        ld      a, b            ; si mi pieza no puntúa devuelvo A a cero y flag Z desactivo
        ret

; 11 bytes
INC     ld      a, l            ; leo posición inicial
        exx
        ld      (PIECE), a      ; guardo en PIECE dicha posición
        call    SQAT            ; si está siendo atacada
        exx                     ; dicha posición, devolver
        ld      a, c            ; Carry activo y devuelvo en A puntuación acumulada
        ret

; 59 bytes
MPSCAN  xor     a               ; inicializo a cero la puntuación del mejor movimiento
        ld      (BEST), a
        ld      b, 8*11-2       ; número de posiciones del tablero
        ld      hl, seglin+2    ; apunto 1 byte antes de la primera posición del tablero
MPSCAN1 inc     hl              ; incremento posición
        push    hl
        push    bc
        ld      e, l            ; guardo posición en E
        call    STR2            ; leo estado de la casilla
        cp      3
        jr      nz, MPSCAN3     ; si la pieza no es del ordenador (blanca) salir a MPSCAN3
        ld      l, e            ; recupero posición en HL
        ld      (PPC), hl       ; guardo en PPC (para ser utilizada por PMOVE)
        call    MOVE            ; relleno lista de movimientos posibles
MPSCAN2 call    TL              ; extraigo movimientos de la lista
        jr      z, MPSCAN3      ; si he acabado con todos los movimientos salgo a MPSCAN3
        ld      e, a            ; pongo en posición final el movimiento a probar
        ld      d, seglin>>8
        call    PMOVE           ; pruebo todos los movimientos de todas las piezas
        jr      MPSCAN2         ; y calculo el que tenga mejor puntuación
MPSCAN3 pop     bc
        pop     hl
        djnz    MPSCAN1         ; hasta acabar de recorrer el tablero
        ld      a, (BEST)       ; leo puntuación del mejor movimiento
        cp      0
MPSCAN4 jp      z, MPSCAN4      ; si le hago jaque mate a la máquina hacer bucle infinito
CHGSQ   call    DOMOVE          ; realizar el movimiento en el tablero
        call    CHGMV           ; cambiar el turno del jugador
        ret

; 11 bytes
TL      ld      hl, MOVCNT      ; apunto a la lista de movimientos
        dec     (hl)            ; decremento el número de elementos de la lista
        ld      a, (hl)         ; leo el número de elementos de la lista
        inc     a               ; si esta vacía A vale $ff (hemos predecrementado)
        ret     z               ; y salgo con flag Z activado
        add     a, l            ; apunto al último elemento
        ld      l, a
        ld      a, (hl)         ; devuelvo el valor del último elemento
        ret

; 32 bytes
PMOVE   ld      hl, (PPC)       ; leo en HL posición inicial pieza
        ld      a, (de)         ; leo el contenido de la posición final de la pieza
        ld      c, a            ; en registro C
        ld      a, (hl)         ; leo en A el contenido de la posición inicial
        ld      (hl), 0         ; vacío el cuadro en la posición inicial (en color blanco)
        ld      (de), a         ; pongo el contenido de la posición inicial en posición final
        ld      b, a            ; guardo en B dicha pieza
        exx                     ; esto mantiene HL, DE y BC en lugar seguro
        and     a               ; desactivo Carry para guardar lista de movimientos en buffer
        call    SHIFT           ; guardo lista
        call    CHK
        exx                     ; recupera HL, DE y BC
        ld      (hl), b         ; devuelvo pieza a posición inicial
        ld      a, c            ; y a posición final
        ld      (de), a
        jr      c, PMOVE1       ; si hay jaque al rey saltar llamada a SCORE
        call    SCORE
PMOVE1  scf                     ; recuperar la lista de movimientos anteriormente
        call    SHIFT           ; guardada en el buffer
        ret

; 41 bytes
DOMOVE  ld      hl, BEST+4      ; apunto a pieza inicial en mejor movimiento
        ld      a, (hl)         ; leo pieza inicial
        dec     hl
        dec     hl              ; apunto a posición inicial en mejor movimiento
        ld      e, (hl)         ; leo posición inicial
        ld      d, seglin>>8
        ld      (de), a         ; escribo pieza inicial en posición inicial
        dec     hl
        ld      l, (hl)         ; leo posición final en HL
        ld      h, d
        ld      c, a            ; guardo en C pieza inicial
        and     $7f             ; quito color
        cp      $35             ; 'P'
        jr      nz, DOMOVE2
        ld      a, e            ; si es un peón leo posición inicial
        cp      seglin+3+8 & 255
        jr      c, DOMOVE1      ; si el peón está en la primera o la
        cp      seglin+2+7*11 & 255 ; última fila, promocionarlo
        jr      c, DOMOVE2       
DOMOVE1 ld      a, c            ; promociono peón a reina
        inc     a
        ld      (de), a
DOMOVE2 bit     0, l            ; pongo cuadro vacío en posición inicial
        ld      (hl), 0         ; del color que corresponda según si la
        jr      nz, DOMOVE3     ; posición es par
        ld      (hl), $80
DOMOVE3 ret

; 5 bytes
TABPIE  defb    $36, $37, $27, $33, $35 ; QRBNP

        block   $4351-$, $fe

_dfile  defb    $76, $76, $76, $76, $76
prilin  defb    $80, $08, $a9, $b7, $ad  ; DRH (iniciales de David Richard Horne)
seglin  defb    $76,29,8,55,51,39,48,54,39,51,55
        defb    $76,30,8,53,53,53,53,128,53,53,53
        defb    $76,31,8,0,128,0,128,53,128,0,128
        defb    $76,32,8,128,0,128,0,128,0,128,0
        defb    $76,33,8,0,128,0,128,0,128,0,128
        defb    $76,34,8,128,0,128,0,128,0,128,0
        defb    $76,35,8,181,181,181,181,181,181,181,181
        defb    $76,36,8,183,179,167,176,182,167,179,183
        defb    $76,8,8,45,44,43,42,41,40,39,38
ultlin  defb    $76,$08,$08,$08,$08,$08
_dfcc   defb    $76,$76,$76,$76,$76,$76,$76,$76,$76,$76

        block   $43fe-$, $fe
        defw    DRIVER
