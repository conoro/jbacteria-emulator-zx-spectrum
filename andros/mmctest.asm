        output "mmctest.bin"
;---------------------------------------------------------------------------------------------
;
; ZXMMC+ test software; allows reading/writing blocks to/from the screen and restoring
; 16K snapshots in ZX-Badaloc's BOOTROM firmware format.
;
; Unica modifica rispetto a zxmmc: la copia dei 512K avviene ad inizio card.
;
; MMC routines are from ZX-Badaloc BOOTROM Version 4.96 01/03/2007, that could run at 21MHz.
; NEW VERSION with OUTI/INI instruction unrolling, suggested by Paolo Ferraris, for maximum
; performance (218Kbytes/sec @3.5MHz)
;
; 4 Functions are provided:
;
; 40.000:       CARD INIT. Returns number of found cards (0, 1 or 2)
; 40.003:       13 blocks (512 bytes each) at offset +512KB are written to the card (from screen content)
; 40.006:       13 blocks (512 bytes each) from offset +512KB are read from the card to the screen
;
;---------------------------------------------------------------------------------------------
;


SPI_PORT        equ     $3F
OUT_PORT        equ     $1F     ; port for CS control (D1:D0)
MMC_0           equ     $F6     ; D0 LOW = SLOT0 active; D3 low = NMI disabled
IDLE_STATE      equ     $40
OP_COND         equ     $41
READ_CID        equ     $4A
SET_BLOCK       equ     $50
READ_MULTIPLE   equ     $52
TERMINATE_MULTI equ     $4C
WRITE_SINGLE    equ     $58
BLOCKSIZE       equ     $200    ; SD/MMC block size (bytes)
FATSIZE         equ     8       ; dimensioni FAT in termini di blocchi da 64KBytes (in pratica e` l'offset
                                ; da caricare nella word MSB dell'indirizzo della SD per accedere al primo
                                ; cluster di dati, subito oltre la FAT). 8 = 512KBytes (8192 entries da 64 bytes)

        org     40000

        jp      init            ; CARD INIT
        jp      writecard       ; WRITE TO CARD
        jp      readcard        ; READ FROM CARD

init    di
        ld      c, SPI_PORT
        call    gcidpo
        ld      b, 0
        ld c,a
;        jr      nz, nodet       ; salta se la card non e` stata rilevata
;        inc     c
nodet   ei
        ret

readcard
        di
        ld      c, SPI_PORT
        ld      hl, FATSIZE     ; MSB = FATSIZE = reads from a 512Kbytes offset
        ld      de, 0
        ld      ix, $4000
        ld      b, 13
        call    read_multidata
        ld      b, 0
        ld      c, a
        ei
        ret

writecard
        di
        ld      c, SPI_PORT
        ld      hl, FATSIZE     ; MSB = FATSIZE = writes to a 512Kbytes offset
        ld      de, 0
        ld      ix, $4000
        ld      b, 13
        call    mmc_write_data
        ld      b, 0
        ld      c, a
        ei
        ret


;*************************************************************************************************
;*************************************************************************************************
; MMC READ/WRITE ROUTINES that can operate @21.25MHz processor clock.
;
; RD/WR are on 512 bytes boundary ONLY.
; MULTIPLE_BLOCK READ is supported, while by now MULTIPLE_BLOCK WR is not
;
;*************************************************************************************************
;*************************************************************************************************

;-------------------------------------------------------------------------------------------
; This subroutine should be called at power-on or when a MMC has been inserted.
; It tries to get the MMC CID (writing at the provided HL pointer) and, in case of failure,
; it calls the INIT procedure then tries again.
;
; Returns A = 0 if OK, or 1 = error (no MMC found or MMC error)
;
; iF != 0 AND != $ff, the mmc_get_cid returned error code is displayed on screen.
;-------------------------------------------------------------------------------------------
getcid  ld      hl, 0
        ld      d, l
        ld      e, l
        ld      a, READ_CID
        call    send_command    ; return A
        jr      nz, cidexit
        call    waitdata_token
        ld      a, 2
        jr      nz, cidexit
        ld      b, 18           ; 16 bytes + CRC?
        inir
        xor     a
cidexit call    cs_high         ; set cs high
        in      f, (c)
        ret
gcidpo  call    getcid          ; try to read the MMC CID INFO --> (HL)
        ret     z               ; to SPI mode (MMC_INIT) communications (once after power-on)
        inc     a               ; card is probably not in SPI mode
        jr      z, needi
        bit     0, a            ; IDLE/still initializing bit
        jr      z, needi
        ld      a, 1            ; unknown response: exit
        ret
needi   call    mmcinit
        ret     nz              ; INIT error: MMC not detected.
        ld      de, BLOCKSIZE
        call    cs_low          ; set cs low
        ld      b, SET_BLOCK
        out     (c), b
        out     (c), a
        out     (c), a
        out     (c), d
        out     (c), e
        dec     a
        out     (c), a
        in      f, (c)
        in      f, (c)
        call    cs_high
        jr      gcidpo

;-----------------------------------------------------------------------------------------
; READ MULTIPLE BLOCK OF DATA TEST subroutine
;
; This routine only works for blocksize = 512 (two INI sequence).
;
; HL, DE= MSB, LSB of 32bit address in MMC memory
; B     = number of 512 bytes blocks to be read
; IX    = ram buffer address
;
; RETURN code in A:
; 0 = OK
; 1 = read_block command error
; 2 = no wait_data token from MMC
;
; DESTROYS AF, B
;-----------------------------------------------------------------------------------------
read_multidata
        ld      a, READ_MULTIPLE  ; Command code for multiple block read
        call    send_command
        ret     nz
        push    hl              ; HL should be saved
        push    ix
        pop     hl              ; INI usa HL come puntatore
jrhere  call    waitdata_token
        jr      z, mmcmb        ; OK
        ld      a, 2            ; no data token from MMC
        pop     hl
        ret
mmcmb   push    bc
        ld      b, a
inilo   ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        jr      nz, inilo
inil2   ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        ini
        jr      nz, inil2
        in      f, (c)          ; CRC
        nop
        in      f, (c)          ; CRC
        pop     bc
        djnz    jrhere
        ld      a, TERMINATE_MULTI
        call    write_command
        in      f, (c)                  ; CRC?
        in      f, (c)                  ; CRC?
        call    wait_response           ; waits for the MMC to reply "0"
        call    cs_high                 ; set cs high
        pop     hl
        call    clock32                 ; 32 more clock cycles
        call    clock32                 ; 32 more clock cycles
        call    clock32                 ; 32 more clock cycles
clock32 in      f, (c)                  ; some more clock cycles
        in      f, (c)
        in      f, (c)
        in      f, (c)
        ret

;
;-----------------------------------------------------------------------------------------
; WRITE BLOCK OF DATA subroutine. By now, we don't use the MULTIPLE_BLOCK transfer.
;
; This routine only works for blocksize = 512 (two OUTI sequence).
;
; HL, DE= MSB, LSB of 32bit address in MMC memory
; B     = number of 512 bytes blocks to write
; IX    = ram buffer address
;
; RETURN code in A:
; 0 = OK
; 1 = read_block command error
; 2 = write error (no "5" response from MMC)
;
; Destroys AF, B, DE, HL, IX.
;-----------------------------------------------------------------------------------------
mmc_write_data
        ld      a, WRITE_SINGLE     ; Command code for block read
        call    send_command
        ret     nz                  ; ERRORE
        push    bc
        ld      b, a                ; B = 0 for 256 bytes on first OTIR
        ld      a, $FE
        out     (c), a              ; first byte to be sent = DATA TOKEN
        push    hl
        push    ix
        pop     hl
out_loop1
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        jr      nz,out_loop1
out_loop2
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        outi
        jr      nz,out_loop2
        push    hl
        pop     ix
        pop     hl
        pop     bc
        out     (c), b
        out     (c), b
        call    wait_response
        and     $1F             ; masks useful response bits
        cp      6
        jr      nz, write_error
        ld      a, d            ; aggiorna il puntatore al blocco da leggere
        add     a, BLOCKSIZE/256  ; 2 se blocksize = 512
        jr      nc, nooverw
        inc     hl
nooverw ld      d, a

wait_busy
        call    wait_response   ; MMC will report "00" until busy
        dec     a
        jr      z, wait_busy
        call    cs_high
        call    clock32         ; 32 more clock cycles
        djnz    mmc_write_data  ; next block
        xor     a
        ret
write_error
        ld      a, 2            ; write error code
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
mmcinit ld      hl, $FF00 + IDLE_STATE
        call    cs_high         ; set cs high
        ld      b, 10           ; sends 80 clocks
l_init  out     (c), h
        djnz    l_init
        call    cs_low          ; set cs low
        out     (c), l          ; sends the command
        ld      b, 4
        ld      de, $9578       ; $78= 120
        xor     a
lsen0   out     (c), a          ; then sends four "00" bytes (parameters = NULL)
        djnz    lsen0
        out     (c), d          ; then this byte is ignored.
        call    wait_response
        cp      $02             ; MMC should respond 01 to this command
        jr      nz, tcshigh     ; fail to reset
resetok call    cs_high         ; set cs high
        out     (c), h          ; 8 extra clock cycles
        call    cs_low          ; set cs low
        ld      a, OP_COND      ; Sends OP_COND command
        call    write_command
        call    wait_response   ; WAIT_RESPONSE tries to receive a response reading an SPI
        bit     0, a            ; D0 SET = initialization still in progress...
        jr      z, ninitok
        call    cs_high         ; set cs high
        in      f, (c)          ; some extra clock cycles
loop3   djnz    loop3
        dec     d
        jr      nz, loop3
        xor     a
        ret
ninitok djnz    resetok         ; if no response, tries to send the entire block 254 more times
        dec     e
        jr      nz, resetok
        ld      a, 3            ; error code for INIT ERROR
tcshigh dec     a               ; MMC Reset error

;------------------------------------------------------------------------------------
; CHIP_SELECT HIGH subroutine. Destroys no registers. Entire port is tied to '1'.
;------------------------------------------------------------------------------------
cs_high push    af
        ld      a, $ff
cs_hig1 out     (OUT_PORT), a
        pop     af
        ret
        
;------------------------------------------------------------------------------------
; CHIP_SELECT LOW subroutine. Destroys no registers. The card to be selected should
; specified in CARD_SELECT (D1 = SLOT1, D0 = SLOT0, active LOW)
;------------------------------------------------------------------------------------
cs_low  push    af
        ld      a, MMC_0
        jr      cs_hig1
        
;-----------------------------------------------------------------------------------------
; SEND COMMAND TO MMC subroutine
;
; A = COMMAND CODE;
; H, L, D, E = 32 bit parameter (MSB ... LSB);
;
; Sends a $FF fake checksum
;
; RETURNS: 0 = OK; != 0 = MMC error code
;
; On OK, the CHIP SELECT will be LOW on exit
; On error, the CHIP SELECT will be deasserted on exit
;
; Destroys AF.
;-----------------------------------------------------------------------------------------

send_command
        call    cs_high         ; set cs high
        call    clock32
        call    cs_low          ; set cs high
        out     (c), a
        nop
        out     (c), h
        nop
        out     (c), l
        nop
        out     (c), d
        nop
        out     (c), e
        nop
        out     (c), e
        call    wait_response          ; waits for the MMC to reply != $FF
        dec     a
        ret     z               ; return A, 0 = no error
        call    cs_high         ; set cs high
        in      f, (c)          ; some more clock cycles
        ret                     ; returns the error code got from MMC

;-----------------------------------------------------------------------------------------
; WAIT FOR DATA TOKEN ($FE) subroutine (calls WAIT_RESPONSE up to 256 times)
; Returns with Z ok, NZ error
;-----------------------------------------------------------------------------------------
waitdata_token
        push    bc
        ld      b, 10                         ; retry counter
waitl   call    wait_response
        inc     a               ; waits for the MMC to reply $FE (DATA TOKEN)
        jr      z, exitw
        dec     a               ; but if not $FF, exits immediately (error code from MMC)
        jr      nz, exitw
        djnz    waitl
        inc     a               ; return A+2, NZ 
exitw   pop     bc
        ret

;
;-----------------------------------------------------------------------------------------
; Sends a command with parameters = 00 and checksum = $95. Destroys AF.
;-----------------------------------------------------------------------------------------
write_command
        out     (c), a          ; sends the command
        xor     a
        out     (c), a          ; then sends four "00" bytes (parameters = NULL)
        out     (c), a
        out     (c), a
        out     (c), a
;        ld      a, $95          ; $95 is only needed when the CARD INIT is being performed,
        out     (c), a          ; then this byte is ignored.
        ret

;-----------------------------------------------------------------------------------------
; Waits for the MMC to respond. Returns with A = response code; $FF = NO RESPONSE
;
; Responses from CARD are in R1 format for all command except SEND_STATUS.
; When SET, a bit indicates:
;
; D0 = Idle state / init not completed yet
; D1 = Erase Reset
; D2 = Illegal Command
; D3 = Com CRC Error
; D4 = Erase Sequence Error
; D5 = Address Error
; D6 = Parameter Error
; D7 = ALWAYS LOW
;
; Destroys AF.
;-----------------------------------------------------------------------------------------
wait_response
        push    bc
        ld      c, 50           ; retry counter
resp    in      a, (SPI_PORT)   ; reads a byte from MMC
        inc     a               ; $FF = no card data line activity
        jr      nz, resp_ok
        djnz    resp
        dec     c
        jr      nz, resp
resp_ok pop     bc
        ret

; suponer 512 bytes por sector
;0b-   200      512 bytes por sector
;0d-     4      4 sectores por cluster
;0e-  184e      6222 sectores reservados
;10-     2      2 copias FAT
;1e-     1      1 sector oculto
;24-  03d9      sectores por FAT  
;2c-     2      direccion cluster de la raiz

;03d9*200= 07b200 bytes por fat
;184e*200= 309C00 direccion fat1
;309C00+07b200= 384E00 direccion fat1
;384E00+07b200= 400000 direccion datos

;A5000,7AD800= 852800,1000000
;
; 384e00

/*<?php require 'zx.inc.php';
  $bas= line(10,"\xef\x22\x22\xaf").
        line(20,"\xf5\xc0" . number('40000'));
  $asm= assemble('mmctest');
  file_put_contents('mmc.tap',
//      head_basic('mmctest', strlen($bas), 10).
//      data($bas).
      head_code('mmctest', strlen($asm), 40000).
      data($asm));?>*/


