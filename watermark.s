.global watermark ;// void watermark(unsigned char *in,unsigned char *out, int width, int height);
watermark:
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
	bal pass

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

	trace_medium:
     LDRB R10, [R0,R9] //Loads red value
	lsr r10, #2
     LDRB R11, [R5,R9] //Loads green value
	lsr r11, #2
     LDRB R12, [R6,R9] //Loads blue value
	lsr r12, #2
     STRB R10, [R1,R9] //Store the red value
     STRB R11, [R7,R9] //Store the green value
     STRB R12, [R8,R9] //Store the blue value
	bal skip

	write:
	mov r12, #255
     STRB R12, [R1,R9] //Store the red value
     STRB R12, [R7,R9] //Store the green value
     STRB R12, [R8,R9] //Store the blue value
	bx lr

	trace_dark:
     LDRB R10, [R0,R9] //Loads red value
	lsr r10, #3
     LDRB R11, [R5,R9] //Loads green value
	lsr r11, #3
     LDRB R12, [R6,R9] //Loads blue value
	lsr r12, #3
     STRB R10, [R1,R9] //Store the red value
     STRB R11, [R7,R9] //Store the green value
     STRB R12, [R8,R9] //Store the blue value
	bal skip

	greyscale:
     LDRB R10, [R0,R9] //Loads red value
     LDRB R11, [R5,R9] //Loads green value
     LDRB R12, [R6,R9] //Loads blue value
     ADD R2, R10, R11 //Adds red and green
     ADD R2, R10, R12 //Add in blue
     //Do the average here, divide R2 by 3
     //Bad way:
     //MOV R2, R2, LSR #1 //Divide by 2, which is not a good average
     //Better way:
     //Multiply by 85 then divide by 256
     MUL R2, R2, R3 //Multiply by 21845
     MOV R2, R2, LSR #16 //Divide by 65536
     STRB R2, [R1,R9] //Store the red value
     STRB R2, [R7,R9] //Store the green value
     STRB R2, [R8,R9] //Store the blue value
	bal skip

	trace_red:
	mov r5, #255
     STRB R5, [R1,R9] //Store the red value
	mov r5, #0
     STRB R5, [R7,R9] //Store the green value
     STRB R5, [R8,R9] //Store the blue value
     ADD R5, R0, R4 ;//RESET GREEN PLANE START
	bal skip

	trace_blue:
	mov r5, #255
     STRB R5, [R8,R9] //Store the blue value
	mov r5, #0
     STRB R5, [R1,R9] //Store the red value
     STRB R5, [R7,R9] //Store the green value
     ADD R5, R0, R4 ;//RESET GREEN PLANE START
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
/*
etch_a_sketch:
	;//r5, r6, r10, r11, r12 not needed
	mov r11, #10
	mov r12, #5
	loop_1:
		subs r12, #1
		STRB R11, [R1,R9] //Store the red value
		STRB R11, [R7,R9] //Store the green value
		STRB R11, [R8,R9] //Store the blue value
		bal trace_red
		beq exit_1
		bal loop_1
	exit_1:

	mov r12, #10
	loop_2:
		subs r12, #1
		STRB R11, [R1,R9] //Store the red value
		STRB R11, [R7,R9] //Store the green value
		STRB R11, [R8,R9] //Store the blue value
		beq exit_2
		bal loop_2
	exit_2:
*/
quit:
	POP {R4-R12} ;#Restore saved registers
	pop {PC}
