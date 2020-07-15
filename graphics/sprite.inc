.ifndef SPRITE_INC
SPRITE_INC = 1

.import sprite_frame, sprite_getpos, move_sprite_right, move_sprite_left
.import move_sprite_down, move_sprite_up

.import __sprite_get_screen_pos, __sprite_sp_x, __sprite_sp_y

; Macro: SPRITE_GET_SCREEN_POS
; Input:
;  idx_addr: address of byte containing sprite index
;  xpos_addr: address of writable word
;  ypos_addr: address of writable word
; Output:
;  A: z-depth (0=disabled)
;  xpos_addr: address of word containing sprite X position
;  ypos_addr: address of word containing sprite Y position
.macro SPRITE_GET_SCREEN_POS idx_addr, xpos_addr, ypos_addr
   lda idx_addr
   jsr __sprite_get_screen_pos
   ldx __sprite_sp_x
   stx xpos_addr
   ldx __sprite_sp_x+1
   stx xpos_addr+1
   ldx __sprite_sp_y
   stx ypos_addr
   ldx __sprite_sp_y+1
   stx ypos_addr+1
.endmacro

.import __sprite_cb_x1, __sprite_cb_y1, __sprite_cb_x2, __sprite_cb_y2
.import __sprite_check_box

; Macro: SPRITE_CHECK_BOX
; Input:
;  max: Maximum pixels in either direction between positions
;  x1_addr: address of word containing X coordinate of position 1
;  y1_addr: address of word containing Y coordinate of position 1
;  x2_addr: address of word containing X coordinate of position 2
;  y2_addr: address of word containing Y coordinate of position 2
; Output:
;  A: 0=outside box; 1: inside box
.macro SPRITE_CHECK_BOX max, x1_addr, y1_addr, x2_addr, y2_addr
   lda x1_addr
   sta __sprite_cb_x1
   lda x1_addr+1
   sta __sprite_cb_x1+1
   lda y1_addr
   sta __sprite_cb_y1
   lda y1_addr+1
   sta __sprite_cb_y1+1
   lda x2_addr
   sta __sprite_cb_x2
   lda x2_addr+1
   sta __sprite_cb_x2+1
   lda y2_addr
   sta __sprite_cb_y2
   lda y2_addr+1
   sta __sprite_cb_y2+1
   lda #max
   jsr __sprite_check_box
.endmacro

.import sprite_disable, sprite_set_po, sprite_setpos

.import __sprattr

.macro SPRITE_SET_SCREEN_POS index_addr, xpos_addr, ypos_addr
                           ; Input:
                           ;  idx_addr: address of byte containing sprite index
                           ;  xpos_addr: address of word containing X position
                           ;  ypos_addr: address of word containing Y position
   lda index_addr
   jsr __sprattr
   lda VERA_data0 ; use current frame for now
   lda VERA_data0
   lda xpos_addr
   sta VERA_data0
   lda xpos_addr+1
   sta VERA_data0
   lda ypos_addr
   sta VERA_data0
   lda ypos_addr+1
   sta VERA_data0
.endmacro


.endif
