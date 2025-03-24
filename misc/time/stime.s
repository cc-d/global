	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0	sdk_version 15, 2
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0
lCPI0_0:
	.quad	0x43e0000000000000
lCPI0_1:
	.quad	0xc3e0000000000001
lCPI0_2:
	.quad	0x41cdcd6500000000
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:
	.cfi_startproc
	sub	sp, sp, #384
	stp	x20, x19, [sp, #352]
	stp	x29, x30, [sp, #368]
	add	x29, sp, #368
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	adrp	x8, "l_.str.11.Fatal error"@PAGE
	add	x8, x8, "l_.str.11.Fatal error"@PAGEOFF
	stur	x8, [x29, #-120]
	adrp	x8, "l_.str.76.Double value cannot be converted to Int because it is either infinite or NaN"@PAGE
	add	x8, x8, "l_.str.76.Double value cannot be converted to Int because it is either infinite or NaN"@PAGEOFF
	stur	x8, [x29, #-112]
	adrp	x8, "l_.str.39.Swift/arm64e-apple-macos.swiftinterface"@PAGE
	add	x8, x8, "l_.str.39.Swift/arm64e-apple-macos.swiftinterface"@PAGEOFF
	stur	x8, [x29, #-104]
	adrp	x8, "l_.str.85.Double value cannot be converted to Int because the result would be less than Int.min"@PAGE
	add	x8, x8, "l_.str.85.Double value cannot be converted to Int because the result would be less than Int.min"@PAGEOFF
	stur	x8, [x29, #-96]
	adrp	x8, "l_.str.88.Double value cannot be converted to Int because the result would be greater than Int.max"@PAGE
	add	x8, x8, "l_.str.88.Double value cannot be converted to Int because the result would be greater than Int.max"@PAGEOFF
	stur	x8, [x29, #-88]
	mov	x0, #0
	bl	_$s10Foundation4DateVMa
	stur	x0, [x29, #-72]
	adrp	x1, _$s5stime3now10Foundation4DateVvp@PAGE
	add	x1, x1, _$s5stime3now10Foundation4DateVvp@PAGEOFF
	stur	x1, [x29, #-80]
	bl	___swift_allocate_value_buffer
	ldur	x1, [x29, #-80]
	ldur	x0, [x29, #-72]
	bl	___swift_project_value_buffer
	mov	x20, x0
	mov	x8, x20
	bl	_$s10Foundation4DateVACycfC
	bl	_$s10Foundation4DateV21timeIntervalSince1970Sdvg
	adrp	x8, _$s5stime12timeIntervalSdvp@PAGE
	str	d0, [x8, _$s5stime12timeIntervalSdvp@PAGEOFF]
	ldr	d0, [x8, _$s5stime12timeIntervalSdvp@PAGEOFF]
	stur	d0, [x29, #-64]
	fmov	x8, d0
	lsr	x8, x8, #52
	and	x8, x8, #0x7ff
	subs	x8, x8, #2047
	cset	w8, lo
	tbnz	w8, #0, LBB0_2
	b	LBB0_1
LBB0_1:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-112]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39203
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #76
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_2:
	ldur	d1, [x29, #-64]
	adrp	x8, lCPI0_1@PAGE
	ldr	d0, [x8, lCPI0_1@PAGEOFF]
	fcmp	d0, d1
	cset	w8, mi
	tbnz	w8, #0, LBB0_4
	b	LBB0_3
LBB0_3:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-96]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39206
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #85
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_4:
	ldur	d0, [x29, #-64]
	adrp	x8, lCPI0_0@PAGE
	ldr	d1, [x8, lCPI0_0@PAGEOFF]
	fcmp	d0, d1
	cset	w8, mi
	tbnz	w8, #0, LBB0_6
	b	LBB0_5
LBB0_5:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-88]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39209
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #88
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_6:
	ldur	d0, [x29, #-64]
	fcvtzs	x9, d0
	adrp	x8, _$s5stime7secondsSivp@PAGE
	str	x9, [x8, _$s5stime7secondsSivp@PAGEOFF]
	adrp	x9, _$s5stime12timeIntervalSdvp@PAGE
	ldr	d0, [x9, _$s5stime12timeIntervalSdvp@PAGEOFF]
	ldr	d1, [x8, _$s5stime7secondsSivp@PAGEOFF]
	scvtf	d1, d1
	fsub	d0, d0, d1
	adrp	x8, lCPI0_2@PAGE
	ldr	d1, [x8, lCPI0_2@PAGEOFF]
	fmul	d0, d0, d1
	stur	d0, [x29, #-128]
	fmov	x8, d0
	lsr	x8, x8, #52
	and	x8, x8, #0x7ff
	subs	x8, x8, #2047
	cset	w8, lo
	tbnz	w8, #0, LBB0_8
	b	LBB0_7
LBB0_7:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-112]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39203
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #76
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_8:
	ldur	d1, [x29, #-128]
	adrp	x8, lCPI0_1@PAGE
	ldr	d0, [x8, lCPI0_1@PAGEOFF]
	fcmp	d0, d1
	cset	w8, mi
	tbnz	w8, #0, LBB0_10
	b	LBB0_9
LBB0_9:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-96]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39206
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #85
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_10:
	ldur	d0, [x29, #-128]
	adrp	x8, lCPI0_0@PAGE
	ldr	d1, [x8, lCPI0_0@PAGEOFF]
	fcmp	d0, d1
	cset	w8, mi
	tbnz	w8, #0, LBB0_12
	b	LBB0_11
LBB0_11:
	ldur	x6, [x29, #-104]
	ldur	x3, [x29, #-88]
	ldur	x0, [x29, #-120]
	mov	x9, sp
	mov	w8, #2
	strb	w8, [x9]
	mov	w8, #39209
	str	x8, [x9, #8]
	mov	w8, #1
	str	w8, [x9, #16]
	mov	w8, #11
	mov	x1, x8
	mov	w5, #2
	mov	x2, x5
	mov	w8, #88
	mov	x4, x8
	mov	w8, #39
	mov	x7, x8
	bl	_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF
	brk	#0x1
LBB0_12:
	ldur	d0, [x29, #-128]
	fcvtzs	x8, d0
	adrp	x9, _$s5stime11nanosecondsSivp@PAGE
	str	x9, [sp, #56]
	str	x8, [x9, _$s5stime11nanosecondsSivp@PAGEOFF]
	mov	w8, #1
	mov	x0, x8
	str	x0, [sp, #48]
	adrp	x8, _$sypN@GOTPAGE
	ldr	x8, [x8, _$sypN@GOTPAGEOFF]
	add	x1, x8, #8
	stur	x1, [x29, #-168]
	bl	_$ss27_allocateUninitializedArrayySayxG_BptBwlF
	mov	x2, x0
	ldr	x0, [sp, #48]
	stur	x2, [x29, #-176]
	str	x1, [sp, #184]
	mov	w8, #2
	mov	x1, x8
	bl	_$ss26DefaultStringInterpolationV15literalCapacity18interpolationCountABSi_SitcfC
	sub	x20, x29, #32
	str	x20, [sp, #152]
	stur	x0, [x29, #-32]
	stur	x1, [x29, #-24]
	adrp	x0, l_.str.0.@PAGE
	add	x0, x0, l_.str.0.@PAGEOFF
	str	x0, [sp, #136]
	mov	x1, #0
	str	x1, [sp, #120]
	mov	w8, #1
	str	w8, [sp, #132]
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	str	x1, [sp, #32]
	bl	_$ss26DefaultStringInterpolationV13appendLiteralyySSF
	ldr	x20, [sp, #152]
	ldr	x0, [sp, #32]
	bl	_swift_bridgeObjectRelease
	adrp	x8, _$s5stime7secondsSivp@PAGE
	ldr	x8, [x8, _$s5stime7secondsSivp@PAGEOFF]
	sub	x0, x29, #40
	stur	x8, [x29, #-40]
	adrp	x1, _$sSiN@GOTPAGE
	ldr	x1, [x1, _$sSiN@GOTPAGEOFF]
	str	x1, [sp, #64]
	adrp	x2, _$sSis23CustomStringConvertiblesWP@GOTPAGE
	ldr	x2, [x2, _$sSis23CustomStringConvertiblesWP@GOTPAGEOFF]
	bl	_$ss26DefaultStringInterpolationV06appendC0yyxs06CustomB11ConvertibleRzlF
	ldr	x20, [sp, #152]
	ldr	x1, [sp, #48]
	ldr	w8, [sp, #132]
	adrp	x0, l_.str.1..@PAGE
	add	x0, x0, l_.str.1..@PAGEOFF
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	str	x1, [sp, #40]
	bl	_$ss26DefaultStringInterpolationV13appendLiteralyySSF
	ldr	x20, [sp, #152]
	ldr	x0, [sp, #40]
	bl	_swift_bridgeObjectRelease
	ldr	w8, [sp, #132]
	adrp	x0, "l_.str.4.%09d"@PAGE
	add	x0, x0, "l_.str.4.%09d"@PAGEOFF
	mov	w9, #4
	mov	x1, x9
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	str	x0, [sp, #80]
	str	x1, [sp, #88]
	adrp	x0, _$ss7CVarArg_pMD@PAGE
	add	x0, x0, _$ss7CVarArg_pMD@PAGEOFF
	bl	___swift_instantiateConcreteTypeFromMangledName
	mov	x1, x0
	ldr	x0, [sp, #48]
	str	x1, [sp, #72]
	bl	_$ss27_allocateUninitializedArrayySayxG_BptBwlF
	ldr	x8, [sp, #56]
	ldr	x10, [sp, #64]
	mov	x9, x1
	ldr	x1, [sp, #72]
	ldr	x8, [x8, _$s5stime11nanosecondsSivp@PAGEOFF]
	str	x10, [x9, #24]
	adrp	x10, _$sSis7CVarArgsWP@GOTPAGE
	ldr	x10, [x10, _$sSis7CVarArgsWP@GOTPAGEOFF]
	str	x10, [x9, #32]
	str	x8, [x9]
	bl	_$ss27_finalizeUninitializedArrayySayxGABnlF
	ldr	x1, [sp, #88]
	mov	x2, x0
	ldr	x0, [sp, #80]
	bl	_$sSS10FoundationE6format_S2Sh_s7CVarArg_pdtcfC
	mov	x8, x0
	ldr	x0, [sp, #88]
	str	x8, [sp, #96]
	str	x1, [sp, #104]
	bl	_swift_bridgeObjectRelease
	ldr	x8, [sp, #96]
	ldr	x1, [sp, #104]
	sub	x0, x29, #56
	str	x0, [sp, #112]
	stur	x8, [x29, #-56]
	stur	x1, [x29, #-48]
	adrp	x1, _$sSSN@GOTPAGE
	ldr	x1, [x1, _$sSSN@GOTPAGEOFF]
	str	x1, [sp, #176]
	adrp	x2, _$sSSs23CustomStringConvertiblesWP@GOTPAGE
	ldr	x2, [x2, _$sSSs23CustomStringConvertiblesWP@GOTPAGEOFF]
	adrp	x3, _$sSSs20TextOutputStreamablesWP@GOTPAGE
	ldr	x3, [x3, _$sSSs20TextOutputStreamablesWP@GOTPAGEOFF]
	bl	_$ss26DefaultStringInterpolationV06appendC0yyxs06CustomB11ConvertibleRzs20TextOutputStreamableRzlF
	ldr	x20, [sp, #152]
	ldr	x0, [sp, #112]
	bl	_$sSSWOh
	ldr	x1, [sp, #120]
	ldr	w8, [sp, #132]
	ldr	x0, [sp, #136]
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	str	x1, [sp, #144]
	bl	_$ss26DefaultStringInterpolationV13appendLiteralyySSF
	ldr	x0, [sp, #144]
	bl	_swift_bridgeObjectRelease
	ldur	x8, [x29, #-32]
	str	x8, [sp, #168]
	ldur	x0, [x29, #-24]
	str	x0, [sp, #160]
	bl	_swift_bridgeObjectRetain
	ldr	x0, [sp, #152]
	bl	_$ss26DefaultStringInterpolationVWOh
	ldr	x1, [sp, #160]
	ldr	x0, [sp, #168]
	bl	_$sSS19stringInterpolationSSs013DefaultStringB0V_tcfC
	ldr	x11, [sp, #176]
	ldr	x9, [sp, #184]
	mov	x10, x0
	ldur	x0, [x29, #-176]
	mov	x8, x1
	ldur	x1, [x29, #-168]
	str	x11, [x9, #24]
	str	x10, [x9]
	str	x8, [x9, #8]
	bl	_$ss27_finalizeUninitializedArrayySayxGABnlF
	stur	x0, [x29, #-136]
	bl	_$ss5print_9separator10terminatoryypd_S2StFfA0_
	stur	x0, [x29, #-160]
	stur	x1, [x29, #-144]
	bl	_$ss5print_9separator10terminatoryypd_S2StFfA1_
	ldur	x2, [x29, #-144]
	mov	x3, x0
	ldur	x0, [x29, #-136]
	mov	x4, x1
	ldur	x1, [x29, #-160]
	stur	x4, [x29, #-152]
	bl	_$ss5print_9separator10terminatoryypd_S2StF
	ldur	x0, [x29, #-152]
	bl	_swift_bridgeObjectRelease
	ldur	x0, [x29, #-144]
	bl	_swift_bridgeObjectRelease
	ldur	x0, [x29, #-136]
	bl	_swift_bridgeObjectRelease
	mov	w0, #0
	ldp	x29, x30, [sp, #368]
	ldp	x20, x19, [sp, #352]
	add	sp, sp, #384
	ret
	.cfi_endproc

	.private_extern	___swift_allocate_value_buffer
	.globl	___swift_allocate_value_buffer
	.weak_definition	___swift_allocate_value_buffer
	.p2align	2
___swift_allocate_value_buffer:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	str	x0, [sp]
	str	x1, [sp, #8]
	ldur	x8, [x0, #-8]
	ldr	w8, [x8, #80]
	str	x8, [sp, #16]
	ands	w8, w8, #0x20000
	cset	w8, eq
	stur	x1, [x29, #-8]
	tbnz	w8, #0, LBB1_2
	b	LBB1_1
LBB1_1:
	ldr	x8, [sp, #16]
	ldr	x9, [sp]
	ldur	x9, [x9, #-8]
	ldr	x0, [x9, #64]
	and	x1, x8, #0xff
	bl	_swift_slowAlloc
	ldr	x9, [sp, #8]
	mov	x8, x0
	str	x8, [x9]
	stur	x0, [x29, #-8]
	b	LBB1_2
LBB1_2:
	ldur	x0, [x29, #-8]
	ldp	x29, x30, [sp, #32]
	add	sp, sp, #48
	ret

	.private_extern	___swift_project_value_buffer
	.globl	___swift_project_value_buffer
	.weak_definition	___swift_project_value_buffer
	.p2align	2
___swift_project_value_buffer:
	sub	sp, sp, #16
	str	x1, [sp]
	ldur	x8, [x0, #-8]
	ldr	w8, [x8, #80]
	ands	w8, w8, #0x20000
	cset	w8, eq
	str	x1, [sp, #8]
	tbnz	w8, #0, LBB2_2
	b	LBB2_1
LBB2_1:
	ldr	x8, [sp]
	ldr	x8, [x8]
	str	x8, [sp, #8]
	b	LBB2_2
LBB2_2:
	ldr	x0, [sp, #8]
	add	sp, sp, #16
	ret

	.private_extern	___swift_instantiateConcreteTypeFromMangledName
	.globl	___swift_instantiateConcreteTypeFromMangledName
	.weak_definition	___swift_instantiateConcreteTypeFromMangledName
	.p2align	2
___swift_instantiateConcreteTypeFromMangledName:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	str	x0, [sp, #8]
	ldr	x0, [x0]
	str	x0, [sp, #16]
	subs	x8, x0, #0
	cset	w8, lt
	stur	x0, [x29, #-8]
	tbnz	w8, #0, LBB3_2
	b	LBB3_1
LBB3_1:
	ldur	x0, [x29, #-8]
	ldp	x29, x30, [sp, #32]
	add	sp, sp, #48
	ret
LBB3_2:
	ldr	x8, [sp, #8]
	ldr	x9, [sp, #16]
	mov	x10, #0
	subs	x1, x10, x9, asr #32
	add	x0, x8, w9, sxtw
	mov	x3, #0
	mov	x2, x3
	bl	_swift_getTypeByMangledNameInContext2
	ldr	x8, [sp, #8]
	str	x0, [x8]
	stur	x0, [x29, #-8]
	b	LBB3_1

	.private_extern	_$ss27_finalizeUninitializedArrayySayxGABnlF
	.globl	_$ss27_finalizeUninitializedArrayySayxGABnlF
	.weak_definition	_$ss27_finalizeUninitializedArrayySayxGABnlF
	.p2align	2
_$ss27_finalizeUninitializedArrayySayxGABnlF:
	.cfi_startproc
	sub	sp, sp, #48
	stp	x20, x19, [sp, #16]
	stp	x29, x30, [sp, #32]
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x8, x1
	str	x8, [sp, #8]
	mov	x20, sp
	str	x0, [sp]
	mov	x0, #0
	bl	_$sSaMa
	bl	_$sSa12_endMutationyyF
	ldr	x0, [sp]
	ldp	x29, x30, [sp, #32]
	ldp	x20, x19, [sp, #16]
	add	sp, sp, #48
	ret
	.cfi_endproc

	.private_extern	_$sSSWOh
	.globl	_$sSSWOh
	.weak_definition	_$sSSWOh
	.p2align	2
_$sSSWOh:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	str	x0, [sp, #8]
	ldr	x0, [x0, #8]
	bl	_swift_bridgeObjectRelease
	ldr	x0, [sp, #8]
	ldp	x29, x30, [sp, #16]
	add	sp, sp, #32
	ret

	.private_extern	_$ss26DefaultStringInterpolationVWOh
	.globl	_$ss26DefaultStringInterpolationVWOh
	.weak_definition	_$ss26DefaultStringInterpolationVWOh
	.p2align	2
_$ss26DefaultStringInterpolationVWOh:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]
	add	x29, sp, #16
	str	x0, [sp, #8]
	ldr	x0, [x0, #8]
	bl	_swift_bridgeObjectRelease
	ldr	x0, [sp, #8]
	ldp	x29, x30, [sp, #16]
	add	sp, sp, #32
	ret

	.private_extern	_$ss5print_9separator10terminatoryypd_S2StFfA0_
	.globl	_$ss5print_9separator10terminatoryypd_S2StFfA0_
	.weak_definition	_$ss5print_9separator10terminatoryypd_S2StFfA0_
	.p2align	2
_$ss5print_9separator10terminatoryypd_S2StFfA0_:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x0, "l_.str.1. "@PAGE
	add	x0, x0, "l_.str.1. "@PAGEOFF
	mov	w8, #1
	mov	x1, x8
	mov	w8, #1
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	ldp	x29, x30, [sp], #16
	ret
	.cfi_endproc

	.private_extern	_$ss5print_9separator10terminatoryypd_S2StFfA1_
	.globl	_$ss5print_9separator10terminatoryypd_S2StFfA1_
	.weak_definition	_$ss5print_9separator10terminatoryypd_S2StFfA1_
	.p2align	2
_$ss5print_9separator10terminatoryypd_S2StFfA1_:
	.cfi_startproc
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x0, "l_.str.1.\n"@PAGE
	add	x0, x0, "l_.str.1.\n"@PAGEOFF
	mov	w8, #1
	mov	x1, x8
	mov	w8, #1
	and	w2, w8, #0x1
	bl	_$sSS21_builtinStringLiteral17utf8CodeUnitCount7isASCIISSBp_BwBi1_tcfC
	ldp	x29, x30, [sp], #16
	ret
	.cfi_endproc

	.private_extern	_$sSa12_endMutationyyF
	.globl	_$sSa12_endMutationyyF
	.weak_definition	_$sSa12_endMutationyyF
	.p2align	2
_$sSa12_endMutationyyF:
	.cfi_startproc
	ldr	x8, [x20]
	str	x8, [x20]
	ret
	.cfi_endproc

	.private_extern	_$s5stime3now10Foundation4DateVvp
	.globl	_$s5stime3now10Foundation4DateVvp
.zerofill __DATA,__common,_$s5stime3now10Foundation4DateVvp,24,3
	.private_extern	_$s5stime12timeIntervalSdvp
	.globl	_$s5stime12timeIntervalSdvp
.zerofill __DATA,__common,_$s5stime12timeIntervalSdvp,8,3
	.private_extern	_$s5stime7secondsSivp
	.globl	_$s5stime7secondsSivp
.zerofill __DATA,__common,_$s5stime7secondsSivp,8,3
	.private_extern	_$s5stime11nanosecondsSivp
	.globl	_$s5stime11nanosecondsSivp
.zerofill __DATA,__common,_$s5stime11nanosecondsSivp,8,3
	.section	__TEXT,__cstring,cstring_literals
	.p2align	4, 0x0
"l_.str.76.Double value cannot be converted to Int because it is either infinite or NaN":
	.asciz	"Double value cannot be converted to Int because it is either infinite or NaN"

	.p2align	4, 0x0
"l_.str.39.Swift/arm64e-apple-macos.swiftinterface":
	.asciz	"Swift/arm64e-apple-macos.swiftinterface"

"l_.str.11.Fatal error":
	.asciz	"Fatal error"

	.p2align	4, 0x0
"l_.str.85.Double value cannot be converted to Int because the result would be less than Int.min":
	.asciz	"Double value cannot be converted to Int because the result would be less than Int.min"

	.p2align	4, 0x0
"l_.str.88.Double value cannot be converted to Int because the result would be greater than Int.max":
	.asciz	"Double value cannot be converted to Int because the result would be greater than Int.max"

l_.str.0.:
	.space	1

l_.str.1..:
	.asciz	"."

"l_.str.4.%09d":
	.asciz	"%09d"

	.private_extern	"_symbolic ______p s7CVarArgP"
	.section	__TEXT,__swift5_typeref
	.globl	"_symbolic ______p s7CVarArgP"
	.weak_definition	"_symbolic ______p s7CVarArgP"
	.p2align	1, 0x0
"_symbolic ______p s7CVarArgP":
	.byte	2
Ltmp0:
	.long	_$ss7CVarArgMp@GOT-Ltmp0
	.ascii	"_p"
	.byte	0

	.private_extern	_$ss7CVarArg_pMD
	.section	__DATA,__data
	.globl	_$ss7CVarArg_pMD
	.weak_definition	_$ss7CVarArg_pMD
	.p2align	3, 0x0
_$ss7CVarArg_pMD:
	.long	"_symbolic ______p s7CVarArgP"-_$ss7CVarArg_pMD
	.long	4294967289

	.section	__TEXT,__swift5_entry,regular,no_dead_strip
	.p2align	2, 0x0
l_entry_point:
	.long	_main-l_entry_point
	.long	0

	.private_extern	__swift_FORCE_LOAD_$_swiftFoundation_$_stime
	.section	__DATA,__const
	.globl	__swift_FORCE_LOAD_$_swiftFoundation_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftFoundation_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftFoundation_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftFoundation

	.private_extern	__swift_FORCE_LOAD_$_swift_errno_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_errno_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_errno_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_errno_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_errno

	.private_extern	__swift_FORCE_LOAD_$_swiftsys_time_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftsys_time_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftsys_time_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftsys_time_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftsys_time

	.private_extern	__swift_FORCE_LOAD_$_swift_signal_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_signal_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_signal_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_signal_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_signal

	.private_extern	__swift_FORCE_LOAD_$_swift_stdio_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_stdio_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_stdio_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_stdio_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_stdio

	.private_extern	__swift_FORCE_LOAD_$_swift_time_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_time_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_time_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_time_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_time

	.private_extern	__swift_FORCE_LOAD_$_swiftunistd_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftunistd_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftunistd_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftunistd_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftunistd

	.private_extern	__swift_FORCE_LOAD_$_swift_math_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_math_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_math_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_math_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_math

	.private_extern	__swift_FORCE_LOAD_$_swift_Builtin_float_$_stime
	.globl	__swift_FORCE_LOAD_$_swift_Builtin_float_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swift_Builtin_float_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swift_Builtin_float_$_stime:
	.quad	__swift_FORCE_LOAD_$_swift_Builtin_float

	.private_extern	__swift_FORCE_LOAD_$_swiftDarwin_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftDarwin_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftDarwin_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDarwin_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftDarwin

	.private_extern	__swift_FORCE_LOAD_$_swiftObjectiveC_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftObjectiveC_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftObjectiveC_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftObjectiveC_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftObjectiveC

	.private_extern	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftCoreFoundation_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftCoreFoundation

	.private_extern	__swift_FORCE_LOAD_$_swiftDispatch_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftDispatch_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftDispatch_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftDispatch_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftDispatch

	.private_extern	__swift_FORCE_LOAD_$_swiftXPC_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftXPC_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftXPC_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftXPC_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftXPC

	.private_extern	__swift_FORCE_LOAD_$_swiftIOKit_$_stime
	.globl	__swift_FORCE_LOAD_$_swiftIOKit_$_stime
	.weak_definition	__swift_FORCE_LOAD_$_swiftIOKit_$_stime
	.p2align	3, 0x0
__swift_FORCE_LOAD_$_swiftIOKit_$_stime:
	.quad	__swift_FORCE_LOAD_$_swiftIOKit

	.section	__TEXT,__cstring,cstring_literals
"l_.str.1.\n":
	.asciz	"\n"

"l_.str.1. ":
	.asciz	" "

	.private_extern	___swift_reflection_version
	.section	__TEXT,__const
	.globl	___swift_reflection_version
	.weak_definition	___swift_reflection_version
	.p2align	1, 0x0
___swift_reflection_version:
	.short	3

	.no_dead_strip	_$s5stime3now10Foundation4DateVvp
	.no_dead_strip	_$s5stime12timeIntervalSdvp
	.no_dead_strip	_$s5stime7secondsSivp
	.no_dead_strip	_$s5stime11nanosecondsSivp
	.no_dead_strip	_main
	.no_dead_strip	l_entry_point
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftFoundation_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_errno_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftsys_time_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_signal_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_stdio_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_time_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftunistd_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_math_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swift_Builtin_float_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDarwin_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftObjectiveC_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftCoreFoundation_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftDispatch_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftXPC_$_stime
	.no_dead_strip	__swift_FORCE_LOAD_$_swiftIOKit_$_stime
	.no_dead_strip	___swift_reflection_version
	.linker_option "-lswiftFoundation"
	.linker_option "-framework", "Foundation"
	.linker_option "-lswiftCore"
	.linker_option "-lswift_errno"
	.linker_option "-lswiftsys_time"
	.linker_option "-lswift_signal"
	.linker_option "-lswift_stdio"
	.linker_option "-lswift_time"
	.linker_option "-lswiftunistd"
	.linker_option "-lswift_math"
	.linker_option "-lswift_Builtin_float"
	.linker_option "-lswift_StringProcessing"
	.linker_option "-lswift_Concurrency"
	.linker_option "-lswiftSystem"
	.linker_option "-lswiftDarwin"
	.linker_option "-lswiftObservation"
	.linker_option "-lswiftObjectiveC"
	.linker_option "-lswiftCoreFoundation"
	.linker_option "-framework", "CoreFoundation"
	.linker_option "-lswiftDispatch"
	.linker_option "-framework", "Combine"
	.linker_option "-framework", "CoreServices"
	.linker_option "-framework", "Security"
	.linker_option "-lswiftXPC"
	.linker_option "-framework", "CFNetwork"
	.linker_option "-framework", "DiskArbitration"
	.linker_option "-lswiftIOKit"
	.linker_option "-framework", "IOKit"
	.linker_option "-lswiftSwiftOnoneSupport"
	.linker_option "-lobjc"
	.section	__DATA,__objc_imageinfo,regular,no_dead_strip
L_OBJC_IMAGE_INFO:
	.long	0
	.long	100665152

	.weak_reference __swift_FORCE_LOAD_$_swiftFoundation
	.weak_reference __swift_FORCE_LOAD_$_swift_errno
	.weak_reference __swift_FORCE_LOAD_$_swiftsys_time
	.weak_reference __swift_FORCE_LOAD_$_swift_signal
	.weak_reference __swift_FORCE_LOAD_$_swift_stdio
	.weak_reference __swift_FORCE_LOAD_$_swift_time
	.weak_reference __swift_FORCE_LOAD_$_swiftunistd
	.weak_reference __swift_FORCE_LOAD_$_swift_math
	.weak_reference __swift_FORCE_LOAD_$_swift_Builtin_float
	.weak_reference __swift_FORCE_LOAD_$_swiftDarwin
	.weak_reference __swift_FORCE_LOAD_$_swiftObjectiveC
	.weak_reference __swift_FORCE_LOAD_$_swiftCoreFoundation
	.weak_reference __swift_FORCE_LOAD_$_swiftDispatch
	.weak_reference __swift_FORCE_LOAD_$_swiftXPC
	.weak_reference __swift_FORCE_LOAD_$_swiftIOKit
.subsections_via_symbols
