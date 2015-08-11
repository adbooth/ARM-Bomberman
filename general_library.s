    AREA    general_library, CODE, READWRITE
    EXPORT  div_and_mod
    EXPORT  edit_register





; Routine div_and_mod
; Author: ADB
; Calculates quotient and remainder of arg0/arg1
; Leaf routine
; arg0: dividend
; arg1: divisor
div_and_mod
			; Store used registers to stack
			STMFD	sp!, {r2-r12, lr}
			; Comparison initializations
			MOV	 	r2, #0x00					; Initialize arg0NFlag
			; arg0 comparison, negation and flag set
			CMP	 	r0, #0x00					; CPSR := (arg0 compared to 0)
			EORLT   r2, r2, #0x01				; if(arg0 < 0) set arg0NFlag
			RSBLT   r0, r0, #0x00		  		; if(arg0 < 0) negate arg0
			; arg1 comparison, negation and flag set
			CMP	 	r1, #0x00					; CPSR := (arg1 compared to 0)
			EORLT   r2, r2, #0x01		  		; if(arg1 < 0) set arg1NFlag
			RSBLT   r1, r1, #0x00		  		; if(arg1 < 0) negate arg1
			; Calculation initializations
			MOV	 	r5, #0x0F					; Initialize counter to 15
			MOV	 	r6, #0x00					; Initialize quotient to 0
			MOV	 	r1, r1, LSL #0x0F			; Left shift divisor 15 places
			MOV	 	r7, r0						; Remainder := dividend
dam_loop
		   ; Division loop
			SUB	 	r7, r7, r1					; Remainder := remainder - divisor
			MOV	 	r6, r6, LSL #0x01			; Left shift quotient one bit
			CMP	 	r7, #0x00					; CPSR := (remainder compared to 0)
			ADDGE   r6, r6, #0x01		  		; if(remainder >= 0) quotient LSB = 1
			ADDLT   r7, r7, r1					; elseif(remainder < 0) remainder := remainder + divisor
			MOV	 	r1, r1, LSR #0x01			; Right shift divisor one bit
			CMP	 	r5, #0x00					; CPSR := (counter compared to 0)
			BLE	 	dam_done					; if(counter <= 0) branch to `done`
			SUB	 	r5, r5, #0x01				; Decrement counter
			B		dam_loop					; Branch to division loop
dam_done
		   ; Handle signed number flags
			CMP	 	r2, #0x01					; CPSR := (diffFlag compared to 1)
			RSBEQ   r6, r6, #0x00				; if(diffFlag == 1) negate quotient

			; Put quotient and remainder into return registers
			MOV	 r0, r6			  				; Store quotient in r0
			MOV	 r1, r7			   				; Store remainder in r7
			; Prepare for return
			LDMFD   sp!, {r2-r12, lr}			; Load used registers from stack
			BX	  	lr							; Branch to caller
; ret0: quotient
; ret1: remainder





; Routine edit_register
; Author: ADB
; Sets specific bits in address IO0SET without affecting other bits
; Leaf routine
; arg0: Code with bits to edit. Only bits with a 1 in this code will be altered
; arg1: Code with bit targets
; arg4: Address of register to be edited
edit_register
			; Store used registers on stack
			STMFD	sp!, {r2, lr}
			; Sets appropriate bits
			LDR		r2, [r4]				; Load contents of target register
			ORR		r2, r1, r2				; Bitwise OR bit targets with target register
			; Resets appropriate bits
			EOR		r0, r0, r1				; Bitwise XOR edit bits with bit targets
			BIC		r2, r2, r0				; Bit clear. Clear edit bits there were 0 in bit targets
			ORR		r1, r0, r1				; Bitwise-OR par0 with contents of target register
			STR		r2, [r4]				; Store new value into target register
			; Prepare for return
			LDMFD	sp!, {r2, lr}			; Load used registers to stack
			BX		lr						; Branch to caller
; No return arguments or addresses





    END
