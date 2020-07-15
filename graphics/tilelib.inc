.ifndef TILELIB_INC
TILELIB_INC = 1

.import xy2vaddr  ; Input:
                  ;  A: layer
                  ;  X: tile display x position
                  ;  Y: tile display y position
                  ; Output:
                  ;  A: VRAM bank
                  ;  X/Y: VRAM addr

.import pix2tilexy   ; Input:
                     ; A: bit 4: layer; bits 3,2: x (9:8), bits 1,0: y (9:8)
                     ; X: display x (7:0)
                     ; Y: display y (7:0)
                     ; Output:
                     ; A: bits 7-4: TILEW/2, bits 3-0: TILEH/2
                     ; X: tile x
                     ; Y: tile y

.import get_tile  ; Input:
                  ; A: layer
                  ; X: tile display x position
                  ; Y: tile display y position
                  ; Output:
                  ; A: layer
                  ; X: tile entry 0
                  ; Y: tile entry 1

.endif
