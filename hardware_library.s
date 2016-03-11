    AREA    hardware_library, CODE, READWRITE
; EXPORTs
    EXPORT  pin_clear
    EXPORT  RGB_LED
    EXPORT  rgb_set
    EXPORT  seg_pattern_display
    EXPORT  read_push_btns
    EXPORT  display_digit
    EXPORT  LEDs
; Initialization EXPORTs
	EXPORT	GPIO_init
	EXPORT	uart_init
; IMPORTs
	IMPORT	cmp_str




; Bit reverse for led sequence
LEDs_table
			DCD		0x00000000	; 0
			DCD		0x00080000	; 1
			DCD		0x00040000	; 2
			DCD		0x000C0000	; 3
			DCD		0x00020000	; 4
			DCD		0x000A0000	; 5
			DCD		0x00060000	; 6
			DCD		0x000E0000	; 7
			DCD		0x00010000	; 8
			DCD		0x00090000	; 9
			DCD		0x00050000	; 10
			DCD		0x000D0000	; 11
			DCD		0x00030000	; 12
			DCD		0x000B0000	; 13
			DCD		0x00070000	; 14
			DCD		0x000F0000	; 15
			ALIGN

; Decimal conversion to ASCII
read_push_btns_table
			DCD		0x00000030	; 0
			DCD		0x00000031	; 1
			DCD		0x00000032	; 2
			DCD		0x00000033	; 3
			DCD		0x00000034	; 4
			DCD		0x00000035	; 5
			DCD		0x00000036	; 6
			DCD		0x00000037	; 7
			DCD		0x00000038	; 8
			DCD		0x00000039	; 9
			DCD		0x00003031	; 10
			DCD		0x00003131	; 11
			DCD		0x00003231	; 12
			DCD		0x00003331	; 13
			DCD		0x00003431	; 14
			DCD		0x00003531	; 15
			ALIGN

; Lookup table for codes to display hex digits on seven segment
display_digit_table
			DCD		0x00001F80	; 0
			DCD		0x00000300	; 1
			DCD		0x00002D80	; 2
			DCD		0x00002780	; 3
			DCD		0x00003300	; 4
			DCD		0x00003680	; 5
			DCD		0x00003E80	; 6
			DCD		0x00000380	; 7
			DCD		0x00003F80	; 8
			DCD		0x00003780	; 9
			DCD		0x00003B80	; A
			DCD		0x00003E00	; B
			DCD		0x00001C80	; C
			DCD		0x00002F00	; D
			DCD		0x00003C80	; E
			DCD		0x00003880	; F
			ALIGN

; Lookup table for codes to display colors on the RGB LED
color_chars_table
			DCD		0x00000077	; white
			DCD		0x00000063	; cyan
			DCD		0x00000079	; yellow
			DCD		0x00000067	; green
			DCD		0x00000070	; purple
			DCD		0x00000062	; blue
			DCD		0x00000072	; red
			DCD		0x0000006F	; off
			ALIGN


; ##### GPIO_init addresses
; Pin Connect Block addresses
PINSEL0     EQU 0xE002C000
PINSEL1     EQU 0xE002C004
; GPIO Direction Register addresses
IO0DIR      EQU 0xE0028008
IO1DIR      EQU 0xE0028018
; GPIO Output Set Register addresses
IO0SET      EQU 0xE0028004
IO1SET      EQU 0xE0028014
; GPIO Output Clear Register addresses
IO0CLR      EQU 0xE002800C
IO1CLR      EQU 0xE002801C
; GPIO Port Pin Value Register addresses
IO0PIN      EQU 0xE0028000
IO1PIN      EQU 0xE0028010
; ##### GPIO_init codes
; GPIO pinsel0 code
PINSEL0_code	EQU 0x00000005
; GPIO port direction code
IO0DIR_code	EQU 0x00263F80
IO1DIR_code	EQU 0x000F0000

; ##### uart_init addresses
UART0_address	EQU	0xE000C000



; Takes users button inputs and displays decimal equivalent in UART
; Author: MH
; No input arguments
; Leaf routine
; Deletes whatever is in r0
read_push_btns
			STMFD	SP!, {r1-r12,lr}
			LDR		r7, =LEDs_table			; Load LEDs_table table address into r7
			LDR		r6, =read_push_btns_table			; Load read_push_btns_table table address into r6
			LDR		r5, =IO1PIN				; Load IO1PIN address into r5
			LDR		r0, [r5]				; Load value of IO1PIN register
			AND		r0, r0, #0x00F00000		; Mask it to just work with bits 20-23
			MVN		r0, r0					; Take 1s compliment
			LSR		r0, r0, #20				; Logical shift right 20 so value is in least significant bit
			AND		r0, r0,	#0x0000000F		; Mask out Fs from 1s compliment
			LDR		r1, [r7, r0, LSL #2]	; Load reversed bit sequence from LEDs_table table
			LSR		r1, r1, #16				; Logical shift right 16 bits so value is in least significant bits
			MOV		r0, r1
			LDMFD 	SP!, {r1-r12,lr}		; Restore register lr from stack
			BX		lr						; Loop back to start
; Returns decimal equivalent of what was on the board in r0





; Routine display_digit
; Author: ADB
; Displays a hex value on the seven segment display based on the value of arg0
; Calls seg_pattern_display
; arg0: value to be displayed on seven segment display
display_digit
			STMFD   sp!, {r0, r1, lr}
			; Get the right digit pattern code by using paramter 0 as an offset
			LDR	 r1, =display_digit_table			; Put base address of digit pattern codes into base register
			LDR	 r0, [r1, r0, LSL #2]		; Load digit pattern code into arg0 offset by par0. The 2-bit left shift is to move 4 bytes at a time
			BL	  seg_pattern_display		; Call seg_pattern_display
			; Prepare for return
			LDMFD   sp!, {r0, r1, lr}			; Load used registers from stack
			BX	  lr						; Branch to caller
; No return arguments

	



; Routine that takes user input 0-15 and displays binary value on the on board leds
; Author: MH
; Takes a decimal number 0-15 as input argument
; Leaf routine
; No input arguments or addresses
; TODO check if order of set and clr matter
LEDs
			STMFD	SP!, {r1-r12,lr}
			LDR		r5, =IO1SET				; Load IO1SET address to r5
			LDR		r4, =LEDs_table			; Load LEDs_table table address
			LDR		r6, =IO1CLR				; Load IO1CLR address into r5
			LDR		r1, [r4, r0, LSL #2]	; Load value at r4 with offset of user input into r1
			STR		r1, [r6]				; Store r1 into IO1CLR
			MVN		r1, r1					; Take 1s compliment
			STR		r1, [r5]				; Store r1 into IO1SET
			LDMFD 	SP!, {r1-r12,lr}		; Restore register lr from stack
			BX		lr						; Loop back to start
; No return arguments or addresses





; Routine pin_clear
; Author: ADB & MTH
; Clears outputs
; Leaf routine
; No input arguments or addresses
pin_clear
			STMFD	sp!, {r0, r1, lr}
			; Turn off active HIGH outputs for IO0
			LDR		r1, =IO0CLR
			LDR		r0, =0x00003F80
			STR		r0, [r1]

			; Turn off active LOW outputs for IO0
			LDR		r1, =IO0SET
			LDR		r0, =0x00260000
			STR		r0, [r1]
			
			; Turn off active LOW outputs for IO1
			LDR		r1, =IO1SET
			LDR		r0, =0x000F0000
			STR		r0, [r1]
			; Return to caller
			LDMFD	sp!, {r0, r1, lr}
			BX		lr
; No return arguments or addresses





; Routine RGB_LED
; Author: ADB
; Sets RGB LED color based on arg4
; Calls rgb_set and cmp_str
; arg4: base address of string representing color to be displayed
RGB_LED
			STMFD	sp!, {r1, r5, lr}
			; Initialize counters
			MOV		r1, #0					; Initialize loop counter
			LDR		r5, =color_chars_table	; Initialize table counter
rm_loop
			; Repeatedly compare input string and stored strings, continue if equal
			CMP		r1, #8					; CPSR := compare(counter, 8)
			LDMFDGE	sp!, {r1, r5, lr}		; if(counter >= 8) load used registers from stack
			BXGE	lr						; if(counter >= 8) branch to caller
			BL		cmp_str					; Compare strings
			CMP		r0, #0					; CPSR should get equal if strings are equal
			ADDNE	r5, r5, #4				; if(strings not equal) increment table counter
			ADDNE	r1, r1, #1				; if(strings not equal) increment loop counter
			BNE		rm_loop					; if(strings not equal) loop
			MOV		r0, r1					; Copy counter to arg0
			BL		rgb_set					; Call rgb_set
			; Prepare for return
			LDMFD	sp!, {r1, r5, lr}		; Load used registers from stack
			BX		lr						; Branch to caller
; No return arguments


; Routine rgb_set
; Author: ADB
; Sets the RGB LED color based on arg0.
; Leaf routine
; Since there are three colors to change (red, green, blue), there are 8 (2^3) possible colors
; arg0: color code of desired color
; The codes for each color are as follows:
; 0: white
; 1: cyan
; 2: yellow
; 3: green
; 4: purple
; 5: blue
; 6: red
; 7: off
rgb_set
			STMFD	sp!, {r0, r1, lr}
			; Test bit 2
			MOV		r1, #0x04
			AND		r1, r0, r1				; Mask arg0 for bit 2
			; If bit 2 is set, reset bit 2 and set bit 4
			CMP		r1, #0x04				; CPSR := CMP(masked argument, 0x04)
			BICEQ	r0, r0, #0x04			; if(masked arg == 0x04) clear bit 2
			ORREQ	r0, r0, #0x10			; if(masked arg == 0x04) set bit 4
			; Left shift until in the proper argument positions (17 bits)
			LSL		r0, r0, #17
			; Load code into set and clear registers
			AND		r0, r0, #0x00260000
			LDR		r1, =IO0SET				; Load IO0SET register address
			STR		r0, [r1]				; Store code into IO0SET register
			MVN		r0, r0					; Take one's complement of code
			AND		r0, r0, #0x00260000
			LDR		r1, =IO0CLR				; Load IO0CLR register address
			STR		r0, [r1]				; Store code into IO0CLR address
			; Prepare for return
			LDMFD	sp!, {r0, r1, lr}			; Load used registers from stack
			BX		lr						; Branch to caller
; No return arguments





; Routine seg_pattern_display
; Author: ADB
; Displays a pattern on the seven segment display based on the code of arg0
; Leaf routine
; arg0: pattern code for segments to be set
seg_pattern_display
			STMFD   sp!, {r1, lr}
			; Set segments that should be lit to HIGH
			LDR	 	r1, =IO0SET				; Put address of IO0SET register into address register
			STR	 	r0, [r1]				; Store par0 in memory at address of IO0SET
			; Set segments that should be off to LOW
			MOV		r1, #0x3F80				; Move ones-complement of par0 into ret0
			EOR		r0, r0, r1
			LDR	 	r1, =IO0CLR				; Put address of IO0CLR register into address register
			STR	 	r0, [r1]				; Store ones-complement of par0 at address of IO0CLR
			; Prepare for return
			LDMFD   sp!, {r1, lr}			; Load used registers from stack
			BX	  	lr						; Branch to caller
; No return arguments





; ###############################################
; Here start the hardware initialization routines
; ###############################################


; Routine GPIO_init
; Author: ADB & MH
; Sets up the pin select block and GPIO direction registers for use with the 7 segment display, RGB LED, buttons and LEDs
; Leaf routine
; No input arguments or addresses
GPIO_init
			; Store used registers on stack
			STMFD	sp!, {r0, r1, lr}
			; Store PINSEL0_code in pin select block register
			LDR		r1, =PINSEL0			
			LDR		r0, =PINSEL0_code         
			STR		r0, [r1]				
			; Store IO0DIR_code in GPIO port 0 direction register
			LDR		r1, =IO0DIR				
			LDR		r0, =IO0DIR_code         
			STR		r0, [r1]			
			; Store IO1DIR_code in GPIO port 1 direction register
			LDR		r1, =IO1DIR				; Load IO1DIR address
			MOV		r0, #0x000F0000			; Load IO1DIR code
			STR		r0, [r1]				; Store IO1DIR code in IO1DIR
			; Clear outputs
			BL		pin_clear
			; Prepare for return
			LDMFD 	sp!, {r0, r1, lr}		; Load used registers from stack
			BX		lr						; Branch to caller
; No return arguments or addresses





; Routine uart_init
; Author: MH & ADB
; Prepares uart for operation
; Leaf routine
; No input arguments or addresses
uart_init
			; Store used registers to stack
			STMFD	sp!, {r0, r1, lr}
			; Load base address into r1
			LDR	 r1, =UART0_address
			; Unlatch
			MOV		r0, #131				; Move 131 into r0
			STR		r0, [r1, #0xC]			; Store r0 into r1 with offset of 0xC
			; Change contents held at base address
			MOV		r0, #3					; Move 3 into r0. This puts it at a baud rate of 384000
			STR		r0, [r1] 				; Store r0 into r1
			; Change contents held at base address + 4
			MOV		r0, #0					; Move 0 into r0
			STR		r0, [r1, #0x4]			; Store r0 into r1 with offset of 4
			; Relatch
			MOV		r0, #3					; Move 3 into r0
			STR		r0, [r1, #0xC]			; Store r0 into r1 with offset of 0xC
			; Prepare to return
			LDMFD	sp!, {r0, r1, lr}		; Load used registers from stack
			BX		lr						; Branch to caller
; No return arguments or addresses





    END
