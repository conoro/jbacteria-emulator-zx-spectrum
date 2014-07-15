.data
.global st, sttap, stint, counter, mem, v, intr, tap, pc, start, endd
.global sp, mp, t, u, ff, ff_, fa, fa_, fb, fb_, fr, fr_    
.global a, c, b, e, d, l, h, a_, c_, b_, e_, d_, l_, h_
.global xl, xh, yl, yh, i, r, rs, prefix, iff, im, w, halted

st:     .quad   0
sttap:  .quad   0
stint:  .quad   0
counter:.quad   100000000
mem:    .word   0
v:      .word   0
intr:   .word   0
tap:    .word   0
ff:     .short  0
pc:     .short  0
start:  .short  0
xl:     .byte   0
xh:     .byte   0
endd:   .short  0
mp:     .short  0
l:      .byte   0
h:      .byte   0
t:      .short  0
u:      .short  0
ff_:    .short  0
fa:     .short  0
sp:     .short  0
fa_:    .short  0
fb:     .short  0
c:      .byte   0
b:      .byte   0
fb_:    .short  0
fr:     .short  0
e:      .byte   0
d:      .byte   0
fr_:    .short  0
prefix: .byte   0
rs:     .byte   0
r:      .byte   0
a:      .byte   0
a_:     .byte   0
c_:     .byte   0
b_:     .byte   0
e_:     .byte   0
d_:     .byte   0
l_:     .byte   0
h_:     .byte   0
yl:     .byte   0
yh:     .byte   0
i:      .byte   0
iff:    .byte   0
im:     .byte   0
w:      .byte   0
halted: .byte   0

        .equ    ost,      0
        .equ    osttap,   8+ost
        .equ    ostint,   8+osttap
        .equ    ocounter, 8+ostint
        .equ    omem,     8+ocounter
        .equ    ov,       4+omem
        .equ    ointr,    4+ov
        .equ    otap,     4+ointr
        .equ    off,      4+otap
        .equ    opc,      2+off
        .equ    ostart,   2+opc
        .equ    oxl,      2+ostart
        .equ    oxh,      1+oxl
        .equ    oendd,    1+oxh
        .equ    omp,      2+oendd
        .equ    ol,       2+omp
        .equ    oh,       1+ol
        .equ    ot,       1+oh
        .equ    ou,       2+ot
        .equ    off_,     2+ou
        .equ    ofa,      2+off_
        .equ    osp,      2+ofa
        .equ    ofa_,     2+osp
        .equ    ofb,      2+ofa_
        .equ    oc,       2+ofb
        .equ    ob,       1+oc
        .equ    ofb_,     1+ob
        .equ    ofr,      2+ofb_
        .equ    oe,       2+ofr
        .equ    od,       1+oe
        .equ    ofr_,     1+od
        .equ    oprefix,  2+ofr_
        .equ    ors,      1+oprefix
        .equ    or,       1+ors
        .equ    oa,       1+or
        .equ    oa_,      1+oa
        .equ    oc_,      1+oa_
        .equ    ob_,      1+oc_
        .equ    oe_,      1+ob_
        .equ    od_,      1+oe_
        .equ    ol_,      1+od_
        .equ    oh_,      1+ol_
        .equ    oyl,      1+oh_
        .equ    oyh,      1+oyl
        .equ    oi,       1+oyh
        .equ    oiff,     1+oi
        .equ    oim,      1+oiff
        .equ    ow,       1+oim
        .equ    ohalted,  1+ow

        punt    .req      r0
        mem     .req      r1
        stlo    .req      r2
        pcff    .req      r3
        spfa    .req      r4
        bcfb    .req      r5
        defr    .req      r6
        hlmp    .req      r7
        arvpref .req      r8
        ixstart .req      r9
        iy      .req      r12

      .macro    TIME  cycles
        adds    stlo, stlo, #\cycles
        blcs    insth
      .endm

      .macro    PREFIX0
        bic     arvpref, #0xff
        b       salida
      .endm

      .macro    PREFIX1
        bic     arvpref, #0xff
        add     arvpref, arvpref, #1
        b       salida
      .endm

      .macro    PREFIX2
        orr     arvpref, #0xff
        b       salida
      .endm

      .macro    LDRRIM  regis
        TIME    10
        ldr     lr, [mem, pcff, lsr #16]
        add     pcff, #0x00020000
        pkhbt   \regis, \regis, lr, lsl #16
      .endm

      .macro    LDXX    dst, ofd, src, ofs
        TIME    4
        bic     \dst, #0x00ff0000 << \ofd
        orr     \dst, \src, ror #\ofs
      .endm

      .macro    INC     regis, ofs
        TIME    4
        bic     spfa, #0x000000ff
        orr     spfa, \regis, lsr #16+\ofs
        bic     bcfb, #0x000000ff
        add     bcfb, bcfb, #1
        add     lr, spfa, bcfb
        bic     \regis, #0x00ff0000 << \ofs
        orr     \regis, \regis, lr, lsl #16+\ofs
        pkhtb   defr, defr, lr
        and     r11, pcff, #0x00000100
        uxtab   lr, r11, lr
        pkhtb   pcff, pcff, lr
      .endm

      .macro    DEC     regis, ofs
        TIME    4
        bic     spfa, #0x000000ff
        orr     spfa, \regis, lsr #16+\ofs
        orr     bcfb, bcfb, #0xff
        add     lr, spfa, bcfb
        bic     \regis, #0x00ff0000 << \ofs
        orr     \regis, \regis, lr, lsl #16+\ofs
        pkhtb   defr, defr, lr
        and     r11, pcff, #0x00000100
        uxtab   lr, r11, lr
        pkhtb   pcff, pcff, lr
      .endm

      .macro    INCW    regis
        TIME    6
        add     \regis, #0x00010000
      .endm

      .macro    DECW    regis
        TIME    6
        sub     \regis, #0x00010000
      .endm

      .macro    CALLC
        beq     callnn
        TIME    10
        add     pcff, #0x00020000
        PREFIX0
      .endm

      .macro    CALLCI
        bne     callnn
        TIME    10
        add     pcff, #0x00020000
        PREFIX0
      .endm

      .macro    LDRP    src, dst, ofs
        TIME    7
        mov     r11, \src, lsr #16
        ldrb    lr, [mem, r11]
        bic     \dst, #0x00ff0000 << \ofs
        orr     \dst, \dst, lr, lsl #16+\ofs
        add     r11, #1 
        pkhtb   hlmp, hlmp, r11
      .endm

      .macro    RET
        ldr     lr, [mem, spfa, lsr #16]
        add     spfa, #0x00020000
        pkhtb   hlmp, hlmp, lr
        pkhbt   pcff, pcff, lr, lsl #16
        PREFIX0
      .endm

      .macro    JRC
        beq     jrnn
        TIME    7
        add     pcff, #0x00010000
        PREFIX0
      .endm

      .macro    JRCI
        bne     jrnn
        TIME    7
        add     pcff, #0x00010000
        PREFIX0
      .endm

      .macro    PUS     regis
        TIME    11
        sub     spfa, #0x00020000
        mov     lr, spfa, lsr #16
        mov     r11, \regis, lsr #16
        strh    r11, [mem, lr]
      .endm

/*      r0      punt
        r1      mem
        r2      stlo
        r3      pc | ff
        r4      sp | fa
        r5      bc | fb
        r6      de | fr
        r7      hl | mp
        r8      ar | r7 iff im halted : prefix
        r9      ix | start
        r12     iy |
*/

.text
.global execute
execute:push    {r4-r12, lr}

        ldr     punt, _st
        @ cambiar todo esto por un ldm
        ldr     mem, [punt, #omem]
        ldr     stlo, [punt, #ost]
        ldr     pcff, [punt, #off]    @ pc | ff
        ldr     spfa, [punt, #ofa]    @ sp | fa
        ldr     bcfb, [punt, #ofb]    @ bc | fb
        ldr     defr, [punt, #ofr]    @ de | fr
        ldr     hlmp, [punt, #omp]    @ hl | mp
        ldr     arvpref, [punt, #oprefix] @ ar | r7 iff im halted : prefix
        ldr     ixstart, [punt, #ostart]  @ ix | start
        ldr     iy, [punt, #oyl-2]    @ iy |


exec1:  ldrh    lr, [punt, #ostart]
        cmp     lr, pcff, lsr #16
        bne     exec2
exec2:

        mov     lr, #0x00010000
        uadd8   arvpref, arvpref, lr

        ldrb    lr, [mem, pcff, lsr #16]
        add     pcff, #0x00010000
        ldr     pc, [pc, lr, lsl #2]
_st:    .word   st
        .word   nop           @ 00 NOP
        .word   ldbcnn        @ 01 LD BC,nn
        .word   nop           @ 02 LD (BC),A
        .word   incbc         @ 03 INC BC
        .word   incb          @ 04 INC B
        .word   decb          @ 05 DEC B
        .word   nop           @ 06 LD B,n
        .word   nop           @ 07 RLCA
        .word   nop           @ 08 EX AF,AF
        .word   nop           @ 09 ADD HL,BC
        .word   ldabc         @ 0a LD A,(BC)
        .word   decbc         @ 0b DEC BC
        .word   incc          @ 0c INC C
        .word   decc          @ 0d DEC C
        .word   nop           @ 0e LD C,n
        .word   nop           @ 0f RRCA
        .word   nop           @ 10 DJNZ
        .word   lddenn        @ 11 LD DE,nn
        .word   nop           @ 12 LD (DE),A
        .word   incde         @ 13 INC DE
        .word   incd          @ 14 INC D
        .word   decd          @ 15 DEC D
        .word   nop           @ 16 LD D,n
        .word   nop           @ 17 RLA
        .word   jr            @ 18 JR
        .word   nop           @ 19 ADD HL,DE
        .word   ldade         @ 1a LD A,(DE)
        .word   decde         @ 1b DEC DE
        .word   ince          @ 1c INC E
        .word   dece          @ 1d DEC E
        .word   nop           @ 1e LD E,n
        .word   nop           @ 1f RRA
        .word   jrnz          @ 20 JR NZ,s8
        .word   ldxxnn        @ 21 LD HL,nn
        .word   nop           @ 22 LD (nn),HL
        .word   inchlx        @ 23 INC HL
        .word   inchx         @ 24 INC H
        .word   dechx         @ 25 DEC H
        .word   nop           @ 26 LD H,n
        .word   nop           @ 27 DAA
        .word   jrz           @ 28 JR Z,s8
        .word   nop           @ 29 ADD HL,HL
        .word   nop           @ 2a LD HL,(nn)
        .word   dechlx        @ 2b DEC HL
        .word   inclx         @ 2c INC L
        .word   declx         @ 2d DEC L
        .word   nop           @ 2e LD L,n
        .word   nop           @ 2f CPL
        .word   jrnc          @ 30 JR NC,s8
        .word   nop           @ 31 LD SP,nn
        .word   nop           @ 32 LD (nn),A
        .word   incsp         @ 33 INC SP
        .word   nop           @ 34 INC (HL)
        .word   nop           @ 35 DEC (HL)
        .word   nop           @ 36 LD (HL),n
        .word   nop           @ 37 SCF
        .word   jrc           @ 38 JR C,s8
        .word   nop           @ 39 ADD HL,SP
        .word   nop           @ 3a LD A,(nn)
        .word   decsp         @ 3b DEC SP
        .word   inca          @ 3c INC A
        .word   deca          @ 3d DEC A
        .word   nop           @ 3e LD A,n
        .word   nop           @ 3f CCF
        .word   nop           @ 40 LD B,B
        .word   ldbc          @ 41 LD B,C
        .word   ldbd          @ 42 LD B,D
        .word   ldbe          @ 43 LD B,E
        .word   lxbh          @ 44 LD B,H
        .word   lxbl          @ 45 LD B,L
        .word   nop           @ 46 LD B,(HL)
        .word   ldba          @ 47 LD B,A
        .word   ldcb          @ 48 LD C,B
        .word   nop           @ 49 LD C,C
        .word   ldcd          @ 4a LD C,D
        .word   ldce          @ 4b LD C,E
        .word   lxch          @ 4c LD C,H
        .word   lxcl          @ 4d LD C,L
        .word   nop           @ 4e LD C,(HL)
        .word   ldca          @ 4f LD C,A
        .word   lddb          @ 50 LD D,B
        .word   lddc          @ 51 LD D,C
        .word   nop           @ 52 LD D,D
        .word   ldde          @ 53 LD D,E
        .word   lxdh          @ 54 LD D,H
        .word   lxdl          @ 55 LD D,L
        .word   nop           @ 56 LD D,(HL)
        .word   ldda          @ 57 LD D,A
        .word   ldeb          @ 58 LD E,B
        .word   ldec          @ 59 LD E,C
        .word   lded          @ 5a LD E,D
        .word   nop           @ 5b LD E,E
        .word   lxeh          @ 5c LD E,H
        .word   lxel          @ 5d LD E,L
        .word   nop           @ 5e LD E,(HL)
        .word   ldea          @ 5f LD E,A
        .word   lxhb          @ 60 LD H,B
        .word   lxhc          @ 61 LD H,C
        .word   lxhd          @ 62 LD H,D
        .word   lxhe          @ 63 LD H,E
        .word   nop           @ 64 LD H,H
        .word   lxhl          @ 65 LD H,L
        .word   nop           @ 66 LD H,(HL)
        .word   lxha          @ 67 LD H,A
        .word   lxlb          @ 68 LD L,B
        .word   lxlc          @ 69 LD L,C
        .word   lxld          @ 6a LD L,D
        .word   lxle          @ 6b LD L,E
        .word   lxlh          @ 6c LD L,H
        .word   nop           @ 6d LD L,L
        .word   nop           @ 6e LD L,(HL)
        .word   lxla          @ 6f LD L,A
        .word   nop           @ 70 LD (HL),B
        .word   nop           @ 71 LD (HL),C
        .word   nop           @ 72 LD (HL),D
        .word   nop           @ 73 LD (HL),E
        .word   nop           @ 74 LD (HL),H
        .word   nop           @ 75 LD (HL),L
        .word   nop           @ 76 HALT
        .word   nop           @ 77 LD (HL),A
        .word   ldab          @ 78 LD A,B
        .word   ldac          @ 79 LD A,C
        .word   ldad          @ 7a LD A,D
        .word   ldae          @ 7b LD A,E
        .word   lxah          @ 7c LD A,H
        .word   lxal          @ 7d LD A,L
        .word   ldahl         @ 7e LD A,(HL) @revisar
        .word   nop           @ 7f LD A,A
        .word   nop           @ 80 ADD A,B
        .word   nop           @ 81 ADD A,C
        .word   nop           @ 82 ADD A,D
        .word   nop           @ 83 ADD A,E
        .word   nop           @ 84 ADD A,H
        .word   nop           @ 85 ADD A,L
        .word   nop           @ 86 ADD A,(HL)
        .word   addaa         @ 87 ADD A,A
        .word   nop           @ 88 ADC A,B
        .word   nop           @ 89 ADC A,C
        .word   nop           @ 8a ADC A,D
        .word   nop           @ 8b ADC A,E
        .word   nop           @ 8c ADC A,H
        .word   nop           @ 8d ADC A,L
        .word   nop           @ 8e ADC A,(HL
        .word   adcaa         @ 8f ADC A,A
        .word   nop           @ 90 SUB A,B
        .word   nop           @ 91 SUB A,C
        .word   nop           @ 92 SUB A,D
        .word   nop           @ 93 SUB A,E
        .word   nop           @ 94 SUB A,H
        .word   nop           @ 95 SUB A,L
        .word   nop           @ 96 SUB A,(HL)
        .word   nop           @ 97 SUB A,A
        .word   nop           @ 98 SBC A,B
        .word   nop           @ 99 SBC A,C
        .word   nop           @ 9a SBC A,D
        .word   nop           @ 9b SBC A,E
        .word   nop           @ 9c SBC A,H
        .word   nop           @ 9d SBC A,L
        .word   nop           @ 9e SBC A,(HL)
        .word   nop           @ 9f SBC A,A
        .word   nop           @ a0 AND B
        .word   nop           @ a1 AND C
        .word   nop           @ a2 AND D
        .word   nop           @ a3 AND E
        .word   nop           @ a4 AND H
        .word   nop           @ a5 AND L
        .word   nop           @ a6 AND (HL)
        .word   nop           @ a7 AND A
        .word   nop           @ a8 XOR B
        .word   nop           @ a9 XOR C
        .word   nop           @ aa XOR D
        .word   nop           @ ab XOR E
        .word   nop           @ ac XOR H
        .word   nop           @ ad XOR L
        .word   nop           @ ae XOR (HL)
        .word   nop           @ af XOR A
        .word   nop           @ b0 OR B
        .word   nop           @ b1 OR C
        .word   nop           @ b2 OR D
        .word   nop           @ b3 OR E
        .word   nop           @ b4 OR H
        .word   nop           @ b5 OR L
        .word   nop           @ b6 OR (HL)
        .word   nop           @ b7 OR A
        .word   nop           @ b8 CP B
        .word   nop           @ b9 CP C
        .word   nop           @ ba CP D
        .word   nop           @ bb CP E
        .word   nop           @ bc CP H
        .word   nop           @ bd CP L
        .word   nop           @ be CP (HL)
        .word   nop           @ bf CP A
        .word   nop           @ c0 RET NZ
        .word   nop           @ c1 POP BC
        .word   nop           @ c2 JP NZ
        .word   nop           @ c3 JP nn
        .word   callnz        @ c4 CALL NZ
        .word   pushbc        @ c5 PUSH BC
        .word   nop           @ c6 ADD A,n
        .word   nop           @ c7 RST 0x00
        .word   nop           @ c8 RET Z
        .word   ret           @ c9 RET
        .word   nop           @ ca JP Z
        .word   nop           @ cb op cb
        .word   callz         @ cc CALL Z
        .word   callnn        @ cd CALL NN
        .word   nop           @ ce ADC A,n
        .word   nop           @ cf RST 0x08
        .word   nop           @ d0 RET NC
        .word   nop           @ d1 POP DE
        .word   nop           @ d2 JP NC
        .word   nop           @ d3 OUT (n),A
        .word   callnc        @ d4 CALL NC
        .word   pushde        @ d5 PUSH DE
        .word   nop           @ d6 SUB A,n
        .word   nop           @ d7 RST 0x10
        .word   nop           @ d8 RET C
        .word   nop           @ d9 EXX
        .word   nop           @ da JP C
        .word   nop           @ db IN A,(n)
        .word   callc         @ dc CALL C
        .word   opdd          @ dd OP dd
        .word   nop           @ de SBC A,n
        .word   nop           @ df RST 0x18
        .word   nop           @ e0 RET PO
        .word   nop           @ e1 POP HL
        .word   nop           @ e2 JP PO
        .word   nop           @ e3 EX (SP),HL
        .word   callpo        @ e4 CALL PO
        .word   pushxx        @ e5 PUSH HL
        .word   nop           @ e6 AND A,n
        .word   nop           @ e7 RST 0x20
        .word   nop           @ e8 RET PE
        .word   nop           @ e9 JP (HL)
        .word   nop           @ ea JP PE
        .word   nop           @ eb EX DE,HL
        .word   callpe        @ ec CALL PE
        .word   oped          @ ed op ed
        .word   nop           @ ee XOR A,n
        .word   nop           @ ef RST 0x28
        .word   nop           @ f0 RET P
        .word   nop           @ f1 POP AF
        .word   nop           @ f2 JP P
        .word   nop           @ f3 DI
        .word   callp         @ f4 CALL P
        .word   nop           @ f5 PUSH AF
        .word   nop           @ f6 OR A,n
        .word   nop           @ f7 RST 0x30
        .word   nop           @ f8 RET M
        .word   nop           @ f9 LD SP,HL
        .word   nop           @ fa JP M
        .word   nop           @ fb EI
        .word   callm         @ fc CALL M
        .word   opfd          @ fd op fd
        .word   nop           @ fe CP A,n
        .word   nop           @ ff RST 0x38

nop:    TIME    4
        PREFIX0

opdd:   TIME    4
        PREFIX1

opfd:   TIME    4
        PREFIX2

ldbcnn: LDRRIM  bcfb
        PREFIX0

lddenn: LDRRIM  defr
        PREFIX0

ldxxnn: movs    lr, arvpref, lsl #24
        beq     ldhlnn
        bmi     ldiynn
        LDRRIM  ixstart
        PREFIX0
ldiynn: LDRRIM  iy
        PREFIX0
ldhlnn: LDRRIM  hlmp
        PREFIX0

callnn: TIME    17
        mov     r11, pcff, lsr #16
        ldrh    lr, [mem, r11]
        add     r11, r11, #2
        pkhbt   pcff, pcff, lr, lsl #16
        pkhtb   hlmp, hlmp, lr
        sub     spfa, #0x00020000
        mov     r10, spfa, lsr #16
        strh    r11, [mem, r10]
        PREFIX0

callz:  movs    lr, defr, lsl #16
        CALLC

callnz: movs    lr, defr, lsl #16
        CALLCI

callnc: tst     pcff, #0x00000100
        CALLC

callc:  tst     pcff, #0x00000100
        CALLCI

callp:  tst     pcff, #0x00000080
        CALLC

callm:  tst     pcff, #0x00000080
        CALLCI

jr:     TIME    12
        ldr     lr, [mem, pcff, lsr #16]
        sxtb    lr, lr
        add     pcff, lr, lsl #16
        add     pcff, #0x00010000
        pkhtb   hlmp, hlmp, pcff, asr #16
        PREFIX0

jrnc:   tst     pcff, #0x00000100
        JRC
jrnn:   TIME    12
        ldr     lr, [mem, pcff, lsr #16]
        sxtb    lr, lr
        add     pcff, lr, lsl #16
        add     pcff, #0x00010000
        PREFIX0

jrc:    tst     pcff, #0x00000100
        JRCI

jrz:    movs    lr, defr, lsl #16
        JRC

jrnz:   movs    lr, defr, lsl #16
        JRCI

ldbc:   LDXX    bcfb, 8, bcfb, 24
        PREFIX0

ldbd:   LDXX    bcfb, 8, defr, 0
        PREFIX0

ldbe:   LDXX    bcfb, 8, defr, 24
        PREFIX0

lxbh:   movs    lr, arvpref, lsl #24
        beq     ldbh
        bmi     ldbyh
        LDXX    bcfb, 8, ixstart, 0
        PREFIX0
ldbyh:  LDXX    bcfb, 8, iy, 0
        PREFIX0
ldbh:   LDXX    bcfb, 8, hlmp, 0
        PREFIX0

lxbl:   movs    lr, arvpref, lsl #24
        beq     ldbl
        bmi     ldbyl
        LDXX    bcfb, 8, ixstart, 24
        PREFIX0
ldbyl:  LDXX    bcfb, 8, iy, 24
        PREFIX0
ldbl:   LDXX    bcfb, 8, hlmp, 24
        PREFIX0

ldba:   LDXX    bcfb, 8, arvpref, 0
        PREFIX0

ldcb:   LDXX    bcfb, 0, bcfb, 8
        PREFIX0

ldcd:   LDXX    bcfb, 0, defr, 8
        PREFIX0

ldce:   LDXX    bcfb, 0, defr, 0
        PREFIX0

lxch:   movs    lr, arvpref, lsl #24
        beq     ldch
        bmi     ldcyh
        LDXX    bcfb, 0, ixstart, 8
        PREFIX0
ldcyh:  LDXX    bcfb, 0, iy, 8
        PREFIX0
ldch:   LDXX    bcfb, 0, hlmp, 8
        PREFIX0

lxcl:   movs    lr, arvpref, lsl #24
        beq     ldcl
        bmi     ldcyl
        LDXX    bcfb, 0, ixstart, 0
        PREFIX0
ldcyl:  LDXX    bcfb, 0, iy, 0
        PREFIX0
ldcl:   LDXX    bcfb, 0, hlmp, 0
        PREFIX0

ldca:   LDXX    bcfb, 0, arvpref, 8
        PREFIX0

lddb:   LDXX    defr, 8, bcfb, 0
        PREFIX0

lddc:   LDXX    defr, 8, bcfb, 24
        PREFIX0

ldde:   LDXX    defr, 8, bcfb, 0
        PREFIX0

lxdh:   movs    lr, arvpref, lsl #24
        beq     lddh
        bmi     lddyh
        LDXX    defr, 8, ixstart, 0
        PREFIX0
lddyh:  LDXX    defr, 8, iy, 0
        PREFIX0
lddh:   LDXX    defr, 8, hlmp, 0
        PREFIX0

lxdl:   movs    lr, arvpref, lsl #24
        beq     lddl
        bmi     lddyl
        LDXX    defr, 8, ixstart, 24
        PREFIX0
lddyl:  LDXX    defr, 8, iy, 24
        PREFIX0
lddl:   LDXX    defr, 8, hlmp, 24
        PREFIX0

ldda:   LDXX    defr, 8, arvpref, 0
        PREFIX0

ldeb:   LDXX    defr, 0, bcfb, 8
        PREFIX0

ldec:   LDXX    defr, 0, bcfb, 0
        PREFIX0

lded:   LDXX    defr, 0, defr, 0
        PREFIX0

lxeh:   movs    lr, arvpref, lsl #24
        beq     ldeh
        bmi     ldeyh
        LDXX    defr, 0, ixstart, 8
        PREFIX0
ldeyh:  LDXX    defr, 0, iy, 8
        PREFIX0
ldeh:   LDXX    defr, 0, hlmp, 8
        PREFIX0

lxel:   movs    lr, arvpref, lsl #24
        beq     ldel
        bmi     ldeyl
        LDXX    defr, 0, ixstart, 0
        PREFIX0
ldeyl:  LDXX    defr, 0, iy, 0
        PREFIX0
ldel:   LDXX    defr, 0, hlmp, 0
        PREFIX0

ldea:   LDXX    defr, 0, arvpref, 8
        PREFIX0

lxhb:   movs    lr, arvpref, lsl #24
        beq     ldhb
        bmi     ldyhb
        LDXX    ixstart, 8, bcfb, 0
        PREFIX0
ldyhb:  LDXX    iy, 8, bcfb, 0
        PREFIX0
ldhb:   LDXX    hlmp, 8, bcfb, 0
        PREFIX0

lxhc:   movs    lr, arvpref, lsl #24
        beq     ldhc
        bmi     ldyhc
        LDXX    ixstart, 8, bcfb, 24
        PREFIX0
ldyhc:  LDXX    iy, 8, bcfb, 24
        PREFIX0
ldhc:   LDXX    hlmp, 8, bcfb, 24
        PREFIX0

lxhd:   movs    lr, arvpref, lsl #24
        beq     ldhd
        bmi     ldyhd
        LDXX    ixstart, 8, defr, 0
        PREFIX0
ldyhd:  LDXX    iy, 8, defr, 0
        PREFIX0
ldhd:   LDXX    hlmp, 8, defr, 0
        PREFIX0

lxhe:   movs    lr, arvpref, lsl #24
        beq     ldhe
        bmi     ldyhe
        LDXX    ixstart, 8, defr, 24
        PREFIX0
ldyhe:  LDXX    iy, 8, defr, 24
        PREFIX0
ldhe:   LDXX    hlmp, 8, defr, 24
        PREFIX0

lxhl:   movs    lr, arvpref, lsl #24
        beq     ldhl
        bmi     ldyhl
        LDXX    ixstart, 8, ixstart, 24
        PREFIX0
ldyhl:  LDXX    iy, 8, iy, 24
        PREFIX0
ldhl:   LDXX    hlmp, 8, hlmp, 24
        PREFIX0

lxha:   movs    lr, arvpref, lsl #24
        beq     ldha
        bmi     ldyha
        LDXX    ixstart, 8, arvpref, 0
        PREFIX0
ldyha:  LDXX    iy, 8, arvpref, 0
        PREFIX0
ldha:   LDXX    hlmp, 8, arvpref, 0
        PREFIX0

lxlb:   movs    lr, arvpref, lsl #24
        beq     ldlb
        bmi     ldylb
        LDXX    ixstart, 0, bcfb, 8
        PREFIX0
ldylb:  LDXX    iy, 0, bcfb, 8
        PREFIX0
ldlb:   LDXX    hlmp, 0, bcfb, 8
        PREFIX0

lxlc:   movs    lr, arvpref, lsl #24
        beq     ldlc
        bmi     ldylc
        LDXX    ixstart, 0, bcfb, 0
        PREFIX0
ldylc:  LDXX    iy, 0, bcfb, 0
        PREFIX0
ldlc:   LDXX    hlmp, 0, bcfb, 0
        PREFIX0

lxld:   movs    lr, arvpref, lsl #24
        beq     ldld
        bmi     ldyld
        LDXX    ixstart, 0, defr, 8
        PREFIX0
ldyld:  LDXX    iy, 0, defr, 8
        PREFIX0
ldld:   LDXX    hlmp, 0, defr, 8
        PREFIX0

lxle:   movs    lr, arvpref, lsl #24
        beq     ldle
        bmi     ldyle
        LDXX    ixstart, 0, defr, 0
        PREFIX0
ldyle:  LDXX    iy, 0, defr, 0
        PREFIX0
ldle:   LDXX    hlmp, 0, defr, 0
        PREFIX0

lxlh:   movs    lr, arvpref, lsl #24
        beq     ldlh
        bmi     ldylh
        LDXX    ixstart, 0, ixstart, 8
        PREFIX0
ldylh:  LDXX    iy, 0, iy, 8
        PREFIX0
ldlh:   LDXX    hlmp, 0, hlmp, 8
        PREFIX0

lxla:   movs    lr, arvpref, lsl #24
        beq     ldla
        bmi     ldyla
        LDXX    ixstart, 0, defr, 8
        PREFIX0
ldyla:  LDXX    iy, 0, arvpref, 8
        PREFIX0
ldla:   LDXX    hlmp, 0, arvpref, 8
        PREFIX0

ldab:   LDXX    arvpref, 8, bcfb, 0
        PREFIX0

ldac:   LDXX    arvpref, 8, bcfb, 24
        PREFIX0

ldad:   LDXX    arvpref, 8, defr, 0
        PREFIX0

ldae:   LDXX    arvpref, 8, defr, 24
        PREFIX0

lxah:   movs    lr, arvpref, lsl #24
        beq     ldah
        bmi     ldayh
        LDXX    arvpref, 8, ixstart, 0
        PREFIX0
ldayh:  LDXX    arvpref, 8, iy, 0
        PREFIX0
ldah:   LDXX    arvpref, 8, hlmp, 0
        PREFIX0

lxal:   movs    lr, arvpref, lsl #24
        beq     ldal
        bmi     ldayl
        LDXX    arvpref, 8, ixstart, 24
        PREFIX0
ldayl:  LDXX    arvpref, 8, iy, 24
        PREFIX0
ldal:   LDXX    arvpref, 8, hlmp, 24
        PREFIX0

inca:   INC     arvpref, 8
        PREFIX0

incb:   INC     bcfb, 8
        PREFIX0

incc:   INC     bcfb, 0
        PREFIX0

incd:   INC     defr, 8
        PREFIX0

ince:   INC     defr, 0
        PREFIX0

inchx:  movs    lr, arvpref, lsl #24
        beq     inch
        bmi     incyh
        INC     ixstart, 8
        PREFIX0
incyh:  INC     iy, 8
        PREFIX0
inch:   INC     hlmp, 8
        PREFIX0

inclx:  movs    lr, arvpref, lsl #24
        beq     incl
        bmi     incyl
        INC     ixstart, 0
        PREFIX0
incyl:  INC     iy, 0
        PREFIX0
incl:   INC     hlmp, 0
        PREFIX0

deca:   DEC     arvpref, 8
        PREFIX0

decb:   DEC     bcfb, 8
        PREFIX0

decc:   DEC     bcfb, 0
        PREFIX0

decd:   DEC     defr, 8
        PREFIX0

dece:   DEC     defr, 0
        PREFIX0

dechx:  movs    lr, arvpref, lsl #24
        beq     dech
        bmi     decyh
        DEC     ixstart, 8
        PREFIX0
decyh:  DEC     iy, 8
        PREFIX0
dech:   DEC     hlmp, 8
        PREFIX0

declx:  movs    lr, arvpref, lsl #24
        beq     decl
        bmi     decyl
        DEC     ixstart, 0
        PREFIX0
decyl:  DEC     iy, 0
        PREFIX0
decl:   DEC     hlmp, 0
        PREFIX0

addaa:  TIME    4
        mov     lr, arvpref, lsr #24
        pkhtb   spfa, spfa, lr
        pkhtb   bcfb, bcfb, lr
        mov     lr, lr, lsl #1
        pkhtb   pcff, pcff, lr
        uxtb    lr, lr  @ importante
        bic     arvpref, #0xff000000
        orr     arvpref, lr, lsl #24
        pkhtb   defr, defr, lr
        PREFIX0

adcaa:  TIME    4
        mov     lr, arvpref, lsr #24
        pkhtb   spfa, spfa, lr
        pkhtb   bcfb, bcfb, lr
        movs    r11, pcff, lsr #9
        adc     lr, lr, lr
        pkhtb   pcff, pcff, lr
        uxtb    lr, lr  @ importante
        bic     arvpref, #0xff000000
        orr     arvpref, lr, lsl #24
        pkhtb   defr, defr, lr
        PREFIX0

ret:    TIME    10
        RET

ldahl:  LDRP    hlmp, arvpref, 8
        PREFIX0

ldade:  LDRP    defr, arvpref, 8
        PREFIX0

ldabc:  LDRP    bcfb, arvpref, 8
        PREFIX0

incbc:  INCW    bcfb
        PREFIX0

incde:  INCW    defr
        PREFIX0

incsp:  INCW    defr
        PREFIX0

inchlx: movs    lr, arvpref, lsl #24
        beq     inchl
        bmi     incyhl
        INCW    ixstart
        PREFIX0
incyhl: INCW    iy
        PREFIX0
inchl:  INCW    hlmp
        PREFIX0

decbc:  DECW    bcfb
        PREFIX0

decde:  DECW    defr
        PREFIX0

decsp:  DECW    defr
        PREFIX0

dechlx: movs    lr, arvpref, lsl #24
        beq     dechl
        bmi     decyhl
        DECW    ixstart
        PREFIX0
decyhl: DECW    iy
        PREFIX0
dechl:  DECW    hlmp
        PREFIX0

pushbc: PUS     bcfb
        PREFIX0

pushde: PUS     defr
        PREFIX0

pushxx: movs    lr, arvpref, lsl #24
        beq     pushhl
        bmi     pushiy
        PUS     ixstart
        PREFIX0
pushiy: PUS     iy
        PREFIX0
pushhl: PUS     hlmp
        PREFIX0

callpo: tst     spfa, #0x00000100
        beq     over1
        ldr     r11, c9669
        eor     lr, defr, defr, lsr #4
        tst     r11, r11, lsl lr
        bmi     callnn
        TIME    10
        add     pcff, #0x00020000
        PREFIX0
over1:  eor     lr, spfa, defr
        eor     r11, bcfb, defr
        and     lr, r11
        tst     lr, #0x80
        CALLC

callpe: tst     spfa, #0x00000100
        beq     over2
        ldr     r11, c9669
        eor     lr, defr, defr, lsr #4
        tst     r11, r11, lsl lr
        bpl     callnn
        TIME    10
        add     pcff, #0x00020000
        PREFIX0
over2:  eor     lr, spfa, defr
        eor     r11, bcfb, defr
        and     lr, r11
        tst     lr, #0x80
        CALLCI

oped:   mov     lr, #0x00010000
        uadd8   arvpref, arvpref, lr
        ldrb    lr, [mem, pcff, lsr #16]
        add     pcff, #0x00010000
        ldr     pc, [pc, lr, lsl #2]
c9669:  .word   0x96690000    @ relleno
        .word   nop8          @ 00 NOP8
        .word   nop8          @ 01 NOP8
        .word   nop8          @ 02 NOP8
        .word   nop8          @ 03 NOP8
        .word   nop8          @ 04 NOP8
        .word   nop8          @ 05 NOP8
        .word   nop8          @ 06 NOP8
        .word   nop8          @ 07 NOP8
        .word   nop8          @ 08 NOP8
        .word   nop8          @ 09 NOP8
        .word   nop8          @ 0a NOP8
        .word   nop8          @ 0b NOP8
        .word   nop8          @ 0c NOP8
        .word   nop8          @ 0d NOP8
        .word   nop8          @ 0e NOP8
        .word   nop8          @ 0f NOP8
        .word   nop8          @ 10 NOP8
        .word   nop8          @ 11 NOP8
        .word   nop8          @ 12 NOP8
        .word   nop8          @ 13 NOP8
        .word   nop8          @ 14 NOP8
        .word   nop8          @ 15 NOP8
        .word   nop8          @ 16 NOP8
        .word   nop8          @ 17 NOP8
        .word   nop8          @ 18 NOP8
        .word   nop8          @ 19 NOP8
        .word   nop8          @ 1a NOP8
        .word   nop8          @ 1b NOP8
        .word   nop8          @ 1c NOP8
        .word   nop8          @ 1d NOP8
        .word   nop8          @ 1e NOP8
        .word   nop8          @ 1f NOP8
        .word   nop8          @ 20 NOP8
        .word   nop8          @ 21 NOP8
        .word   nop8          @ 22 NOP8
        .word   nop8          @ 23 NOP8
        .word   nop8          @ 24 NOP8
        .word   nop8          @ 25 NOP8
        .word   nop8          @ 26 NOP8
        .word   nop8          @ 27 NOP8
        .word   nop8          @ 28 NOP8
        .word   nop8          @ 29 NOP8
        .word   nop8          @ 2a NOP8
        .word   nop8          @ 2b NOP8
        .word   nop8          @ 2c NOP8
        .word   nop8          @ 2d NOP8
        .word   nop8          @ 2e NOP8
        .word   nop8          @ 2f NOP8
        .word   nop8          @ 30 NOP8
        .word   nop8          @ 31 NOP8
        .word   nop8          @ 32 NOP8
        .word   nop8          @ 33 NOP8
        .word   nop8          @ 34 NOP8
        .word   nop8          @ 35 NOP8
        .word   nop8          @ 36 NOP8
        .word   nop8          @ 37 NOP8
        .word   nop8          @ 38 NOP8
        .word   nop8          @ 39 NOP8
        .word   nop8          @ 3a NOP8
        .word   nop8          @ 3b NOP8
        .word   nop8          @ 3c NOP8
        .word   nop8          @ 3d NOP8
        .word   nop8          @ 3e NOP8
        .word   nop8          @ 3f NOP8
        .word   nop8          @ 40 NOP8
        .word   nop8          @ 41 NOP8
        .word   nop8          @ 42 NOP8
        .word   nop8          @ 43 NOP8
        .word   nop8          @ 44 NOP8
        .word   nop8          @ 45 NOP8
        .word   nop8          @ 46 NOP8
        .word   nop8          @ 47 NOP8
        .word   nop8          @ 48 NOP8
        .word   nop8          @ 49 NOP8
        .word   nop8          @ 4a NOP8
        .word   nop8          @ 4b NOP8
        .word   nop8          @ 4c NOP8
        .word   nop8          @ 4d NOP8
        .word   nop8          @ 4e NOP8
        .word   nop8          @ 4f NOP8
        .word   nop8          @ 50 NOP8
        .word   nop8          @ 51 NOP8
        .word   nop8          @ 52 NOP8
        .word   nop8          @ 53 NOP8
        .word   nop8          @ 54 NOP8
        .word   nop8          @ 55 NOP8
        .word   nop8          @ 56 NOP8
        .word   nop8          @ 57 NOP8
        .word   nop8          @ 58 NOP8
        .word   nop8          @ 59 NOP8
        .word   nop8          @ 5a NOP8
        .word   nop8          @ 5b NOP8
        .word   nop8          @ 5c NOP8
        .word   nop8          @ 5d NOP8
        .word   nop8          @ 5e NOP8
        .word   nop8          @ 5f NOP8
        .word   nop8          @ 60 NOP8
        .word   nop8          @ 61 NOP8
        .word   nop8          @ 62 NOP8
        .word   nop8          @ 63 NOP8
        .word   nop8          @ 64 NOP8
        .word   nop8          @ 65 NOP8
        .word   nop8          @ 66 NOP8
        .word   nop8          @ 67 NOP8
        .word   nop8          @ 68 NOP8
        .word   nop8          @ 69 NOP8
        .word   nop8          @ 6a NOP8
        .word   nop8          @ 6b NOP8
        .word   nop8          @ 6c NOP8
        .word   nop8          @ 6d NOP8
        .word   nop8          @ 6e NOP8
        .word   nop8          @ 6f NOP8
        .word   nop8          @ 70 NOP8
        .word   nop8          @ 71 NOP8
        .word   nop8          @ 72 NOP8
        .word   nop8          @ 73 NOP8
        .word   nop8          @ 74 NOP8
        .word   nop8          @ 75 NOP8
        .word   nop8          @ 76 NOP8
        .word   nop8          @ 77 NOP8
        .word   nop8          @ 78 NOP8
        .word   nop8          @ 79 NOP8
        .word   nop8          @ 7a NOP8
        .word   nop8          @ 7b NOP8
        .word   nop8          @ 7c NOP8
        .word   nop8          @ 7d NOP8
        .word   nop8          @ 7e NOP8
        .word   nop8          @ 7f NOP8
        .word   nop8          @ 80 NOP8
        .word   nop8          @ 81 NOP8
        .word   nop8          @ 82 NOP8
        .word   nop8          @ 83 NOP8
        .word   nop8          @ 84 NOP8
        .word   nop8          @ 85 NOP8
        .word   nop8          @ 86 NOP8
        .word   nop8          @ 87 NOP8
        .word   nop8          @ 88 NOP8
        .word   nop8          @ 89 NOP8
        .word   nop8          @ 8a NOP8
        .word   nop8          @ 8b NOP8
        .word   nop8          @ 8c NOP8
        .word   nop8          @ 8d NOP8
        .word   nop8          @ 8e NOP8
        .word   nop8          @ 8f NOP8
        .word   nop8          @ 90 NOP8
        .word   nop8          @ 91 NOP8
        .word   nop8          @ 92 NOP8
        .word   nop8          @ 93 NOP8
        .word   nop8          @ 94 NOP8
        .word   nop8          @ 95 NOP8
        .word   nop8          @ 96 NOP8
        .word   nop8          @ 97 NOP8
        .word   nop8          @ 98 NOP8
        .word   nop8          @ 99 NOP8
        .word   nop8          @ 9a NOP8
        .word   nop8          @ 9b NOP8
        .word   nop8          @ 9c NOP8
        .word   nop8          @ 9d NOP8
        .word   nop8          @ 9e NOP8
        .word   nop8          @ 9f NOP8
        .word   nop8          @ a0 NOP8
        .word   nop8          @ a1 NOP8
        .word   nop8          @ a2 NOP8
        .word   nop8          @ a3 NOP8
        .word   nop8          @ a4 NOP8
        .word   nop8          @ a5 NOP8
        .word   nop8          @ a6 NOP8
        .word   nop8          @ a7 NOP8
        .word   ldd           @ a8 NOP8
        .word   nop8          @ a9 NOP8
        .word   nop8          @ aa NOP8
        .word   nop8          @ ab NOP8
        .word   nop8          @ ac NOP8
        .word   nop8          @ ad NOP8
        .word   nop8          @ ae NOP8
        .word   nop8          @ af NOP8
        .word   nop8          @ b0 NOP8
        .word   nop8          @ b1 NOP8
        .word   nop8          @ b2 NOP8
        .word   nop8          @ b3 NOP8
        .word   nop8          @ b4 NOP8
        .word   nop8          @ b5 NOP8
        .word   nop8          @ b6 NOP8
        .word   nop8          @ b7 NOP8
        .word   nop8          @ b8 NOP8
        .word   nop8          @ b9 NOP8
        .word   nop8          @ ba NOP8
        .word   nop8          @ bb NOP8
        .word   nop8          @ bc NOP8
        .word   nop8          @ bd NOP8
        .word   nop8          @ be NOP8
        .word   nop8          @ bf NOP8
        .word   nop8          @ c0 NOP8
        .word   nop8          @ c1 NOP8
        .word   nop8          @ c2 NOP8
        .word   nop8          @ c3 NOP8
        .word   nop8          @ c4 NOP8
        .word   nop8          @ c5 NOP8
        .word   nop8          @ c6 NOP8
        .word   nop8          @ c7 NOP8
        .word   nop8          @ c8 NOP8
        .word   nop8          @ c9 NOP8
        .word   nop8          @ ca NOP8
        .word   nop8          @ cb NOP8
        .word   nop8          @ cc NOP8
        .word   nop8          @ cd NOP8
        .word   nop8          @ ce NOP8
        .word   nop8          @ cf NOP8
        .word   nop8          @ d0 NOP8
        .word   nop8          @ d1 NOP8
        .word   nop8          @ d2 NOP8
        .word   nop8          @ d3 NOP8
        .word   nop8          @ d4 NOP8
        .word   nop8          @ d5 NOP8
        .word   nop8          @ d6 NOP8
        .word   nop8          @ d7 NOP8
        .word   nop8          @ d8 NOP8
        .word   nop8          @ d9 NOP8
        .word   nop8          @ da NOP8
        .word   nop8          @ db NOP8
        .word   nop8          @ dc NOP8
        .word   nop8          @ dd NOP8
        .word   nop8          @ de NOP8
        .word   nop8          @ df NOP8
        .word   nop8          @ e0 NOP8
        .word   nop8          @ e1 NOP8
        .word   nop8          @ e2 NOP8
        .word   nop8          @ e3 NOP8
        .word   nop8          @ e4 NOP8
        .word   nop8          @ e5 NOP8
        .word   nop8          @ e6 NOP8
        .word   nop8          @ e7 NOP8
        .word   nop8          @ e8 NOP8
        .word   nop8          @ e9 NOP8
        .word   nop8          @ ea NOP8
        .word   nop8          @ eb NOP8
        .word   nop8          @ ec NOP8
        .word   nop8          @ ed NOP8
        .word   nop8          @ ee NOP8
        .word   nop8          @ ef NOP8
        .word   nop8          @ f0 NOP8
        .word   nop8          @ f1 NOP8
        .word   nop8          @ f2 NOP8
        .word   nop8          @ f3 NOP8
        .word   nop8          @ f4 NOP8
        .word   nop8          @ f5 NOP8
        .word   nop8          @ f6 NOP8
        .word   nop8          @ f7 NOP8
        .word   nop8          @ f8 NOP8
        .word   nop8          @ f9 NOP8
        .word   nop8          @ fa NOP8
        .word   nop8          @ fb NOP8
        .word   nop8          @ fc NOP8
        .word   nop8          @ fd NOP8
        .word   nop8          @ fe NOP8
        .word   nop8          @ ff NOP8

nop8:   TIME    8
        PREFIX0

ldd:    TIME    16
        ldrb    lr, [mem, hlmp, lsr #16]
        strb    lr, [mem, defr, lsr #16]
        mov     r11, #0x00010000
        sub     hlmp, r11
        sub     defr, r11
        sub     bcfb, r11
        movs    r10, defr, lsl #24
        pkhtbne defr, defr, r11, asr #16
        add     lr, arvpref, lsr #24
        and     lr, #0b00001010
        add     lr, lr, lsl #4
        eor     lr, pcff
        and     lr, #40
        eor     pcff, lr
        pkhtb   spfa, spfa, lr, asr #8
        movs    lr, bcfb, lsr #16
        eorne   spfa, #0x00000080
        pkhbt   bcfb, spfa, lr, lsl #16
        PREFIX0

salida: ldrh    lr, [punt, #oendd]
        cmp     lr, pcff, lsr #16
        beq     exec11

        ldrd    r10, [punt, #ocounter]
        ldr     lr, [punt, #ost+4]
        cmp     stlo, r10
        sbcs    lr, lr, r11
        bcc     exec1

exec11:
        movs    lr, arvpref, lsl #24
        bne     exec1

        str     stlo, [punt, #ost]
        str     pcff, [punt, #off]    @ pc | ff
        str     spfa, [punt, #ofa]    @ sp | fa
        str     bcfb, [punt, #ofb]    @ bc | fb
        str     defr, [punt, #ofr]    @ de | fr
        str     hlmp, [punt, #omp]    @ hl | mp
        str     arvpref, [punt, #oprefix] @ ar | r7 iff im halted : prefix
        str     ixstart, [punt, #ostart]  @ ix | start
        mov     iy, iy, lsr #16
        str     iy, [punt, #oyl]      @ iy |

        pop     {r4-r12, lr}
        bx      lr

insth:  ldr     r11, [punt, #ost+4]
        add     r11, r11, #1
        str     r11, [punt, #ost+4]
        bx      lr
