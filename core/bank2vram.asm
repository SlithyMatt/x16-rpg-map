.include "x16.inc"

.export bank2vram

getramaddr: ; A = Offset into RAM bank >> 5
            ; Output: X/Y = Absolute address
   pha
   and #$07
   asl
   asl
   asl
   asl
   asl
   ora #<RAM_WIN
   tax
   pla
   and #$F8
   lsr
   lsr
   lsr
   ora #>RAM_WIN
   tay
   rts



bank2vram:  ; A = RAM bank,
            ; X = beginning of data offset >> 5,
            ; Y = end of data offset >> 5 (0 = whole bank)
   sta RAM_BANK
   phy               ; push end offset
   txa
   jsr getramaddr    ; get start address
   stx ZP_PTR_1
   sty ZP_PTR_1+1
   pla               ; pull end offset
   beq @wholebank
   jsr getramaddr    ; get end address from offset
   stx ZP_PTR_2
   sty ZP_PTR_2+1
   jmp @loop
@wholebank:
   lda #<(RAM_WIN+RAM_WIN_SIZE)
   sta ZP_PTR_2
   lda #>(RAM_WIN+RAM_WIN_SIZE)
   sta ZP_PTR_2+1
@loop:
   lda (ZP_PTR_1)    ; load from banked RAM
   sta VERA_data0     ; store to next VRAM address
   clc
   lda #1
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda #0
   adc ZP_PTR_1+1
   sta ZP_PTR_1+1
   lda ZP_PTR_1
   cmp ZP_PTR_2
   bne @loop
   lda ZP_PTR_1+1
   cmp ZP_PTR_2+1
   bne @loop
   rts
