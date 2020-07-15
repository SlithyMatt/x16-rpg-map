.include "x16.inc"
.include "globals.inc"
.include "joystick.inc"
.include "music.inc"
.include "sound.inc"
.include "map.inc"

.export init_game, game_tick

init_game:
   lda #0
   jsr MOUSE_CONFIG  ; disable mouse cursor
   jsr init_map
   jsr init_music
   jsr init_sound
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
   jsr map_tick
   jsr music_tick
   jsr sound_tick
@return:
   rts
