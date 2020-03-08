	.thumb
	.syntax unified
.text

//function for a TOOM-COOK in assembly
//*************************************************
// toom_cook_4way_mem_asm(&a1, &b1, &result);
//*************************************************
.global toom_cook_4way_mem_asm
.func toom_cook_4way_mem_asm, toom_cook_4way_mem_asm
.type toom_cook_4way_mem_asm, %function
toom_cook_4way_mem_asm:
	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	subw	sp, sp, #3076
	mov 	r3, sp
	mov 	r11, r2
	add 	r2, r3, #1792
//r0=&a1[i] r1=b1 r2=&w_m[896+i]
//loop1
	add 	r12, r0, #128
toom_cook_4way_mem_asm_loop1:
	ldr 	r6, [r0, #384]
	ldr 	r4, [r0, #128]
	ldr 	r5, [r0, #256]
	ldr 	r3, [r0], #4
	cmp 	r0, r12
	uadd16 	r8, r4, r6
	uadd16 	r7, r3, r5
	uadd16 	r9, r7, r8
	usub16 	r10, r7, r8
	str 	r9, [r2, #128]
	str 	r10, [r2, #256]
	uadd16 	r7, r3, r3
	uadd16	r7, r7, r7
	uadd16	r7, r7, r5
	uadd16 	r7, r7, r7
	uadd16 	r8, r4, r4
	uadd16 	r8, r8, r8
	uadd16 	r8, r8, r6
	uadd16 	r9, r7, r8
	usub16 	r10, r7, r8
	str 	r9, [r2, #384]
	str 	r10, [r2, #512]
	uadd16 	r7, r6, r6
	uadd16 	r7, r7, r5
	uadd16 	r7, r7, r7
	uadd16 	r7, r7, r4
	uadd16 	r7, r7, r7
	uadd16 	r7, r7 ,r3
	str 	r7, [r2], #4
	bne 	toom_cook_4way_mem_asm_loop1
//loop2
	add 	r12, r1, #128
	add 	r2, r2, #512
toom_cook_4way_mem_asm_loop2:
	ldr 	r6, [r1, #384]
	ldr 	r4, [r1, #128]
	ldr 	r5, [r1, #256]
	ldr 	r3, [r1], #4
	cmp 	r1, r12
	uadd16 	r8, r4, r6
	uadd16 	r7, r3, r5
	uadd16 	r9, r7, r8
	usub16 	r10, r7, r8
	str 	r9, [r2, #128]
	str 	r10, [r2, #256]
	uadd16 	r7, r3, r3
	uadd16	r7, r7, r7
	uadd16	r7, r7, r5
	uadd16 	r7, r7, r7
	uadd16 	r8, r4, r4
	uadd16 	r8, r8, r8
	uadd16 	r8, r8, r6
	uadd16 	r9, r7, r8
	usub16 	r10, r7, r8
	str 	r9, [r2, #384]
	str 	r10, [r2, #512]
	uadd16 	r7, r6, r6
	uadd16 	r7, r7, r5
	uadd16 	r7, r7, r7
	uadd16 	r7, r7, r4
	uadd16 	r7, r7, r7
	uadd16 	r7, r7 ,r3
	str 	r7, [r2], #4
	bne 	toom_cook_4way_mem_asm_loop2
//r0=&a1[i+64] r1=&b1[i+64] r2=&w_m[896+320+64+i] r3-r10 r12
	mov 	r9, r11
	mov 	r11, r0
	mov 	r12, r1
	sub 	r0, r2, #2560
	mov 	r1, #0
	mov 	r2, #1792
	bl 		memset
	mov 	r10, r0
	sub 	r0, r11, #128
	sub 	r1, r12, #128
	add		r2, r10, #1536
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r10, #2304
	add 	r1, r10, #2944
	add 	r2, r10, #1280
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r10, #2176
	add 	r1, r10, #2816
	add 	r2, r10, #1024
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r10, #2048
	add 	r1, r10, #2688
	add 	r2, r10, #768
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r10, #1920
	add 	r1, r10, #2560
	add 	r2, r10, #512
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r10, #1792
	add 	r1, r10, #2432
	add 	r2, r10, #256
	mov 	r3, #32
	bl 		unrolled_kara_mem
	add 	r0, r11, #256
	add 	r1, r12, #256
	mov 	r2, r10
	mov 	r3, #32
	bl 		unrolled_kara_mem
//r0=i r9=result r10=w_m
//loop3
	movw	r14, #0x1fff
	mov 	r0, #0
	mov 	r11, #128
	add 	r14, r14, r14, lsl #16
toom_cook_4way_mem_asm_loop3:
	ldr 	r5, [r10, #1024]
	ldr 	r3, [r10, #512]
	ldr 	r2, [r10, #256]
	ldr 	r7, [r10, #1536]
	ldr 	r6, [r10, #1280]
	ldr 	r4, [r10, #768]
	ldr 	r1, [r10], #4
	uadd16	r2, r2, r5
	usub16	r6, r6, r5
	usub16	r4, r4, r3
	usub16	r5, r5, r1
	lsr 	r11, r7, #16
	lsl		r12, r7, #6
	pkhbt	r8, r12, r11, lsl #22
	usub16	r5, r5, r8
	lsl		r11, r4, #16
	lsr	 	r12, r4, #1
	pkhtb 	r4, r12, r11, asr #17
	uadd16	r3, r3, r4
	lsr 	r11, r5, #16
	lsl		r12, r5, #1
	pkhbt	r8, r12, r11, lsl #17
	uadd16	r5, r6, r8
	lsr 	r11, r3, #16
	lsl		r12, r3, #6
	pkhbt	r8, r12, r11, lsl #22
	uadd16	r8, r3, r8
	usub16	r2, r2, r8
	usub16	r3, r3, r7
	usub16 	r3, r3, r1
	mov 	r8, #45
	smulbb 	r11, r3, r8
	smultb 	r12, r3, r8
	pkhbt 	r8, r11, r12, lsl #16
	uadd16	r2, r2, r8
	lsr 	r11, r3, #16
	lsl		r12, r3, #3
	pkhbt	r8, r12, r11, lsl #19
	usub16	r5, r5, r8
	movw 	r8, #43691
	smulbb 	r11, r5, r8
	smultb 	r12, r5, r8
	pkhbt 	r8, r11, r12, lsl #16
	lsl		r11, r8, #16
	lsr	 	r12, r8, #3
	pkhtb 	r5, r12, r11, asr #19
	uadd16 	r6, r2, r6
	lsr 	r11, r4, #16
	lsl		r12, r4, #4
	pkhbt	r8, r12, r11, lsl #20
	uadd16	r2, r2, r8
	movw 	r8, #36409
	smulbb 	r11, r2, r8
	smultb 	r12, r2, r8
	pkhbt 	r8, r11, r12, lsl #16
	lsl		r11, r8, #16
	lsr	 	r12, r8, #1
	pkhtb 	r2, r12, r11, asr #17
	usub16	r3, r3, r5
	uadd16	r4, r4, r2
	mov		r8, #0
	usub16	r4, r8, r4
	mov 	r8, #30
	smulbb 	r11, r2, r8
	smultb 	r12, r2, r8
	pkhbt 	r8, r11, r12, lsl #16
	usub16	r6, r8, r6
	movw 	r8, #61167
	smulbb 	r11, r6, r8
	smultb 	r12, r6, r8
	pkhbt 	r8, r11, r12, lsl #16
	lsl		r11, r8, #16
	lsr	 	r12, r8, #1
	pkhtb 	r6, r12, r11, asr #17
//r0=i r9=result r10=w_m
	usub16	r7, r7, r3
	usub16	r6, r6, r2
	usub16	r5, r5, r1
	ldr 	r3, [r9]
	ldr 	r2, [r9, #128]
	ldr 	r1, [r9, #256]
	uadd16	r7, r7, r3
	uadd16	r6, r6, r2
	uadd16	r5, r5, r1
	#ubfx	r7, r7, #0, #13
	#ubfx	r6, r6, #0, #13
	#ubfx	r5, r5, #0, #13
	and		r7, r7, r14
	and		r6, r6, r14
	and 	r5, r5, r14
	cmp 	r0, #63
	add		r0, r0, #2
	sub 	r1, r9, #128
	it 		ls
	addls	r1, r1, #512
	ldr 	r8, [r1]
	str 	r5, [r9, #256]
	str 	r6, [r9, #128]
	str 	r7, [r9], #4
	usub16	r3, r8, r4
	it 		ls
	uadd16ls r3, r8, r4
	cmp 	r0, #126
	#ubfx 	r3, r3, #0, #13
	and 	r3, r3, r14
	str 	r3, [r1]
	bne		toom_cook_4way_mem_asm_loop3
//for(i=0;i<2*(SABER_N/4)-1;i++){ last iteration only halfword!!!
	ldrh 	r5, [r10, #1024]
	ldrh 	r3, [r10, #512]
	ldrh 	r2, [r10, #256]
	ldrh 	r7, [r10, #1536]
	ldrh 	r6, [r10, #1280]
	ldrh 	r4, [r10, #768]
	ldrh 	r1, [r10], #4
	uadd16	r2, r2, r5
	usub16	r6, r6, r5
	usub16	r4, r4, r3
	usub16	r5, r5, r1
	lsl 	r8, r7, #6
	usub16	r5, r5, r8
	lsr		r4, r4, #1
	uadd16	r3, r3, r4
	lsl		r8, r5, #1
	uadd16	r5, r6, r8
	lsl		r8, r3, #6
	uadd16	r8, r3, r8
	usub16	r2, r2, r8
	usub16	r3, r3, r7
	usub16 	r3, r3, r1
	mov 	r8, #45
	smulbb 	r8, r3, r8
	uadd16	r2, r2, r8
	lsl		r8, r3, #3
	usub16	r5, r5, r8
	movw 	r8, #43691
	smulbb 	r8, r5, r8
	lsr		r5, r8, #3
	uadd16 	r6, r2, r6
	lsl		r8, r4, #4
	uadd16	r2, r2, r8
	movw 	r8, #36409
	smulbb 	r8, r2, r8
	lsr 	r2, r8, #1
	usub16	r3, r3, r5
	uadd16	r4, r4, r2
	mov		r8, #0
	usub16	r4, r8, r4
	mov 	r8, #30
	smulbb 	r8, r2, r8
	usub16	r6, r8, r6
	movw 	r8, #61167
	smulbb 	r8, r6, r8
	lsr		r6, r8, #1
//r0=i r9=result r10=w_m
	usub16	r7, r7, r3
	usub16	r6, r6, r2
	usub16	r5, r5, r1
	ldrh 	r3, [r9]
	ldrh 	r2, [r9, #128]
	ldrh 	r1, [r9, #256]
	uadd16	r7, r7, r3
	uadd16	r6, r6, r2
	uadd16	r5, r5, r1
	ubfx	r7, r7, #0, #13
	ubfx	r6, r6, #0, #13
	ubfx	r5, r5, #0, #13
	cmp 	r0, #63
	add		r0, r0, #2
	sub 	r1, r9, #128
	it 		ls
	addls	r1, r1, #512
	ldr 	r8, [r1]
	strh 	r5, [r9, #256]
	strh 	r6, [r9, #128]
	strh 	r7, [r9], #4
	usub16	r3, r8, r4
	it 		ls
	uadd16ls r3, r8, r4
	cmp 	r0, #126
	ubfx 	r3, r3, #0, #13
	strh 	r3, [r1]
exit_toom_cook_4way_mem_asm:
	addw	sp, sp, #3076
	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
	bx	lr
	nop
.endfunc

//*********************
//* SCHOOLBOOK ON ASM *
//*********************
.global school_book_mul2_16_fast_mem
.func school_book_mul2_16_fast_mem, school_book_mul2_16_fast_mem
.type school_book_mul2_16_fast_mem, %function
.align 2
school_book_mul2_16_fast_mem:
	stmdb	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	ldr.w r6, [r1, #0]
	ldr.w ip, [r1, #4]
	ldr.w r3, [r1, #8]
	ldr.w sl, [r1, #12]
	ldrh.w r9, [r2]
	ldrh.w fp, [r2, #2]
	ldr.w r7, [r0, #0]
	ldr.w r8, [r0, #4]
	ldr.w r4, [r0, #8]
	ldr.w lr, [r0, #12]
	smlabb r9, r7, r6, r9
	smladx fp, r7, r6, fp
	pkhbt r9, r9, fp, lsl #16
	ldrh.w fp, [r2, #6]
	ldrh.w r5, [r2, #4]
	str.w r9, [r2]
	smladx fp, r7, ip, fp
	smlabb r5, r7, ip, r5
	pkhbt r9, r8, r7
	smladx fp, r8, r6, fp
	smlad r5, r9, r6, r5
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #4]
	ldrh.w r5, [r2, #8]
	ldrh.w fp, [r2, #10]
	smlabb r5, r3, r7, r5
	smladx fp, r3, r7, fp
	smlad r5, r9, ip, r5
	pkhbt r9, r4, r8
	smlad r5, r9, r6, r5
	smladx fp, r8, ip, fp
	smladx fp, r4, r6, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #8]
	ldrh.w r5, [r2, #12]
	ldrh.w fp, [r2, #14]
	smlabb r5, sl, r7, r5
	smladx fp, sl, r7, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, r3, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r6, r9, r5
	smladx fp, r3, r8, fp
	smladx fp, ip, r4, fp
	smladx fp, r6, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #12]
	ldrh.w r5, [r2, #16]
	ldrh.w fp, [r2, #18]
	smlatt r5, r6, lr, r5
	smladx fp, sl, r8, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, sl, r9, r5
	pkhbt r9, r4, r8
	smlad r5, r3, r9, r5
	smladx fp, r3, r4, fp
	smladx fp, ip, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #16]
	ldrh.w r5, [r2, #20]
	ldrh.w fp, [r2, #22]
	smlatt r5, ip, lr, r5
	smladx fp, sl, r4, fp
	smlad r5, sl, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r3, r9, r5
	smladx fp, r3, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #20]
	ldrh.w r5, [r2, #24]
	ldrh.w fp, [r2, #26]
	smlad r5, sl, r9, r5
	smladx fp, sl, lr, fp
	smlatt r5, r3, lr, r5
	pkhbt fp, r5, fp, lsl #16
	ldr.w r9, [r2, #28]
	str.w fp, [r2, #24]
	smlatt fp, sl, lr, r9
	pkhbt fp, fp, r9
	str.w fp, [r2, #28]
	ldr.w r7, [r0, #16]
	ldr.w r8, [r0, #20]
	ldr.w r4, [r0, #24]
	ldr.w lr, [r0, #28]
	ldr.w r9, [r2, #16]
	ldr.w r5, [r2, #20]
	mov.w fp, r9, lsr #16
	smlabb r9, r7, r6, r9
	smladx fp, r7, r6, fp
	pkhbt r9, r9, fp, lsl #16
	str.w r9, [r2, #16]
	mov.w fp, r5, lsr #16
	smladx fp, r7, ip, fp
	smlabb r5, r7, ip, r5
	pkhbt r9, r8, r7
	smladx fp, r8, r6, fp
	smlad r5, r9, r6, r5
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #24]
	str.w fp, [r2, #20]
	mov.w fp, r5, lsr #16
	smlabb r5, r3, r7, r5
	smladx fp, r3, r7, fp
	smlad r5, r9, ip, r5
	pkhbt r9, r4, r8
	smlad r5, r9, r6, r5
	smladx fp, r8, ip, fp
	smladx fp, r4, r6, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #28]
	str.w fp, [r2, #24]
	mov.w fp, r5, lsr #16
	smlabb r5, sl, r7, r5
	smladx fp, sl, r7, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, r3, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r6, r9, r5
	smladx fp, r3, r8, fp
	smladx fp, ip, r4, fp
	smladx fp, r6, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #28]
	ldrh.w r5, [r2, #32]
	ldrh.w fp, [r2, #34]
	smlatt r5, r6, lr, r5
	smladx fp, sl, r8, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, sl, r9, r5
	pkhbt r9, r4, r8
	smlad r5, r3, r9, r5
	smladx fp, r3, r4, fp
	smladx fp, ip, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #32]
	ldrh.w r5, [r2, #36]
	ldrh.w fp, [r2, #38]
	smlatt r5, ip, lr, r5
	smladx fp, sl, r4, fp
	smlad r5, sl, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r3, r9, r5
	smladx fp, r3, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #36]
	ldrh.w r5, [r2, #40]
	ldrh.w fp, [r2, #42]
	smlad r5, sl, r9, r5
	smladx fp, sl, lr, fp
	smlatt r5, r3, lr, r5
	pkhbt fp, r5, fp, lsl #16
	ldr.w r9, [r2, #44]
	str.w fp, [r2, #40]
	smlatt fp, sl, lr, r9
	pkhbt fp, fp, r9
	str.w fp, [r2, #44]
	ldr.w r6, [r1, #16]
	ldr.w ip, [r1, #20]
	ldr.w r3, [r1, #24]
	ldr.w sl, [r1, #28]
	ldr.w r9, [r2, #32]
	ldr.w r5, [r2, #36]
	mov.w fp, r9, lsr #16
	smlabb r9, r7, r6, r9
	smladx fp, r7, r6, fp
	pkhbt r9, r9, fp, lsl #16
	str.w r9, [r2, #32]
	mov.w fp, r5, lsr #16
	smladx fp, r7, ip, fp
	smlabb r5, r7, ip, r5
	pkhbt r9, r8, r7
	smladx fp, r8, r6, fp
	smlad r5, r9, r6, r5
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #40]
	str.w fp, [r2, #36]
	mov.w fp, r5, lsr #16
	smlabb r5, r3, r7, r5
	smladx fp, r3, r7, fp
	smlad r5, r9, ip, r5
	pkhbt r9, r4, r8
	smlad r5, r9, r6, r5
	smladx fp, r8, ip, fp
	smladx fp, r4, r6, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #44]
	str.w fp, [r2, #40]
	mov.w fp, r5, lsr #16
	smlabb r5, sl, r7, r5
	smladx fp, sl, r7, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, r3, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r6, r9, r5
	smladx fp, r3, r8, fp
	smladx fp, ip, r4, fp
	smladx fp, r6, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #44]
	ldrh.w r5, [r2, #48]
	ldrh.w fp, [r2, #50]
	smlatt r5, r6, lr, r5
	smladx fp, sl, r8, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, sl, r9, r5
	pkhbt r9, r4, r8
	smlad r5, r3, r9, r5
	smladx fp, r3, r4, fp
	smladx fp, ip, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #48]
	ldrh.w r5, [r2, #52]
	ldrh.w fp, [r2, #54]
	smlatt r5, ip, lr, r5
	smladx fp, sl, r4, fp
	smlad r5, sl, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r3, r9, r5
	smladx fp, r3, lr, fp
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #52]
	ldrh.w r5, [r2, #56]
	ldrh.w fp, [r2, #58]
	smlad r5, sl, r9, r5
	smladx fp, sl, lr, fp
	smlatt r5, r3, lr, r5
	ldrh.w r9, [r2, #60]
	pkhbt fp, r5, fp, lsl #16
	str.w fp, [r2, #56]
	smlatt fp, sl, lr, r9
	strh.w fp, [r2, #60]
	ldr.w r7, [r0, #0]
	ldr.w r8, [r0, #4]
	ldr.w r4, [r0, #8]
	ldr.w lr, [r0, #12]
	ldr.w r9, [r2, #16]
	ldr.w r5, [r2, #20]
	mov.w fp, r9, lsr #16
	smlabb r9, r7, r6, r9
	smladx fp, r7, r6, fp
	pkhbt r9, r9, fp, lsl #16
	str.w r9, [r2, #16]
	mov.w fp, r5, lsr #16
	smladx fp, r7, ip, fp
	smlabb r5, r7, ip, r5
	pkhbt r9, r8, r7
	smladx fp, r8, r6, fp
	smlad r5, r9, r6, r5
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #24]
	str.w fp, [r2, #20]
	mov.w fp, r5, lsr #16
	smlabb r5, r3, r7, r5
	smladx fp, r3, r7, fp
	smlad r5, r9, ip, r5
	pkhbt r9, r4, r8
	smlad r5, r9, r6, r5
	smladx fp, r8, ip, fp
	smladx fp, r4, r6, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #28]
	str.w fp, [r2, #24]
	mov.w fp, r5, lsr #16
	smlabb r5, sl, r7, r5
	smladx fp, sl, r7, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, r3, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r6, r9, r5
	smladx fp, r3, r8, fp
	smladx fp, ip, r4, fp
	smladx fp, r6, lr, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #32]
	str.w fp, [r2, #28]
	mov.w fp, r5, lsr #16
	smlatt r5, r6, lr, r5
	smladx fp, sl, r8, fp
	smlad r5, ip, r9, r5
	pkhbt r9, r8, r7
	smlad r5, sl, r9, r5
	pkhbt r9, r4, r8
	smlad r5, r3, r9, r5
	smladx fp, r3, r4, fp
	smladx fp, ip, lr, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #36]
	str.w fp, [r2, #32]
	mov.w fp, r5, lsr #16
	smlatt r5, ip, lr, r5
	smladx fp, sl, r4, fp
	smlad r5, sl, r9, r5
	pkhbt r9, lr, r4
	smlad r5, r3, r9, r5
	smladx fp, r3, lr, fp
	pkhbt fp, r5, fp, lsl #16
	ldr.w r5, [r2, #40]
	str.w fp, [r2, #36]
	mov.w fp, r5, lsr #16
	smlad r5, sl, r9, r5
	smladx fp, sl, lr, fp
	smlatt r5, r3, lr, r5
	pkhbt fp, r5, fp, lsl #16
	ldrh.w r5, [r2, #44]
	str.w fp, [r2, #40]
	smlatt fp, sl, lr, r5
	strh.w fp, [r2, #44]
	ldmia.w	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
.endfunc

//*************************************************
// unrolled_kara_mem(uint16_t* a, uint16_t* c, uint16_t* d, uint16_t k)
//*************************************************
.global unrolled_kara_mem
.func unrolled_kara_mem, unrolled_kara_mem
.type unrolled_kara_mem, %function
unrolled_kara_mem:
	stmdb	sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	mov		r9, r3, lsr #1
	mov		r11, r0
	mov		r12, r1
	add		r3, r3, r9
	ldr		r0, =kara_tmp_asm
	add		r1, r2, r3, lsl #2
	mov		r4, #0
	sub		r1, r1, #2
// r11=a r12=c
	mov		r10, #0
//r0=kara_tmp r1=&d[3k-1] r2=d r3=k+k/2 r4=i r9=k/2
unrolled_kara_mem_loop1:
	ldr 	r5, [r2, r9, lsl #2]
	ldr 	r6, [r2]
	ldr 	r7, [r2, r3, lsl #1]
	ldr 	r8, [r2, r9, lsl #1]
	add		r4, r4, #2
	uadd16	r5, r5, r6
	uadd16	r7, r7, r8
	str		r10, [r2, r9, lsl #3]
	uadd16	r7, r7, r5
	str		r5, [r2, r9, lsl #2]
	str		r7, [r2, r3, lsl #1]
	ldr		r8, [r11, r3, lsl #1]
	ldr		r7, [r11, r9, lsl #1]
	ldr		r6, [r11, r9, lsl #2]
	ldr		r5, [r11], #4
	uadd16	r7, r7, r8
	uadd16	r5, r5, r6
	str		r7, [r1, r9, lsl #1]
	uadd16	r7, r5, r7
	str		r5, [r1], #4
	str		r7, [r0], #4
	cmp		r4, r9
	add		r2, r2, #4
	bne		unrolled_kara_mem_loop1
	sub		r1, r1, r9, lsl #2
	sub		r0, r0, r9, lsl #1
	add		r2, r2, r9, lsl #2
	sub		r11, r11, r9, lsl #1
	mov		r4, #0
//r0=kara_tmp r1=&d[2k+k/2-1] r2=&d[k+k/2] r3=k+k/2 r4=i
unrolled_kara_mem_loop1_2:
	ldr 	r8, [r12, r3, lsl #1]
	ldr 	r7, [r12, r9, lsl #2]
	ldr 	r6, [r12, r9, lsl #1]
	ldr		r5, [r12], #4
	uadd16 	r7, r7, r8
	uadd16 	r5, r5, r6
	uadd16	r5, r5, r7
	str 	r5, [r1, r4, lsl #1]
	add		r4, r4, #2
	cmp		r4, r9
	bne		unrolled_kara_mem_loop1_2
	mov		r3, r9
	sub		r12, r12, r9, lsl #1
//r0=kara_tmp r1=&d[2k+k/2-1] r2=&d[k+k/2] r3=k/2 r4=i
	bl 		school_book_mul2_16_fast_mem
	mov		r4, #0
unrolled_kara_mem_loop2:
	ldr 	r8, [r2, r3, lsl #1]
	ldr 	r7, [r2]
	ldr 	r6, [r12, r3, lsl #2]
	ldr 	r5, [r12], #4
	add		r4, r4, #2
	uadd16	r7, r7, r8
	uadd16	r5, r5, r6
	str 	r10, [r2], #4
	str 	r7, [r1], #4
	str 	r5, [r0], #4
	cmp		r4, r3
	bne		unrolled_kara_mem_loop2
//undo last iteration for one of the segments
	usub16 	r7, r7, r8
	sub 	r2, r2, r3, lsl #2
	lsr 	r7, r7, #16
	sub 	r0, r0, r3, lsl #1
	strh 	r7, [r1, #-2]
//r0=kara_tmp r1=&d[3k-1] r2=&d[k] r3=k/2 r4=i r11=a r12=&c[k/2]
	bl 		school_book_mul2_16_fast_mem
	sub 	r1, r1, r4, lsl #1
	mov		r3, r9
	mov		r4, #0
//r0=kara_tmp r1=&d[2k+k/2-1] r2=&d[k] r3=k/2 r4=i r11=a r12=&c[k/2]
unrolled_kara_mem_loop3:
	ldr 	r8, [r2]
	ldr 	r7, [r1]
	ldr 	r6, [r2, r3, lsl #1]
	ldr 	r5, [r2, r3, lsl #2]
	usub16	r7, r7, r8
	ldr 	r8, [r12, r3, lsl #2]
	ldr 	r9, [r12], #4
	usub16	r5, r5, r6
	uadd16	r8, r8, r9
	add		r4, r4, #2
	str 	r5, [r2, r3, lsl #2]
	str 	r7, [r2, r3, lsl #1]
	str 	r10, [r1], #4
	str 	r8, [r0], #4
	cmp		r4, r3
	add		r2, r2, #4
	bne		unrolled_kara_mem_loop3
//undo last iteration for one of the segments
//prepare call to subroutine
	uadd16	r5, r5, r6
	add		r2, r2, r3, lsl #1
	lsr		r5, r5, #16
	sub 	r9, r3, #1
	add		r1, r1, r3, lsl #1
	sub 	r0, r0, r3, lsl #1
	strh	r5, [r2, r9, lsl #1]
//r0=kara_tmp r1=&d[3k+k/2-1] r2=&d[2k] r3=k/2 r4=i r11=a r12=&c[k]
	bl 		school_book_mul2_16_fast_mem
	add		r9, r4, r4, lsl #1
	sub 	r1, r1, r4, lsl #2
	sub 	r2, r2, r4, lsl #3
	mov		r4, #0
	sub 	r12, r12, r3, lsl #2
//r0=kara_tmp r1=&d[2k+k/2-1] r2=d r3=k/2 r4=i r9=k+k/2 r11=a r12=c
unrolled_kara_mem_loop4:
	ldr 	r5, [r2]
	ldr 	r6, [r2, r3, lsl #1]
	ldr 	r7, [r2, r3, lsl #3]
	ldr 	r8, [r1, #2]
	uadd16	r5, r5, r6
	str 	r5, [r2, r3, lsl #1]
	usub16	r7, r7, r8
	ldr 	r5, [r2, r3, lsl #2]
	str 	r7, [r2, r3, lsl #3]
	str 	r10, [r2, r3, lsl #2]
	uadd16	r6, r5, r7
	str 	r6, [r1, r3, lsl #1]
	ldr 	r6, [r2, r9, lsl #1]
	add		r4, r4, #2
	add		r2, r2, #4
	usub16	r6, r6, r7
	cmp		r4, r3
	str 	r6, [r1, r3, lsl #2]
	add		r1, r1, #4
	bne 	unrolled_kara_mem_loop4
//undo last iteration for one of the arrays
	sub 	r1, r1, r9, lsl #1
	uadd16	r7, r7, r8
	usub16	r6, r6, r8
	uadd16	r8, r5, r7
	lsr		r5, #16
	strh 	r5, [r1]
	add		r1, r1, r3, lsl #2
	lsr		r7, #16
	strh	r7, [r1]
	add		r1, r1, r3, lsl #2
	lsr 	r8, #16
	strh 	r8, [r1, #-2]!
	add		r1, r1, r3, lsl #1
	lsr		r6, #16
	strh	r6, [r1], #2
	sub 	r1, r1, r9, lsl #2
	mov		r4, #0
	add		r1, r1, r3, lsl #1
//r0=kara_tmp r1=&d[k+k/2-1] r2=&d[k/2] r3=k/2 r4=i r9=k+k/2 r11=a r12=c
unrolled_kara_mem_loop4_2:
	ldr 	r5, [r11, r3, lsl #1]
	ldr 	r6, [r11], #4
	ldr 	r7, [r12, r3, lsl #1]
	ldr 	r8, [r12], #4
	uadd16	r5, r5, r6
	uadd16	r7, r7, r8
	str 	r5, [r1, r4, lsl #1]
	str 	r7, [r0, r4, lsl #1]
	add 	r4, r4, #2
	cmp 	r4, r3
	bne 	unrolled_kara_mem_loop4_2
	sub 	r11, r11, r3, lsl #1
	sub 	r12, r12, r3, lsl #1
	bl 		school_book_mul2_16_fast_mem
	add 	r0, r0, r4, lsl #1
	mov 	r4, #0
//r0=&kara_tmp[k/2] r1=&d[k+k/2-1] r2=&d[k/2] r3=k/2 r4=i r9=k+k/2 r11=a r12=c
unrolled_kara_mem_loop5:
	ldr 	r5, [r2, r3, lsl #1]
	ldr 	r6, [r2]
	str 	r10, [r2], #4
	add 	r4, r4, #2
	uadd16 	r5, r5, r6
	cmp 	r4, r3
	str 	r5, [r1], #4
	bne 	unrolled_kara_mem_loop5
	lsr 	r6, r6, #16
	sub 	r2, r2, r3, lsl #2
	strh 	r6, [r1, #-2]
	sub 	r9, r1, r3, lsl #1
	mov		r0, r11
	mov		r1, r12
//r0=a r1=c r2=d r3=k/2 r4=i r9=&d[k+k/2-1] r11=a r12=c
	bl 		school_book_mul2_16_fast_mem
	add 	r0, r0, r4, lsl #1
	mov 	r3, #0
//r0=&a[k/2] r1=c r2=d r3=i r4=k/2 r9=&d[k+k/2-1] r11=a r12=c
unrolled_kara_mem_loop6:
	ldr 	r5, [r2, r4, lsl #1]
	ldr 	r6, [r2, r4, lsl #2]
	ldr 	r7, [r9]
	ldr 	r8, [r2]
	add 	r3, r3, #2
	usub16	r5, r6, r5
	usub16	r7, r7, r8
	str 	r5, [r2, r4, lsl #2]
	str 	r7, [r2, r4, lsl #1]
	cmp		r3, r4
	add 	r2, r2, #4
	str 	r10, [r9], #4
	bne 	unrolled_kara_mem_loop6
//r0=&a[k/2] r1=c r2=&d[k/2] r3=k/2 r4=k/2 r9=&d[2k-1] r11=a r12=c
//undo last iteration for one of the arrays
	sub 	r9, r9, r3, lsl #1
	add 	r2, r2, r3, lsl #1
	add 	r1, r1, r3, lsl #1
	strh 	r10, [r9]
//r0=&a[k/2] r1=&c[k/2] r2=&d[k] r3=k/2 r4=k/2 r9=&d[k+k/2-1] r11=a r12=c
	bl 		school_book_mul2_16_fast_mem
	add 	r0, r0, r4, lsl #1
	sub 	r2, r2, r4, lsl #2
	add 	r1, r4, r4, lsl #1
	mov 	r3, #0
	add 	r9, r9, r4, lsl #2
// loop7 much optmzd!
//r0=&a[k] r1=k+k/2 r2=d r3=i r4=k/2 r9=&d[2k+k/2-1] r10=0 r12=c
unrolled_kara_mem_loop7:
	ldr 	r5, [r2, r4, lsl #1]
	ldr 	r6, [r2, r4, lsl #2]
	ldr 	r7, [r2, r4, lsl #3]
	ldr 	r11, [r2, r1, lsl #1]
	usub16	r5, r5, r6
	usub16 	r7, r7, r6
	ldr 	r8, [r9, r4, lsl #2]
	ldr 	r6, [r2]
	str 	r5, [r2, r4, lsl #1]
	usub16 	r8, r8, r5
	ldr 	r5, [r9, r4, lsl #1]
	str 	r8, [r2, r1, lsl #1]
	add 	r3, r3, #2
	usub16 	r5, r5, r6
	ldr 	r8, [r9, #2]
	str 	r5, [r2, r4, lsl #2]
	str 	r10, [r9, r4, lsl #1]
	uadd16	r5, r7, r11
	uadd16	r8, r7, r8
	str 	r5, [r2, r4, lsl #3]
	str 	r8, [r9, #2]!
	add 	r2, r2, #4
	cmp 	r4, r3
	add 	r9, r9, #2
	bne 	unrolled_kara_mem_loop7
	lsr 	r7, r7, #16
	add 	r2, r2, r4, lsl #3
	mov 	r3, #0
	strh 	r7, [r2, #-2]
	add 	r1, r9, r4, lsl #1
	mov		r11, r0
	add 	r12, r12, r4, lsl #2
	ldr 	r0, =kara_tmp_asm
//r0=kara_tmp r1=&d[3k+k/2-1] r2=&d[2k+k/2] r3=i r4=k/2 r11=&a[k] r12=&c[k]
unrolled_kara_mem_loop7_2:
	ldr 	r5, [r11, r4, lsl #1]
	ldr 	r6, [r11], #4
	ldr 	r7, [r12, r4, lsl #1]
	ldr 	r8, [r12], #4
	add 	r3, r3, #4
	uadd16	r5, r5, r6
	uadd16	r7, r7, r8
	ldr 	r6, [r11, r4, lsl #1]
	ldr 	r8, [r11], #4
	ldr 	r9, [r12, r4, lsl #1]
	ldr 	r10, [r12], #4
	str 	r5, [r1], #4
	str 	r7, [r0], #4
	uadd16	r6, r6, r8
	uadd16	r9, r9, r10
	cmp 	r3, r4
	str 	r6, [r1], #4
	str 	r9, [r0], #4
	bne 	unrolled_kara_mem_loop7_2
	sub 	r0, r0, r4, lsl #1
	sub 	r1, r1, r4, lsl #1
	mov 	r10, #0
//r0=kara_tmp r1=&d[3k+k/2-1] r2=&d[2k+k/2] r3=k/2 r4=k/2 r10=0 r11=&a[k+k/2] r12=&c[k+k/2]
	bl 		school_book_mul2_16_fast_mem
	sub 	r0, r11, r4, lsl #1
	mov		r9, r1
	mov 	r3, #0
	sub 	r1, r12, r4, lsl #1
//r0=&a[k] r1=&c[k] r2=&d[2k+k/2] r3=i r4=k/2 r9=&d[3k+k/2-1] r10=0 r11=&a[k+k/2] r12=&c[k+k/2]
unrolled_kara_mem_loop8:
	ldr 	r5, [r2, r4, lsl #1]
	ldr 	r6, [r2], #4
	ldr 	r7, [r2, r4, lsl #1]
	ldr 	r8, [r2], #4
	add 	r3, r3, #4
	uadd16	r5, r5, r6
	uadd16	r7, r7, r8
	str 	r5, [r9], #4
	str 	r10, [r2, #-8]
	cmp		r3, r4
	str 	r7, [r9], #4
	str 	r10, [r2, #-4]
	bne		unrolled_kara_mem_loop8
	lsr		r8, r8, #16
	sub 	r2, r2, r4, lsl #2
	strh	r8, [r9, #-2]
//r0=&a[k] r1=&c[k] r2=&d[2k] r3=i r4=k/2 r9=&d[4k-1] r10=0 r11=&a[k+k/2] r12=&c[k+k/2]
	bl 		school_book_mul2_16_fast_mem
	sub 	r9, r9, r4, lsl #1
	add 	r0, r0, r4, lsl #1
	mov		r3, #0
	mov		r1, r12
//r0=&a[k+k/2] r1=&c[k+k/2] r2=&d[2k] r3=i r4=k/2 r9=&d[3k+k/2-1] r10=0
unrolled_kara_mem_loop9:
	ldr 	r5, [r2, r4, lsl #1]
	ldr 	r6, [r2, r4, lsl #2]
	ldr 	r7, [r2], #4
	ldr 	r8, [r9], #4
	ldr 	r11, [r2, r4, lsl #1]
	ldr 	r12, [r2, r4, lsl #2]
	usub16	r5, r6, r5
	usub16	r7, r8, r7
	ldr 	r6, [r2], #-4
	ldr 	r8, [r9], #4
	str 	r5, [r2, r4, lsl #2]
	str 	r7, [r2, r4, lsl #1]
	usub16	r5, r12, r11
	usub16	r7, r8, r6
	add		r2, r2, #4
	add		r3, r3, #4
	str 	r5, [r2, r4, lsl #2]
	str 	r7, [r2, r4, lsl #1]
	add		r2, r2, #4
	cmp 	r3, r4
	str 	r10, [r9, #-8]
	str 	r10, [r9, #-4]
	bne 	unrolled_kara_mem_loop9
	mov		r12, r2
	add 	r2, r2, r4, lsl #1
	sub 	r11, r2, r4, lsl #3
//r0=&a[k+k/2] r1=&c[k+k/2] r2=&d[3k] r3=k/2 r4=k/2 r9=&d[4k-1] r10=0 r11=d[k] r12=d[2k+k/2]
	bl 		school_book_mul2_16_fast_mem
	add 	r2, r2, r4, lsl #1
//r0=&a[2k] r1=&c[k+k/2] r2=&d[3k+k/2] r3=k/2 r4=k/2 r9=&d[4k-1] r10=0 r11=d[k] r12=d[2k+k/2]
unrolled_kara_mem_loop10:
	ldr 	r7, [r12]
	ldr 	r8, [r12, r3, lsl #1]
	ldr 	r5, [r11, r3, lsl #1]
	ldr 	r4, [r11]
	usub16 	r7, r7, r8
	ldr 	r6, [r11, r3, lsl #2]
	usub16	r5, r5, r7
	ldr 	r9, [r12, r3, lsl #2]
	str 	r5, [r11, r3, lsl #1]
	usub16	r4, r4, r6
	usub16	r5, r8, r9
	add		r10, r10, #2
	usub16	r6, r6, r5
	usub16 	r9, r7, r9
	str 	r5, [r12, r3, lsl #1]
	str 	r6, [r11, r3, lsl #2]
	cmp 	r3, r10
	str 	r4, [r11], #4
	str 	r9, [r12], #4
	bne 	unrolled_kara_mem_loop10
//r0=&a[2k] r1=&c[k+k/2] r2=&d[3k+k/2] r3=k/2 r4=k/2 r9=&d[4k-1] r10=0 r11=d[k+k/2] r12=d[3k]
	lsr 	r7, r7, #16
	lsr 	r8, r8, #16
	strh 	r7, [r12, #-2]
	strh	r8, [r2, #-2]
	ldmia.w	sp!, {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
exit_unrolled_kara_mem:
	bx	lr
	nop
.endfunc

//**************************
//* HELPER FOR DEBUGGING C *
//**************************
.global debug_helper
.func debug_helper, debug_helper
.type debug_helper, %function
.align 2
debug_helper:
	stmdb	sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
	nop
	nop
	nop
	ldmia.w	sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}
.endfunc
