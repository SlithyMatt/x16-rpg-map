.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

.include "irq.inc"
.include "vsync.inc"
.include "globals.inc"
.include "music.inc"

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

music_filename: .byte "music.bin"
MUSIC_FILENAME_SIZE = 9

START_MAP_ID = 0

start:

   lda #MAP_MUSIC_BANK
   sta music_bank

   lda #0
   sta ROM_BANK
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=8,SA=0)
   lda #MUSIC_FILENAME_SIZE
   ldx #<music_filename
   ldy #>music_filename
   jsr SETNAM        ; SetFileName(music_filename)
   lda music_bank
   sta RAM_BANK
   lda #0
   ldx #<RAM_WIN
   ldy #>RAM_WIN
   jsr LOAD          ; LoadFile(Verify=0,Address=RAM_WIN)

   PRINT_STRING "playing music.bin..."
   PRINT_CR

   ; setup interrupts
   jsr init_irq

   jsr init_music
   jsr start_music

mainloop:
   wai
   lda vsync_trig
   beq mainloop
   jsr music_tick
   stz vsync_trig
   bra mainloop  ; loop forever
