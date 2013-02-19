      macro     table val0, val1, val2, val3
        defb    val0, 0, val0   ; 81 83
        defb    val0, 0, val0   ; 84 86
        defb    val0, 0, val0   ; 87 89
        defb    val1, 0, val1   ; 8a 8c
        defb    val1, 0, val1   ; 8d 8f
        defb    val1, 0, val1   ; 90 92
        defb    val1, 0, val1   ; 93 95
        defb    val1, 0, val2   ; 96 98
        defb    val2, 0, val2   ; 99 9b -
        defb    val2, 0, val2   ; 9c 9e
        defb    val2, 0, val2   ; 9f a1
        defb    val2, 0, val2   ; a2 a4
        defb    val2, 0, val3   ; a5 a7
        defb    val3, 0, val3   ; a8 aa
        defb    val3, 0, val3   ; ab ad
        defb    val3, 0, val3   ; ae b0
        defb    val3, 0, val3   ; b1 b3
        defb    val3            ; b4
      endm
        output  leches.bin
        org     $5ccb
        ld      de, $8000
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; OVER USR 7 ($5ccb)
        ld      hl, comp
        push    de

dzx7    ld      a, $80
copy_byte_loop:
        ldi                             ; copy literal byte
main_loop:
        call    next_bit
        jr      nc, copy_byte_loop      ; next bit indicates either literal or sequence

; determine number of bits used for length (Elias gamma coding)
        push    de
        ld      bc, 0
        ld      d, b
length_size_loop:
        inc     d
        call    next_bit
        jr      nc, length_size_loop

; determine length
length_value_loop:
        call    nc, next_bit
        rl      c
        rl      b
        jr      c, exit                 ; check end marker
        dec     d
        jr      nz, length_value_loop
        inc     bc                      ; adjust length

; determine offset
        ld      e, (hl)                 ; load offset flag (1 bit) + offset value (7 bits)
        inc     hl
        defb    $cb, $33                ; opcode for undocumented instruction "SLL E" aka "SLS E"
        jr      nc, offset_end          ; if offset flag is set, load 4 extra bits
        ld      d, $10                  ; bit marker to load 4 bits
rld_next_bit:
        call    next_bit
        rl      d                       ; insert next bit into D
        jr      nc, rld_next_bit        ; repeat 4 times, until bit marker is out
        inc     d                       ; add 128 to DE
        srl     d                       ; retrieve fourth bit from D
offset_end:
        rr      e                       ; insert fourth bit into E

; copy previous sequence
        ex      (sp), hl                ; store source, restore destination
        push    hl                      ; store destination
        sbc     hl, de                  ; HL = destination - offset - 1
        pop     de                      ; DE = destination
        ldir
exit:
        pop     hl                      ; restore source address (compressed data)
        jr      nc, main_loop
next_bit:
        add     a, a                    ; check next bit
        ret     nz                      ; no more bits left?
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
        ret
comp    incbin  leches.zx7