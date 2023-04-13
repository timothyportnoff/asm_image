.global pastel ;// void pastel(unsigned char *in,unsigned char *out, int width, int height);
pastel:
	push {LR}
	PUSH {R4-R12} //Preserve registers the ABI says we must preserve
	;//R0 is *in
     ;//R1 is *out
     ;//R2 is width
     ;//R3 is height
     ;//R4 is how many bytes to process
     ;//R5 is input green
     ;//R6 is input blue
     ;//R7 is output green
     ;//R8 is output blue
     ;//R9 is i

     MULS R4,R2,R3 @R4 will hold how many bytes to process - this is enough for the red part
     MOV R3, #21845 //Used in the multiply below
     BLE quit @If image is zero size, quit

     ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output
     MOV R9, #0 //Your i

     @TODO: Make sure the size of the array is divisible by 128 bits

loop:
	;//
	bal wash


	;//====================

	compass:
	mov r7, #0
	mov r8, #0
	mov r12, #0 ;//reset

	n: ;//n
	subs r10, r9, r2
	blt s
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, r11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	s: ;//s
	adds r10, r9, r2
	bge e
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, r11

	e: ;//e
	adds r10, r9, #1
	cmp r10, r4
	bge w
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, r11

	w: ;//w
	subs r10, r9, #1
	blt compass_end
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, r11
	
	VMOV s0, #4
	VMOV s1, r7
	VDIV.F32 s1, s1, s0
	VMOV r7, s1

	VMOV s1, r8
	VDIV.F32 s1, s1, s0
	VMOV r8, s1

	VMOV s1, r12
	VDIV.F32 s1, s1, s0
	VMOV r12, s1

	compass_end:

	;//====================
     LDRB R11, [R0,R10] ;//Loads red value
     STRB R11, [R1,R9] ;//Store the red value

     LDRB R11, [R5,R10] ;//Loads green value
     STRB R11, [R7,R9] ;//Store the red value

     LDRB R11, [R6,R10] ;//Loads blue value
     STRB R11, [R8,R9] ;//Store the red value

	;//take average of colors and return them to output
     ADD R7, R1, R4 ;//@R7 is the start of the green plane for output
     STRB R8, [R7,R9] ;//Store the green value
     ADD R8, R7, R4 ;//@R8 is the start of the blue plane for output
     STRB R12, [R8,R9] ;//Store the blue value
	bal skip

	;//

	;//====================

	trace_light:
     LDRB R10, [R0,R9] //Loads red value
	lsr r10, #1
     LDRB R11, [R5,R9] //Loads green value
	lsr r11, #1
     LDRB R12, [R6,R9] //Loads blue value
	lsr r12, #1
     STRB R10, [R1,R9] //Store the red value
     STRB R11, [R7,R9] //Store the green value
     STRB R12, [R8,R9] //Store the blue value
	bal skip

	trace_red:
	mov r5, #255
     STRB R5, [R1,R9] //Store the red value
	mov r5, #0
     STRB R5, [R7,R9] //Store the green value
     STRB R5, [R8,R9] //Store the blue value
     ADD R5, R0, R4 ;//RESET GREEN PLANE START
	bal skip

	wash:
     ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output
     LDRB R10, [R0,R9] //Loads red value
     LDRB R11, [R5,R9] //Loads green value
     LDRB R12, [R6,R9] //Loads blue value
     STRB R10, [R1,R9] //Store the red value
     STRB R11, [R7,R9] //Store the green value
     STRB R11, [R8,R9] //Store the blue value
	bal skip

	pass:
     ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output
     LDRB R10, [R0,R9] //Loads red value
     LDRB R11, [R5,R9] //Loads green value
     LDRB R12, [R6,R9] //Loads blue value
     STRB R10, [R1,R9] //Store the red value
     STRB R11, [R7,R9] //Store the green value
     STRB R12, [R8,R9] //Store the blue value
	bal skip

	;//Exit statements
	skip:
     ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output
     ADD R9, R9, #1
     CMP R9,R4
     BLT loop

quit:
	POP {R4-R12} ;#Restore saved registers
	pop {PC}
