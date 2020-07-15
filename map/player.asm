.include "x16.inc"
.include "globals.inc"
.include "joystick.inc"
.include "sprite.inc"
.include "meta.inc"
.include "tilelib.inc"

.export init_player, player_tick, player_tile_x, player_tile_y

PLAYER_INC = 1

PLAYER_SPRITE = 1
PLAYER_PO     = 4

PLAYER_X = 152
PLAYER_Y = 112

PLAYER_MIN_TILE_X = 10
PLAYER_MIN_TILE_Y = 7
PLAYER_MAX_TILE_X = 63
PLAYER_MAX_TILE_Y = 63

PLAYER_FRAME_DELTA = 1

PLAYER_FRAME_LOOP_SIZE = 8

.macro GET_TILE_XY x_screen, y_screen
   lda #(((x_screen & $0300) >> 6) | ((y_screen & $0300) >> 8))
   ldx #(x_screen & $00FF)
   ldy #(y_screen & $00FF)
   jsr pix2tilexy
.endmacro

player_tile_x:        .byte 0
player_tile_y:        .byte 0

__player_frames:        .word 0
__player_flips:         .word 0
__player_frame_index:   .byte 0
__player_delta_x:       .byte 0
__player_delta_y:       .byte 0
__player_lr_frames:     .byte 12,16,12,20
__player_down_frames:   .byte 0,4,0,8
__player_up_frames:     .byte 24,28,24,32
__player_right_flips:   .byte 0,0,0,0
__player_left_flips:    .byte 1,1,1,1
__player_up_flips:      .byte 0,0,0,0
__player_down_flips:    .byte 0,0,0,0
__player_ladder_frames: .byte 28,32,28,32
__player_ladder_flips:  .byte 0,0,0,0
__player_sprite_idx:    .byte PLAYER_SPRITE
__player_frame:         .byte 0
__player_sprite_x:      .word PLAYER_X
__player_sprite_y:      .word PLAYER_Y
__player_anim:          .byte 0
__player_z:             .byte 2
__player_meta_zbit:     .byte TM_Z2

init_player:
   SPRITE_SET_SCREEN_POS __player_sprite_idx, __player_sprite_x, __player_sprite_y
   ldx #PLAYER_SPRITE
   lda #2
   sta __player_z
   asl
   asl
   ora __player_down_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_down_frames
   jsr sprite_frame
   stz __player_anim
   rts

player_tick:
   lda joystick1_b
   bne @check_anim
   lda frame_num
   and #$01
   beq @check_anim
   jmp @return
@check_anim:
   lda __player_anim
   beq @check_move
   jmp @next_frame
@check_move:
   GET_TILE_XY PLAYER_X, PLAYER_Y
   stx player_tile_x
   sty player_tile_y
   lda joystick1_right
   beq @check_left
   jsr check_right
   bcs @next_frame
   jmp @return
@check_left:
   lda joystick1_left
   beq @check_down
   jsr check_left
   bcs @next_frame
   jmp @return
@check_down:
   lda joystick1_down
   beq @check_up
   jsr check_down
   bcs @next_frame
   jmp @return
@check_up:
   lda joystick1_up
   bne @verify_up
   jmp @return
@verify_up:
   jsr check_up
   bcs @next_frame
   jmp @return
@next_frame:
   bit __player_delta_x
   bmi @sub_x
   lda VERA_L0_hscroll_l
   clc
   adc __player_delta_x
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   adc #0
   sta VERA_L0_hscroll_h
   bra @check_y
@sub_x:
   lda VERA_L0_hscroll_l
   clc
   adc __player_delta_x
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   sbc #0
   sta VERA_L0_hscroll_h
@check_y:
   bit __player_delta_y
   bmi @sub_y
   lda VERA_L0_vscroll_l
   clc
   adc __player_delta_y
   sta VERA_L0_vscroll_l
   lda VERA_L0_vscroll_h
   adc #0
   sta VERA_L0_vscroll_h
   bra @copy_scroll
@sub_y:
   lda VERA_L0_vscroll_l
   clc
   adc __player_delta_y
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
   lda __player_frames
   sta ZP_PTR_1
   lda __player_frames+1
   sta ZP_PTR_1+1
   lda __player_flips
   sta ZP_PTR_2
   lda __player_flips+1
   sta ZP_PTR_2+1
   lda __player_frame_index
   lsr
   lsr
   tay
   lda (ZP_PTR_1),y
   pha
   lda __player_z
   asl
   asl
   ora (ZP_PTR_2),y
   ora #(PLAYER_PO << 4)
   tay
   pla
   ldx #PLAYER_SPRITE
   jsr sprite_frame
   inc __player_frame_index
   lda __player_frame_index
   cmp #16
   bmi @return
   stz __player_frame_index
   stz __player_anim
@return:
   rts

check_current_meta:
   ldx player_tile_x
   ldy player_tile_y
   jsr get_tile_meta
   lda tile_meta
   bit #TM_ZCHANGE
   bne @zchange
   lda __player_z
   cmp #3
   beq @check_z3
   bra @check_z2
@zchange:
   lda __player_z
   cmp #3
   beq @check_z2
@check_z3:
   lda #TM_Z3
   sta __player_meta_zbit
   bra @return
@check_z2:
   lda #TM_Z2
   sta __player_meta_zbit
@return:
   rts

set_next_z:
   lda __player_meta_zbit
   cmp #TM_Z3
   beq @go_z3
   lda #2
   sta __player_z
   bra @return
@go_z3:
   lda #3
   sta __player_z
@return:
   rts

check_right:   ; Output: C set if player can move right
   lda player_tile_x
   cmp #PLAYER_MAX_TILE_X
   beq @blocked
   jsr check_current_meta
   GET_TILE_XY (PLAYER_X + 16), PLAYER_Y
   jsr get_tile_meta
   lda tile_meta
   bit __player_meta_zbit
   beq @blocked
   bit #TM_LADDER
   bne @blocked
@clear:
   lda #<__player_lr_frames
   sta __player_frames
   lda #>__player_lr_frames
   sta __player_frames+1
   lda #<__player_right_flips
   sta __player_flips
   lda #>__player_right_flips
   sta __player_flips+1
   stz __player_frame_index
   lda #1
   sta __player_anim
   lda #PLAYER_FRAME_DELTA
   sta __player_delta_x
   stz __player_delta_y
   jsr set_next_z
   sec
   bra @return
@blocked:
   lda __player_z
   asl
   asl
   ora __player_right_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_lr_frames
   ldx #PLAYER_SPRITE
   jsr sprite_frame
   clc
@return:
   rts

check_left:   ; Output: C set if player can move right
   lda player_tile_x
   cmp #PLAYER_MIN_TILE_X
   beq @blocked
   jsr check_current_meta
   GET_TILE_XY (PLAYER_X - 16), PLAYER_Y
   jsr get_tile_meta
   lda tile_meta
   bit __player_meta_zbit
   beq @blocked
   bit #TM_LADDER
   bne @blocked
   lda #<__player_lr_frames
   sta __player_frames
   lda #>__player_lr_frames
   sta __player_frames+1
   lda #<__player_left_flips
   sta __player_flips
   lda #>__player_left_flips
   sta __player_flips+1
   stz __player_frame_index
   lda #1
   sta __player_anim
   lda #($FF - PLAYER_FRAME_DELTA + 1)
   sta __player_delta_x
   stz __player_delta_y
   jsr set_next_z
   sec
   bra @return
@blocked:
   lda __player_z
   asl
   asl
   ora __player_left_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_lr_frames
   ldx #PLAYER_SPRITE
   jsr sprite_frame
   clc
@return:
   rts

check_down: ; Output: C set if player can move down
   lda player_tile_y
   cmp #PLAYER_MAX_TILE_Y
   beq @blocked
   jsr check_current_meta
   GET_TILE_XY PLAYER_X, (PLAYER_Y+16)
   jsr get_tile_meta
   lda tile_meta
   bit __player_meta_zbit
   beq @blocked
   bit #TM_LADDER
   beq @normal
   lda #<__player_ladder_frames
   sta __player_frames
   lda #>__player_ladder_frames
   sta __player_frames+1
   lda #<__player_ladder_flips
   sta __player_flips
   lda #>__player_ladder_flips
   sta __player_flips+1
   bra @start
@normal:
   lda #<__player_down_frames
   sta __player_frames
   lda #>__player_down_frames
   sta __player_frames+1
   lda #<__player_down_flips
   sta __player_flips
   lda #>__player_down_flips
   sta __player_flips+1
@start:
   stz __player_frame_index
   lda #1
   sta __player_anim
   stz __player_delta_x
   lda #PLAYER_FRAME_DELTA
   sta __player_delta_y
   jsr set_next_z
   sec
   bra @return
@blocked:
   lda __player_z
   asl
   asl
   ora __player_down_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_down_frames
   ldx #PLAYER_SPRITE
   jsr sprite_frame
   clc
@return:
   rts

check_up:   ; Output: C set if player can move up
   lda player_tile_y
   cmp #PLAYER_MIN_TILE_Y
   beq @blocked
   jsr check_current_meta
   GET_TILE_XY PLAYER_X, (PLAYER_Y-16)
   jsr get_tile_meta
   lda tile_meta
   bit __player_meta_zbit
   beq @blocked
   bit #TM_LADDER
   beq @normal
   lda #<__player_ladder_frames
   sta __player_frames
   lda #>__player_ladder_frames
   sta __player_frames+1
   lda #<__player_ladder_flips
   sta __player_flips
   lda #>__player_ladder_flips
   sta __player_flips+1
   bra @start
@normal:
   lda #<__player_up_frames
   sta __player_frames
   lda #>__player_up_frames
   sta __player_frames+1
   lda #<__player_up_flips
   sta __player_flips
   lda #>__player_up_flips
   sta __player_flips+1
@start:
   stz __player_frame_index
   lda #1
   sta __player_anim
   stz __player_delta_x
   lda #($FF - PLAYER_FRAME_DELTA + 1)
   sta __player_delta_y
   jsr set_next_z
   sec
   bra @return
@blocked:
   lda __player_z
   asl
   asl
   ora __player_up_flips
   ora #(PLAYER_PO << 4)
   tay
   lda __player_up_frames
   ldx #PLAYER_SPRITE
   jsr sprite_frame
   clc
@return:
   rts
