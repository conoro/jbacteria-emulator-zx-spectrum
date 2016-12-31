LOCALS
.MODEL SMALL
.486
.CODE
ORG 100H
;-----------------------variables guardadas en snap,f†cil acceso e inicializadas a 0
F       equ     DL
A       equ     BYTE PTR DS:[DI]
BC      equ     WORD PTR DS:[DI+2]
B       equ     BYTE PTR DS:[DI+3]
C       equ     BYTE PTR DS:[DI+2]
DE      equ     WORD PTR DS:[DI+4]
D       equ     BYTE PTR DS:[DI+5]
E       equ     BYTE PTR DS:[DI+4]
HL      equ     WORD PTR DS:[DI+6]
H       equ     BYTE PTR DS:[DI+7]
L       equ     BYTE PTR DS:[DI+6]
AFp     equ     WORD PTR DS:[DI+8]
Ap      equ     BYTE PTR DS:[DI+9]
Fp      equ     BYTE PTR DS:[DI+8]
BCp     equ     WORD PTR DS:[DI+10]
Bpp     equ     BYTE PTR DS:[DI+11]
Cp      equ     BYTE PTR DS:[DI+10]
DEp     equ     WORD PTR DS:[DI+12]
Dpp     equ     BYTE PTR DS:[DI+13]
Ep      equ     BYTE PTR DS:[DI+12]
HLp     equ     WORD PTR DS:[DI+14]
Hp      equ     BYTE PTR DS:[DI+15]
Lp      equ     BYTE PTR DS:[DI+14]
IX      equ     WORD PTR DS:[DI+16]
IY      equ     WORD PTR DS:[DI+18]
IR      equ     WORD PTR DS:[DI+20]
I       equ     BYTE PTR DS:[DI+21]
R       equ     BYTE PTR DS:[DI+20]
RD      equ     BYTE PTR DS:[100h+20]
TIM     equ     WORD PTR DS:[DI+22]
PRB     equ     BYTE PTR DS:[DI+24]
POR     equ     BYTE PTR DS:[DI+25]
POC     equ     BYTE PTR DS:[100h+25]
IMA     equ     WORD PTR DS:[DI+25]
IM      equ     BYTE PTR DS:[DI+26]   ;PROBAR EN DI+1
SNAPF   equ     BYTE PTR DS:[DI+27]
SNAPSI  equ     WORD PTR DS:[DI+28]
SNAPBP  equ     WORD PTR DS:[DI+30]
;-----------------------constantes ensamblaje condicional
SOUNDB  equ     0               ;utilizo soundblaster o speaker
ESPANOL equ     1               ;el texto aparece en espa§ol
INGLES  equ     0               ;el texto aparece en inglÇs
JOYST   equ     1               ;a 1 para deshabilitar el joystick
COMPRE  equ     0               ;a 1 compresi¢n habilitada
;-----------------------constantes miscelanea
SENSI   equ     80              ;sensibilidad del joystick
TOTREG  equ     32              ;numero total de registros que se guardan
HFILE   equ     5               ;handle generico del archivo tap
TOTNOP  equ     32              ;nops que se deben insertar al principio
;-----------------------variables no guardadas en snap,f†cil acceso e inicializadas a 0
FLASH   equ     BYTE PTR DS:[DI-19]
FLAS2   equ     BYTE PTR CS:[100h-19]
EJEX    equ     WORD PTR DS:[DI-20]     ;centro del eje x del joystick
EJEY    equ     WORD PTR DS:[DI-18]     ;centro del eje y del joystick
PFAIR   equ     WORD PTR DS:[DI-16]
TVACIO  equ     WORD PTR DS:[DI-14]
TIEM    equ     WORD PTR DS:[DI-12]
PUNTE   equ     WORD PTR DS:[DI-10]     ;puntero del sample actual de sonido
PUNTEG  equ     WORD PTR CS:[100h-10]
PUNTEG1 equ     BYTE PTR CS:[100h-9]
MAXLEN  equ     WORD PTR DS:[100h-8]    ;m†xima longitud de cadena encontrada en bytes
MAXPOS  equ     WORD PTR DS:[100h-6]    ;posici¢n hacia atr†s donde se encuentra la cadena
MAXTLE  equ     WORD PTR DS:[100h-4]    ;m†xima longitud total en bits que llevo
TMTEC   equ     BYTE PTR DS:[DI-2]      ;tecla pulsada en el frame anterior
EXTEN   equ     BYTE PTR CS:[100h-1]    ;flag indicando car†cter extendido

GRAB    equ     20h             ;GRABx128=NUMERO DE BOTONES QUE SE GRABAN
repu    equ     100h
longde  equ     133             ;longitud en bytes del descompresor
;-----------------------empieza el programa
START:  DB      TOTNOP DUP (0)
IF COMPRE
ELSE
        XOR     AX,AX
ENDIF
IF SOUNDB
        MOV     DI,AX
        MOV     FS,AX
        MOV     CH,040h
        mov     es,word ptr ds:[DI+2Ch]
@sigdet:repnz   scasb
        scasb
        jz      @findet
        cmp     word ptr es:[di-1],'LB'
        jnz     @sigdet
        mov     al,BYTE PTR ES:[di+09h]         ;PUERTOBASE
        shl     ax,4
        add     ax,6-100h      ;2x6
        xchg    ax,dx
        sub     BYTE PTR ES:[DI+0Dh],'0'-8      ;IRQ
        mov     cl,BYTE PTR ES:[DI+0Dh]         ;IRQ
        mov     al,1
        rol     al,cl
        mov     BYTE PTR DS:[offset pico+1],al
        MOV     BP,OFFSET @waitw
        mov     al,1
        out     dx,al          ; start DSP reset
        call    BP
        xchg    ax,cx
        out     dx,al          ; end DSP Reset
        add     dl,8           ;2xE
        mov     WORD PTR DS:[offset adbase+1],dx
@waitr: in      al,dx
        or      al,al
        jns     @waitr
        sub     dl,4           ; dx = 2xA DSP Read Data
        in      al,dx
@findet:cmp     al,0aah        ; if there is a SB then it returns 0AAh
        jnz     @empe
        inc     dx
        inc     dx             ; 2xC
        call    BP
        mov     al,0D1h        ; AL = Enable speaker
        out     dx,al
        in      al,021h
        mov     bl,BYTE PTR DS:[offset pico+1]
        not     bl
        and     al,bl
        out     021h,al
IF COMPRE
        mov     bl,BYTE PTR ES:[DI+0Dh]         ;IRQ
ELSE
        movzx   bx,BYTE PTR ES:[DI+0Dh]         ;IRQ
ENDIF
        shl     bl,2
        mov     word ptr fs:[bx],OFFSET OWN_IRQ
        mov     word ptr fs:[bx+2],ds
        mov     al,BYTE PTR ES:[DI+10h]         ;DMACHANEL
        sub     al,'0'-4
        out     10,al                   ;Write mask
        out     12,al                   ;Clear ff
        add     al,01011000b-4          ;Wanted mode: singlemode, autoinit, readmode
        out     11,al                   ;Write mode
        sub     al,01011000b            ;Wanted mode: singlemode, autoinit, readmode
        push    dx
        push    ax
        mov     ax,ds
        rol     ax,4                ; * 16 - higher 4 bits in al
        mov     bl,al
        and     bl,00fh             ; BL - higher 4 bits
        and     al,0f0h             ; clear higher 4bits in AL
        add     ax,offset BUFSO
        adc     bl,bh               ; BL = page
        pop     dx
        push    dx
        add     dx,dx
        out     dx,al
        mov     al,ah
        out     dx,al
        mov     cx,dx
        add     cx,cx
        inc     dx
        mov     al,0DFh ;1247cl
        out     dx,al
        mov     al,004h ;ch
        out     dx,al
        mov     ax,7312h
        shl     ax,cl
        shr     ax,12
        add     al,80h
        xchg    ax,dx
        xchg    ax,bx
        out     dx,al
        pop     ax
        pop     dx
        out     10,al                   ;Write mask
        mov     al,040h                 ;AL = Set timeconstant
        out     dx,al
        mov     al,224                  ; = 31250 Hz (256-1000000/11000)
        out     dx,al
        call    BP
        mov     al,048h                 ;AL = DMA DAC 8bit
        out     dx,al
        call    BP
        mov     al,06Fh                      ;AL = LOWER PART SAMPLELENGTH
        out     dx,al
        call    BP
        mov     al,2                         ;AL = HIGHER PART SAMPLELENGTH
        out     dx,al
        call    BP
        mov     al,1ch                 ;AL = Auto-Initialize DMA DAC, 8-bit
        out     dx,al
@empe:  mov     bl,80h
ELSE
        mov     bx,80h
ENDIF
IF COMPRE
        pop     di           ;100h          ;Seccion 3
        pop     es           ;ds+1000h
ELSE
        mov     di,100h
        mov     ax,ds
        add     ah,11h
        mov     es,ax
ENDIF
        mov     si,81h
kili:   mov     dx,si
        lodsb
        cmp     al,32
        jz      kili
        mov     word ptr ds:[oche+1],dx
        add     bl,[bx]
        mov     [bx+1],bh
        mov     ax,3D00h     ;open for read
        int     21h
        jc      @MIMI                    ;error file no exist
        test    byte ptr ds:[bx],0Fh     ;.tap p=50h flag z activate
        jz      @MIMI
        mov     byte ptr ds:[offset @MOFE],03Ch ;make jump in mofe
        xchg    ax,bx
        push    es
        pop     ds
        mov     ah,3Fh
        mov     dx,03FE5h                ;place to open snap
        mov     cx,0C01Bh                ;length to open
        int     21h
        push    cs
        pop     ds
@MIMI:  mov     ax,3D00h                 ;open for read
        mov     dx,OFFSET nrom           ;rom file
        int     21h
        jnc     @nfino
        mov     ah,9
        mov     dx,offset cade ;no cambiar
        int     21h
        ret
@nfino: push    ax                       ;push handle
        mov     al,13h
        int     10h                      ;mode 13h
        db      0D6h
        mov     dx,3C8h
        out     dx,al                    ;color index=0
        inc     dx
        mov     si,offset colores
        mov     cx,3*17
        rep     outsb
IF JOYST
ELSE
        CALL    @LEEJO                  ;read joystick axes
        MOV     EJEY,BX
        MOV     EJEX,CX
ENDIF
        mov     ax,3509h                   ;save interrup vectors
        push    es
        int     21h
        mov     word ptr ds:[IRQ9SEG],es
        mov     word ptr ds:[IRQ9OFF+1],bx
        mov     ah,25h                     ;set keyboard interrupt
        mov     dx,offset NewInt9
        int     21h
        pop     es
        xor     si,si
@MOFE:  JMP     @FISI
        CALL    @LDSNA                  ;load snapshot
@DLDA:  CALL    @MUEL
@FISI:  pop     bx                      ;end of sna, bx=handle
        push    es
        pop     ds
        mov     ah,3Fh
        PUSH    DX
        cwd
        mov     ch,40h
        int     21h                     ;read 48.rom
        POP     DX
        push    cs
        pop     ds
        CALL    @GRABA
@INIV:  MOV     AX,0
        MOV     TVACIO,AX               ;ES IMPORTANTE QUE SEA DESPUES DE GRABA

@DECO:  MOV     DI,100h
        CMP     DH,112
        JC      @SIGE
        SUB     DH,112
IF SOUNDB
        MOV     AL,BYTE PTR DS:[@issue+1]
        SHL     AL,2
        DB      0D6h
        MOV     BX,PUNTE
        MOV     BYTE PTR DS:[BX+OFFSET BUFSO],AL
        cmp     bh,5
        jnc     @npute
        INC     PUNTE
@npute: 
ELSE
@llkk:  db      0D6h
        out     43h,al
        in      al,40h
        mov     ah,al
        in      al,40h
        xchg    al,ah
        mov     cx,ax
        sub     cx,TIEM
trik:   add     cx,38
        jc      @llkk
        mov     TIEM,ax
        IN      AL,61h
        AND     AL,11111100b
        TEST    POR,10h
        JZ      @CERO
        OR      AL,2
@CERO:  OUT     61h,AL
ENDIF
        MOV     AX,TIM
        INC     TIM
        SHR     AX,1
        JC      @DECO ;;;;;;
        CMP     AX,252
        JNC     @VLSI
        SUB     AX,52
        JC      @DECO ;;;;;
        DB      68h
        DW      OFFSET @SIGE
@PANTA: MOV     DI,AX     ;APUNTAREMOS A LA PANTALLA
        XCHG    AH,AL     ;MULTIPLICAMOS AX POR 256
        SHL     DI,6      ;MULTIPLICAMOS DI POR 64
        ADD     DI,AX     ;DI YA ESTA CALCULADO DI=320*line
        MOV     AL,POC    ;EN AL EL COLOR DEL BORDE "POR"
        DB      68h        ;MOV DS,A000
        DW      0A000h
        POP     DS
        PUSH    DS ;compresor
        POP     FS
        AND     AL,111b   ;LOS BITS QUE ME INTERESAN DEL BORDE
        SUB     AH,4
        JC      @TBDE
        CMP     AH,192
        JC      @DNTR
@TBDE:  MOV     CX,320    ;;;;;;;NUMERO DE PUNTOS=320=1 LINEA ENTERA
        CMP     CL,BYTE PTR SS:[@MVEE+1]
        JNC     @TCLP
        MOV     AL,16
@TCLP:  JMP     @CCLP
@DNTR:  MOV     CX,32  ;;;;;;;;;;;;;;   ;CX = 32 PUNTOS QUE HAY DE BORDE IZDO
@CCLO:  MOV     BYTE PTR DS:[DI],AL   ;PINTO UN PUNTO
        INC     DI        ;INCREMENTO POSICION
        LOOP    @CCLO    ;REPITO 32 VECES
        PUSH    AX
        MOV     CL,AH
        AND     AH,11000000b
        MOV     BX,CX
        AND     BL,111b
        SHL     BL,3
        SHR     CL,3
        PUSH    CX
        AND     CL,111b
        OR      BL,CL
        OR      BL,AH
        MOV     BH,2
        SHL     BX,5
        POP     AX
        SHL     AX,5
        ADD     AH,58h
        MOV     CL,32     ;CX=32= NUMERO DE CARACTERES A PINTAR
        PUSH    DX
@LIN1:  PUSH    CX       ;GUARDAMOS EN PILA
        XCHG    AX,BX    ;AX=ATTRIB  BX=BYTECARAC
        MOV     DH,ES:[BX];DH=ATRIBUTO
        XCHG    AX,BX    ;BX=ATTRIB  AX=BYTECARAC
        INC     AX        ;INCREMENTO BYTECARAC
        MOV     CH,DH
        AND     CH,111b
        MOV     CL,DH
        AND     CL,38h
        SHR     CL,3
        TEST    DH,40h
        JZ      @NBRI
        OR      CX,0808h
@NBRI:  TEST    DH,FLAS2
        JNS     @LIN2
        XCHG    CH,CL
@LIN2:  ROL     BYTE PTR ES:[BX],1
        JC      @PIFO
        MOV     BYTE PTR DS:[DI],CL
        DB      3Dh
@PIFO:  MOV     BYTE PTR DS:[DI],CH
@PIPI:  INC     DI
        TEST    DI,111b
        JNZ     @LIN2
        POP     CX
        INC     BX          ;INCREMENTO ATRIBUTO
        LOOP    @LIN1      ;REPITO 32 VECES
        POP     DX
        POP     AX
        MOV     CL,32
@CCLP:  MOV     BYTE PTR DS:[DI],AL
        INC     DI
        LOOP    @CCLP
        PUSH    CS
        POP     DS
        MOV     DI,100h
        RET
@VLSI:  SUB     AX,312
        JNZ     @SIGE
        MOV     TIM,AX

IF SOUNDB
@aqui:  jmp     @aqui
        mov     byte ptr ds:[@aqui+1],0FEh
@alli:
ENDIF


IF JOYST
@MVEE:  MOV     CX,11             ;11 estados kempston,8 column,2funcios
ELSE
@DESJO: JMP     @MVEE             ;descarto si no hay joystick
        CALL    @LEEJO            ;leo ejes en cx y bx
        MOV     AX,4              ;bit 4=boton
        CALL    @EMJO             ;guardo en variable
        DEC     AX                ;bit 3=arriba
        SUB     BX,EJEY
        JNC     @ABJ
        ADD     BX,SENSI          ;comparo arriba
        CALL    @EMJO             ;guardo
        JMP     @MVER
@ABJ:   DEC     AX                ;bit 2=abajo
        CMP     BX,SENSI          ;comparo abajo
        CALL    @EMJO             ;guardo
@MVER:  MOV     AL,1              ;bit 1=izqui
        MOV     BX,CX
        SUB     BX,EJEX
        JNC     @ABE
        ADD     BX,SENSI          ;comparo izqui
        CALL    @EMJO             ;guardo
        JMP     @MVEE
@ABE:   DEC     AX                ;bit 0=dere
        CMP     BX,SENSI          ;comparo
        CALL    @EMJO             ;guardo
@MVEE:  MOV     CX,12             ;12 estados joystick,kempston,8 column,2funcios
ENDIF
@PMVE:  MOV     BX,OFFSET TECAC
IF JOYST
@BUBX:  MOV     AL,BYTE PTR DS:[BX+OFFSET TECLADO-OFFSET TECAC-1] ;leo de teclado
ELSE
@BUBX:  MOV     AL,BYTE PTR DS:[BX+OFFSET TECLADO-OFFSET TECAC-2] ;leo de teclado
ENDIF
        MOV     AH,BYTE PTR DS:[BX]                               ;leo de tecac
        MOV     BYTE PTR DS:[BX],AL                               ;escribo en teclado
        XOR     AH,AL                ;miro diferencias entre pulsado anterior y ahora
        MOV     CH,5                 ;ch=5 teclas por byte=movimientos kempston=funcios
@OTBX:  SAHF                         ;miro bit0 de ah
        JNC     @NABX                ;si no carry salto a nabx
        PUSHA                        ;diferencia, pongo todo en pila
        XCHG    AX,CX                ;en ax tengo contadores que me indican el evento
        SUB     AX,0101h             ;resto uno a fila y columna
        MOV     CH,AL                ;ch=fila-1
        SHL     AL,2                 ;al=(fila-1)*4
        ADD     AL,CH                ;al=(fila-1)*5
        ADD     AL,AH                ;al=(fila-1)*5+columna-1
        MOV     CH,AL                ;ch=(fila-1)*5+columna-1
        MOV     BX,TVACIO            ;bx=contador de estados sin cambiar
        CWD
        MOV     TVACIO,DX            ;reseteo contador de estados
        XCHG    AL,TMTEC
        SHL     AX,10                ;en parte alta pongo evento
        OR      AX,BX                ;en parte baja contador de estados
        MOV     BX,PFAIR             ;leo puntero de grabaci¢n
        CMP     BH,GRAB              ;si ya he leido mucho tiempo
        JZ      @NOIN                ;no incremento puntero
        ADD     PFAIR,2              ;incremento puntero
@NOIN:  MOV     WORD PTR DS:[BX+OFFSET FAIR],AX  ;guardo en zona
        CMP     CH,10                ;miro si orden es mayor de 10
        MOV     GS,CX                ;guardo orden en gs
        POPA                         ;restauro registros
        JNC     @NABX                ;continuo bucle si no orden
        PUSH    CX
        MOV     CX,GS                ;leo orden pulsada
        SHR     CL,1                 ;veo si es descartable
        JNC     @APEA
        SUB     PFAIR,2              ;recupero puntero cambiado
        JMP     @KSTK
@APEA:  SHR     CX,8                 ;cl=orden
        CALL    @EXECU               ;ejecuto orden
@KSTK:  POP     CX
@NABX:  SHR     AX,1               ;leo siguiente bit de diferencia de entre los 5
        DEC     CH
        JNZ     @OTBX              ;cierro bucle columna
        INC     BX
        LOOP    @BUBX              ;cierro bucle fila
;IF SOUNDB
;        INC     TVACIO             ;tvacio=tvacio+1   o 1
;ELSE
        MOV     AX,TVACIO
        INC     AX
        SAHF
        JNP     @NMEL
        MOV     AL,7       ;F7
        XCHG    AL,TMTEC
        SHL     AX,10
        OR      AX,3FFh
        MOV     BX,PFAIR
        CMP     BH,GRAB
        JZ      @NOIA
        ADD     PFAIR,2
@NOIA:  MOV     WORD PTR DS:[BX+OFFSET FAIR],AX
        MOV     AX,1
@NMEL:  MOV     TVACIO,AX
;ENDIF
        JMP     @NREPR

@REPRO: 
        BT      WORD PTR DS:[OFFSET FUNCIOS],1
IF COMPRE
        JC      SILK
ELSE
        JNC     SILK
ENDIF
IF JOYST
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 11)*100h
ELSE
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 12)*100h
ENDIF
IF SOUNDB
        MOV     BYTE PTR DS:[OFFSET trik+1],0
ELSE
        MOV     BYTE PTR DS:[OFFSET trik+2],38
ENDIF
SILK:   BT      WORD PTR DS:[OFFSET FUNCIOS],0        ;F5
        JC      SIL2
IF SOUNDB
        MOV     BYTE PTR DS:[OFFSET trik+1],5
ELSE
        MOV     BYTE PTR DS:[OFFSET trik+2],0
ENDIF
SIL2:   DEC     TVACIO
        JNZ     @ACTE                     ;si tvacio=0 hago ste cosa
@MIGO:  MOV     TVACIO,3FFh               ;pongo tvacio al maximo
        MOV     BX,PFAIR
        ADD     PFAIR,2
        MOV     AX,WORD PTR DS:[BX+OFFSET FAIR+2] ;leo orden guardada
        PUSH    AX
        SHR     AX,10
        CMP     AL,8
        JNZ     @KOAE                          ;miro si la orden es F6 fin de reproducci¢n
IF JOYST
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 11)*100h
ELSE
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 12)*100h
ENDIF
IF SOUNDB
        MOV     BYTE PTR DS:[OFFSET trik+1],0
ELSE
        MOV     BYTE PTR DS:[OFFSET trik+2],38
ENDIF

@KOAE:  MOV     CL,5                           ;puesto en modo grabaci¢n
        DIV     CL
        MOV     CL,AH                          ;cl=columna al=fila
IF JOYST
        MOV     BX,OFFSET TECAC+10 ;;;
ELSE
        MOV     BX,OFFSET TECAC+11 ;;;
ENDIF
        CBW
        SUB     BX,AX                          ;bx apunta a byte
        MOV     AL,10h
        SHR     AL,CL                          ;al apunta a bit
        XOR     BYTE PTR DS:[BX],AL            ;cambio estado
        POP     AX                             ;recupero tiempo
        AND     AX,3FFh                        ;filtro solo parte tiempo
        JZ      @MIGO                          ;si cero poner a 3ff y repetir ya que se pulso otra tecla en el mismo frame
        MOV     TVACIO,AX                      ;actualizar variable
@ACTE:

@NREPR: MOV     AL,FLASH
        INC     AX
        MOV     AH,80h
        CMP     AL,25
        JNZ     @NRST
        MOV     AL,-25
@NRST:  MOV     FLASH,AL
        TEST    IM,AH
        JZ      @SIGE
        XOR     IM,AH
        DEC     BP
        DEC     BP
        CMP     BYTE PTR ES:[SI],76h
        JNZ     @EHAL
        INC     SI
@EHAL:  MOV     WORD PTR ES:[BP],SI
        MOV     SI,38h
        ADD     DH,13
        SUB     AH,IM
        JS      @SIGE
        MOV     BH,I
        MOV     BL,0FFh
        MOV     SI,WORD PTR ES:[BX]
        ADD     DH,6

@SIGE:  DB      68h
        DW      OFFSET @DECO
        MOV     PRB,6
@ABAPRE:MOV     BX,102h
        MOV     AL,R
        ROL     AL,1
        ADD     AL,2
        ROR     AL,1
        MOV     R,AL
        XOR     CX,CX
        XOR     AX,AX
;                cmp     si,0BDBBh   ;56565656
;                jnz @pupu
;                nop
;@pupu:
        ADD     DH,4
        DB      026h
        LODSB
        SHL     AL,1
        JNC     @S
@N:     SHL     AL,1          ;80-FF
        JNC     _CALC
@NN:    ADD     DH,6
        SHR     AL,3          ;C0-FF
        JNC     @NNL
@NNH:   SHR     AL,1          ;C0-FF impares
        JC      @NNHH
@NNHL:  SHR     AL,1          ;C0-FF imp*par C1,C5,C9,CD,D1,D5,D9,DD,E1,E5,E9,ED,F1,F5,F9,FD 
        JNC     @NNHLL
@NNHLH: SHR     AL,1          ;C0-FF imp*par*imp  C5,CD,D5,DD,E5,ED,F5,FD
        JNC     _PUSH
@NNHLHH:SHR     AL,1          ;C0-FF imp*par*imp*imp  CD,DD,ED,FD
        JC      _DDFD
        JZ      _CALNN        ;C0-FF imp*par*imp*imp*par  CD,ED 
;‹‹‹‹‹‹‹;ED PREFIX
_EDPR:  MOV     AL,R
        ROL     AL,1
        ADD     AL,2
        ROR     AL,1
        MOV     R,AL
        ADD     DH,4
        DB      026h
        LODSB
        SHL     AL,1      
        JC      _N
_S:     SHL     AL,1      ;00-7F
        JNC     _NAD
_SN:    SHR     AL,3      ;40-7F
        JC      _SNH
_SNL:   SHR     AL,1      ;40 42 44 46 48 ...
        JC      _SNLH
_SNLL:  SHR     AL,1      ;40 44 48 4C 50
        JC      _NEG
;‹‹‹‹‹‹‹;IN S,(C) ;ED 40,48,50,58,60,68,70,78 "IN S,(C)" S=B,C,D,E,H,L,A
_INSC:  ADD     DH,4
        ADD     BX,AX
        AND     BL,111b
        XOR     BL,BH
_ED70:  DB      68h
        DW      OFFSET @DERE
@PINBC: MOV     AX,BC
@PIN:   PUSH    DI
        CMP     AL,0DFh
IF JOYST
        MOV     DI,OFFSET TECAC+1        ;kempston
ELSE
        MOV     DI,OFFSET TECAC+2
ENDIF
        JZ      @KOER
        TEST    AL,11100000b
        JNZ     @NOKE
@KOER:  DEC     DI
IF JOYST
;        MOV     AL,0FFh                ;NO ENTIENDO PORQUE LO DE ABAJO ES
;        XOR     AL,BYTE PTR DS:[DI]    ;MEJOR, PERO LO ES fffffffffffffff
        MOV     AL,BYTE PTR DS:[DI]
        DEC     DI
        AND     AL,BYTE PTR DS:[DI]
        NOT     AL
ELSE
        MOV     AL,BYTE PTR DS:[DI] ;;abcd mov al,ff xor al,
        DEC     DI
        AND     AL,BYTE PTR DS:[DI]
        NOT     AL
ENDIF
@NKNK:  POP     DI
        RET
@NOKE:  AND     AL,1
        JNZ     @NKNK
        INC     AX
@issue: MOV     CL,0BFh;;;;;;ABCD ;  OR  CL,0BFh ;;;;ABCD
@RUTL:  SHR     AH,1
        JC      @NAND
        AND     CL,BYTE PTR DS:[DI]
@NAND:  INC     DI
        SHL     AL,1
        JNZ     @RUTL
@KEMP:  XCHG    AX,CX
        POP     DI
_NAD:   RET
;‹‹‹‹‹‹‹;NEG ;ED 44,4C,54,5C,64,6C,74,7C "NEG"
_NEG:   XCHG    CH,A
        MOV     CL,010000b
        JMP     @OPER;ﬂﬂﬂﬂﬂ
_SNLH:  SHR     AL,1       ;42 46 4A 4E 52 56 5A ....
        JC      _IMOD
;‹‹‹‹‹‹‹;ADC,SBC HL,SS ;ED 42,4A,52,5A,62,6A,72,7A "ADC,SBB HL,SS"  SS=BC,DE,HL,SP
_ADSBC: ADD     DH,7
        MOV     CH,11h     ;11h=OPCODE ADC
        SHR     AL,1
        JC      @SBBB
        MOV     CX,1902h   ;19h=OPCODE SBB
@SBBB:  MOV     BYTE PTR DS:[OFFSET @SUMO],CH
        DW      0C000h ;ADD     AL,AL
        ADD     BX,AX
        CMP     AL,6
        MOV     AX,WORD PTR DS:[BX]
        JNZ     @SBAC
        MOV     AX,BP
@SBAC:  ror F,1                  ;paso el C del z80 al PC
@SUMO:  adc HL,ax
        lahf
        PUSHF
        and     ah,11111001b    ;Overflow  N a 0
        POPF
        jNo @cafi
        or      ah,00000100b    ;Overflow a 1
@cafi:  mov     F,ah
        OR F,CL
        RET
;‹‹‹‹‹‹‹;IM ?      ;OP ED 46,4E,56,5E,66,6E,76,7E "IM ?"
_IMOD:  ;AND AL,11b
        ;JPO @AH01
        ;JZ @AH01
        INC     AX
        AND     AL,11b
        JNZ     @AH01
        STC
@AH01:  RCR     IM,1
        ROL     IM,1
        RET
;        OR      IMA,DI
;@AH01:  RET
_SNH:   SHR     AL,1               ;41 43 45 47 49 4B 4D..
        JC      _SNHH   ;
_SNHL:  SHR     AL,1               ;41 45 49 4D 51 55 ..
        JC      _RETI
;‹‹‹‹‹‹‹;OUT (C),S   ;OP ED 41,49,51,59,61,69,79 "OUT (C),S" S=B,C,D,E,H,L,A   12
_OUTCS: ADD     DH,4
        ADD     BX,AX
        SHL     BL,5
        JZ      _OUT0
        SHR     BL,5
        XOR     BL,BH
        MOV     AL,BYTE PTR DS:[BX]
        DB      03Dh
_OUT0:  MOV     AL,0 ;DB      0D6h         ;ED 71
@POUTBC:MOV     AH,C
@POUT:  SHR     AH,1
        JC      @LARE   ;ENTRADA AH=DIREC PUERTO AL=BYTE
        MOV     POR,AL
        SHR     AL,1
        XOR     AL,POR
        SHR     AL,4 
        DB      0D6h
        or      al,0BFh
        MOV     BYTE PTR DS:[@issue+1],AL
@LARE:  RET
;‹‹‹‹‹‹‹;RETI, RETN   ;OP ED 45,4D,55,5D,65,6D,75,7D
_RETI:  ADD     DH,6
        OR      IM,10000000b
@RELT:  JMP     @SIRE
_SNHH:  SHR     AL,1           ;43 47 4B 4F 53 57 ..
        JC      _SNHHH
_SNHHL: SHR     AL,1           ;43 4B 53 5B ..
        JC      _LSSNN
;‹‹‹‹‹‹‹;LD (NN),SS   ;OP ED 43,53,63,73 "LD (NN),SS"  SS=BC,DE,HL,SP
_LNNSS: DW      0C000h ;ADD     AL,AL
        ADD     BX,AX           
        CMP     AL,6
        MOV     AX,WORD PTR DS:[BX]
        JNZ     @SBAD
        MOV     AX,BP
@SBAD:  JMP     @LDIM
;‹‹‹‹‹‹‹;LD SS,(NN)   ;OP ED 4B,5B,6B,7B "LD SS,(NN)"  SS=BC,DE,HL,SP
_LSSNN: DW      0C000h ;ADD     AL,AL
         and al,0FFh
        ADD     BX,AX
        CMP     AL,6
        JNZ     @LDIX
        DB      26h
        LODSW
        XCHG    BX,AX
        MOV     BP,WORD PTR ES:[BX]  ;OP ED 7B "LD SP,(NN)"
        RET
_SNHHH: CMP     AL,2     ;47 4F 57 5F 67 6F 77 7F
        JNC     _RRR1
;‹‹‹‹‹‹‹;LD I,A ;LD R,A  ;ED 47 4F > 8 9 > A B
_LDIAR: inc     dh
        XOR     AL,13h
        ADD     BX,AX
        MOV     AL,A
@DERE:  MOV     BYTE PTR DS:[BX],AL
        RET
_RRR1:  CMP     AL,4     ;57 5F 67 6F 77 7F
        JNC     _RRRR
;‹‹‹‹‹‹‹;LD A,I ;LD A,R
_LDAIR: INC     DH
        XOR     AL,11h
        ADD     BX,AX
        MOV     AL,BYTE PTR DS:[BX]
        MOV     A,AL
        MOV     AH,F
        AND     AX, 0000000111101000b
        OR      AH,AL
        MOV     AL,IM
        SHR     AL,5
        OR      AL,AH
        MOV     F,AL
        RET;ﬂﬂﬂﬂﬂ
_RRRR:  ADD     DH,10
        CMP     AL,5
        MOV     BX,HL
        MOV     CH,ES:[BX]
        MOV     AL,A
        MOV     AH,AL
        MOV     CL,4
        JNZ     _RRD
;‹‹‹‹‹‹‹;RLD ;ED 6F
_RLD:   SHL     CH,CL
        AND     AX,0F00FH
        OR      AL,CH
        XCHG    AL,BYTE PTR ES:[BX]
        SHR     AL,CL
@TOTE:  OR      AL,AH
        MOV     A,AL
        AND     AL,AL
        LAHF
        AND     AX,0100010010101000b
        SHR     F,1
        ADC     AL,AH
        MOV     F,AL
_2RET:  RET
;‹‹‹‹‹‹‹;RRD ;ED 67
_RRD:   JNC     _2RET
        SHR     CH,CL
        SHL     AL,CL
        OR      AL,CH
        XCHG    AL,BYTE PTR ES:[BX]
        AND     AX,0F00Fh
        JMP     @TOTE;ﬂﬂﬂﬂﬂ
_N:     SHL     AL,1        ;80-FF
        JC      _2RET
        SUB     AL,80h      ;80-BF
        SHL     AL,1
        JC      _2RET
        ADD     DH,8
        SHR     AL,4        ;A0-BF > 00-1F
        JC      _NH
_NL:    SHR     AL,1        ;A0 A2 A4 A6 A8 ..
        JC      _NLH
        SHR     AL,1        ;A0 A4 A8 AC B0 B4..
        JC      _2RET
;‹‹‹‹‹‹‹;LD??   ;OP A0 A8 B0 B8 "LDI,LDD,LDIR,LDDR" BX=0,1,2,3
_LDILD: SHR     AL,1
        MOV     BX,HL
        MOV     BL,BYTE PTR ES:[BX]
        PUSHF
        PUSH    DI
        MOV     DI,DE
        XCHG    AX,BX
        CALL    @ESDB
        POP     DI
        POPF
        JC      @OIOD  ;FLAG ARRASTRADO 9 LINEAS ARRIBA
        INC     DE
        INC     HL
        JMP     SHORT @OOOI
@OIOD:  DEC     DE
        DEC     HL
@OOOI:  AND     F,11000001b  ;TODOS MENOS SZC A LA MIERDA
        ADD     AL,A
        AND     AL,101b
        SHL     AL,3
        DEC     BC
        JZ      @ORFA
        OR      AL,00000100b
        SHR     BL,1
        JNC     @ORFA
@CORE:  ADD     DH,5
        SUB     SI,2
@ORFA:  OR      F,AL
_3RET:  RET;ﬂﬂﬂﬂﬂ
_NLH:   SHR     AL,1        ;A2 A6 AA AE B2 B6
        JC      _3RET
;‹‹‹‹‹‹‹;IN??   ;OP A2 AA B2 BA "INI,IND,INIR,INDR"
_INIR:  PUSH    AX
        CALL    @PINBC
        MOV     BX,HL
        MOV     BYTE PTR ES:[BX],AL
@LMQI:  XCHG    AX,BX
        POP     AX
        SHR     AL,1
        JC      @CIAD
        INC     HL
        JMP     @MIER
@CIAD:  DEC     HL
@MIER:  DEC     B
        LAHF
        AND     AH,11000000b
        MOV     F,AH
        MOV     AH,BL
        STC
        ADC     BL,C
        JNO     @RACH
        OR      F,00010001b
@RACH:  SHR     AH,7
        ADD     AH,AH
        OR      F,AH
        TEST    F,01000000b
        JNZ     @RTIT
        SHR     AL,1
        JC      @CORE
@RTIT:  RET;ﬂﬂﬂﬂﬂ
_NH:    SHR     AL,1   ; A1 A3 A5 A7 A9 AB ..
        JNC     _NHL
_NHH:   SHR     AL,1   ; A3 A7 AB AF B3 ..
        JC      @RTIT
;‹‹‹‹‹‹‹;OUT??  ;OP A3 AB B3 BB "OUTI,OUTD,OTIR,OTDR"
_OUTIR: PUSH    AX
        MOV     BX,HL
        MOV     AL,BYTE PTR ES:[BX]
        CALL    @POUTBC
        JMP     @LMQI;ﬂﬂﬂﬂﬂ
_NHL:   SHR     AL,1
        JC      @RTIT
;‹‹‹‹‹‹‹;CP??  ;OP A1 A9 B1 B9 "CPI,CPD,CPIR,CPDR"
_CPIR:  SHR     AL,1
        XCHG    AX,CX
        MOV     DI,HL
        JC      @CIOD
        INC     WORD PTR DS:[BX+4];HL
        JMP     @MDDM
@CIOD:  DEC     WORD PTR DS:[BX+4];HL
@MDDM:  MOV     AL,[BX-2]
        SUB     AL,ES:[DI]
        LAHF                     ; X VELOCIDAD CON CALL OPER TB VALE
        SUB     AL,BYTE PTR DS:[BX+5];H
        AND     AX,1101000000000101b
        SHL     AL,3
        OR      AL,10b
        OR      AL,AH
        AND     F,BH
        DEC     WORD PTR DS:[BX];BC
        JZ      @CPIR
        OR      AL,100b ; PV LO PONGO A 1
        JCXZ    @CPIR
        TEST    AL,01000000b  ;MIRO SI FLAG Z=1 SALGO
        JZ      @CORE
@CPIR:  OR      F,AL
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;DD FD PREFIX
_DDFD:  SUB     DH,6
        SHL     AL,1        ;DD FD PREFIJOS
        ADD     AL,10h
        MOV     PRB,AL
        JMP     @ABAPRE;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;PUSH SS  ;C5,D5,E5,F5 > 00 01 02 03  BC,DE,HL,AF
_PUSH:  INC     DH
        CMP     AL,2
        JC      @NANH
        MOV     BL,PRB
        JZ      _PUSHDA
        MOV     AH,A    ;PUSH AF
        MOV     AL,F
        JMP     _PUSHDX
@NANH:  DW      0C000h ;ADD     AL,AL
        ADD     BX,AX
_PUSHDA:MOV     AX,[BX]
_PUSHDX:DEC     BP
        DEC     BP
@ESBP:  CMP     BP,04000h
        JC      @SA04
        MOV     WORD PTR ES:[BP],AX
@SA04:  RET
@NNHLL: SHR     AL,1     ;C1,C9,D1,D9,E1,E9,F1,F9
        JC      @NNHLLH ; ;C1,D1,E1,F1 > 00 40 80 C0
;‹‹‹‹‹‹‹;POP XX  ;C1 D1 E1 F1
_POPXX: MOV     CX,WORD PTR ES:[BP]
        INC     BP
        INC     BP
        CMP     AL,2
        JC      @NAN2
        MOV     BL,PRB
        JZ      _POPDA
        MOV     A,CH  ;POP AF
        MOV     F,CL
        RET
@NAN2:  SHL     AL,1
@POPDE: ADD     BX,AX
_POPDA: MOV     WORD PTR DS:[BX],CX
        RET;ﬂﬂﬂﬂﬂ
@NNHLLH:SHR     AL,1               ;C9,D9,E9,F9 > 00 40 80 C0
        JC      @NNHLLHH
        JZ      _RET
;‹‹‹‹‹‹‹;JP (HL)  ;OP E9
_JPHL:  SUB     DH,6
        MOV     BL,PRB
        MOV     SI,WORD PTR DS:[BX]
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;RET c/Nc  ;OPS C0,C8,D0,D8,E0,E8,F0,F8 *
_RETNC: SUB     DH,5
        MOV     BX,OFFSET FLCMP
        SHR     AL,1
        XLAT      
        JNC     @SISI
        TEST    F,AL
        JZ      @NORE
        JNZ     @SIRE
@SISI:  TEST    F,AL
        JNZ     @NORE
@SIRE:  ADD     DH,6
;‹‹‹‹‹‹‹;RET  ;OP C9 *
_RET:   MOV     SI,WORD PTR ES:[BP] 
        INC     BP
        INC     BP
@NORE:  RET;ﬂﬂﬂﬂﬂ
@NNHLLHH:JNZ _LSPHL   ;D9,F9 > 00 80
;‹‹‹‹‹‹‹;EXX  ;OP D9 *"EXX" BC DE HL
_EXX:   SUB     DH,6
        MOV     CL,3
@LOO3:  MOV     AX,WORD PTR DS:[BX]
        XOR     BL,8
        XCHG    AX,WORD PTR DS:[BX]
        XOR     BL,8
        MOV     WORD PTR DS:[BX],AX
        ADD     BL,2
        LOOP    @LOO3
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;LD SP,HL    ;OP F9 *
_LSPHL: SUB     DH,4
        MOV     BL,PRB
        MOV     BP,[BX]
        RET;ﬂﬂﬂﬂﬂ
@NNHH:  SHR AL,1         ;C3,C7,CB,CF,D....,E....,F.......
        JNC @NNHHL
;‹‹‹‹‹‹‹;RST XX  ;OP C7,CF,D7,DF,E7,EF,F7,FF *"RST" XX= 00 08 10 18 ...
_RST:   INC     DH
        SHL     AL,3
        DEC     BP
        DEC     BP
        XCHG    SI,AX
        JMP     @ESBP;ﬂﬂﬂﬂﬂ
@NNHHL: SHR     AL,1         ;C3,CB,D3,DB,E3,EB,F3,FB @NNNNSS
        JNC     @NNHHLL  ;
@NNHHLH:SHR     AL,1         ;CB,DB,EB,FB  00 40 80 C0
        JC      @NNHHLHH  ;
        JNZ     _EXDHL   ;   ;CB,EB
;‹‹‹‹‹‹‹;CB PREFIX
_PRCB:  ADD     DH,4
        MOV     BL,PRB       ;OP CB PREFIJO CB
        MOV     DI,WORD PTR DS:[BX]  ;ch=0;MODO DE ENTRADA NORMAL (SOLO 1 OPERACION)
        CMP     BL,06h
        JZ      @OPOC
        ADD     DH,8
        MOV     CH,1  ;MODO DE ENTRADA CON PREFIJO (2 OPERACIONES)
        DB      026h
        LODSB
        CBW
        ADD     DI,AX ;;;;;;;;;;;;,ARREGLAR TODO ESTO
        JMP     @NICR
@OPOC:  MOV     AL,RD
        ROL     AL,1
        ADD     AL,2
        ROR     AL,1
        MOV     RD,AL
@NICR:  DB      026h                   ;CH=0 HL CH=1 IX CH=2 IY
        LODSB
        MOV     BH,AL    ;ETO E MUY COMPLICAO
        MOV     AH,1
        ADD     AL,2     
        AND     AL,111b  ;HL A B C D E H L
        JNZ     @DES0
        ADD     DH,7
        MOV     CH,1     ;SIMULAMOS QUE ES UN PREFIJO
@DES0:  XOR     AL,1     ;A HL C B E D L H
        XCHG    BX,AX
        SHR     AX,6    ;AH 0-3 OPCODE ; AL 0-8 MODO
        SHR     AL,5
        OR      AH,AH
        JNZ     @ROTE
        PUSH    BX               ;ROTACIONES  00-3F
        MOV     BX,OFFSET ROTEMO
        CMP     AL,6   ;SLL RARO UNDOCUMENTADO
        JNZ     @UNOR
        MOV     F,1
@UNOR:  XLAT      ;AL OPCODE INSTR ROTAR
        POP     BX
        OR      CH,CH   ;COMPROBAR SI HAY PREFIJO
        JNZ     @IXIY
        MOV     BYTE PTR DS:[@RTAD+1],AL
        SHR     F,1
@RTAD:  RCL     BYTE PTR DS:[BX],1
        MOV     AL,BYTE PTR DS:[BX]
@TSIG:  LAHF
        AND     AX,0000000110101000b
        OR      AL,AH
        MOV     F,AL
        MOV     AL,BYTE PTR DS:[BX]
        AND     AL,AL
        LAHF
        AND     AH,01000100b
        OR      F,AH
        RET
@IXIY:  SUB AL,2
        MOV BYTE PTR DS:[@RTXY+2],AL
        SHR F,1
@RTXY:  RCL BYTE PTR ES:[DI],1
        MOV AL,BYTE PTR ES:[DI]
        MOV BYTE PTR DS:[BX],AL
        JMP @TSIG
@ROTE:  MOV CL,1
        XCHG CX,AX
        SHL AL,CL
        DEC CH           ;COMPARACIONES DE BITS 40-7F
        JNZ @BITC
        sub dh,3
        OR AH,AH
        JZ @IXY1+1  ;SI NORMAL COJO DE DS:BX
        MOV BX,DI    ;SI PREFIJO COJO DE ES:DI
@IXY1:  TEST AL,BYTE PTR ES:[BX];;;NUEVO
        jnz      @@bitun
        and     F,11111101b ;N a 0
        or      F,01010000b ;H Z a 1
        jmp @@FinOp
@@bitun:and     F,10111101b ;N Z a 0
        or      F,00010000b ;H a 1
@@FinOp:ret
@BITC:  DEC     CH       ;PONER 0 O 1?
        JNZ     @REST
        NOT     AL
        DEC     AH  ;PREFIJOS?
        JNZ     @IXY2
        AND     BYTE PTR ES:[DI],AL
@IXY2:  AND     BYTE PTR DS:[BX],AL
        RET
@REST:  DEC     AH      ;PUESTA A 1 DE BIT C0-FF
        JNZ     @IXY3
        OR      BYTE PTR ES:[DI],AL    ;;BBBBB
@IXY3:  OR      BYTE PTR DS:[BX],AL
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;EX DE,HL  ;OP EB *
_EXDHL: SUB     DH,6
        MOV     BL,PRB
        MOV     AX,DE
        XCHG    AX,WORD PTR DS:[BX]
        MOV     DE,AX
        RET;ﬂﬂﬂﬂﬂ
@NNHHLHH:JZ _INAN    ;DB,FB
;‹‹‹‹‹‹‹;EI   ;OP FB
_EI:    SUB     DH,6
        OR      IM,10000000b
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;IN A,(N)  ;OP DB
_INAN:  INC     DH
        MOV     AH,A
        DB      026h
        LODSB
        CALL    @PIN
        MOV     A,AL
        RET;ﬂﬂﬂﬂﬂ
@NNHHLL:SHR     AL,1      ;C3,D3,E3,F3
        JC      @NNHHLLH
@NNHHLLL:JZ     _JUNP        ;C3,E3
;‹‹‹‹‹‹‹;EX (SP),HL  ;OP E3 *
_EXPHL: ADD     DH,9
        MOV     BL,PRB
        MOV     AX,WORD PTR ES:[BP]
        XCHG    AX,WORD PTR DS:[BX]
        JMP     @ESBP;ﬂﬂﬂﬂﬂ
@NNHHLLH:JNZ    _DI  ;D3,F3
;‹‹‹‹‹‹‹;OUT (N),A  ;OP D3 *
_OUTNA: INC     DH
        DB      26h
        LODSB
        MOV     AH,AL
        MOV     AL,A
        JMP     @POUT;ﬂﬂﬂﬂﬂ
FLCMP   DB 40h,1,4;,80h OJO CON ESTE TRUCO;;;;;;NO QUITAR DE 
;‹‹‹‹‹‹‹;DI   ;OP F3 *
_DI:    SUB     DH,6
        AND     IM,01111111b
        RET;ﬂﬂﬂﬂﬂ
@NNL:   SHR     AL,1        ;C0-FF pares C0 C2 C4 C6 C8 CA ...
        JC      @NNLH
@NNLL:  SHR     AL,1        ;C0 C4 C8 CC D0 D4 D8 *
        JNC     _RETNC
;‹‹‹‹‹‹‹;CALL Nc NN  ;OPS C4,CC,D4,DC,E4,EC,F4,FC ;
_CALLC: MOV     BX,OFFSET FLCMP
        SHR     AL,1  
        XLAT
        JNC     @ZZSI
        TEST    F,AL
        JZ      @NOXX
        JNZ     @SIZZ
@ZZSI:  TEST    F,AL
        JNZ     @NOXX
@SIZZ:  ADD     DH,7
;‹‹‹‹‹‹‹;CALL NN  ;OP CD
_CALNN: ADD     DH,7
        DB      26h
        LODSW
        cmp     AX,05E7h
        jz      @kkoe
        DEC     BP
        DEC     BP
        XCHG    SI,AX
        JMP     @ESBP;ﬂﬂﬂﬂﬂ
@kkoe:  OR      AL,0ACh   ;96;xchg si,ax 80h
        CALL    @READ                   ;posiciono el buffer
        push    DX                      ;guardo flags
        mov     bx,HFILE                ;cargo handle de archivo
        push    DE                      ;DE=numero de bytes a leer
        mov     dx,IX                   ;IX=posicion memoria a escribir
        push    es
        pop     ds                      ;apunto a mapa Z80
        mov     cx,1                    ;cx=1 leo primero un byte
        mov     ah,3Fh
        int     21h                     ;leo 1 byte
        pop     cx                      ;ahora cx es realmente los bytes a leer
        mov     ah,3Fh                  ;repito lectura
        int     21h                     ;esta vez de cx=DE bytes
        cwd                             ;leo en zona segura dx=0 int 20, ya que ax<32768
        push    cs
        pop     ds                      ;restauro ds
        add     IX,cx                   ;actualizo IX con bytes le°dos
        mov     cx,1                    ;leo paridad
        mov     ah,3Fh                  ;en teor°a debo dejar DE=0 H=0 L=paridad
        int     21h                     ;en practica solo dejo HL=paridad
        and     HL,dx                   ;reseteo HL pongo carry a 0 y sign a 0
        mov     SI,5DFh                 ;continuo en rutina cargadora cinta
        pop     DX                      ;recupero flag
        CALL    @READ                   ;incremento numero de bloque
        JMP     @GRABA                  ;hago un snapshot despues de la carga
@NNLH:  SHR     AL,1        ;C2 C6 CA CD D2 D6 DA ..
        JC      _WOPER
;‹‹‹‹‹‹‹;JP Nc   ;OPS C2,CA,D2,DA,E2,EA,F2,FA  ;
_JPCNC: MOV     BX,OFFSET FLCMP
        SHR     AL,1
        XLAT
        JNC     @XXSI
        TEST    F,AL
        JZ      @NOXX
        JNZ     _JUNP
@XXSI:  TEST    F,AL
        JNZ     @NOXX
_JUNP:  MOV     SI,WORD PTR ES:[SI] ;OP C3 "JP NN"  ;4 =1
        RET
@NOXX:  CMPSW
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;ADD SUB ADC SBB AND OR XOR CP A,N ;OPS C6,CE,D6,DE,E6,EE,F6,FE *;12 =3
_WOPER: SUB     DH,3
        DEC     SI
        DB      26h
        LODSW
        XCHG    CX,AX
        JMP     @OPER;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;"ADD,ADC,SUB,SBC,AND,XOR,OR,CP" ;OP 80-BF
_CALC:  SHR     AL,2
        MOV     CL,AL
        ADD     AX,BX ;OP 80-BF "ADD,ADC,SUB,SBC,AND,XOR,OR,CP" ;62 =16
        AND     AL,111b
        PUSHF
        XOR     AL,AH  ;1
        CMP     AL,6
        JC      @MAL2
        SUB     AL,6
        ADD     AL,PRB
@MAL2:  POPF
        XCHG    BX,AX
        JNZ     @NNE7
        ADD     DH,3
        CALL    @SAIXD
        DB      26h
@NNE7:  MOV     CH,BYTE PTR DS:[BX]
@OPER:  SHR     CL,3 ;AL VIENE SUMADO A 32
        AND     CL,111b ;SI VIENE DE WOPER
        MOV     AL,CL
        MOV     BX,OFFSET OPCOS;CH=NUMERO A SUMAR.  CL=OPERACION
        XLAT
        MOV     BYTE PTR DS:[@ASAS],AL
        MOV     BX,0000101000000001b  ;CARRY ANTERIOR
        SHL     BL,CL
        TEST    BH,BL
        JZ      @NFLA
        MOV     AL,F
        SHR     AL,1
@NFLA:  MOV     AL,A
@ASAS:  DW      0E800h ; OPER AL,CH   ;;;;;ARREGLAR COMPRI
        MOV     A,AL
@FLAG:  PUSHF         ;FLAGS Z A O C= Z H PV C ;CL OPERACION ;AL RESULTADO ;SALIDA FLAGS CAMBIADOS 
        POP BX        ;BL FLAGS PC                       ;55 =14
        OR      BH,BL
        AND     BH,00001100b ;BIT 3 OVERFLOW BIT 2 PARITY
        XCHG    AL,BH
        AND     BX,0010100011010001b  ;FLAG 5 3 YA PUESTOS LOS DEMAS A 0
        OR      BL,BH          ;PONGO FLAGS FILTRADOS
        INC     CX
        AND     CL,111b
        CMP     CL,5
        JNC     @LOGI
        SHR     AL,1          ;OPERACION ARITMETICA PASO OVERFLOW A PV
        JMP     @MDDC
@LOGI:  AND     BL,11101111b  ;PONGO A 0 EL BIT H SI SE TRATA DE OPER LOGICA
@MDDC:  AND     AL,00000100b  ;FILTRO PV
        OR      BL,AL          ;METO EL FLAG PV
        MOV     AL,1  ;PONGO BIT 0 DE AL A 1
        SHL     AL,CL
        TEST    AL,00011001b  ;XOR,OR,AND,SBB,SUB,ADC,ADD,CP
        JZ      @NFNN
        OR      BL,10b         ;METO FLAG N
@NFNN:  AND     AL,00100000b  ;XOR,OR,AND,SBB,SUB,ADC,ADD,CP
        SHR     AL,1
        OR      AL,BL          ;BIT H PUESTO SI LA OPERACION ES AND
@NFHH:  MOV     F,AL           ;LO PONGO EN FLAGS
        RET;ﬂﬂﬂﬂﬂ
@S:     SHL     AL,1
        JC      _LDR_R
@SS:    SHR     AL,3   ;00 01 02 03 04
        JC      @SSH
@SSL:   SHR     AL,1   ;00 02 04 06 08
        JC      @SSLH
@SSLL:  SHR     AL,1   ;00 04 08 0C 10
        JC      _INCRU
@SSLLL: SHR     AL,1   ;00 08 10 18 20 28 30 38
        JC      @SSLLLH
@SSLLLL:SHR     AL,1   ;00 10 20 30
        JC      @SSLLLLH
@SSLLLLL:JZ     _NOP
;‹‹‹‹‹‹‹;JR NZ,dis ;OP 20
_JNZ:   ADD     DH,3
        TEST    F,01000000b
@AJMP:  JZ      _JUMP
@INRE:  INC     SI
_NOP:   RET;ﬂﬂﬂﬂﬂ
@SSLLLLH:JZ _DJNZ
;‹‹‹‹‹‹‹;JR NC,dis ;OP 30
_JNC:   ADC     DH,BL
        TEST    F,00000001b
        JMP     @AJMP;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;DJNZ (LOOP)  ;OP 10
_DJNZ:  ADD     DH,4
        DEC     B
        JZ      @INRE
;‹‹‹‹‹‹‹;JP dis (JMP) ;OP 18 "JMP"
_JUMP:  ADD     DH,5
        DB      26h
        LODSB
        CBW
        ADD     SI,AX
        RET;ﬂﬂﬂﬂﬂ
@SSLLLH:ADC     DH,BL
        SHR     AL,1          ;08 18 28 38
        JC      @SSLLLHH
@SSLLLHL:JZ     _EXAF ;08 28
;‹‹‹‹‹‹‹;JM NC (JS)  ;OP 28
_JZ:    TEST    F,01000000b
@BJMP:  JNZ     _JUMP
        JZ      @INRE;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;EX AF,AF'  ;OP 08 "EX AF,AF'"
_EXAF:  SUB     DH,3
        MOV     AH,A
        MOV     AL,F
        XCHG    AX,[DI+8]
        MOV     A,AH
        MOV     F,AL
        RET;ﬂﬂﬂﬂﬂ
@SSLLLHH:JZ     _JUMP;18 38
;‹‹‹‹‹‹‹;JP NC (JC/JNC) ;OP 38
_JC:    TEST    F,00000001b
        JMP     @BJMP
;‹‹‹‹‹‹‹;INC/DEC B,C,D,E,A,(HL) ;04,0C,14,1C,24,2C,34,3C
_DECRU: MOV     CL,BL
_INCRU: AND     F,BH
        OR      F,CL
        SHL     CL,CL
        OR      CL,111b
        MOV     BYTE PTR DS:[@INHL+1],CL
        ADD     BX,AX
        AND     BL,111b
        JNZ     @HLSF
        ADD     DH,7      ;34 35
        CALL    @SAIXD
        PUSH    ES
        POP     DS
        JMP     @INHL
@HLSF:  XOR     BL,BH
        CMP     BL,6
        JC      @INHL
        INC     DH
        SUB     BL,6
        ADD     BL,PRB
@INHL:  INC     BYTE PTR DS:[BX]
        MOV     BL,BYTE PTR DS:[BX]
        PUSH    CS
        POP     DS
        LAHF
        JNO     @OSNV
        OR      F,100b
@OSNV:  AND     AH,11010000b
        OR      F,AH
        AND     BL,00101000b
        OR      F,BL
        RET;ﬂﬂﬂﬂﬂ
@SSLH:  SHR     AL,1                ;02 06 0A 0E 12
        JNC     @SSLHL
;‹‹‹‹‹‹‹;LD X,N  ;X=B,C,D,E,H,L,X,A ;OP 06,0E,16,1E,26,2E,XX,3E
_LDXN:  ADC     DH,BL
        ADD     AX,BX
        AND     AL,111b
        JZ      _LDHLN
        XOR     AL,AH
        CMP     AL,6
        JC      @MALO
        SUB     DH,BL
        SUB     AL,6
        ADD     AL,PRB
@MALO:  XCHG    BX,AX
        DB      26h
        LODSB
        MOV     BYTE PTR DS:[BX],AL
        RET;ﬂﬂﬂﬂﬂ
@SSLHL: SHR     AL,1                ;02 0A 12 1A
        JC      @SSLHLH
@SSLHLL:CMP     AL,2       ;02 12 22 32
        JNC     @2232
;‹‹‹‹‹‹‹;LD (BC/DE),A   ;OPS 02,12
_LDXXA: ADC     DH,BL
        DW      0C000h ;ADD     AL,AL
        ADD     BX,AX
        MOV     AL,A
        MOV     DI,WORD PTR DS:[BX]
        JMP     @TESD;ﬂﬂﬂﬂﬂ
@2232:  JNZ     _LDNNA
;‹‹‹‹‹‹‹;LD (NN),HL   ;OP 22
_LNNHL: MOV     BL,PRB
        MOV     AX,[BX]
@LDIM:  ADD     DH,12
        XCHG    DI,AX
        DB      26h
        LODSW
        CMP     AH,40h
        XCHG    DI,AX
        JC      @NST0
        STOSW
@NST0:  RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;LD (NN),A  ;OP 32
_LDNNA: ADD     DH,9
        DB      026h
        LODSW
        MOV     DI,[DI]
        XCHG    AX,DI
@TESD:  JMP     @SDBE
@SSLHLH:CMP     AL,2                       ;0A 1A 2A 3A
        JNC     @2A3A
;‹‹‹‹‹‹‹;LD A,(BC/DE)  ;OPS 0A,1A
_LDAXX: ADC     DH,BL
        DW      0C000h ;ADD     AL,AL
        ADD     BX,AX
        MOV     BX,WORD PTR DS:[BX]
        MOV     AL,BYTE PTR ES:[BX]
        MOV     A,AL
        RET;ﬂﬂﬂﬂﬂ
@2A3A:  JNZ     _LDANN
;‹‹‹‹‹‹‹;LD HL,(NN) ;OP 2A
_LHLNN: MOV     BL,PRB
@LDIX:  ADD     DH,12
        DB      26h
        LODSW
        XCHG    DI,AX
        MOV     AX,WORD PTR ES:[DI]
        MOV     WORD PTR DS:[BX],AX
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;LD A,(NN)  ;OP 3A
_LDANN: ADD     DH,9
        DB      26h
        LODSW
        XCHG    AX,BX
        MOV     AL,ES:[BX]
        MOV     A,AL
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;LD (HL),N  ;OP 36
_LDHLN: ADD     DH,3
        CALL    @SAIXD ;;;;me falta un puto ciclo
        MOV     DI,BX
        DB      26h
        LODSB
@SDBE:  JMP     @ESDB;ﬂﬂﬂﬂﬂ
@SSH:   SHR     AL,1         ;01 03 05 07 ...
        JC      @SSHH
@SSHL:  SHR     AL,1         ;01 05 09 0D 11 ...
        JC      _DECRU
@SSHLL: SHR     AL,1         ;01 09 11 19...
        JC      _AHLSS
;‹‹‹‹‹‹‹;LD XX,NN ;XX=BC,DE,HL,SP  ;01 11 21 31
_LRRNN: ADD     DH,6
        CMP     AL,2
        JNZ     _CNTI
        MOV     BL,PRB
        JZ      @D222
_CNTI:  JC      _NLDS
_LDSPN: DB      26h  ; OP 31 "LD SP,NN"
        LODSW
        XCHG    BP,AX
        RET
_NLDS:  DW      0C000h ;ADD     AL,AL    ;OPS 01,11,21 "LD RR,NN"  ;19        +1
        ADD     BX,AX
@D222:  DB      26h
        LODSW
        MOV     WORD PTR DS:[BX],AX
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;ADD RR,NN  ;OPS 09,19,29,39
_AHLSS: ADD     DH,7
        CMP     AL,2
        JC      _ADHL
        JNZ     _AHLSP
        MOV     BL,PRB
        JMP     @D244;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;ADD HL,BC/DE  ;09 19
_ADHL:  DW      0C000h ;ADD     AL,AL
        ADD     BX,AX
@D244:  MOV     AX,WORD PTR DS:[BX]
        DB      3Dh
_AHLSP: MOV     AX,BP  ;39
@SUMA:  MOV     BL,PRB
        AND     F,11000100b   ; N a cero por ahora
        ADD     WORD PTR DS:[BX],AX
        LAHF
        MOV     AL,BYTE PTR DS:[BX+1]
        AND     AX,0000000100101000b
        OR      AL,AH
        OR      F,AL
@DD16:  RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;DEC B,C,D,E,A,(HL) ;05 0D 15 1D 25 2D 35 3D;;;;;;;;CONJUNTAR CON EL INCREMENTO
@SSHH:  SHR     AL,1                   ;03 07 0B 0F 13 ...
        JC      @SSHHH
@SSHHL: ADD     DH,BL
        CMP     AL,6                   ;03 0B 13 1B 23 2B 33 3B
        JNC     _SPLH
;‹‹‹‹‹‹‹;INC/DEC BC/DE/HL  ;OPS 03,0B,13,1B,23 2B
        SHR     AL,1
        RCL     CL,4
        OR      CL,7
        MOV     BYTE PTR DS:[@HL01+1],CL
_INCXX: DW      0C000h ;ADD     AL,AL
        ADD     AX,BX
        CMP     AL,6
        MOV     BL,PRB
        JZ      @HL01
        XCHG    BX,AX
@HL01:  INC     WORD PTR DS:[BX]
        RET;ﬂﬂﬂﬂﬂ
_SPLH:  JNZ     _DECSP
;‹‹‹‹‹‹‹;INC SP   ;OP 33
_INCSP: INC     BP
        INC     BP
;‹‹‹‹‹‹‹;DEC SP   ;OP 3B
_DECSP: DEC     BP
        RET;ﬂﬂﬂﬂﬂ
@SSHHH: CMP     AL,4          ;07,0F,17,1F,27,2F,37,3F,47,4F
        JNC     @SHHHL
;‹‹‹‹‹‹‹;RLCA RRCA RLA RRA  ;OP 07,0F,17,1F
_RLCA:  SHL     AL,3
        OR      AL,5
        MOV     BYTE PTR DS:[OFFSET @MAG2+1],AL
        AND     F,11000101b
        SHR     F,1
@MAG2:  ROL     A,1
        RCL     F,1
        MOV     AL,A
        AND     AL,00101000b
        OR      F,AL
        RET;ﬂﬂﬂﬂﬂ
@SHHHL: SUB     AL,5      ;27 2F 37 3F 
        JNC     @NO27
;‹‹‹‹‹‹‹;DAA   ;OP 27
_DAA:   MOV     AL,A
        MOV     AH,F
        TEST    AH,2
        JNZ     DAAS
        SAHF
        DAA
        LAHF
        MOV     A,AL
        MOV     F,AH
        RET
DAAS:   SAHF
        DAS
        LAHF
        MOV     A,AL
        MOV     F,AH
        RET;ﬂﬂﬂﬂﬂ
@NO27:  JNZ _SCF
;‹‹‹‹‹‹‹;CPL  ;OP 2F
_CPL:   NOT     A
        MOV     AL,A
        AND     AL,00101000b
        OR      AL,00010010b
        AND     F,11000101b
        OR      F,AL
        RET;ﬂﬂﬂﬂﬂ
;‹‹‹‹‹‹‹;SCF/CCF  ;OP 37 3F   ;1 2
_SCF:   AND     F,11000101b     ;H N a 0
        MOV     CL,A
        AND     CL,00101000b
        DEC     AX
        JNZ     CCF
SCF:    OR      F,BH
        OR      F,CL
        RET
CCF:    TEST    F,BH
        JZ      SCF
        MOV     BH,00010000b     ;H a 1
        DEC     DX       ;;CHAPUZA   ;C a 0
        JMP     SCF
;‹‹‹‹‹‹‹;LD R,R   ;OP 40-7F
_LDR_R: MOV     CL,6
        SHR     AL,2
        PUSH    AX
        ADD     AX,BX
        MOV     BL,PRB
        AND     AL,111b
        JZ      @ATAJ
        XOR     AL,AH    
        CMP     BL,CL    ;A (HL) B C D E H L
        JZ      @OTCO
        CMP     AL,CL
        JC      @OTCO
        SUB     DH,2
        SUB     AL,CL    ; H L > 6 7
        ADD     AL,BL    ;
@OTCO:  XCHG    AX,BX
        JMP     @EHDD
@ATAJ:  ADD     DH,3
        MOV     CL,8
        CALL    @SAIXD     ;46 4E 56 5E 66 6E
@AEHH:  DB      26h
@EHDD:  MOV     CH,[BX]
        POP     AX
        SHR     AL,3    ;EN BX CONSERVO FUENTE DATO
        ADD     AL,2
        AND     AL,111b
        JZ      @HHHH      ;DESTINO (HL) O (IX+D)
        XOR     AL,1
        CMP     PRB,CL
        JZ      @OTC2
        CMP     AL,CL
        JC      @OTC2
        SUB     AL,CL
        ADD     AL,PRB
@OTC2:  ADD     DI,AX
        MOV     BYTE PTR DS:[DI],CH
        RET
@HHHH:  ADD     DH,3
        CMP     CL,8
        JZ      _HALT  ;DESTINO=(HL),ORIGEN=(HL)
        MOV     AL,CH
        CMP     BL,8  ;DESTINO=(IX+D),ORIGEN =IXh/IXl
        DB      68h
        DW      OFFSET @DEPU
        JC      @SAIXD
        DB      0D6h
        AND     BL,BH
        ADD     BL,CL
        XLAT
@SAIXD: MOV     BL,PRB
        CMP     BL,6
        MOV     BX,WORD PTR DS:[BX]
        JZ      @INPX
        ADD     DH,8
        PUSH    AX
        DB      26h
        LODSB
        CBW
        ADD     BX,AX
        POP     AX
@INPX:  RET
@DEPU:  MOV     DI,BX
@ESDB:  CMP     DI,4000h  ;LO PUEDO QUITAR LUEGO
        JC      @NST1
        STOSB
@NST1:  RET;ﬂﬂﬂﬂﬂ
_HALT:  SUB     DH,6
        DEC     SI              ;OP 76 HALT      ;4 =1
        RET;ﬂﬂﬂﬂﬂ

NewInt9:PUSH    AX              ;guardo ax y cx
        PUSH    CX
        IN      AL,60h          ;leo tecla
        MOV     AH,1
        CMP     AL,0E0h         ;miro si es extendida
        JNZ     @NEXT
        MOV     EXTEN,AH        ;pongo a 1 el bit extendida
        JMP     @FINS           ;acabo
@NEXT:  CMP     EXTEN,AH        ;miro si antes he recibido caracter extend
        CBW
        JNZ     @AEXT
        CMP     AL,02Ah         ;si lo he recibido comparo con tecla ??
        JZ      @FINS           ;acabo
@AEXT:  MOV     EXTEN,AH        ;reseteo exten
        MOV     CX,010Ah        ;BANCO 8
        SHL     AX,1            ;pongo codigo make en ah
        SHR     AL,1
        SUB     AL,1            ;0-2
        JZ      @DPAF           ;escape?
        SUB     AL,58-1
        CMP     AL,5
        JC      @DPAF
        DEC     CX
        SUB     AL,63-58
        CMP     AL,5
        JC      @DPAF
        DEC     CX
        SUB     AL,1Ch-63
        CMP     AL,1
        JZ      @DPAF
        SUB     AL,2Fh-1Bh ;2B-30
        CMP     AL,3       ;30-32
        JC      @DPNE
        SUB     AL,9
        JZ      @DPAF      ;39
        DEC     CX
        SUB     AL,1Ch-39h ;1C
        JZ      @DPAF
        SUB     AL,7       ;23
        CMP     AL,4       ;23-26
        JC      @DPNE
        DEC     CX
        SUB     AL,15h-23h ;15
        CMP     AL,5       ;15-19
        JC      @DPNE
        DEC     CX
        SUB     AL,7-15h   ;7
        CMP     AL,5       ;7-B
        JNC     @SIPO
@DPNE:  NOT     AL
        ADD     AL,5
@DPAF:  XCHG    AX,CX
        ROL     AH,CL
        PUSH    BX
        MOV     BX,OFFSET TECLADO-1
        ADD     BL,AL
        MOV     AL,BYTE PTR CS:[BX]
        SHR     CH,1
        JC      @MAKE
        NOT     AH
        AND     AL,AH
        DB      3Dh
@MAKE:  OR      AL,AH
        MOV     BYTE PTR CS:[BX],AL
        POP     BX
@FINS:  MOV     AL,20h
        OUT     20h,AL
        POP     CX
        POP     AX
        IRET
@SIPO:  DEC     CX
        SUB     AL,2-7     ;2
        CMP     AL,5       ;2-6
        JC      @DPAF
        DEC     CX
        SUB     AL,10h-2   ;10
        CMP     AL,5       ;10-14
        JC      @DPAF
        DEC     CX
        SUB     AL,1Eh-10h ;1E
        CMP     AL,5       ;1E-23
        JC      @DPAF
        DEC     CX
        SUB     AL,2Ah-1Eh ;2A
        JZ      @DPAF
        DEC     AX
        CMP     AL,5       ;2B-2F
        JC      @DPAF
        DEC     CX
        SUB     AL,0Eh-2Bh
        JNZ     @NZNZ
@BACK:  SHL     AH,8
        PUSH    BX
        MOV     BX,OFFSET TECLADO
        JC      @UN1
        BTR     WORD PTR CS:[BX],AX ;;;
        BTR     WORD PTR CS:[BX+4],AX ;;;
        JMP     @TAFI
@UN1:   BTS     WORD PTR CS:[BX],AX ;;;
        BTS     WORD PTR CS:[BX+4],AX ;;;
@TAFI:  POP     BX
@NZNZ:  SUB     AL,72-0Eh  ;72 DERECHA
        JZ      @ARI
        SUB     AL,3
        JZ      @IZQ
        SUB     AL,2
        JZ      @DPAF
        SUB     AL,3
        JZ      @ABA
        SUB     AL,15-80
        JNZ     @FINS
        INC     AX
@ARI:   INC     AX
@ABA:   INC     AX
@IZQ:   INC     AX
        JMP     @DPAF

IF JOYST
ELSE
@LEEJO: PUSH  DX
        MOV   DX,201h
@ALO:   OUT   DX,AL
        XOR   CX,CX
        XOR   BX,BX
@OTA:   IN    AL,DX
        TEST  AL,1
        JZ    @PPA
        INC   CX
        JZ    @NJOSA
@PPA:   TEST  AL,2
        JZ    @PPB
        INC   BX
@PPB:   TEST  AL,3
        JNZ   @OTA
        SHR   AL,5
        MOV   BYTE PTR DS:[OFFSET @DESJO+1],ah
@NJOSA: POP   DX
        RET
@EMJO:  JC      @LLT
        BTR     WORD PTR DS:[JOYSTIK],AX
        RET
@LLT:   BTS     WORD PTR DS:[JOYSTIK],AX
        RET
ENDIF

IF JOYST
ELSE
JOYSTIK DB 0FFh
ENDIF
KEMPSTO DB 0FFh
TECLADO DB 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
FUNCIOS DW 0FFFFh
IF JOYST
  TECAC DB 11 DUP (0FFh)
ELSE
  TECAC DB 12 DUP (0FFh)
ENDIF

IF SOUNDB
OWN_IRQ:push    ax
        push    dx
adbase: mov     dx, 0
        in      al,dx
trik:   mov     ax,0
        mov     byte ptr cs:[@aqui+1],al
        CMP     PUNTEG1,3
        JNC     @dos
        MOV     AX,624
@dos:   MOV     PUNTEG,ax
        mov     al,020h
        out     020h,al         ;ACKNOWLEDGE HARDWARE INTERRUPT
        pop     dx
        pop     ax
        IRET
@waitw: in      al,dx
        or      al,al
        jns     @endl2
        loop    @waitw
@endl2: ret
ENDIF

PRESEN  DB 24,24,24,24,0,10Fh-70h,' BACTERIA 1.91'
IF SOUNDB
        DB 'A'
ELSE
        DB 'B'
ENDIF
        DB '              ',0,104h-0Fh,'‹€',0,04Eh-4,'‹€',0,0E2h-4Eh,'‹€'
        DB 0,0129h-0E2h,'‹€',0,90h-29h,'‹€€',24,24
IF ESPANOL
        DB '€',0,0F0h-70h,'  El emulador m†s peque§o del mundo   €',24,24
IF SOUNDB
ELSE
        DB '€',0,0F0h-70h,'    Realizado en ensamblador por:     €',24,24
ENDIF
ENDIF
IF INGLES
        DB '€',0,0F0h-70h,'  The smallest emulator in the world  €',24,24
IF SOUNDB
ELSE
        DB '€',0,0F0h-70h,'    Made in assembly language by:     €',24,24
ENDIF
ENDIF

IF SOUNDB
        DB '€',0,0B0h-70h,'   Antonio Villena Godoy  1998-2003   €',24,24
        DB 'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ',24,0,100h-70h
ELSE
        DB '€',0,0B0h-70h,'     Antonio JosÇ Villena Godoy       €',24,24
        DB '€',0,0F0h-70h,'        espineter@yahoo.com           €',24,24
        DB 'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ',24,24
        DB '     ',0,0F2h-70h,'ﬂﬂﬂﬂﬂﬂ',0,17Eh-0F2h,' CP 29770, Torrox ',0,0E4h-7Eh,'ﬂﬂﬂﬂﬂﬂ',24,24
        DB '          ',0,72h-70h,'ﬂﬂﬂﬂﬂﬂ',0,74h-72h,'  MALAGA, Ap 125  ﬂﬂﬂﬂﬂﬂ'
        DB 24,24,24,24,24,'     ',0,100h-070h
ENDIF
IF ESPANOL
   cade DB 'No existe '
ENDIF
IF INGLES
   cade DB 'Not found '
ENDIF
   nrom DB '48.ROM',0,36

COLORES DB  00,00,00
        DB  00,00,40
        DB  56,00,00
        DB  56,00,44
        DB  00,52,00
        DB  00,52,52
        DB  52,52,00
        DB  48,50,48
        DB  00,00,00
        DB  00,00,44
        DB  60,00,00
        DB  62,00,56
        DB  00,60,00
        DB  00,60,62
        DB  62,60,00
        DB  62,60,62
        DB  12,34,56     ;color de grabaci¢n

ROTEMO  DB 7,0Fh,17h,1Fh,27h,3Fh,17h,2Fh
OPCOS   DB 0,10h,28h,18h,20h,30h,8,38h

@EXECU: JNZ     @TETEA
@EXF4:  PUSH    DI                              ;F4
        MOV     DI,16384
        MOV     SI,OFFSET JUEGO
        MOV     CX,6000h ;;;(16384*3/256)/2
        REP     MOVSW
        MOV     DI,100h
        MOV     CL,TOTREG
@TRAS:  LODSB
        MOV     [DI],AL
        INC     DI
        LOOP    @TRAS
        POP     DI
        MOV     SI,SNAPSI
        MOV     BP,SNAPBP
        MOV     F,SNAPF
@RSTP:  MOV     PFAIR,CX ;ecx los dos
        MOV     TVACIO,CX
        XCHG    CL,TMTEC
        RET
@TETEA: LOOP    @ATDE

@GRABA: MOV     SNAPSI,SI                       ;F3
        MOV     SNAPBP,BP
        MOV     SNAPF,F
        XOR     CX,CX
        PUSHA
        MOV     SI,16384
        MOV     DI,OFFSET JUEGO
@BKLT:  MOV     AL,BYTE PTR ES:[SI]
        MOV     BYTE PTR DS:[DI],AL
        INC     DI
        INC     SI
        JNZ     @BKLT
        MOV     SI,100h
        MOV     CL,TOTREG
@O3LD:  LODSB
        MOV     BYTE PTR DS:[DI],AL
        INC     DI
        LOOP    @O3LD
        POPA
        JMP     @RSTP

@ATDE:                                         ;F2
IF SOUNDB
        DEC     CX
ELSE
        LOOP    @DESBE
        MOV     BYTE PTR DS:[@CERO],03Ch
@DESBE:
ENDIF
        LOOP    @NGRAB
        PUSHA                                   ;F1

        mov     si,offset BUFSO                 
        mov     ch,1400/256
@okek:  mov     [si],al
        inc     si
        loop    @okek

        PUSH    DS
        DB      68h
        DW      OFFSET @RREE
        PUSH    ES
        DB      68h
        DW      4BFh
        RETF

@RREE: IN       AL,60h
       test     al,80h ;;cmp      al,59+80h
       JZ       @RREE
@PUPA: IN       AL,60h
       TEST     AL,80h
       JnZ       @PUPA
        POPA

@NGRAB: LOOP    @NSES
KSALIR: MOV     SI,OFFSET PRESEN
@SALIR:                                  ;ESCAPE
IRQ9OFF:mov     dx,3C8h
        DB      068h
IRQ9SEG DW      04BFh
        POP     DS
        MOV     AX,2509h
        INT     21h
        AAD     0F2h
        INT     10h
        xor     bx,bx    ;KITAR EL BLINK
        mov     ah,10h
        int     10h
        push    cs
        pop     ds

IF SOUNDB
        in      al,021h
pico:   OR      AL,00010010b
        out     021h,al
ENDIF

        XOR     DI,DI;;
@PRN:   DB      68h
        DW      0B800h ;0B7F0h
        POP     ES
        mov     cX,20
        mov     ax,07000h
        db      0F3h
@ST:    STOSW
@RP:    LODSB
        cmp     al,24
        jz      @PRN
        jnc     @ST
        lodsb
        add     ah,al
        jnz     @RP
        mov     ah,2
        mov     dh,00Ah-SOUNDB*4
        INT     10h
        mov     ah,4Ch
        INT     21h

@MUEL:  PUSHA
@MUUL:  MOV     DI,16D4h ;EN RECLAIM RUTINE
        MOV     BP,DI
        XCHG    AL,AH
        STOSW
        MOV     AX,201
@PAPAT: PUSH    AX
        CALL    @PANTA
        POP     AX
        DEC     AX
        JNZ     @PAPAT
        MOV     AH,13h
        CWD
        MOV     BH,0
        INC     CX
        INC     CX
        INT     10h
LALO:   LOOP    LALO
        DEC     AX
        JNZ     LALO
        POPA
@ATAT:  RET

@NSES:  LOOP    @NPLA
        XOR     SI,SI                           ;F9
@NPLA:  STC
        LOOP    @NRES
        DB      0A9h   ;TEST AX,.... C=0        ;F8
@NRES:  LOOP    @NANTE

@READ:  PUSHA                                   ;F7
        DB      0D6h
        JS      STLT
        CMC
STLT:   CBW
NUMEBL: ADC     AL,0
        JS      @LUKA
        MOV     DI,AX
@FUSI:  XCHG    AX,SI
        MOV     AX,4200h
        MOV     BX,HFILE
        CWD
        XOR     CX,CX
        INT     21h
@FAAA:  MOV     AH,3Fh
        MOV     DX,OFFSET @LONGT+1
        INC     CX
        INC     CX
        int     21h
        CMP     AL,2
        JC      @FNKT
        DEC     SI
        JS      @FNKR
@OSKT:  MOV     AX,4201h
@LONGT: mov     DX,OFFSET @LONGT+1
        XOR     CX,CX
        int     21h
        JMP     @FAAA
@FNKR:  XCHG    AX,DI
@FNKT:  MOV     BYTE PTR DS:[NUMEBL+1],AL
        AAM     10
        DEC     AX
@LUKA:  ADD     AX,'00'+1
        JMP     @MUUL

@NANTE: LOOP    @NDEPU
        INC     CX                              ;F6
        MOV     BP,CX
        MOV     BX,PFAIR                         ;leo puntero de grabaci¢n
        MOV     AH,23h                           ;F6 es lo £ltimo que me desactiva
        MOV     WORD PTR DS:[BX+OFFSET FAIR],AX  ;guardo en zona

@NDEPU: loop    @ATAT                           ;F5
        PUSH    PFAIR
IF COMPRE
ELSE
        MOV     CL,TOTNOP                       ;ahora pongo nop iniciales
        PUSH    DI
KSXK:   MOV     BYTE PTR DS:[DI],CH
        INC     DI
        LOOP    KSXK
ENDIF
oche:   MOV     DX,OFFSET @LONGT+1              ;dx=asciz filename
        MOV     SI,DX                           ;si=dx para buscar el punto
RSRA:   LODSB
        CMP     AL,'.'
        JNZ     RSRA
        MOV     WORD PTR DS:[SI],'OC'           ;cambio el tap o sna por extension com
        MOV     BYTE PTR DS:[SI+2],'M'
        MOV     AH,3Ch
        MOV     BYTE PTR DS:[OFFSET @MOFE],AH
        MOV     WORD PTR DS:[OFFSET @MOFE+3],OFFSET @EXF4-OFFSET @DLDA  ;sustituyo el LDSNA por F4
        INT     21h
        XCHG    AX,BX                           ;pongo handle en bx
IF COMPRE
        mov     ax,es                           ;es=base+1000h
        dec     ah
        mov     es,ax
        sub     ax,0FEEh                        ;ds=base+12h
        mov     ds,ax
        add     ax,7000h                        ;ss=base+7012h
        POP     DX                              ;DX=PFAIR
        mov     ss,ax
        MOV     CX,OFFSET @LDSNA-OFFSET @GUACHI
        MOV     DI,offset @GUACHI-offset @LDSNA
        PUSH    ES              ;para hacer un salto retf pongo segmento en pila
        push    di
        MOV     SI,OFFSET @GUACHI-120h          ;-120h porque ahora ds vale 12h mas
        REP     MOVSB           ;muevo el compresor, desde guachi hasta ldsna
        PUSH    DS
        POP     ES              ;ahora es apunta a zona emulador
        RETF
@GUACHI:MOV     DI,OFFSET @NPLA-120h            ;di=offset npla-100h porque ahora ds vale 10h mas
        MOV     CX,OFFSET JUEGO-OFFSET @NPLA    ;cx=borrar desde npla hasta juego
        MOV     AL,0C3h                         ;mediante ret
        REP     STOSB                           ;borro
        MOV     SI,OFFSET FAIR-OFFSET START-31  ;cx=longitud total
        DEC     BP                              ;es F5 o F6
        JNZ     @NOCM
        ADD     SI,DX                           ;es F6, a§ado el RZX
        LODSW                                   ;+2 para albergar ultimo F6
IF JOYST
        XOR     WORD PTR DS:[OFFSET @MVEE-120h],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 11)*100h
ELSE                                            ;para empezar reproduciendo
        XOR     WORD PTR DS:[OFFSET @MVEE-120h],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 12)*100h
ENDIF
        MOV     AX,WORD PTR DS:[OFFSET FAIR-120h]  ;parcheo para inicializar TVACIO
        INC     AX
        MOV     WORD PTR DS:[@INIV+1-120h],AX
@NOCM:  push    ds
        push    cs
        pop     ds
        mov     word ptr ds:[LONG+2-offset @LDSNA],SI
        dec     si
        dec     si
        push    bx              ;handle del archivo
        db      6Ah,0FFh
        push    cx
        push    cx
        push    cx
        push    cx
        push    cx
bprp:   mov     di,repu
        mov     cx,100h         ;repeticiones posibles a 256
        cmp     sp,1000h        ;ajusto segmento/offset de pila para no desbordarla
        jnc     kdld
        mov     ax,ss
        sub     ax,800h
        mov     ss,ax
        add     sp,8000h
kdld:   movzx   ax,es:[si]              ;leo de fuente
        mov     byte ptr fs:[si],al     ;ver por pantalla el status
        cwd                             ;dx=0
kere:   mov     word ptr ds:[di],dx
        scasw
        loop    kere
        adc     cx,si
        xor     di,di
nfin:   repnz   scasb
        jcxz    fine
        push    cx
        mov     cx,100h
        push    di
        push    si
        inc     si
        db      26h
        rep     cmpsb
LONG:   cmp     si,0FE81h
        ja      afin
        jcxz    spec
        sub     di,si
        neg     di
        mov     si,repu
        add     si,cx
        add     si,cx
        not     cl
        jcxz    afin
mile:   mov     word ptr [si],di
        inc     si
        inc     si
        loop    mile
afin:   pop     si
        pop     di
        pop     cx
        jmp     nfin
spec:   pop     si              ;peque§o truco para acelerar algoritmo
        pop     di              ;frente a repeticiones sucesivas
        pop     cx
        sub     cx,0FFh
        ja      nfin

fine:   mov     bx,repu
        mov     cx,0FFh
skla:   inc     bx
        inc     bx
        cmp     word ptr ds:[bx],dx
        jnz     alpl
        loop    skla
alpl:   dec     dx
        mov     MAXTLE,dx
        jcxz    lits
        dec     cx
amib:   mov     bp,sp
        push    cx
        push    word ptr ds:[bx]
        mov     dx,word ptr ds:[bx]
        add     bp,cx
        add     bp,cx
        add     bp,cx
        add     bp,cx
        add     bp,cx
        add     bp,cx
        mov     ax,9
        add     ax,cx           ;ax=11 para lon2,12 para lon3
        cmp     dx,127
        ja      bibi
        cmp     cl,3
        jc      ktik
bibi:   push    dx              ;calculo bits general
        push    cx
        inc     cx
        cmp     dx,127
        ja      tnnn
        dec     cx
        dec     cx
tnnn:   shr     dx,8
        inc     dx
        inc     dx
        bsr     ax,dx
        bsr     dx,cx
        pop     cx
        add     ax,dx
        add     ax,ax
        add     ax,10
        pop     dx
ktik:   add     ax,word ptr ss:[bp]
lnzo:   cmp     ax,MAXTLE
        jnc     fnts
        pop     MAXPOS
        pop     MAXLEN
        mov     MAXTLE,ax
        db      3Dh
fnts:   pop     bp
        pop     bp
fnls:   inc     bx
        inc     bx
        loop    amib
        movzx   ax,byte ptr es:[si]
lits:   mov     bx,7
        push    si
        or      al,al
        jz      lit0
        mov     cl,15
kluo:   dec     si
        cmp     al,es:[si]
        jz      lit0
        loop    kluo
litn:   inc     bx
        inc     bx
lit0:   pop     si
        pop     bp
        add     bx,bp
        push    bp
        cmp     bx,MAXTLE
        jbe     litr
        push    MAXLEN
        push    MAXPOS
        push    MAXTLE
        jmp     amil
litr:   jcxz    likt
        xchg    ax,cx
        lahf
likt:   db      06Ah            ;push 0, literales codifican longitud con 0
        db      0h
        push    ax
        push    bx
amil:   sub     si,1            ;cierro bucle
        jnc     bprp
        push    ds
        pop     es
        mov     di,longde       ;longitud del ejecutable
        mov     ax,0080h
        stosb
        rcl     ax,1
        push    di
maxi:   mov     ch,127-((offset @LDSNA-offset maxi+80h)/512)
        rep     stosw
        pop     di

miot:   cmp     sp,0F000h
        jc      nanz
        mov     ax,ss
        add     ax,800h
        mov     ss,ax
        add     sp,8000h
nanz:   pop     dx
        pop     bx
        pop     cx
        jcxz    lili
        add     sp,cx
        add     sp,cx
        add     sp,cx
        add     sp,cx
        add     sp,cx
        add     sp,cx
        inc     cx
        jz      fdto
        db      68h
        dw      offset miot-offset @LDSNA
        mov     ax,8080h ;10XXXXXX1XXXXXXX mejorar para aprovechar compresor
        cmp     bx,bp
        mov     bp,bx
        jz      ulpo
nliz:   cmp     bx,127
        ja      genl
        cmp     cl,3
        ja      genl
        xchg    ax,bx
        mov     ah,0Fh    ;111.0XXXXXXX 2  1111.0XXXXXXX 3
        jnc     slto
        shl     ax,1
slto:   add     cl,9
        shl     ax,1
        shl     ax,1
        shl     ax,1
pukk:   shl     ax,1
puta:   shl     ax,1
putb:   rcl     byte ptr ds:[di],1
        adc     di,0
        loop    puta
        ret
ulpo:   push    cx
        cbw
        mov     cl,5
        call    puta
        pop     dx
        jmp     gsle
lili:   db      68h
        dw      offset miot-offset @LDSNA
        or      bh,bh
        jz      norm
        neg     bl
        mov     ah,bl
neno:   and     ax,0110111100000000b    ;el 0 no sirve de nada pero ocupa igual
        mov     cl,7                    ;y mejora compresi¢n.
        jmp     pukk
genl:   db      68h
        dw      offset miau-offset @LDSNA
        push    cx
        mov     cl,2
        call    puta            ;10-
        mov     dl,bh
        inc     dx
        inc     dx
        call    gsle            ;10-X1X1X0-    bh-2
        pop     dx
        cmp     bx,127
        ja      gsle
        dec     dx
        dec     dx
gsle:   db      0Ch
mixu:   stc
        rcr     ax,1
        inc     cx
        inc     cx
        shr     dl,1
        rcr     ax,1
        cmp     dl,1
        jnz     mixu
        jz      puta
norm:   or      bl,bl
        mov     ah,0E0h
        jz      neno
        inc     cx
        call    putb
miau:   mov     cl,8
        mov     ah,bl
        jmp     puta
fdto:   mov     ax,040h
        mov     cl,8
        call    puta
        stosb
        pop     bx
        pop     bx
        pop     bx
        pop     bx
        mov     cx,di
        int     21h
        MOV     SI,OFFSET PRESEN-120h
        DB      68h
        DW      OFFSET @SALIR-120h
        RETF
ELSE
        MOV     CL,OFFSET @LDSNA-OFFSET @GUACHI
        PUSH    ES              ;para hacer un salto retf pongo segmento en pila
        push    di
        MOV     SI,OFFSET @GUACHI
        REP     MOVSB           ;muevo el compresor, desde guachi hasta ldsna
        PUSH    DS
        POP     ES              ;ahora es apunta a zona emulador
        RETF
@GUACHI:MOV     DI,OFFSET @NPLA
        MOV     CX,OFFSET JUEGO-OFFSET @NPLA    ;cx=borrar desde npla hasta juego
        MOV     AL,0C3h                         ;mediante ret
        REP     STOSB                           ;borro
        POP     DX
        POP     SI
        MOV     CX,OFFSET FAIR-OFFSET START
        DEC     BP
        JNZ     @NOCM
        LODSW
        ADD     CX,SI
IF JOYST
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 11)*100h
ELSE
        XOR     WORD PTR DS:[OFFSET @MVEE],50h+((OFFSET @REPRO-OFFSET @PMVE) XOR 12)*100h
ENDIF
        MOV     AX,WORD PTR DS:[OFFSET FAIR]
        INC     AX
        MOV     WORD PTR DS:[@INIV+1],AX
@NOCM:  MOV     AH,40h
        INT     21h
        PUSH    DS
        DB      68h
        DW      OFFSET KSALIR
        RETF

ENDIF
@LDSNA: mov     si,03FE5h
        db      26h
        lodsb
        mov     i,al
        db      26h
        lodsw
        MOV     HLp,AX
        db      26h
        lodsw
        MOV     DEp,AX
        db      26h
        lodsw
        MOV     BCp,AX
        db      26h
        lodsw
        MOV     AFp,AX
        db      26h
        lodsw
        MOV     HL,AX
        db      26h
        lodsw
        MOV     DE,AX
        db      26h
        lodsw
        MOV     BC,AX
        db      26h
        lodsw
        MOV     IY,AX
        db      26h
        lodsw
        MOV     IX,AX
        db      26h
        lodsb
        SHL     AL,5
        AND     AL,80h
        mov     IM,AL
        db      26h
        lodsb
        MOV     R,AL
        db      26h
        lodsw
        MOV     F,AL
        MOV     A,AH
        db      26h
        lodsw
        xchg    bp,ax
        db      26h
        lodsb
        SHR     AL,1
        OR      IM,AL
        db      26h
        lodsb
        MOV     POR,AL
        MOV     SI,WORD PTR ES:[BP]
        INC     BP
        INC     BP
        RET
 JUEGO  DB      16384*3+TOTREG DUP (?)
  FAIR  DB      4096*2 DUP (?)
 BUFSO  DB      1400 DUP (?)
END START
 pspseg         00 00 00 .. 00
 pspseg+2       bacteria
 pspseg+1000h   decompresor
 pspseg+1100h   mapa z80
 pspseg+2100h   demo F1
