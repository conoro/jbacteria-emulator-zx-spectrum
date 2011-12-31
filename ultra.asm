
        DEFINE  sinborde

L386E:  LD      IXH,128
        LD      B,52
        LD      IY,$5B00        ; EXO_MAPBASEBITS
        PUSH    DE

;; EXO_INITBITS
L3878:  LD      A, B
        SUB     4
        AND     15
        JR      NZ,L3882
        LD      DE,1            ; DE=b2
L3882:  LD      C,16
L3884:  CALL    L3BEE           ; EXO_GETBIT
        RL      C
        JR      NC,L3884
        LD      (IY+0),C        ; bits[i]=b1
        PUSH    HL
        INC     C
        LD      HL,0
        SCF
L3894:  ADC     HL,HL
        DEC     C
        JR      NZ,L3894
        LD      (IY+52),E
        LD      (IY+104),D      ; base[i]=b2
        ADD     HL,DE
        EX      DE,HL
        INC     IY
        POP     HL
        DJNZ    L3878           ; EXO_INITBITS
        POP     DE
;; EXO_LITERALCOPY
L38A7:  LDI
;; EXO_MAINLOOP
L38A9:  CALL    L3BEE           ; EXO_GETBIT, literal?
        JR      C,L38A7         ; EXO_LITERALCOPY
        LD      C,255
L38B0:  INC     C
        CALL    L3BEE           ; EXO_GETBIT
        JR      NC,L38B0
        LD      A,C             ; C=index
        CP      16
        JR      L38D7

L38BB:  LD      C,$FE
        NOP
        NOP

L38BF:  INC     H               ;4
    IFDEF sinborde
        EX      AF,AF'          ;4
        JR      NC,L38CD        ;7/12   41/43
        XOR     B               ;4
        LD      (DE),A          ;7
        INC     DE              ;6
        LD      A,$DC           ;7
        EX      AF,AF'          ;4
        IN      L,(C)           ;12
        JP      (HL)            ;4
L38CD:  XOR     B               ;4
        ADD     A,A             ;4
        RET     C               ;5
        ADD     A,A             ;4
        EX      AF,AF'          ;4
        IN      L,(C)           ;12
        JP      (HL)            ;4
        DEFB    $FF, $FF, $FF; 3 bytes
    ELSE
        JP      NC,L38CD        ;10     46/46
        XOR     B               ;4
        ADD     A,A             ;4
        RET     C               ;5
        ADD     A,A             ;4
        EX      AF,AF'          ;4
        OUT     ($FE),A         ;11
        IN      L,(C)           ;12
        JP      (HL)            ;4
L38CD:  XOR     B               ;4
        LD      (DE),A          ;7
        INC     DE              ;6
        LD      A,$88           ;7
        SCF                     ;4
        EX      AF,AF'          ;4
        IN      L,(C)           ;12
        JP      (HL)            ;4
    ENDIF

L38D7:  RET     Z
        PUSH    DE
        CALL    L3BCD           ; EXO_GETPAIR
        PUSH    BC
        POP     AF
        EX      AF,AF'          ; lenght in AF'
        LD      DE,512+48       ; 1?
        DEC     BC
        LD      A,B
        OR      C
        JR      Z,L38F1         ; EXO_GOFORIT
        LD      DE,1024+32
        DEC     BC              ; 2?
        LD      A,B
        OR      C
        JR      Z,L38F1         ; EXO_GOFORIT
        LD      E,16
;; EXO_GOFORIT
L38F1:  CALL    L3BE0           ; EXO_GETBITS
        LD      A,E
        ADD     A,C
        LD      C,A
        JP      L3AA9

        DEFB    $FF; 1 byte

L38FB:  IN      L,(C)
        JP      (HL)
        NOP

L38FF:  IN      L,(C)
        JP      (HL)

L3902:  LD      B,0             ; esta rutina lee 2 pulsos e inicializa el contador de pulsos
        CALL    $05ED
        CALL    $05ED
        LD      A,B
        RET

        DEFB    $FF; 1 byte

    IFDEF sinborde
        DEFB    $7F; 1 byte
    ENDIF

L390D:  DEFB    $ED, $ED, $7F   ; 0D
        DEFB    $ED, $ED, $7F   ; 10
        DEFB    $ED, $ED, $7F   ; 13
        DEFB    $ED, $ED, $7F   ; 16
        DEFB    $ED, $ED, $7F   ; 19
        DEFB    $ED, $ED, $7F   ; 1C
        DEFB    $ED, $ED, $7F   ; 1F
        DEFB    $ED, $ED, $7F   ; 22
        DEFB    $ED, $ED, $7F   ; 25
        DEFB    $EC, $EC, $7F   ; 28
        DEFB    $EC, $EC, $7F   ; 2B
        DEFB    $EC, $EC, $7F   ; 2E
        DEFB    $EC, $EC, $7F   ; 31
        DEFB    $EC, $EC, $7F   ; 34
        DEFB    $EC, $EC, $7F   ; 37
        DEFB    $EC, $EC, $7F   ; 3A
        DEFB    $EC, $EC, $7F   ; 3D
        DEFB    $EC, $EC, $7F   ; 40
        DEFB    $EC, $EF, $7F   ; 43 --
        DEFB    $EF, $EF, $7F   ; 46 --
        DEFB    $EF, $EF, $7F   ; 49
        DEFB    $EF, $EF, $7F   ; 4C
        DEFB    $EF, $EF, $7F   ; 4F
        DEFB    $EF, $EF, $7F   ; 52
        DEFB    $EF, $EF, $7F   ; 55
        DEFB    $EF, $EF, $7F   ; 58
        DEFB    $EF, $EF, $7F   ; 5B
        DEFB    $EF, $EE, $7F   ; 5E
        DEFB    $EF, $EE, $7F   ; 61
        DEFB    $EE, $EE, $7F   ; 64
        DEFB    $EE, $EE, $7F   ; 67
        DEFB    $EE, $EE, $7F   ; 6A
        DEFB    $EE, $EE, $7F   ; 6D
        DEFB    $EE, $EE, $7F   ; 70
        DEFB    $EE, $EE, $7F   ; 73
        DEFB    $EE, $EE, $7F   ; 76
        DEFB    $EE, $7F, $7F   ; 79
        DEFB    $EE, $7F, $7F   ; 7C
        DEFB    $EE             ; 7F

        DEFB    $ED, $ED, $7F   ; 80
        DEFB    $ED, $ED, $7F   ; 83
        DEFB    $ED, $ED, $7F   ; 86
        DEFB    $ED, $ED, $7F   ; 89
        DEFB    $ED, $ED, $7F   ; 8C
        DEFB    $EC, $EC, $7F   ; 8F
        DEFB    $EC, $EC, $7F   ; 92
        DEFB    $EC, $EC, $7F   ; 95
        DEFB    $EC, $EC, $7F   ; 98
        DEFB    $EC, $EF, $7F   ; 9B --
        DEFB    $EF, $EF, $7F   ; 9E
        DEFB    $EF, $EF, $7F   ; A1
        DEFB    $EF, $EF, $7F   ; A4
        DEFB    $EF, $EF, $7F   ; A7
        DEFB    $EF, $EE, $7F   ; AA
        DEFB    $EE, $EE, $7F   ; AD
        DEFB    $EE, $EE, $7F   ; B0
        DEFB    $EE, $EE, $7F   ; B3
        DEFB    $EE, $EE, $7F   ; B6
        DEFB    $EE             ; B9

    IFNDEF sinborde
        DEFB    $7F
    ENDIF

L39BB:  IN      L,(C)
        JP      (HL)
        NOP

L39BF:  IN      L,(C)
        JP      (HL)

L39C2:  POP     HL
        LD      SP,HL
        POP     HL              ; reemplazo pila, 4 bytes
        LD      ($BFFE),HL
        POP     HL
        LD      ($C000),HL
        JR      C, L39CB
        EXX
        DEC     SP
        POP     AF              ; last byte 7FFD
        OUT     (C),A
L39CB:  POP     BC              ; BC'
        POP     DE              ; DE'
        POP     HL              ; HL'
        EXX
        POP     AF              ; AF'
        EX      AF,AF'
        POP     BC              ; BC
        POP     DE              ; DE
        POP     HL              ; IR
        POP     IX              ; IX
        POP     IY              ; IY
        LD      A,L
        LD      I,A
        POP     AF              ; IM,IFF
        JR      NC,L39E1
        IM      2
L39E1:  JR      NZ,L39E4
        EI
L39E4:  PUSH    AF
        DEC     SP
        POP     AF
        RRA
        OUT     ($FE),A
        LD      A,H
        LD      HL,2
        ADD     HL,SP
        LD      R,A
        POP     AF              ; AF
        JP      (HL)

        DEFB    $FF; 1 byte

L39FB:  LD      C,$FE
        NOP
        NOP

L39FF:  LD      A,R             ;9        49 (41 sin borde)
        LD      L,A             ;4
        LD      B,(HL)          ;7
L3A03:  LD      A,IXL           ;8
        LD      R,A             ;9
    IFDEF sinborde
        DEC     H               ;4
        IN      L,(C)           ;12
        JP      (HL)            ;4
        DEFB    $FF, $FF; 2 bytes
    ELSE
        LD      A,B             ;4
        EX      AF,AF'          ;4
        DEC     H               ;4
        IN      L,(C)           ;12
        JP      (HL)            ;4
    ENDIF

L3A0D:  PUSH    IX
        POP     BC              ; pongo la direccion de comienzo en BC
        EXX                     ; salvo DE, en caso de volver al cargador estandar y para hacer luego el checksum
        LD      C,$00
        DEFB    $2A
L3A14:  JR      NZ,L3A29        ; return if at any time space is pressed.
L3A16:  LD      B,0
        CALL    L05ED           ; leo la duracion de un pulso (positivo o negativo)
        JR      NC,L3A14        ; si el pulso es muy largo retorno a bucle
        LD      A, B
        CP      40              ; si el contador esta entre 24 y 40
        JR      NC,L3A2D        ; y se reciben 8 pulsos (me falta inicializar HL a 00FF)
        CP      24
        RL      L
        JP      NZ,L3A2D
L3A29:  EXX
        LD      C,2
        RET
L3A2D:  CP      16              ; si el contador esta entre 10 y 16 es el tono guia
        RR      H               ; de las ultracargas, si los ultimos 8 pulsos
        CP      10              ; son de tono guia H debe valer FF
        JR      NC,L3A16
        INC     H
        JR      NZ,L3A16        ; si detecto sincronismo sin 8 pulsos de tono guia retorno a bucle
        CALL    L05ED           ; leo pulso negativo de sincronismo
        LD      L,$01           ; HL vale 0001, marker para leer 16 bits en HL (checksum y byte flag)
        CALL    L3A8E           ; leo 16 bits, ahora temporizo cada 2 pulsos
        POP     AF              ; machaco la direccion de retorno de la carga estandar
        EX      AF,AF'          ; A es el byte flag que espero
        CP      L               ; lo comparo con el que me encuentro en la ultracarga
        RET     NZ              ; salgo si no coinciden
        XOR     H               ; xoreo el checksum con en byte flag, resultado en A
        EXX                     ; guardo checksum por duplicado en H' y L'
        PUSH    BC              ; pongo direccion de comienzo en pila
        LD      H,A
        LD      L,A
        EXX
        LD      HL,$0040        ; leo 10 bits en HL
        LD      D,A
        LD      E,$FE
        CALL    L3A8E
        PUSH    HL
        POP     IX
    IFDEF sinborde
        XOR     A
        LD      A,$D8           ; A' tiene que valer esto para entrar en Raudo
        EX      AF,AF'
        AND     H
        JR      NZ,L3A5D
        LD      SP,$C000
        DEFB    $FE
L3A5D:  POP     DE              ; recupero en DE la direccion de comienzo del bloque
L3A5E:  INC     C               ; pongo en flag Z el signo del pulso
        LD      BC,$EFFE        ; este valor es el que necesita B para entrar en Raudo
        JR      Z,L3A6F
        LD      H,$3B+OFFS
L3A65:  IN      F,(C)
        JP      PE,L3A65
        CALL    L3BC3           ; salto a Raudo segun el signo del pulso en flag Z
        JR      L3A79
L3A6F:  LD      H,$39+OFFS      ; H tiene un valor 3B u otro 39 segun el signo del pulso
L3A71:  IN      F,(C)
        JP      PO,L3A71
        CALL    L3A03           ; salto a Raudo
L3A79:  AND     IXH             ; en caso de no verificar checksum me salto la rutina
        EXX                     ; ya se ha acabado la ultracarga (Raudo)
        JR      Z,L3A88
L3A7E:  LD      A,(BC)          ; verifico checksum
        XOR     H
        LD      H,A
        INC     BC
        DEC     DE
        LD      A,D
        OR      E
        JR      NZ,L3A7E
        XOR     H               ; salgo con A=0 H=0 L=checksum y Carry activo si todo
L3A88:  PUSH    BC              ; ha ido bien
        POP     IX              ; IX debe apuntar al siguiente byte despues del bloque
        RET     NZ              ; si no coincide el checksum salgo con Carry desactivado
        SCF
        RET
L3A8E:  CALL    L3902
        CP      6
        ADC     HL,HL
        JR      NC,L3A8E
        RET
L3A98:  INC     C
        LD      A,$D8           ; A' tiene que valer esto para entrar en Raudo
        EX      AF,AF'
        BIT     1,H
        JP      NZ,L3BC3        ; salto a Raudo segun el signo del pulso en flag Z
        JP      L3C05           ; salto a Raudo
    ELSE
        LD      A,$8D           ; A' tiene que valer esto para entrar en Raudo
        EX      AF,AF'
        AND     H
        JR      NZ,L3A5D
        LD      SP,$C000
        DEFB    $FE
L3A5D:  POP     DE              ; recupero en DE la direccion de comienzo del bloque
L3A5E:  INC     C               ; pongo en flag Z el signo del pulso
        LD      BC,$EFFE        ; este valor es el que necesita B para entrar en Raudo
        JR      Z,L3A6F
        LD      H,$3B+OFFS
L3A65:  IN      F,(C)
        JP      PE,L3A65
        CALL    L3BC3           ; salto a Raudo segun el signo del pulso en flag Z
        JR      L3A79
L3A6F:  LD      H,$39+OFFS      ; H tiene un valor 3B u otro 39 segun el signo del pulso
L3A71:  IN      F,(C)
        JP      PO,L3A71
        CALL    L3A03           ; salto a Raudo
L3A79:  AND     IXH             ; en caso de no verificar checksum me salto la rutina
        EXX                     ; ya se ha acabado la ultracarga (Raudo)
        JR      Z,L3A88
L3A7E:  LD      A,(BC)          ; verifico checksum
        XOR     H
        LD      H,A
        INC     BC
        DEC     DE
        LD      A,D
        OR      E
        JR      NZ,L3A7E
        XOR     H               ; salgo con A=0 H=0 L=checksum y Carry activo si todo
L3A88:  PUSH    BC              ; ha ido bien
        POP     IX              ; IX debe apuntar al siguiente byte despues del bloque
        RET     NZ              ; si no coincide el checksum salgo con Carry desactivado
        SCF
        RET
L3A8E:  CALL    L3902
        CP      6
        ADC     HL,HL
        JR      NC,L3A8E
        RET
L3A98:  INC     C
        LD      A,$8D           ; A' tiene que valer esto para entrar en Raudo
        EX      AF,AF'
        BIT     1,H
        JP      NZ,L3BC3        ; salto a Raudo segun el signo del pulso en flag Z
        JP      L3C05           ; salto a Raudo
        DEFB    $FF;  1 byte
    ENDIF
        
L3AA9:  CALL    L3BCD           ; EXO_GETPAIR, BC=offset
        POP     DE              ; DE=destination
        PUSH    HL    
        LD      H,D
        LD      L,E
        SBC     HL,BC           ; HL=origin
        EX      AF,AF'
        PUSH    AF
        POP     BC              ; BC=lenght
        LDIR
        POP     HL              ; keep HL, DE is updated
        JP      L38A9           ; EXO_MAINLOOP

L3ABB:  IN      L,(C)
        JP      (HL)
        NOP

L3ABF:  IN      L,(C)
        JP      (HL)

        DEFB    $FF;  1 byte

L3AC3:  DEC     (IY+$02)
L3AC6:  CALL    L3902
        JR      Z,L3AC6
        DEC     D
        JR      NZ,L3AC6
        LD      B,D
        CALL    L05ED
        PUSH    BC
        CALL    L05ED
        LD      E,B
        CALL    L2CB3           ; STK-(PULSE0+PULSE1)
        LD      D,B
        POP     BC
        LD      E,B
        CALL    L2CB3           ; STK-PULSE0
        RST     28H             ; FP-CALC      P0+P1, P0.
        DEFB    $01             ; EXCHANGE     P0, P0+P1.
        DEFB    $05             ; DIVISION     P0/(P0+P1).
        DEFB    $A2             ; STK-HALF     P0/(P0+P1), 0.5.
        DEFB    $03             ; SUBTRACT     P0/(P0+P1)-0.5.
        DEFB    $38             ; END-CALC
        CALL    L2DE3           ; ROUTINE PRINT-FP OUTPUTS THE NUMBER TO
        LD      A,$0D
        RST     10H
        LD      D,A
        LD      C,3
        JR      L3AC6

    IFDEF sinborde
L3AF1:  XOR     B
        ADD     A,A
        RET     C
        ADD     A,A
        EX      AF,AF'
        IN      L,(C)
        JP      (HL)
        DEFB    $FF, $FF; 2 bytes
L3AFB:  LD      C,$FE
        NOP
        NOP
L3AFF:  INC     H
        EX      AF,AF'          ;4
        JR      NC,L3AF1
        XOR     B
        LD      (DE),A
        INC     DE
        LD      A,$DC
        EX      AF,AF'
        IN      L,(C)           ;12
        JP      (HL)            ;4
        DEFB    $FF; 1 byte
    ELSE
L3AF1:  XOR     B
        LD      (DE),A
        INC     DE
        LD      A,$88
        SCF
        EX      AF,AF'
        IN      L,(C)
        JP      (HL)
L3AFB:  LD      C,$FE
        NOP
        NOP
L3AFF:  INC     H
        JP      NC,L3AF1
        XOR     B
        ADD     A,A
        RET     C
        ADD     A,A
        EX      AF,AF'
        OUT     ($FE),A         ;11
        IN      L,(C)           ;12
        JP      (HL)            ;4
    ENDIF

    IFDEF sinborde
        DEFB    $7F; 1 byte
    ENDIF

L3B0D:  DEFB    $ED, $ED, $7F, $ED, $ED, $7F, $ED, $ED;
        DEFB    $7F, $ED, $ED, $7F, $ED, $ED, $7F, $ED;
        DEFB    $ED, $7F, $ED, $ED, $7F, $ED, $ED, $7F;
        DEFB    $ED, $ED, $7F, $EC, $EC, $7F, $EC, $EC;
        DEFB    $7F, $EC, $EC, $7F, $EC, $EC, $7F, $EC;
        DEFB    $EC, $7F, $EC, $EC, $7F, $EC, $EC, $7F;
        DEFB    $EC, $EC, $7F, $EC, $EC, $7F, $EC, $EF;
        DEFB    $7F, $EF, $EF, $7F, $EF, $EF, $7F, $EF;
        DEFB    $EF, $7F, $EF, $EF, $7F, $EF, $EF, $7F;
        DEFB    $EF, $EF, $7F, $EF, $EF, $7F, $EF, $EF;
        DEFB    $7F, $EF, $EE, $7F, $EF, $EE, $7F, $EE;
        DEFB    $EE, $7F, $EE, $EE, $7F, $EE, $EE, $7F;
        DEFB    $EE, $EE, $7F, $EE, $EE, $7F, $EE, $EE;
        DEFB    $7F, $EE, $EE, $7F, $EE, $7F, $7F, $EE;
        DEFB    $7F, $7F, $EE, $ED, $ED, $7F, $ED, $ED;
        DEFB    $7F, $ED, $ED, $7F, $ED, $ED, $7F, $ED;
        DEFB    $ED, $7F, $EC, $EC, $7F, $EC, $EC, $7F;
        DEFB    $EC, $EC, $7F, $EC, $EC, $7F, $EC, $EF;
        DEFB    $7F, $EF, $EF, $7F, $EF, $EF, $7F, $EF;
        DEFB    $EF, $7F, $EF, $EF, $7F, $EF, $EE, $7F;
        DEFB    $EE, $EE, $7F, $EE, $EE, $7F, $EE, $EE;
        DEFB    $7F, $EE, $EE, $7F, $EE;

    IFNDEF sinborde
        DEFB    $7F; 1 byte
    ENDIF

L3BBB:  LD      C,$FE
        NOP
        NOP

L3BBF:  LD      A,R
        LD      L,A
        LD      B,(HL)
L3BC3:  LD      A,IXL
        LD      R,A

    IFDEF sinborde
        DEC     H
        IN      L,(C)
        JP      (HL)
        DEFB    $FF, $FF; 2 bytes
    ELSE
        LD      A,B
        EX      AF,AF'
        DEC     H
        IN      L,(C)
        JP      (HL)
    ENDIF
        
;; EXO_GETPAIR
L3BCD:  LD      IYL,C
        LD      D,(IY+0)
        CALL    L3BE0           ; EXO_GETBITS
        LD      A,C
        ADD     A,(IY+52)
        LD      C,A
        LD      A,B
        ADC     A,(IY+104)      ; always clear C flag
        LD      B,A
        RET

;; EXO_GETBITS
L3BE0:  LD      BC,0            ; get D bits in BC
L3BE3:  DEC     D
        RET     M
        CALL    L3BEE           ; EXO_GETBIT
        RL      C
        RL      B
        JR      L3BE3

;; EXO_GETBIT
L3BEE:  LD      A,IXH           ; get one bit
        ADD     A,A
        LD      IXH,A
        RET     NZ
        LD      A,(HL)
        INC     HL
        RLA
        LD      IXH,A
        RET

        DEFB    $FF; 1 byte

L3BFB:  IN      L,(C)
        JP      (HL)
        NOP

L3BFF:  IN      L,(C)
        JP      (HL)

L3C02:  DEFB    $FF; 1 bytes

L3C03:  LD      (DE),A          ; Una de las dos opciones de subfuncion a llamar (En este caso pinta/borra pieza)
        RET

L3C05:  JP      L3A03

        DEFB    $FF; 1 bytes

L3C07:  AND     D
        RST     $10
        DEC     (IY+$02)
        LD      IXH,B
L3C0E:  LD      B,23            ; Dibujar 22 lineas (el primer CR se salta) con "RANDOMIZE " en tinta y fondo negros (se ve una columna negra de 10 caracteres de ancho)
        LD      A,$11           ; Funcion que cambia el color de fondo
        RST     $10
        DB      $3A             ; xor   a, Opcode para LD A, (NN). En la primera pasada se salta el CR y carga A con el valor 0 (fondo negro)
L3C14:  RST     $10             ; Funcion imprime caracter por pantalla, el codigo ASCII se introduce en el registro A
        LD      A,13            ; Codigo ASCII para CR (retorno de carro)
        LD      (IY-$0B),A      ; Pongo inicialmente a 13 la variable velo (velocidad) que en realidad es el retardo en frames de la caida de una pieza. Es necesario inicializarla porque durante el juego se decrementa y pierde su valor inicial (variable incrustada en codigo)
        RST     $10             ; Envio por pantalla el retorno de carro (fondo negro en primera iteracion)
        LD      A,249           ; Codigo ASCII para RANDOMIZE, lo uso porque es el token mas largo, que ademas me da el ancho de 10 cuadros que necesito (contando con el espacio del final)
        DJNZ    L3C14           ; Repito el bucle 23 veces (dibujo 22 lineas). Si lo hago tras perder una partida se produce scroll (y la tipica pregunta scroll? mas?)
        LD      HL,$0110        ; Inicializo las variables REPDEL, REPPER (frames para detectar una pulsacion continua y cadencia en frames del envio de la misma tecla) a unos valores mas optimos para jugar
        LD      ($5C09),HL      ; Los que usa la ROM por defecto son muy lentos para la dinamica del juego
L3C25:  LD      A,R             ; Leo un numero pseudoaleatorio del registro R
L3C27:  SUB     7               ; Estas dos lineas equivalen a un MOD 7
        JR      NC,L3C27        ; o resto de dividir el byte entre 7, ya que necesito elegir una pieza al azar de entre las 7
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
L3C3F:  LD      IXL,$F3         ; IX apunta a la subfuncion a llamar (dentro de la funcion L3CDC), en este caso es la que comprueba si hay colision antes de pintar la pieza
        CALL    L3CDC           ; Llamo a la funcion L3CDC para testear la pieza (con -1 ahorro un byte porque PUSH DE coincide con el ultimo byte de la instruccion anterior)
        JR      Z,L3C51         ; Si no hay colision, salto a ncol
        POP     HL              ; Si hay colision, recupero los valores de posicion
        POP     DE              ; y pieza anteriores a la colision
        LD      SP,$FF40        ; Equilibro la pila, ya que la estaba desequilibrando con muchos PUSH HL,DE y un solo POP HL,DE
        BIT     2,C             ; Compruebo si en punto de entrada del bucle es haber
        JR      Z,L3C0E         ; generado la pieza, en tal caso (con una colision nada mas generar la pieza) reinicio el juego
        INC     C               ; Senalizo la colision poniendo a 1 el bit 1 del registro C
L3C51:  LD      IXL,$03         ; IX apunta a la subfuncion pintar/borrar
        EX      AF,AF'          ; recupero el color de A'
        CALL    L3CDC           ; pinto la pieza
        EX      AF,AF'          ; vuelvo a guardar el color en A'
        BIT     1,C             ; Compruebo si ha habido colision (del tipo colision contra el suelo, no vale contra paredes ni tras rotar)
        JR      NZ,L3C9E        ; Salto a L3C9E en caso de ese tipo de colision
        PUSH    DE              ; Guardo posicion en pila
L3C5E:  LD      A,($5C78)       ; Leo contador de frames
        LD      B,A             ; Lo guardo temporalmente en B
        SUB     (IY)            ; Comparo con referencia (valor de frames que tenia la pieza antes de descender)
        SUB     (IY-$0B)        ; Aplico un retardo (numero de frames que tarda la pieza en descender)
        JR      Z,L3C73         ; Si se agota el tiempo, la pieza cae por gravedad, salto a "salt"
        BIT     5,(IY+1)        ; Mientras tanto voy leyendo si se ha pulsado una tecla
        JR      Z,L3C5E         ; En tal caso, rompo el bucle de tiempo
        LD      A,($5C08)       ; Con el registro A conteniendo el codigo ASCII de la tecla pulsada
L3C73:  PUSH    HL              ; Guardo pieza en pila
        CALL    L1F4F           ; res   5, (iy+1). Senalizo tecla leida. En este punto si A vale cero es que no se ha pulsado nada y la pieza cae por si sola
        PUSH    AF              ; Guardo tecla pulsada
        XOR     A               ; Borrar es pintar con color 0 (negro)
        CALL    L3CDC           ; Borra pieza
        POP     AF              ; Recupero tecla pulsada
        SUB     $6F             ; He pulsado izquierda?
        JR      NZ,L3C82        ; No, pues salto y no hago nada
        DEC     E               ; Si, pues decremento posicion
L3C82:  DEC     A               ; He pulsado derecha? seria caracter 'p' justo despues de 'o', por eso basta con un decremento para comparar
        JR      NZ,L3C86        ; No, pues salto y no hago nada
        INC     E               ; Si, pues incremento posicion
L3C86:  DEC     A               ; He pulsado arriba (rotar)? seria caracter 'q', despues de 'p'
        LD      C,1             ; Inicializo A y C a cero y uno respectivamente, independientemente de si salto o no
        JR      Z,L3CCB         ; Si, pues salto a rota (con A y C inicializadas)
        ADD     $0F             ; Se ha pulsado una tecla que cae fuera del rango 'b'-'q'? Como por ejemplo 'a', acelerar caida
        LD      A,B             ; Pongo la actual variable FRAMES1 de B a A
L3C8E:  LD      BC,$2004        ; Inicializo B a 32 (bajo posicion una fila completa) y C a 4 indicando que entro al bucle principal via pieza no acelerada
        JR      C,L3C3F         ; Si la pieza cae por su peso (ninguna tecla pulsada), cierro bucle principal
        INC     C               ; Si se ha pulsado 'a' o equivalente, senalizo pieza acelerada en registro C
L3C94:  INC     DE              ; Avanza la posicion en una fila (32 caracteres)
        DJNZ    L3C94
        LD      (IY),A          ; Pongo FRAMES1 (antes guardada en A) como referencia en time (variable incrustada en codigo)
        JR      L3C3F           ; Cierro bucle principal
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
        JP      C,L3C25         ; Si me salgo de la zona de atributos es que ya he llegado a la primera linea y por tanto salgo del bucle (a generar una nueva pieza)
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
        JR      L3C8E           ; Salto al bucle principal (con indicador de pieza no acelerada)
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
