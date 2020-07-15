.include "game.inc"

.export vsync_trig, check_vsync

vsync_trig: .byte 0

check_vsync:
   lda vsync_trig
   beq @done

   ; VSYNC has occurred, handle
   jsr game_tick

   stz vsync_trig
@done:
   rts
