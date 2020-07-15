.ifndef GLOBALS_INC
GLOBALS_INC = 1

; ---------- Build Options ----------

; ------------ Constants ------------

; zero page pointers
MUSIC_PTR      = $28

; VRAM map for map engine
MAP_VRAM_TILEMAP0  = $00000 ; 64x64 tilemap (map background)
MAP_VRAM_TILEMAP1  = $02000 ; 128x128 tilemap (map foreground/GUI)
MAP_VRAM_TILES0    = $0A000 ; 256 4bpp 16x16 tiles (may also be used as sprite frames)
MAP_VRAM_TILES1    = $12000 ; 768 4bpp 8x8 tiles
MAP_VRAM_SPRITES   = $18000 ; 243 4bpp 16x16 frames
; $1F9C0+ reserved

; VRAM map for battle engine
BATTLE_VRAM_BITMAP   = $00000 ; 320x240 8bpp bitmap (battle area background)
BATTLE_VRAM_TILEMAP  = $12C00 ; 64x32 tilemap (battle GUI)
BATTLE_VRAM_TILES    = $13C00 ; 512 4bpp 8x8 tiles
BATTLE_VRAM_SPRITES  = $17C00 ; sprites of various sizes
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

; RAM Banks
MAP_MUSIC_BANK    = 1
MAP_SOUND_BANK    = 3
MAP_TILEMAP0_BANK = 5
MAP_TILEMAP1_BANK = 6
MAP_TILES0_BANK   = 10
MAP_TILES1_BANK   = 14
MAP_SPRITES_BANK  = 17
MAP_CONFIG_BANK   = 21
MAP_META_BANK     = 22
MAP_SCRIPTS_BANK  = 23

BATTLE_MUSIC_BANK    = 25
BATTLE_SOUND_BANK    = 27
BATTLE_BITMAP_BANK   = 29
BATTLE_TILEMAP_BANK  = 36
BATTLE_TILES_BANK    = 37
BATTLE_SPRITES_BANK  = 39
BATTLE_CONFIG_BANK   = 43

; Map Configuration
MAPCFG_PALETTE    = 0


; --------- Global Variables ---------

.import frame_num    ; Current frame number (0-59)
.import music_bank   ; Current starting music bank (1-63)
.import sound_bank   ; Current starting sound bank (1-63)
.import map_id       ; Current map ID (0-65535)

.endif
