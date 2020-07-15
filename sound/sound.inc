.ifndef SOUND_INC
SOUND_INC = 1

; Function: init_sound
; Input: none
; Output: undefined - may change register values
; Behavior: Initializes the sound module, making it ready to handle the
;           first call to sound_tick.
.import init_sound

; Function: request_cue
; Input: A - Index of sound cue
; Output: undefined - may change register values
; Behavior: Requests a sound effect cue by placing it on the queue. If queue
;           is full, request is ignored. Cue will be played once it reaches
;           the head of the queue and channels are available to play it.
;           Any cue requested needs to be available in the RAM bank referenced
;           by the current value of sound_bank (imported with globals.inc).
.import request_cue

; Function: sound_tick
; Input: none
; Output: undefined - may change register values
; Behavior: Tick handler for sound module. Will be called 60 times a second
;           after each VSYNC interrupt. Processes scheduled changes to
;           currently playing sound effects and pulls new cues from the
;           queue when channels are available to play it.
;           Any cues currently playing need to be available in the RAM bank
;           referenced by the current value of sound_bank (imported with
;           globals.inc).
.import sound_tick

.endif
