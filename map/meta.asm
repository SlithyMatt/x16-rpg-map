.include "x16.inc"
.include "globals.inc"
.include "map.inc"

.export tile_meta, get_tile_meta

tile_meta: .word 0

get_tile_meta: ; Input: X/Y - Tilemap 0 coordinates
               ; Output: tile_meta - meta data for coordinates
   stz ZP_PTR_1
   tya
   lsr
   ror ZP_PTR_1
   sta ZP_PTR_1+1
   txa
   asl
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #>RAM_WIN
   sta ZP_PTR_1+1
   lda #MAP_META_BANK
   sta RAM_BANK
   ldy #0
   lda (ZP_PTR_1),y
   sta tile_meta
   iny
   lda (ZP_PTR_1),y
   sta tile_meta+1
   rts
