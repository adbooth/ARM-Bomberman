    AREA    string_library, CODE, READWRITE
; EXPORTs
    EXPORT  cmp_str
    EXPORT  numberString_to_int
    EXPORT  int_to_numberString
    EXPORT  newline
    EXPORT  output_character
    EXPORT  output_string
    EXPORT  println
    EXPORT  prompt
    EXPORT  read_character
    EXPORT  read_string
    EXPORT  reverse_string
	EXPORT	set_figs
	EXPORT	store_string
    EXPORT  string_length
; IMPORTs
	IMPORT	div_and_mod




; Allocate 16 bytes in memory for values input to int_to_numberString
int_to_ASCII_number_mem
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            ALIGN

; Allocate 16 bytes in memory for strings input to read_string
read_string_mem
			DCD		0x00000000
			DCD		0x00000000
			DCD		0x00000000
			DCD		0x00000000
			ALIGN

; Allocate 16 bytes in memory for strings input to reverse_string
reverse_string_mem
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            ALIGN

set_figs_mem
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            DCD     0x00000000
            ALIGN

; UART0 addresses
U0THR       EQU 	0xE000C000  ; UART0 buffer
U0LSR       EQU 	0xE000C014  ; UART0 Line Status Register



; Routine cmp_str
; Author: MH
; Compares two strings
; Leaf routine
; arg4: base address of first string to be compared
; arg5: base address of second string to be compared
cmp_str
			; Store used registers to stack
			STMFD	sp!, {r4, r5, r10, r11, r12, lr}
			MOV		r12, #0					; Initialize offset to 0
			MOV		r0, #0					; Clear r0
cs_loop
			LDRB	r10, [r4, r12]			; Load value at r4 with offset of r12 into r10
			LDRB	r11, [r5, r12]			; Load value at r5 with offset of r12 into r11
			CMP		r10, #0x00				; Check if r10 is NULL terminator
			BEQ		cs_done					; If it is, branch to cdone
			CMP		r11, #0x00				; Check if r11 is NULL terminator
			BEQ		cs_done					; If it is, branch to cdone
			CMP		r10, r11				; Compare current characters
			MOVNE	r0, #1					; If they are not the same, set flag to 1
			BNE		cs_done					; If they are not the same, branch to cdone
			ADD		r12, r12, #1			; If the are the same, increment offset
			B		cs_loop					; Branch back to cloop
cs_done
			; Prepare for return
			LDMFD	sp!, {r4, r5, r10, r11, r12, lr}; Load used registers from stack
			BX		lr						; Branch to caller
; ret0: flag indicating sameness of strings; 0 if strings are equal, 1 otherwise
; ret4: arg4
; ret5: arg5





; Routine numberString_to_int
; Author: MH
; Converts decimal string to number
; Leaf routine
; arg4: base address of string to be converted
numberString_to_int
			; Store used registers to stack
			STMFD	sp!, {r1, r4, r5, r10, r11, r12, lr}
			MOV		r0, #0
			LDRB	r1, [r4]				; Load first byte of string from memory to r1
			MOV		r12, #0
			ADD		r12, r12, #1			; Increment memory pointer by 1
			CMP		r1, #'-'				; Compare r1 to ASCII '-'
			MOVEQ	r10, #1					; If equal, number is negative, set flag to 1
			MOVNE	r10, #0					; If not equal, number is positive keep flag at 0
			MOV		r5, #0					; clear r5
			SUBGT	r5, r1, #'0'			; If r1 > 0x2D, r1 is a number, subtract 0x30 to get decimal value
			MOV		r11, #10				; Move 10 into r11 for decimal shift
ic_loop
			LDRB	r1, [r4, r12]			; Load next byte to r1
			ADD		r12, r12, #1			; Increment memory pointer
			CMP		r1, #0x00				; Check for ASCII 'NULL'
			BEQ		ic_done					; If 'NULL' branch to primality
			SUB		r1, r1, #'0'			; Subtract 0x30 to get decimal value
			MUL		r6, r5, r11				; Multiply r5 by 10 and temporarily store in r6
			MOV		r5, r6 					; Move back into r5
			ADD		r5, r5, r1				; Add r1 to r5
			B		ic_loop					; Branch back to pool
ic_done
			CMP		r10, #1					; Check if input is negative
			RSBEQ	r5, r5, #0				; If it is negative, subtract from 0
			MOV		r0, r5					; Move number into r0 to be output argument
			; Prepare for return
			LDMFD	sp!, {r1, r4, r5, r10, r11, r12, lr}	; Load used registers from stack
			BX		lr						; Branch to caller
; ret0: value of input string
; ret4: arg4





; Routine int_to_numberString
; Author: ADB
; Returns string representing value of number passed into arg0
; Calls: reverse_string
; arg0: value to be turned into ASCII string
int_to_numberString
        STMFD   sp!, {r0, r1, lr}
        ; Divide by ten, store remainder in ASCII, repeat
        LDR     r4, =int_to_ASCII_number_mem
itAn_loop
        MOV     r1, #10
        BL      div_and_mod
        ADD     r1, r1, #'0'
        STRB    r1, [r4], #1
        CMP     r0, #0
        BNE     itAn_loop
		; Add null to end
		MOV		r1, #0x00
		STRB	r1, [r4]
        ; Reverse string for answer
        LDR     r4, =int_to_ASCII_number_mem
        BL      reverse_string
        ; Return to caller
        LDMFD   sp!, {r0, r1, lr}
        BX      lr
; ret0: arg0
; ret4: base address of constructed string





; Routine newline
; Author: ADB
; Prints a line feed and carriage return to move text to next line
; Calls output_character
; No input arguments or addresses
newline
			; Store used registers to stack
			STMFD	sp!, {r0, lr}
			; Output line feed and carriage return
			MOV		r0, #0x0A
			BL		output_character		; Output line feed
			MOV		r0, #0x0D
			BL		output_character		; Output carriage return
			; Prepare for return
			LDMFD	sp!, {r0, lr}			; Load used registers from stack
			BX		lr						; Branch to caller
; No return arguments or addresses





; Routine output_character
; Author: ADB
; Transmits a character through the UART from the caller passed into r0
; Leaf routine
; arg0: ASCII value of character to be output
output_character
			; Store used registers to stack
			STMFD	sp!, {r0, r1, r2, r3, lr}
			; Set up register addresses
			LDR		r2, =U0THR				; r2 := buffer address
			LDR		r3, =U0LSR				; r3 := LSR address
oc_loop
			; Check the THRE bit in the LSR for emptiness
			LDRB	r1, [r3]				; r1 := contents of LSR
			AND		r1, r1, #0x20			; r1 := AND(LSR, 0x20)	//Masking the LSR with the value 32 to get the THRE bit
			CMP		r1, #0x20				; CPSR := CMP(masked value, 0x20)
			BNE		oc_loop					; if(masked value != 0x20) branch to outputloop	//Loop until flag is 1 which means register is empty
			; Once the THRE bit is 1, transmit the passed argument through the UART by storing the contents of r0
			STRB 	r0, [r2]				; buffer := passed value from r0
			; Prepare for return
			LDMFD	sp!, {r0, r1, r2, r3, lr}	; Load used registers from stack
			BX		lr						; Branch to caller
; ret0: arg0





; Routine output_string
; Author: ADB
; Outputs a string through the UART
; Calls output_character
; arg4: base address of string to be output
output_string
			; Store used registers to stack
			STMFD	sp!, {r0, r1, r4, lr}
			MOV		r1, #0					; Initialize offset pointer
os_loop
			LDRB	r0, [r4, r1]			; Load data in address into r0
			CMP		r0, #0x00				; Check if 'NULL' reached
			BEQ		os_done					; If 'NULL', exit loop
			BL		output_character		; Output character
			ADD		r1, r1, #1				; Increment offset pointer
			B		os_loop					; Loop for next character
os_done
			; Prepare for return
			LDMFD	sp!, {r0, r1, r4, lr}		; Load used registers from stack
			BX		lr						; Branch to caller
; ret4: arg4





; Routine println
; Author: ADB
; Prints string held in arg4 and then a newline
; Calls output_string and newline
; arg4: base address of string to be printed
println
		STMFD	sp!, {lr}
		BL		output_string
		BL		newline
		LDMFD	sp!, {lr}
		BX		lr
; ret4: arg4





; Routine prompt
; Author: ADB
; Prints prompt held in arg4 and returns user input string into ret4
; Calls output_string, read_string and newline
; arg4: base address of prompt for user
prompt
		STMFD	sp!, {lr}
		BL		output_string
		BL		read_string
		BL		newline
		LDMFD	sp!, {lr}
		BX		lr
; ret4: base address of user input string





; Routine read_character
; Author: MH
; Reads a character from the UART and returns it into ret0
; Leaf routine
; No input arguments or addresses
read_character
			; Store used registers to stack
			STMFD	sp!, {r3, r4, r10, r11, lr}
			; Set up register addresses
			LDR		r10, =U0THR				; r10 := buffer address
			LDR		r11, =U0LSR				; r11 := LSR address
rc_loop
			; Check the RDR bit in the LSR for readiness
			LDR		r3, [r11]				; r3 := contents of the LSR
			AND		r4, r3, #0x01			; r4 := AND(LSR, 0x01)	//Masking the LSR with the value 1 to get the RDR bit
			CMP		r4, #0x01				; CPSR := CMP(masked value, 0x01)
			BNE		rc_loop					; if(masked value != 0x01) branch to readloop	//Loop until flag is 1 which means register is ready
			; Once the RDR bit is 1, take the contents of the buffer into r0 and return
			LDRB	r0, [r10]				; r0 := contents of buffer
			; Prepare for return
			LDMFD	sp!, {r3, r4, r10, r11, lr}		; Load used registers from stack
			BX		lr						; Branch to caller
; ret0: ASCII value of character that was input





; Routine read_string
; Author: MH
; Reads a string from the user and stores it in memory
; Calls read_character
; No input arguments or addresses
read_string
			; Store used registers to stack
			STMFD	sp!, {r0, r2, lr}
			LDR		r4, =read_string_mem		; r1 := string pointer address
			MOV		r2, #0					; Initialize pointer to 0
rs_loop
			BL 		read_character			; Get char from user into r0
			BL		output_character		; Output chars as they are typed in
			STRB	r0, [r4, r2]			; Store char in r0 into memory at read_string_mem
			ADD		r2, r2, #1				; Increment pointer
			CMP		r0, #0x0D				; CPSR := CMP(char, carriage return)	//Compare char to carriage return
			BNE		rs_loop					; if(char != carriage return) branch to read_string	//Loop until char is carriage return
			MOV		r0, #0x00				; r0 := NULL
			SUB		r2, r2, #1				; Decrement counter
			STRB	r0, [r4, r2]			; Store NULL in place of carriage return
			; Prepare for return
			LDMFD	sp!, {r0, r2, lr}; Load used registers from stack
			BX 		lr					  ; Branch to caller
; ret4: base address of string that was input





; Routine reverse_string
; Author: ADB
; Returns string as reverse of string passed into arg4
; Calls: string_length
; arg4: base address of string to be reversed
reverse_string
        STMFD   sp!, {r0, r1, r5, lr}
        BL      string_length           ; Get length of string
		SUB		r0, r0, #1
        ; Loop backwards through string and move ASCII values to new address in reverse order
        LDR     r5, =reverse_string_mem
rv_loop
        LDRB    r1, [r4, r0]            ; Get ASCII value of char from string
        STRB    r1, [r5], #1            ; Store ASCII value of char and increment address
        CMP     r0, #0                  ; Compare counter to 0
        SUB     r0, r0, #1              ; Decrement counter
        BNE     rv_loop                 ; if(counter != 0) branch to rs_loop
        ; Add NULL char to end
        MOV     r0, #0x00
        STRB    r0, [r5]
        ; Return address of new string in r4
        LDR     r4, =reverse_string_mem
        ; Return to caller
        LDMFD   sp!, {r0, r1, r5, lr}
        BX      lr
; ret4: base address of reversed string





; Routine set_figs
; Makes a numberString a certain number of characters long by adding zeroes to the front
; Author: ADB
; Calls:
; arg0: desired number of digits
; arg4: numberString to be edited
set_figs
		STMFD	sp!, {r0, r1, r5, lr}
		; Move target length to r1 and get current length of string
		MOV		r1, r0
		BL		string_length
		CMP		r0, r1					; CPSR := CMP(string length, target length)
		BGT		sf_done					; if(string length > target length) branch to sf_done
		LDR		r5, =set_figs_mem
sf_loop
		MOV		r2, #'0'
		CMP		r0, r1					; CPSR := CMP(string length, counter)
		LDRBGE	r2, [r4], #1			; if(string length >= counter)
		STRB	r2, [r5], #1
		SUB		r1, r1, #1
		CMP		r1, #0
		BNE		sf_loop
		; Move ASCII NULL to end of string
		MOV		r2, #0x00
		STRB	r2, [r5]
		; Move address to ret0
		LDR		r4, =set_figs_mem
sf_done
		; Return to caller
		LDMFD	sp!, {r0, r1, r5, lr}
		BX		lr
; ret0: arg0
; ret4: base address of edited string





; Routine store_string
; Stores a string passed whose base address is passed through r4 into an array whose base address is passed through r5
; Author: ADB
; Leaf routine
; arg4: base address of string to be stored
; arg5: base address of location in memory to be stored to
store_string
		STMFD	sp!, {r0, r4, r5, lr}
ss_loop
		LDRB	r0, [r4], #1
		STRB	r0,	[r5], #1
		CMP		r0, #0x00
		BNE		ss_loop
		; Return to caller
		LDMFD	sp!, {r0, r4, r5, lr}
		BX		lr
; ret4: arg4
; ret5: arg5





; Routine string_length
; Returns character length of a string, discluding terminating NULL character
; Author: ADB
; Leaf routine
; arg4: base address of string to be analyzed
string_length
        STMFD   sp!, {r1, r4, lr}
        ; Loop and increment counter untill NULL is encountered
        MOV     r0, #0                  ; Initialize counter
sl_loop
        LDRB    r1, [r4, r0]            ; Get ASCII value of char from string
        CMP     r1, #0x00               ; Compare to NULL
        ADDNE   r0, r0, #1              ; Increment counter if not NULL
        BNE     sl_loop                 ; Loop if not NULL
        ; Return to caller
        LDMFD   sp!, {r1, r4, lr}
        BX      lr
; ret0: length of string passed into par4
; ret4: arg4





    END
