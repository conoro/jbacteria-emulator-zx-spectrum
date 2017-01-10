                cpu     186
                org     $100
;-----------------------constantes ensamblaje condicional
                %define SOUNDB  1               ;utilizo soundblaster o speaker
                %define JOYST   1               ;a 0 para deshabilitar el joystick
;-----------------------registros Z80
                %define F       dl
                %define A       byte [di]
                %define BC      word [di+2]
                %define B       byte [di+3]
                %define C       byte [di+2]
                %define DE      word [di+4]
                %define D       byte [di+5]
                %define E       byte [di+4]
                %define HL      word [di+6]
                %define H       byte [di+7]
                %define L       byte [di+6]
                %define AFp     word [di+8]
                %define Ap      byte [di+9]
                %define Fp      byte [di+8]
                %define BCp     word [di+10]
                %define Bpp     byte [di+11]
                %define Cp      byte [di+10]
                %define DEp     word [di+12]
                %define Dpp     byte [di+13]
                %define Ep      byte [di+12]
                %define HLp     word [di+14]
                %define Hp      byte [di+15]
                %define Lp      byte [di+14]
                %define IX      word [di+16]
                %define IY      word [di+18]
                %define IR      word [di+20]
                %define I       byte [di+21]
                %define R       byte [di+20]
                %define RD      byte [$100+20]
                %define TIM     word [di+22]
                %define PRB     byte [di+24]
                %define POR     byte [di+25]
                %define POC     byte [$100+25]
                %define IMA     word [di+25]
                %define IM      byte [di+26]   ;PROBAR EN DI+1
                %define SNAPF   byte [di+27]
                %define SNAPSI  word [di+28]
                %define SNAPBP  word [di+30]
;-----------------------constantes miscelanea
                %define SENSI   80              ;sensibilidad del joystick
                %define TOTREG  32              ;numero total de registros que se guardan
                %define HFILE   5               ;handle generico del archivo tap
                %define TOTNOP  32              ;nops que se deben insertar al principio
                %define GRAB    20h             ;GRABx128=NUMERO DE BOTONES QUE SE GRABAN
;-----------------------variables no guardadas en snap,fácil acceso e inicializadas a 0
                %define FLASH   byte [di-19]
                %define FLAS2   [cs:$100-19]
                %define EJEX    word [di-20]    ;centro del eje x del joystick
                %define EJEY    word [di-18]    ;centro del eje y del joystick
                %define PFAIR   word [di-16]
                %define TVACIO  word [di-14]
                %define TIEM    word [di-12]
                %define PUNTE   word [di-10]    ;puntero del sample actual de sonido
                %define PUNTEG  word [cs:$100-10]
                %define PUNTEG1 byte [cs:$100-9]
                %define MAXLEN  word [$100-8]   ;máxima longitud de cadena encontrada en bytes
                %define MAXPOS  word [$100-6]   ;posición hacia atrás donde se encuentra la cadena
                %define MAXTLE  word [$100-4]   ;máxima longitud total en bits que llevo
                %define TMTEC   byte [di-2]     ;tecla pulsada en el frame anterior
                %define EXTEN   [cs:$100-1]     ;flag indicando carácter extendido
                %define fair    juego+16384*3+TOTREG
                %define bufso   fair+4096*2
;-----------------------empieza el programa
start           times   TOTNOP  db  0
                cld
%if SOUNDB
                salc
                mov     di, ax
                mov     ch, $40
                mov     es, [di+$2C]
sigdet          repnz   scasb
                scasb
                jz      short findet
                cmp     word [es:di-1], 'BL'
                jnz     short sigdet
                mov     al, [es:di+$09]         ;PUERTOBASE
                shl     ax, 4
                add     ax, 6-$100              ;2x6
                xchg    ax, dx
                sub     byte [es:di+$0D], '0'-8 ;IRQ
                mov     cl, [es:di+$0D]         ;IRQ
                mov     al, 1
                rol     al, cl
                mov     [pico+1], al
                mov     bp, waitw
                mov     al, 1
                out     dx, al                  ; start DSP reset
                call    bp
                xchg    ax, cx
                out     dx, al                  ; end DSP Reset
                add     dl, 8                   ;2xE
                mov     [adbase+1], dx
waitr           in      al, dx
                or      al, al
                jns     short waitr
                sub     dl, 4                   ; dx = 2xA DSP Read Data
                in      al, dx
findet          cmp     al, $0aa                ; if there is a SB then it returns 0AAh
                jnz     short tttt+1
                inc     dx
                inc     dx                      ; 2xC
                call    bp
                mov     al, $0d1                ; AL = Enable speaker
                out     dx, al
                in      al, $21
                mov     cl, [pico+1]
                not     cl
                and     al, cl
                out     $21, al
                mov     ds, bx
                mov     bl, [es:di+$0d]         ;IRQ
                shl     bl, 2
                mov     word [bx], OWN_IRQ
                mov     [bx+2], cs
                push    cs
                pop     ds
                mov     al, [es:di+$10]         ;DMACHANEL
                sub     al, '0'-4
                out     $0a, al                 ;Write mask
                out     $0c, al                 ;Clear ff
                add     al, 01011000b-4         ;Wanted mode: singlemode, autoinit, readmode
                out     $0b, al                 ;Write mode
                sub     al, 01011000b           ;Wanted mode: singlemode, autoinit, readmode
                push    dx
                push    ax
                mov     ax, ds
                rol     ax, 4                   ; * 16 - higher 4 bits in al
tttt            mov     bl, al
                and     bl, $0f                 ; BL - higher 4 bits
                and     al, $0f0                ; clear higher 4bits in AL
                add     ax, bufso
                adc     bl, bh                  ; BL = page
                pop     dx
                push    dx
                add     dx, dx
                out     dx, al
                mov     al, ah
                out     dx, al
                mov     cx, dx
                add     cx, cx
                inc     dx
                mov     al, $0df ;1247cl
                out     dx, al
                mov     al, $04 ;ch
                out     dx, al
                mov     ax, $7312
                shl     ax, cl
                shr     ax, 12
                add     al, $80
                xchg    ax, dx
                xchg    ax, bx
                out     dx, al
                pop     ax
                pop     dx
                out     $0a, al                 ;Write mask
                mov     al, $40                 ;AL = Set timeconstant
                out     dx, al
                mov     al, 224                 ; = 31250 Hz (256-1000000/11000)
                out     dx, al
                call    bp
                mov     al, $48                 ;AL = DMA DAC 8bit
                out     dx, al
                call    bp
                mov     al, $6F                 ;AL = LOWER PART SAMPLELENGTH
                out     dx, al
                call    bp
                mov     al, 2                   ;AL = HIGHER PART SAMPLELENGTH
                out     dx, al
                call    bp
                mov     al, $1c                 ;AL = Auto-Initialize DMA DAC, 8-bit
                out     dx, al
%endif
                mov     bl, $80
                mov     di, $0100
                mov     ax, ds
                add     ah, $11
                mov     es, ax
                mov     si, $0081
kili            mov     dx, si
                lodsb
                cmp     al, 32
                jz      short kili
                mov     [oche+1], dx
                add     bl, [bx]
                mov     [bx+1], bh
                mov     ax, $3D00               ;open for read
                int     $21
                jc      short mimi              ;error file no exist
                test    byte [bx], $0F          ;.tap p=50h flag z activate
                jz      short mimi
                mov     byte [mofe], $3C        ;make jump in mofe
                xchg    ax, bx
                push    es
                pop     ds
                mov     ah, $3f
                mov     dx, $3fe5               ;place to open snap
                mov     cx, $0c01b              ;length to open
                int     $21
                push    cs
                pop     ds
mimi            mov     ax, $3d00               ;open for read
                mov     dx, nrom                ;rom file
                int     $21
                jnc     short nfino
                mov     ah, 9
                mov     dx, cade
                int     $21
                ret
nfino           push    ax                      ;push handle
                mov     al, $13
                int     $10                     ;mode 13h
                salc
                mov     dx, $03c8
                out     dx, al                  ;color index=0
                inc     dx
                mov     si, colores
                mov     cx, 3*17
                rep     outsb
%if JOYST
                call    leejo                   ;read joystick axes
                mov     EJEY, bx
                mov     EJEX, cx
%endif
                mov     ax, $3509               ;save interrup vectors
                push    es
                int     $21
                mov     [irq9seg+1], es
                mov     [irq9off+1], bx
                mov     ah, $25                 ;set keyboard interrupt
                mov     dx, NewInt9
                int     $21
                pop     es
                xor     si, si
mofe            jmp     fisi
                call    ldsna                   ;load snapshot
dlda            call    muel
fisi            pop     bx                      ;end of sna, bx=handle
                push    es
                pop     ds
                mov     ah, $3F
                push    dx
                cwd
                mov     ch, $40
                int     $21                     ;read 48.rom
                pop     dx
                push    cs
                pop     ds
                call    graba
iniv            mov     ax, 0
                mov     TVACIO, ax              ;es importante que sea despues de graba
deco            mov     di, $100
                cmp     dh, 112
                jc      short tsige
                sub     dh, 112
%if SOUNDB
                mov     al, [issue+1]
                shl     al, 2
                salc
                mov     bx, PUNTE
                mov     [bx+bufso], al
                cmp     bh, 5
                jnc     short npute
                inc     PUNTE
%else
llkk            salc
                out     $43, al
                in      al, $40
                mov     ah, al
                in      al, $40
                xchg    al, ah
                mov     cx, ax
                sub     cx, TIEM
trik            add     cx, 38
                jc      short llkk
                mov     TIEM, ax
                in      al, $61
                and     al, 11111100b
                test    POR, $10
                jz      short cero
                or      al, 2
cero            out     $61, al
%endif
npute           mov     ax, TIM
                inc     TIM
                shr     ax, 1
                jc      short deco
                cmp     ax, 252
                jnc     short vlsi
                db      $2d, 52, 0  ; sub ax, 52
                jc      short deco
                push    sige
panta           mov     di, ax                  ;apuntaremos a la pantalla
                xchg    ah, al                  ;multiplicamos ax por 256
                shl     di, 6                   ;multiplicamos di por 64
                add     di, ax                  ;di ya esta calculado di=320*line
                mov     al, POC                 ;en al el color del borde "por"
                push    $0a000                  ;mov ds,a000
                pop     ds
                and     al, 111b                ;los bits que me interesan del borde
                sub     ah, 4
                jc      short tbde
                cmp     ah, 192
                jc      short dntr
tbde            mov     cx, 320                 ;numero de puntos=320=1 linea entera
                cmp     cl, [ss:mvee+1]
                jnc     short tclp
                mov     al, 16
tclp            jmp     cclp
vlsi            sub     ax, 312
                jz      short nsige
tsige           jmp     sige
dntr            mov     cx, 32                  ;cx = 32 puntos que hay de borde izdo
cclo            mov     [di], al                ;pinto un punto
                inc     di                      ;incremento posicion
                loop    cclo                    ;repito 32 veces
                push    ax
                mov     cl, ah
                and     ah, 11000000b
                mov     bx, cx
                and     bl, 111b
                shl     bl, 3
                shr     cl, 3
                push    cx
                and     cl, 111b
                or      bl, cl
                or      bl, ah
                mov     bh, 2
                shl     bx, 5
                pop     ax
                shl     ax, 5
                add     ah, $58
                mov     cl, 32                  ;cx=32= numero de caracteres a pintar
                push    dx
lin1            push    cx                      ;guardamos en pila
                xchg    ax, bx                  ;ax=attrib  bx=bytecarac
                mov     dh, [es:bx]             ;dh=atributo
                xchg    ax, bx                  ;bx=attrib  ax=bytecarac
                inc     ax                      ;incremento bytecarac
                mov     ch, dh
                and     ch, 111b
                mov     cl, dh
                and     cl, $38
                shr     cl, 3
                test    dh, $40
                jz      short nbri
                or      cx, $0808
nbri            test    dh, FLAS2
                jns     short lin2
                xchg    ch, cl
lin2            rol     byte [es:bx], 1
                jc      short pifo
                mov     [di], cl
                db      $3d
pifo            mov     [di], ch
                inc     di
                test    di, 111b
                jnz     short lin2
                pop     cx
                inc     bx                      ;incremento atributo
                loop    lin1                    ;repito 32 veces
                pop     dx
                pop     ax
                mov     cl, 32
cclp            mov     [di], al
                inc     di
                loop    cclp
                push    cs
                pop     ds
                mov     di, $100
                ret

nsige           mov     TIM, ax

%if SOUNDB
aqui            jmp     aqui
                mov     byte [aqui+1], $0fe
%endif

%if JOYST
desjo           JMP     mvee                    ;descarto si no hay joystick
                call    leejo                   ;leo ejes en cx y bx
                mov     al, $10                 ;bit 4=boton
                call    emjo                    ;guardo en variable
                mov     al, $08                 ;bit 3=arriba
                sub     bx, EJEY
                jnc     short abj
                add     bx, SENSI               ;comparo arriba
                call    emjo                    ;guardo
                jmp     mver
abj             mov     al, $04                 ;bit 2=abajo
                cmp     bx, SENSI               ;comparo abajo
                call    emjo                    ;guardo
mver            mov     al, $02                 ;bit 1=izqui
                mov     bx, cx
                sub     bx, EJEX
                jnc     short abe
                add     bx, SENSI               ;comparo izqui
                call    emjo                    ;guardo
                jmp     mvee
abe             dec     ax                      ;bit 0=dere
                cmp     bx, SENSI               ;comparo
                call    emjo                    ;guardo
mvee            mov     cx, 12                  ;12 estados joystick,kempston,8 column,2funcios
%else
mvee            mov     cx, 11                  ;11 estados kempston,8 column,2funcios
%endif
pmve            mov     bx, tecac
%if JOYST
bubx            mov     al, [bx+teclado-tecac-2]  ;leo de teclado
%else
bubx            mov     al, [bx+teclado-tecac-1]  ;leo de teclado
%endif
                mov     ah, [bx]                ;leo de tecac
                mov     [bx], al                ;escribo en teclado
                xor     ah, al                  ;miro diferencias entre pulsado anterior y ahora
                mov     ch, 5                   ;ch=5 teclas por byte=movimientos kempston=funcios
otbx            sahf                            ;miro bit0 de ah
                jnc     short nabx              ;si no carry salto a nabx
                pusha                           ;diferencia, pongo todo en pila
                xchg    ax, cx                  ;en ax tengo contadores que me indican el evento
                sub     ax, $0101               ;resto uno a fila y columna
                mov     ch, al                  ;ch=fila-1
                shl     al, 2                   ;al=(fila-1)*4
                add     al, ch                  ;al=(fila-1)*5
                add     al, ah                  ;al=(fila-1)*5+columna-1
                mov     ch, al                  ;ch=(fila-1)*5+columna-1
                mov     bx, TVACIO              ;bx=contador de estados sin cambiar
                cwd
                mov     TVACIO, dx              ;reseteo contador de estados
                xchg    al, TMTEC
                shl     ax, 10                  ;en parte alta pongo evento
                or      ax, bx                  ;en parte baja contador de estados
                mov     bx, PFAIR               ;leo puntero de grabación
                cmp     bh, GRAB                ;si ya he leido mucho tiempo
                jz      short noin              ;no incremento puntero
                add     PFAIR, 2                ;incremento puntero
noin            mov     [bx+fair], ax           ;guardo en zona
                cmp     ch, 10                  ;miro si orden es mayor de 10
                mov     [cs:tmpv+1], cx
                popa                            ;restauro registros
                jnc     short nabx              ;continuo bucle si no orden
                push    cx
tmpv            mov     cx, 0                   ;leo orden pulsada
                shr     cl, 1                   ;veo si es descartable
                jnc     short apea
                sub     PFAIR, 2                ;recupero puntero cambiado
                jmp     kstk
apea            shr     cx, 8                   ;cl=orden
                call    execu                   ;ejecuto orden
kstk            pop     cx
nabx            shr     ax, 1                   ;leo siguiente bit de diferencia de entre los 5
                dec     ch
                jnz     short otbx              ;cierro bucle columna
                inc     bx
                loop    bubx                    ;cierro bucle fila
                mov     ax, TVACIO
                inc     ax
                sahf
                jnp     short nmel
                mov     al, 7                   ;F7
                XCHG    AL, TMTEC
                shl     ax, 10
                or      ax, $03ff
                mov     bx, PFAIR
                cmp     bh, GRAB
                jz      short noia
                add     PFAIR, 2
noia            mov     [bx+fair], ax
                mov     ax, 1
nmel            mov     TVACIO, AX
                jmp     acte

repro           test    byte [funcios], $02
                jz      short silk
%if JOYST
                xor     word [mvee], $50+((repro-pmve)^12)*$100
%else
                xor     word [mvee], $50+((repro-pmve)^11)*$100
%endif
%if SOUNDB
                mov     byte [trik+1], 0
%else
                mov     byte [trik+2], 38
%endif
silk            test    byte [funcios], $01     ;f5
                jnz     short sil2
%if SOUNDB
                mov     byte [trik+1], 5
%else
                mov     byte [trik+2], 0
%endif
sil2            dec     TVACIO
                jnz     short acte              ;si tvacio=0 hago ste cosa
migo            mov     TVACIO, $03FF           ;pongo tvacio al maximo
                mov     bx, PFAIR
                add     PFAIR, 2
                mov     ax, [bx+fair+2]         ;leo orden guardada
                push    ax
                shr     ax, 10
                cmp     al, 8
                jnz     short koae              ;miro si la orden es F6 fin de reproducción
%if JOYST
                xor     word [mvee], $50+((repro-pmve)^12)*$100
%else
                xor     word [mvee], $50+((repro-pmve)^11)*$100
%endif
%if SOUNDB
                mov     byte [trik+1], 0
%else
                mov     byte [trik+2], 38
%endif

koae            mov     cl, 5                   ;puesto en modo grabación
                div     cl
                mov     cl, ah                  ;cl=columna al=fila
%if JOYST
                mov     bx, tecac+11
%else
                mov     bx, tecac+10
%endif
                cbw
                sub     bx, ax                  ;bx apunta a byte
                mov     al, $10
                shr     al, cl                  ;al apunta a bit
                xor     [bx], al                ;cambio estado
                pop     ax                      ;recupero tiempo
                and     ax, $03ff               ;filtro solo parte tiempo
                jz      short migo              ;si cero poner a 3ff y repetir ya que se pulso otra tecla en el mismo frame
                mov     TVACIO, ax              ;actualizar variable
acte            mov     al, FLASH
                inc     ax
                mov     ah, $80
                cmp     al, 25
                jnz     short nrst
                mov     al, -25
nrst            mov     FLASH, al
                test    IM, ah
                jz      short sige
                xor     IM, ah
                dec     bp
                dec     bp
                cmp     byte [es:si], $76
                jnz     short ehal
                inc     si
ehal            mov     [es:bp], si
                mov     si, $0038
                add     dh, 13
                sub     ah, IM
                js      short sige
                mov     bh, I
                mov     bl, $0ff
                mov     si, [es:bx]
                add     dh, 6

sige            push    deco
                mov     PRB, 6
abapre          mov     bx, 102h
                mov     al, R
                rol     al, 1
                add     al, 2
                ror     al, 1
                mov     R, al
                xor     cx, cx
                xor     ax, ax
                add     dh, 4
                db      $26 ;es
                lodsb
                shl     al, 1
                jc      short n
                jmp     s
n               shl     al, 1                   ;80-FF
                jc      short nn
                jmp     calc
nn              add     dh, 6
                shr     al, 3                   ;C0-FF
                jc      short nnh
                jmp     nnl
nnh             shr     al, 1                   ;C0-FF impares
                jnc     short nnhl
                jmp     nnhh
nnhl            shr     al, 1                   ;C0-FF imp*par C1,C5,C9,CD,D1,D5,D9,DD,E1,E5,E9,ED,F1,F5,F9,FD 
                jc      short nnhlh
                jmp     nnhll
nnhlh           shr     al, 1                   ;C0-FF imp*par*imp  C5,CD,D5,DD,E5,ED,F5,FD
                jc      short nnhlhh
                jmp     _push
nnhlhh          shr     al, 1                   ;C0-FF imp*par*imp*imp  CD,DD,ED,FD
                jnc     short nddfd
                jmp     ddfd
nddfd           jnz     short edpr
                jmp     calnn                   ;C0-FF imp*par*imp*imp*par  CD,ED 
        ;;ED PREFIX
edpr            mov     al, R
                rol     al, 1
                add     al, 2
                ror     al, 1
                mov     R, al
                add     dh, 4
                db      $26
                lodsb
                shl     al, 1
                jnc     short _s
                jmp     _n
_s              shl     al, 1                   ;00-7F
                jnc     short _nad
                shr     al, 3                   ;40-7F
                jc      short _snh
                shr     al, 1                   ;40 42 44 46 48 ...
                jc      short _snlh
                shr     al, 1                   ;40 44 48 4c 50
                jc      short _neg
        ;;IN S,(C) ;ED 40,48,50,58,60,68,70,78 "IN S,(C)" S=B,C,D,E,H,L,A
                add     dh, 4
                add     bx, ax
                and     bl, 111b
                xor     bl, bh
                push    dere
pinbc           mov     ax, BC
pin             push    di
                cmp     al, $0df
%if JOYST
                mov     di, tecac+2
%else
                mov     di, tecac+1             ;kempston
%endif
                jz      short koer
                test    al, 11100000b
                jnz     short noke
koer            dec     di
                mov     al, [di]
                dec     di
                and     al, [di]
                not     al
nknk            pop     di
                ret
noke            and     al, 1
                jnz     short nknk
                inc     ax
issue           mov     cl, $0bf
rutl            shr     ah, 1
                JC      short nand
                and     cl, [di]
nand            inc     di
                shl     al, 1
                jnz     short rutl
                xchg    ax, cx
                pop     di
_nad            ret
        ;;NEG ;ED 44,4C,54,5C,64,6C,74,7C "NEG"
_neg            xchg    ch, A
                mov     cl, 010000b
                jmp     oper
_snlh           shr     al, 1                   ;42 46 4A 4E 52 56 5A ....
                jc      short imod
        ;;ADC,SBC HL,SS ;ED 42,4A,52,5A,62,6A,72,7A "ADC,SBB HL,SS"  SS=BC,DE,HL,SP
                add     dh, 7
                mov     ch, $11                 ;11h=opcode adc
                shr     al, 1
                jc      short sbbb
                mov     cx, $1902               ;19h=opcode sbb
sbbb            mov     [sumo], ch
                add     al, al
                add     bx, ax
                cmp     al, 6
                mov     ax, [bx]
                jnz     short sbac
                mov     ax, bp
sbac            ror     F, 1                    ;paso el C del z80 al PC
sumo            adc     HL, ax
                lahf
                pushf
                and     ah, 11111001b           ;overflow  n a 0
                popf
                jno     short cafi
                or      ah, 00000100b           ;Overflow a 1
cafi            mov     F, ah
                or      F, cl
                ret
_snh            shr     al,1               ;41 43 45 47 49 4b 4d..
                jc      short _snhh
                shr     al,1               ;41 45 49 4d 51 55 ..
                jc      short reti
        ;;OUT (C),S   ;OP ED 41,49,51,59,61,69,79 "OUT (C),S" S=B,C,D,E,H,L,A   12
                add     dh, 4
                add     bx, ax
                shl     bl, 5
                jz      short out0
                shr     bl, 5
                xor     bl, bh
                mov     al, [bx]
                db      $3d
out0            mov     al, 0 ;db      0d6h         ;ed 71
poutbc          mov     ah, C
pout            shr     ah, 1
                jc      short lare              ;entrada ah=direc puerto al=byte
                mov     POR, al
                shr     al, 1
                xor     al, POR
                shr     al, 4 
                salc
                or      al, $0bf
                mov     [issue+1], al
lare            ret
        ;;IM ?      ;OP ED 46,4E,56,5E,66,6E,76,7E "IM ?"
imod            inc     ax
                and     al, 11b
                jnz     short ah01
                stc
ah01            rcr     IM, 1
                rol     IM, 1
                ret
        ;;RETI, RETN   ;OP ED 45,4D,55,5D,65,6D,75,7D
reti            add     dh, 6
                or      IM, 10000000b
                jmp     sire
_snhh           shr     al, 1                   ;43 47 4B 4F 53 57 ..
                jc      short _snhhh
                shr     al, 1                   ;43 4b 53 5b ..
                jc      short _lssnn
        ;;LD (NN),SS   ;OP ED 43,53,63,73 "LD (NN),SS"  SS=BC,DE,HL,SP
                add     al, al
                add     bx, ax
                cmp     al, 6
                mov     ax, [bx]
                jnz     short sbad
                mov     ax, bp
sbad            jmp     ldim
        ;;LD SS,(NN)   ;OP ED 4B,5B,6B,7B "LD SS,(NN)"  SS=BC,DE,HL,SP
_lssnn          add     al, al
                add     bx, ax
                cmp     al, 6
                jz      short nldix
                jmp     ldix
nldix           db      $26
                lodsw
                xchg    bx, ax
                mov     bp, [es:bx]             ;op ed 7b "ld sp,(nn)"
                ret
_snhhh          cmp     al, 2                   ;47 4f 57 5f 67 6f 77 7f
                jnc     short _rrr1
        ;;LD I,A ;LD R,A  ;ED 47 4F > 8 9 > A B
                inc     dh
                xor     al, $13
                add     bx, ax
                mov     al, A
dere            mov     [bx], al
                ret
_rrr1           cmp     al, 4                   ;57 5f 67 6f 77 7f
                jnc     short _rrrr
        ;;LD A,I ;LD A,R
                inc     dh
                xor     al, $11
                add     bx, ax
                mov     al, [bx]
                mov     A, al
                mov     ah, F
                and     ax, 0000000111101000b
                or      ah, al
                mov     al, IM
                shr     al, 5
                or      al, ah
                mov     F, al
                ret
_rrrr           add     dh, 10
                cmp     al, 5
                mov     bx, HL
                mov     ch, [es:bx]
                mov     al, A
                mov     ah, al
                mov     cl, 4
                jnz     short _rrd
        ;;RLD ;ED 6F
                shl     ch, cl
                and     ax, $0f00f
                or      al, ch
                xchg    al, [es:bx]
                shr     al, cl
tote            or      al, ah
                mov     A, al
                and     al, al
                lahf
                and     ax, 0100010010101000b
                shr     F, 1
                adc     al, ah
                mov     F, al
_2ret           ret
        ;;RRD ;ED 67
_rrd            jnc     short _2ret
                shr     ch, cl
                shl     al, cl
                or      al, ch
                xchg    al, [es:bx]
                and     ax, $0f00f
                jmp     tote
_n              shl     al, 1                   ;80-ff
                jc      short _2ret
                sub     al, $80                 ;80-bf
                shl     al, 1
                jc      short _2ret
                add     dh, 8
                shr     al, 4                   ;a0-bf > 00-1f
                jc      short _nh
                shr     al, 1                   ;a0 a2 a4 a6 a8 ..
                jc      short _nlh
                shr     al, 1                   ;a0 a4 a8 ac b0 b4..
                jc      short _2ret
        ;;LD??   ;OP A0 A8 B0 B8 "LDI,LDD,LDIR,LDDR" BX=0,1,2,3
                shr     al, 1
                mov     bx, HL
                mov     bl, [es:bx]
                pushf
                push    di
                mov     di, DE
                xchg    ax, bx
                call    esdb
                pop     di
                popf
                jc      short oiod              ;flag arrastrado 9 lineas arriba
                inc     DE
                inc     HL
                jmp     short oooi
_nlh            shr     al, 1                   ;a2 a6 aa ae b2 b6
                jc      short _3ret
        ;;IN??   ;OP A2 AA B2 BA "INI,IND,INIR,INDR"
                push    ax
                call    pinbc
                mov     bx, HL
                mov     [es:bx], al
lmqi            xchg    ax, bx
                pop     ax
                shr     al, 1
                jc      short ciad
                inc     HL
                jmp     short mier
ciad            dec     HL
mier            dec     B
                lahf
                and     ah, 11000000b
                mov     F, ah
                mov     ah, bl
                stc
                adc     bl, C
                jno     short rach
                or      F, 00010001b
rach            shr     ah, 7
                add     ah, ah
                or      F, ah
                test    F, 01000000b
                jnz     short rtit
                shr     al, 1
                jc      short core
rtit            ret
_nh             shr     al, 1                   ; a1 a3 a5 a7 a9 ab ..
                jnc     short _nhl
                shr     al, 1                   ; a3 a7 ab af b3 ..
                jc      short rtit
        ;;OUT??  ;OP A3 AB B3 BB "OUTI,OUTD,OTIR,OTDR"
                push    ax
                mov     bx, HL
                mov     al, [es:bx]
                call    poutbc
                jmp     short lmqi

oiod            dec     DE
                dec     HL
oooi            and     F, 11000001b            ;todos menos szc a la m
                add     al, A
                and     al, 101b
                shl     al, 3
                dec     BC
                jz      short orfa
                or      al, 00000100b
                shr     bl, 1
                jnc     short orfa
core            add     dh, 5
                sub     si, 2
orfa            or      F, al
_3ret           ret

ciod            dec     word [bx+4];HL
mddm            sub     al, [es:di]
                lahf                            ; x velocidad con call oper tb vale
                sub     al, [bx+5];H
                and     ax, 1101000000000101b
                shl     al, 3
                or      al, 10b
                or      al, ah
                and     F, bh
                dec     word [bx];BC
                jz      short cpir
                or      al, 100b                ; pv lo pongo a 1
                jcxz    cpir
                test    al, 01000000b           ;miro si flag z=1 salgo
                jz      short core
cpir            or      F, al
                ret

_nhl            shr     al, 1
                jc      short rtit
        ;;CP??  ;OP A1 A9 B1 B9 "CPI,CPD,CPIR,CPDR"
                shr     al, 1
                xchg    ax, cx
                mov     di, HL
                mov     al, [bx-2]
                jc      short ciod
                inc     word [bx+4];hl
                jmp     mddm

        ;;DD FD PREFIX
ddfd            sub     dh, 6
                shl     al, 1                   ;dd fd prefijos
                add     al, $10
                mov     PRB, al
                jmp     abapre
        ;;PUSH SS  ;C5,D5,E5,F5 > 00 01 02 03  BC,DE,HL,AF
_push           inc     dh
                cmp     al, 2
                jc      short nanh
                mov     bl, PRB
                jz      short pushda
                mov     ah, A                   ;push af
                mov     al, F
                jmp     pushdx
nanh            add     al, al
                add     bx, ax
pushda          mov     ax, [bx]
pushdx          dec     bp
                dec     bp
esbp            cmp     bp, $4000
                jc      short sa04
                mov     [es:bp], ax
sa04            ret
nnhll           shr     al, 1                   ;c1,c9,d1,d9,e1,e9,f1,f9
                jc      short nnhllh            ;c1,d1,e1,f1 > 00 40 80 c0
        ;;POP XX  ;C1 D1 E1 F1
                mov     cx, [es:bp]
                inc     bp
                inc     bp
                cmp     al, 2
                jc      short nan2
                mov     bl, PRB
                jz      short popda
                mov     A, ch                   ;pop af
                mov     F, cl
                ret
nan2            shl     al, 1
                add     bx, ax
popda           mov     [bx], cx
                ret
nnhllh          shr     al, 1                   ;c9,d9,e9,f9 > 00 40 80 c0
                jc      short nnhllhh
                jz      short _ret
        ;;JP (HL)  ;OP E9
                sub     dh, 6
                mov     bl, PRB
                mov     si, [bx]
                ret
        ;;RET c/Nc  ;OPS C0,C8,D0,D8,E0,E8,F0,F8 *
retnc           sub     dh, 5
                mov     bx, flcmp
                shr     al, 1
                xlat      
                jnc     short sisi
                test    F, al
                jz      short nore
                jnz     short sire
sisi            test    F, al
                jnz     short nore
sire            add     dh, 6
        ;;RET  ;OP C9 *
_ret            mov     si, [es:bp] 
                inc     bp
                inc     bp
nore            ret
nnhllhh         jnz     short lsphl             ;D9,F9 > 00 80
        ;;EXX  ;OP D9 *"EXX" BC DE HL
                sub     dh, 6
                mov     cl, 3
loo3            mov     ax, [bx]
                xor     bl, 8
                xchg    ax, [bx]
                xor     bl, 8
                mov     [bx], ax
                add     bl, 2
                loop    loo3
                ret
        ;;LD SP,HL    ;OP F9 *
lsphl           sub     dh, 4
                mov     bl, PRB
                mov     bp, [bx]
                ret
nnhh            shr     al, 1                   ;c3,c7,cb,cf,d....,e....,f.......
                jnc     short nnhhl
        ;;RST XX  ;OP C7,CF,D7,DF,E7,EF,F7,FF *"RST" XX= 00 08 10 18 ...
                inc     dh
                shl     al, 3
                dec     bp
                dec     bp
                xchg    si, ax
                jmp     esbp
opoc            mov     al, RD
                rol     al, 1
                add     al, 2
                ror     al, 1
                mov     RD, al
nicr            db      $26                     ;ch=0 hl ch=1 ix ch=2 iy
                lodsb
                mov     bh, al                  ;eto e muy complicao
                mov     ah, 1
                add     al, 2     
                and     al, 111b                ;hl a b c d e h l
                jnz     short des0
                add     dh, 7
                mov     ch, 1                   ;simulamos que es un prefijo
des0            xor     al, 1                   ;a hl c b e d l h
                xchg    bx, ax
                shr     ax, 6                   ;ah 0-3 opcode ; al 0-8 modo
                shr     al, 5
                or      ah, ah
                jnz     short rote
                push    bx                      ;rotaciones  00-3f
                mov     bx, rotemo
                cmp     al, 6                   ;sll raro undocumentado
                jnz     short unor
                mov     F, 1
unor            xlat                            ;al opcode instr rotar
                pop     bx
                or      ch, ch                  ;comprobar si hay prefijo
                jnz     short ixiy
                mov     [rtad+1], al
                shr     F, 1
rtad            rcl     byte [bx], 1
                mov     al, [bx]
tsig            lahf
                and     ax, 0000000110101000b
                or      al, ah
                mov     F, al
                mov     al, [bx]
                and     al, al
                lahf
                and     ah, 01000100b
                or      F, ah
                ret

nnhhl           shr     al, 1                   ;C3,CB,D3,DB,E3,EB,F3,FB @NNNNSS
                jnc     short nnhhll
                shr     al, 1                   ;cb,db,eb,fb  00 40 80 c0
                jc      short nnhhlhh
                jnz     short exdhl             ;cb,eb
        ;;CB PREFIX
                add     dh, 4
                mov     bl, PRB                 ;OP CB PREFIJO CB
                mov     di, [bx]                ;ch=0;modo de entrada normal (solo 1 operacion)
                cmp     bl, $06
                jz      short opoc
                add     dh, 8
                mov     ch, 1                   ;modo de entrada con prefijo (2 operaciones)
                db      $26
                lodsb
                cbw
                add     di, ax                  ;;;;;;;;;;;;arreglar todo esto
                jmp     nicr

ixiy            sub     al, 2
                mov     [rtxy+2], al
                shr     F, 1
rtxy            rcl     byte [es:di], 1
                mov     al, [es:di]
                mov     [bx], al
                jmp     tsig
rote            mov     cl, 1
                xchg    cx, ax
                shl     al, cl
                dec     ch                      ;comparaciones de bits 40-7f
                jnz     short bitc
                sub     dh, 3
                or      ah, ah
                jz      short ixy1+1            ;si normal cojo de ds:bx
                mov     bx, di                  ;si prefijo cojo de es:di
ixy1            test    al, [es:bx]             ;;;nuevo
                jnz     short bitun
                and     F, 11111101b            ;n a 0
                or      F, 01010000b            ;h z a 1
                jmp     finop
bitun           and     F, 10111101b            ;n z a 0
                or      F, 00010000b            ;h a 1
finop           ret
bitc            dec     ch                      ;poner 0 o 1?
                jnz     short resr
                not     al
                dec     ah                      ;prefijos?
                jnz     short ixy2
                and     [es:di], al
ixy2            and     [bx], al
                ret
resr            dec     ah                      ;puesta a 1 de bit c0-ff
                jnz     short ixy3
                or      [es:di], al             ;;bbbbb
ixy3            or      [bx], al
                ret

nnhhll          shr     al, 1                   ;C3,D3,E3,F3
                jc      short nnhhllh
                jnz     short exphl
                jmp     junp                    ;C3,E3

nnhhlhh         jz      short inan              ;DB,FB
        ;;EI   ;OP FB
                sub     dh, 6
                or      IM, 10000000b
                ret

        ;;EX DE,HL  ;OP EB *
exdhl           sub     dh, 6
                mov     bl, PRB
                mov     ax, DE
                xchg    ax, [bx]
                mov     DE, ax
                ret

        ;;IN A,(N)  ;OP DB
inan            inc     dh
                mov     ah,A
                db      $26
                lodsb
                call    pin
                mov     A, al
                ret
        ;;EX (SP),HL  ;OP E3 *
exphl           add     dh, 9
                mov     bl, PRB
                mov     ax, [es:bp]
                xchg    ax, [bx]
                jmp     esbp
nnhhllh         jnz     short _di               ;D3,F3
        ;;OUT (N),A  ;OP D3 *
                inc     dh
                db      $26
                lodsb
                mov     ah, al
                mov     al, A
                jmp     pout
flcmp           db      $40, 1, 4               ;,80h ojo con este truco;;;;;;no quitar de 
        ;;DI   ;OP F3 *
_di             sub     dh, 6
                and     IM, 01111111b
                ret
nnl             shr     al, 1                   ;C0-FF pares C0 C2 C4 C6 C8 CA ...
                jc      short nnlh
                shr     al, 1                   ;C0 C4 C8 CC D0 D4 D8 *
                jc      short callc
                jmp     retnc
        ;;CALL Nc NN  ;OPS C4,CC,D4,DC,E4,EC,F4,FC ;
callc           mov     bx, flcmp
                shr     al, 1
                xlat
                jnc     short zzsi
                test    F, al
                jz      short noxx
                jnz     short sizz
zzsi            test    F, al
                jnz     short noxx
sizz            add     dh, 7
        ;;CALL NN  ;OP CD
calnn           add     dh, 7
                db      $26
                lodsw
                cmp     ax, $05E7
                jz      short kkoe
                dec     bp
                dec     bp
                xchg    si, ax
                jmp     esbp
kkoe            or      al, $0ac                ;96;xchg si,ax 80h
                call    read                    ;posiciono el buffer
                push    dx                      ;guardo flags
                mov     bx, HFILE               ;cargo handle de archivo
                push    DE                      ;DE=numero de bytes a leer
                mov     dx, IX                  ;IX=posicion memoria a escribir
                push    es
                pop     ds                      ;apunto a mapa Z80
                mov     cx, 1                   ;cx=1 leo primero un byte
                mov     ah, $3F
                int     $21                     ;leo 1 byte
                pop     cx                      ;ahora cx es realmente los bytes a leer
                mov     ah, $3F                 ;repito lectura
                int     $21                     ;esta vez de cx=DE bytes
                xor     dx, dx
                push    cs
                pop     ds                      ;restauro ds
                add     IX, cx                  ;actualizo IX con bytes leídos
                and     HL, dx                  ;reseteo HL pongo carry a 0 y sign a 0
                mov     DE, dx
                mov     si, $05df               ;continuo en rutina cargadora cinta
                pop     dx                      ;recupero flag
                call    read                    ;incremento numero de bloque
                jmp     graba                   ;hago un snapshot despues de la carga
nnlh            shr     al, 1                   ;C2 C6 CA CD D2 D6 DA ..
                jc      short woper
        ;;JP Nc   ;OPS C2,CA,D2,DA,E2,EA,F2,FA  ;
                mov     bx, flcmp
                shr     al, 1
                xlat
                jnc     short xxsi
                test    F, al
                jz      short noxx
                jnz     short junp
xxsi            test    F, al
                jnz     short noxx
junp            mov     si, [es:si]             ;op c3 "jp nn"  ;4 =1
                ret
noxx            cmpsw
                ret
        ;;ADD SUB ADC SBB AND OR XOR CP A,N     ;OPS C6,CE,D6,DE,E6,EE,F6,FE *;12 =3
woper           sub     dh, 3
                dec     si
                db      $26
                lodsw
                xchg    cx, ax
                jmp     oper
        ;;"ADD,ADC,SUB,SBC,AND,XOR,OR,CP"       ;OP 80-BF
calc            shr     al, 2
                mov     cl, al
                add     ax, bx                  ;op 80-bf "add,adc,sub,sbc,and,xor,or,cp" ;62 =16
                and     al, 111b
                pushf
                xor     al, ah                  ;1
                cmp     al, 6
                jc      short mal2
                sub     al, 6
                add     al, PRB
mal2            popf
                xchg    bx, ax
                jnz     short nne7
                add     dh, 3
                call    saixd
                db      $26
nne7            mov     ch, [bx]
oper            shr     cl, 3                   ;al viene sumado a 32
                and     cl, 111b                ;si viene de woper
                mov     al, cl
                mov     bx, opcos               ;ch=numero a sumar.  cl=operacion
                xlat
                mov     [asas], al
                mov     bx, 0000101000000001b   ;carry anterior
                shl     bl, cl
                test    bh, bl
                jz      short nfla
                mov     al, F
                shr     al, 1
nfla            mov     al, A
asas            dw      $0e800                  ; oper al,ch   ;;;;;arreglar compri
                mov     A, al
                pushf                           ;flags z a o c= z h pv c ;cl operacion ;al resultado ;salida flags cambiados 
                pop     bx                      ;bl flags pc                       ;55 =14
                or      bh, bl
                and     bh, 00001100b           ;bit 3 overflow bit 2 parity
                xchg    al, bh
                and     bx, 0010100011010001b   ;flag 5 3 ya puestos los demas a 0
                or      bl, bh                  ;pongo flags filtrados
                inc     cx
                and     cl, 111b
                cmp     cl, 5
                jnc     short logi
                shr     al, 1                   ;operacion aritmetica paso overflow a pv
                jmp     mddc
logi            and     bl, 11101111b           ;pongo a 0 el bit h si se trata de oper logica
mddc            and     al, 00000100b           ;filtro pv
                or      bl, al                  ;meto el flag pv
                mov     al, 1                   ;pongo bit 0 de al a 1
                shl     al, cl
                test    al, 00011001b           ;xor,or,and,sbb,sub,adc,add,cp
                jz      short nfnn
                or      bl, 10b                 ;meto flag n
nfnn            and     al, 00100000b           ;xor,or,and,sbb,sub,adc,add,cp
                shr     al, 1
                or      al, bl                  ;bit h puesto si la operacion es and
                mov     F, al                   ;lo pongo en flags
                ret

s               shl     al, 1
                jnc     short _ss
        ;;LD R,R   ;OP 40-7F
                mov     cl, 6
                shr     al, 2
                push    ax
                add     ax, bx
                mov     bl, PRB
                and     al, 111b
                jz      short ataj
                xor     al, ah    
                cmp     bl, cl                  ;a (hl) b c d e h l
                jz      short otco
                cmp     al, cl
                jc      short otco
                sub     dh, 2
                sub     al, cl                  ; h l > 6 7
                add     al, bl
otco            xchg    ax, bx
                jmp     ehdd
ataj            add     dh, 3
                mov     cl, 8
                call    saixd                   ;46 4e 56 5e 66 6e
                db      $26
ehdd            mov     ch, [bx]
                pop     ax
                shr     al, 3                   ;en bx conservo fuente dato
                add     al, 2
                and     al, 111b
                jz      short hhhh              ;destino (hl) o (ix+d)
                xor     al, 1
                cmp     PRB, cl
                jz      short otc2
                cmp     al, cl
                jc      short otc2
                sub     al, cl
                add     al, PRB
otc2            add     di, ax
                mov     [di], ch
                ret
hhhh            add     dh, 3
                cmp     cl, 8
                jz      short halt              ;destino=(hl),origen=(hl)
                mov     al, ch
                cmp     bl, 8                   ;destino=(ix+d),origen =ixh/ixl
                push    depu
                jc      short saixd
                salc
                and     bl, bh
                add     bl, cl
                xlat
saixd           mov     bl, PRB
                cmp     bl, 6
                mov     bx, [bx]
                jz      short inpx
                add     dh, 8
                push    ax
                db      $26
                lodsb
                cbw
                add     bx, ax
                pop     ax
inpx            ret
_ss             shr     al, 3                   ;00 01 02 03 04
                jnc     short ssl
                jmp     ssh

depu            mov     di, bx
esdb            cmp     di, $4000               ;lo puedo quitar luego
                jc      short nst1
                stosb
nst1            ret
halt            sub     dh,6
                dec     si                      ;op 76 halt      ;4 =1
                ret

ssl             shr     al,1   ;00 02 04 06 08
                jnc     short ssll
                jmp     sslh
ssll            shr     al, 1                   ;00 04 08 0c 10
                jc      short incru
                shr     al, 1                   ;00 08 10 18 20 28 30 38
                jc      short sslllh
                shr     al, 1                   ;00 10 20 30
                jc      short ssllllh
                jz      short _nop
        ;;JR NZ,dis ;OP 20
                add     dh, 3
                test    F, 01000000b
ajmp            jz      short jump
inre            inc     si
_nop            ret
ssllllh         jz      short djnz
        ;;JR NC,dis ;OP 30
                adc     dh, bl
                test    F, 00000001b
                jmp     ajmp
        ;;djnz (loop)  ;op 10
djnz            add     dh, 4
                dec     B
                jz      short inre
        ;;jp dis (jmp) ;op 18 "jmp"
jump            add     dh, 5
                db      $26
                lodsb
                cbw
                add     si, ax
                ret
sslllh          adc     dh, bl
                shr     al, 1                   ;08 18 28 38
                jc      short sslllhh
                jz      short exaf              ;08 28
        ;;JM NC (JS)  ;OP 28
                test    F, 01000000b
bjmp            jnz     short jump
                jz      short inre
        ;;EX AF,AF'  ;OP 08 "EX AF,AF'"
exaf            sub     dh, 3
                mov     ah, A
                mov     al, F
                xchg    ax, [di+8]
                mov     A, ah
                mov     F, al
                ret
sslllhh         jz     short jump               ;18 38
        ;;JP NC (JC/JNC) ;OP 38
                test    F, 00000001b
                jmp     bjmp
        ;;INC/DEC B,C,D,E,A,(HL)                ;04,0C,14,1C,24,2C,34,3C
decru           mov     cl, bl
incru           and     F, bh
                or      F, cl
                shl     cl, cl
                or      cl, 111b
                mov     [inhl+1], cl
                add     bx, ax
                and     bl, 111b
                jnz     short hlsf
                add     dh,7                    ;34 35
                call    saixd
                push    es
                pop     ds
                jmp     inhl
hlsf            xor     bl, bh
                cmp     bl, 6
                jc      short inhl
                inc     dh
                sub     bl, 6
                add     bl, PRB
inhl            inc     byte [bx]
                mov     bl, [bx]
                push    cs
                pop     ds
                lahf
                jno     short osnv
                or      F, 100b
osnv            and     ah, 11010000b
                or      F, ah
                and     bl, 00101000b
                or      F, bl
                ret
sslh            shr     al, 1                   ;02 06 0a 0e 12
                jnc     short sslhl
        ;;LD X,N  ;X=B,C,D,E,H,L,X,A            ;OP 06,0E,16,1E,26,2E,XX,3E
                adc     dh, bl
                add     ax, bx
                and     al, 111b
                jz      short ldhln
                xor     al, ah
                cmp     al, 6
                jc      short malo
                sub     dh, bl
                sub     al, 6
                add     al, PRB
malo            xchg    bx, ax
                db      $26
                lodsb
                mov     [bx], al
                ret
sslhl           shr     al, 1                   ;02 0a 12 1a
                jc      short sslhlh
                cmp     al, 2                   ;02 12 22 32
                jnc     short d232
        ;;LD (BC/DE),A                          ;OPS 02,12
                adc     dh, bl
                add     al, al
                add     bx, ax
                mov     al, A
                mov     di, [bx]
                jmp     tesd
d232            jnz     short ldnna
        ;;LD (NN),HL   ;OP 22
                mov     bl, PRB
                mov     ax, [bx]
ldim            add     dh, 12
                xchg    di, ax
                db      $26
                lodsw
                cmp     ah, 40h
                xchg    di, ax
                jc      short nst0
                stosw
nst0            ret
        ;;LD (NN),A  ;OP 32
ldnna           add     dh, 9
                db      $26
                lodsw
                mov     di, [di]
                xchg    ax, di
tesd            jmp     sdbe
sslhlh          cmp     al, 2                   ;0a 1a 2a 3a
                jnc     short da3a
        ;;LD A,(BC/DE)  ;OPS 0A,1A
                adc     dh, bl
                add     al, al
                add     bx, ax
                mov     bx, [bx]
                mov     al, [es:bx]
                mov     A, al
                ret
da3a            jnz     short ldann
        ;;LD HL,(NN) ;OP 2A
                mov     bl, PRB
ldix            add     dh, 12
                db      $26
                lodsw
                xchg    di, ax
                mov     ax, [es:di]
                mov     [bx], ax
                ret
        ;;LD A,(NN)  ;OP 3A
ldann           add     dh, 9
                db      $26
                lodsw
                xchg    ax, bx
                mov     al, [es:bx]
                mov     A, al
                ret
        ;;LD (HL),N                             ;OP 36
ldhln           add     dh, 3
                call    saixd                   ;;;;me falta un p.ciclo
                mov     di, bx
                db      $26
                lodsb
sdbe            jmp     esdb
ssh             shr     al, 1                   ;01 03 05 07 ...
                jc      short sshh
                shr     al, 1                   ;01 05 09 0d 11 ...
                jnc     short sshll
                jmp     decru
sshll           shr     al, 1                   ;01 09 11 19...
                jc      short ahlss
        ;;LD XX,NN ;XX=BC,DE,HL,SP              ;01 11 21 31
                add     dh, 6
                cmp     al, 2
                jnz     short cnti
                mov     bl, PRB
                jz      short d222
cnti            jc      short nlds
                db      $26  ; op 31 "ld sp,nn"
                lodsw
                xchg    bp, ax
                ret
nlds            add     al, al                  ;ops 01,11,21 "ld rr,nn"  ;19        +1
                add     bx, ax
d222            db      $26
                lodsw
                mov     [bx], ax
                ret
        ;;ADD RR,NN  ;OPS 09,19,29,39
ahlss           add     dh, 7
                cmp     al, 2
                jc      short adhl
                jnz     short ahlsp
                mov     bl, PRB
                jmp     d244
        ;;ADD HL,BC/DE  ;09 19
adhl            add     al, al
                add     bx, ax
d244            mov     ax, [bx]
                db      $3d
ahlsp           mov     ax, bp                  ;39
        @suma:  mov     bl, PRB
                and     F, 11000100b            ; n a cero por ahora
                add     [bx], ax
                lahf
                mov     al, [bx+1]
                and     ax, 0000000100101000b
                or      al, ah
                or      F, al
                ret
        ;;DEC B,C,D,E,A,(HL)                    ;05 0D 15 1D 25 2D 35 3D;;;;;;;;CONJUNTAR CON EL INCREMENTO
sshh            shr     al, 1                   ;03 07 0b 0f 13 ...
                jc      short sshhh
                add     dh, bl
                cmp     al, 6                   ;03 0b 13 1b 23 2b 33 3b
                jnc     short splh
        ;;INC/DEC BC/DE/HL                      ;OPS 03,0B,13,1B,23 2B
                shr     al, 1
                rcl     cl, 4
                or      cl, 7
                mov     [hl01+1], cl
                add     al, al
                add     ax, bx
                cmp     al, 6
                mov     bl, PRB
                jz      short hl01
                xchg    bx, ax
hl01            inc     word [bx]
                ret
splh            jnz     short decsp
        ;;INC SP                                ;OP 33
                inc     bp
                inc     bp
        ;;DEC SP                                ;OP 3B
decsp           dec     bp
                ret
sshhh           cmp     al, 4                   ;07,0f,17,1f,27,2f,37,3f,47,4f
                jnc     short shhhl
        ;;RLCA RRCA RLA RRA                     ;OP 07,0F,17,1F
                shl     al, 3
                or      al, 5
                mov     [mag2+1], al
                and     F, 11000101b
                shr     F, 1
mag2            rol     A, 1
                rcl     F, 1
                mov     al, A
                and     al, 00101000b
                or      F, al
                ret
shhhl           sub     al, 5                   ;27 2f 37 3f 
                jnc     short no27
        ;;DAA   ;OP 27
                mov     al, A
                mov     ah, F
                test    ah, 2
                jnz     short daas
                sahf
                daa
                lahf
                mov     A, al
                mov     F, ah
                ret
daas            sahf
                das
                lahf
                mov     A, al
                mov     F, ah
                ret
no27            jnz     short tscf
        ;;CPL                                   ;OP 2F
                not     A
                mov     al, A
                and     al, 00101000b
                or      al, 00010010b
                and     F, 11000101b
                or      F, al
                ret
        ;;SCF/CCF                               ;OP 37 3F   ;1 2
tscf            and     F, 11000101b            ;h n a 0
                mov     cl, A
                and     cl, 00101000b
                dec     ax
                jnz     short ccf
scf             or      F, bh
                or      F, cl
                ret
ccf             test    F, bh
                jz      short scf
                mov     bh, 00010000b           ;h a 1
                dec     dx                      ;;chapuza   ;c a 0
                jmp     scf

NewInt9         push    ax                      ;guardo ax y cx
                push    cx
                in      al, $60                 ;leo tecla
                mov     ah, 1
                cmp     al, $0e0                ;miro si es extendida
                jnz     short next
                mov     EXTEN, ah               ;pongo a 1 el bit extendida
                jmp     fins                    ;acabo
next            cmp     EXTEN, ah               ;miro si antes he recibido caracter extend
                cbw
                jnz     short aext
                cmp     al, $2a                 ;si lo he recibido comparo con tecla ??
                jz      short fins              ;acabo
aext            mov     EXTEN, ah               ;reseteo exten
                mov     cx, $010a               ;banco 8
                shl     ax, 1                   ;pongo codigo make en ah
                shr     al, 1
                sub     al, 1                   ;0-2
                jz      short dpaf              ;escape?
                sub     al, 58-1
                cmp     al, 5
                jc      short dpaf
                dec     cx
                sub     al, 63-58
                cmp     al, 5
                jc      short dpaf
                dec     cx
                sub     al, $1c-63
                cmp     al, 1
                jz      short dpaf
                sub     al, $2f-$1b             ;2b-30
                cmp     al, 3                   ;30-32
                jc      short dpne
                sub     al, 9
                jz      short dpaf              ;39
                dec     cx
                sub     al, $1c-$39             ;1c
                jz      short dpaf
                sub     al, 7                   ;23
                cmp     al, 4                   ;23-26
                jc      short dpne
                dec     cx
                sub     al, $15-$23             ;15
                cmp     al, 5                   ;15-19
                jc      short dpne
                dec     cx
                sub     al, 7-$15               ;7
                cmp     al, 5                   ;7-b
                jnc     short sipo
dpne            not     al
                add     al, 5
dpaf            xchg    ax, cx
                rol     ah, cl
                push    bx
                mov     bx, teclado-1
                add     bl, al
                mov     al, [cs:bx]
                shr     ch, 1
                jc      short make
                not     ah
                and     al, ah
                db      $3d
make            or      al, ah
                mov     [cs:bx], al
                pop     bx
fins            mov     al, $20
                out     $20, al
                pop     cx
                pop     ax
                iret
sipo            dec     cx
                sub     al, 2-7                 ;2
                cmp     al, 5                   ;2-6
                jc      short dpaf
                dec     cx
                sub     al, $10-2               ;10
                cmp     al, 5                   ;10-14
                jc      short dpaf
                dec     cx
                sub     al, $1e-$10             ;1e
                cmp     al, 5                   ;1e-23
                jc      short dpaf
                dec     cx
                sub     al, $2a-$1e             ;2a
                jz      short dpaf
                dec     ax
                cmp     al, 5                   ;2b-2f
                jc      short dpaf
                dec     cx
                sub     al, 72-$2b              ;72 derecha
                jz      short ari
                sub     al, 3
                jz      short izq
                sub     al, 2
                jz      short dpaf
                sub     al, 3
                jz      short aba
                sub     al, 15-80
                jnz     short fins
                inc     ax
ari             inc     ax
aba             inc     ax
izq             inc     ax
                jmp     dpaf

%if JOYST
leejo           push    dx
                mov     dx, $0201
                out     dx, al
                xor     cx, cx
                xor     bx, bx
ota             in      al, dx
                test    al, 1
                jz      short ppa
                inc     cx
                jz      short njosa
ppa             test    al, 2
                jz      short ppb
                inc     bx
ppb             test    al, 3
                jnz     short ota
                shr     al, 5
                mov     [desjo+1], ah
njosa           pop     dx
                ret
emjo            jc      short llt
                not     al
                and     [joystik], al
                ret
llt             or      [joystik], al
                ret
        joystik db      255
%endif
kempsto         db      255
teclado         db      255, 255, 255, 255, 255, 255, 255, 255
funcios         dw      $0ffff
%if JOYST
tecac           times   12  db  255
%else
tecac           times   11  db  255
%endif

%if SOUNDB
OWN_IRQ         push    ax
                push    dx
adbase          mov     dx, 0
                in      al, dx
trik            mov     ax, 0
                mov     [cs:aqui+1], al
                cmp     PUNTEG1, 3
                jnc     short dos
                mov     ax, 624
dos             mov     PUNTEG, ax
                mov     al, $20
                out     $20, al                 ;acknowledge hardware interrupt
                pop     dx
                pop     ax
                iret
waitw           in      al, dx
                or      al, al
                jns     short endl
                loop    waitw
endl            ret
%endif

presen          db 24,24,24,24,0,$10F-$70,' BACTERIA 2.0'
%if SOUNDB
                db 'A'
%else
                db 'B'
%endif
                db '               ',0,$104-$0f,220,219,0,$4e-4,220,219,0,$0e2-$4e,220,219
                db 0,$129-$0e2,220,219,0,$90-$29,220,219,219,24,24
                db 219,0,$0f0-$70,'  The smallest emulator in the world  ',219,24,24
                db 219,0,$0f0-$70,'    Made in assembly language by:     ',219,24,24
                db 219,0,$0b0-$70,'     Antonio Jos',$82,' Villena Godoy       ',219,24,24
                db 219,0,$0f0-$70,'        espineter@yahoo.com           ',219,24,24
                times 40  db  223
                db 24,24
                db '     ',0,$0f2-$70,223,223,223,223,223,223,0,$17e-$0f2,' CP 29770, Torrox ',0,$0e4-$7e,223,223,223,223,223,223,24,24
                db '          ',0,$72-$70,223,223,223,223,223,223,0,$74-$72,'  MALAGA, Ap 125  ',223,223,223,223,223,223
                db 24,24,24,24,24,'     ',0,$100-$70

cade            db 'Not found '
nrom            db '48.ROM',0,36

colores         db  00,00,00
                db  00,00,40
                db  56,00,00
                db  56,00,44
                db  00,52,00
                db  00,52,52
                db  52,52,00
                db  48,50,48
                db  00,00,00
                db  00,00,44
                db  60,00,00
                db  62,00,56
                db  00,60,00
                db  00,60,62
                db  62,60,00
                db  62,60,62
                db  12,34,56     ;color de grabación

rotemo          db      $07, $0f, $17, $1f, $27, $3f, $17, $2f
opcos           db      $00, $10, $28, $18, $20, $30, $08, $38

execu           jnz     short tetea
exf4            push    di                      ;F4
                mov     di, $4000
                mov     si, juego
                mov     cx, $6000               ;;;(16384*3/256)/2
                rep     movsw
                mov     di, $100
                mov     cl, TOTREG
tras            lodsb
                mov     [di], al
                inc     di
                loop    tras
                pop     di
                mov     si, SNAPSI
                mov     bp, SNAPBP
                mov     F, SNAPF
rstp            mov     PFAIR, cx               ;ecx los dos
                mov     TVACIO, cx
                xchg    cl, TMTEC
                ret
tetea           loop    atde

graba           mov     SNAPSI, si              ;F3
                mov     SNAPBP, bp
                mov     SNAPF, F
                xor     cx, cx
                pusha
                mov     si, $4000
                mov     di, juego
bklt            mov     al, [es:si]
                mov     [di], al
                inc     di
                inc     si
                jnz     short bklt
                mov     si, $100
                mov     cl, TOTREG
o3ld            lodsb
                mov     [di], al
                inc     di
                loop    o3ld
                popa
                jmp     rstp

atde:                                           ;F2
%if SOUNDB
                dec     cx
%else
                loop    desbe
                mov     byte [cero], $3c
%endif
desbe           loop    ngrab
                pusha                                   ;F1
%if SOUNDB
                mov     si, bufso
                mov     ch, 1400/256
okek            mov     [si], al
                inc     si
                loop    okek
%endif
rree            in      al, $60
                test    al, $80 ;;cmp      al,59+80h
                jz      short rree
pupa            in      al, $60
                test    al, $80
                jnz     short pupa
                popa

ngrab           loop    nses
ksalir          mov     si, presen
irq9off         mov     dx, $03c8               ;escape
irq9seg         push    $04bf
                pop     ds
                mov     ax, $2509
                int     $21
                aad     $0f2
                int     $10
                xor     bx, bx                  ;kitar el blink
                mov     ah, $10
                int     $10
                push    cs
                pop     ds
%if SOUNDB
                in      al, $21
pico            or      al, 00010010b
                out     $21, al
%endif
                xor     di, di
prn             push    $0b800 ;0b7f0h
                pop     es
                mov     cx, 20
                mov     ax, $7000
                db      $0f3
st              stosw
rp              lodsb
                cmp     al, 24
                jz      short prn
                jnc     short st
                lodsb
                add     ah, al
                jnz     short rp
                mov     ah, 2
                mov     dh, $0a
                int     $10
                mov     ah, $4c
                int     $21
muel            pusha
muul            mov     di, $16d4 ;en reclaim rutine
                mov     bp, di
                xchg    al, ah
                stosw
                mov     ax, 201
papat           push    ax
                call    panta
                pop     ax
                dec     ax
                jnz     short papat
                mov     ah, $13
                cwd
                mov     bh, 0
                inc     cx
                inc     cx
                int     $10
lalo            loop    lalo
                dec     al
                jnz     short lalo
                popa
atat            ret
nses            loop    npla
                xor     si, si                  ;F9
npla            stc
                loop    nres
                db      $0a9                    ;test ax,.... c=0  ;F8
nres            loop    nante
read            pusha                           ;F7
                salc
                js      short stlt
                cmc
stlt            cbw
numebl          adc     al, 0
                js      short luka
                mov     di, ax
                xchg    ax, si
                mov     ax, $4200
                mov     bx, HFILE
                cwd
                xor     cx, cx
                int     $21
faaa            mov     ah, $3f
                mov     dx, longt+1
                inc     cx
                inc     cx
                int     $21
                cmp     al, 2
                jc      short fnkt
                dec     si
                js      short fnkr
                mov     ax, $4201
longt           mov     dx, longt+1
                xor     cx, cx
                int     $21
                jmp     faaa
fnkr            xchg    ax, di
fnkt            mov     [numebl+1], al
                aam     10
                dec     ax
luka            add     ax, '00'+1
                jmp     muul
nante           loop    ndepu
                inc     cx                      ;F6
                mov     bp, cx
                mov     bx, PFAIR               ;leo puntero de grabación
                mov     ah, $23                 ;F6 es lo último que me desactiva
                mov     [bx+fair], ax           ;guardo en zona
ndepu           loop    atat                    ;F5
                push    PFAIR
                mov     cl, TOTNOP              ;ahora pongo nop iniciales
                push    di
ksxk            mov     [di], ch
                inc     di
                loop    ksxk
oche            mov     dx, longt+1             ;dx=asciz filename
                mov     si, dx                  ;si=dx para buscar el punto
rsra            lodsb
                cmp     al, '.'
                jnz     short rsra
                mov     word [si], 'CO'         ;cambio el tap o sna por extension com
                mov     byte [si+2], 'M'
                mov     ah, $3c
                mov     [mofe],ah
                mov     word [mofe+3], exf4-dlda  ;sustituyo el ldsna por f4
                int     $21
                xchg    ax, bx                  ;pongo handle en bx
                mov     cl, ldsna-guachi
                push    es                      ;para hacer un salto retf pongo segmento en pila
                push    di
                mov     si, guachi
                rep     movsb                   ;muevo el compresor, desde guachi hasta ldsna
                push    ds
                pop     es                      ;ahora es apunta a zona emulador
                retf
guachi          mov     di, npla
                mov     cx, juego-npla          ;cx=borrar desde npla hasta juego
                mov     al, $0c3                ;mediante ret
                rep     stosb                   ;borro
                pop     dx
                pop     si
                mov     cx, fair-start
                dec     bp
                jnz     short nocm
                lodsw
                add     cx, si
%if JOYST
                xor     word [mvee],$50+((repro-pmve)^12)*$100
%else
                xor     word [mvee],$50+((repro-pmve)^11)*$100
%endif
                mov     ax, [fair]
                inc     ax
                mov     [iniv+1], ax
nocm            mov     ah, $40
                int     $21
                push    ds
                push    ksalir
                retf

ldsna           mov     si, $3fe5
                db      $26
                lodsb
                mov     I, al
                db      $26
                lodsw
                mov     HLp, ax
                db      $26
                lodsw
                mov     DEp, ax
                db      $26
                lodsw
                mov     BCp, ax
                db      $26
                lodsw
                mov     AFp, ax
                db      $26
                lodsw
                mov     HL, ax
                db      $26
                lodsw
                mov     DE, ax
                db      $26
                lodsw
                mov     BC, ax
                db      $26
                lodsw
                mov     IY, ax
                db      $26
                lodsw
                mov     IX, ax
                db      $26
                lodsb
                shl     al, 5
                and     al, $80
                mov     IM, al
                db      $26
                lodsb
                mov     R, al
                db      $26
                lodsw
                mov     F, al
                mov     A, ah
                db      $26
                lodsw
                xchg    bp, ax
                db      $26
                lodsb
                shr     al, 1
                or      IM, al
                db      $26
                lodsb
                mov     POR, al
                mov     si, [es:bp]
                inc     bp
                inc     bp
                ret
juego:
