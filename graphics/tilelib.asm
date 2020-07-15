.include "x16.inc"

.export xy2vaddr, pix2tilexy, get_tile

xy2vaddr:   ; Input:
            ;  A: layer
            ;  X: tile display x position
            ;  Y: tile display y position
            ; Output:
            ;  A: VRAM bank
            ;  X/Y: VRAM addr
   jmp @start
@vars:
@config:    .byte 0
@tilebase:  .byte 0
@map:       .word 0
@xoff:      .word 0
@yoff:      .word 0
@end_vars:
@banks:     .byte 0,1
@start:
   phx
   ldx #(@end_vars-@vars-1)
@init:
   stz @vars,x
   dex
   bpl @init
   plx
   cmp #0
   bne @layer1
   lda VERA_L0_config
   sta @config
   lda VERA_L0_tilebase
   sta @tilebase
   stz @map
   lda VERA_L0_mapbase
   sta @map+1
   lda VERA_L0_hscroll_l
   sta @xoff
   lda VERA_L0_hscroll_h
   sta @xoff+1
   lda VERA_L0_vscroll_l
   sta @yoff
   lda VERA_L0_vscroll_h
   sta @yoff+1
   jmp @do_calc
@layer1:
   lda VERA_L1_config
   sta @config
   lda VERA_L1_tilebase
   sta @tilebase
   stz @map
   lda VERA_L1_mapbase
   sta @map+1
   lda VERA_L1_hscroll_l
   sta @xoff
   lda VERA_L1_hscroll_h
   sta @xoff+1
   lda VERA_L1_vscroll_l
   sta @yoff
   lda VERA_L1_vscroll_h
   sta @yoff+1
@do_calc:
   lda @tilebase
   and #$01
   beq @xoff_div8
   clc               ; tiles are 16 pixels wide, xoff >> 4
   ror @xoff+1
   ror @xoff
@xoff_div8:
   lsr @xoff+1
   ror @xoff
   lsr @xoff+1
   ror @xoff
   lsr @xoff+1
   ror @xoff
   txa
   clc
   adc @xoff
   sta @xoff
   bcc @calc_yoff
   lda #1
   sta @xoff+1
@calc_yoff:
   lda @tilebase
   and #$02
   beq @yoff_div8
   clc               ; tiles are 16 pixels high, yoff >> 4
   ror @yoff+1
   ror @yoff
@yoff_div8:
   lsr @yoff+1
   ror @yoff
   lsr @yoff+1
   ror @yoff
   lsr @yoff+1
   ror @yoff
   tya
   clc
   adc @yoff
   sta @yoff
   bcc @calcaddr
   lda #1
   sta @yoff+1
@calcaddr:  ; address = map_base+(yoff*MAPW+xoff)*2
   lda @config
   and #$30
   lsr
   lsr
   lsr
   lsr
   clc
   adc #5
   tax            ; X = log2(MAPW)
@mult_loop:
   txa
   beq @end_mult_loop
   asl @yoff
   rol @yoff+1
   dex
   jmp @mult_loop
@end_mult_loop:   ; yoff = yoff*MAPW
   clc
   lda @yoff
   adc @xoff
   sta @yoff
   lda @yoff+1
   adc @xoff+1
   sta @yoff+1    ; yoff = yoff + xoff
   asl @yoff
   rol @yoff+1    ; yoff = yoff * 2
   asl @map+1
   lda #0
   bcc @push_bank
   lda #1
@push_bank:
   pha
   lda @yoff
   sta @map
   lda @map+1
   clc
   adc @yoff+1
   sta @map+1
   ldx #0
   bcc @pull_bank
   ldx #1
@pull_bank:
   pla
   clc
   adc @banks,x
   ldx @map
   ldy @map+1
   rts


__tile_dim: .byte $44, $84, $48, $88

pix2tilexy: ; Input:
            ; A: bit 4: layer; bits 3,2: x (9:8), bits 1,0: y (9:8)
            ; X: display x (7:0)
            ; Y: display y (7:0)
            ; Output:
            ; A: bits 7-4: TILEW/2, bits 3-0: TILEH/2
            ; X: tile x
            ; Y: tile y
   jmp @start
@tilebase:  .byte 0
@xscroll:   .word 0
@yscroll:   .word 0
@xpix:      .word 0
@ypix:      .word 0
@start:
   pha
   and #$0C
   lsr
   lsr
   sta @xpix+1
   stx @xpix
   pla
   pha
   and #$03
   sta @ypix+1
   sty @ypix
   pla
   bit #$10
   bne @layer1
   lda VERA_L0_tilebase
   sta @tilebase
   lda VERA_L0_hscroll_l
   sta @xscroll
   lda VERA_L0_hscroll_h
   sta @xscroll+1
   lda VERA_L0_vscroll_l
   sta @yscroll
   lda VERA_L0_vscroll_h
   sta @yscroll+1
   bra @calc_tile
@layer1:
   lda VERA_L1_tilebase
   sta @tilebase
   lda VERA_L1_hscroll_l
   sta @xscroll
   lda VERA_L1_hscroll_h
   sta @xscroll+1
   lda VERA_L1_vscroll_l
   sta @yscroll
   lda VERA_L1_vscroll_h
   sta @yscroll+1
@calc_tile:
   lda @xpix
   clc
   adc @xscroll
   sta @xpix
   lda @xpix+1
   adc @xscroll+1
   sta @xpix+1
   lsr @xpix+1
   ror @xpix
   lsr @xpix+1
   ror @xpix
   lsr @xpix+1
   ror @xpix
   lda @tilebase
   bit #$01
   beq @calc_y
   lsr @xpix+1
   ror @xpix
@calc_y:
   lda @ypix
   clc
   adc @yscroll
   sta @ypix
   lda @ypix+1
   adc @yscroll+1
   sta @ypix+1
   lsr @ypix+1
   ror @ypix
   lsr @ypix+1
   ror @ypix
   lsr @ypix+1
   ror @ypix
   lda @tilebase
   bit #$02
   beq @set_output
   lsr @ypix+1
   ror @ypix
@set_output:
   lda @tilebase
   and #$03
   tax
   lda __tile_dim,x
   ldx @xpix
   ldy @ypix
   rts


get_tile:   ; Input:
            ; A: layer
            ; X: tile display x position
            ; Y: tile display y position
            ; Output:
            ; A: layer
            ; X: tile entry 0
            ; Y: tile entry 1
   pha
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldx VERA_data0
   ldy VERA_data0
   pla
   rts
