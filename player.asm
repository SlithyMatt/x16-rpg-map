.ifndef PLAYER_INC
PLAYER_INC = 1

.include "x16.inc"
.include "joystick.asm"
.include "sprite.asm"

PLAYER_SPRITE = 1

PLAYER_X = 152
PLAYER_Y = 112

PLAYER_FRAME_LOOP_SIZE = 8

__player_lr_frames:     .byte 0,1,2,1,0,3,4,3
__player_down_frames:   .byte 5,6,7,6,5,6,7,6
__player_up_frames:     .byte 8,9,10,9,8,11,12,11
__player_ud_flips:      .byte 0,0,0,0,0,1,1,1
__player_sprite_idx:    .byte PLAYER_SPRITE
__player_sprite_x:      .word PLAYER_X
__player_sprite_y:      .word PLAYER_Y



init_player:
   SPRITE_SET_SCREEN_POS __player_sprite_idx, __player_sprite_x, __player_sprite_y
   lda __player_down_frames
   ldx #PLAYER_SPRITE
   ldy __player_ud_flips
   jsr sprite_frame
   rts

player_tick:
   ; TODO
   rts

.endif
