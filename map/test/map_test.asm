.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

.include "irq.inc"
.include "vsync.inc"
.include "game.inc"
.include "globals.inc"
.include "music.inc"
.include "map.inc"

.macro PRINT_STRING str_arg
   .scope
         jmp end_string
      string_begin: .byte str_arg
      end_string:
         lda #<string_begin
         sta ZP_PTR_1
         lda #>string_begin
         sta ZP_PTR_1+1
         ldx #(end_string-string_begin)
         ldy #0
      loop:
         lda (ZP_PTR_1),y
         jsr CHROUT
         iny
         dex
         bne loop
   .endscope
.endmacro

.macro PRINT_CR
   lda #$0D
   jsr CHROUT
.endmacro

START_MAP_ID = 0

start:

   ; set display to 2x scale
   lda #64
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; setup interrupts
   jsr init_irq

   ; initialize game
   lda #<START_MAP_ID
   sta map_id
   lda #>START_MAP_ID
   sta map_id+1
   jsr init_game
   ldx #12
   ldy #10
   jsr start_map

mainloop:
   wai
   jsr check_vsync
   bra mainloop  ; loop forever
