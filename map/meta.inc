.ifndef META_INC
META_INC = 1

.import tile_meta, get_tile_meta

; tile_meta + 0

TM_DAMAGE   = $80
TM_LADDER   = $40
TM_WADE     = $20
TM_ZCHANGE  = $10
TM_Z2       = $08
TM_Z3       = $04
TM_STAIRS_L = $02
TM_STAIRS_R = $01

; tile_meta + 1

TM_AUTOTRIG = $80
TM_SLOW     = $40
TM_BATTLE   = $20
TM_NPC      = $10
TM_P_BOTTOM = $08
TM_P_TOP    = $04
TM_P_LEFT   = $02
TM_P_RIGHT  = $01

.endif
