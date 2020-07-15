.include "x16.inc"
.include "charmap.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

MOUSE_PIXEL_X  = $28
MOUSE_PIXEL_Y  = $2A

curr_mouse_button: .byte 0
last_mouse_button: .byte 0
mouse_x: .byte 0
mouse_y: .byte 0

req_quit: .byte 0

num_string: .res 5
num_string_len: .byte 0
bcd_value: .dword 0
bin_value: .word 0

csv_buffer: .res (6+2+3+2+3)*4

csv_fn: .byte "psg.csv"
end_csv_fn:

psg_data: .res 4*4

INIT_FREQ   = 32768
INIT_PW     = 63

waveforms:
.byte "   PULSE"
.byte "SAWTOOTH"
.byte "TRIANGLE"
.byte "   NOISE"

channels:
.byte "--"
.byte "L-"
.byte "-R"
.byte "LR"

start_screen: ; lines are null terminated
.byte $55,$43,$43,$43,$43,$49," ",$55,$43,$43,$43,$43,$43,$43,$43,$43,$49,0
.byte $42,"QUIT",$42," ",$42,"SAVE CSV",$42,0
.byte $4A,$43,$43,$43,$43,$4B," ",$4A,$43,$43,$43,$43,$43,$43,$43,$43,$4B,0
.byte 0
.byte "        FREQ LR VOL WAVEFORM PW",0
.byte "      ",$70,$43,$43,$43,$43,$43,$72,$43,$43,$72,$43,$43,$43,$72,$43,$43,$43,$43,$43,$43,$43,$43,$72,$43,$43,$6E,0
.byte " CH 0 ",$42,"     ",$42,"  ",$42,"   ",$42,"        ",$42,"  ",$42,0
.byte "      ",$6B,$43,$43,$43,$43,$43,$5B,$43,$43,$5B,$43,$43,$43,$5B,$43,$43,$43,$43,$43,$43,$43,$43,$5B,$43,$43,$73,0
.byte " CH 1 ",$42,"     ",$42,"  ",$42,"   ",$42,"        ",$42,"  ",$42,0
.byte "      ",$6B,$43,$43,$43,$43,$43,$5B,$43,$43,$5B,$43,$43,$43,$5B,$43,$43,$43,$43,$43,$43,$43,$43,$5B,$43,$43,$73,0
.byte " CH 2 ",$42,"     ",$42,"  ",$42,"   ",$42,"        ",$42,"  ",$42,0
.byte "      ",$6B,$43,$43,$43,$43,$43,$5B,$43,$43,$5B,$43,$43,$43,$5B,$43,$43,$43,$43,$43,$43,$43,$43,$5B,$43,$43,$73,0
.byte " CH 3 ",$42,"     ",$42,"  ",$42,"   ",$42,"        ",$42,"  ",$42,0
.byte "      ",$6D,$43,$43,$43,$43,$43,$71,$43,$43,$71,$43,$43,$43,$71,$43,$43,$43,$43,$43,$43,$43,$43,$71,$43,$43,$7D,0

NUM_SCREEN_LINES = 14
screen_line: .byte 0

; Button rows
button_row: .byte 0,2

; Button areas: x, width
quit_button: .byte 0,6
save_button: .byte 7,10

; Cell rows
cell_row: .byte 6,8,10,12

; Cell areas: x, width
freq_col:      .byte 7,5
lr_col:        .byte 13,2
right_col:     .byte 14
vol_col:       .byte 17,2
waveform_col:  .byte 20,8
pw_col:        .byte 29,2
current_col:   .byte 0,0

psg_chan: .byte 0
psg_reg: .byte 0

start:
   stz req_quit
   stz screen_line
   stz last_mouse_button

   ; clear display
   jsr SCINIT

   ; set display to 2x scale
   lda #64
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; set character set to PETSCII upper/graph
   lda #2
   jsr SCREEN_SET_CHARSET

   jsr init_psg

   jsr refresh_grid

   lda #1
   ldx #1
   jsr MOUSE_CONFIG

@loop:
   cli
   wai
   sei
   lda req_quit
   bne @return
   ldx #MOUSE_PIXEL_X
   jsr MOUSE_GET
   cmp last_mouse_button
   beq @loop
   sta last_mouse_button
   cmp #0
   beq @loop
   lsr MOUSE_PIXEL_X+1
   ror MOUSE_PIXEL_X
   lsr MOUSE_PIXEL_X+1
   ror MOUSE_PIXEL_X
   lsr MOUSE_PIXEL_X+1
   lda MOUSE_PIXEL_X
   ror
   sta mouse_x
   lsr MOUSE_PIXEL_Y+1
   ror MOUSE_PIXEL_Y
   lsr MOUSE_PIXEL_Y+1
   ror MOUSE_PIXEL_Y
   lsr MOUSE_PIXEL_Y+1
   lda MOUSE_PIXEL_Y
   ror
   sta mouse_y
   jsr do_click
   jmp @loop
@return:
   cli
   jsr init_psg
   lda #0
   jsr MOUSE_CONFIG
   jsr SCINIT
   ; set display back to 1x scale
   lda #128
   sta VERA_dc_hscale
   sta VERA_dc_vscale
   rts

init_psg:
   stz VERA_ctrl
   lda #($10 | ^VRAM_psg)
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda #<VRAM_psg
   sta VERA_addr_low
   ldx #0
@chan_loop:
   lda #<INIT_FREQ
   stz VERA_data0
   lda #>INIT_FREQ
   sta VERA_data0
   stz VERA_data0
   lda #INIT_PW
   sta VERA_data0
   inx
   cpx #16
   bne @chan_loop
   rts

do_click:
   lda mouse_y
   cmp button_row
   bmi @check_cell
   dec
   cmp button_row+1
   bpl @check_cell
   lda mouse_x
   cmp quit_button
   bmi @return
   sec
   sbc quit_button
   cmp quit_button+1
   bpl @check_save
   lda #1
   sta req_quit
   bra @return
@check_save:
   lda mouse_x
   cmp save_button
   bmi @return
   sec
   sbc save_button
   cmp save_button+1
   bpl @return
   jsr save_csv
   bra @return
@check_cell:
   jsr click_cell
@return:
   rts

click_cell:
   lda mouse_y
   ldx #0
@row_loop:
   cmp cell_row,x
   beq @set_chan
   inx
   cpx #4
   bne @row_loop
   bra @return
@set_chan:
   stx psg_chan
   ldx freq_col
   ldy freq_col+1
   jsr check_column
   bne @check_waveform
   jsr input_cell
   jsr set_freq
   bra @return
@check_waveform:
   ldx waveform_col
   ldy waveform_col+1
   jsr check_column
   bne @check_left
   jsr change_waveform
   bra @return
@check_left:
   lda mouse_x
   cmp lr_col
   bne @check_right
   jsr toggle_left
   bra @return
@check_right:
   cmp right_col
   bne @check_vol
   jsr toggle_right
   bra @return
@check_vol:
   ldx vol_col
   ldy vol_col+1
   jsr check_column
   bne @check_pw
   jsr input_cell
   jsr set_vol
   bra @return
@check_pw:
   ldx pw_col
   ldy pw_col+1
   jsr check_column
   bne @return
   jsr input_cell
   jsr set_pw
@return:
   rts

check_column:
   stx current_col
   sty current_col+1
   lda mouse_x
   cmp current_col
   bmi @return
   sec
   sbc current_col
   cmp current_col+1
   bmi @in_col
   lda #1
   bra @return
@in_col:
   lda #0
@return:
   rts

input_cell:
   stz VERA_ctrl
   lda #$20
   sta VERA_addr_bank
   ldx psg_chan
   lda cell_row,x
   sta VERA_addr_high
   lda current_col
   asl
   sta VERA_addr_low
   ldx current_col+1
@clear_loop:
   cpx #0
   beq @do_cursor
   lda #$20
   sta VERA_data0
   dex
   bra @clear_loop
@do_cursor:
   clc
   ldx mouse_y
   ldy current_col
   jsr PLOT
   ldx #0
   cli
@read_loop:
   jsr CHRIN
   cmp #$20
   beq @flush
   sta num_string,x
   inx
   cpx current_col+1
   beq @flush
   bra @read_loop
@flush:
   jsr CHRIN
   cmp #$0D
   bne @flush
@convert:
   sei
   txa
   jsr str2bin
   rts

set_freq:
   stz VERA_ctrl
   lda #($10 | ^VRAM_psg)
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #<VRAM_psg
   sta VERA_addr_low
   lda bin_value
   sta VERA_data0
   lda bin_value+1
   sta VERA_data0
   jsr refresh_grid
   rts

set_vol:
   stz VERA_ctrl
   lda #^VRAM_psg
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #(<VRAM_psg + 2)
   sta VERA_addr_low
   lda bin_value
   and #$3F
   sta bin_value
   lda VERA_data0
   and #$C0
   ora bin_value
   sta VERA_data0
   jsr refresh_grid
   rts

set_pw:
   stz VERA_ctrl
   lda #^VRAM_psg
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #(<VRAM_psg + 3)
   sta VERA_addr_low
   lda bin_value
   and #$3F
   sta bin_value
   lda VERA_data0
   and #$C0
   ora bin_value
   sta VERA_data0
   jsr refresh_grid
   rts

change_waveform:
   stz VERA_ctrl
   lda #^VRAM_psg
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #(<VRAM_psg + 3)
   sta VERA_addr_low
   lda VERA_data0
   and #$3F
   sta bin_value
   lda VERA_data0
   and #$C0
   clc
   adc #$40
   ora bin_value
   sta VERA_data0
   jsr refresh_grid
   rts

toggle_left:
   stz VERA_ctrl
   lda #^VRAM_psg
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #(<VRAM_psg + 2)
   sta VERA_addr_low
   lda VERA_data0
   eor #$40
   sta VERA_data0
   jsr refresh_grid
   rts

toggle_right:
   stz VERA_ctrl
   lda #^VRAM_psg
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #(<VRAM_psg + 2)
   sta VERA_addr_low
   lda VERA_data0
   eor #$80
   sta VERA_data0
   jsr refresh_grid
   rts

refresh_grid:
   stz VERA_ctrl
   lda #<start_screen
   sta ZP_PTR_1
   lda #>start_screen
   sta ZP_PTR_1+1
   stz screen_line
@screen_loop:
   lda #$20
   sta VERA_addr_bank
   lda screen_line
   sta VERA_addr_high
   stz VERA_addr_low
@line_loop:
   lda (ZP_PTR_1)
   pha
   clc
   lda ZP_PTR_1
   adc #1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   pla
   beq @next
   sta VERA_data0
   bra @line_loop
@next:
   inc screen_line
   lda #NUM_SCREEN_LINES
   cmp screen_line
   bne @screen_loop
   stz psg_chan
@row_loop:
   stz VERA_ctrl
   lda #$20
   sta VERA_addr_bank
   ldx psg_chan
   lda cell_row,x
   sta VERA_addr_high
   lda freq_col
   asl
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda #($10 | ^VRAM_psg)
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda psg_chan
   asl
   asl
   clc
   adc #<VRAM_psg
   sta VERA_addr_low
   lda VERA_data1
   sta bin_value
   lda VERA_data1
   sta bin_value+1
   lda freq_col+1
   jsr bin2str
   ldx #0
@render_freq:
   lda num_string,x
   sta VERA_data0
   inx
   cpx freq_col+1
   bmi @render_freq
   lda VERA_data0 ; skip cell divider
   lda VERA_data1
   sta psg_reg
   and #$C0
   asl
   rol
   rol
   asl
   tax
   lda channels,x
   sta VERA_data0
   inx
   lda channels,x
   sta VERA_data0
   lda VERA_data0 ; skip cell divider
   lda VERA_data0 ; skip leading space
   lda psg_reg
   and #$3F
   sta bin_value
   stz bin_value+1
   lda vol_col+1
   jsr bin2str
   ldx #0
@render_vol:
   lda num_string,x
   sta VERA_data0
   inx
   cpx vol_col+1
   bmi @render_vol
   lda VERA_data0 ; skip cell divider
   lda VERA_data1
   sta psg_reg
   and #$C0
   lsr
   lsr
   lsr
   tax
   ldy #8
@render_waveform:
   lda waveforms,x
   sta VERA_data0
   inx
   dey
   bne @render_waveform
   lda VERA_data0 ; skip cell divider
   lda psg_reg
   and #$3F
   sta bin_value
   stz bin_value+1
   lda pw_col+1
   jsr bin2str
   ldx #0
@render_pw:
   lda num_string,x
   sta VERA_data0
   inx
   cpx pw_col+1
   bmi @render_pw
   inc psg_chan
   lda #4
   cmp psg_chan
   beq @return
   jmp @row_loop
@return:
   stz VERA_ctrl
   rts

save_csv:
   stz VERA_ctrl
   lda #($10 | ^VRAM_psg)
   sta VERA_addr_bank
   lda #>VRAM_psg
   sta VERA_addr_high
   lda #<VRAM_psg
   sta VERA_addr_low
   stz psg_chan
   ldx #0
@chan_loop:
   lda VERA_data0
   sta bin_value
   lda VERA_data0
   sta bin_value+1
   lda #5
   phx
   jsr bin2str
   plx
   ldy #0
@freq_loop:
   lda num_string,y
   sta csv_buffer,x
   inx
   iny
   cpy #5
   bne @freq_loop
   lda #$2C
   sta csv_buffer,x
   inx
   lda VERA_data0
   pha
   and #$C0
   asl
   rol
   rol
   ora #$30
   sta csv_buffer,x
   inx
   lda #$2C
   sta csv_buffer,x
   inx
   pla
   and #$3F
   sta bin_value
   stz bin_value+1
   lda #2
   phx
   jsr bin2str
   plx
   ldy #0
@vol_loop:
   lda num_string,y
   sta csv_buffer,x
   inx
   iny
   cpy #2
   bne @vol_loop
   lda #$2C
   sta csv_buffer,x
   inx
   lda VERA_data0
   pha
   and #$C0
   asl
   rol
   rol
   ora #$30
   sta csv_buffer,x
   inx
   lda #$2C
   sta csv_buffer,x
   inx
   pla
   and #$3F
   sta bin_value
   stz bin_value+1
   lda #2
   phx
   jsr bin2str
   plx
   ldy #0
@pw_loop:
   lda num_string,y
   sta csv_buffer,x
   inx
   iny
   cpy #2
   bne @pw_loop
   lda #$0A
   sta csv_buffer,x
   inx
   inc psg_chan
   lda #4
   cmp psg_chan
   beq @write_file
   jmp @chan_loop
@write_file:
   phx
   lda #0
   sta ROM_BANK
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=8,SA=0)
   lda #(end_csv_fn-csv_fn)
   ldx #<csv_fn
   ldy #>csv_fn
   jsr SETNAM
   pla
   clc
   adc #<csv_buffer
   tax
   lda #>csv_buffer
   adc #0
   tay
   lda #<csv_buffer
   sta ZP_PTR_1
   lda #>csv_buffer
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   jsr SAVE
   rts


str2bin: ; Input: A - string length
         ;        num_string - ASCII decimal string
         ; Output: bin_value - binary value
   tay
   ldx #0
@ascii_loop:
   cpy #0
   beq @fill_bcd
   dey
   lda num_string,y
   and #$0F
   sta bcd_value,x
   cpy #0
   beq @split_byte
   dey
   lda num_string,y
   and #$0F
   asl
   asl
   asl
   asl
   ora bcd_value,x
   sta bcd_value,x
   inx
   bra @ascii_loop
@split_byte:
   inx
@fill_bcd:
   cpx #3
   beq @conv_bcd
   stz bcd_value,x
   inx
   bra @fill_bcd
@conv_bcd:
   jsr bcd_bin
   rts


;This routine converts a packed 6 digit BCD value in memory locations bcd_value
;to bcd_value+2 to a binary value in locations bin_value to bin_value+1.
bcd_bin:
   stz     bin_value+1 ;Reset MSBY
   jsr     nxt_bcd  ;Get next BCD value
   sta     bin_value   ;Store in LSBY
   ldx     #$05
@get_nxt:
   jsr     nxt_bcd  ;Get next BCD value
   jsr     mpy10
   dex
   bne     @get_nxt
   rts

nxt_bcd:
   ldy     #$04
   lda     #$00
@mv_bits:
   asl     bcd_value
   rol     bcd_value+1
   rol     bcd_value+2
   rol
   dey
   bne     @mv_bits
   rts

temp2: .byte 0

;Conversion subroutine for bcd_bin
mpy10:
   sta     temp2    ;Save digit just entered
   lda     bin_value+1
   pha
   lda     bin_value
   pha
   asl     bin_value   ;Multiply partial
   rol     bin_value+1 ;result by 2
   asl     bin_value   ;Multiply by 2 again
   rol     bin_value+1
   pla              ;Add original result
   adc     bin_value
   sta     bin_value
   pla
   adc     bin_value+1
   sta     bin_value+1
   asl     bin_value   ;Multiply result by 2
   rol     bin_value+1
   lda     temp2    ;Add digit just entered
   adc     bin_value
   sta     bin_value
   lda     #$00
   adc     bin_value+1
   sta     bin_value+1
   rts

bin2str: ; Input: bin_value - binary value
         ;        A - string length (to include leading spaces, if necessary)
         ; Output: num_string - ASCII decimal string
   sta num_string_len
   stz bcd_value
   stz bcd_value+1
   stz bcd_value+2
   ldx #16
   sed
@bcd_loop:
   asl bin_value
   rol bin_value+1
   lda bcd_value
   adc bcd_value
   sta bcd_value
   lda bcd_value+1
   adc bcd_value+1
   sta bcd_value+1
   lda bcd_value+2
   adc bcd_value+2
   sta bcd_value+2
   dex
   bne @bcd_loop
   cld
   ldx #0
   ldy num_string_len
   dey
@write_string:
   lda bcd_value,x
   and #$0F
   ora #$30
   sta num_string,y
   dey
   bmi @space_fill
   lda bcd_value,x
   and #$F0
   lsr
   lsr
   lsr
   lsr
   ora #$30
   sta num_string,y
   dey
   bmi @space_fill
   inx
   bra @write_string
@space_fill:
   ldx #0
   dec num_string_len
@space_loop:
   lda num_string,x
   cmp #$30
   bne @return
   lda #$20
   sta num_string,x
   inx
   cpx num_string_len
   bne @space_loop
@return:
   rts
