; UnoDOS 3 - An operating system for the ZX-Uno and divMMC.
; Copyright (c) 2017 Source Solutions, Inc.
; Modified by Antonio Villena to revert to ESXDOS 0.8.5

;       This file is part of UnoDOS 3.
;
;       UnoDOS 3 is free software: you can redistribute it and/or modify
;       it under the terms of the Lesser GNU General Public License as published by
;       the Free Software Foundation, either version 3 of the License, or
;       (at your option) any later version.
;
;       UnoDOS 3 is distributed in the hope that it will be useful,
;       but WITHOUT ANY WARRANTY; without even the implied warranty of
;       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;       GNU General Public License for more details.
;
;       You should have received a copy of the GNU Lesser General Public License
;       along with UnoDOS 3.  If not, see <http://www.gnu.org/licenses/>.

        output  esxdos.rom

        include "esxdosinc.asm"
        include "basic.asm"

RST_00H:                
; automatically mapped in by the hardware after M1 when PC=$0000
L0000:  di                      ;interrupts off
        ld      sp, $5e00       ;set stack poitner to $5e00
        jp      L0101           ;immediate jump

        block   $0008-$, $ff
L0008:  jp      L0985           ;immediate jump
; automatically mapped in by the hardware after M1 when PC=0008h
; main ESXDOS API entry point

L000B:  ld      hl, (ch_add)
        jr      L0015

        block $0010-$
L0010:  jp L0845

        block $0015-$, $ff
L0015:  jp L0CD4;

        block $0018-$, $ff
L0018:  jp $0cbd;

        block $001f-$, $ff
L001F:
        define  L0020 L001F + 1
        jr L004B;
        ld e, l;
        ld e, h;
        ld (x_ptr), hl;
        jr L004D;

        block $0028-$, $ff
L0028:
        push hl;
        ld hl, (mmc_sp);
        ex (sp), hl;
        ret;

        block $0030-$, $ff
L0030:
; auxiliary routines for internal UnoDOS business
        jr L0091;

L0032:
        defb "/BIN/";+ avoids clash with keyword in tokenizers

        block $0038-$, $ff
L0038:
; automatically mapped in by the hardware after M1 when PC=$0038
        jr L001F;
        ld hl, $0039;
        jp L1FF4;

L0040:
        defm "PLUS3DOS";                // file header text

L0048:
        ld a, (de);

L0049:
        ld bc, $fb00;
        ret;

L004B equ L0049 + 2;

L004D:
        jp L0C06;

L0050:
        defm 'Detecting Devices...'
        defm $0d, 0;                    // carriage return, end marker

verbose:
;        ld hl, 20480;                   // printing off by default
;        ld a, $7f;                              // test for SPACE
;        in a, (ula);                    // read it
;        rra;
;        ret c;                                  // back if no SPACE
;        ld hl, $3c00;                   // point to character set
;        ret;

        block $0066-$
NMI:
; automatically mapped in by the hardware after M1 when PC=$0066
        ret;                                    // after triggering the first NMI, the CPU will
;                                                       // still execute the instruction stored in the
;                                                       // system ROM, which will be ignored (hence the
;                                                       // NOP). The first actual instruction executed
;                                                       // from the EEPROM is the one located at $0068.
;                                                       // if a second NMI is triggered while still
;                                                       // inside this NMI handler, the RET instruction
;                                                       // will be executed, terminating it. So this is a
;                                                       // mixed software-hardware solution to avoid
;                                                       // nesting NMI calls.
        nop;

        block $0068-$
L0068:
        ld (mmc_2), hl;
        ld hl, (mmc_3);
        ld h, a;
        ;
        ld a, 0;
        out (mmcram), a;                // divMMC mem page 0, CONMEM off, MAPRAM off
        ld (mmc_1), hl;
        ld a, l;                                // mem page from L
        out (mmcram), a;
        ld hl, (mmc_2);
        ld a, 0;                                // could use XOR A if flags are not important
        out (mmcram), a;                // divMMC mem page 0, CONMEM off, MAPRAM off
        ;
        ld a, ($2e7b);
        jp $201e;
        ei;                                             // interrupts on
        push af;
        ld a, (mmc_1);
        out (mmcram), a;                // divMMC mem
        pop af;
        jp L1FFA;

L0091:
        ld (mmc_2), hl;
        pop hl;
        inc hl;
        push hl;
        dec hl;
        push de;
        ld d, 0;
        ld e, (hl);
        ld hl, L05A0;

L009F:
        add hl, de;
        add hl, de;
        ld e, (hl);
        inc hl;
        ld h, (hl);
        ld l, e;
        pop de;
        push hl;
        ld hl, (mmc_2);
        ret;

L00AB:
        defm "/SYS";                    // system folder
        defb 0;                                 // end marker

coprig  defb    $13, $01, $17, $12, $01, $13, $00
        defm    ' v0.8.5-DivMMC', 13
        defb    $13, $01, $17, $15, $01, $13, $00
        defm    $7f, ' 2005-2013', 13
        defb    $13, $01, $17, $13, $01, $13, $00
        defm    'Papaya Dezign', 13, 13+$80

L00EF:
; select BASIC ROM on 128K machines;
        ld bc, $1ffd;                   // +3 paging
        ld a, 4;                                // ROMh to 1, normal memory mode
        out (c), a;
        ld b, $7f;                              // 128 paging
        ld a, $10;                              // ROMl to 1, normal video, RAM 0, unlocked
        out (c), a;
        ret;                                    // done

        nop;
        nop;
        ld e, d;
        dec a;

L0101:
; Jumped to from RST0;
        ld bc, $2a30;
        xor a;                                  // LD A, 0;
        out (mmcram), a;                // divMMC RAM page 0, CONMEM off, MAPRAM off

L0107:
        dec bc  ;
        nop;
        nop;
        nop;
        nop;
        ld a, b;
        or c;
        jr nz, L0107;                   // loop to settle the bus 
        call L00EF;                             // force BASIC ROM;
        call L04FF;                             // mute AY
        ld a, $0e;
        ld ($201f), a;
        ld a, ($2d42);
        cp $aa;                                 // SCREEN$, 170d
        jr nz, L012A;
        ld a, $7f;                              // high byte of I/O address                     ;
        in a, (ula);                    // Read keyboard (?)
        rra;
        jp c, L0251;                    // if ?space? not pressed, jump to L0251
        ;                                               // which sets HL to 1 then exits

        block $012a-$
L012A:
; start of init
; make screen black;
        xor a;                                  // LD A, 0
        out (ula), a;                   // black border
        ld hl, $5eff;                   // source
        ld de, $5efe;                   // destination
        ld bc, $1eff;                   // byte count
        ld (hl), a;                             // set first value to zero
        lddr;                                   // zero 16384 to 24319 (blank screen)
        ;                                               // seems odd not to just do the attributes

;        call logo;

; Check this divMMC device has more than 32K (4 pages) of memory
        ld a, 4;                                // Start at page 4

L013B:
        out (mmcram), a;                // set divMMC memory page
        ld hl, $2000;                   // source
        ld de, $2001;                   // destination
        ld bc, $1fff;                   // byte count
        ld (hl), l;                             // zero first byte
        ldir;                                   // clear 8K from $2000 to $3fff
        ld (mmc_3), a;                  // store current memory page in $3df9
        ld hl, $3dfd;
        ld (hl), $c9;                   // put a RET at $3dfd
        ld hl, $3d30;
        ld (hl), $c9;                   // put a RET at 3d30h
        dec a;                                  // page=page-1
        cp $ff;                                 // COPY, 255d
        jr nz, L013B;                   // if we've not just done page 0, loop back
        ld a, 4;
        out (mmcram), a;                // back to page 4
        ld hl, $2000;                   // address top 8K of ROM area
        ld a, (hl);                             // get value
        inc (hl);                               // increment it
        cp (hl);                                // check page 4 is writable
        jr nz, L0169;                   // if so, jump to L0169
        ld l, $1c;                              // else?

L0169:
        xor a;                                  // LD A, 0
        out (mmcram), a;                // Switch to page 0, CONMEM off, MAPRAM off
        ld a, l;
        ld ($2e8c), a;
        ld a, $aa;
        ld ($2d42), a;
        ld hl, print_out;
        ld (chans), hl;
        ld hl, chans;
        ld (curchl), hl;
        ld a, 7;                                // INK 7, PAPER 0, BRIGHT 0, FLASH 0
        ld (attr_t), a;
        ld hl, $4000;                   // screen address
        ld (df_cc), hl;
        ld hl, $1821;                   // row 24, column 33 (gives PRINT AT 0,0;) 
        ld (s_posn), hl;
;        call verbose;                   // test for SPACE (verbose boot mode)
        ld hl, $3c00
        ld (chars), hl;
        ld hl, coprig;                   // address copyright message
  call $0c90
  ld hl, $00ce
  call $0c90
;        call pr_str;                    // print it
  call L0463
        call L031C;
        call L03A7;
        ld hl, $2007;
        ld a, $3e;
        ld (hl), a;
        inc l;
        ld a, $14;
        ld (hl), a;
        inc l;
        ld a, $37;
        ld (hl), a;
        inc l;
        ld a, $0c9;
        ld (hl), a;
        ld (L2014), a;
        ld hl, $0812;
        ld ($2017), hl;
        ld hl, $0c3f1;
        ld ($201e), hl;
        ld hl, $1ff7;
        ld ($2020), hl;
        ld a, $c9;
        ld ($2f00), a;
        ld hl, $0c937;
        ld (L2357), hl;
        ld ($2515), hl;
        ld hl, L0050;                   // "detecting devices"
        call pr_str;                    // print string
    ld a, 13
    rst $10
        ld a, $80;
        call L027D;
        ld a, $88;
        call L027D;
        ld hl, L0670;                   // "mounting drives"
        call pr_str;                    // print string
        call L06E1;
        ld a, ($2d01);
        ld ($2d46), a;
        ld ($2d4a), a;
        call L041E;
    ld a, 13
    rst $10
        ld hl, L1C58;                   // UnoDOS text
        call L0257;
        call L02C5;
        push af;
        call L0272;                             // ok or error for dos system file
        pop af;
        jr c, L0242;
        ld hl, L06D9;
        call L0257;
        call L02B3;
        call L0272;                             // ok or error for NMI system file
        jr nz, L0242;
        ld a, ($2e8c);
        and a;
        jr nz, L0242;
        ld hl, $06b2;
        call L0257;
        call L02A1;
        push af;
        call nc, L03C4;
        pop af;
        call L0272;                             // ok or error for betadisk system file

L0242:
        ld a, $7f;                              // high byte of I/O address
        in a, (ula);                    // read keyboard
        rra;
        jr c, L024B;
        jr L0242;

L024B:  ld de, $07d0;
        call L0297;
L0251:
        ld hl, $0001;
        jp L1FFB;

L0257: ex de, hl
      ld hl, $06d0
      call L083E
      ex de, hl
        call L02EF;
        push hl;
        ld de, $0005;
        add hl, de;
        call pr_str;
      ld  hl, $06dd
      call L083E
        pop hl;
        ret;

L0272:
        ld hl, L06C7;                   // OK
        jr nc, L027A;                   // jump if so, else...
        ld hl, L06BB;                   // error

L027A:
        jp pr_str;

L027D:
        ld de, $2df2;
        rst $08;
        defb disk_status;
        ret c;
        and %11111000;
        rst $30;
        ld c, $3e;
        ld a, ($3ed7);
        jr nz, $0264;
        ld hl, $2df2;
        call pr_str;
        ld a, $0d;                              // carriage return
        rst $10;
        ret;

        block $0297-$
L0297:
        ld b, $ff;                              // fixed address used by taps.io

L0299:
        djnz L0299;
        dec de;
        ld a, d;
        or e;
        jr nz, L0297;
        ret;

L02A1:
        call L02E8;
        ret c;
        push af;
        ld a, 3;
        out (mmcram), a;                // divMMC memory page 3
        pop af;
        ld hl, $2000;
        ld bc, $1c00;
        jr L02BD;

L02B3:
        call L02E8;
        ret c;
        ld hl, $2f00;
        ld bc, $0e00;

L02BD:
        ld e, a;
        push de;
        rst $08;
        defb f_read;
        pop de;
        ld a, e;
        jr L02E1;

L02C5:
        call L02E8;
        ret c;
        push af;
        ld hl, $2000;
        ld bc, $061a;
        rst $08;
        defb f_read;
        ld a, 1;
        out (mmcram), a;                // divMMC memory page 1
        pop af;
        push af;
        ld hl, $3000;
        ld bc, $07ca;
        rst $08;
        defb f_read;
        pop af;

L02E1:
        rst $08;
        defb f_close;
        ld a, 0;
        out (mmcram), a;                // divMMC memory page 0
        ret;

L02E8:
        ld a, $24;
        ld b, 1;
        rst $08;
        defb f_open;
        ret;

L02EF:
        call L0305;
        ld hl, $00ac;

L02F5:
        call L0598;
        ld (de), a;
        ld hl, $2dce;
        ret;

L02FD:
        call L0305;
        ld hl, $201b;
        jr L02F5;

L0305:
        push hl;
        ld de, $2dce;
        ld hl, $00ab;
        call L0598;
        ld a, $2f;
        ld (de), a;
        inc de;
        pop hl;
        call L0598;
        ld a, $2e;
        ld (de), a;
        inc de;
        ret;

L031C:
        ld hl, $2d24;
        ld de, $1c6d;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        inc hl;
        ld de, $2515;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        inc hl;
        ret;

L032E:
        ld c, a;
        ld a, ($2d47);
        cp 6;                                   // tab character 6d
        scf;
        ret z;
        ld hl, $2c00;

L0339:
        ld a, (hl);
        and a;
        jr z, L0343;
        ld a, $28;
        add a, l;
        ld l, a;
        jr L0339;

L0343:
        ld (hl), c;
        push hl;
        pop iy;
        ld hl, $2d47;
        inc (hl);
        ret;

L034C:
        call L0363;
        ret c;
        xor a;
        ld (hl), a;
        ld hl, $2d47;
        dec (hl);
        or a;
        ret;

L0358:
        push hl;
        push bc;
        call L0363;
        push hl;
        pop iy;
        pop bc;
        pop hl;
        ret;

L0363:
        ld c, a;
        ld b, 6;
        ld hl, $2c00;

L0369:
        ld a, (hl);
        xor c;
        and %11111000;
        jr z, L0377;
        ld a, $28;
        add a, l;
        ld l, a;
        djnz L0369;
        scf;
        ret;

L0377:
        ld a, (hl);
        cp c;
        ret c;
        ld a, c;
        and %00000111;
        ret;

L037E:
        push hl;
        ld hl, ($3dfb);
        ex (sp), hl;
        ret;
        push de;
        push hl;
        ld a, iyl;
        ld ixl, a;
        ld de, $2400;
        ld h, 0;
        ld a, ixh;
        add a, a;
        add a, a;
        add a, a;
        add a, a;
        add a, a;
        ld l, a;
        rl h;
        add hl, de;
        ld a, iyh;
        call L03D4;
        ld a, ixl;

L03A1:
        push hl;
        pop ix;
        pop hl;
        pop de;
        ret;

L03A7:
        ld hl, $2d2a;
        ld de, $0df1;
        ld bc, $0384;
        ld a, 1;
        ld (hl), a;
        inc hl;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        inc hl;
        ld (hl), $ff;
        out (mmcram), a;                // divMMC page 1
        ld ($3dfb), bc;
        xor a;
        out (mmcram), a;                // divMMC page 0
        ret;

L03C4:
        nop;
        nop;
        nop;
        nop;
        nop;
        ld a, 3;
        out (mmcram), a;                // divMMC page 3
        call L2000;                             // call an unknown (dynamic?) routine
        xor a;                                  // LD A, 0
        out (mmcram), a;                // divMMC page 0
        ret;

L03D4:
        push bc;
        ld iy, $2000;
        ld b, 4;

L03DB:
        cp (iy + _err_nr);
        jr z, L03E7;
        inc iyh;
        djnz L03DB;
        pop bc;
        scf;
        ret;

L03E7:
        or a;
        pop bc;
        ret;

L03EA:
        ld b, a;
        ld hl, $2d2a;

L03EE:
        call L04E7;
        ld ixh, a;
        ld a, (hl);
        cp 255;                                 // COPY, $ff
        jr z, L040B;
        ld e, a;
        push de;
        inc hl;
        ld e, (hl);
        inc hl;
        ld d, (hl);
        inc hl;
        push hl;
        push bc;
        call L040F;
        pop bc;
        pop hl;
        pop ix;
        ret nc;
        jr L03EE;

L040B:
        ld a, $1e;
        scf;
        ret;

L040F:
        push hl;
        push hl;
        out (mmcram), a;                // Set divMMC ram page
        ld ($3df8), a;                  // Store current divMMC ram page
        ld h, d;
        ld l, e;
        call L037E;
        jp L0B5A;

L041E:
        ld hl, $2df2;
        push hl;
        rst $08;
        defb m_driveinfo;
        pop hl;
        ld b, a;
        and a;
        ret z;

L0428:
        push bc;
        call L0430;
        pop bc;
        djnz L0428;
        ret;

L0430:
        ld a, (hl);
        rst $30;
        add hl, bc;
        ld a, ' ';                              // space
        rst $10;                                // print a character
        inc hl;
        inc hl;
        inc hl;
        rst $30;
        ld bc, $e5c5;
        ld bc, $00ff;
        xor a;
        cpir;
        call L0458;
        ld b, h;
        ld c, l;
        pop hl;
        call L0458;
        ld l, e;
        ld h, d;
        pop de;
        push bc;
        call L089A;
        ld a, $0d;                              // carriage return
        rst $10;                                // print a character
        pop hl;
        ret;

L0458:
        call pr_str;
        inc hl;
        ld a, ',';
        rst $10;
        ld a, ' ';
        rst $10;
        ret;

L0463: ld hl, $1b37
      ld de, $4000
      ld c, $10
L046B ld a, (hl)
      inc b
      and $f0
      cp  $a0
      ld a, (hl)
      inc hl
      jr nz, L0478
      and $0f
      ret z
      ld  b, a
L0477 xor a
L0478 ld  (de), a
      call  L0581
      djnz  L0477
      jr  L046B

L0482:
        ld l, a;
        and %11100000;
        ret z;
        ld e, $30;
        ld c, $66;
        cp ' ';                                 // $20
        jr z, L049E;
        ld c, $76;
        cp $60;                                 // £
        jr z, L049E;
        ld e, $61;
        cp $80;                                 // empty block graphic
        ld c, $73;
        jr z, L049E;
        ld c, $68;

L049E:
        ld a, c;
        rst $10;                                // print a character
        ld a, 'd';
        rst $10;                                // print a character
        ld a, l;
        rrca;
        rrca;
        rrca;
        and %00000011;
        add a, e;
        rst $10;                                // print a character
        ld a, l;
        and %00000111;
        ret z;
        add a, 30h;
        rst $10;
        ret;

        block $04c6-$
L04C6:
; automatically mapped in by the hardware after M1 when PC=004C6h
; Automapped entry point for SAVE command
        ld hl, $1f80;
        push hl;
        ld b, a;
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, ($2d4c);
        and a;
        ld a, b;
        jr z, L04E1;
        push de;
        push bc;
        call L23C4;
        pop bc;
        pop de;
        pop hl;
        ld a, b;
        jp nc, $2011;

L04E1:
        ld hl, $04c9;
        jp L1FF4;

L04E7:
        push hl;
        push bc;
        ld hl, $2cf1;
        ld bc, $000f;
        xor a;
        cpir;
        ld a, $0c;
        scf;
        call z, L04FB;
        pop bc;
        pop hl;
        ret;

L04FB:
        ld a, $0f;
        sub c;
        ret;

L04FF:
; Mute AY;
        ld bc, $fffd;                   // AY register port
        ld a, 7;                                // volume (all channels)
        out (c), a;                             // select register
        ld b, $bf;                              // AY data port
        ld a, $ff;                              // mute (inverse value)
        out (c), a;                             // AY off
        ret;                                    // done

L050D:
        push af;
        push ix;
        push hl;
        pop ix;
        ld hl, ($3df8);
        ld c, mmcram;
        ld b, $7f;

L051A:
        out (c), l;                             // Set divMMC memory page...
        ld a, (ix + 0);
        out (c), h;                             // Set divMMC memory page...


        ld (de), a;
        inc ix;
        inc de;
        and a;
        jr z, L052A;
        djnz L051A;

L052A:
        push ix;
        pop hl;
        pop ix;
        pop af;
        ret;

L0531:
        push bc;
        cp '*';                                 // use current drive?
        jr nz, L0546;
        ld a, ($3df9);
        ld b, a;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, ($2d46);
        ld c, a;
        ld a, b;
        out (mmcram), a;                // divMMC RAM page 
        ld a, c;

L0546:
        push af;
        and %11111000;
        srl a;
        srl a;
        srl a;
        or %01100000;                   // make upper case
        rst $10;                                // print a character
        ld a, 'd';
        rst $10;                                // print a character
        pop af;
        push af;
        and %00000111;
        add a, $30;
        rst $10;                                // print a character
        ld a, $3a;
        rst $10;                                // print a character
        pop af;
        pop bc;
        ret;

        block $0562-$
; The divMMC automapper trap for the LOAD command
; This explains the redundant in a, (ula)
; automatically mapped in by the hardware after M1 when PC=$0562
L0562:
        in a, (ula);
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, ($2d4b);
        and a;
        jr nz, L0577;

L056E:
        push hl;
        ld hl, $0564;
        in a, (ula);
        jp L1FF4;

L0577:
        push de;
        call L23C4;
        pop de;
        jr c, L056E;
        jp $200e;

L0581:
        inc e;
        dec c;
        ret nz;
        ld c, $10;
        ld a, e;
        sub c;
        ld e, a;
        inc d;
        ld a, d;
        and %00000111;
        ret nz;
        ld a, e;
        add a, $20;
        ld e, a;
        ret c;
        ld a, d;
        sub 8;
        ld d, a;
        ret;

L0598:
        ld a, (hl);
        and a;
        ret z;
        ld (de), a;
        inc hl;
        inc de;
        jr L0598;

L05A0:
        defw L06A9
        defw L0686
        defw L05F3
        defw L06A5
        defw L064B
        defw L050D
        defw L0643
        defw L0619
        defw L0694
        defw L0531
        defw L05BE
        defw L05C3
        defw L05DD
        defw L068F
        defw L0482
        
L05BE:
        ld de, $2000;
        jr L05C8;

L05C3:
        ld hl, $2000;
        jr L05C8;

L05C8:
        call L05D6;
        ret z;
        ld a, 4;
        out (mmcram), a;                // divMMC RAM page 4
        ldir;
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        ret;

L05D6:
        ld a, ($2e8c);
        cp $1c;
        scf;
        ret;

L05DD:
        ld e, a;
        call L05D6;
        ret z;
        ld a, 4;
        out (mmcram), a;                // divMMC RAM page 4
        ld a, e;
        ld hl, $2000;
        rst $08;
        defb f_write;
        ld e, a;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, e;
        ret;

L05F3:
        rst $18;
        defw next_char
        ret;

L05F7:
        push ix;
        push hl;
        pop ix;
        ld hl, ($3df8);

L05FF:
        push bc;
        ld c, mmcram;
        out (c), l;                             // Set divMMC RAM page...
        ld a, (ix + 0);
        out (c), h;                             // Set divMMC RAM page...
        ld (de), a;
        inc ix;
        inc de;
        pop bc;
        dec bc;
        ld a, b;
        or c;
        jr nz, L05FF;
        push ix;
        pop hl;
        pop ix;
        ret;

L0619:
        ld a, d;
        cp '@';                                 // $40
        jr c, L05F7;
        ldir;
        ret;

L0621:
        push ix;
        push hl;
        pop ix;
        ld hl, ($3df8);

L0629:
        push bc;
        ld c, mmcram;
        ld a, (ix + 0);
        out (c), l;                             // set divMMC RAM page...
        ld (de), a;
        out (c), h;                             // set divMMC RAM page...
        inc ix;
        inc de;
        pop bc;
        dec bc;
        ld a, b;
        or c;
        jr nz, L0629;
        push ix;
        pop hl;
        pop ix;
        ret;

L0643:
        ld a, d;
        cp '@';                                 // $40
        jr c, L0621;
        ldir;
        ret;

L064B:
        push af;
        push ix;
        push hl;
        pop ix;
        ld hl, ($3df8);
        ld a, h;
        ld h, l;
        ld l, a;
        ld c, mmcram;
        ld b, $7f;

L065B:
        out (c), l;                             // set divMMC RAM page...
        ld a, (ix + 0);
        out (c), h;                             // set divMMC RAM page...
        ld (de), a;
        inc ix;
        inc de;
        and a;
        jr z, L066B;
        djnz L065B;

L066B:
        out (c), l;
        jp L052A;

L0670:
        defm  13, 'Mounting drives...', 13, 13, 0
        
        block $0686-$
L0686:
        ld e, (hl);
        inc hl;
        ld d, (hl);
        inc hl;
        ld c, (hl);
        inc hl;
        ld b, (hl);
        inc hl;
        ret;

L068F:
        ld a, b;
        or c;
        or d;
        or e;
        ret;

L0694:
        ld a, (hl);
        cp b;
        ret nz;
        dec hl;
        ld a, (hl);
        cp c;
        ret nz;
        dec hl;
        ld a, (hl);
        cp d;
        ret nz;
        dec hl;
        ld a, (hl);
        cp e;
        ret nz;
        scf;
        ret;

L06A5:
        rst $18;
        defw syntax_z
        ret;

L06A9:
        ld (hl), e;
        inc hl;
        ld (hl), d;
        inc hl;
        ld (hl), c;
        inc hl;
        ld (hl), b;
        inc hl;
        ret;

L06B2:  ;
        defm "BETADISK";
        defb 0;                                 // end marker

L06BB:
        defb $17, $18, $01;             // TAB 24
        defm "[ERROR]";
        defb $0d, $00;                  // carriage return, end marker

L06C7:
        defb $17, $1b, $01;             // TAB 27
        defm "[OK]";
        defb $0d, $00;                  // carriage return, end marker
        
L06D0   defm 'Loading ', 0

L06D9   defm 'NMI', 0, '...'
        defb 0;                                 // end marker

L06E1   ld hl, $2df2;
        push hl;
        rst $08;
        defb disk_info;
        pop hl;

L06E8:
        ld a, (hl);
        and a;
        ret z;
        push hl;
        ld bc, $0000;
        rst $08;
        defb f_mount;
        pop hl;
        ld de, $0006;
        add hl, de;
        jr L06E8;
        call L0714;
        scf;
        ret z;
        ld l, a;
        push hl;
        call L0B19;
        pop hl;
        ret c;
        ld a, l;
        call L07C3;
        ret c;
        xor a;
        push iy;
        pop hl;
        ld (hl), a;
        inc hl;
        ld (hl), a;
        inc hl;
        ld (hl), a;
        or a;
        ret;

L0714:
        push bc;
        ld hl, $2cf0;
        ld bc, $000f;
        cpir;
        pop bc;
        ret nz;
        ld a, $1d;
        ret;

L0722:
        ld hl, $2d00;
        ld b, $0c;

L0727:
        cp (hl);
        jr z, L0730;
        inc hl;
        inc hl;
        inc hl;
        djnz L0727;
        ret;

L0730:
        ld a, $1f;
        scf;
        ret;
        ld l, a;
        push hl;
        push bc;
        call L0722;
        pop bc;
        pop hl;
        ret c;
        ld a, c;
        and a;
        jr z, L0748;
        call L07C3;
        ld a, $0b;
        ccf;
        ret c;

L0748:
        inc c;
        ld a, l;
        ld hl, $2df2;
        push bc;
        push hl;
        rst $08;
        defb disk_info;
        pop hl;
        jr nc, L0756;
        pop bc;
        ret;

L0756:
        call L07E6;
        pop bc;
        ld a, (hl);
        call L077F;
        dec c;
        jr nz, L0769;
        push hl;
        push bc;
        call L07AB;
        pop bc;
        pop hl;
        ld c, a;

L0769:
        ex de, hl;
        ld a, (de);
        push hl;
        push bc;
        call L03EA;
        pop bc;
        pop hl;
        ret c;
        ld (hl), a;
        inc hl;
        ld (hl), c;
        inc hl;
        ld a, b;
        or ixl;
        or %10000000;
        ld (hl), a;
        ld a, c;
        ret;

L077F:
        push hl;
        push bc;
        inc hl;
        and %11100000;
        cp $80;
        jr nz, L079B;
        ld a, (hl);
        bit 7, a;
        ld a, $40;
        jr z, L079B;
        ld b, $40;
        and %00000111;
        cp 5;
        ld a, $30;
        jr nz, L079B;
        ld a, 18h;

L079B:
        dec hl;
        ld c, a;
        ld a, (hl);
        and %11100000;
        cp $60;                                 // £
        jr nz, L07A6;
        ld c, $b0;

L07A6:
        ld a, c;
        pop hl;
        ld c, l;
        pop hl;
        ret;

L07AB:
        ld c, a;
        call L07B4;
        ld a, c;
        ret c;
        inc a;
        jr L07AB;

L07B4:
        ld hl, $2d01;
        ld b, $0c;

L07B9:
        ld a, (hl);
        cp c;
        ret z;
        inc hl;
        inc hl;
        inc hl;
        djnz L07B9;
        scf;
        ret;

L07C3:
        push bc;
        call L07FE;
        jr c, L07D9;
        ld iy, $2d00;
        ld b, $0c;

L07CF:
        cp (iy + _flags);
        jr z, L07DE;
        call L07F7;
        djnz L07CF;

L07D9:
        pop bc;
        ld a, $0b;
        scf;
        ret;

L07DE:
        ld a, (iy + _tv_flag);
        and %00001111;
        or a;
        pop bc;
        ret;

L07E6:
        ld de, $2d00;
        ld b, $0c;

L07EB:
        ld a, (de);
        and a;
        ret z;
        inc de;
        inc de;
        inc de;
        djnz L07EB;
        ld a, $0b;
        scf;
        ret;

L07F7:
        inc iy;
        inc iy;
        inc iy;
        ret;

L07FE:
        ld b, a;
        and a;
        scf;
        ret z;
        cp '*';                                 // use current drive?
        ld a, ($2d46);
        ret z;
        ld a, b;
        cp $24;
        ld a, ($2d4a);
        ret z;
        ld a, b;
        or a;
        ret;
        add a, b


        defm "No SYSTE"
        defb 'M' + $80

L081C:
        inc e;
        ret nz;
        inc d;
        ret nz;
        inc c;
        ret nz;
        inc b;
        ret;

L0824:
        ld a, $ff;
        dec e;
        cp e;
        ret nz;
        dec d;
        cp d;
        ret nz;
        dec c;
        cp c;
        ret nz;
        dec b;
        ret;

L0831:
        add hl, de;
        ex de, hl;
        ret nc;
        inc bc;
        ret;

L0836:
        or a;
        ex de, hl;
        sbc hl, de;
        ex de, hl;
        ret nc;
        dec bc;
        ret;

; called from dirs.io
L083E:
pr_str:
; Output a string of characters, zero terminated
        ld a, (hl);                             // get value at (HL)
        and a;                                  // test for zero
        ret z;                                  // return if zero
        rst $10;                                // print_a
        inc hl;                                 // next address
        jr pr_str;                              // repeat

L0845:
; Jumped to from RST10 - print a character in 'a'
        push hl;
        push de;
        push bc;
        push af;
        push iy;
        ld iy, err_nr;
        rst $18;
        defw print_a;
        pop iy;
        pop af;
        pop bc;
        pop de;
        pop hl;
        ret;

L0859:
        ld c, $30;
        ld h, 0;
        jr L0873;
        ld c, $20;

L0861:;                                         // called from dirs.io
        ld de, $2710;
        call L087D;
        ld de, $03e8;

L086a:
        call L087D;
        ld de, $0064;
        call L087D;

L0873:
        ld de, $000a;
        call L087D;
        ld e, 1;
        ld c, $30;

L087D:
        ld a, $2f;

L087F:
        inc a;
        or a;
        sbc hl, de;
        jr nc, L087F;
        add hl, de;
        cp $3a;
        jr nc, L0894;
        cp $30;
        jr nz, L0896;
        ld a, c;
        or a;
        call nz, L0010;
        ret;

L0894:
        add a, 7;

L0896:
        ld c, $30;
        rst $10;                                // print a character
        ret;

L089A:;                                         // called from dirs.io
        ld a, d;
        or e;
        jr nz, L08AD;
        ld e, h;
        ld h, l;
        ld l, 0;
        sla h;
        rl e;
        rl d;
        call L08D3;
        jr L08CB;

L08AD:
        ld l, h;
        ld h, e;
        ld e, d;
        ld d, 0;
        srl e;
        rr h;
        rr l;
        srl e;
        rr h;
        rr l;
        srl e;
        rr h;
        rr l;
        xor a;
        call L08DA;
        ld a, 'M';
        rst $10;                                // print a character

L08CB:
        ld a, b;
        cp 'B';                                 // $42
        ret z;
        ld a, 'B';
        rst $10;                                // print a character
        ret;

L08D3:
        xor a;
        call L08DA;
        ld a, b;
        rst $10;                                // print a character
        ret;

L08DA:
        ld bc, $4200;
        ex af, af';';
        ld a, e;
        or d;
        jr z, L08F0;
        call L0902;
        ld a, e;
        or a;
        ld b, $4b;
        jr z, L08F0;
        call L0902;
        ld b, $4d;

L08F0:
        push bc;
        ex af, af';';
        ld c, a;
        call L0861;
        pop bc;
        ld a, c;
        or a;
        ret z;
        ld a, '.';
        rst $10;                                // print a character
        ld a, $30;
        add a, c;
        rst $10;                                // print a character
        ret;

L0902:
        xor a;
        ld l, h;

L0904:
        ld h, e;
        ld e, d;
        ld d, a;
        srl e;
        rr h;
        rr l;
        jr nc, L0911;
        add a, 2;

L0911:
        srl e;
        rr h;
        rr l;
        jr nc, L091B;
        add a, 5;

L091B:
        ld c, a;
        ret;
        inc c;
        ld a, (bc);
        ld d, c;
        ld a, (bc);
        ld d, c;
        ld a, (bc);
        ld e, a;
        ld a, (bc);
        add a, e;
        dec bc;
        xor %00001001;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        exx;
        add hl, bc;
        call po, $000a;
        jr nz, L093D;
        jr nz, L0904;
        add hl, bc;
        pop de;
        add hl, bc;
        dec a;
        inc h;

L093D:
        and c;
        ld ($09c8), hl;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        ret z;
        add hl, bc;
        inc (hl);
        rlca;
        ret m;
        ld b, $a2;
        ld a, (bc);
        cp d;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        and d;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        ret nc;
        ld a, (bc);
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        add hl, de;
        dec bc;
        ld b, $0b;
        add hl, de;
        dec bc;

L0985:
; RST08_handler;
        ex (sp), hl;
        ld ($3dfa), a;                  // save parameter in A
        ld a, (hl);                             // retrieve syscall # from position
        ;                                               // after RST instruction
        inc hl;                                 // adjust return address
        ex (sp), hl;                    // and saves it to the stack

L098C:
        push iy;
        push ix;
        sub $80;                                // now A holds the syscall number
        ;                                               // subtract HOOK_BASE from it
        ld iyl, a;                              // so the syscall number begins now at 0
        ;                                               // save in IYl
        ld ix, (mmc_3);
        xor a;
        out (mmcram), a;                // divMMC RAM page 0 at $2000
        ld a, ixl;
        ld (call_num), a;               // Store syscall number
        push ix;
        call L09B4;
        pop ix;
        ld iyl, a;
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page
        ld a, iyl;
        pop ix;
        pop iy;
        ret;

L09B4:
        ld a, iyl;
        push hl;
        ld hl, $091d;
        add a, a;
        add a, l;
        ld l, a;
        jr nc, L09C0;
        inc h;

L09C0:
        ld a, (hl);
        inc hl;
        ld h, (hl);
        ld l, a;
        ld a, ixh;
        ex (sp), hl;
        ret;
        ld a, $14;
        scf;
        ret;
        ld a, ($2e32);
        or a;
        ret;
        ld de, $0000;
        ld bc, $0497;
        or a;
        ret;
        and a;
        jr nz, L09E1;
        ld a, ($2d46);
        or a;
        ret;

L09E1:
        cp '*';                                 // use current drive? test for file commands
        ret z;
        ld c, a;
        call L07C3;
        ret c;
        ld a, c;
        ld ($2d46), a;
        ret;
        and %11111000;
        ld c, a;
        ld hl, $2d00;
        ld b, $0c;

L09F6:
        ld a, (hl);
        inc hl;
        inc hl;
        inc hl;
        and %11111000;
        cp c;
        scf;
        ret z;
        djnz L09F6;
        ld a, c;
        push bc;
        call L0A5F;
        pop bc;
        ret c;
        ld a, c;
        jp L034C;
        ld ($3df4), hl;
        ld ($3dfa), a;
        ld ($3df6), bc;
        ld ($3df2), de;
        call L0363;
        ccf;
        ld a, $1f;
        ret c;
        ld hl, $2d24;

L0A24:
        ld e, (hl);
        inc hl;
        ld d, (hl);
        inc hl;
        ld a, d;
        and a;
        ld a, $0e;
        scf;
        ret z;
        push hl;
        call L0A36;
        pop hl;
        ret nc;
        jr L0A24;

L0A36:
        ld hl, ($3df4);
        ld bc, ($3df6);
        ld a, ($3dfa);
        push de;
        ld de, ($3df2);
        ret;

L0A46:
        push de;
        ld e, iyl;
        ld a, ixh;
        ld ixh, e;
        pop de;
        jp L0358;
        call L0A46;
        ret c;
        push hl;
        call L0A77;
        pop hl;
        jr nc, L0A63;
        ld a, $0a;
        ret;

L0A5F:
        call L0A46;
        ret c;

L0A63:
        push hl;
        ld h, (iy + _err_sp);
        ld a, ixh;
        add a, a;
        add a, (iy + _tv_flag);
        ld l, a;
        jr nc, L0A71;
        inc h;

L0A71:
        ld a, (hl);
        inc hl;
        ld h, (hl);
        ld l, a;
        ex (sp), hl;
        ret;

L0A77:
        push iy;
        pop hl;
        and a;
        jr nz, L0A84;
        ld a, 7;
        add a, l;
        ld l, a;
        jp L0694;

L0A84:
        add a, a;
        add a, a;
        add a, a;
        add a, l;
        ld l, a;
        push hl;
        add a, 7;
        ld l, a;
        call L0694;
        pop hl;
        ret c;
        ld a, (hl);
        inc hl;
        add a, e;
        ld e, a;
        ld a, (hl);
        inc hl;
        adc a, d;
        ld d, a;
        ld a, (hl);
        inc hl;
        adc a, c;
        ld c, a;
        ld a, (hl);
        adc a, b;
        ld b, a;
        ret;
        call L0B19;
        ret c;
        push hl;
        ld hl, $2cf0;
        ld a, ixh;
        push af;
        add a, l;
        ld l, a;
        ld a, iyh;
        ld (hl), a;
        ld a, ixh;
        call L0B73;
        pop af;
        pop hl;
        ret;
        call L0AD0;
        ret c;
        ld a, ixh;
        push af;
        ld hl, $2cf0;
        call L0ACB;
        pop af;
        ld hl, $2e22;

L0ACB:
        add a, l;
        ld l, a;
        xor a;
        ld (hl), a;
        ret;

L0AD0:
        push de;
        ld de, $2cf0;
        add a, e;
        ld e, a;
        ld a, (de);
        and a;
        ld d, a;
        ld a, ixh;
        ld ixh, d;
        jr nz, L0B1E;
        ld a, $0d;

L0AE1:
        pop de;
        scf;
        ret;
        ld de, $2d01;
        ld b, $0c;
        ld c, 0;

L0AEB:
        ld a, (de);
        and a;
        jr z, L0AFF;
        inc c;
        push de;
        push bc;
        ld c, a;
        ld a, ixl;
        out (mmcram), a;                // set divMMC RAM page...
        ld a, c;
        rst $08;
        defb $b2;                               // unknown hook code
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        pop bc;
        pop de;

L0AFF:
        inc de;
        inc de;
        inc de;
        djnz L0AEB;
        ld a, c;
        ret;
        push iy;
        call L07C3;
        pop bc;
        ret c;
        ld a, (iy + _flags);
        ld b, a;
        ld d, (iy + _err_nr);
        ld e, (iy + _tv_flag);
        ld iyl, c;

L0B19:
        call L04E7;
        ret c;
        push de;

L0B1E:
        ld e, a;
        ld d, iyl;
        ld a, ixh;
        cp '*';                                 // use current drive?
        jr nz, L0B2A;
        ld a, ($2d46);

L0B2A:
        call L07C3;
        jr c, L0AE1;
        push af;
        ld a, (iy + _flags);
        ld iyh, a;
        ld iyl, d;
        ld ixh, e;
        pop af;
        pop de;
        push ix;
        push iy;
        out (mmcram), a;                // set divMMC RAM page...
        ld a, ixl;
        ld ($3df8), a;
        ld ($3df4), hl;
        call L037E;
        sub $18;
        ld l, (iy + _tv_flag);
        ld h, (iy + _err_sp);
        add a, a;
        add a, l;
        ld l, a;
        jr nc, L0B5A;
        inc h;

L0B5A:
        ld a, (hl);
        inc hl;
        ld h, (hl);
        ld l, a;
        call L0B6E;
        ld ixh, a;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0;
        ld a, ixh;
        pop iy;
        pop ix;
        ret;

L0B6E:
        push hl;
        ld hl, ($3df4);
        ret;

L0B73:
        ld ixh, a;
        ld hl, $2e22;
        add a, l;
        ld l, a;
        ld a, ixl;
        cp 2;
        ret nz;
        ld a, ixh;
        ld (hl), a;
        ret;
        and a;
        jr z, L0BB8;
        ld b, a;
        call L0358;
        jr nc, L0B8F;

L0B8c:
        ld a, $0e;
        ret;

L0B8F:
        ld c, a;
        ld a, b;
        and %00000111;
        cp c;
        jr c, L0B8c;
        push hl;
        push iy;
        pop hl;
        ld de, $2df2;
        ld a, b;
        ld (de), a;
        inc de;
        inc hl;
        ldi;
        inc hl;
        inc hl;
        and %00000111;
        add a, a;
        add a, a;
        add a, a;
        add a, l;
        ld l, a;
        jr nc, L0BAF;
        inc h;

L0BAF:
        ld bc, $0004;
        ldir;
        ld c, 6;
        jr L0BFE;

L0BB8:
        push hl;
        ld b, 6;
        ld hl, $2c00;
        ld de, $2df2;

L0BC1:
        push bc;
        push hl;
        ld a, (hl);
        inc hl;
        and a;
        jr z, L0BED;
        ld b, a;
        and %11111000;
        ld c, a;
        ld a, b;
        and %00000111;
        ld b, a;
        ld a, (hl);
        ld ixl, a;
        dec hl;
        xor a;

L0BD5:
        push af;
        or c;
        ld (de), a;
        inc de;
        ld a, ixl;
        ld (de), a;
        inc de;
        push bc;
        inc hl;
        inc hl;
        inc hl;
        inc hl;
        ld bc, $0004;
        ldir;
        pop bc;
        pop af;
        cp b;
        inc a;
        jr c, L0BD5;

L0BED:
        pop hl;
        ld bc, $0028;
        add hl, bc;
        pop bc;
        djnz L0BC1;
        xor a;
        ld (de), a;
        inc de;
        ld hl, $0d20e;
        add hl, de;
        ld b, h;
        ld c, l;

L0BFE:
        ld hl, $2df2;
        pop de;
        rst $30;
        ld b, $b7;
        ret;

L0C06:
; based on the Spectrum ROM's main_4 / main_g routine
        ld (err_nr), a;                 // get error number
        res 5, (iy + _flags);   // no new key
        ld sp, (err_sp);                // error stack pointer to SP
        rst $18;                                //
        defw syntax_z;
        ld hl, $16c5;
        jp z, L1FFB;
        ld hl, $0000;                   // used to zero out system variables
        ld (iy + _flag_x), h;   // clear flag_x
        ld (iy + _x_ptr), h;    // clear x_ptr to hide error marker
        ld (defadd), hl;                // set no function to evaluate
        inc l;                                  // LD L, 1
        ld (strms_0), hl;               // keybaord stream
        rst $18;
        defw set_min;
        ld a, (nmiadd);
        and a;
        jp nz, L24CD;
        res 5, (iy + _flag_x);  // no new key
        rst $18;
        defw cls_lower;
        set 5, (iy + _tv_flag);
        res 3, (iy + _tv_flag);
        ld a, (err_nr);
        and a;
        ld hl, ($3de8);
        jr z, L0C82;
        ld b, a;

L0C4d:
        ld a, ($3df9);
        push af;
        xor a;
        out (mmcram), a;                //divMMC memory page 0
        ld hl, $23bd;
        push bc;
        call L2357;
        pop bc;
        jr nc, L0C78;
        cp $0c;
        jr nz, L0C67;
        ld hl, $0caa;
        jr L0C82;

L0C67:
        ld a, b;
        cp 1;
        jr z, L0C78;
        ld hl, $0c9c;
        call pr_msg;
        ld l, b;
        call L0859;
        jr L0C85;

L0C78:
        ld hl, ($2017);

L0C7B:
        bit 7, (hl);
        inc hl;
        jr z, L0C7B;
        djnz L0C7B;

L0C82:
        call pr_msg;

L0C85:
        pop af;
        out (mmcram), a;                //Set divMMC RAM page...
        inc sp;
        inc sp;
        ld hl, $1349;
        jp L1FFB;

L0C90:
pr_msg:;                                        // called from files.io
        ld a, (hl);
        cp $7f;
        push af;
        and $7f;
        rst $10;                                // print a character
        pop af;
        ret nc;
        inc hl;
        jr pr_msg

        defm "ESXDOS error ";
        defb '#' + $80;

        defm "Too many OPEN FILE"
        defb 'S' + $80;

L0Cbd:          
; jumped from RST $18 (CALLBAS)
        ld ($3df2),de;                  // save DE as it will be used right now
        ex (sp),hl;                             // HL = return address from the stack
        ld e, (hl);                             // get 16-bit value
        inc hl;                                 // stored after the RST $18 instruction
        ld d, (hl);                             // and put it in DE
        inc hl;                                 // while advancing the return address to skip
        ;                                               // this value
        ex (sp), hl;                    // replace the new return address into the stack
        push hl;                                // make room in the stack?
        ld hl, $3dfd;                   // Automapper address (immediate mapping)
        ex (sp), hl;                    // Store in the stack.
        push de;                                // Store the address to call to in system ROM
        ;                                               // into the stack
        ld de, ($3df2);                 // Restore saved DE
        jp L1FFA;                               // Jump to auto-unmap address.


; The calling sequence is as follows: after this last jump, a RET instruction
; at $1ffa is executed. While it is being executed, the divMMC is unpaged, so
; the next instruction to fetch will have the system ROM paged in. The address
; fetched from the stack is the one pointing to the desired system ROM routine.
; After this routine ends, the return address fetched from the stack will point
; to 3DFD. This is a TR-DOS trap, which immediately pages divMMC again. $3dfd
; will have a RET instruction also, thus returning to the instruction past the
; immediate 16-bit value after the RST $18 instruction, thus resuming
; execution with divMMC paged in.

L0CD4:
        ld (x_ptr), hl;
        ld l, a;
        ld a, ($3df9);
        ld h, a;
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, h;
        ld ($3df8), a;
        ld a, l;
        ld ($3dfa), a;
        pop hl;
        rst $18;
        defw reentry;
        inc hl;
        push hl;
        cp $0ff;                                // COPY
        jr nz, L0D08;
        ld a, h;
        cp '@';                                 // $40
        jr c, L0D05;
        ld sp, (err_sp);
        ld a, ($3df8);
        out (mmcram), a;                // set divMMC RAM page...

L0CFF:
        ld hl, $16c5;
        jp L1FFB;

L0D05:
        ld a, 1;
        rst $20;

L0D08:
        cp $1b;
        jr c, L0D18;
        push ix;
        pop hl;
        call L098C;
        push hl;
        pop ix;
        jp L1FFA;

L0D18:
        bit 7, (iy + _err_nr);

L0D1c:
        ld (err_nr), a;
        ld hl, (ch_add);
        ld (x_ptr), hl;
        jp z, L0D72;
        cp $0b;
        jr z, L0D39;
        cp $0e;
        jr z, L0D39;
        cp $17;
        jr z, L0D39;
        cp 1;
        jp nz, L0D72;

L0D39:
        bit 5, (iy + 55);
        jp nz, L0D72;
        ld de, (e_line);
        and a;
        sbc hl, de;
        jr c, L0D52;
        rst $18;
        defw e_line_no;
        ld hl, (ch_add);
        dec hl;
        jr L0D5B;

L0D52:
        ld hl, (ppc);
        rst $18;
        defw line_addr
        inc hl;
        inc hl;
        inc hl;

L0D5B:
        ld d, (iy + _subppc);
        ld e, 0;
        rst $18;
        defw each_stmt;
        rst $30;
        inc bc;
        jr nz, $0d6a;
        rst $18;
        defw remove_fp;
        rst $18;
        defw set_work;
        rst $30;
        ld (bc), a;
        call L2014;

L0D72:
        ld a, ($3df8);
        out (mmcram), a;                // set divMMC RAM page...
        res 3, (iy + _tv_flag);
        ld hl, $0058;
        rst $30;
        inc bc;
        jp z, L1FFB;
        ld a, (nmiadd);
        and a;
        jp z, L1FFB;
        set 7, (iy + _err_nr);
        ld hl, $1b7d;
        jp L1FFB;

L0D94:
        call L0DCF;
        jp c, $0020;
        call L0DEB;
        ld hl, ($2e46);
        ld a, 2;
        out (mmcram), a;                // divMMC RAM page 2
        call L2000;
        ld ($3de8), hl;
        jp c, $0020;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        jp L24CD;

L0DB4:
        push hl;
        call L0DCF;
        pop hl;
        jr c, L0DC2;
        ld a, 2;
        out (mmcram), a;                // divMMC RAM page 2
        call L2000;

L0DC2:
        push af;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, ($3df0);
        ld ($3df8), a;
        pop af;
        ret;

L0DCF:
        ld b, a;
        ld a, 2;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, b;
        push bc;
        ld hl, $2000;
        ld bc, $1c00;
        rst $08;
        defb f_read;
        pop bc;
        push af;
        ld a, b;
        rst $08;
        defb f_close;
        pop af;
        ld b, a;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 2
        ld a, b;
        ret;

L0DEB:;                                         // called from dirs.io
        ld a, 2;                                // screen
        rst $18;
        defw chan_open;
        ret;

L0DF1:
        ld d, (hl);
        ld c, $b2;
        ld sp, $16de;
        adc a, a;
        ld d, $97;
        ld d, $de;
        jr L0E40;
        ld sp, $369a;
        add a, $19;
        rst $38;
        dec (hl);
        ld l, (hl);
        ld (hl), $d2;
        inc sp;
        ld (bc), a;
        inc (hl);
        ld b, a;
        dec (hl);
        sub b;
        ld (hl), $94;
        ld (hl), $77;
        ld d, $ad;
        inc sp;
        ei;                                             // interrupts on
        ld ($354c), a;
        ex (sp), hl;
        dec (hl);
        sbc a, l;
        dec (hl);
        ld a, ($a936);
        ld ($31c4), a;
        dec bc;
        dec (hl);
        ld hl, ($290e);
        ld c, $c9;
        ex de, hl;
        ld a, b;
        call L0E4C;
        ld a, d;
        call L0E4C;
        ld a, e;
        call L0E4C;
        push iy;
        pop hl;
        ld l, $18;
        ld bc, $0004;
        rst $30;

L0E40:
        ld b, $2e;
        inc b;
        rst $30;
        inc b;
        ld l, $0c;
        rst $30;
        inc b;
        ex de, hl;
        or a;
        ret;

L0E4C:
        ld hl, $3dfa;
        ld (hl), a;
        ld bc, $0001;
        rst $30;
        ld b, $c9;
        push bc;
        call L0E6D;
        pop bc;
        ret c;
        push hl;
        pop iy;
        ld (hl), c;
        inc l;
        ld (hl), b;
        inc l;
        ld (hl), e;
        inc l;
        ld (hl), d;
        call L0E80;
        ld a, (iy + _flags);
        ret;

L0E6D:
        ld hl, $2000;
        ld b, 4;

L0E72:
        ld a, (hl);
        and a;
        ret z;
        inc h;
        djnz L0E72;
        scf;
        ret;

L0E7A:
        xor a;
        ld (iy + _err_nr), a;
        scf;
        ret;

L0E80:
        ld hl, $2d00;
        ld bc, $0000;
        ld de, $0000;
        push hl;
        call L1096;
        pop hl;
        jr c, L0E7A;
        inc h;
        ld l, $fe;
        ld a, (hl);
        inc l;
        and (hl);
        jr nz, L0E7A;
        dec h;
        ld l, $0b;
        ld a, (hl);
        inc l;
        or (hl);
        cp 2;
        jr nz, L0E7A;
        ld l, $10;
        ld a, (hl);
        cp 2;
        jr nz, L0E7A;
        ld hl, $2d00;
        ld l, $13;
        ld e, (hl);
        inc l;
        ld d, (hl);
        ld a, d;
        or e;
        jr nz, L0EBF;
        ld l, $20;
        rst $30;
        ld bc, $70fd;
        dec de;
        ld (iy + 26), c;

L0EBF:
        ld (iy + 25), d;
        ld (iy + 24), e;
        ld l, $0d;
        ld a, (hl);
        ld (iy + 37), a;
        inc l;
        ld e, (hl);
        inc l;
        ld d, (hl);
        ld (iy + 30), d;
        ld (iy + 29), e;
        ld l, $3a;
        ld a, (hl);
        cp '2';                                 // $50
        jr z, L0E7A;
        dec l;
        ld a, (hl);
        ld l, $36;
        cp '1';                                 // $49
        ld a, 0;
        jr z, L0EE9;
        ld l, $52;
        inc a;

L0EE9:
        ld (iy + 28), a;
        push de;
        push iy;
        pop de;
        ld e, 4;
        ld bc, $0005;
        ldir;
        pop de;
        cp 1;
        jr z, L0F3E;
        push hl;
        ld l, $16;
        ld a, (hl);
        inc l;
        ld h, (hl);
        ld l, a;
        xor a;
        ld (iy + 34), a;
        ld (iy + 33), a;
        ld (iy + 32), h;
        ld (iy + 31), l;
        sla l;
        rl h;
        add hl, de;
        ex de, hl;
        ld (iy + 36), d;
        ld (iy + 35), e;
        pop hl;
        ld l, $11;
        ld a, (hl);
        inc l;
        ld h, (hl);
        ld l, a;
        srl h;
        rr l;
        srl h;
        rr l;
        srl h;
        rr l;
        srl h;
        rr l;
        ld (iy + 66), l;
        ld bc, $0000;
        call L0831;
        jr L0F68;

L0F3E:
        push iy;
        pop de;
        ld e, $26;
        ld l, $2c;
        ldi;
        ldi;
        ldi;
        ldi;
        ld l, $24;
        rst $30;
        ld bc, $70fd;
        ld ($71fd), hl;
        ld hl, $72fd;
        jr nz, $0f58;
        ld (hl), e;
        rra;
        sla e;
        rl d;
        rl c;
        rl b;
        call L1173;

L0F68:
        ld h, 0;
        ld l, (iy + 37);
        sla l;
        rl h;
        call L0836;
        ld (iy + 45), b;
        ld (iy + 44), c;
        ld (iy + 43), d;
        ld (iy + 42), e;
        call L0F8E;
        call L0FBE;
        call L1065;
        call L1021;
        or a;
        ret;

L0F8E:
        ld h, (iy + 25);
        ld l, (iy + 24);
        or a;
        sbc hl, de;
        ex de, hl;
        ld h, (iy + 27);
        ld l, (iy + 26);
        sbc hl, bc;
        ld a, (iy + 37);

L0Fa3:
        srl a;
        jr c, L0FB1;
        srl h;
        rr l;
        rr d;
        rr e;
        jr L0Fa3;

L0FB1:
        ld (iy + 62), e;
        ld (iy + 63), d;
        ld (iy + 64), l;
        ld (iy + 65), h;
        ret;

L0FBE:
        ld a, (iy + 28);
        cp 1;
        jr nz, $100f;
        ld hl, $2d30;
        ld a, (hl);
        dec a;
        jr nz, $100f;
        ld hl, $3e00;
        ld bc, $0000;
        ld de, $0001;
        push hl;
        call L1096;
        pop hl;
        jr c, $100f;
        inc h;
        ld l, $e4;
        ld a, (hl);
        inc l;
        xor (hl);
        inc l;
        add a, (hl);
        inc l;
        and (hl);
        cp 'A';                                 // $41
        jr nz, $100f;
        ld l, $fe;
        ld a, (hl);
        inc l;
        and (hl);
        jr nz, $100f;
        ld a, 1;
        ld (iy + 61), a;
        ld a, ($2d41);
        and %00000001;
        jr nz, $100f;
        ld l, $e8;
        rst $30;
        ld bc, $b178;
        or d;
        or e;
        jr z, $100f;
        call L11D0;
        rst $30;
        ld bc, $b6c3;
        ld de, $ff01;
        rst $38;
        ld de, $ffff;
        call L11D0;
        ld bc, $0000;
        ld de, $0002;
        jp L11B6;

L1021:
        ld hl, $1416;
        ld a, 8;
        call L1470;
        jr nc, L102E;
        ld hl, $2d2b;

L102E:
        push iy;
        pop de;
        ld e, $0c;
        ld a, (hl);
        and a;
        jr nz, L103A;

L1037:
        ld hl, $105c;

L103A:
        call L103E;
        ret;

L103E:
        ld b, $0b;

L1040:
        ld a, (hl);
        cp ' ';                                 // $20
        jr z, L104B;

L1045:
        ld (de), a;
        inc hl;
        inc de;
        djnz L1040;
        ret;

L104B:
        inc hl;
        ld a, (hl);
        cp ' ';                                 // $20
        dec hl;
        ld a, (hl);
        jr nz, L1045;
        ld a, b;
        cp $0b;
        jr z, L1037;
        ld a, 0;
        ld (de), a;
        ret;
        ld d, l;
        ld c, (hl);
        ld c, (hl);
        ld b, c;
        ld c, l;
        ld b, l;
        ld b, h;
        jr nz, L1085;

L1065:
        call L1169;
        call L107B;
        push iy;
        pop hl;
        ld l, $80;
        ld a, $2f;
        ld (hl), a;
        inc l;
        ld a, l;
        ld (iy + 127), l;
        xor a;
        ld (hl), a;
        ret;

L107B:
        ld a, (iy + 28);
        cp 1;
        jr nz, L1089;
        ld a, b;
        or c;
        or d;

L1085:
        or e;
        call z, L1169;

L1089:
        ld (iy + 49), b;
        ld (iy + 48), c;
        ld (iy + 47), d;
        ld (iy + 46), e;
        ret;

L1096:
        push bc;
        push de;
        ld a, (iy + _flags);
        rst $08;
        defb disk_read;
        pop de;
        pop bc;
        ret;

L10A0:
        ld a, (iy + _flags);
        rst $08;
        defb disk_write;
        ret;

L10A6:
        push bc;
        push de;
        ld a, ($3c25);
        rst $08;
        defb disk_write;
        pop de;
        pop bc;
        ret;

L10B0:
        call L117F;
        jr L10A6;

L10B5:
        call L117F;
        jr L1096;

L10BA:
        ld a, ($3c25);
        cp (iy + _flags);
        jr nz, L10C8;
        ld hl, $3c14;
        call L0694;

L10C8:
        ld hl, $2800;
        ccf;
        ret z;
        call L10F3;
        ret c;
        push de;
        push bc;
        push hl;
        call L1173;
        push hl;
        call L1096;
        pop hl;
        call c, L10B5;
        pop hl;
        pop bc;
        pop de;
        push af;
        ld a, (iy + _flags);
        ld ($3c25), a;
        ld ($3c11), de;
        ld ($3c13), bc;
        pop af;
        ret;

L10F3:
        ld a, ($3c2b);
        or a;
        ret z;
        push bc;
        push de;
        push hl;
        ld de, ($3c11);
        ld bc, ($3c13);
        call L1111;
        pop hl;
        pop de;
        pop bc;
        ret;

L110A:
        ld a, $ff;
        ld ($3c2b), a;
        or a;
        ret;

L1111:
        xor a;
        ld ($3c2b), a;
        ld hl, $2800;
        push de;
        push bc;
        push hl;
        call L1173;
        push hl;
        call L10A6;
        pop hl;
        jr c, L1129;
        call L10B0;
        or a;

L1129:
        call c, L10B0;
        jr c, L1131;
        call L11DD;

L1131:
        pop hl;
        pop bc;
        pop de;
        ret;

L1135:
        ld (ix + 20), e;
        ld (ix + 21), d;
        ld (ix + 22), c;
        ld (ix + 23), b;
        ret;

L1142:
        ld e, (ix + 20);
        ld d, (ix + 21);
        ld c, (ix + 22);
        ld b, (ix + 23);
        ret;

L114F:
        ld (ix + 24), e;
        ld (ix + 25), d;
        ld (ix + 26), c;
        ld (ix + 27), b;
        ret;

L115C:
        ld e, (ix + 24);
        ld d, (ix + 25);
        ld c, (ix + 26);
        ld b, (ix + 27);
        ret;

L1169:
        push hl;
        push iy;
        pop hl;
        ld l, $26;
        rst $30;
        ld bc, $c9e1;

L1173:
        push hl;
        ld l, (iy + 29);
        ld h, (iy + 30);
        call L0831;
        pop hl;
        ret;

L117F:
        push hl;
        push bc;
        push de;
        call L118F;
        pop hl;
        add hl, de;
        ex de, hl;
        pop hl;
        adc hl, bc;
        ld b, h;
        ld c, l;
        pop hl;
        ret;

L118F:
        ld e, (iy + 31);
        ld d, (iy + 32);
        ld c, (iy + 33);
        ld b, (iy + 34);
        ret;

L119C:
        ld b, (iy + 49);
        ld c, (iy + 48);
        ld d, (iy + 47);
        ld e, (iy + 46);
        ret;

L11A9:
        ld e, (iy + 53);
        ld d, (iy + 54);
        ld c, (iy + 55);
        ld b, (iy + 56);
        ret;

L11B6:
        ld (iy + 53), e;
        ld (iy + 54), d;
        ld (iy + 55), c;
        ld (iy + 56), b;
        ret;

L11C3:
        ld e, (iy + 57);
        ld d, (iy + 58);
        ld c, (iy + 59);
        ld b, (iy + 60);
        ret;

L11D0:
        ld (iy + 57), e;
        ld (iy + 58), d;
        ld (iy + 59), c;
        ld (iy + 60), b;
        ret;

L11DD:
        ld a, (iy + 61);
        or a;
        ret z;
        ld hl, $3fe8;
        call L11C3;
        rst $30;
        nop;
        call L11A9;
        rst $30;
        nop;
        ld hl, $3e00;
        ld bc, $0000;
        ld de, $0001;
        jp L10A0;

L11FB:
        call L115C;
        call L1096;
        ret;

L1202:
        call L115C;
        ld a, ($3c26);
        cp (iy + _flags);
        jr nz, L1213;
        ld hl, $3c2a;
        call L0694;

L1213:
        ld hl, $2a00;
        ccf;
        ret z;
        ld a, (iy + _flags);
        ld ($3c26), a;
        ld ($3c27), de;
        ld ($3c29), bc;
        push hl;
        call L11FB;
        pop hl;
        ret;

L122C:
        push hl;
        ld hl, $2a00;
        call $313c;
        pop hl;
        ret;

L1235:
        call L115C;
        ld a, (iy + _flags);
        exx;
        push bc;
        push de;
        ld c, mmcram;
        ld de, ($3df8);
        out (c), e;                             // set divMMC RAM page...
        exx;
        rst $08;
        defb disk_read;
        exx;
        out (c), d;                             // set divMMC RAM page...
        pop de;
        pop bc;
        exx;
        ret;

L1250:
        dec (ix + 19);
        jr z, L125E;
        call L115C;
        call $081c;
        jp L114F;

L125E:
        call L12B2;
        ret c;
        jp L12A9;

L1265:
        ld a, (iy + 28);
        cp 1;
        jr z, L127D;
        ld a, e;
        or d;
        jr nz, L127D;
        ld bc, $0000;
        ld d, (iy + 36);
        ld e, (iy + 35);
        ld a, (iy + 66);
        ret;

L127D:
        ld a, (iy + 37);

L1280:
        srl a;
        jr c, L128E;
        sla e;
        rl d;
        rl c;
        rl b;
        jr L1280;

L128E:
        ld a, (iy + 42);
        add a, e;
        ld e, a;
        ld a, (iy + 43);
        adc a, d;
        ld d, a;
        ld a, (iy + 44);
        adc a, c;
        ld c, a;
        ld a, (iy + 45);
        adc a, b;
        ld b, a;
        ld a, (iy + 37);
        ret;

L12A6:
        call L1135;

L12A9:
        call L1265;
        ld (ix + 19), a;
        jp L114F;

L12B2:
        call L1142;
        call L12C7;
        jp nc, L1135;
        cp $80;                                 // empty block graphic, 128d
        scf;
        ret nz;
        bit 2, (ix + 1);
        ret z;
        jp $3000;

L12C7:
        ld a, (iy + 28);
        cp 1;
        jr z, L12F4;
        push de;
        ld e, d;
        ld d, c;
        ld c, b;
        ld b, 0;
        call L10BA;
        pop de;
        ret c;
        xor a;
        sla e;
        ld l, e;
        adc a, h;
        ld h, a;
        ld e, (hl);
        inc hl;
        ld d, (hl);
        dec hl;
        ld bc, $0000;
        ld a, d;

L12E7:
        cp $ff;                                 // COPY
        ccf;
        ret nz;
        ld a, e;
        and %11110000;
        cp $f0;                                 // LIST
        ccf;
        ld a, $80;
        ret;

L12F4:
        push de;
        ld a, e;
        ld e, d;
        ld d, c;
        ld c, b;
        ld b, 0;
        sla a;
        rl e;
        rl d;
        rl c;
        rl b;
        call L10BA;
        pop de;
        ret c;
        xor a;
        sla e;
        sla e;
        ld l, e;
        adc a, h;
        ld h, a;
        push hl;
        rst $30;
        ld bc, $78e1;
        cp $0f;
        jr nz, L12E7;
        ld a, $ff;
        and c;
        and d;
        jr L12E7;

L1321:
        push de;
        call L11C3;
        inc b;
        jr z, L1332;
        dec b;
        call c, $081c;
        call nc, L0824;
        call L11D0;

L1332:
        pop de;
        ret;

L1334:
        push bc;
        push de;
        call L11C3;
        rst $30;
        dec c;
        pop de;
        pop bc;
        ret nz;
        ld a, 9;
        scf;
        ret;

L1342:
        call L115C;
        ld a, (iy + _flags);
        exx;
        push bc;
        push de;
        ld c, mmcram;
        ld de, ($3df8);
        out (c), e;                             // set divMMC RAM page...
        exx;
        rst $08;
        defb disk_write;
        exx;
        out (c), d;                             // set divMMC RAM page...
        pop de;
        pop bc;
        exx;
        ret;

L135D:
        call L11A9;
        call L12C7;
        call $305e;
        ret c;
        ld h, d;
        ld l, e;
        ld a, $ff;
        call $30e2;
        push de;
        ld de, ($3c11);
        ld bc, ($3c13);
        push bc;
        push de;
        call L110A;
        pop de;
        pop bc;
        pop hl;
        ret c;

L1380:
        rr h;
        rr l;
        ld a, (iy + 28);
        cp 1;
        jr nz, L1395;
        srl b;
        rr c;
        rr d;
        rr e;
        rr l;

L1395:
        ld b, c;
        ld c, d;
        ld d, e;
        ld e, l;
        or a;
        ret;

L139B:
        ld b, 8;
        call L13E2;
        call L13AB;
        ld a, (hl);
        cp '.';                                 // external command?
        jr nz, L13A9;
        inc hl;

L13A9:
        ld b, 3;

L13AB:
        ld a, (hl);
        ld c, $20;
        cp '.';                                 // $2e
        jr z, L13DB;
        and a;
        jr z, L13DB;
        cp '/';                                 // $2f
        jr z, L13DB;
        call L13F8;
        jr nc, L13C2;

L13BE:
        scf;
        ld a, 7;
        ret;

L13C2:
        cp 'a';                                 // $61
        jr c, L13CC;
        cp '{';                                 // $7b
        jr nc, L13CC;
        and %11011111;

L13CC:
        ld (de), a;
        inc de;
        inc hl;
        djnz L13AB;
        ld a, (hl);
        and a;
        jr z, L13D9;
        cp '/';                                 // $2f
        jr nz, L13BE;

L13D9:
        or a;
        ret;

L13DB:
        ld a, c;

L13DC:
        ld (de), a;
        inc de;
        djnz L13DC;
        or a;
        ret;

L13E2:
        ld a, (hl);
        cp '.';                                 // external command?
        ret nz;
        ld bc, $0b00;
        ldi;
        cp (hl);
        jr nz, L13F1;
        ldi;
        dec b;

L13F1:
        ld c, $20;
        call L13DB;
        pop bc;
        ret;

L13F8:
        cp '!';                                 // $21
        ret c;
        push bc;
        push hl;
        ld hl, $140b;
        ld bc, $000c;
        scf;
        cpir;
        pop hl;
        pop bc;
        ret z;
        ccf;
        ret;
        ccf;
        ld ($3a2f), hl;
        dec sp;
        inc l;
        inc a;
        ld a, $5c;
        ld a, h;
        ld l, $2a;

L1417:
        push de;
        push hl;
        push bc;
        ld b, $0b;

L141C:
        ld a, (de);
        cp '*';                                 // use current drive?
        jr z, L1428;
        cp (hl);
        jr nz, L1428;
        inc de;
        inc hl;
        djnz L141C;

L1428:
        pop bc;
        pop hl;
        pop de;
        ret;

L142C:
        ld b, a;
        push bc;
        push hl;
        call L1142;
        ld hl, $3c22;
        call L0694;
        pop hl;
        pop bc;
        ld a, b;
        jr z, L143F;
        or a;
        ret;

L143F:
        ld a, $13;
        ret;

L1442:
        ld b, a;
        push bc;
        push hl;
        call L1142;
        push iy;
        pop hl;
        ld l, $29;
        call L0694;
        jr nz, L145D;
        pop hl;
        push hl;
        ld a, (hl);
        cp '.';                                 // $2e
        jr nz, L145D;
        inc l;
        ld a, (hl);
        cp ' ';                                 // $20

L145D:
        pop hl;
        pop bc;
        ld a, b;
        ret;

L1461:
        ld de, $2f00;
        push de;
        exx;
        call L1169;
        exx;
        call $336d;
        pop hl;
        or a;
        ret;

L1470:
        push af;
        call L119C;
        call L19ED;
        call L12A6;
        pop af;

L147B:
        call L1442;
        jr z, L1461;
        call L142C;
        ret c;
        res 2, (ix + 1);
        ld (iy + 51), a;
        res 1, (iy + 52);
        ld ($3c04), hl;

L1492:
        ld a, $11;
        ld (ix + 6), a;
        ld hl, $2600;
        push hl;
        call L11FB;
        pop hl;
        ret c;

L14A0:
        dec (ix + 6);
        jr nz, L14AA;
        call L1250;
        jr L1492;

L14AA:
        ld a, (hl);
        and a;
        jr z, L1505;
        cp 229;                                 // RESTORE, $e5
        jr z, L14C3;
        ld c, l;
        ld a, l;
        add a, 11;
        ld l, a;
        ld a, (hl);
        ld l, c;
        cp 15;                                  // $0f
        jr nz, L14EA;

L14BD:
        ld bc, $0020;
        add hl, bc;
        jr L14A0;

L14C3:
        call L14C8;
        jr L14BD;

L14C8:
        bit 1, (iy + 52);
        ret nz;
        set 1, (iy + 52);
        ld a, (ix + 6);
        ld (ix + 30), a;
        ld a, (ix + 19);
        ld (ix + 31), a;
        call L115C;
        call L19D3;
        call L1142;
        call L19B9;
        ret;

L14EA:
        ld e, a;
        ld a, (iy + 51);
        and a;
        jr z, L14F4;
        and e;
        jr z, L14BD;

L14F4:
        ld de, ($3c04);
        call L1417;
        jr nz, L14BD;
        ld (ix + 28), l;
        ld (ix + 29), h;
        or a;
        ret;

L1505:
        call L14C8;
        ld a, (ix + 30);
        ld (ix + 6), a;
        ld a, (ix + 31);
        ld (ix + 19), a;
        call L19E0;
        call L114F;
        call L19C6;
        call L1135;
        ld a, 5;
        scf;
        ret;

L1524:
        ld bc, $ffff;
        ld ($3c1f), bc;
        ld ($3c20), bc;

L152F:
        ld de, $2c00;
        push de;
        rst $30;
        dec b;
        pop hl;
        ld (iy + 52), a;
        rra;
        jr nc, L1555;
        push hl;
        push iy;
        pop hl;
        ld l, $80;
        ld de, $2c80;
        push de;
        ld a, (iy + 127);               // FIXME negative offset 
        push af;
        sub $80;
        ld b, 0;
        ld c, a;
        ldir;
        pop af;
        pop de;
        ld e, a;
        pop hl;

L1555:
        xor a;
        ld (ix + 29), a;
        ld a, (hl);
        and a;
        jp z, L1609;
        cp '/';                                 // $2f
        jr nz, L156E;
        bit 0, (iy + 52);
        jr z, L156D;
        cp a;
        ld e, $80;
        ld (de), a;
        inc de;

L156D:
        inc hl;

L156E:
        ld ($3dea), de;
        call z, L1169;
        call nz, L119C;

L1578:
        ld ($3dec), hl;
        ld a, (hl);
        and a;
        jp z, L160D;
        call L19ED;
        call L12A6;
        ld de, $3c06;
        push de;
        call L139B;
        pop de;
        ret c;
        push hl;
        ex de, hl;
        xor a;
        call L147B;
        pop de;
        jp c, L162E;
        ld c, l;
        ld a, l;
        add a, $0b;
        ld l, a;
        bit 4, (hl);
        ld l, c;
        ex de, hl;
        jr nz, L15B5;
        ld a, (hl);
        and a;
        jr z, L15AC;
        ld a, $13;
        scf;
        ret;

L15AC:
        ld a, (iy + 52);
        rla;
        ld a, $11;
        ret c;
        jr L1615;

L15B5:
        bit 0, (iy + 52);
        jr z, L15FC;
        push hl;
        ld hl, ($3dec);
        ld de, ($3dea);
        ld a, (hl);
        cp '.';                                 // external command?
        jr z, L15D5;

L15C8:
        ld a, (hl);
        inc hl;
        and a;
        jr z, L15E8;
        cp '/';                                 // $2f
        jr z, L15E8;
        ld (de), a;
        inc de;
        jr L15C8;

L15D5:
        inc hl;
        ld a, (hl);
        cp '.';                                 // $2e
        jr nz, L15EC;
        dec de;
        dec de;

L15DD:
        ld a, (de);
        cp '/';                                 // $2f
        jr z, L15E5;
        dec de;
        jr L15DD;

L15E5:
        inc de;
        jr L15EC;

L15E8:
        ld a, $2f;
        ld (de), a;
        inc de;

L15EC:
        ld ($3dea), de;
        pop hl;
        ld a, e;
        cp $81;
        ld a, $15;
        ret c;
        call z, L1169;
        jr z, L15FF;

L15FC:
        call L163E;

L15FF:
        ld a, (hl);
        and a;
        jr z, L160D;
        cp '/';                                 // $2f
        inc hl;
        jp z, L1578;

L1609:
        scf;
        ld a, $13;
        ret;

L160D:
        ld a, (iy + 52);
        rla;
        ccf;
        ld a, $10;
        ret c;

L1615:
        call L161A;
        or a;
        ret;

L161A:
        bit 0, (iy + 52);
        ret z;
        ld hl, ($3dec);
        ld de, ($3dea);

L1626:
        ld a, (hl);
        ld (de), a;
        inc hl;
        inc de;
        or a;
        ret z;
        jr L1626;

L162E:
        ex de, hl;
        ld a, (hl);
        and a;
        jr z, L1637;
        scf;
        ld a, $13;
        ret;

L1637:
        call L161A;
        scf;
        ld a, 5;
        ret;

L163E:
        push hl;
        ld a, (ix + 29);
        and a;
        jr nz, L164A;
        call L1169;
        jr L1654;

L164A:
        ld h, a;
        ld a, (ix + 28);
        add a, $14;
        ld l, a;
        call L165F;

L1654:
        pop hl;

L1655:
        ld a, (iy + 28);
        cp 1;
        ret z;
        ld bc, $0000;
        ret;

L165F:
        call L166B;
        ld a, b;
        or c;
        or d;
        or e;
        call z, L1169;
        jr L1655;

L166B:
        ld c, (hl);
        inc l;
        ld b, (hl);
        ld a, l;
        add a, 5;
        ld l, a;
        ld e, (hl);
        inc l;
        ld d, (hl);
        inc l;
        ret;
        ex de, hl;
        push iy;
        pop hl;
        ld l, $80;
        rst $30;
        inc b;
        or a;
        ret;

L1681:
        push hl;
        set 5, (ix + 1);
        call L18EE;
        res 5, (ix + 1);
        pop hl;
        ret;

L168F:
        call L1697;
        ld (ix + 0), 0;
        ret;

L1697:
        or a;

L1699 equ $1699

        bit 3, (ix + 1);
        jp z, L10F3;
        call L16CB;
        ret c;
        ld de, $0014;
        add hl, de;
        call L19FA;
        ld (hl), c;
        inc hl;
        ld (hl), b;
        inc hl;
        inc hl;
        inc hl;
        inc hl;
        inc hl;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        inc hl;
        call L19E0;
        rst $30;
        nop;
        call L17E7;

L16BE:
        push af;
        ld hl, $3c1b;
        rst $30;
        ld bc, $4fcd;
        ld de, $c3f1;
        di;                                             // interrupts off

L16CB equ $16cb

        djnz L1699;
        ld e, h;
        ld de, $1b21;
        inc a;
        rst $30;
        nop;
        call L1A14;
        call L114F;
        call L17F4;
        ex de, hl;
        ret;

L16DE:
        ld a, b;
        ld ($3c01), a;
        ld ($3c23), de;
        ld a, 1;
        call L1524;
        jr nc, L16FD;
        cp 5;
        scf;
        ret nz;
        ld a, ($3c01);
        and %00001100;
        scf;
        ld a, 5;
        ret z;
        jp L1712;

L16FD:
        ld a, ($3c01);
        and %00001100;
        cp 4;
        jr nz, L170A;
        scf;
        ld a, $12;
        ret;

L170A:
        cp $0c;
        jp z, L1815;
        jp L184A;

L1712:
        call L1334;
        ret c;
        call L17F4;
        ret c;
        ld a, (de);
        push af;
        call L17A0;
        pop de;
        ret c;
        ld a, d;
        cp $e5;                                 // RESTORE
        jr z, L172A;
        call L177A;
        ret c;

L172A:
        ld hl, $3c1b;
        rst $30;
        ld bc, $07cd;
        ld a, (de);
        call L17DB;
        call L19B9;
        ld a, ($3c01);
        push af;
        and %00000011;
        or %00000010;
        ld (ix + 1), a;
        pop af;
        or a;
        bit 6, a;
        jr z, L1767;
        call $34ca;
        call $3192;
        ret c;
        ld hl, $2d00;
        call $313c;
        ret c;
        set 3, (ix + 1);
        ld a, $80;
        ld (ix + 11), a;
        ld (ix + 15), a;
        call L1697;
        ret c;

L1767:
        call L1773;
        ld hl, $2c80;
        ld a, ($3df9);
        ld b, a;
        or a;
        ret;

L1773:
        ld a, (iy + _err_nr);
        ld (ix + 0), a;
        ret;

L177A:
        ld a, h;
        and %00000001;
        add a, l;
        ld bc, L001F;
        jr nz, L1794;
        set 2, (ix + 1);
        call L1250;
        res 2, (ix + 1);
        ld hl, $2600;
        ld bc, $01ff;

L1794:
        ld a, (hl);
        ld d, h;
        ld e, l;
        inc de;
        ld (hl), 0;
        ldir;
        call L17E7;
        ret;

L17A0:
        ld hl, $3c06;
        ld bc, $000b;
        ldir;
        xor a;
        ld (de), a;
        ex de, hl;
        inc hl;

L17AC:
        ld (hl), a;
        inc hl;
        ld (hl), a;
        inc hl;
        rst $08;
        defb m_getdate;
        rst $30;
        nop;
        xor a;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc l;
        rst $30;
        nop;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc l;
        ld b, a;
        ld c, b;
        ld d, c;
        ld e, d;
        rst $30;
        nop;
        push hl;
        call L17E7;
        pop hl;
        ret c;
        push hl;
        call L115C;
        ld hl, $3c1b;
        rst $30;
        nop;
        pop hl;
        or a;
        ret;

L17DB:
        ld b, 0;
        ld c, b;
        ld d, c;
        ld e, d;
        call L1135;
        call L19D3;
        ret;

L17E7:
        ld hl, $2600;
        call $313c;
        push af;
        xor a;
        ld ($3c26), a;
        pop af;
        ret;

L17F4:
        ld hl, $2600;
        push hl;
        call L11FB;
        pop hl;
        ret c;

L17FD:
        ld a, $10;
        sub (ix + 6);
        sla a;
        sla a;
        sla a;
        sla a;
        sla a;
        ld e, a;
        ld d, 0;
        rl d;
        add hl, de;
        ex de, hl;
        or a;
        ret;

L1815:
        call L163E;
        push bc;
        push de;
        ld l, (ix + 28);
        ld h, (ix + 29);
        ld de, $000c;
        add hl, de;
        call L17AC;
        pop de;
        pop bc;
        ret c;
        call $3108;
        call nc, L10F3;
        ret c;
        call L17DB;
        call L19B9;
        call L1773;
        ld hl, $1a7c;
        ld ($3dee), hl;
        call L1A21;
        ld (ix + 0), 0;
        jp L172A;

L184A:
        ld a, ($3c01);
        push af;
        and %00000011;
        ld (ix + 1), a;
        call L115C;
        call L1A07;
        call L163E;
        call L18D0;
        ld l, (ix + 28);
        ld h, (ix + 29);
        ld de, $001c;
        add hl, de;
        call L1897;
        pop af;
        bit 6, a;
        jr z, $1894;
        ld hl, $2d00;
        ld bc, $0080;
        call L1681;
        ret c;
        call L18B3;
        ld l, $0f;
        jr z, L188B;
        ld (ix + 15), 0;
        push hl;
        call L189E;
        pop hl;

L188B:
        ld de, ($3c23);
        ld bc, $0008;
        rst $30;
        ld b, $c3;
        ld h, a;
        rla;

L1897:
        rst $30;
        ld bc, $d3cd;
        add hl, de;
        or a;
        ret;

L189E:
        push af;
        ld a, $ff;
        ld (hl), a;
        inc l;
        call L19E0;
        ld (hl), e;
        inc l;
        ld (hl), d;
        inc l;
        ld b, 5;
        xor a;

L18AD:
        ld (hl), a;
        inc l;
        djnz L18AD;
        pop af;
        ret;

L18B3:
        push hl;
        ld de, $0040;
        ld bc, $0009;

L18BA:
        ld a, (de);
        cpi;
        jr nz, L18C3;
        inc de;
        jp pe, L18BA;

L18C3:
        pop hl;
        ret nz;
        ld c, $7f;
        xor a;

L18C8:
        add a, (hl);
        cpi;
        jp pe, L18C8;
        cp (hl);
        ret;

L18D0:
        call L19ED;
        call L12A6;
        ld b, 0;
        ld c, b;
        ld d, c;
        ld e, d;
        jp L19B9;
        bit 0, (ix + 1);
        ld a, 8;
        scf;
        ret z;
        push hl;
        call L1989;
        pop hl;
        ld a, b;
        or c;
        ret z;

L18EE:
        res 2, (ix + 1);

L18F2:
        push bc;

L18F3:
        ld e, (ix + 15);
        ld a, (ix + 16);
        and %00000001;
        ld d, a;
        call L1934;
        jr c, L1929;
        push bc;
        push hl;
        ld hl, $0200;
        sbc hl, de;
        ex de, hl;
        ld h, b;
        ld l, c;
        sbc hl, de;
        jr c, L1911;
        ld b, d;
        ld c, e;

L1911:
        pop hl;
        push bc;
        call L1945;
        pop de;
        pop bc;
        jr c, L1929;
        ld a, c;
        sub e;
        ld c, a;
        ld a, b;
        sbc a, d;
        ld b, a;
        or c;
        ex de, hl;
        call L19AB;
        ex de, hl;
        jr nz, L18F3;
        or a;

L1929:
        pop de;
        push af;
        ex de, hl;
        or a;
        sbc hl, bc;
        ld b, h;
        ld c, l;
        ex de, hl;
        pop af;
        ret;

L1934:
        or e;
        ret nz;
        push de;
        push bc;
        push hl;
        call L19C6;
        rst $30;
        dec c;
        call nz, L1250;
        pop hl;
        pop bc;
        pop de;
        ret;

L1945:
        ld a, b;
        sub 2;
        or c;
        jr nz, L195c;
        bit 2, (ix + 1);
        jp nz, L1342;
        bit 5, (ix + 1);
        jp nz, L11FB;
        jp L1235;

L195c:
        push bc;
        push hl;
        call L1202;
        pop de;
        pop bc;
        ret c;
        ld l, (ix + 15);
        ld a, (ix + 16);
        and %00000001;
        add a, h;
        ld h, a;
        bit 2, (ix + 1);
        jr nz, L1983;
        bit 5, (ix + 1);
        jr z, L197F;
        ldir;
        ex de, hl;
        or a;
        ret;

L197F:
        rst $30;
        ld b, mmcspi;
        ret;

L1983:
        ex de, hl;
        rst $30;
        rlca;
        jp L122C;

L1989:
        push bc;
        call L19C6;
        ld h, (ix + 12);
        ld l, (ix + 11);
        or a;
        sbc hl, de;
        ex de, hl;
        ld h, (ix + 14);
        ld l, (ix + 13);
        sbc hl, bc;
        pop bc;
        ld a, h;
        or l;
        ret nz;
        ld h, d;
        ld l, e;
        sbc hl, bc;
        ret nc;
        ld b, d;
        ld c, e;
        ret;

L19AB:
        push de;
        push bc;
        call L19C6;
        call L0831;
        call L19B9;
        pop bc;
        pop de;
        ret;

L19B9:
        ld (ix + 15), e;
        ld (ix + 16), d;
        ld (ix + 17), c;
        ld (ix + 18), b;
        ret;

L19C6:
        ld e, (ix + 15);
        ld d, (ix + 16);
        ld c, (ix + 17);
        ld b, (ix + 18);
        ret;

L19D3:
        ld (ix + 11), e;
        ld (ix + 12), d;
        ld (ix + 13), c;
        ld (ix + 14), b;
        ret;

L19E0:
        ld e, (ix + 11);
        ld d, (ix + 12);
        ld c, (ix + 13);
        ld b, (ix + 14);
        ret;

L19ED:
        ld (ix + 7), e;
        ld (ix + 8), d;
        ld (ix + 9), c;
        ld (ix + 10), b;
        ret;

L19FA:
        ld e, (ix + 7);
        ld d, (ix + 8);
        ld c, (ix + 9);
        ld b, (ix + 10);
        ret;

L1A07:
        ld (ix + 2), e;
        ld (ix + 3), d;
        ld (ix + 4), c;
        ld (ix + 5), b;
        ret;

L1A14:
        ld e, (ix + 2);
        ld d, (ix + 3);
        ld c, (ix + 4);
        ld b, (ix + 5);
        ret;

L1A21:
        push bc;
        push de;
        ld hl, $2420;
        ld b, $0f;

L1A28:
        ld a, (hl);
        and a;
        jr z, L1A39;
        ld a, ixh;
        cp h;
        jr nz, L1A36;
        ld a, ixl;
        cp l;
        jr z, L1A39;

L1A36:
        call L1A43;

L1A39:
        ld de, $0020;
        add hl, de;
        djnz L1A28;
        pop de;
        pop bc;
        or a;
        ret;

L1A43:
        ld a, (hl);
        cp (ix + 00);
        ret nz;
        push hl;
        ld a, 6;
        add a, l;
        ld l, a;
        ld a, (hl);
        cp (ix + 6);
        pop hl;
        ret nz;
        push bc;
        push hl;
        ld a, 5;
        add a, l;
        ld l, a;
        call L1A14;
        call L0694;
        call z, L0028;
        pop hl;
        pop bc;
        ret;
        pop hl;
        pop hl;
        pop hl;
        pop hl;
        pop de;
        pop bc;
        scf;
        ret;
        dec l;
        dec l;
        dec l;
        res 4, (hl);
        ld a, $0a;
        add a, l;
        ld l, a;
        call L19E0;
        jp L06A9;
        dec l;
        dec l;
        dec l;
        set 4, (hl);
        res 3, (hl);
        ld a, 6;
        add a, l;
        ld l, a;
        ex de, hl;
        push ix;
        pop hl;
        ld a, 7;
        add a, l;
        ld l, a;
        ld bc, L0015;
        ldir;
        ret;
        dec d;
        dec h;
        ret;
        ld a, (de);
        and e;
        ld a, (de);
        and c;
        ld a, (de);
        nop;
        nop;
        rrca;
        dec h;
        or a;
        ret;
        call L1B13;
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page...
        ld a, ($3df8);
        ld ixh, a;
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        call L1AF4;
        ret c;
        ld e, (iy + _newppc);
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page...
        ld a, e;
        push de;
        rst $08;
        defb f_write;
        pop de;
        push af;
        ld a, e;
        rst $08;
        defb f_sync;
        pop af;
        jr L1AE6;
        call L1B13;
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page...
        ld a, ($3df8);
        ld ixh, a;
        xor a;
        out (mmcram), a;                // divMMC RAM page 0
        call L1AF4;
        ret c;
        ld e, (iy + _newppc);
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page...
        ld a, e;
        rst $08;
        defb f_read;

L1AE6:
        ld iyl, a;

L1AE8:
        ld a, ixh;
        ld ($3df8), a;
        ld a, 0;
        out (mmcram), a;                // divMMC RAM page 0
        ld a, iyl;
        ret;

L1AF4:
        ld a, (iy + _newppc);
        push hl;
        ld l, 0;
        rst $08;
        defb f_seek;
        pop hl;
        ret c;
        push hl;
        ld hl, $0080;
        ld a, (iy + _flags);
        and %00000111;
        dec a;
        jr z, L1B0E;

L1B0A:
        add hl, hl;
        dec a;
        jr nz, L1B0A;

L1B0E:
        ld b, h;
        ld c, l;
        pop hl;
        or a;
        ret;

L1B13:
        call L1B29;
        ld a, (iy + _flags);
        and %00000111;
        dec a;
        ret z;

L1B1D:
        sla e;
        rl d;
        rl c;
        rl b;
        dec a;
        jr nz, L1B1D;
        ret;

L1B29:
        ld a, 7;

L1B2B:
        sla e;
        rl d;
        rl c;
        rl b;
        dec a;
        jr nz, L1B2B;
        ret;

L1B37   defb    $A4, $03, $C0, $A2, $30, $AB, $1F, $E1
        defb    $C0, $A1, $78, $A9, $03, $E0, $7F, $E0
        defb    $78, $A1, $7E, $A9, $1F, $F8, $E0, $C0
        defb    $1E, $A1, $EF, $C0, $A3, $3F, $C0, $A3
        defb    $78, $FD, $80, $01, $FF, $C1, $CD, $F0
        defb    $A1, $07, $80, $F1, $E0, $A3, $E0, $3D
        defb    $C0, $3F, $FE, $F1, $8C, $7E, $A1, $1F
        defb    $E1, $C0, $C3, $F0, $A1, $01, $C0, $1F
        defb    $FF, $FE, $1E, $3B, $06, $0F, $C0, $38
        defb    $71, $C0, $1F, $FC, $A1, $03, $80, $1F
        defb    $3F, $80, $1C, $0E, $06, $01, $F0, $30
        defb    $39, $FF, $F8, $1E, $A1, $F3, $80, $0F
        defb    $A2, $3C, $0F, $87, $A1, $78, $70, $1C
        defb    $7F, $80, $0E, $07, $FF, $80, $0F, $78
        defb    $A1, $38, $1B, $C3, $A1, $1E, $70, $0C
        defb    $A2, $0E, $1C, $1F, $C0, $3E, $FC, $08
        defb    $70, $30, $E3, $A1, $07, $F0, $0E, $18
        defb    $A1, $1C, $30, $0F, $FF, $F8, $FC, $10
        defb    $E0, $E0, $71, $80, $01, $F8, $06, $3C
        defb    $A1, $1C, $60, $0E, $FF, $C0, $F8, $11
        defb    $C3, $C0, $19, $80, $A1, $78, $06, $7C
        defb    $A1, $38, $E0, $0E, $A1, $01, $F0, $33
        defb    $0F, $A1, $0C, $C0, $A1, $3C, $06, $78
        defb    $A1, $70, $E0, $26, $01, $01, $E0, $3E
        defb    $7C, $A1, $06, $C0, $A1, $3C, $06, $F0
        defb    $A1, $E0, $F0, $C7, $06, $01, $C0, $1F
        defb    $E0, $A1, $02, $40, $A1, $7F, $0F, $F0
        defb    $01, $C0, $FF, $83, $FC, $03, $C0, $1C
        defb    $A2, $03, $21, $FF, $FF, $FF, $E0, $03
        defb    $80, $7E, $A1, $F0, $03, $80, $30, $A2
        defb    $01, $23, $FF, $F9, $FD, $E0, $07, $A4
        defb    $03, $80, $F0, $A3, $93, $FF, $E0, $79
        defb    $E0, $0E, $A4, $03, $C7, $C0, $A3, $01
        defb    $FE, $A1, $01, $C0, $3C, $A4, $01, $FF
        defb    $A7, $01, $C0, $F8, $A5, $7C, $A7, $01
        defb    $E7, $E0, $AE, $FF, $80, $AE, $3C, $A2
        defb    $A0

L1C58:
        defm "ESXDOS";                  // UNODOS.SYS filename
        defb 0;                                 // end marker

L1C5F:
        ld l, l;
        inc e;
        ld d, c;
        ld e, $ea;
        dec e;
        ld l, e;
        inc e;
        nop;
        nop;
        ld l, e;
        inc e;
        or a;
        ret;
        ld l, a;
        and %11100000;
        cp $80;
        scf;
        ret nz;
        ld a, l;
        call L1C8B;
        ret c;
        call L1F04;
        ld a, (iy + _err_nr);
        ret;

L1C80:
        and %00001000;
        ld a, $f6;
        jr z, L1C87;
        dec a;

L1C87:
        ld ($3dfe), a;
        ret;

L1C8B:
        ld ($3df2), de;
        ld ($3dfa), a;
        call L1C80;
        call L1D40;
        ret c;
        call L1D00;
        ret c;
        ld hl, $3e00;
        ld a, $49;
        call L1D2F;
        ret c;
        ld hl, $3e20;
        ld a, $4a;
        call L1D2F;
        ret c;
        ld a, ($3dfa);
        call L1E8A;
        ld a, $7a;
        ld de, $0000;
        call L1D81;
        ret c;
        ld a, b;
        and %01000000;
        or %00000011;
        ld (iy + _flags), a;
        and %01000000;
        call z, L1CF7;
        ld hl, $3e05;
        call L1EA3;
        push iy;
        pop hl;
        inc hl;
        inc hl;
        inc hl;
        inc hl;
        rst $30;
        nop;
        ld hl, $3e21;
        ld de, $3e20;
        push de;
        ldi;
        ldi;
        ld a, $20;
        ld (de), a;
        pop hl;
        ld de, ($3df2);
        ld bc, $0008;
        rst $30;
        ld b, $fd;
        ld a, (hl);
        nop;
        or a;
        ret;

L1CF7:
        ld a, $50;
        ld de, $0200;
        ld b, e;
        ld c, e;
        jr L1D6C;

L1D00:
        ld a, $48;
        ld de, $01aa;
        call L1D81;
        ld hl, $1d65;
        jr c, L1D10;
        ld hl, $1d20;

L1D10:
        ld bc, $0078;

L1D13:
        push bc;
        call L1D2E;
        pop bc;
        ret nc;
        djnz L1D13;
        dec c;
        jr nz, L1D13;
        scf;
        ret;
        ld a, $77;
        call L1D67;
        ld a, $69;
        ld bc, $4000;
        ld d, c;
        ld e, c;
        jr L1D6C;

L1D2E:
        jp (hl);

L1D2F:
        call L1D67;
        ret c;
        call L1DC4;
        ret c;
        ld b, $12;
        ld c, mmcspi;
        inir;                                   // Read 12 bytes from divMMC SPI port into (HL)
        or a;
        jr L1D5E;

L1D40:
        call L1D5E;
        ld b, $0a;

L1D45:
        ld a, $ff;
        out (mmcspi), a;                // Write FF to divMMC SPI port
        djnz L1D45;
        call L1DE0;
        ld b, 8;

L1D50:
        ld a, $40;
        ld de, $0000;
        push bc;
        call L1D74;
        pop bc;
        ret nc;
        djnz L1D50;
        scf;

L1D5E:
        push af;
        ld a, $ff;
        out (mmcdev), a;                // Select all available SD cards
        pop af;
        ret;


        ld a, 41h

L1D67:
        ld bc, $0000;
        ld d, b;
        ld e, c;

L1D6C:
        call L1D9A;
        or a;
        ret z;

L1D71:
        scf;
        jr L1D5E;

L1D74:
        ld bc, $0000;
        call L1D9A;
        ld b, a;
        and %11111110;
        ld a, b;
        jr nz, L1D71;
        ret;

L1D81:
        call L1D74;
        ret c;
        push af;
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        ld h, a;
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        ld l, a;
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        ld d, a;
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        ld e, a;
        ld b, h;
        ld c, l;
        pop af;
        ret;

L1D9A:
        call L1DE0;
        out (mmcspi), a;                // write to divMMC SPI port
        push af;
        ld a, b;
        nop;
        out (mmcspi), a;                // write to divMMC SPI port
        ld a, c;
        nop;
        out (mmcspi), a;                // write to divMMC SPI port
        ld a, d;
        nop;
        out (mmcspi), a;                // write to divMMC SPI port
        ld a, e;
        nop;
        out (mmcspi), a;                // write to divMMC SPI port
        pop af;
        cp '@';                                 // $40
        ld b, $95;
        jr z, L1DBF;
        cp 'H';                                 // $48
        ld b, $87;
        jr z, L1DBF;
        ld b, $ff;

L1DBF:
        ld a, b;
        out (mmcspi), a;                // write to divMMC SPI port
        jr L1DD2;                               //Poll the SPI port for a non FFh value

L1DC4:
        ld b, $0a;

L1DC6:
        push bc;
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        pop bc;
        cp $fe;                                 // was the return code FE?
        ret z;                                  // return if so
        djnz L1DC6;
        scf;
        ret;

L1DD2:
; Poll the SPI port up to 255*50 times, waiting for a non-FFh value to be returned
; Return results in A;
        ld bc, $0032;                   // number of retries (C)=50*255 (12750)

L1DD5:
        in a, (mmcspi);                 // read divMMC SPI port
        cp $ff;                                 // did I read FFh?
        ret nz;                                 // RET if not FFh
        djnz L1DD5;                             // decrement B and loop back if B is not 0
        dec c;                                  // decrement C
        jr nz, L1DD5;                   // if C is not 0 , loop back
        ret;                                    // return after 50 lots of 255 attempts

L1DE0:
        push af;
        in a, (mmcspi);                 // read divMMC SPI port
        ld a, ($3dfe);
        out (mmcdev), a;                // select SD card(s);
        pop af;
        ret;

        ld a, (iy + _flags);
        and %01000000;
        call z, L1E97;
        ld a, (iy + _err_nr);
        ld ixh, a;
        ld a, ixl;
        out (mmcram), a;                // Set divMMC ram page...
        ld a, ixh;
        call L1C80;
      call L1E43;
        ld a, $58;
        call L1D6C;
        ld a, 6;
        jr c, L1E30;
        ld a, $fe;
        out (mmcspi), a;                // write FE to divMMC SPI port
        ld bc, $00eb;
        otir;
        otir;
        ld a, $ff;
        out (mmcspi), a;                // write FF to divMMC SPI port
        nop;
        out (mmcspi), a;                // write FF to divMMC SPI port
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        and $1f;
        cp 5;
        ld a, 6;
        scf;
        jr nz, L1E30;

        block $1e2a-$
L1E2A:
        call L1DD2;                             // poll the SPI port for a non FFh value
        ;                                               // to be returned. Result returned in A.
        or a;
        jr z, L1E2A;

; ZX-Badaloc settings (read / write)

; d0-1: Z80 Clock Select:
;               "00" = 3.54MHz, "01" = 7.08MHz, "10" = 14.16MHz, "11" = 21.25MHz
; d2:   Z80 Clock / Screen / INT Doubler:
;               '1' = Z80 Clock *2, INT = 100Hz, VGA 100 Hz instead of 50Hz
; d3-5: High ROM bank address select (A16-18). A14-15 come from #1FFD and #7FFD
; d6-7: Shadow RAM R/W control (not implemented in FPGA version)

L1E30   call    L1D5E           ;this routine probably sets normal CPU / interrupt
        ld      ixl, a
        ld      a, ixh
        ld      bc, $24df
        out     (c), a
        ld      a, 0
        out     (mmcram), a     ;divMMC RAM page 0;
        ld      a, ixl
        ret

L1E43   push    bc
        ld      bc, $24df
        in      a, (c)
        ld      ixh, a
        or      $04
        out     (c), a
        pop     bc
        ret

L1E51:
        ld a, (iy + _flags);
        and %01000000;
        call z, L1E97;
        ld a, (iy + _err_nr);
        ld ixh, a;
        ld a, ixl;
        out (mmcram), a;                // Set divMMC RAM page...
        ld a, ixh;
        call L1C80;
        call L1E43;
        ld a, $51;
        call L1D6C;
        jr nc, L1E75;

L1E71   ld a, 6;
        jr L1E30;

L1E75:
        call L1DC4;
        jr c, L1E71;
        ld bc, $00eb;
        inir;                                   // read ?255? bytes from divMMC SPI port to (HL)
        inir;                                   // read ?255? bytes from divMMC SPI port to (HL)
        nop;
        in a, (mmcspi);                 // read divMMC SPI port
        nop;
        in a, (mmcspi);                 // read divMMC SPI port
        or a;
        jr L1E30;

L1E8A:
        call L032E;
        ld hl, L1C5F;
        ld (iy + _tv_flag), l;
        ld (iy + _err_sp), h;
        ret;

L1E97:
        ld b, c;
        ld c, d;
        ld d, e;
        ld e, 0;

L1E9C:
        sla d;
        rl c;
        rl b;
        ret;

L1EA3:
        ld a, (iy + _flags);
        and %01000000;
        jr z, L1EBC;
        inc hl;
        inc hl;
        ld a, (hl);
        and %00111111;
        ld c, a;
        inc hl;
        ld d, (hl);
        inc hl;
        ld e, (hl);
        call $081c;
        call L1E97;
        jr L1E9C;

L1EBC:
        ld a, (hl);
        and %00001111;
        push af;
        inc hl;
        ld a, (hl);
        and %00000011;
        ld d, a;
        inc hl;
        ld e, (hl);
        inc hl;
        ld a, (hl);
        and %11000000;
        add a, a;
        rl e;
        rl d;
        add a, a;
        rl e;
        rl d;
        inc de;
        inc hl;
        ld a, (hl);
        and %00000011;
        ld b, a;
        inc hl;
        ld a, (hl);
        and %10000000;
        add a, a;
        rl b;
        inc b;
        inc b;
        pop af;
        add a, b;
        ld bc, $0000;
        call L1EF8;
        ld e, d;
        ld d, c;
        ld c, b;
        ld b, 0;
        srl c;
        rr d;
        rr e;
        ret;

L1EF8:
        sla e;
        rl d;
        rl c;
        rl b;
        dec a;
        jr nz, L1EF8;
        ret;

L1F04:
        ld bc, $0000;
        ld d, b;
        ld e, c;
        ld hl, $3e00;
        rst $08;
        defb disk_read;
        ret c;
        ld hl, ($3ffe);
        ld a, h;
        and l;
        scf;
        ret nz;
        push iy;
        pop hl;
        ld de, $0008;
        add hl, de;
        ex de, hl;
        ld b, 4;
        ld hl, $3fbe;

L1F23:
        ld a, (hl);
        and %01111111;
        inc hl;
        inc hl;
        inc hl;
        inc hl;
        jr nz, L1F32;
        or (hl);
        jr z, L1F32;
        inc (iy + _err_nr);

L1F32:
        ld a, b;
        ld bc, $0004;
        add hl, bc;
        ld c, 8;
        ldir;
        ld b, a;
        djnz L1F23;
        ret;

        block $1ff4-$

L1FF4:  ex (sp), hl;
        jr L1FFA;
        ei;                                             // interrupts on

L1FF8:
; A jump to 1FF8 - 1FFF unmaps divMMC ROM/RAM when M1 goes high
        ret;
        ei;                                             // interrupts on

L1FFA:
; Jump from RST $18 handler to return to a system ROM routine whose address has 
; been placed in the stack
; Also called from taps.io
        ret;

L1FFB:
        jp (hl);
        rst $38;
        rst $38;
        rst $38;
        rst $38;





; UNODOS.SYS starts here

        block   $2000-$
L2000: 
        call L23C9;
        ret c;
        jp L2800;
        call L23C9;
        ret c;
        jp L28BE;
        
L200E: 
        jp L29af;
        
L2011: 
        jp L294B;
        
L2014: 
        jp L233A;
        nop;

L2019 equ $2019

        jr z, L2019;
        rst $38;
        defb "KO", 0

L201E: 
        jr L202F;
        ld hl, L0000;
        add hl, sp;
        ld h, a;
        ld a, l;
        cp $0A;
        jr z, L202B;
        pop bc;
        
L202B: 
        ld a, h;
        jp L1FFA;
        
L202F: 
        ld ($2E61), sp;
        ld sp, $2E61;
        push af;
        ld a, r;
        push af;
        ld sp, $3DE8;
        ld a, ($2E7A);
        push hl;
        push de;
        push bc;
        push af;
        ld a, $00;
        ld ($201F), a;
        call L21F6;
        pop bc;
        ld a, b;
        ld ($2E7A), a;
        ld a, $0F;
        ld ($201F), a;
        pop bc;
        pop de;
        pop hl;
        jr nz, L2064;
        ld sp, ($2E61);
        pop af;
        ld ($2E61), sp;
        
L2064: 
        ld sp, $2E5D;
        ld a, ($2E5D);
        and $04;
        ld ($2E5D), a;
        push ix;
        push iy;
        push bc;
        push de;
        push hl;
        ex af, af';
        exx;
        push af;
        push bc;
        push de;
        push hl;
        ld a, i;
        ld ($2E4A), a;
        ld sp, $3DE8;
        ld a, $E9;
        call L21E7;
        ld a, ($5800);
        rrca;
        rrca;
        rrca;
        and $07;
        ld ($2E64), a;
        call L2140;
        ld a, $01;
        ei;
        halt;
        ld ($2E63), a;
        im 1;
        call L215E;
        call L218A;
        ld hl, ($2E61);
        push hl;
        ld a, (hl);
        inc hl;
        ld h, (hl);
        ld l, a;
        ld ($2E65), hl;
        pop hl;
        ld a, ($2E68);
        cp $02;
        jr nz, L20BE;
        inc hl;
        inc hl;
        ld ($2E61), hl 
        
L20BE: 
        ld a, ($3DF8);
        ld ($2E79), a;
        ld hl, $2E4A;
        call $2F00;
        ld a, ($2E79);
        ld ($3DF8), a;
        ld a, ($2E68);
        cp $02;
        jr nz, L20DF;
        ld hl, ($2E61);
        dec hl;
        dec hl;
        ld ($2E61), hl;
        
L20DF: 
        ld a, $F5;
        call L21E7;
        im 1;
        ei;
        halt;
        di;
        ld a, ($2E67);
        ld bc, $7FFD;
        out (c), a;
        ld hl, $2E69;
        call L2177;
        ld a, ($2E5D);
        bit 2, a;
        ld hl, $0086;
        jr nz, L2109;
        inc hl;
        ld a, ($2E5E);
        inc a;
        ld ($2E5E), a;
        
L2109: 
        ld ($213E), hl;
        ld hl, $2E64;
        ld a, (hl);
        out (ula), a;
        dec hl;
        ld a, (hl);
        im 0;
        or a;
        jr z, L2120;
        im 1;
        dec a;
        jr z, L2120;
        im 2;
        
L2120: 
        ld hl, $2E4A;
        ld a, (hl);
        ld i, a;
        inc hl;
        ld sp, hl;
        pop hl;
        pop de;
        pop bc;
        pop af;
        exx;
        ex af, af';
        pop hl;
        pop de;
        pop bc;
        pop iy;
        pop ix;
        pop af;
        ld r, a;
        pop af;
        ld sp, ($2E61);
        jp L0000;
        
L2140: 
        ld hl, $3E00;
        ld de, $3E01;
        ld bc, $0100;
        ld a, h;
        ld i, a;
        inc a;
        ld (hl), a;
        ldir;
        ld h, a;
        ld l, a;
        ld de, $215C;
        ld (hl), $C3;
        inc hl;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        ret;
        inc a;
        ret;
        
L215E: 
        ld hl, $2E69;
        ld de, L0010;
        
L2164: 
        ld bc, $FFFD;
        out (c), d;
        in a, (c);
        ld (hl), a;
        ld b, $BF;
        xor a;
        out (c), a;
        inc hl;
        inc d;
        dec e;
        jr nz, L2164;
        ret;
        
L2177: 
        ld de, L0010;
        
L217A: 
        ld bc, $FFFD;
        out (c), d;
        ld b, $BF;
        ld a, (hl);
        out (c), a;
        inc hl;
        inc d;
        dec e;
        jr nz, L217A;
        ret;
        
L218A: 
        ld hl, $C000;
        ld de, $3E00;
        ld bc, $0006;
        push de;
        push hl;
        push bc;
        ldir;
        pop bc;
        pop de;
        ld hl, $1C58;
        push de;
        push bc;
        ldir;
        ld a, ($2E67);
        ld c, $00;
        
L21A6: 
        push af;
        exx;
        ld bc, $7FFD;
        out (c), a;
        exx;
        ld de, $C000;
        ld hl, $1C58;
        ld b, $06;
        
L21B6: 
        ld a, (de);
        cp (hl);
        jr nz, L21D9;
        inc de;
        inc hl;
        djnz L21B6;
        inc c;
        pop af;
        ld ($2E67), a;
        
L21C3: 
        inc a;
        ld b, a;
        and $07;
        ld a, b;
        jr nz, L21A6;
        ld a, ($2E67);
        exx;
        out (c), a;
        exx;
        ld a, c;
        pop bc;
        pop de;
        pop hl;
        ldir;
        jr L21de;
        
L21D9: 
        pop af;
        jr L21C3;
        jr L21de;
        
L21de: 
        and a;
        ret z;
        inc a;
        and $07;
        ld ($2E68), a;
        ret;
        
L21E7: 
        ld hl, $2E5E;
        ld b, a;
        ld a, (hl);
        and $80;
        ld c, a;
        ld a, (hl);
        add a, b;
        and $7F;
        or c;
        ld (hl), a;
        ret;
        
L21F6: 
        ld hl, $5B00;
        push hl;
        ld de, $3E00;
        ld bc, $000E;
        push bc;
        ldir;
        pop bc;
        pop de;
        ld hl, $2234;
        ldir;
        ld ($3E10), sp;
        ld sp, $5B0E;
        ld hl, $5B00;
        call L1FFB;
        ld sp, ($3E10);
        ld hl, $3E00;
        ld de, $5B00;
        ld bc, $000E;
        ldir;
        cp $AF;                                 // CODE
        push af;
        ld a, $10;
        jr z, L222F;
        ld a, $00;
        
L222F: 
        ld ($2E67), a;
        pop af;
        ret;
        ld a, ($0001);
        jp $3DFD;
        ld de, L0000;
        ld hl, $2D4E;
        call L2264;
        jp L1FFA;
        rst $28;
        ld ($0D22), hl;
        rst $28;
        ld bc, $0022;
        ld ($F90D), hl;
        ret nz;
        ld sp, $3635;
        ld sp, $3A39;
        jp pe, $F73A;
        dec c;
        ld sp, hl;
        ret nz;
        ld sp, $3635;
        ld sp, $0D36;
        
L2264: 
        ld a, (de);
        inc de;
        and a;
        jr nz, L226C;
        ex de, hl;
        jr L2264;
        
L226C: 
        cp $0D;
        ret z;
        cp $01;
        call z, L2279;
        call L2299;
        jr L2264;
        
L2279: 
        ld a, ($2E31);
        cp '*';                                 // $2A
        ret z;
        push af;
        and $F8;
        srl a;
        srl a;
        srl a;
        or $60;
        call L2299;
        ld a, $64;
        call L2299;
        pop af;
        and $07;
        add a, $30;
        or a;
        ret;
        
L2299: 
        push hl;
        push de;
        rst $18;
        defw add_char;
        pop de;
        pop hl;
        ret;
        cp $FF;
        jp z, L012A;
        cp $FE;
        jp z, L0251;
        cp $FC;
        jr c, L22C7;
        ld de, $225C;
        jr z, L22B7;
        ld de, $2250;
        
L22B7: 
        ld a, ($3D00);
        and a;
        jr nz, L22C1;
        ld a, $1C;
        scf;
        ret;
        
L22C1: 
        ld a, $07;
        out (ula), a;
        jr L22D8;
        
L22C7: 
        ld de, $2246;
        ld ($2E31), a;
        and a;
        jr z, L22D8;
        ld de, $2D4E;
        rst $30;
        inc b;
        ld de, $224A;
        
L22D8: 
        ld ($223B), de;
        di;
        call L00EF;
        ld hl, $5B00;
        ld d, h;
        ld e, $01;
        ld bc, $A4FF;
        ld (hl), l;
        ldir;
        ld hl, $230C;
        ld de, $5D25;
        ld bc, $002E;
        ldir;
        ld sp, $5DA5;
        rst $18;
        defw $5d25;             // BASIC call used to call routine copied to $5d25
        ld hl, $FFFF;
        ld a, $01;
        ld (hl), a;
        ld a, (hl);
        dec a;
        jr z, L2309;
        res 7, h;
        
L2309: 
        rst $18;
        defw $5da5;             // BASIC call used to call routine copied to $5da5
        ld hl, $1200;
        ld de, $5DA5;
        ld bc, $00B1;
        ldir;
        ld hl, $5D47;
        ld bc, $000C;
        ldir;
        ex de, hl;
        ld de, $12B4;
        ld (hl), $C3;
        inc hl;
        ld (hl), e;
        inc hl;
        ld (hl), d;
        xor a;
        ld ($5DD9), a;
        ret;
        ld hl, $5E62;
        push hl;
        ld hl, $223A;
        push hl;
        ei;
        jp $3DFD;
        
L233A: 
        ld ($2E33), a;
        cp '.';                                 // $2E
        jp z, L23DA;
        call L2387;
        ret nc;
        push hl;
        ex de, hl;
        call L2357;
        pop hl;
        jr nc, L2351;
        ld a, $1A;
        rst $20;
        
L2351: 
        ld a, ($2E33);
        jp L2800;
        
L2357: 
        ld a, (L2019);
        cp l;
        jr nz, L2362;
        ld a, ($201A);
        cp h;
        ret z;
        
L2362: 
        ld (L2019), hl;
        call L02FD;
        ld a, $24;
        ld b, $01;
        rst $08;
        defb f_open;
        jr c, L2380;
        push af;
        ld hl, L2800;
        ld bc, $0400;
        rst $08;
        defb f_read;
        pop bc;
        push af;
        ld a, b;
        rst $08;
        defb f_close;
        pop af;
        ret nc;
        
L2380: 
        push af;
        xor a;
        ld ($201A), a;
        pop af;
        ret;
        
L2387: 
        ld c, a;
        ld de, L23A5;
        ld a, (de);
        
L238C: 
        or a;
        ret z;
        inc de;
        cp c;
        jr z, L239E;
        ld a, (de);
        
L2393: 
        cp $80;
        jr nc, L238C;
        inc de;
        or a;
        ld a, (de);
        jr z, L238C;
        jr L2393;
        
L239E: 
        ld a, (de);
        cp $80;
        ret c;
        inc de;
        jr L239E;

L23A5:
        defb $ef, $f8, $d6, $d5, $d2
        defb "BFILE"
        defb $00, $ec, $cf
        defb "BDIR"
        defb $00, $00
        defb "TAPE"
        defb $00
        defb "ERRMSG"
        defb $00
        
L23C4: 
        ld hl, $23B8;
        jr L2357;
        
L23C9: 
        push hl;
        push de;
        push bc;
        call L23C4;
        pop bc;
        pop de;
        pop hl;
        ld a, ixl;
        ld ($3DF8), a;
        ld a, $1A;
        ret;
        
L23DA: 
        inc hl;
        push hl;
        ld hl, $0032;
        ld de, $2DCE;
        ld bc, $0005;
        ldir;
        pop hl;
        ld c, $20;
        
L23EA: 
        ld a, (hl);
        cp ' ';                                 // $20
        jr z, L23FB;
        rst $18;
        defw pr_st_end;
        jr z, L23FB;

        ldi;
        jp po, L23FB;
        jr L23EA;
        
L23FB: 
        cp ' ';                                 // $20
        jr nz, L2414;
        inc hl;
        ld ($2E46), hl;
        
L2403: 
        ld a, (hl);
        rst $18;
        defw pr_st_end;
        jr z, L240C;
        
        inc hl;
        jr L2403;

L240C:
        ld (ch_add), hl;
        ld hl, ($2E46);
        jr L241A;
        
L2414: 
        ld (ch_add), hl;
        ld hl, L0000;

L241A: 
        ld ($2E46), hl;

L241B equ $241b

        call L24C1;
        call L242E;
        jp nc, L0D94;
        cp $05;
        jp nz, L0020;
        ld a, $16;
        rst $20;
        
L242E: 
        xor a;
        ld (de), a 
        
L2430: 
        call L2475;
        ld a, $24;
        ld hl, $2DCE;
        ld b, $01;
        rst $08;
        defb f_open;
        ret;
        ld a, ($3DF8);
        ld ($3DF0), a;
        push hl;
        ld hl, $0032;
        ld de, $2DCE;
        ld bc, $0005;
        ldir;
        pop hl;
        
L2450: 
        ld a, (hl);
        inc hl;
        cp ' ';                                 // $20
        jr z, L245A;
        ld (de), a;
        inc de;
        jr L2450;
        
L245A: 
        ld ($2E46), hl;
        call L242E;
        ret c;
        push af;
        ld a, $02;
        ld ($3DF8), a;
        ld hl, ($2E46);
        ld de, $3D00;
        push de;
        rst $30;
        inc b;
        pop hl;
        pop af;
        jp L0DB4;
        
L2475: 
        ld b, $0F;
        ld hl, $2E22;
        
L247A: 
        ld a, (hl);
        and a;
        jr z, L2484;
        push hl;
        push bc;
        rst $08;
        defb f_close;
        pop bc;
        pop hl;
        
L2484: 
        inc hl;
        djnz L247A;
        ret;

L248A equ $248a

L2488:;                                         // called from dirs.io
        call L249A;
        ret z;
        ld a, b;
        or c;
        jp z, L24EF;
        ex de, hl;
        ld de, $2D4E;
        ldir;
        xor a;
        ld (de), a;
        ret;
        
L249A: 
        rst $18;
        defw expt_exp;
        rst $30;
        inc bc;
        ret z;
        push af;
        rst $18;
        defw stk_fetch;
        pop af;
        ret;

L24A6:;                                         // called from dirs.io
        push af;
        rst $30;
        ld (bc), a;
        cp $64;                                 // 'd'
        jp nz, L24EC;
        rst $30;
        ld (bc), a;
        jp z, L24EC;
        sub $30;
        and $07;
        ld c, a;
        pop af;
        sla a;
        sla a;
        sla a;
        or c;
        ret;
        
L24C1:;                                         // called from dirs.io 
        rst $18;
        defw get_char;
        
L24C4:
        rst $18;
        defw pr_st_end;
        jp nz, L24E9;
        rst $30;
        inc bc;
        ret nz;
        
L24CD:;                                         // called from dirs.io
        ld sp, (err_sp);
        ld (iy + $00), $FF;
        ld hl, $1BF4;
        rst $30;
        inc bc;
        jp z, L1FFB;
        ld hl, $1B7D;
        jp L1FFB;
        ld a, $01;
        rst $20;

L24E6:;                                         // called from files.io
        ld a, $02;
        rst $20;

L24E9:
        ld a, $03;
        rst $20;
        
L24EC: 
        ld a, $0B;
        rst $20;
        
L24EF: 
        ld a, $13;
        rst $20;

L24F2:;                                         // called from files.io
        ld a, $04;
        rst $20;
        
L24F5:;                                         // called from dirs.io
        ld a, ($2E32);
        push af;
        ld a, $00;
        ld ($2E32), a;
        pop af;
        rst $08;
        defb f_close;
        ret;

L2502:;                                         // called from dirs.io
        ld a, ($2E32);
        and a;
        ret z;
        push bc;
        push de;
        call L24F5;
        pop de;
        pop bc;
        ret;
        ld a, (iy + $08);
        rst $08;
        defb f_close;
        ret;
        ld ixh, a;
        and $E0;
        cp $60;                                 // £
        scf;
        ret nz;
        ld a, ixh;
        and $F8;
        push bc;
        push af;
        ld ($3DEA), de;
        push bc;
        ld de, $2D4E;
        push de;
        rst $30;
        dec b;
        pop hl;
        pop bc;
        ld a, c;
        ld b, $03;
        rst $08;
        defb f_open;
        jr nc, L253A;
        pop bc;
        pop bc;
        ret;
        
L253A: 
        ld ($2D4D), a;
        ld hl, $2DF2;
        rst $08;
        defb f_fstat;
        pop af;
        call L032E;
        ld hl, $1A95;
        ld (iy + $02), l;
        ld (iy + $03), h;
        pop bc;
        call L25A9;
        jr nc, L255C;
        call L25BA;
        jr nc, L255C;
        ld c, $03;
        
L255C: 
        ld a, b;
        and $07;
        or c;
        or b;
        ld (iy + $01), a;
        ld a, c;
        ld hl, $2DF9;
        rst $30;
        ld bc, $F4CD;
        dec h;
        ld l, a;
        dec l;
        rst $30;
        dec c;
        jr z, L2587;
        ld h, $00;
        
L2575: 
        srl b;
        rr c;
        rr d;
        rr e;
        rl h;
        dec l;
        jr nz, L2575;
        ld a, h;
        and a;
        call nz, L081C;
        
L2587: 
        push iy;
        pop hl;
        ld a, $04;
        add a, l;
        ld l, a;
        rst $30;
        nop;
        ld a, ($2D4D);
        ld (iy + $08), a;
        ld a, ixl;
        ld ($3DF8), a;
        ld de, ($3DEA);
        ld hl, $260D;
        rst $30;
        inc b;
        ld a, (iy + $00);
        or a;
        ret;
        
L25A9: 
        ld de, $0800;
        call L25de;
        ret c;
        ld a, ($3EE7);
        cp $10;
        ld c, $02;
        ret z;
        
L25B8: 
        scf;
        ret;
        
L25BA: 
        ld de, $4000;
        call L25de;
        ret c;
        ld a, ($3E00);
        cp $FF;
        ret nz;
        ld hl, $3E09;
        ld a, (hl);
        cp $44;                                 // 'D'
        jr nz, L25B8;
        inc l;
        ld a, (hl);
        cp $49;                                 // 'I'
        jr nz, L25B8;
        inc l;
        ld a, (hl);
        cp $52;                                 // 'R'
        jr nz, L25B8;
        ld c, $02;
        ret;
        
L25de: 
        push bc;
        ld bc, L0000;
        ld l, c;
        ld a, ($2D4D);
        push af;
        rst $08;
        defb f_seek;
        pop af;
        ld hl, $3E00;
        ld bc, $0200;
        rst $08;
        defb f_read;
        pop bc;
        ret;
        ld h, a;
        ld l, $00;
        ld a, $07;
        
L25F9: 
        srl b;
        rr c;
        rr d;
        rr e;
        rl l;
        dec a;
        jr nz, L25F9;
        ld a, l;
        and a;
        ld a, h;
        call nz, L081C;
        ret;
        ld d, (hl);
        ld l, c;
        ld (hl), d;
        ld (hl), h;
        ld (hl), l;
        ld h, c;
        ld l, h;
        jr nz, L265A;
        ld l, c;
        ld (hl), e;
        ld l, e;
        nop;
        ld ($3C19), hl;
        ld de, ($3C11);
        ld bc, ($3C13);
        ld ($3C15), de;
        ld ($3C17), bc;
        call $305E;
        ret c;
        call L1321;
        ld h, d;
        ld l, e;
        ld a, $FF;
        call $30E2;
        push de;
        ld de, ($3C11);
        ld bc, ($3C13);
        call L110A;
        pop hl;
        call L1380;
        push bc;
        push de;
        ld bc, ($3C17);
        ld de, ($3C15);
        call L10BA;
        ld de, ($3C19);
        ld a, d;
        and $01;
        ld d, a;
        add hl, de;
        pop de;
        pop bc;
        call $30F7;
        push bc;
        push de;
        ld bc, ($3C17);
        ld de, ($3C15);
        call L110A;
        pop de;
        pop bc;
        jp L1135;
        bit 2, (iy + $34);
        jr z, L26B2;

L265A equ $265a
        
L267E: 
        push hl;
        push iy;
        pop hl;
        ld l, $3E;
        rst $30;
        ld bc, $FDE1;
        ld a, (hl);
        inc e;
        cp $00;
        ld a, $00;
        jr z, L2692;
        sla e;
        
L2692: 
        sla e;
        adc a, a;
        ld d, a;
        ld a, h;
        and $FE;
        or d;
        ld d, a;
        or a;
        ex de, hl;
        sbc hl, de;
        ex de, hl;
        jr z, L26AA;
        ld d, h;
        ld e, l;
        call $30D3;
        jr nz, L267E;
        ret;
        
L26AA: 
        res 2, (iy + $34);
        ld a, $09;
        scf;
        ret;
        
L26B2: 
        ld d, h;
        ld e, l;
        call $30D3;
        ret z;
        ld a, h;
        cp '*';                                 // $2A
        jr nz, L26B2;
        res 2, (iy + $34);
        ld de, ($3C11);
        ld bc, ($3C13);
        call L081C;
        push bc;
        push de;
        call L081C;
        push iy;
        pop hl;
        ld l, $22;
        call L0694;
        pop de;
        pop bc;
        jr nz, L26E7;
        set 2, (iy + $34);
        call L10BA;
        jr nc, L267E;
        ret;
        
L26E7: 
        call L10BA;
        jr nc, L26B2;
        ret;
        ld a, (iy + $1C);
        cp $01;
        ld a, $00;
        call z, $30DD;
        or (hl);
        inc l;
        or (hl);
        inc hl;
        ret;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc hl;
        push bc;
        ld b, a;
        ld a, (iy + $1C);
        cp $01;
        ld a, b;
        pop bc;
        ret nz;
        ld (hl), a;
        inc l;
        and $0F;
        ld (hl), a;
        inc hl;
        ret;
        call L11B6;
        ld (hl), e;
        inc l;
        ld (hl), d;
        ld a, (iy + $1C);
        cp $01;
        ret nz;
        inc l;
        ld (hl), c;
        inc l;
        ld (hl), b;
        ret;
        
L2722: 
        rst $30;
        dec c;
        ret z;
        call L1334;
        jr nz, L272D;
        call L11B6;
        
L272D: 
        call L12C7;
        jr c, L2738;
        call $3122;
        jr nc, L2722;
        ret;
        
L2738: 
        cp $80;
        scf;
        ret nz;
        xor a;
        call $30E2;
        push bc;
        push de;
        ld de, ($3C11);
        ld bc, ($3C13);
        call L110A;
        push af;
        scf;
        call L1321;
        pop af;
        pop de;
        pop bc;
        ret;
        call L115C;
        jp L10A0;
        bit 1, (ix + $01);
        ld a, $08;
        scf;
        ret z;
        ld a, b;
        or c;
        ret z;
        push bc;
        call L19E0;
        rst $30;
        dec c;
        pop bc;
        jr nz, L2776;
        push bc;
        call $3192;
        pop bc;
        ret c;
        
L2776: 
        set 2, (ix + $01);
        call L18F2;
        push af;
        push bc;
        push hl;
        call L19C6;
        push ix;
        pop hl;
        ld a, l;
        add a, $0E;
        ld l, a;
        rst $30;
        ex af, af';
        call c, $3183;
        set 3, (ix + $01);
        pop hl;
        pop bc;
        pop af;
        ret nc;
        push af;
        call L10F3;
        pop af;
        ret;
        call L19D3;
        push hl;
        ld hl, $1A6D;
        ld ($3DEE), hl;
        call L1A21;
        pop hl;
        ret;
        push hl;
        call L135D;
        pop hl;
        call nc, L10F3;
        ret c;
        push bc;
        call L1321;
        pop bc;
        call L19ED;
        call L12A6;
        push hl;
        ld hl, $1A7C;
        ld ($3DEE), hl;
        call L1A21;
        pop hl;
        ret;
        call L1697;
        ret c;
        push iy;
        pop hl;
        ld d, h;
        ld e, l;
        inc de;
        ld bc, $00FF;
        ld (hl), l;
        ldir;
        or a;
        ret;
        push de;
        ld a, $80;
        call L1524;
        pop de;
        jr nc, L27EB;
        cp $11;
        scf;
        ret nz;
        
L27EB: 
        ld a, ($3C06);
        cp '.';                                 // $2E
        ld a, $13;
        scf;
        jp z, $329F;
        call L1773;
        ld hl, $1A65;
        ld ($3DEE), hl;
        call L1A21;
        ld a, $17;
        ret c;
        ld l, (ix + $1C);
        ld h, (ix + $1D);
        ld a, $0B;
        add a, l;
        ld l, a;
        bit 0, (hl);
        ld a, $18;
        scf;
        jp nz, $32A4;
        push de;
        call L19FA;
        ld hl, $3C1B;
        rst $30;
        nop;
        call L163E;
        ld hl, $3C1F;
        rst $30;
        nop;
        call L115C;
        call L1A07;
        ld a, (ix + $06);
        ld ($3C23), a;
        ld l, (ix + $1C);
        ld h, (ix + $1D);
        ld de, $2D00;
        ld bc, L0020;
        ldir;
        pop hl;
        ld a, $80;
        call L152F;
        jr c, L284F;
        ld a, $12;
        scf;
        jr L28BE;

L2800 equ $2800

L284F: 
        cp $05;
        scf;
        jr nz, L28B9;
        ld a, ($3C06);
        cp '.';                                 // $2E
        ld a, $13;
        scf;
        jr z, L28B9;
        call L19FA;
        ld hl, $3C1E;
        call L0694;
        jr nz, L287F;
        ld a, ($3C23);
        ld (ix + $06), a;
        call L16CB;
        jr c, L28B9;
        ex de, hl;
        ld hl, $3C06;
        ld bc, $000B;
        ldir;
        jr L28B6;
        
L287F: 
        call L17F4;
        jr c, L28B9;
        ld a, (de);
        push af;
        ld hl, $3C06;
        ld bc, $000B;
        ldir;
        ld hl, $2D0B;
        ld bc, L0015;
        ldir;
        push de;
        call L17E7;
        pop hl;
        pop de;
        jr c, L28B9;
        ld a, d;
        cp $E5;                                 // RESTORE
        jr z, L28A6;
        call L177A;
        
L28A6: 
        call L17E7;
        ld a, ($3C23);
        ld (ix + $06), a;
        call L16CB;
        jr c, L28B9;
        ld (hl), $E5;
        
L28B6: 
        call L17E7;
        
L28B9: 
        push af;
        call L10F3;
        pop af;
        
L28BE: 
        ld (ix + $00), $00;
        ret;
        push bc;
        ld a, $80;
        call L1524;
        pop bc;
        jr nc, L28D2;
        cp $11;
        scf;
        jr z, L28D6;
        ret;
        
L28D2: 
        call $32E7;
        ret c;
        
L28D6: 
        push bc;
        call L115C;
        call L1A07;
        call L163E;
        ld l, (ix + $1C);
        ld h, (ix + $1D);
        ld a, $0B;
        add a, l;
        ld l, a;
        pop bc;
        ld a, b;
        rra;
        ccf;
        rla;
        and c;
        ld b, a;
        ld a, c;
        and $27;
        cpl;
        and (hl);
        or b;
        and $37;
        ld (hl), a;
        call L17E7;
        ret c;
        jp L10F3;
        ld hl, $2C00;
        ld a, (hl);
        cp '/';                                 // $2F
        jr nz, L290A;
        inc hl;
        
L290A: 
        ld a, (hl);
        cp '.';                                 // $2E
        jr z, L2911;
        or a;
        ret nz;
        
L2911: 
        ld a, $08;
        scf;
        ret;
        ld a, $80;
        call L1524;
        jr c, L2920;
        
L291C: 
        ld a, $12;
        scf;
        ret;
        
L2920: 
        cp $11;
        jr z, L291C;
        cp $05;
        scf;
        ret nz;
        call L19FA;
        push bc;
        push de;
        call $3348;
        pop de;
        pop bc;
        ret c;
        push bc;
        push de;
        ld de, $2D00;
        ld hl, $33A2;
        exx;
        call L19FA;
        exx;
        call $336D;
        ex de, hl;
        exx;
        pop de;
        pop bc;
        exx;
        ld hl, $33A1;
        
L294B: 
        call $336D;
        ld d, h;
        ld e, l;
        inc de;
        xor a;
        ld (hl), a;
        ld bc, $01BF;
        ldir;
        ld hl, $2D00;
        call $313C;
        ret c;
        jp L1697;
        xor a;
        ld ($3C01), a;
        call L1712;
        ld (ix + $00), $00;
        ret c;
        ld hl, $2600;
        call L17FD;
        ret c;
        ld a, $0B;
        add a, e;
        ld e, a;
        ld a, $10;
        ld (de), a;
        call L17E7;
        ret c;
        set 3, (ix + $01);
        jp $3192;
        ld bc, $000B;
        ldir;
        ld a, $10;
        ld (de), a;
        ex de, hl;
        inc hl;
        ld (hl), a;
        inc hl;
        ld (hl), a;
        inc hl;
        rst $08;
        defb m_getdate;
        rst $30;
        nop;
        xor a;
        ld (hl), a;
        inc l;
        ld (hl), a;
        inc l;
        push hl;
        exx;
        pop hl;
        ld (hl), c;
        inc l;
        ld (hl), b;
        inc l;
        push hl;
        exx;
        pop hl;
        rst $30;
        nop;
        push hl;
        exx;
        pop hl;
        ld (hl), e;
        inc l;
        
L29af: 
        ld (hl), d;
        inc l;
        push hl;
        exx;
        pop hl;
        ld b, a;
        ld c, b;
        ld d, c;
        ld e, d;
        rst $30;
        nop;
        ret;
        ld l, $2E;
        jr nz, L29DF;
        jr nz, L29E1;
        jr nz, L29E3;
        jr nz, L29E5;
        jr nz, L29E7;
        ld a, $81;
        call L1524;
        ret c;
        call L163E;
        call L107B;
        ld hl, $2C80;
        ld a, ($3DEA);
        ld (iy + $7F), a;
        push iy;
        pop de;
        
L29DF: 
        ld e, $80;
        
L29E1: 
        sub $80;
        
L29E3: 
        ld b, $00;
        
L29E5: 
        ld c, a;

L29E7 equ $29e7

        ldir;
        ld a, b;
        ld (de), a;
        or a;
        ret;
        ld a, $01;
        or b;
        and $41;
        ld (ix + $01), a;
        ld a, $80;
        call L1524;
        ret c;
        call L115C;
        call L1A07;
        call L163E;
        call L19ED;
        call L12A6;
        ld b, $00;
        ld c, b;
        ld d, c;
        ld e, d;
        call L19B9;
        call L0824;
        call L19D3;
        call L1773;
        or a;
        ret;
        ex de, hl;
        
L2A1D: 
        ld hl, $2D00;
        ld bc, L0020;
        push de;
        call L1681;
        pop de;
        ret c;
        ld a, (hl);
        and a;
        ret z;
        cp $E5;                                 // RESTORE
        jr z, L2A1D;
        ld l, $0B;
        bit 3, (hl);
        ld l, $00;
        jr nz, L2A1D;
        push de;
        ld de, $2D20;
        push de;
        inc de;
        ld b, $08;
        call $34BF;
        ld a, (hl);
        cp ' ';                                 // $20
        jr z, L2A4C;
        ld a, $2E;
        ld (de), a;
        inc de;
        
L2A4C: 
        ld b, $03;
        call $34BF;
        xor a;
        ld (de), a;
        inc de;
        ld a, (hl);
        and $3F;
        ld ($2D20), a;
        ld bc, $0009;
        add hl, bc;
        ld c, (hl);
        inc hl;
        ld b, (hl);
        ld ($3C21), bc;
        inc hl;
        ldi;
        ldi;
        ldi;
        ldi;
        ld c, (hl);
        inc hl;
        ld b, (hl);
        ld ($3C1F), bc;
        inc hl;
        ldi;
        ldi;
        ldi;
        ldi;
        bit 6, (ix + $01);
        call nz, $347B;
        ld b, $00;
        ld a, e;
        sub $20;
        ld c, a;
        pop hl;
        pop de;
        ret c;
        rst $30;
        ld b, $EB;
        ld a, $01;
        or a;
        ret;
        ld a, ($2D20);
        bit 4, a;
        jr nz, L2ACB;
        ld hl, $3C1F;
        push de;
        rst $30;
        ld bc, $0DF7;
        jr z, L2AB1;
        call L1265;
        ld hl, $2600;
        push hl;
        call L1096;
        pop hl;
        
L2AB1: 
        pop de;
        ret c;
        push de;
        call L18B3;
        pop de;
        jr nz, L2ACB;
        ld hl, $2D20;
        ld a, $40;
        or (hl);
        ld (hl), a;
        ld hl, $260F;
        ld bc, $0008;
        
L2AC7: 
        ldir;
        xor a;
        ret;
        
L2ACB: 
        ld a, $FF;
        ld (de), a;
        inc de;
        inc a;
        ld (de), a;
        push de;
        pop hl;
        inc de;
        ld bc, $0005;
        jr L2AC7;
        
L2AD9: 
        ld a, (hl);
        inc hl;
        cp ' ';                                 // $20
        jr z, L2AE1;
        ld (de), a;
        inc de;
        
L2AE1: 
        djnz L2AD9;
        ret;
        ld de, $2D00;
        ld hl, $0040;
        ld bc, $000B;
        ldir;
        ld hl, ($3C23);
        ld e, $0F;
        ld bc, $0008;
        rst $30;
        rlca;
        xor a;
        ld (de), a;
        ld h, d;
        ld l, e;
        inc e;
        ld bc, $0067;
        ldir;
        push de;
        ld l, $10;
        ld e, (hl);
        inc l;
        ld d, (hl);
        ld b, a;
        ld c, a;
        push hl;
        ld hl, $0080;
        call L0831;
        pop hl;
        ld l, $0B;
        rst $30;
        nop;
        pop hl;
        ld l, $00;
        ld c, $7F;
        xor a;
        add a, (hl);
        cpi;
        jp pe, $3503;
        ld (hl), a;
        ret;
        call L11C3;
        ld a, b;
        inc a;
        jr nz, L2B33;
        call $352D;
        cp $09;
        scf;
        ret nz;
        
L2B33: 
        call L11D0;
        ld a, (iy + $25);
        
L2B39: 
        srl a;
        ccf;
        ret nc;
        sla e;
        rl d;
        rl c;
        rl b;
        jr L2B39;
        res 3, (iy + $34);
        exx;
        ld bc, L0000;
        ld de, $0002;
        call L10BA;
        ret c;
        
L2B56: 
        call $305E;
        exx;
        call L081C;
        ret c;
        exx;
        jr L2B56;
        call L19C6;
        or a;
        ret;
        push hl;
        ld b, $00;
        call $33D2;
        pop hl;
        ret c;
        ld a, ($3DF8);
        ld c, a;
        ld a, ($3DF9);
        ld ($3DF8), a;
        push hl;
        push bc;
        call $3570;
        pop bc;
        pop hl;
        push af;
        ld a, c;
        ld ($3DF8), a;
        pop af;
        ret c;
        ld a, $80;
        jr L2BB9;
        ld b, $00;
        
L2B8C: 
        ld hl, $2D40;
        push bc;
        push hl;
        call $3402;
        pop hl;
        pop bc;
        ret c;
        and a;
        jr z, L2BA5;
        inc b;
        inc hl;
        ld a, (hl);
        cp '.';                                 // $2E
        jr z, L2B8C;
        
L2BA1: 
        ld a, $1B;
        scf;
        ret;
        
L2BA5: 
        ld a, b;
        cp $02;
        jr nz, L2BA1;
        ld a, ($3C06);
        cp '.';                                 // $2E
        jr nz, L2BB5;
        ld a, $08;
        scf;
        ret;
        
L2BB5: 
        or a;
        ret;
        ld a, $00;
        
L2BB9: 
        call L1524;
        ret c;
        call L1773;
        call L115C;
        call L1A07;
        call L163E;
        ld hl, $1A65;
        ld ($3DEE), hl;
        call L1A21;
        ld a, $17;
        jr c, L2BF8;
        ld l, (ix + $1C);
        ld h, (ix + $1D);
        push hl;
        ld a, $0B;
        add a, l;
        ld l, a;
        bit 0, (hl);
        pop hl;
        ld a, $18;
        scf;
        jr nz, L2BF8;
        ld (hl), $E5;
        push bc;
        push de;
        call L17E7;
        pop de;
        pop bc;
        call nc, $3108;
        call nc, L10F3;
        
L2BF8: 
        ld (ix + $00), $00;
        ret;
        ld b, $01;
        push hl;
        push de;
        call L16DE;
        pop de;
        pop hl;
        jr nc, L2C14;
        cp $10;
        scf;
        ret nz;
        push de;
        ld b, $00;
        call $33D2;
        pop de;
        ret c;
        
L2C14: 
        ex de, hl;
        call $35FF;
        ret;
        push hl;
        ld hl, $2D00;
        ld a, (iy + $00);
        ld (hl), a;
        inc hl;
        ld a, (iy + $01);
        ld (hl), a;
        call L16CB;
        pop de;
        ret c;
        push de;
        ex de, hl;
        ld hl, $2D02;
        ld a, $0B;
        ld c, a;
        add a, e;
        ld e, a;
        ld a, (de);
        ld (hl), a;
        inc hl;
        ld a, c;
        add a, e;
        ld e, a;
        ex de, hl;
        ld bc, $0004;
        ldir;
        ex de, hl;
        call L19E0;
        rst $30;
        nop;
        pop de;
        ld hl, $2D00;
        ld bc, $000B;
        rst $30;
        ld b, $B7;
        jp L16BE;
        ld a, $00;
        call L1524;
        ret c;
        call L1773;
        call L115C;
        call L1A07;
        ld l, (ix + $1C);
        ld h, (ix + $1D);
        ld a, $0B;
        add a, l;
        ld l, a;
        bit 0, (hl);
        ld a, $18;
        scf;
        jr nz, L2C82;
        ld b, $00;
        ld c, b;
        ld d, c;
        ld e, d;
        call $3183;
        call L163E;
        call $367F;
        
L2C82: 
        push af;
        call L168F;
        pop af;
        ret;
        bit 1, (ix + $01);
        ld a, $08;
        scf;
        ret z;
        call L19C6;
        call $3183;
        call L1142;
        call $3108;
        call nc, L10F3;
        ld hl, $1A7C;
        ld ($3DEE), hl;
        call L1A21;
        or a;
        ret;
        ld l, $00;
        jr L2CB4;
        ld l, $00;
        ld b, l;
        ld c, l;
        ld d, l;
        ld e, l;
        
L2CB4: 
        push bc;
        push de;
        ld a, (iy + $1C);
        cp $00;
        jr nz, L2CCC;
        call L19FA;
        rst $30;
        dec c;
        ld b, $00;
        jr nz, L2CCC;
        inc b;
        ld a, (iy + $42);
        jr L2CCF;
        
L2CCC: 
        ld a, (iy + $25);
        
L2CCF: 
        ld (iy + $43), b;
        ld (iy + $44), a;
        pop de;
        pop bc;
        ld a, l;
        cp $00;
        jr z, L2D0A;
        push bc;
        push de;
        call L19C6;
        ex de, hl;
        pop de;
        cp $01;
        jr z, L2CFA;
        cp $02;
        jr z, L2CF0;
        pop bc;
        ld a, $02;
        scf;
        ret;
        
L2CF0: 
        sbc hl, de;
        ex de, hl;
        ld h, b;
        ld l, c;
        pop bc;
        sbc hl, bc;
        jr L2D01;
        
L2CFA: 
        add hl, de;
        ex de, hl;
        ld h, b;
        ld l, c;
        pop bc;
        adc hl, bc;
        
L2D01: 
        ld b, h;
        ld c, l;
        jr nc, L2D0A;
        ld bc, L0000;
        ld d, b;
        ld e, c 
        
L2D0A: 
        ld a, $0E;
        call $37C4;
        rst $30;
        ex af, af';
        jr nc, L2D16;
        call L19E0;
        
L2D16: 
        ld a, $12;
        call $37C4;
        rst $30;
        ex af, af';
        jp z, $3792;
        jr c, L2D2E;
        push bc;
        push de;
        call L19FA;
        call L18D0;
        pop de;
        pop bc;
        jr L2D16;
        
L2D2E: 
        push bc;
        push de;
        rst $30;
        dec c;
        jr nz, L2D39;
        call $37BC;
        jr L2D49 
        
L2D39: 
        xor a;
        push bc;
        push de;
        call $3796;
        call $37BC;
        pop de;
        pop bc;
        ld a, $01;
        call $3796 
        
L2D49: 
        push de;
        call L19C6;
        rst $30;
        dec c;
        jr z, L2D5D;
        ld a, (iy + $43);
        or a;
        jr nz, L2D78;
        call L19C6;
        call $3796;
        
L2D5D: 
        ld a, $1F;
        call $37C4;
        rst $30;
        ex af, af';
        jr z, L2D78;
        push bc;
        push de;
        call L125E;
        pop de;
        pop bc;
        jr nc, L2D73;
        pop hl;
        pop de;
        pop bc;
        ret;
        
L2D73: 
        call L081C;
        jr L2D5D 
        
L2D78: 
        call L115C;
        ld a, (iy + $44);
        sub (ix + $13);
        ld l, a;
        ld h, $00;
        call L0836;
        pop hl;
        ld a, (iy + $44);
        dec a;
        and l;
        ld l, a;
        ld h, $00;
        call L0831;
        call L114F;
        pop de;
        pop bc;
        ld h, d;
        ld l, e;
        inc h;
        inc h;
        dec hl;
        srl h;
        dec h;
        ld a, (iy + $44);
        ld l, a;
        dec a;
        and h;
        ld h, a;
        ld a, l;
        sub h;
        ld (ix + $13), a;
        or a;
        jp L19B9;
        ld hl, $0200;
        or a;
        jr nz, L2DC1;
        ld a, (iy + $44);
        push af;
        
L2DBA: 
        rrca;
        jr c, L2DC0;
        add hl, hl;
        jr L2DBA;
        
L2DC0: 
        pop af;
        
L2DC1: 
        dec hl;
        call L0831;
        ld e, d;
        ld d, c;
        ld c, b;
        ld b, $00;
        
L2DCA: 
        srl c;
        rr d;
        rr e;
        rrca;
        jr nc, L2DCA;
        jp L0824;
        ld a, $1C;
        call $37C4;
        rst $30;
        nop;
        ret;
        push ix;
        pop hl;
        add a, l;
        ld l, a;
        ret;
