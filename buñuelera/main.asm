;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.3.0 #8604 (May 11 2013) (MINGW32)
; This file was generated Tue Jan 07 15:21:59 2014
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _sprites
	.globl _screen
	.globl _tiles
	.globl _positions
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_tiles	=	0x5b01
_screen	=	0x5b00
_sprites	=	0x5c00
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;main.c:13: int main()
;	---------------------------------
; Function main
; ---------------------------------
_main_start::
_main:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;main.c:20: __endasm;
	ld sp, #57104
;main.c:23: for ( i = 0; i < 32; i++ )
	ld	de,#0x0000
00124$:
;main.c:24: sprites[i>>2][i&3]= positions[i];
	ld	l, e
	ld	h, d
	sra	h
	rr	l
	sra	h
	rr	l
	add	hl, hl
	add	hl, hl
	ld	bc,#_sprites
	add	hl,bc
	ld	a,e
	and	a, #0x03
	ld	c,a
	ld	b,#0x00
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	hl,#_positions
	add	hl,de
	ld	a,(hl)
	ld	(bc),a
;main.c:23: for ( i = 0; i < 32; i++ )
	inc	de
	ld	a,e
	sub	a, #0x20
	ld	a,d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00124$
;main.c:27: INIT;
	call 0xfffc
;main.c:30: screen= 0;
	ld	iy,#_screen
	ld	0 (iy),#0x00
;main.c:32: while(1){
00122$:
;main.c:35: FRAME;
	call 0xfff1
;main.c:38: for ( i = 1; i < 8; i++ ){
	ld	bc,#0x0001
00126$:
;main.c:39: if( sprites[i][3]&1 )
	ld	e, c
	ld	d, b
	sla	e
	rl	d
	sla	e
	rl	d
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ld	a,(hl)
	rrca
	jr	NC,00109$
;main.c:40: if( sprites[i][2] )
	ld	hl,#_sprites+1+1
	add	hl,de
	ld	a,(hl)
	or	a, a
	jr	Z,00103$
;main.c:41: sprites[i][2]--;
	ld	hl,#_sprites+1+1
	add	hl,de
	ld	a,(hl)
	add	a,#0xFF
	ld	(hl),a
	jr	00110$
00103$:
;main.c:43: sprites[i][3]^= 1;
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ex	(sp), hl
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ld	a,(hl)
	xor	a, #0x01
	pop	hl
	push	hl
	ld	(hl),a
	jr	00110$
00109$:
;main.c:45: if( sprites[i][2]<0x90 )
	ld	hl,#_sprites+1+1
	add	hl,de
	ld	a, (hl)
	sub	a, #0x90
	jr	NC,00106$
;main.c:46: sprites[i][2]++;
	ld	hl,#_sprites+1+1
	add	hl,de
	inc	(hl)
	jr	00110$
00106$:
;main.c:48: sprites[i][3]^= 1;
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ex	(sp), hl
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ld	a,(hl)
	xor	a, #0x01
	pop	hl
	push	hl
	ld	(hl),a
00110$:
;main.c:49: if( sprites[i][3]&2 )
	ld	hl,#_sprites+1+1+1
	add	hl,de
	bit	1,(hl)
	jr	Z,00118$
;main.c:50: if( sprites[i][1]>0x08 )
	ld	hl,#_sprites+1
	add	hl,de
	ld	h,(hl)
	ld	a,#0x08
	sub	a, h
	jr	NC,00112$
;main.c:51: sprites[i][1]--;
	ld	hl,#_sprites+1
	add	hl,de
	ld	d,(hl)
	dec	d
	ld	(hl),d
	jr	00127$
00112$:
;main.c:53: sprites[i][3]^= 2;
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ex	(sp), hl
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ld	a,(hl)
	xor	a, #0x02
	pop	hl
	push	hl
	ld	(hl),a
	jr	00127$
00118$:
;main.c:55: if( sprites[i][1]<0xe8 )
	ld	hl,#_sprites+1
	add	hl,de
	ld	a, (hl)
	sub	a, #0xE8
	jr	NC,00115$
;main.c:56: sprites[i][1]++;
	ld	hl,#_sprites+1
	add	hl,de
	inc	(hl)
	jr	00127$
00115$:
;main.c:58: sprites[i][3]^= 2;
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ex	(sp), hl
	ld	hl,#_sprites+1+1+1
	add	hl,de
	ld	a,(hl)
	xor	a, #0x02
	pop	hl
	push	hl
	ld	(hl),a
00127$:
;main.c:38: for ( i = 1; i < 8; i++ ){
	inc	bc
	ld	a,c
	sub	a, #0x08
	ld	a,b
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C,00126$
	jp	00122$
_main_end::
_positions:
	.db #0x00	; 0
	.db #0x42	; 66	'B'
	.db #0x11	; 17
	.db #0x00	; 0
	.db #0x08	; 8
	.db #0x60	; 96
	.db #0x60	; 96
	.db #0x02	; 2
	.db #0x09	; 9
	.db #0xA8	; 168
	.db #0x48	; 72	'H'
	.db #0x03	; 3
	.db #0x0A	; 10
	.db #0x22	; 34
	.db #0x02	; 2
	.db #0x01	; 1
	.db #0x0B	; 11
	.db #0xD0	; 208
	.db #0x6E	; 110	'n'
	.db #0x02	; 2
	.db #0x0C	; 12
	.db #0xB6	; 182
	.db #0x34	; 52	'4'
	.db #0x03	; 3
	.db #0x0D	; 13
	.db #0x32	; 50	'2'
	.db #0x32	; 50	'2'
	.db #0x01	; 1
	.db #0x04	; 4
	.db #0x52	; 82	'R'
	.db #0x5E	; 94
	.db #0x00	; 0
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
