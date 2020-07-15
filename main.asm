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

start:

   PRINT_STRING "loading assets..."
   PRINT_CR

   ; TODO load initial map and battle assets, game config

   ; Disable layers and sprites
   lda VERA_dc_video
   and #$8F
   sta VERA_dc_video

   ; TODO configure graphics layers for intro

   ; set display to 2x scale
   lda #64
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; enable all layers and sprites
   lda VERA_dc_video
   ora #$70
   sta VERA_dc_video

   ; setup interrupts
   jsr init_irq

   ; initialize game
   jsr init_game

   ; TODO play intro

mainloop:
   wai
   jsr check_vsync
   bra mainloop  ; loop forever
