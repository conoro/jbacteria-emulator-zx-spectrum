
        DEFINE  modo    1

        DEVICE  ZXSPECTRUM48

        DEFINE  LASTK   (IY-$32)
        DEFINE  LASTKK  ($5C08)
        DEFINE  REPDELL ($5C09)
        DEFINE  KREPERR ($5C0A)
        DEFINE  SYSFLA  (IY+1)
        DEFINE  SYSFLAA ($5C3B)
        DEFINE  ANTELEM ($5C3C)
        DEFINE  TEMSP   ($5C3E)
        DEFINE  MOD24   (IY+6)
        DEFINE  MOD244  ($5C40)
        DEFINE  CADE    (IY+$1D+1)
        DEFINE  CADEE   ($5C57+1)
        DEFINE  CADEN   $5C57+1
        DEFINE  CONT1   (IY+$3E)
        DEFINE  CONT11  ($5C78)
        DEFINE  CORX    (IY+$41)
        DEFINE  CORXX   ($5C7B)
        DEFINE  CORY    (IY+$42)
        DEFINE  CORYY   ($5C7C)
        DEFINE  CONT2   (IY+$43)
        DEFINE  CONT22  ($5C7D)
        DEFINE  POSX    (IY+$4E)
        DEFINE  POSXX   ($5C88)
        DEFINE  POSY    (IY+$4F)
        DEFINE  POSYY   ($5C89)
        DEFINE  ANTPOSX (IY+$50)
        DEFINE  ANTPOXX ($5C8A)
        DEFINE  ANTPOSY (IY+$51)
        DEFINE  ANTPOYY ($5C8B)
        DEFINE  POSMAX  ($5C8C)
        DEFINE  TEMP    (IY+$54)
        DEFINE  TEMPP   ($5C8E)
        DEFINE  ELEM    ($5C1C)
        DEFINE  ELEM1   (IY-$1D)

      IF modo=0
        DEFINE  START   $EB48+18+$D79
      ELSE
        DEFINE  START   $EB48+18
      ENDIF

        ORG     $5B00           ; Lo de arriba no lo comento pq da problemas el ensamblador
LINE    nop                     ; Para diferenciar (HL difiere 1) LINE de LJN0 (directorio raiz y padre)
LJN0    ex      de, hl          ; Guardo en DE el resultado que leerá el PIC
LE04    di                      ; Desactivo interrupciones (solo lo despertará un NMI que lance el PIC cuando vea el halt)
        halt                    ; Le doy el control al PIC
LENT    ld      hl, LE04        ; Al pulsar Enter debo traducir el elemento seleccionado en un número
        push    hl              ; Retomo por LE04 cuando lo tenga en DE
LE01    call    CMPMA           ; Obtengo el número de elemento del cursor
        add     hl, de          ; Restauro HL ya que la rutina lo ha cambiado
        add     hl, hl          ; Para pasar de número de elemento a puntero índice
        ld      de, $5C92-2     ; Multiplico por 2 y sumo 5C92, resto 2 para coger el anterior
        add     hl, de          ; Hago la suma, 5C92 es la referencia que tomo para el número devuelto luego
        ld      a, (hl)         ; Obtengo el puntero a la cadena
        inc     l               ; partiendo del índice
        ld      h, (hl)
        ld      l, a
ULBYT   ld      bc, 0           ; En BC tengo el puntero al último byte de la zona de nombres
LE02    inc     de              ; Incremento valor a devolver (uno por cada nombre que lea hasta el final)
        ld      a, (hl)         ; Leo Tipo+Longitud
        and     $0f             ; Me quedo con Longitud, en realidad es LONG-1
        add     a, 2            ; Le sumo 2 para compensar LONG-1 y el byte que ocupa esto
        add     a, l            ; Se lo añado HL para apuntar a la siguiente cadena
        ld      l, a            ; Paso la suma a L
        jr      nc, LE03        ; Y si hay carry lo propago al MSB
        and     a               ; Debo resetear el carry para no influir en SBC
        inc     h               ; Incremento parte alta del puntero HL
LE03    sbc     hl, bc          ; Compruebo si he llegado al final
        ret     z               ; Si fuera el caso, fin de la subrutina, en DE tengo el resultado
        add     hl, bc          ; Si no, restauro puntero y salto a LE02
        jr      LE02
LKN3    ld      b, 4            ; Debo retroceder 3 columnas, pongo B a 3+1
        ld      hl, ELEM        ; HL es el elemento sup izd (multiplo de 24)
        ld      de, $18         ; DE es 24
LK01    ld      ELEM, hl        ; Actualizo la variable (en la primera pasada no hago nada, por eso B vale 4)
        sbc     hl, de          ; HL=ELEM-24
        ret     c               ; Si el resultado es -24 salgo (carry a 1)
        djnz    LK01            ; Si no (HL puede ser 0) continuo con la siguiente columna
        ret
LLN4    ld      a, 4            ; Debo avanzar 3 columnas, pongo A a 3+1
        ld      hl, (MAXELEM+1) ; HL es el último elemento posible
        ld      de, $ffD0       ; DE = -48
        add     hl, de          ; HL = MAXELEM-48
        ret     nc              ; Puede ser que haya menos de 48 elementos, por lo que tengo en cuenta el caso
        ex      de, hl          ; DE = MAXELEM-48
        ld      hl, ELEM        ; HL = ELEM
        ld      bc, $18         ; BC = 24
LL01    ld      ELEM, hl        ; Idem que arriba, actualizo variable
        add     hl, bc          ; HL = ELEM+24
        sbc     hl, de          ; HL = ELEM+24-(MAXELEM-48) = ELEM-MAXELEM+72
        ret     nc              ; Si me salgo del límite retorno de la rutina
        add     hl, de          ; Si no, restauro HL
        dec     a               ; Número de columna que llevo avanzadas (hasta 3)
        jr      nz, LL01        ; Utilizo A para contador porque BC lo estoy usando
        ret
LMN1    ld      hl, (INK+1)     ; Cambio la tinta.  En HL obtengo FONDO/TINTA
        ld      a, l            ; Leo la Tinta en A
LM01    inc     a               ; La incremento (siguiente color)
        and     $7              ; Uso los 3 ultimos bits, despues del 7 va el 0
        cp      h               ; Aparte compruebo que no coincida con el Fondo
        jr      z, LM01         ; Si coincide pruebo con el siguiente color
        ld      (INK+1), a      ; Guardo valor cambiado en su respectiva variable
        jr      LN02            ; Salida común con cambio fondo en LN02
LNN2    ld      hl, (INK+1)     ; Cambio el fondo
        ld      a, h            ; La rutina es paralela a la anterior
LN01    inc     a
        and     $7
        cp      l
        jr      z, LN01
        ld      (INK+2), a
LN02    ld      hl, BUCL2       ; Cambio el flujo normal del programa (debo volver a pintar el cursor)
        ex      (sp), hl        ; modificando la cima de la pila
        jp      CALCOR          ; Salto a CALCOR para cambiar los atributos de color de la pantalla
LQN7    ld      a, POSYY        ; Elemento anterior.  En A tengo la coordenada Y (línea)
        dec     a               ; Le resto 1
        jp      m, LQ01         ; Si se lo resto sin problemas ya está
LQ00    ld      POSYY, a
        ret
LQ01    ld      a, POSXX        ; Si estaba en la primera línea ahora leo coordenada X (columna)
        sub     $0b             ; Le resto 11 (en realidad 1 pq solo hay 3 posibles valores)
        jr      c, LQ02         ; Si también estaba en la primera columna salto a LQ02
        ld      POSXX, a        ; Si no, actualizo columna y continúo por LQ03
        jr      LQ03
LQ02    ld      hl, ELEM        ; HL = ELEM
        ld      de, $ffE8       ; DE = -24
        add     hl, de          ; HL = ELEM - 24
        ret     nc              ; Si ELEM valía 0, no hago nada y salgo
        ld      ELEM, hl        ; ELEM = ELEM - 24
LQ03    ld      POSY, $17       ; Me voy a la última línea y salgo
        ret
LAN6    call    CMPMA           ; Elemento siguiente.  Miro si es el último
        ret     nc              ; Si lo es salgo sin hacer nada
        ld      a, POSYY        ; Si no leo línea y lo guardo en A
        inc     a               ; A = POSY+1
        cp      $18             ; Compruebo si estaba en la última línea
        jr      nz, LQ00        ; Si no lo estaba la actualizo y salgo
        ld      a, POSXX        ; Si estaba en la última línea, A= POSX
        add     a, $0b          ; Le añado 1 columna (11 caracteres)
        cp      $21             ; Era la última columna también?
        jr      z, LA03         ; Si lo era prosigo por LA03
        ld      POSXX, a        ; Si no, actualizo POSX y hago POSY=0
LA02    xor     a               ; para luego salir por LQ00
        jr      LQ00
LA03    ld      hl, ELEM        ; Caso ultimas línea y columna, HL=ELEM
        ld      de, $48         ; DE = 72
        add     hl, de          ; HL = ELEM + 72
        ld      de, (MAXELEM+1) ; DE = MAXELEM
        sbc     hl, de          ; HL = ELEM-MAXELEM+72
        ret     nc              ; Si no puedo avanzar columna salgo sin hacer nada
        ld      POSY, 0         ; Si puedo, me posiciono en la primera línea
        add     hl, de          ; Sumo MAXELEM, HL vale ahora ELEM+72
LA04    ld      de, $ffd0       ; DE = -30
        add     hl, de          ; HL = ELEM+24 (siguiente columna)
        ld      ELEM, hl        ; Actualizo variable y salgo
        ret
LON5    ld      a, POSXX        ; Una columna antes.  Guardo en A la columna
        sub     $0b             ; Veo si no es la primera (la de la izquierda)
        jr      c, LO02         ; Si lo es prosigo por LO02
LO01    ld      POSXX, a        ; Si no actualizo columna y salgo
        ret
LO02    ld      hl, ELEM        ; HL = ELEM
        ld      de, $ffE8       ; DE = -24
        add     hl, de          ; HL = ELEM - 24
        jr      nc, LA02        ; Si no hay carry (ELEM<24) POSY=0 y salgo
        ld      ELEM, hl        ; Si lo hay actualizo ELEM=ELEM-24 y salgo
        ret
LHAC    jp      PCHAR-93-8      ; Función CS+H (Ayuda), salta a un punto en función de PCHAR
LGRA    jp      PCHAR-8         ; Función CS+9 o GRAPH (varias funciones)
LPN8    ld      a, POSXX        ; Una columna después (Como esta rutina es más larga la dejo para el final y la intercalo entre la zona de variables
        add     a, $0b          ; Voy a la columna que tenga a mi derecha
        cp      $21             ; Veo si partía de la columna más a la derecha
        jr      LP00            ; Me salto las variables (este salto es incondicional)

        ORG     $5C00
        defb    $ff,$00,$00,$00,$ff,$00,$00,$00   ; Aquí van varias variables relacionadas con el teclado
        defb    0,$20,3                           ; LASTK,REPDELL,KREPPER         5C08
LP00    jr      nz, LO01        ; Si puedo ir a la derecha, actualizo variable POSX y salgo
        ld      de, (MAXELEM+1) ; Si no, tengo que hacer muchos cálculos, DE = MAXELEM
        push    de              ; Guardo MAXELEM en pila
        ld      a, e            ; Estas 6 líneas equivalen a lo siguiente
        sub     POSY            ; DE=MAXELEM-POSY-1
        jr      nc, LP01
        dec     d
LP01    ld      e, a
        dec     de
        ld      hl, 0           ; HL = ELEM, parece un cero pero es aquí donde guardo la variable (incrustada en el código)
        ld      bc, $48         ; BC = 72
        add     hl, bc          ; HL = ELEM + 72
        ex      de, hl          ; DE = ELEM + 72, HL = MAXELEM-POSY-1
        sbc     hl, de          ; si MAXELEM-POSY-1<ELEM+72 entonces POSY=23
        jr      nc, LP02
        ld      POSY, $17
LP02    pop     hl              ; HL = MAXELEM
        and     a               ; Carry=0
        sbc     hl, de          ; HL = MAXELEM - ELEM - 72
        ret     z               ; Si MAXELEM-72 <= ELEM salgo sin hacer nada
        ret     c
        ex      de, hl          ; en caso contrario HL = ELEM +72, que con los 48 que les restaré
        jr      LA04            ; luego se queda en ELEM+24, que es una columna a la derecha
        defb    0,0             ; 2 bytes libres para futuras mejoras             5C34
        defw    $3c00           ; puntero a caracteres ROM                        5C36
        defb    0,0,0           ; 3 bytes libres que se pueden juntar con los dos de arriba ya que lo del medio es fijo y el código es indefenso
        defb    8,0,0,0,0,0,0   ; SYSFLAGS,ANTELEM,TEMSP,MOD24,CURMODE            5C3B
READK   ld      hl, $5c3b       ; Rutina que mira si se ha pulsado una tecla,     5C42
        bit     5, (hl)         ; y en caso afirmativo la devuelve en A.
        ret     z               ; La pulsación/no pulsación se devuelve en Flag Z
        res     5, (hl)
        ld      a, (LASTKK)
        ret
NOENC   xor     a               ; En caso de no encontrar la cadena buscada, cancelo la búsqueda
        ld      CADEE, a        ; poniendo la longitud a cero y el modo de búsqueda
        res     7, SYSFLA       ; para avanzar al repetir tecla
        ret
        defw    0,0,0,0,0,0,0,0,0                 ; Aquí hay 20 bytes  1 libre + 17 cadena+ 5C57
        defb    0,0                               ; 1 libre + 1 variable FLAGS2             5C69
        defb    LKN3-$5B00,LLN4-$5B00,LNN2-$5B00  ; Punteros a las direcciones de las       5C6B
        defb    LMN1-$5B00,LON5-$5B00,LPN8-$5B00  ; rutinas para cada tecla de función      5C6E
        defb    LAN6-$5B00,LQN7-$5B00,LJN0-$5B00                                          ; 5C71
        defb    LENT-$5B00,LINE-$5B00,LGRA-$5B00                                          ; 5C74
        defb    LAN6-$5B00,0,0,0,0,0,0            ; LAN6,CONT1,CONT,CONT,CORX,CORY,CONT2    ; 5C77
        defb    LHAC-$5B00,LINE-$5B00,LJN0-$5B00  ; Idem pero para las funciones de         5C7E
        defb    LKN3-$5B00,LLN4-$5B00,LMN1-$5B00  ; los números                             5C81
        defb    LNN2-$5B00,LON5-$5B00,LPN8-$5B00  ;                                         5C84
        defb    LQN7-$5B00                        ;                                         5C87
        defb    0,0,0,0,0,0,0                     ; POSX,POSY,ANTX,ANTY,POSMAX,TEMP         5C88
        defb    0,0,0                             ; variables sistema ATTR-T,MASK-T,PFLAG   5C8F

 ; TIPOARCHIVO  0 Directorio 1 SNA, 2 Z80, 3 TAP, 4 TZX, 5 ADF (AnDros File,comprimido)
 ;              6 SCR, 7 TXT, 8 ZIP (monoarchivo)
        ORG     $7000
        INCLUDE folder.asm

        ORG     START
PRINC 
      IF modo=0
UDG     
  DEFB $2C,$24,$2F,$21,$21,$2F,$00      ; Los iconos para los archivos también son caracteres, pero
  DEFB $2F,$21,$2F,$2F,$2F,$2F,$00      ; deben codificarse aparte, ya que no existen en ROM
  DEFB $2F,$0B,$0F,$0F,$0B,$2F,$00      ; 7 bytes por icono*8 iconos=56 bytes, el último me lo ahorro
  DEFB $2F,$0D,$0B,$0D,$0B,$2F,$00                      
  DEFB $2F,$25,$25,$25,$25,$2F,$00
  DEFB $2F,$21,$25,$25,$2B,$2B,$00
  DEFB $2F,$21,$21,$29,$27,$2E,$00
  DEFB $0E,$01,$2D,$2D,$01,$0E 
TABDE   defb    07H, 23H, 49H, 89H, 54H,0C2H, 85H, 61H  ; Estos bytes sirven para comprimir los caracteres
        defb    70H, 07H, 62H, 62H, 61H, 62H, 61H, 61H  ; Obtenidos de la ROM, cada byte tiene 3 unos, que serín
        defb    25H, 52H, 0DH, 19H, 07H, 0DH, 0DH, 61H  ; las columnas que serín desechadas del carácter 8x8
        defb    0DH, 0DH, 23H, 43H, 61H, 62H, 61H, 31H  ; Si además desechamos la primera fila, entonces el carácter
        defb    85H, 0DH, 0DH, 07H, 19H, 0DH, 0DH, 15H  ; 8x8 se transforma en uno 5x7 (7 de alto)
        defb    0DH, 52H, 0DH, 31H, 07H, 89H, 0DH, 0DH
        defb    0DH, 25H, 19H, 0DH, 23H, 0DH, 89H, 89H
        defb    89H, 29H, 43H, 70H, 83H, 07H, 83H, 07H
        defb    49H, 0BH, 45H, 43H, 0BH, 0BH, 61H, 0BH
        defb    0BH, 43H, 49H, 43H, 61H, 83H, 0BH, 0BH
        defb    0BH, 19H, 43H, 0BH, 43H, 0BH, 83H, 83H
        defb    83H, 0BH, 43H, 52H, 31H, 46H
ROTLE   dec     a               ;  Esta rutina rota el caracter de la pantalla
        ret     m               ; hacia la izquierda tantas veces como indique
        ld      b, 7            ; el registro A, pudiendo ser 0 veces
        push    hl
ROTL1   inc     h
        rlc     (hl)
        djnz    ROTL1
        pop     hl
        jr      ROTLE
CHAR    defb    0,0,0,0,0,0,0   ; Aquí se guarda el carácter temporalmente (extraído de ROM) y operamos con él
TRANS   push    af              ; Rutina un poco compleja, se trata de traspasar
TRAN1   ld      de, CHAR        ; el contenido de CHAR hacia la pantalla por medio
        rlc     c               ; de rotaciones, el número de rotaciones viene
        push    af              ; indicado por el registro A, pero no transfiero
        push    hl              ; todos los 8 bits del carácter, solo 5 de ellos
        jr      c, TRAN3        ; y ésto vendrá indicado por el registro C
        ld      b, 7
TRAN2   inc     h              
        ld      a, (de)  
        inc     de        
        rlca        
        rl      (hl)        
        djnz    TRAN2     
TRAN3   ld      b, 7
        ld      hl, CHAR
TRAN4   rlc     (hl)
        inc     l
        djnz    TRAN4
        pop     hl
        pop     af
        jr      c, TRAN1
        pop     af
        dec     a
        jr      nz, TRANS
        ret
TCHAR   push    hl              ; Rutina LENTA que escribe un carácter en pantalla
        sub     $20             ; Los caracteres < 32 no se usan
        jp      z, PCHA6        ; Y con el 32 no hacemos nada (los espacios no se imprimen)
        ld      de, $3D01       ; Apunto al mapa de caracteres de ROM+1 (la primera línea del carácter es 0, no se imprime)
        ld      l, a            ; L = Código ASCII - 32
        ld      c, a            ; C = L
        ld      h, 0            ; H = 0, entonces HL= CA-32
        ld      b, h            ; B = 0, entonces BC=HL
        push    hl              ; guardo HL en pila
        add     hl, hl          ; HL = HL * 8
        add     hl, hl
        add     hl, hl
        cp      $5e             ; Veo si es una letra o un icono lo que voy a imprimir
        jr      c, PCHA1        ; Si es una letra salto a PCHA1
        sbc     hl, bc          ; HL = HL*7 (ya que cada icono son 7 bytes)
        ld      de, UDG-$292    ; $5E*7=$292, debo apuntar al icono -$5E, no al 0
PCHA1   add     hl, de          ; HL apunta al primer byte tanto del icono como del carácter
        ld      c, 7            ; Copio el carácter completo menos la primera línea 8x7
        ld      de, CHAR        ; a la zona de memoria donde apunta CHAR
        ldir
        cp      $39             ; Miro si es la tecla Y (mayúscula)
        jr      nz, PCHA2       ; Es un carácter imposible de comprimir bien (queda inconexo),
        ld      (CHAR+2), a     ; Así que con este truco tratamos esta excepción
PCHA2   pop     hl              ; Recupero el HL antes guardado, que vale CA-32
        ld      c, $d0          ; Por defecto C vale 11010000 para los iconos (antes era 7 pero necesitaba un ret en el 2 byte)
        cp      $5e             ; Veo de nuevo si es letra o icono
        ld      a, TEMPP        ; En A obtengo el desplazamiento dentro del byte de pantalla por el que voy
        jr      nc, PCH25       ; Si es icono salto directamente a PCH25
        ld      de, TABDE       ; Si es carácter debo obtener la máscara para ver qué 3
        add     hl, de          ; columnas del carácter 8x7 descartaré para quedarme
        ld      c, (hl)         ; con un carácter 5x7
        defb    $11             ; Forma optimizada (1 byte) para saltar a PCH27
PCH25   cp      1               ; Parche para partir de un desplazamiento dentro del byte bueno
        jr      nz, PCH27       ; La rutina rápida se basa en la secuencia 01234567 y ésta (lenta) en 05274163
        ld      a, 5            ; Como los iconos corresponden a las 3 primeras posiciones 012 debe transformarse en 052
        ld      TEMPP, a        ; Tan sencillo como cambiar un 1 por un 5
PCH27   ld      hl, CORXX       ; HL apunta a pantalla (donde me toca escribir el carácter)
        call    ROTLE           ; Primero roto el carácter de pantalla (circularmente)
        bit     2, TEMP         ; Veo si A vale más de 4 (caracter repartido en 2 bytes)
        jr      nz, PCHA3       ; Si es mayor PCHA3 (para hacer 2 transferencias)
        ld      a, 5            ; Si es menor hago una sola transferencia de 5 bits por fila
        call    TRANS           ; y pongo A a 3 para rotar luego 3-TEMP veces el caracter en pantalla
        ld      a, 3
        jr      PCHA4
PCHA3   ld      a, 8            ; La primera transferencia es de 8-TEMP
        sub     TEMP
        call    TRANS
        inc     l               ; Avanzo al siguiente carácter
        ld      a, TEMPP        ; La segunda transferencia es de TEMP-3, en total 8-TEMP+TEMP-3=5 bits por fila
        sub     3
        call    TRANS
        ld      a, 11           ; Roto el carácter de pantalla 8-TEMP
PCHA4   sub     TEMP            ; Lo último es una rotación (común para los dos casos)
        call    ROTLE
PCHA6   ld      a, TEMPP        ; Solo me queda por actualizar TEMP sumándole 5 en módulo 8
        add     a, 5
        cp      8
        jr      c, PCHA7
        sub     8
        inc     CORX            ; Si detecto un overflow (ej 5+5=10 mod 8=2) ir a la siguiente
PCHA7   ld      TEMPP, a        ; celda de la pantalla (8x8)
        pop     hl
        ret
      ELSE
CHAR    INCLUDE charset.asm     ; Estos bytes codifican el mapa de caracteres 5x7, uno a continuación de otro,

DOBLE   DEFW $F83F,$FE0F,$F07F,$FC1F    ; DOBLE es por si el caracter esta entre 2 celdas ;  el tercer byte de SIMPLE no se usa

TCHAR   push    hl              ; Al igual que antes queremos conservar HL al acabar la rutina
        sub     $20             ; No necesitamos imprimir los primeros 32 caracteres ASCII
        jp      z, PCHA6
        ld      l, a            ; HL=CA-32
        ld      h, 0
        ld      d, h            ; DE=CA-32
        ld      e, l
        add     hl, hl          ; HL=2*(CA-32)
        ld      b, h            ; BC=2*(CA-32)
        ld      c, l
        add     hl, hl          ; HL=32*(CA-32)
        add     hl, hl
        add     hl, hl
        add     hl, hl
        add     hl, bc          ; HL=34*(CA-32)
        add     hl, de          ; HL=35*(CA-32)
        ld      bc, CHAR-35     ; Evitamos el carácter espacio
        add     hl, bc          ; Apuntamos al carácter correcto
        ld      a, TEMPP        ; Vemos en cual de los 8 casos estamos
        cp      4               ; Traduzco 0123456
        sbc     a, 255          ; en 01235678
        and     a               ; Reseteo carry
        rra                     ; Paso a carry el bit de menor peso
        ld      e, a            ; En E tendrá 00112344
        jr      c, PCHA3        ; Los impares me indican el caso doble en PCHA3 (carácter entre 2 celdas)
        add     hl, de          ; Ahora hago HL = HL + E
        ld      d, SIMPL>>8     ; DE apunta a la máscara simple
        ld      a, (de)         ; Leemos máscara simple
        ld      e, a            ; En E la ponemos invertida
        cpl                     ; Invertimos A
        ld      d, a            ; En D la ponemos sin invertir
        ld      ix, CORXX       ; Leo puntero a memoria de video en IX
        ld      b, 7            ; En B pongo número de repeticiones del bucle
PCHA2   inc     ixh             ; Incremento línea (me salto la primera línea)
        ld      a, (hl)         ; Leo byte del carácter a escribir
        and     e               ; Aplico AND con la máscara invertida
        ld      c, a            ; Guardo en C el byte filtrado (con la máscara aplicada)
        ld      a, (ix)         ; Leo byte de memoria de vídeo
        and     d               ; Le aplico la máscara sin invertir
        xor     c               ; Escribo el byte filtrado proveniente del carácter
        ld      (ix), a         ; Actualizo el byte de la memoria de vídeo
        inc     hl              ; HL = HL + 5
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        djnz    PCHA2           ; Repito bucle 7 veces
        jr      PCHA6           ; Salto a PCHA6, ya que lo siguiente es para caso doble
PCHA3   add     hl, de          ; HL = HL + E
        ld      a, DOBLE&255    ; Quiero que DE apunte a la máscara doble
        add     a, e            ; Pero en este caso hay offset y E debe multiplicarse por 2
        add     a, e            ; En total, estas 5 líneas
        ld      e, a            ; realizan la siguiente funcion 
        ld      d, DOBLE>>8     ; DE = OFFSET DOBLE + 2*E
        ex      de, hl          ; Como LD C,(DE) y LD E,(DE) no existen, hago este intercambio
        ld      c, (hl)         ; Leo máscara del 2º byte sin invertir en C
        inc     l               ; Me voy al segundo byte de la máscara
        ld      l, (hl)         ; Leo máscara del 1º byte sin invertir en L, que luego será E
        ex      de, hl          ; Me interesa que lo que apunte al carácter sea HL
        ld      ix, CORXX       ; IX apunta al puntero de la pantalla en memoria de vídeo
        ld      b, 7            ; Debo escribir 7 líneas (de 2 bytes cada una)
PCHA5   inc     ixh             ; La primera línea me la salto, además debo incrementar una línea en cada paso del bucle
        ld      a, e            ; Leo máscara del primer byte sin invertir
        cpl                     ; Invierto mascara
        and     (hl)            ; En A tengo el byte del carácter ya enmascarado
        inc     hl              ; Apunto al 2º byte
        ld      d, a            ; Guardo el byte enmascarado del carácter en el registro D
        ld      a, (ix)         ; Leo el primer byte de la pantalla
        and     e               ; Enmasacaro el byte de la pantalla con la máscara sin invertir
        xor     d               ; Escribo encima el byte enmascarado proveniente del carácter
        ld      (ix), a         ; Escribo en memoria el byte ya manipulado (primer byte)
        ld      a, c            ; Hago lo mismo para el segundo byte, leo máscara sin invertir
        cpl                     ; La invierto
        and     (hl)            ; Y obtengo el byte proveniente del caracter enmascarado
        ld      d, a            ; Guardo este resultado en D (es el unico registro que me queda libre en todo el bucle)
        ld      a, (ix+1)       ; Leo el segundo byte de la pantalla
        and     c               ; Enmascaro el byte con máscara sin invertir
        xor     d               ; Escribo encima (también se puede hacer con OR o con ADD)
        ld      (ix+1), a       ; Actualizo byte en pantalla
        inc     hl              ; HL = HL + 4 (ya le he sumado uno antes)
        inc     hl
        inc     hl
        inc     hl
        djnz    PCHA5           ; Repito bucle 7 veces
PCHA6   ld      a, TEMPP        ; Incremento TEMP para contemplar el siguiente caso en el siguiente carácter a imprimir
        inc     a
        and     7
        ld      TEMPP, a
        cp      5
        sbc     a, 255
        rrca
        pop     hl
        ret     c
        inc     CORX            ; Incremento coordenada para los casos 13467
        ret

PRSTR   ld      a, (de)         ; Imprimir una cadena mediante rutina ROM, leo carácter de buffer (DE)
        push    de              ; Guardo puntero al buffer (DE)
        call    $0b65           ; Imprimo carácter mediante rutina ROM
        pop     de              ; Recupero puntero
        inc     de              ; Incremento puntero (apunto al siguiente carácter)
        djnz    PRSTR           ; Repito B veces y salgo
        ret

TLHA    ld      de, CHAR+93*35+2; Imprimo pantalla de ayuda, DE apunta al primer byte libre (tercer byte del primer icono)
        ld      hl, $4805       ; HL apunta a la zona de pantalla donde irá la esquina sup izq del cuadro de ayuda
LHA1    ld      c, 28           ; Como C se decrementa con cada carácter, para que nos sirva de contador de bucle tiene que valer 28=7+7*3
LHA2    ld      b, 3            ; Escribimos una línea con 21 caracteres, y leemos los caracteres
        call    PRSTR           ; Agruupados de 3 en 3 con separación de 2 entre ellos
        inc     de
        inc     de
        dec     c
        jr      nz, LHA2
        ld      c, 11           ; BC = 11
        add     hl, bc          ; HL = HL + 11 (apunto justo al principio de la siguiente línea)
        bit     0, h            ; Debo escribir 8 líneas (desde 4800 hasta 5000 (segundo tercio de pantalla)
        jr      z, LHA1
LHA3    call    READK           ; Una vez pintada la pantalla de ayuda,
        jr      z, LHA3         ; Espero la pulsación de una tecla
        call    BUC17           ; Restauro toda la pantalla de atrás
        ld      bc, POSXX       ; Leo coordenada del cursor
        call    PINCUR          ; Pinto el cursor (solo extremos, los atributos de colores los pongo luego)
        jp      LN02            ; Cambio los atributos de toda la pantalla que han sido modificados para imprimir la ayuda
      ENDIF
       
      IF modo>0
LGR1    ld      (hl), c         ; Pongo a 01 20 20 .. 20 (todo espacios) la cadena a escribir
        dec     hl
        ld      (hl), b
        djnz    LGR1
LGR2    ld      de, CADEN+1     ; Apunto con DE al primer carácter de la cadena
        ld      hl, $50E8       ; Zona de pantalla donde se imprimirá la cadena
SIMPL   defb    $F8,$3E,0,$7C,$1F ; Aquí guardo las máscaras para el caso doble de PCHAR (LO(SIMPL)=0)
        ld      bc, $1011       ; B=16 caracteres de longitud, C=B+1 porque se decrementará y no interesa que nos cambie de línea
        call    PRSTR           ; Imprimo la cadena (mediante rutina ROM)
LGR3    call    READK           ; Espero a que se pulse una tecla y obtengo el resultado en A
        jr      z, LGR3
        ld      hl, CADEN       ; Apunto al principio de la cadena (longitud)
        ld      c, (hl)         ; Leo la longitud en C
        cp      13              ; Veo si he pulsado Enter
        jp      z, LE04         ; Si lo he pulsado salgo por LE04 y le doy el control al PIC
        jr      nc, LGR4        ; Si es mayor (no se ha pulsado la tecla borrar) salto a LGR4
        dec     (hl)            ; Al pulsar CS+0 debo borrar el último carácter
        ld      a, $20          ; Pongo un espacio en ese lugar y decremento longitud
        jr      z, LGR4         ; Si la longitud es 0 salto a LGR4 para no decrementar más la longitud
        dec     c               ; Decremento C también para apuntar al carácter que quiero borrar
        dec     (hl)            ; Para compensar en INC que hay justo después (saltarse la siguiente línea requeriría 2 bytes)
LGR4    inc     (hl)            ; Aumento la longitud de la cadena en 1
        add     hl, bc          ; Posiciono el puntero al carácter que se va a escribir (el último de la cadena)
        ld      (hl), a         ; Escribo el carácter en la cadena
        jr      LGR2            ; Retomo el bucle en LGR2
      ENDIF

      IF modo=1
TLGR    ld      hl, CADEN+16    ; Función GRAPH para darle nombre al archivo, Apunto a final buffer cadena
        ld      bc, $1020       ; B=16 caracteres del buffer cadena. C=32 (lo relleno de espacios)
        jr      LGR1            ; Continúo por LGR1
      ELSE
TLGR    call    LE01            ; Función GRAPH para ejecutar en modo SNAPSHOT rápido, simulo pulsar Enter
        set     7, d            ; Pongo el bit más significativo a 1, que indicará dicho modo al PIC
        jp      LE04            ; Salgo por LE04, enviando DE al PIC
      ENDIF

PCHAR   jp      TCHAR           ; Salta a TCHAR (ya que la dirección es distinta según el caso)

AINIC 
 ;         ORG     START+AINIC-PRINC
INICI   di                      ; La ejecución empieza por aquí, primero desactivo interrupciones
COMCA   ld      sp, $7000       ; Hago que SP apunte justo debajo de los nombres de archivo
INK     ld      hl, $0004       ; HL tendrá los colores TINTA/FONDO
        call    CALC1           ; Actualizo la memoria de atributos
MAXELEM ld      bc, 2053        ; BC es el número de archivos que hay
POSDI   ld      hl, 44*2+$5C92  ; HL apunta al índice del primer archivo (después de los directorios)
        inc     b               ; Incremento B (debido al método para contar bucles que uso en INIC4)
        ld      de, (COMCA+1)   ; De apunta a los nombres de archivo (a lo mismo que apunta SP)
        ld      ix, $5c92       ; IX apunta al índice del primer directorio
INIC1   ld      a, (de)         ; Miro tipoarchivo/longitud
        and     $f0             ; Filtro tipoarchivo
        jr      nz, INIC2       ; Si es archivo salto a INIC2
        ld      (ix), e         ; Si es directorio lo pongo en su índice y prosigo por INIC3
        inc     ixl
        ld      (ix), d
        inc     ix
        jr      INIC3
INIC2   ld      (hl), e         ; Si es archivo, ídem
        inc     l
        ld      (hl), d
        inc     hl
INIC3   ld      a, (de)         ; Leo de nuevo tipoarchivo/longitud
        and     $0f             ; Ahora filtro longitud
        add     a, 2            ; Le sumo 2 (1 por que 0 corresponde a longitud 1 y otro por el byte que ocupa esto)
        add     a, e            ; Le sumo E (para aumentar el puntero DE)
        ld      e, a            ; Lo guardo en E
        jr      nc, INIC4       ; Si al sumar no hay carry salto a INIC4
        inc     d               ; Si lo hay debo incrementar D
INIC4   dec     c               ; Decremento en 1 el número de archivos que me faltan
        jr      nz, INIC1       ; Si no es 0 salto a INIC1
        djnz    INIC1           ; Si lo es, decremento la parte alta del número de archivos (en B) y salto a INIC1
        ld      (ULBYT+1), de   ; El puntero al final de los archivos lo voy a usar luego (cuando pulso Enter)
        ld      POSMAX, hl      ; También necesito guardar la posición del índice del último archivo
        push    hl              ; Lo pongo en pila como primer parámetro de SORTN
        push    ix              ; Hago HL=IX mediante 2 instrucciones de pila
        pop     hl
        push    hl              ; Pongo el segundo parámetro de SORTN en pila
        dec     hl              ; HL = HL - 2
        dec     l
        push    hl              ; Lo pongo como primer parámetro de la segunda llamada a SORTN
        ld      hl, $5C92       ; 5C92 (posición del índice del primer directorio) será el segundo parámetro de la segunda llamada a SORTN
        push    hl
        call    SORTN           ; Hago la primera llamada a SORTN (ordenar directorios)
        ld      ELEM, hl        ; Como al salir de SORTN, HL es 0, aprovecho para resetear ELEM
        pop     hl              ; SP = SP + 4 (equilibro pila)
        pop     hl
        call    SORTN           ; Hago la segunda llamada a SORTN (ordenar archivos)
        ld      POSXX, hl       ; Aprovecho que HL es 0 para resetear POSX y POSY
        ld      iy, $5c3a       ; Hago que IY apunte a variables del sistema (y mis variables) al igual que se hace en la ROM
        ld      hl, (MAXELEM+1) ; HL es el número de elementos
        dec     hl              ; HL = HL - 1
        call    REM24           ; Esto hace una división, y el resto (módulo) lo devuelve en A
        ld      MOD244, a       ; En MOD24 tendrá guardado el número de archivos que hay en la última columna (para no calcular lo mismo luego)
        ld      hl, $5c89       ; HL apunta a POSY
        ld      ANTELEM, hl     ; Necesito que la primera vez ANTELEM no valga ni 0, ni 24, ni -24 para que se actualice la pantalla
        jr      BUCL2           ; Salto a BUCL2 (la primera vez no se restaurará el cursor anterior)
CALCOR  ld      hl, (INK+1)     ; Rutina multipropósito, traduce el color a varias variables
CALC1   ld      a, l            ; y actualiza atributos de pantalla
        rlca
        rlca
        rlca
        add     a, h            ; Aquí condensamos los colores en un byte
        push    af              ; Lo pongo en pila
        or      $40             ; Le doy un brillo especial a la pantalla de ayuda
        ld      ($5c8f), a      ; ATTR-T, que lo usará la ROM en la rutina para imprimir caracteres que emplearé
        ld      a, h            ; El color del fondo lo paso a COLIM, que me servirá para cambiar
        ld      (COLIM+1), a    ; el color del borde (en función del color del fondo actual)
        rlca                    ; ahora los condenso en un byte pero al revés
        rlca
        rlca
        add     a, l
        ld      hl, $5800       ; apunto a la zona de atributos
        ld      b, l            ; B=0 para repetir 256 veces el bucle
CALC2   ld      (hl), a         ; Como son 768 bytes, así es más rápido que con LDIR (además uso loop unrolling de 3)
        inc     hl
        ld      (hl), a
        inc     hl
        ld      (hl), a
        inc     l
        djnz    CALC2
        pop     bc              ; Obtengo en B lo que antes en pila guardó en A (colores condensados en un byte)
        add     a, b            ; Lo sumo con el byte condensado invertido de ahora
        ld      (COLOR+1), a    ; Lo escribo en COLOR, que calculará de forma rápida el inverso del atributo
        ld      hl, $5C89       ; Esto es para que cuando se salte a BUCL2 via RET tengamos HL apuntando a POSY
        ret

BUCLE   call    CMPMA           ; Bucle principal del programa, empiezo probando excepciones en caso de que haya menos de 3 columnas de archivos
        jr      c, BUCL1        ; Si el elemento seleccionado cae dentro de MAXELEM salto a BUCL1
        ld      a, MOD244       ; Si cae fuera pongo POSY a MOD24 (MOD24=(MAXELEM-1)MOD 24)
        ld      POSYY, a
        call    CMPMA           ; Y repito la misma comparación
        jr      z, BUCL1        ; Si estoy dentro pero justo al final, salto a BUCL1
        call    nc, LON5        ; Si estoy fuera, simulo que he pulsado cursor izquierda (columna anterior)
BUCL1   ld      hl, $5C8B       ; Apunto a ANTPOSY (para restaurar y pintar cursor)
BUCL2   ld      a, (hl)         ; A es igual a POSY/ANTPOSY
        dec     l               ; HL apunta ahora a POSX/ANTPOSX
        rlca                    ; Me interesan los bits 3 y 4 de POSY/ANTPOSY, salto los bits 7,6 y 5
        rlca
        rlca
        rla                     ; Pongo el bit 4 de POSY/ANTPOSY en carry
        ld      d, $16          ; D = $16
        rl      d               ; D = $2C + bit4
        rla                     ; Pongo el bit 3 de POSY/ANTPOSY en carry
        rl      d               ; D = $58 + bit4*2 + bit3
        add     a, (hl)         ; Sumo los bits 2,1,0 (justificados a la izda) de POSY/ANTPOSY a POSX/ANTPOSX
        dec     l               ; HL vuelve apuntar a POSY/ANTPOSY
        ld      e, a            ; Ahora DE apunta exactamente al primer atributo de la línea que voy a escribir (cursor)
        ld      b, 10           ; La longitud de la línea es de 10 bytes (80 pixeles)
BUCL3   ld      a, (de)         ; Leo un byte de atributo
        neg                     ; Invierto valor del byte (no color)
COLOR   add     a, $25          ; Con esta suma sé que se invierte el color
        and     $3f             ; Me aseguro de dejar los bits flash y bright a 0
        ld      (de), a         ; Actualizo el atributo que acabamos de invertir
        inc     e               ; Apunto a la siguiente celda
        djnz    BUCL3           ; Repito esto 10 veces
        bit     3, l            ; Lo repito dos veces (una para ANTPOS y otra para POS), o bien una sola vez (para POS),
        jr      nz, BUCL2       ; dependiendo de lo que tenga en HL cuando está en la etiqueta BUCL2
        di                      ; Desactivo interrupciones aquí, porque habrá momentos en los que SP apuntará a zonas de la pantalla y una interrupción podría meter basura en pantalla
        ld      hl, BUC20       ; Pongo BUC20 en la pila para que cuando haya un RET prosigamos por allí
        push    hl
        ld      hl, ANTELEM
        ld      bc, ELEM
        sbc     hl, bc
        jp      z, RESCUR
        ld      bc, 23
        adc     hl, bc
        jr      nz, BUCL8
        call    RESCUR
        ld      TEMSP, sp
        ld      ix, $400a
BUCL4   ld      a, $c0
BUCL5   ex      af, af'
        ld      sp, ix
        ld      a, $3
        pop     bc
        pop     de
        pop     hl
        exx
        pop     bc
        pop     de
        pop     hl
BUCL6   exx
        rr      c
        rr      b
        rr      e
        rr      d
        rr      l
        rr      h
        exx
        rr      c
        rr      b
        rr      e
        rr      d
        rr      l
        rr      h
        dec     a
        jr      nz, BUCL6
        ld      sp, ix
        inc     sp
        push    hl
        push    de
        push    bc
        exx
        push    hl
        push    de
        ld      (ix-10), b
        ld      de, $20
        add     ix, de
        ex      af, af'
        dec     a
        jr      nz, BUCL5
        ld      bc, $E80B
        add     ix, bc
        xor     e
        xor     ixl
        jr      nz, BUCL4
        ld      b, 192
        sbc     hl, hl
BUCL7   ld      sp, ix
        ld      a, (ix-11)
        and     $c0
        ld      (ix-11), a
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        add     ix, de
        djnz    BUCL7
        ld      sp, TEMSP
        ld      hl, ELEM
        add     hl, hl
        ld      de, $5C92+$60
        add     hl, de
        ld      a, $16
        jp      BUC13

BUCL8   sbc     hl, bc
        inc     c
        sbc     hl, bc
        jp      nz, BUC17
        call    RESCUR
        ld      TEMSP, sp
        ld      ix, $400a
BUCL9   ld      a, $c0
BUC10   ex      af, af'
        ld      sp, ix
        ld      a, $3
        pop     bc
        pop     de
        pop     hl
        exx
        pop     bc
        pop     de
        pop     hl
BUC11   rl      h
        rl      l
        rl      d
        rl      e
        rl      b
        rl      c
        exx
        rl      h
        rl      l
        rl      d
        rl      e
        rl      b
        rl      c
        exx
        dec     a
        jr      nz, BUC11
        inc     ix
        ld      a, ixl
        add     a, $14
        ld      ixl, a
        ld      sp, ix
        ld      (ix), l
        push    de
        push    bc
        exx
        push    hl
        push    de
        push    bc
        ld      de, $0B
        add     ix, de
        ex      af, af'
        dec     a
        jr      nz, BUC10
        ld      bc, $E7F5
        add     ix, bc
        xor     ixl
        jp      pe, BUCL9
        ld      ix, $400a
        ld      de, $0020
        ld      b, 192
        sbc     hl, hl
BUC12   ld      sp, ix
        ld      a, (ix)
        and     $07
        ld      (ix), a
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        add     ix, de
        res     0, (ix-11)
        djnz    BUC12
        ld      sp, TEMSP
        ld      hl, ELEM
        add     hl, hl
        ld      de, $5C92
        add     hl, de

        xor     a
BUC13   ld      CORXX, a
BUC14   ld      CORY, $40
BUC15   call    AJUST
        ld      CORXX, a
        and     $18
        rrca
        rrca
        rrca
        ld      TEMPP, a
        ld      de, POSMAX
        ex      de, hl
        sbc     hl, de
        ex      de, hl
        ret     z
        push    hl
        ld      a, (hl)
        inc     hl
        ld      h, (hl)
        ld      l, a
        ld      a, (hl)
        and     $f0
        rrca
        rrca
        rrca
        rrca
        add     a, $7e
        call    PCHAR
        ld      a, $0f
        and     (hl)
        inc     a
        ld      b, a
BUC16   inc     hl
        ld      a, (hl)
        push    bc
        call    PCHAR
        pop     bc
        djnz    BUC16
        pop     hl
        inc     l
        inc     hl
        ld      a, CORXX
        add     a, $20
        ld      CORXX, a
        jr      nc, BUC15
        ld      a, CORYY
        add     a, $08
        ld      CORYY, a
        cp      $58
        jr      nz, BUC15
        dec     a
        ret
BUC17   ld      TEMSP, sp
        ld      sp, $5800
        ld      hl, 0           ; SBC HL,HL
        ld      b, l
BUC18   push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        push    hl
        djnz    BUC18
        ld      sp, TEMSP
        ld      hl, ELEM
        add     hl, hl
        ld      de, $5C92
        add     hl, de
        xor     a
BUC19   ld      CORXX, a
        call    BUC14
       ret     z
        call    AJUST
        add     a, $0c
        cp      $21
        jr      nz, BUC19
        ret
BUC20   ld      bc, POSXX
        call    PINCUR
        ld      hl, ELEM
        ld      ANTELEM, hl
        ld      hl, POSXX
        ld      ANTPOXX, hl
        ei
BUC21   ld      a, CONT11
BUC22   cp      CONT1
        jr      z, BUC22
        ld      a, CADEE
        or      a
COLIM   ld      a, 0
        push    af
        jr      z, BUC23
        dec     CONT2
        call    z, NOENC
        inc     a
        bit     7, SYSFLA
        jr      nz, BUC23
        inc     a
BUC23   out     ($fe), a
BUC24   add     hl, hl
        add     hl, hl
        djnz    BUC24
        pop     af
        out     ($fe), a
        call    READK
        jr      z, BUC21
        ld      hl, BUCLE
        push    hl
        ld      e, a
        sub     4
        cp      12
        jr      nc, BUC25
        add     a, $6b
        jr      BUC27
BUC25   sub     $41-4
        jr      z, BUC26
        cp      7
        jr      c, BUC28
        cp      17
        jr      nc, BUC28
BUC26   add     a, $77
BUC27   ld      l, a
        ld      h, $5c
        ld      l, (hl)
        dec     h
        call    NOENC
        jp      (hl)
BUC28   ld      hl, CADEN
        ld      c, (hl)
        add     hl, bc
        ld      a, (hl)
        bit     7, SYSFLA
        jr      nz, BUC30
        and     a
        jr      z, BUC29
        cp      e
        jr      z, BUC29
        set     7, SYSFLA
        defb    $3E             ; CP A,X
BUC29   ld      b, 64
BUC30   ld      CONT2, b
        bit     4, CADE
        jr      nz, BUC31
        inc     CADE
BUC31   inc     l
        ld      (hl), e
        ld      a, CADEE
        ld      TEMPP, a
        bit     7, SYSFLA
        jr      nz, BUC34
        ld      CADE, 1
        call    CMPMA
        jr      z, BUC33
        add     hl, de
        add     hl, hl
        ld      de, $5C92
        add     hl, de
        ld      de, (POSDI+1)
        sbc     hl, de
        jr      nc, BUC32
        ex      de, hl
        defb    $FE
BUC32   add     hl, de
        ld      bc, POSMAX
        call    BUSBI
        jr      z, ENCON
BUC33   ld      hl, (POSDI+1)
        ld      bc, POSMAX
        call    BUSBI
        jr      z, ENCON
TNOEN   jp      NOENC
BUC34   ld      hl, (POSDI+1)
        ld      bc, POSMAX
        call    BUSBI
        jr      z, ENCON
        ld      hl, $5C92
        ld      bc, (POSDI+1)
        call    BUSBI
        jr      nz, TNOEN
ENCON   exx
        ld      a, TEMPP
        ld      CADEE, a
        dec     b
        call    z, NOENC
        exx
        ex      de, hl
        ld      de, -$5C92
        add     hl, de
       and     a
        rr      h
        rr      l
        push    hl
        call    REM24
        pop     bc
        ld      TEMPP, a
        call    CMPMA
        add     hl, de
        sbc     hl, bc
        jr      nc, ENCO2
        ld      de, 71
        ld      hl, ELEM
        add     hl, de
        sbc     hl, bc
        jr      c, ENCO4
        ld      POSY, $17
ENCO1   call    CMPMA
        add     hl, de
        sbc     hl, bc
        jr      nc, ENCO7
        ld      a, POSXX
        add     a, $0b
        ld      POSXX, a
        jr      ENCO1
ENCO2   xor     a
        ld      hl, ELEM
        sbc     hl, bc
        jr      nc, ENCO5
        ld      POSYY, a
ENCO3   call    CMPMA
        add     hl, de
        sbc     hl, bc
        jr      z, ENCO7
        jr      c, ENCO7
        call    LON5
        jr      ENCO3
ENCO4   ld      hl, $ffd0
        add     hl, bc
        ld      b, h
        ld      c, l
        ld      a, $16
ENCO5   ld      POSXX, a
        ld      a, c
        sub     TEMP
        ld      ELEM, a
        jr      nc, ENCO6
        dec     b
ENCO6   ld      ELEM1, b
ENCO7   ld      a, TEMPP
        ld      POSYY, a
        ret

AJUST   ld      a, CORXX        ; 27
        ld      c, a
        and     $e0
        ld      b, a
        ld      a, c
        and     $1f
        cp      $0b
        jr      nc, AJUS1
        xor     a
        jr      AJUS2
AJUS1   cp      $16
        ld      a, $15
        jr      nc, AJUS2
        ld      a, $0a
AJUS2   add     a, b
        ret

BUSB1   ex      de, hl          ; 29
        ld      h, b
        ld      l, c
BUSB2   add     hl, de
        rr      h
        res     1, l
        rr      l
        sbc     hl, de
        ret     z
        add     hl, de
        push    hl
        ld      a, (hl)
        inc     l
        ld      h, (hl)
        ld      l, a
        call    COMP
        pop     hl
        jr      c, BUSB1
        ld      b, h
        ld      c, l
        jr      BUSB2

BUSBI   ld      ix, CADEN       ; 61
        call    BUSB1
        ld      a, (de)
        inc     e
        ld      l, a
        ld      a, (de)
        dec     e
        ld      h, a
        call    COMP
        ret     z
        ld      e, c
        ld      d, b
        ld      a, (bc)
        inc     c
        ld      l, a
        ld      a, (bc)
        ld      h, a
COMP    push    ix
        ld      a, (hl)
        and     $0f
        inc     a
        exx
        ld      b, a
        ld      e, (ix)
COM1    exx
        inc     hl
        inc     ix
        ld      a, (hl)
        or      $20
        exx
        ld      c, (ix)
        set     5, c
        sub     c
        jr      nz, COM2
        dec     e
        jr      z, COM2
        djnz    COM1
        scf
COM2    exx
        pop     ix
        ret

CMPMA   ld      a, POSXX        ; 30
        cp      $0b
        jr      c, CMPM1
        ld      a, $19
        jr      z, CMPM1
        ld      a, $31
CMPM1   adc     a, POSY
        ld      l, a
        ld      h, 0
        ld      de, ELEM
        add     hl, de
        ld      de, (MAXELEM+1)
        sbc     hl, de
        ret

REM24   ld      bc, $0818       ; 17
        ld      a, h
REM1    and     a
        rl      l
        rla
        cp      c
        jr      c, REM2
        sub     c
        set     0, l
REM2    djnz    REM1
        ret

RESCUR  ld      bc, ANTPOXX
PINCUR  ld      a, b
        and     7
        ld      l, a
        ld      a, c
        rlca
        rlca
        add     a, c
        ld      e, a
        and     7
        xor     e
        add     a, l
        rrca
        rrca
        rrca
        ld      l, a
        ld      a, b
        and     $18
        or      $40
        ld      h, a
        ld      b, 8
        ld      a, c
        cp      $0b
        jr      z, RESC4
        jr      c, RESC2
        ld      a, b
        add     a, l
        ld      l, a
RESC1   ld      a, (hl)
        xor     $3f
        ld      (hl), a
        inc     h
        djnz    RESC1
        ret
RESC2   ld      a, $0a
        add     a, l
        ld      l, a
RESC3   ld      a, (hl)
        xor     $f8
        ld      (hl), a
        inc     h
        djnz    RESC3
        ret
RESC4   ld      a, 4
        add     a, l
        ld      l, a
        add     a, $0b
        ld      e, a
        ld      d, h
RESC5   ld      a, (hl)
        xor     $07
        ld      (hl), a
        ld      a, (de)
        xor     $c0
        ld      (de), a
        inc     d
        inc     h
        djnz    RESC5
        ret

SORTN   ld      iy, 0
        add     iy, sp
SORT1   ld      e, (iy+2)
        ld      d, (iy+3)
        ld      c, (iy+4)
        ld      b, (iy+5)
        ld      h, b
        ld      l, c
        add     hl, de
        rr      h
        rr      l
        res     0, l
        ld      a, (hl)
        inc     l
        ld      ixl, a
        ld      a, (hl)
        ld      ixh, a
SORT2   ld      a, (de)
        inc     e
        ld      l, a
        sub     ixl
        ld      a, (de)
        inc     de
        ld      h, a
        push    ix
        jr      nz, SORT3
        sub     ixh
        jr      z, SORT6
SORT3   ld      a, (hl)
        and     $0f
        inc     a
        exx
        ld      b, a
        ld      a, (ix)
        and     $0f
        inc     a
        ld      e, a
SORT4   exx
        inc     hl
        inc     ix
        ld      a, (hl)
        or      $20
        exx
        ld      c, (ix)
        set     5, c
        sub     c
        jr      nz, SORT5
        dec     e
        jr      z, SORT5
        djnz    SORT4
        scf
SORT5   exx
SORT6   pop     ix
        jr      c, SORT2
        dec     de
        dec     e
SORT7   inc     c
        ld      a, (bc)
        dec     c
        ld      h, a
        ld      a, (bc)
        dec     bc
        dec     c
        ld      l, a
        push    ix
        sub     ixl
        jr      nz, SORT8
        ld      a, h
        sub     ixh
        jr      z, SOR12
SORT8   ld      a, (hl)
        and     $0f
        inc     a
        exx
        ld      b, a
        ld      a, (ix)
        and     $0f
        inc     a
        ld      e, a
SORT9   exx
        inc     hl
        inc     ix
        ld      a, (hl)
        or      $20
        exx
        ld      c, (ix)
        set     5, c
        sub     c
        ccf
        jr      nz, SOR11
        dec     e
        jr      z, SOR10
        djnz    SORT9
        defb    $e6             ; AND XX PONE CARRY A 0
SOR10   scf
SOR11   exx
SOR12   pop     ix
        jr      c, SORT7
        inc     c
        inc     bc
        ld      h, b
        ld      l, c
        sbc     hl, de
        jr      c, SOR13
        ld      h, b
        ld      l, c
        ld      b, (hl)
        inc     l
        ld      c, (hl)
        ex      de, hl
        ld      a, (hl)
        ld      (hl), b
        inc     l
        dec     e
        ld      (de), a
        inc     e
        ld      a, (hl)
        ld      (hl), c
        ld      (de), a
        ex      de, hl
        ld      b, h
        ld      c, l
        dec     c
        dec     bc
        dec     c
        inc     de
        ld      h, b
        ld      l, c
        sbc     hl, de
        jp      nc, SORT2
SOR13   ld      l, (iy+2)
        ld      h, (iy+3)
        push    de
        push    bc
        push    hl
        and     a
        sbc     hl, bc
        call    c, SORTN
        pop     hl
        pop     hl
        pop     hl
        ld      iy, 0
        add     iy, sp
        ld      e, (iy+4)
        ld      d, (iy+5)
        ld      (iy+2), l
        ld      (iy+3), h
        sbc     hl, de
        jp      c, SORT1
        ret

        SAVESNA "andros.sna", INICI

; LEE TECLADO     A->E7 M+A->E2 M+B->2A
; MAY    QAOPSD0 51 41 4F 50 53 44 0C  F6 E6 F4 F5 F8 E9 0C
; OPQA5678 CURSORES    8 A B 9
; KL34 AVPAG REPAG     4 TRUEVIDEO 5 INVIDEO
; M1 INK+ N2 PAPER+    7 EDIT 6 CAPSLOCK
; JYO DIR PADRE        C DELETE
; RYEXT DIR RAIZ       E EXTRA
; AbcdefgHIJKLMNOPQrstuvwxyz 4,5,6,7,8,9,A,B,C,D,E
; COMPILAR 3 SNA0 SNA1 SNA2 HACER EJECUTABLE QUE SEPARE BLOQUES
; VER COMO MONTAR LOS BLOQUES SEPARADOS BUG CDM
; 5B00-5C92 COMUN
; F8D3-FA32 MODO0
; EB48-FA27 FA2F-FA32 MODO12
; FA27-FA2F MODO1o2
; FA32-FA42 COMUN VAR
; FA42-0000 COMUN
; LEER ARCHIVOS DE EB47 PARA ATRAS (HASTA 8000) BLOQUES 1F00
; SI 2C+C*LN(C)/K+5C92>PUNTERO (C=CONTADOR+(F8D3-EB48)/L 0<L<17)
; LEER HACIA ALANTE EB48 HASTA F8D3-11h Y EJECUTAR MODO 0
; MODO 012   COMUN    FA42-0000-1VEZ
; MODO 012   COMUNVAR FA32-FA43
; MODO 0|12  RELLENAR FA2F-FA32
; MODO 0|1|2 RELLENAR FA27-FA2F
; MODO 0|12  RELLENAR EB48-FA27
; MODO 0     RELLENAR F8D3-EB48
; MODO 012   COMUN    5B00-5C92-1VEZ
; JP FA32