.ifndef GLOBALS_INC
GLOBALS_INC = 1

; ---------- Build Options ----------

; ------------ Constants ------------

; zero page pointers
MUSIC_PTR      = $28

; VRAM map
VRAM_TILEMAP0  = $00000 ; 64x64 tilemap (map background)
VRAM_TILEMAP1  = $02000 ; 128x128 tilemap (map foreground/GUI)
VRAM_TILES0    = $0A000 ; 256 4bpp 16x16 tiles (may also be used as sprite frames)
VRAM_TILES1    = $12000 ; 768 4bpp 8x8 tiles
VRAM_SPRITES   = $18000 ; 243 4bpp 16x16 frames
; $1F9C0+ reserved


; sprite indices
PLAYER_idx     = 1

TICK_MOVEMENT  = 1

DIR_RIGHT   = 0
DIR_LEFT    = 1
DIR_DOWN    = 2
DIR_UP      = 3

NO_FLIP     = $00
H_FLIP      = $01
V_FLIP      = $02
HV_FLIP     = $03

GAME_MUSIC_BANK   = 1

OPM_DELAY_REG   = 2
OPM_DONE_REG    = 4


; --------- Global Variables ---------

frame_num:        .byte 0

.endif
