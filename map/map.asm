.include "player.inc"
.include "music.inc"
.include "bank2vram.inc"
.include "globals.inc"

.export init_map, start_map, map_tick, stop_map

__map_filename:   .byte "map0000.bin"
MAP_FILENAME_SIZE = 11

__map_visible: .byte 0

hex2ascii:  ; Input: A - integer value, $0-$F
            ; Output: A - ASCII character of hex digit, '0'-'F'
   cmp #$0A
   bpl @letter
   ora #$30
   bra @return
@letter:
   clc
   adc #$37
@return:
   rts

init_map: ; Input: map_id - ID of map to load and initialize
   ldx #3
   lda map_id+1
   lsr
   lsr
   lsr
   lsr
   jsr hex2ascii
   sta __map_filename,x
   inx
   lda map_id+1
   and #$0F
   jsr hex2ascii
   sta __map_filename,x
   inx
   lda map_id
   lsr
   lsr
   lsr
   lsr
   jsr hex2ascii
   sta __map_filename,x
   inx
   lda map_id
   and #$0F
   jsr hex2ascii
   sta __map_filename,x
   lda #0
   sta ROM_BANK
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=8,SA=0)
   lda #MAP_FILENAME_SIZE
   ldx #<__map_filename
   ldy #>__map_filename
   jsr SETNAM        ; SetFileName(__map_filename)
   lda #MAP_MUSIC_BANK
   sta RAM_BANK
   lda #0
   ldx #<RAM_WIN
   ldy #>RAM_WIN
   jsr LOAD          ; LoadFile(Verify=0,Address=RAM_WIN)
   jsr init_player
   jsr init_music
   rts

start_map: ; Input: X,Y - Starting background tile X,Y
   ; Disable layers and sprites
   lda VERA_dc_video
   and #$8F
   sta VERA_dc_video

   ; Setup tiles on layer 0
   lda #$52                      ; 64x64 map of 4bpp tiles
   sta VERA_L0_config
   lda #((MAP_VRAM_TILEMAP0 >> 9) & $FF)
   sta VERA_L0_mapbase
   lda #((((MAP_VRAM_TILES0 >> 11) & $3F) << 2) | $03)  ; 16x16 tiles
   sta VERA_L0_tilebase

   ; Setup tiles on layer 1
   lda #$A2                      ; 128x128 map of 4bpp tiles
   sta VERA_L1_config
   lda #((MAP_VRAM_TILEMAP1 >> 9) & $FF)
   sta VERA_L1_mapbase
   lda #((((MAP_VRAM_TILES1 >> 11) & $3F) << 2) | $00)  ; 8x8 tiles
   sta VERA_L1_tilebase

   jsr __map_position

   BANK2VRAM MAP_TILEMAP0_BANK, 0, $2000, MAP_VRAM_TILEMAP0
   BANK2VRAM MAP_TILEMAP1_BANK, 0, $2000, MAP_VRAM_TILEMAP1
   BANK2VRAM (MAP_TILEMAP1_BANK+1), 0, $2000, (MAP_VRAM_TILEMAP1+$2000)
   BANK2VRAM (MAP_TILEMAP1_BANK+2), 0, $2000, (MAP_VRAM_TILEMAP1+$4000)
   BANK2VRAM (MAP_TILEMAP1_BANK+3), 0, $2000, (MAP_VRAM_TILEMAP1+$6000)
   BANK2VRAM MAP_TILES0_BANK, 0, $2000, MAP_VRAM_TILES0
   BANK2VRAM (MAP_TILES0_BANK+1), 0, $2000, (MAP_VRAM_TILES0+$2000)
   BANK2VRAM (MAP_TILES0_BANK+2), 0, $2000, (MAP_VRAM_TILES0+$4000)
   BANK2VRAM (MAP_TILES0_BANK+3), 0, $2000, (MAP_VRAM_TILES0+$6000)
   BANK2VRAM MAP_TILES1_BANK, 0, $2000, MAP_VRAM_TILES1
   BANK2VRAM (MAP_TILES1_BANK+1), 0, $2000, (MAP_VRAM_TILES1+$2000)
   BANK2VRAM (MAP_TILES1_BANK+2), 0, $2000, (MAP_VRAM_TILES1+$4000)
   BANK2VRAM MAP_SPRITES_BANK, 0, $2000, MAP_VRAM_SPRITES
   BANK2VRAM (MAP_SPRITES_BANK+1), 0, $2000, (MAP_VRAM_SPRITES+$2000)
   BANK2VRAM (MAP_SPRITES_BANK+2), 0, $2000, (MAP_VRAM_SPRITES+$4000)
   BANK2VRAM (MAP_SPRITES_BANK+3), 0, $1980, (MAP_VRAM_SPRITES+$6000)
   BANK2VRAM MAP_CONFIG_BANK, MAPCFG_PALETTE, 512, VRAM_palette

   ; enable all layers and sprites
   lda VERA_dc_video
   ora #$70
   sta VERA_dc_video

   lda #1
   sta __map_visible

   lda #MAP_MUSIC_BANK
   sta music_bank
   jsr start_music

   lda #MAP_SOUND_BANK
   sta sound_bank
   ;jsr init_sound

   ; TODO: check for scene and start script
   rts

__map_position: ; Input: X,Y - Starting background tile X,Y
   stx player_tile_x
   sty player_tile_y
   ; set scroll position to center on X,Y
   stx VERA_L0_hscroll_l
   stz VERA_L0_hscroll_h
   asl VERA_L0_hscroll_l
   rol VERA_L0_hscroll_h
   asl VERA_L0_hscroll_l
   rol VERA_L0_hscroll_h
   asl VERA_L0_hscroll_l
   rol VERA_L0_hscroll_h
   asl VERA_L0_hscroll_l
   rol VERA_L0_hscroll_h
   lda VERA_L0_hscroll_l
   sec
   sbc #<PLAYER_X
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   sbc #>PLAYER_X
   sta VERA_L0_hscroll_h
   sty VERA_L0_vscroll_l
   stz VERA_L0_vscroll_h
   asl VERA_L0_vscroll_l
   rol VERA_L0_vscroll_h
   asl VERA_L0_vscroll_l
   rol VERA_L0_vscroll_h
   asl VERA_L0_vscroll_l
   rol VERA_L0_vscroll_h
   asl VERA_L0_vscroll_l
   rol VERA_L0_vscroll_h
   lda VERA_L0_vscroll_l
   sec
   sbc #<PLAYER_Y
   sta VERA_L0_vscroll_l
   lda VERA_L0_vscroll_h
   sbc #>PLAYER_Y
   sta VERA_L0_vscroll_h
   ; copy layer 0 scroll position to layer 1
   lda VERA_L0_hscroll_l
   sta VERA_L1_hscroll_l
   lda VERA_L0_hscroll_h
   sta VERA_L1_hscroll_h
   lda VERA_L0_vscroll_l
   sta VERA_L1_vscroll_l
   lda VERA_L0_vscroll_h
   sta VERA_L1_vscroll_h
   rts

map_tick:
   lda __map_visible
   beq @return
   jsr player_tick
   jsr __map_check_triggers
@return:
   rts

stop_map:
   stz __map_visible
   rts

TRIGGER_TABLE  = $A200
NPC_TABLE      = $A400
FRAMESET_TABLE = $A500

PORTAL_TYPE = 1
SCRIPT_TYPE = 2
ITEM_TYPE   = 3
BATTLE_TYPE = 4

__trigger_type: .byte 0

__map_check_triggers:
   lda #MAP_CONFIG_BANK
   sta RAM_BANK
   lda #<TRIGGER_TABLE
   sta ZP_PTR_1
   lda #>TRIGGER_TABLE
   sta ZP_PTR_1+1
   ldx #0
@trig_loop:
   ldy #0
   lda (ZP_PTR_1),y
   beq @return
   sta __trigger_type
   iny
   lda (ZP_PTR_1),y
   cmp player_tile_x
   bne @next
   iny
   lda (ZP_PTR_1),y
   cmp player_tile_y
   bne @next
   lda __trigger_type
   cmp #PORTAL_TYPE
   bne @check_script
   jsr __map_portal
   bra @return
@check_script:
   cmp #SCRIPT_TYPE
   bne @check_item
   jsr __map_script
   bra @return
@check_item:
   cmp #ITEM_TYPE
   bne @check_battle
   jsr __map_item
   bra @return
@check_battle:
   cmp #BATTLE_TYPE
   bne @next
   jsr __map_battle
   bra @return
@next:
   lda ZP_PTR_1
   clc
   adc #8
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   inx
   cpx #64
   bne @trig_loop
@return:
   rts

__map_portal:  ; Input: ZP_PTR_1 - Portal trigger config
   ldy #3
   lda (ZP_PTR_1),y
   cmp map_id
   bne @new_map
   iny
   lda (ZP_PTR_1),y
   cmp map_id+1
   beq @set_pos
@new_map:
   ldy #3
   lda (ZP_PTR_1),y
   sta map_id
   iny
   lda (ZP_PTR_1),y
   sta map_id+1
   iny
   lda (ZP_PTR_1),y
   pha
   iny
   lda (ZP_PTR_1),y
   pha
   jsr stop_music
   jsr init_map
   ply
   plx
   jsr start_map
   bra @return
@set_pos:
   ldy #5
   lda (ZP_PTR_1),y
   tax
   iny
   lda (ZP_PTR_1),y
   tay
   jsr __map_position
@return:
   rts

__map_script:  ; Input: ZP_PTR_1 - Portal trigger config

   rts

__map_item: ; Input: ZP_PTR_1 - Portal trigger config

   rts

__map_battle:  ; Input: ZP_PTR_1 - Portal trigger config

   rts
