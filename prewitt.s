.global prewitt
prewitt:
	;// void prewitt(unsigned char *in,unsigned char *out, int width, int height);
     @TODO: Make sure the size of the array is divisible by 128 bits
	push {LR}
	PUSH {R4-R12} 	;//Preserve registers the ABI says we must preserve

     MULS R4,R2,R3 	;//@R4 will hold how many bytes to process - this is enough for the red part
     MOV R3, #21845 ;//@R3 Used in the multiply below, magic number??
     BLE quit		;//If image is zero size, quit
     ADD R5, R0, R4 ;//@R5 is the start of the green plane for input
     ADD R6, R5, R4 ;//@R6 is the start of the blue plane for input
     ADD R7, R1, R4 ;//@R7 is the start of the green plane for output
     ADD R8, R7, R4 ;//@R8 is the start of the blue plane for output
     MOV R9, #0 	;//@R9 iterator variable

loop:
	mov r7, #0
	mov r8, #0
	mov r12, #0

	;//w
	subs r10, r9, #1
	blt skip
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
	//VADD s0, s0
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, r11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	;//n_w
	subs r10, r2
	blt check_s_w
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	;//s_w
	check_s_w:
	add r10, r2
	add r10, r2
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	;// Multiplicative property of negative one through reverse subtraction
	rsb r7, r7, #0 
	rsb r8, r8, #0 
	rsb r12, r12, #0 

	;//e
	subs r10, r2
	add r10, r10, #2
	cmp r10, r4
	bge skip
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	;//n_e
	subs r10, r2
	blt check_s_e
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads green value
     add r12, r11

	;//s_e
	check_s_e:
	add r10, r2
	add r10, r2
	cmp r10, r4
	bge n_s_e
     LDRB R11, [R0,R10] ;//Loads red value
     adds r7, r11
     LDRB R11, [R5,R10] ;//Loads blue value
     adds r8, R11
     LDRB R11, [R6,R10] ;//Loads green value
     adds r12, r11
	n_s_e:

	;//Calculate absolute value
	cmp r7, #0
	blt flip_7_x
	bal skip_flip_7_x
	flip_7_x:
	rsb r7, r7, #0
	skip_flip_7_x:
	cmp r8, #0
	blt flip_8_x
	bal skip_flip_8_x
	flip_8_x:
	rsb r8, r8, #0
	skip_flip_8_x:
	cmp r12, #0
	blt flip_12_x
	bal skip_flip_12_x
	flip_12_x:
	rsb r12, r12, #0
	skip_flip_12_x:

	;//Compute total weight 
	add r12, r12, r8//, lsr #1
	add r12, r12, r7//, lsr #1

     ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output

	;//Check to see if the total is above our horizontal threshold
	cmp r12, #240
	bge pass;//trace_medium
	//cmp r12, #100
	//bge trace_light

	;//==================================================

	mov r7, #0
	mov r8, #0
	mov r12, #0

	;//n
	subs r10, r9, r2	;//Move to north pixel
	blt skip			;//If the pixel is under bounds
     LDRB R11, [R0,R10] 	;//Loads red value
     add r7, r11 		;//Add red to total
     LDRB R11, [R5,R10] 	;//Loads green value
     add r8, r11		;//Add green to total
     LDRB R11, [R6,R10] 	;//Loads blue value
     add r12, r11		;//Add blue to total

	;//n_w
	subs r10, #1
	blt check_n_e		;//If the pixel is under bounds
     LDRB R11, [R0,R10]	;//Loads red value
     add r7, R11
     LDRB R11, [R5,R10] 	;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] 	;//Loads blue value
     add r12, R11

	;//n_e
	check_n_e:
	add r10, #2
	cmp r10, r4
	bge trash;//If the pixel is over bounds
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, R11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, R11
	trash:

	;// Multiplicative property of negative one through reverse subtraction
	rsb r7, r7, #0 
	rsb r8, r8, #0 
	rsb r12, r12, #0 

	;//s
	adds r10, r9, r2
	cmp r10, r4
	bge skip
     LDRB R11, [R0,R10] ;//Loads red value
     add r7, R11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, R11

	;//s_e
	add r10, #1
	cmp r10, r4
	bge check_s_w_2;//If the pixel is over bounds
	LDRB R11, [R0,R10] ;//Loads red value
     add r7, R11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, R11

	;//s_w
	check_s_w_2:
	subs r10, #2
	blt panda;//If the pixel is over bounds
	LDRB R11, [R0,R10] ;//Loads red value
     add r7, r11
     LDRB R11, [R5,R10] ;//Loads green value
     add r8, R11
     LDRB R11, [R6,R10] ;//Loads blue value
     add r12, r11
	panda:

	;//Calculate absolute value
	cmp r7, #0
	blt flip_7_y
	bal skip_flip_7_y
	flip_7_y:
	rsb r7, r7, #0
	skip_flip_7_y:
	cmp r8, #0
	blt flip_8_y
	bal skip_flip_8_y
	flip_8_y:
	rsb r8, r8, #0
	skip_flip_8_y:
	cmp r12, #0
	blt flip_12_y
	bal skip_flip_12_y
	flip_12_y:
	rsb r12, r12, #0
	skip_flip_12_y:

	;//Compute total weight 
	add r12, r12, r8//, lsr #1
	add r12, r12, r7//, lsr #1

     ;//Reset registers
	ADD R5, R0, R4 @R5 is the start of the green plane for input
     ADD R6, R5, R4 @R6 is the start of the blue plane for input
     ADD R7, R1, R4 @R7 is the start of the green plane for output
     ADD R8, R7, R4 @R8 is the start of the blue plane for output

	;//Check to see if the total is above our horizontal threshold
	cmp r12, #240
	bge pass
	//cmp r12, #100
	//bge trace_light
	bal skip;//pass

	;//==================================================

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

	trace_gray:
	mov r5, #220
     STRB R5, [R1,R9] //Store the red value
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

	trace_green:
	mov r5, #255
     STRB R5, [R7,R9] //Store the green value
	mov r5, #0
     STRB R5, [R1,R9] //Store the red value
     STRB R5, [R8,R9] //Store the blue value
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
