.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
	jmp	start

.include "irq.inc"
.include "vsync.inc"
.include "game.inc"
.include "globals.inc"
.include "sound.inc"
.include "x16.inc"

testfile:	.byte "soundtst.bin"
FILE_LENGTH	= 12

start:
	jsr	init_irq
	stz	ROM_BANK
	lda	#$01
	ldx	#$08
	ldy	#$00
	jsr	SETLFS
	lda	#FILE_LENGTH
	ldx	#<testfile
	ldy	#>testfile
	jsr	SETNAM
	lda	#$03	;replace later with sound_bank
	sta	sound_bank	;will go away
	sta	RAM_BANK
	lda	#$00
	ldx	#<RAM_WIN
	ldy	#>RAM_WIN
	jsr	LOAD
test:
	jsr	init_sound
	lda	#$00
	jsr	request_cue
mainloop:
	wai
	jsr	check_vsync
	bra	mainloop

	
	
	
	
	