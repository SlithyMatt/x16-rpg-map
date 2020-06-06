.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

.include "filenames.asm"
.include "loadbank.asm"
.include "loadvram.asm"
.include "irq.asm"
.include "vsync.asm"
.include "game.asm"
.include "globals.asm"

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

   PRINT_STRING "loading map tiles..."
   PRINT_CR

   lda #>(VRAM_TILES0>>4)
   ldx #<(VRAM_TILES0>>4)
   ldy #<tiles0_fn
   jsr loadvram

   PRINT_STRING "loading GUI tiles..."
   PRINT_CR

   ; load VRAM data from binaries
   lda #>(VRAM_TILES1>>4)
   ldx #<(VRAM_TILES1>>4)
   ldy #<tiles1_fn
   jsr loadvram

   PRINT_STRING "loading sprites..."
   PRINT_CR

   lda #>(VRAM_SPRITES>>4)
   ldx #<(VRAM_SPRITES>>4)
   ldy #<sprites_fn
   jsr loadvram

   PRINT_STRING "loading palette..."
   PRINT_CR

   lda #>(VRAM_palette>>4)
   ldx #<(VRAM_palette>>4)
   ldy #<palette_fn
   jsr loadvram

   PRINT_STRING "loading banked RAM"
   jsr loadbank

   ; Disable layers and sprites
   lda VERA_dc_video
   and #$8F
   sta VERA_dc_video

   ; Setup tiles on layer 0
   lda #$52                      ; 64x64 map of 4bpp tiles
   sta VERA_L0_config
   lda #((VRAM_TILEMAP0 >> 9) & $FF)
   sta VERA_L0_mapbase
   lda #((((VRAM_TILES0 >> 11) & $3F) << 2) | $03)  ; 16x16 tiles
   sta VERA_L0_tilebase
   stz VERA_L0_hscroll_l         ; set scroll position to 0,0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l
   stz VERA_L0_vscroll_h

   lda #>(VRAM_TILEMAP0>>4)
   ldx #<(VRAM_TILEMAP0>>4)
   ldy #<tilemap0_fn
   jsr loadvram

   ; Setup tiles on layer 1
   lda #$A2                      ; 128x128 map of 4bpp tiles
   sta VERA_L1_config
   lda #((VRAM_TILEMAP1 >> 9) & $FF)
   sta VERA_L1_mapbase
   lda #((((VRAM_TILES1 >> 11) & $3F) << 2) | $00)  ; 8x8 tiles
   sta VERA_L1_tilebase
   stz VERA_L1_hscroll_l         ; set scroll position to 0,0
   stz VERA_L1_hscroll_h
   stz VERA_L1_vscroll_l
   stz VERA_L1_vscroll_h

   lda #>(VRAM_TILEMAP1>>4)
   ldx #<(VRAM_TILEMAP1>>4)
   ldy #<tilemap1_fn
   jsr loadvram


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

mainloop:
   wai
   jsr check_vsync
   bra mainloop  ; loop forever
