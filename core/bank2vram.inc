.ifndef BANK2VRAM_INC
BANK2VRAM_INC = 1

.include "x16.inc"

.import bank2vram

.macro BANK2VRAM bank_idx, bank_offset, length, vram_addr
   stz VERA_ctrl
   VERA_SET_ADDR vram_addr, 1
   lda #bank_idx
   ldx #(bank_offset >> 5)
   ldy #<((bank_offset+length) >> 5)
   jsr bank2vram
.endmacro

.endif
