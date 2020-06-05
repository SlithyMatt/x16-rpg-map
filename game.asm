.ifndef GAME_INC
GAME_INC = 1

.include "x16.inc"
.include "joystick.asm"
.include "music.asm"
.include "player.asm"

init_game:
   lda #0
   jsr MOUSE_CONFIG  ; disable mouse cursor
   jsr init_player
   jsr init_music
   rts

game_tick:        ; called after every VSYNC detected (60 Hz)
   inc frame_num
   lda frame_num
   cmp #60
   bne @tick
   lda #0
   sta frame_num
@tick:
   jsr joystick_tick
   jsr player_tick
   jsr music_tick
@return:
   rts

.endif
