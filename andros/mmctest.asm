        output "mmctest.bin"

SPI_PORT        equ     $3F
OUT_PORT        equ     $1F     ; port for CS control (D1:D0)
MMC_0           equ     $F6     ; D0 LOW = SLOT0 active; D3 low = NMI disabled
IDLE_STATE      equ     $40
OP_COND         equ     $41
READ_SINGLE     equ     $51
READ_MULTIPLE   equ     $52
TERMINATE_MULTI equ     $4C
WRITE_SINGLE    equ     $58
BLOCKSIZE       equ     $200    ; SD/MMC block size (bytes)

        org     50000

        di
        ld      c, SPI_PORT
        sbc     hl, hl          ; read MBR
        ld      e, l
        ld      ix, $8000
        call    readata
        ld      hl, ($81c6)
        ld      a, ($81c8)
        add     hl, hl
        adc     a, a
        ld      e, a
        call    readata
        ld      a, e
        ex      de, hl
        ld      hl, ($800e)
        add     hl, hl
        adc     a, 0  ;b
        add     hl, de
        adc     a, 0  ;b
        ld      (fat), hl
        ld      (fat+2), a
        ld      b, a
        ex      de, hl
        ld      hl, ($8024)
        ld      a, ($8026)
        add     hl, hl
        adc     a, a
        add     hl, hl
        adc     a, a
        add     hl, de
        adc     a, b
        ld      (dire), hl
        ld      (dire+2), a
        ld      hl, ($802c)
        ld      a, ($802e)
        ld      b, a
tica    push    hl
        push    bc
        call    calcs
        ld      de, (dire)
        add     hl, de
        ld      a, (dire+2)
        adc     a, b
        ld      e, a
        ld      d, 0
        ld      ix, $9000
        push    ix
        ld      a, ($800d)
        ld      b, a
otve    call    readata
        inc     ixh
        inc     ixh
        inc     l
        inc     hl
        djnz    otve
        pop     hl
        ld      a, ($800d)
        ld      c, a
buba    ld      b, 16
bubi    push    bc
        ld      b, 11
        ld      a, (hl)
        cp      $e5
        jr      z, desc
        ld      de, filena
        push    hl
buub    ld      a, (de)
        cp      (hl)
        inc     hl
        inc     de
        jr      nz, beeb
        djnz    buub
beeb    jr      z, bien
        pop     hl
desc    pop     bc
        ld      de, $0020
        add     hl, de
        djnz    bubi
        dec     c
        jr      nz, buba
        pop     bc
        ld      c, SPI_PORT
        pop     hl
        ld      a, l
        or      h
        or      b
        inc     a
        jr      z, fina
        add     hl, hl
        rl      b
        push    hl
        rl      h
        rl      b
        ld      l, h
        ld      h, b
        ld      de, (fat)
        add     hl, de
        ld      e, 0
        ld      ix, $9000
        call    readata
        pop     hl
        ld      h, $48
        add     hl, hl
        ld      e, (hl)
        inc     hl
        ld      d, (hl)
        inc     hl
        ld      b, (hl)
        ex      de, hl
        jp      tica
        
fina    ld      a, 'M'
        rst     $10
hhh jr hhh


bien    ld      c, SPI_PORT
        ld      de, 9
        add     hl, de
        ld      b, (hl)
        ld      e, 6
        add     hl, de
        ld      a, (hl)
        inc     hl
        ld      h, (hl)
        ld      l, a
        call    calcs
        ld      de, (dire)
        add     hl, de
        ld      a, (dire+2)
        adc     a, b
        ld      e, a
        ld      d, 0
        ld      ix, $4000
        ld      a, ($800d)
        ld      b, 16
cuan    call    readata
        inc     ixh
        inc     ixh
        inc     l
        inc     hl
        djnz    cuan
    jr hhh


calcs   ld      a, [$800d]
        call    decbhl
        call    decbhl
agai    add     hl, hl
        rl      b
        rrca
        jr      nc, agai
        ret

decbhl  dec     l
        ret     nc
        dec     h
        ret     nc
        dec     b
        ret

;-----------------------------------------------------------------------------------------
; READ DATA TEST subroutine
;
; HL, DE= MSB, LSB of 32bit address in MMC memory
; IX    = ram buffer address
;
; RETURN code
; Z OK, NZ ERROR

; DESTROYS AF, B
;-----------------------------------------------------------------------------------------
reinit  call    mmcinit
        ret     nz
readata ld      a, READ_SINGLE  ; Command code for multiple block read
        call    cs_low          ; set cs high
        out     (c), a
        nop
        out     (c), e
        nop
        out     (c), h
        nop
        out     (c), l
        nop
        out     (c), 0
        nop
        out     (c), 0
        call    waitr           ; waits for the MMC to reply != $FF
        dec     a
        jr      nz, reinit
        call    waittok
        ret     nz
        push    bc
        push    hl
        push    ix
        pop     hl              ; INI usa HL come puntatore
        ld      b, a
        inir
        inir
        pop     hl
        pop     bc
        ret

;
;-----------------------------------------------------------------------------------------
; MMC SPI MODE initialization. RETURNS ERROR CODE IN A register:
;
; 0 = OK
; 1 = Card RESET ERROR
; 2 = Card INIT ERROR
;
; Destroys AF, B.
;-----------------------------------------------------------------------------------------
mmcinit push    bc
        push    hl
        ld      hl, $FF00 + IDLE_STATE
        call    cs_high         ; set cs high
        ld      b, 9            ; sends 80 clocks
l_init  out     (c), h
        djnz    l_init
        call    cs_low          ; set cs low
        out     (c), l          ; sends the command
        ld      b, 4
        ld      hl, $9540       ; $40= 64
lsen0   out     (c), 0          ; then sends four "00" bytes (parameters = NULL)
        djnz    lsen0
        out     (c), h          ; then this byte is ignored.
        call    waitr
        cp      $02             ; MMC should respond 01 to this command
        jr      nz, mmcfin      ; fail to reset
resetok call    cs_high         ; set cs high
        out     (c), h          ; 8 extra clock cycles
        call    cs_low          ; set cs low
        ld      a, OP_COND      ; Sends OP_COND command
        out     (c), a          ; sends the command
        out     (c), 0          ; then sends four "00" bytes (parameters = NULL)
        out     (c), 0
        out     (c), 0
        out     (c), 0
        out     (c), 0          ; then this byte is ignored.
        call    waitr           ; waitr tries to receive a response reading an SPI
        bit     0, a            ; D0 SET = initialization still in progress...
        jr      z, ninitok
        call    cs_high         ; set cs high
loop3   djnz    loop3
        dec     h
        jr      nz, loop3
        pop     hl
        ret
ninitok djnz    resetok         ; if no response, tries to send the entire block 254 more times
        dec     l
        jr      nz, resetok
        inc     l
mmcfin  pop     hl
        pop     bc
cs_high push    af
        ld      a, $ff
cs_hig1 out     (OUT_PORT), a
        pop     af
        ret

cs_low  push    af
        ld      a, MMC_0
        jr      cs_hig1
        
waittok push    bc
        ld      b, 10                         ; retry counter
waitl   call    waitr
        inc     a               ; waits for the MMC to reply $FE (DATA TOKEN)
        jr      z, exitw
        dec     a               ; but if not $FF, exits immediately (error code from MMC)
        jr      nz, exitw
        djnz    waitl
        inc     a               ; return A+2, NZ 
exitw   pop     bc
        ret

waitr   push    bc
        ld      c, 50           ; retry counter
resp    in      a, (SPI_PORT)   ; reads a byte from MMC
        inc     a               ; $FF = no card data line activity
        jr      nz, resp_ok
        djnz    resp
        dec     c
        jr      nz, resp
resp_ok pop     bc
        ret

dire    defb    0, 0, 0
fat     defb    0, 0, 0
filena  defb    'BOOT    SCR'

hex:    push    af
        and     $f0
        rrca
        rrca
        rrca
        rrca
        cp      $0a
        jr      c, mayo
        add     a, 7
mayo:   add     a, $30
        rst     $10
        pop     af
        and     $0f
        cp      $0a
        jr      c, maya
        add     a, 7
maya:   add     a, $30
        rst     $10
        ret

/*<?php require 'zx.inc.php';
  $bas= line(10,"\xef\x22\x22\xaf").
        line(20,"\xf5\xc0" . number('50000'));
  $asm= assemble('mmctest');
  file_put_contents('mmc.tap',
      head_basic('mmctest', strlen($bas), 10).
      data($bas).
      head_code('mmctest', strlen($asm), 50000).
      data($asm));?>*/
