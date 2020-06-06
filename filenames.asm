.ifndef FILENAMES_INC
FILENAMES_INC = 1

.include "globals.asm"

filenames:
tilemap0_fn:   .asciiz "tilemap0.bin"
tilemap1_fn:   .asciiz "tilemap1.bin"
loadmap_fn:    .asciiz "loadmap.bin"
sprites_fn:    .asciiz "sprites.bin"
tiles0_fn:     .asciiz "tiles0.bin"
tiles1_fn:     .asciiz "tiles1.bin"
palette_fn:    .asciiz "pal.bin"
music_fn:      .asciiz "music.bin"
end_filenames:
FILES_TO_LOAD = 1
bankparams:
.byte GAME_MUSIC_BANK
.byte end_filenames-music_fn-1
.word music_fn

.endif
