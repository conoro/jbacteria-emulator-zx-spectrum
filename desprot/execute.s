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
endd:   .short  0
sp:     .short  0
mp:     .short  0
l:      .byte   0
h:      .byte   0
t:      .short  0
u:      .short  0
ff_:    .short  0
fa:     .short  0
fa_:    .short  0
fb:     .short  0
fb_:    .short  0
fr:     .short  0
fr_:    .short  0
a:      .byte   0
c:      .byte   0
b:      .byte   0
e:      .byte   0
d:      .byte   0
a_:     .byte   0
c_:     .byte   0
b_:     .byte   0
e_:     .byte   0
d_:     .byte   0
l_:     .byte   0
h_:     .byte   0
xl:     .byte   0
xh:     .byte   0
yl:     .byte   0
yh:     .byte   0
i:      .byte   0
r:      .byte   0
rs:     .byte   0
prefix: .byte   0
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
        .equ    oendd,    2+ostart
        .equ    osp,      2+oendd
        .equ    omp,      2+osp
        .equ    ol,       2+omp
        .equ    oh,       1+ol
        .equ    ot,       1+oh
        .equ    ou,       2+ot
        .equ    off_,     2+ou
        .equ    ofa,      2+off_
        .equ    ofa_,     2+ofa
        .equ    ofb,      2+ofa_
        .equ    ofb_,     2+ofb
        .equ    ofr,      2+ofb_
        .equ    ofr_,     2+ofr
        .equ    oa,       2+ofr_
        .equ    oc,       1+oa
        .equ    ob,       1+oc
        .equ    oe,       1+ob
        .equ    od,       1+oe
        .equ    oa_,      1+od
        .equ    oc_,      1+oa_
        .equ    ob_,      1+oc_
        .equ    oe_,      1+ob_
        .equ    od_,      1+oe_
        .equ    ol_,      1+od_
        .equ    oh_,      1+ol_
        .equ    oxl,      1+oh_
        .equ    oxh,      1+oxl
        .equ    oyl,      1+oxh
        .equ    oyh,      1+oyl
        .equ    oi,       1+oyh
        .equ    or,       1+oi
        .equ    ors,      1+or
        .equ    oprefix,  1+ors
        .equ    oiff,     1+oprefix
        .equ    oim,      1+oiff
        .equ    ow,       1+oim
        .equ    ohalted,  1+ow

        punt    .req      r0
        mem     .req      r1
        stlow   .req      r2
        pcff    .req      r3
        spfa    .req      r4
        bcfb    .req      r5
        defr    .req      r6
        hlmp    .req      r7
        arrr    .req      r8
        ixstart .req      r9
        iy      .req      r12

/*      r0      punt
        r1      mem
        r2      stlow
        r3      pc | ff
        r4      sp | fa
        r5      bc | fb
        r6      de | fr
        r7      hl | mp
        r8      ar | r7 prefix iff im halted
        r9      ix | start
        r12     iy |
*/

.text
.global execute
execute:push    {r4-r12, lr}

        ldr     punt, =st
        ldr     mem, [punt, #omem]
        ldr     stlow, [punt, #ost]
        ldr     pcff, [punt, #off]    @ pc | ff
        ldr     hlmp, [punt, #omp]    @ hl | mp

        ldrh    lr, [punt, #ostart]
        cmp     lr, pcff, lsr #16
        bne     exec1
exec1:

        ldrb    lr, [punt, #or]
        add     lr, lr, #1
        strb    lr, [punt, #or]

        ldrb    lr, [mem, pcff, lsr #16]
        add     pcff, pcff, #0x10000
        ldr     pc, [pc, lr, lsl #2]
        .word   0             @ relleno
        .word   nop           @ 00 NOP00
        .word   nop           @ 01 LD BC,nn
        .word   nop           @ 02 LD (BC),A
        .word   nop           @ 03 INC BC
        .word   nop           @ 04 INC B
        .word   nop           @ 05 DEC B
        .word   nop           @ 06 LD B,n
        .word   nop           @ 07 RLCA
        .word   nop           @ 08 EX AF,AF
        .word   nop           @ 09 ADD HL,BC
        .word   nop           @ 0a LD A,(BC)
        .word   nop           @ 0b DEC BC
        .word   nop           @ 0c INC C
        .word   nop           @ 0d DEC C
        .word   nop           @ 0e LD C,n
        .word   nop           @ 0f RRCA
        .word   nop           @ 10 DJNZ
        .word   nop           @ 11 LD DE,nn
        .word   nop           @ 12 LD (DE),A
        .word   nop           @ 13 INC DE
        .word   nop           @ 14 INC D
        .word   nop           @ 15 DEC D
        .word   nop           @ 16 LD D,n
        .word   nop           @ 17 RLA
        .word   nop           @ 18 JR
        .word   nop           @ 19 ADD HL,DE
        .word   nop           @ 1a LD A,(DE)
        .word   nop           @ 1b DEC DE
        .word   nop           @ 1c INC E
        .word   nop           @ 1d DEC E
        .word   nop           @ 1e LD E,n
        .word   nop           @ 1f RRA
        .word   nop           @ 20 JR NZ,s8
        .word   ldhlnn        @ 21 LD HL,nn

nop:    mov     lr, r0

ldhlnn: adds    stlow, stlow, #10
        blcs    insth

        ldr     lr, [mem, pcff, lsr #16]
        add     pcff, pcff, #0x20000
        pkhbt   hlmp, hlmp, lr, lsl #16
        b       exec10

exec10: ldrh    lr, [punt, #oendd]
        cmp     lr, pcff, lsr #16
        beq     exec11

        ldrd    r10, [punt, #ocounter]
        ldr     lr, [punt, #ost+4]
        cmp     stlow, r10
        sbcs    lr, lr, r11
        bcs     execute

exec11:
        ldrb    lr, [punt, #oprefix]
        cmp     lr, #0
        bne     execute

        str     stlow, [punt, #ost]
        str     pcff, [punt, #off]    @ pc | ff
        str     hlmp, [punt, #omp]    @ hl | mp
        pop     {r4-r12, lr}
        bx      lr

insth:  ldr     r11, [punt, #ost+4]
        add     r11, r11, #1
        str     r11, [punt, #ost+4]
        bx      lr
