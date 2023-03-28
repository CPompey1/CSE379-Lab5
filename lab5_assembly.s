	.data

	.global prompt
	.global mydata
	.global switch_presses_str
	.global key_presses_str
	.global num_1_string
	.global num_2_string


prompt:	.string "Your prompt with instructions is place here", 0
mydata:	.byte	0x20	; This is where you can store data.
			; The .byte assembler directive stores a byte
			; (initialized to 0x20) at the label mydata.
			; Halfwords & Words can be stored using the
			; directives .half & .word
switch_presses_str: 	.string "Switch Presses: ", 0
key_presses_str:  		.string "Key Presses: ", 0
num_1_string: 	.string "Place holder too long", 0
num_2_string:  	.string "Place holder too long", 0


	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global simple_read_character
	.global output_character	; This is from your Lab #4 Library
	.global read_string		; This is from your Lab #4 Library
	.global output_string		; This is from your Lab #4 Library
	.global uart_init		; This is from your Lab #4 Library
	.global lab5

ptr_to_prompt:		.word prompt
ptr_to_mydata:		.word mydata
ptr_to_switch_presses_str:	.word switch_presses_str
ptr_to_key_presses_str:	.word key_presses_str
ptr_to_num_1_string:	.word num_1_string
ptr_to_num_2_string:	.word num_2_string

;***************Data packet orginization*******************************
;	|SwitchPresses	|KeyPresses	|End Flag	|Nothing|
;	0				8			16			24		32
;**********************************************************************
lab5:	; This is your main routine which is called from your C wrapper
	PUSH {lr}   		; Store lr to stack
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_mydata

        bl uart_init
	bl uart_interrupt_init
	bl uart_interrupt_init

	; This is where you should implement a loop, waiting for the user to
	; enter a q, indicating they want to end the program.

	MOV r0,r5
	bl output_string

main_print_data_loop:
	bl print_data
	LDRB r0,[r4,#16]
	cmp r0, #1
	bne main_print_data_loop

	POP {lr}		; Restore lr from the stack
	MOV pc, lr



uart_interrupt_init:

	; Your code to initialize the UART0 interrupt goes here
	;enable UART0 6th bit

	;MUST SET END BIT IF Q IS TYPED


	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.

	;enable interrupt sense register GPIOS
	MOV r0, #0x5404
	MOVT r0, #0x4002
	LDR r1, [r0]
	ORR r1,r1, #16
	STR r1,[r0]

	;Enable interupt direction(s) ;Consider removing this when debugging
	MOV r0, #0x5408
	MOVt r0, #0x4002
	LDR r1, [r0]
	ORR r1,r1,#16
	STR r1,[r0]

	;Enable rising edge interrupt
	MOV r0, #0x540C
	MOVt r0, #0x4002
	LDR r1, [r0]
	ORR r1,r1,#16
	STR r1,[r0]

	;Enable nterrupt GPIOIM
	MOV r0, #0x5410
	MOVt r0, #0x4002
	LDR r1, [r0]
	ORR r1,r1,#16
	STR r1,[r0]

	;Convfigure Procesor to Allow GPIO Port F to interrupt processor
	MOV r0, #0xE100
	MOVt r0, #0xE000
	LDR r1, [r0]
	ORR r1,r1, #1073741824 ;lol 2^30
	STR r1,[r0]

	MOV pc, lr


UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler

	BX lr       	; Return


Switch_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r11}

	;clear interrupt register GPIOICR
	MOV r0, #0x541C
	MOVT r0, #0x4002
	LDR r1,[r0]
	ORR r1, r1,#16
	STR r1, [r0]

	;Incrament switch presses
	ldr r0,ptr_to_mydata
	LDRB r1,[r0];Modify first byte
	ADD r1, r1,#1
	STRB r1,[r0]




	POP {r4-r11}

	BX lr       	; Return


Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed
	; for Lab #5, but will be used in Lab #6.  It is referenced here
	; because the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.

	BX lr       	; Return

;************************************************************************START PRINT DATA************************************************************************
;print_data
;	-prints data loaded in data word block as well as a bar graph
;	- uses no unpreserved registers
print_data:
	;load switch presses
	ldr r0, ptr_to_mydata
	LDRB r1, [r0]

	;Print switch presses
	PUSH {r0,r1}
	ldr r0, ptr_to_switch_presses_str
	bl output_string
	POP {r0,r1}
	PUSH {r0,r1}
	MOV r0,r1
	ldr r1, ptr_to_num_1_string
	bl int2string
	MOV r0,r1
	bl output_string
	POP {r0,r1}

	;Print newline

	PUSH {r0,r1,r2}
	MOV r0, #0x0A
	bl output_character
	PUSH {r0,r1,r2}

	;print carriage return
	PUSH {r0,r1,r2}
	MOV r0, #0x0d
	bl output_character
	PUSH {r0,r1,r2}

	;load key presses
	ldr r0, ptr_to_mydata
	LDRB r1, [r0,#8]

	;Print key presses
	PUSH {r0,r1}
	ldr r0, ptr_to_key_presses_str
	bl output_string
	POP {r0,r1}
	PUSH {r0,r1}
	MOV r0,r1
	ldr r1,ptr_to_num_2_string
	bl int2string
	MOV r0,r1
	bl output_string
	POP {r0,r1}

	;Print newline

	PUSH {r0,r1,r2}
	MOV r0, #0x0A
	bl output_character
	PUSH {r0,r1,r2}

	;print carriage return
	PUSH {r0,r1,r2}
	MOV r0, #0x0d
	bl output_character
	PUSH {r0,r1,r2}




	;Print Bargraph
	;load switch presses
	ldr r0, ptr_to_mydata
	LDRB r1, [r0]
	;For all switchpresses print x's
print_switch_presses_loop:
	PUSH {r0,r1,r2}
	MOV r0, #120
	bl output_character
	POP {r0,r1,r2}
	ADD r1, r1,#-1
	CMP r1, #0
	BNE print_switch_presses_loop

	;Print newline

	PUSH {r0,r1,r2}
	MOV r0, #0x0A
	bl output_character
	PUSH {r0,r1,r2}

	;print carriage return
	PUSH {r0,r1,r2}
	MOV r0, #0x0d
	bl output_character
	PUSH {r0,r1,r2}

	;Load key presses
	ldr r0, ptr_to_mydata
	LDRB r1, [r0,#8]

	;For all keypresses print x's
print_key_presses_loop:
	PUSH {r0,r1,r2}
	MOV r0, #120
	bl output_character
	POP {r0,r1,r2}
	ADD r1, r1, #-1
	CMP r1, #0
	BNE print_key_presses_loop
	;Print newline

	PUSH {r0,r1,r2}
	MOV r0, #0x0A
	bl output_character
	PUSH {r0,r1,r2}

	;print carriage return
	PUSH {r0,r1,r2}
	MOV r0, #0x0d
	bl output_character
	PUSH {r0,r1,r2}





	MOV PC,LR
;************************************************************************END PRINT DATA************************************************************************
simple_read_character:

	MOV PC,LR      	; Return


output_character:

	MOV PC,LR      	; Return


read_string:

	MOV PC,LR      	; Return


output_string:

	MOV PC,LR      	; Return

uart_init:
	MOV PC, LR

;****************************************************************HELPER SUBROUTINES************************************************************************
int2string:
	PUSH {lr}   ; Store register lr on stack

	;Push r0 and r1 before the call to integer_digits
	PUSH {r0,r1}

	;r1 = integer_digits(r0,r1-doesntmatter)
	MOV r1, #0x0
	BL integer_digit

	;Store (numDigits - 1) in r2
	SUB r2, r0, #0x1

	;Pop old r0 & r1 from stack
	POP {r0,r1}

;Integer_digit
;Inputs: r0	- Decimal value
;		 r1 - n place in decimal value to find
;
;Outputs: r0 - nth place digit in decimal value
;		  r1 - number of digits to place
integer_digit:			; Your code for the integer_digit routine goes here.
	PUSH{lr}
	CMP r0, #0
	BEQ ALMOSTFINISH
	cmp r0,#10
	BLT ALMOSTFINISH1
	MOV r2, #10			;10
	MOV r3, #1			 ;Decimal digit counter
	MOV r4, r0			;inital r0 with deciaml place to be shifted


countDigLoop:			;Loop until r4 is shifted to the left most digit

	ADD r3, r3, #1		;Incrament r3
	SDIV r4, r4, r2		;Shift r4 by one decimal place


	CMP r4, #10			;r4 will be at its left most digit when r4 < 10
	BGE countDigLoop

						;Num of decimal digits stored in r3
	PUSH {r0,r1}
	bl nthPlace

	MOV r4, r0
	POP {r0,r1}
	MOV r0, r3
	MOV r1, r4

	b FINISH
ALMOSTFINISH:
	mov r0, #0
	mov r1, #0

ALMOSTFINISH1:
	MOV r1,r0
	MOV r0,#1

FINISH:
	POP {lr}
	MOV pc, lr


nthPlace:				;find the digit in the r1 = nth place of r0(r2 used
	PUSH {lr}
	PUSH {r2,r3,r4}
	MOV r2,r0
	MOV r3,r1


	MOV r0, #10
	bl POW			;r0 = 10^r1(n)


	SDIV r0, r2, r0	;r0 = val/10^n & r1 = n
	MOV r1, #10
	PUSH {r0,r1}			;Store r0 & r1
	bl MOD				; r0 = r0 mod 10
	MOV r2, r0			;Move result from r0 to r2
	POP {r0,r1}			; Get r0 and r1 back


	;r0 = divided val, r1 = 10 , r2 = dvidedVal mod 10

	CMP r2, #0
	BEQ endNthPlaceLoop
	MOV r3, #0
nthPlaceLoop:

	ADD r3, r3, #1
	SUB r0, r0, #1
	push {r0,r1}
	MOV r1, #10
	push {LR}
	BL MOD
	pop {lr}
	MOV r2, r0
	POP {r0,r1}
	CMP r2, #0
	BNE nthPlaceLoop

endNthPlaceLoop:
	MOV r0,r3
	pop {r2,r3,r4}
	pop {lr}
	MOV pc, lr

MOD:					;Take r0 = r0 mod r1		(r0 & r1 as arguments. r2 is used)
	PUSH {lr}
	PUSH {r2}
	SDIV r2, r0, r1		;r2 = floor(r0/r1)
	MUL r1, r1, r2		;r1 = r1 * r2
	SUB r0,	r0, r1,		;r0 = r0 mod r1
	POP {r2}
	POP {lr}
	MOV pc, lr

POW:					;r0 has base, r1 has exponential
	PUSH {lr}
	PUSH {r2}
	MOV r2, #1
	CMP r1, #0		;Stop if the exponential is 0
	BEQ donePow1

powLoop:
					;Push the registers that were used in the subroutine
	MUL r2, r2, r0
	SUB r1, r1, #1
	CMP r1, #0
	BNE powLoop			;Stop if the exponential is 0



donePow1: 				;Pow exit
	MOV r0, r2			;Return stored in r0
	POP {r2}
	POP {lr}
	MOV pc,lr
;****************************************************************END HELPER SUBROUTINES************************************************************************



	.end
