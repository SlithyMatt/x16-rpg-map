.ifndef PLAYER_INC
PLAYER_INC = 1

.include "x16.inc"
.include "joystick.asm"
.include "sprite.asm"

PLAYER_SPRITE = 1
PLAYER_PO     = 3

PLAYER_X = 152
PLAYER_Y = 112

PLAYER_MOVE_PIXELS = 1

MAX_SCROLL_X = 1024 - 320
MAX_SCROLL_Y = 1024 - 240

PLAYER_FRAME_LOOP_SIZE = 8

__player_lr_frames:     .byte 0,1,2,1,0,3,4,3
__player_down_frames:   .byte 5,6,7,6,5,6,7,6
__player_up_frames:     .byte 8,9,10,9,8,9,10,9
__player_right_flips:   .byte 0,0,0,0,0,0,0,0
__player_left_flips:    .byte 1,1,1,1,1,1,1,1
__player_ud_flips:      .byte 0,0,0,0,0,1,1,1
__player_sprite_idx:    .byte PLAYER_SPRITE
__player_frame:         .byte 0
__player_sprite_x:      .word PLAYER_X
__player_sprite_y:      .word PLAYER_Y

init_player:
   SPRITE_SET_SCREEN_POS __player_sprite_idx, __player_sprite_x, __player_sprite_y
   ldx #PLAYER_SPRITE
   lda __player_ud_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_down_frames
   jsr sprite_frame
   rts

player_tick:
   lda frame_num
   and #1
   beq @check_move
   jmp @return
@check_move:
   lda VERA_L0_hscroll_l
   cmp #<MAX_SCROLL_X
   bne @check_right
   lda VERA_L0_hscroll_h
   cmp #>MAX_SCROLL_X
   beq @check_min_x
@check_right:
   lda joystick1_right
   beq @check_min_x
   lda VERA_L0_hscroll_l
   clc
   adc #PLAYER_MOVE_PIXELS
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   adc #0
   sta VERA_L0_hscroll_h
@check_min_x:
   lda VERA_L0_hscroll_l
   cmp #0
   bne @check_left
   lda VERA_L0_hscroll_h
   cmp #0
   beq @check_max_y
@check_left:
   lda joystick1_left
   beq @check_max_y
   lda VERA_L0_hscroll_l
   sec
   sbc #PLAYER_MOVE_PIXELS
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   sbc #0
   sta VERA_L0_hscroll_h
@check_max_y:
   lda VERA_L0_vscroll_l
   cmp #<MAX_SCROLL_Y
   bne @check_down
   lda VERA_L0_vscroll_h
   cmp #>MAX_SCROLL_Y
   beq @check_min_y
@check_down:
   lda joystick1_down
   beq @check_min_y
   lda VERA_L0_vscroll_l
   clc
   adc #PLAYER_MOVE_PIXELS
   sta VERA_L0_vscroll_l
   lda VERA_L0_vscroll_h
   adc #0
   sta VERA_L0_vscroll_h
@check_min_y:
   lda VERA_L0_vscroll_l
   cmp #0
   bne @check_up
   lda VERA_L0_vscroll_h
   cmp #0
   beq @copy_scroll
@check_up:
   lda joystick1_up
   beq @copy_scroll
   lda VERA_L0_vscroll_l
   sec
   sbc #PLAYER_MOVE_PIXELS
   sta VERA_L0_vscroll_l
   lda VERA_L0_vscroll_h
   sbc #0
   sta VERA_L0_vscroll_h
@copy_scroll:
   lda VERA_L0_hscroll_l
   sta VERA_L1_hscroll_l
   lda VERA_L0_hscroll_h
   sta VERA_L1_hscroll_h
   lda VERA_L0_vscroll_l
   sta VERA_L1_vscroll_l
   lda VERA_L0_vscroll_h
   sta VERA_L1_vscroll_h
   lda frame_num
   and #3
   beq @check_loop_down
   jmp @return
@check_loop_down:
   lda joystick1_down
   beq @check_loop_up
   lda #<__player_down_frames
   sta ZP_PTR_1
   lda #>__player_down_frames
   sta ZP_PTR_1+1
   lda #<__player_ud_flips
   sta ZP_PTR_2
   lda #>__player_ud_flips
   sta ZP_PTR_2+1
   bra @advance
@check_loop_up:
   lda joystick1_up
   beq @check_loop_left
   lda #<__player_up_frames
   sta ZP_PTR_1
   lda #>__player_up_frames
   sta ZP_PTR_1+1
   lda #<__player_ud_flips
   sta ZP_PTR_2
   lda #>__player_ud_flips
   sta ZP_PTR_2+1
   bra @advance
@check_loop_left:
   lda joystick1_left
   beq @check_loop_right
   lda #<__player_lr_frames
   sta ZP_PTR_1
   lda #>__player_lr_frames
   sta ZP_PTR_1+1
   lda #<__player_left_flips
   sta ZP_PTR_2
   lda #>__player_left_flips
   sta ZP_PTR_2+1
   bra @advance
@check_loop_right:
   lda joystick1_right
   beq @return
   lda #<__player_lr_frames
   sta ZP_PTR_1
   lda #>__player_lr_frames
   sta ZP_PTR_1+1
   lda #<__player_right_flips
   sta ZP_PTR_2
   lda #>__player_right_flips
   sta ZP_PTR_2+1
@advance:
   ldy __player_frame
   iny
   cpy #PLAYER_FRAME_LOOP_SIZE
   bne @set_frame
   ldy #0
@set_frame:
   sty __player_frame
   lda (ZP_PTR_1),y
   pha
   lda (ZP_PTR_2),y
   ora #(PLAYER_PO << 4)
   tay
   pla
   ldx #PLAYER_SPRITE
   jsr sprite_frame
@return:
   rts

.endif
