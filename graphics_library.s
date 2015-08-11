	AREA	graphics_library, CODE, READWRITE
; EXPORTs
	EXPORT	brick_setup
	EXPORT	change_character
	EXPORT	change_score_value
	EXPORT	change_time_value
	EXPORT	check_location
	EXPORT	clear_screen
	EXPORT	cursor_position
	EXPORT	cursor_down
	EXPORT	cursor_left
	EXPORT	cursor_right
	EXPORT	cursor_up
	EXPORT	draw_board
	EXPORT	draw_bomberman
	EXPORT	draw_on_board
	EXPORT	edit_array
	EXPORT	populate_array
	EXPORT	read_array
; IMPORTs
	IMPORT	output_character
	IMPORT	int_to_numberString
	IMPORT	output_string
	IMPORT	set_figs
	IMPORT	println
	IMPORT	store_string
	IMPORT	div_and_mod
	IMPORT	get_rand





title = 	"       Bomberman         ",0x00
			ALIGN
HUD = 		"Time:120       Score:0000",0x00
			ALIGN
edge =		"ZZZZZZZZZZZZZZZZZZZZZZZZZ",0x00
			ALIGN
row =		"Z                       Z",0x00
			ALIGN
zRow =		"Z Z Z Z Z Z Z Z Z Z Z Z Z",0x00
			ALIGN


vec_0		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN

vec_1		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_2		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_3		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_4		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_5		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_6		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_7		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_8		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_9		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_10		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_11		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_12		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_13		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN
vec_14		DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			DCD	0x00000000
			ALIGN


array_base	DCD	vec_0
			DCD	vec_1
			DCD	vec_2
			DCD	vec_3
			DCD	vec_4
			DCD	vec_5
			DCD	vec_6
			DCD	vec_7
			DCD	vec_8
			DCD	vec_9
			DCD	vec_10
			DCD	vec_11
			DCD	vec_12
			DCD	vec_13
			DCD	vec_14






clear_chars = 	0x1B,"[2J",0
			ALIGN
cursor_up_string =	0x1B,"[1A",0
			ALIGN
cursor_down_string =	0x1B,"[1B",0
			ALIGN
cursor_right_string =	0x1B,"[1C",0
			ALIGN
cursor_left_string =	0x1B,"[1D",0
			ALIGN





; Routine brick_setup
; Fills already populated array with bricks ('#') and displays them on the board
; Author: ADB
; Calls: get_rand
; arg0: number of bricks to be added
brick_setup
			STMFD	sp!, {r0-r3, r10, r11, lr}
			; Move brick amount out of the way to r10 and initialize counter in r11 to 1
			MOV		r2, #'#'
			MOV		r10, r0
			MOV		r11, #1
bs_loop
			; Pick random row
			MOV		r0, #11
			BL		get_rand
			; Decide what do based on row index
			MOV		r1, r0
			CMP		r0, #0
			BEQ		bs_first_short_row
			CMP		r0, #2
			BLE		bs_other_short_rows
			; For all normal rows, pick number between 0 and 22 and check location for brick or player
bs_normal_loop
			MOV		r0, #23
			BL		get_rand
			MOV		r3, r0
			BL		check_location
			CMP		r0, #0
			BEQ		bs_normal_loop
			B		loop_check
bs_first_short_row
			MOV		r0, #20
			BL		get_rand
			ADD		r0, r0, #3
			MOV		r3, r0
			BL		check_location
			CMP		r0, #0
			BEQ		bs_first_short_row
			B		loop_check
bs_other_short_rows
			MOV		r0, #22
			BL		get_rand
			ADD		r0, r0, #1
			MOV		r3, r0
			BL		check_location
			CMP		r0, #0
			BEQ		bs_other_short_rows
loop_check
			MOV		r0, r3
			BL		draw_on_board
			BL		edit_array
			CMP		r10, r11
			ADD		r11, r11, #1
			BNE		bs_loop
			; Return to caller
			LDMFD	sp!, {r0-r3, r10, r11, lr}
			BX		lr
; No return arguments or addresses





; Routine change_character
; Changes a character at position x,y
; Author: ADB
; Calls: cursor_position, output_character
; arg0: x position of character to be changed
; arg1: y position of character to be changed
; arg2: ASCII value of character to be output
change_character
			STMFD	sp!, {r0, r1, r2, lr}
			BL		cursor_position
			MOV		r0, r2
			BL		output_character
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, lr}
			BX		lr
; ret0: arg0
; ret1: arg1
; ret2: arg2





; Routine change_score_value
; Changes the value of the score field on the HUD
; Author: ADB
; Calls: cursor_position, int_to_numberString, set_figs, output_string
; arg0: value to change the score to
change_score_value
			STMFD	sp!, {r0, r1, r2, lr}
			; Store par0 in r2
			MOV		r2, r0
			; Move cursor to time location
			MOV		r0, #22
			MOV		r1, #2
			BL		cursor_position
			; Turn par0 into ASCII numberString and output
			MOV		r0, r2
			BL		int_to_numberString
			MOV		r0, #4
			BL		set_figs
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, lr}
			BX		lr
; ret0: arg0





; Routine change_time_value
; Changes the value of the time field on the HUD
; Author: ADB
; Calls: cursor_position, int_to_numberString, set_figs, output_string
; arg0: value to change the time to
change_time_value
			STMFD	sp!, {r0, r1, r2, lr}
			; Store par0 in r2
			MOV		r2, r0
			; Move cursor to time location
			MOV		r0, #6
			MOV		r1, #2
			BL		cursor_position
			; Turn par0 into ASCII numberString and output
			MOV		r0, r2
			BL		int_to_numberString
			MOV		r0, #3
			BL		set_figs
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, lr}
			BX		lr
; ret0: arg0


; Routine check_location
; Returns 1 if location is clear, 0 otherwise
; Author: ADB
; Calls: read_array
; arg0: x value of location of interest
; arg1: y value of location of interest
check_location
			STMFD	sp!, {r1, lr}
			; Get outputs and compare to space
			BL		read_array
			CMP		r0, #' '
			; Set return flag depending on comparison
			MOVEQ	r0, #1
			MOVNE	r0, #0
			; Return to caller
			LDMFD	sp!, {r1, lr}
			BX		lr
; ret0: arg0


; Routine clear_screen
; Clears the screen and moves cursor to 0 position
; Author: ADB & MTH
; Calls: output_string, cursor_position
; No input arguments or addresses
clear_screen
			STMFD	sp!, {r0, r1, r4, lr}
			LDR		r4, =clear_chars
			BL		output_string
			MOV		r0, #0
			MOV		r1, #0
			BL		cursor_position		
			; Return to caller
			LDMFD	sp!, {r0, r1, r4, lr}
			BX		lr
; No output arguments or addresses


; Routine cursor_position
; Moves the cursor to a location on screen
; Author: ADB
; Calls: output_character, int_to_numberString
; arg0: x position on screen
; arg1: y position on screen
cursor_position
			STMFD	sp!, {r0, r1, r2, r4, lr}
			MOV		r2, r0
			; Output escape character and left bracket character
			MOV		r0, #0x1B
			BL		output_character
			MOV		r0, #'['
			BL		output_character
			; Output y value as ASCII characters
			MOV		r0, r1
			BL		int_to_numberString
cp_yloop	
 			LDRB	r0, [r4], #1
			CMP		r0, #0x00
			BLNE	output_character
			CMP		r0, #0x00
			BNE		cp_yloop
			; Output separating semicolon
			MOV		r0, #';'
			BL		output_character
			; Output x value as ASCII characters
			MOV		r0, r2
			BL		int_to_numberString
cp_xloop	
			LDRB	r0, [r4], #1
			CMP		r0, #0x00
			BLNE	output_character
			CMP		r0, #0x00
			BNE		cp_xloop
			; Output terminating capital 'H'
			MOV		r0, #'H'
			BL		output_character
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, r4, lr}
			BX		lr
; ret0: arg0
; ret1: arg1





; Routine cursor_down
; Moves the cursor down one row
; Author: ADB
; Calls: output_string
; No input values of addresses
cursor_down
			STMFD	sp!, {r4, lr}
			LDR		r4, =cursor_down_string
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r4, lr}
			BX		lr
; No output values or addresses





; Routine cursor_left
; Moves the cursor left one column
; Author: ADB
; Calls: output_string
; No input values of addresses
cursor_left
			STMFD	sp!, {r4, lr}
			LDR		r4, =cursor_left_string
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r4, lr}
			BX		lr
; No output values or addresses





; Routine cursor_right
; Moves the cursor right one column
; Author: ADB
; Calls: output_string
; No input values of addresses
cursor_right
			STMFD	sp!, {r4, lr}
			LDR		r4, =cursor_right_string
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r4, lr}
			BX		lr
; No output values or addresses





; Routine cursor_up
; Moves the cursor up one row
; Author: ADB
; Calls: output_string
; No input values of addresses
cursor_up
			STMFD	sp!, {r4, lr}
			LDR		r4, =cursor_up_string
			BL		output_string
			; Return to caller
			LDMFD	sp!, {r4, lr}
			BX		lr
; No output values or addresses





; Routine draw_board
; Draws initial board outline
; Author: ADB
; Calls: output_character, println
; No input values or addresses
draw_board
			STMFD	sp!, {r0, r4, lr}
			; Clear screen
			MOV		r0, #0x0C
			BL		output_character
			; Output tile and HUD
			LDR		r4, =title
			BL		println
			LDR		r4, =HUD
			BL		println
			; Output top edge
			LDR		r4, =edge
			BL		println
			; Loop and output blank rows
			LDR		r5, =row
			LDR		r6, =zRow
			MOV		r2, #0				; Initialize counter
db_loop
			MOV		r0, r2
			MOV		r1, #2
			BL		div_and_mod
			CMP		r1, #0
			MOVEQ	r4, r5
			MOVNE	r4, r6
			BL		println
			CMP		r2, #10
			ADD		r2, r2, #1
			BNE		db_loop
			; Output bottom edge
			LDR		r4, =edge
			BL		println
			; Print bomberman
			MOV		r0, #0
			MOV		r1, #0
			MOV		r2, #'B'
			BL		draw_on_board
			; Return to caller
			LDMFD	sp!, {r0, r4, lr}
			BX		lr
; No output values or addresses




; Routine draw_bomberman
; Draws bomberman depending on arg0 & arg1
; Author: ADB
; arg0: x value of bomberman
; arg1: y value of bomberman
draw_bomberman
			STMFD	sp!, {r0, r1, r2, lr}
			MOV		r2, #'B'
			BL		draw_on_board
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, lr}
			BX		lr
; ret0: arg0
; ret1: arg1





; Routine draw_on_board
; Draws character on the board using top left corner of the board as 0,0
; Author: ADB
; Calls: cursor_position, output_character
; arg0: x value of character to be displayed
; arg1: y value of character to be displayed
; arg2: ASCII value of character to be displayed
draw_on_board
			STMFD	sp!, {r0, r1, r2, lr}
			; Offset coordinates
			ADD		r0, r0, #2
			ADD		r1, r1, #4
			BL		cursor_position
			MOV		r0, r2
			BL		output_character
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, lr}
			BX		lr
; ret0: arg0
; ret1: arg1
; ret2: arg2





; Routine edit_array
; Changes the value of element held at x,y to the value passed into r2
; Author: ADB
; Leaf routine
; arg0: x value of desired element
; arg1: y value of desired element
; arg2: value for element at x,y to be changed to
edit_array
			STMFD	sp!, {r0, r1, r2, r4, r5, lr}
			; Normalize x & y inputs to board
			ADD		r0, r0, #1
			ADD		r1, r1, #3
			; Store character dependent on normalized inputs
			LDR		r4, =array_base				; Get address of base of array
			LDR		r5, [r4, r1, LSL #2]		; Get address of desired vector (y coordinate)
			STRB	r2, [r5, r0]				; Put desired value into vector (x coordinate)
			; Return to caller
			LDMFD	sp!, {r0 ,r1, r2, r4, r5, lr}
			BX		lr
; ret0: arg0
; ret1: arg1
; ret2: arg2





; Routine populate_array
; Fills array used for managing character positions on screen
; Author: ADB
; Calls: store_string
; No input arguments or addresses
populate_array
			STMFD	sp!, {r0-r2, r4-r8, lr}
			; Get base address of array
			LDR		r6, =array_base
			; Store title string
			LDR		r4, =title
			LDR		r5, [r6], #4
			BL		store_string
			; Store HUD string
			LDR		r4, =HUD
			LDR		r5, [r6], #4
			BL		store_string
			; Store edge string
			LDR		r4, =edge
			LDR		r5, [r6], #4
			BL		store_string
			; Loop and store row or zRow depending on mod of counter
			MOV		r2, #0				; Initialize counter
			LDR		r7, =row
			LDR		r8, =zRow
pa_loop
			MOV		r0, r2
			MOV		r1, #2
			BL		div_and_mod
			CMP		r1, #0
			MOVEQ	r4, r7
			MOVNE	r4, r8
			LDR		r5, [r6], #4
			BL		store_string
			CMP		r2, #10
			ADD		r2, r2, #1
			BNE		pa_loop
			; Store edge string
			LDR		r4, =edge
			LDR		r5, [r6], #4
			BL		store_string
			; Return to caller
			LDMFD	sp!, {r0-r2, r4-r8, lr}
			BX		lr
; No output arguments or addresses





; Routine read_array
; Returns the value of element held at x,y
; Author: ADB
; Leaf routine
; arg0: x value of desired element
; arg1: y value of desired element
read_array
			STMFD	sp!, {r1, r4, r5, lr}
			; Normalize x & y inputs to board
			ADD		r0, r0, #1
			ADD		r1, r1, #3
			; Get data based on normalized inputs
			LDR		r4, =array_base				; Get address of base of array
			LDR		r5, [r4, r1, LSL #2]		; Get address of desired vector (y coordinate)
			LDRB	r0, [r5, r0]				; Get desired value from vector (x coordinate)
			; Return to caller
			LDMFD	sp!, {r1, r4, r5, lr}
			BX		lr
; arg0: ASCII value of current 





			END