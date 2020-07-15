.include "globals.inc"
.include "x16.inc"

queue_status:	.byte $01
queue_front_pos:	.byte $00
queue_back_pos:	.byte $00
cue_id:		.byte $00
new_sfx_pos:	.byte $00
min:		.byte $00
min_idx:	.byte $00
ptr_store1:	.byte $00
sfx_queue:	.res 4,$00
active_sfx:	.res 8,$00
remaining_events:	.res 4,$00
cur_data:	.res 64, $00
cur_delay:	.res 16, $00
cur_duration:	.res 16, $00
next_data:	.res 16, $00
next_delay:	.res 4, $00
next_duration:	.res 4, $00

.export	init_sound, request_cue, sound_tick

init_sound:
	lda	#$01
	sta	queue_status
	stz	queue_front_pos
	stz	queue_back_pos
	stz	active_sfx
	stz	active_sfx+1
	stz	active_sfx+2
	stz	active_sfx+3
	stz	active_sfx+4
	stz	active_sfx+5
	stz	active_sfx+6
	stz	active_sfx+7
	rts



request_cue:
	sta	cue_id
	lda	queue_status
	and	#$02
	bne	@end
	lda	queue_status
	and	#$FE
	sta	queue_status
	ldx	queue_back_pos
	lda	cue_id
	sta	sfx_queue,X
	lda	queue_back_pos
	inc
	and	#$03
	sta	queue_back_pos
	cmp	queue_front_pos
	bne	@end
	lda	queue_status
	ora	#$02
	sta	queue_status
@end:
	rts

sound_tick:
	stz	VERA_ctrl
	lda	#$11
	sta	VERA_addr_bank
	lda	sound_bank
	sta	RAM_BANK
	lda	queue_status
	and	#$FD
	sta	queue_status
	ldx	#$00
@loop1:
	and	#$01
	bne	@loop2
	lda	active_sfx,X
	bne	@endif1
	lda	active_sfx+4,X
	bne	@endif1
	stx	new_sfx_pos
	jsr	load_sfx
	ldx	new_sfx_pos
@endif1:
	inx
	cpx	#$04
	bcs	@loop2
	lda	queue_status
	bra	@loop1
@loop2:
	lda	queue_status
	and	#$01
	bne	@loop2e
	lda	remaining_events
	sta	min
	stz	min_idx
	ldx	#$01
@loop3:
	lda	remaining_events,X
	cmp	min
	bcc	@endif2
	sta	min
	stx	min_idx
@endif2:
	inx
	cpx	#$04
	bcc	@loop3
@loop3e:
	lda	min_idx
	sta	new_sfx_pos
	jsr	load_sfx
	bra	@loop2
@loop2e:
	ldx	#$00
@loop4:
	lda	active_sfx,X
	beq	@loop6e_jmp
	lda	active_sfx+4,X
	beq	@loop6e_jmp
	bra	@loop6e_jmp_e
@loop6e_jmp:
	jmp	@loop6e
@loop6e_jmp_e:
	txa
	tay
@loop5:
	lda	cur_duration,Y
	dec
	bne	@loop6e_jmp
	lda	#>VRAM_psg
	sta	VERA_addr_high
	tya
	asl
	asl
	sta	ptr_store1
	lda	#<VRAM_psg
	clc
	adc	ptr_store1
	sta	VERA_addr_low
	stz	VERA_data0
	stz	VERA_data0
	stz	VERA_data0
	stz	VERA_data0
	lda	remaining_events,X
	bne	@loop6e_jmp
	stz	active_sfx,X
	stz	active_sfx+4,X
@endif4:
	tya
	clc
	adc	#$04
	tay
	cpy	#$10
	bmi	@loop5
@loop5e:
	lda	next_delay,X
	dec
	sta	next_delay,X
@loop6:
	lda	next_delay,X
	bne	@loop6e_jmp
	lda	remaining_events,X
	beq	@loop6e_jmp
	bmi	@loop6e_jmp	;precautionary measure
	txa
	tay
@loop7:
	lda	cur_duration,Y
	beq	@loop7e
	bmi	@loop7e
	tya
	clc
	adc	#$04
	tay
	cpy	#$10
	bmi	@loop7
@loop7e:
	lda	next_duration,X
	sta	cur_duration,Y
	lda	next_duration+1,X
	sta	cur_duration+1,Y
	lda	next_duration+2,X
	sta	cur_duration+2,Y
	lda	next_duration+3,X
	sta	cur_duration+3,Y
	lda	#>VRAM_psg
	sta	VERA_addr_high
	tya
	asl
	asl
	sta	ptr_store1
	lda	#<VRAM_psg
	clc
	adc	ptr_store1
	sta	VERA_addr_low
	lda	next_data,X
	sta	cur_data,Y
	sta	VERA_data0
	lda	next_data+4,X
	sta	cur_data+16,Y
	sta	VERA_data0
	lda	next_data+8,X
	sta	cur_data+32,Y
	sta	VERA_data0
	lda	next_data+12,X
	sta	cur_data+48,Y
	sta	VERA_data0
	lda	remaining_events,X
	dec
	sta	remaining_events,X
	beq	@endif5
	bmi	@endif5
	lda	active_sfx,X
	sta	ZP_PTR_1
	clc
	adc	#$06
	sta	active_sfx,X
	lda	active_sfx+4,X
	sta	ZP_PTR_1+1
	adc	#$00
	sta	active_sfx+4,X
	ldy	#$00
	lda	(ZP_PTR_1),Y
	sta	next_data,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+4,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+8,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+12,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_delay,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_duration,X
	iny
@endif5:
	jmp	@loop6
@loop6e:
	inx
	cpx	#$04
	bmi	@loop4_jmp
	bra	@loop4e
@loop4_jmp:
	jmp	@loop4
@loop4e:
	rts

load_sfx:
	ldy	queue_front_pos
	lda	sfx_queue,Y
	asl
	tay
	ldx	new_sfx_pos
	lda	RAM_BANK,Y
	sta	active_sfx,X
	sta	ZP_PTR_1
	lda	RAM_BANK+1,Y
	sta	active_sfx+4,X
	sta	ZP_PTR_1
	ldy	#$00
	lda	(ZP_PTR_1),Y
	sta	remaining_events,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+4,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+8,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+12,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_delay,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_delay,X
	clc
	lda	active_sfx,X
	adc	#$07
	sta	active_sfx,X
	lda	active_sfx+4,X
	adc	#$00
	sta	active_sfx+4,X
	ldy	#$00
@loop1:
	lda	remaining_events,X
	beq	@loop1e_jmp
	bmi	@loop1e_jmp
	bra	@loop1e_jmp_e
@loop1e_jmp:
	jmp	@loop1e
@loop1e_jmp_e:	
	lda	next_delay,X
	bne	@loop1e_jmp
	sta	cur_delay,Y
	lda	next_duration,X
	sta	cur_duration,Y
	lda	#>VRAM_psg
	sta	VERA_addr_high
	tya
	asl
	asl
	sta	ptr_store1
	lda	#<VRAM_psg
	clc
	adc	ptr_store1
	sta	VERA_addr_low
	lda	next_data,X
	sta	cur_data,Y
	sta	VERA_data0
	lda	next_data+4,X
	sta	cur_data+16,Y
	sta	VERA_data0
	lda	next_data+8,X
	sta	cur_data+32,Y
	sta	VERA_data0
	lda	next_data+12,X
	sta	cur_data+48,Y
	sta	VERA_data0
	tya
	inc
	and	#$03	;safety measure	against bad channel management
	tay
	lda	remaining_events,X
	dec
	sta	remaining_events,X
	beq	@endif1
	bmi	@endif1
	lda	active_sfx,X
	sta	ZP_PTR_1
	clc
	adc	#$06
	sta	active_sfx,X
	lda	active_sfx+4,X
	sta	ZP_PTR_1+1
	adc	#$00
	sta	active_sfx+4,X
	sty	ptr_store1
	ldy	#$00
	lda	(ZP_PTR_1),Y
	sta	next_data,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+4,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+8,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_data+12,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_delay,X
	iny
	lda	(ZP_PTR_1),Y
	sta	next_duration,X
	ldy	ptr_store1
@endif1:
	iny
	jmp	@loop1
@loop1e:
	lda	queue_front_pos
	inc
	and	#$03
	sta	queue_front_pos
	cmp	queue_back_pos
	bne	@endif2
	lda	queue_status
	ora	#$01
	sta	queue_status
@endif2:
	rts
