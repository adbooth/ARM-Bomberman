	AREA	main, CODE, READWRITE
; IMPORTS
	; Import from general_library
	IMPORT  div_and_mod
    IMPORT  edit_register
	; Import from hardware_library
	IMPORT  pin_clear
    IMPORT  RGB_LED
    IMPORT  rgb_set
    IMPORT  seg_pattern_display
    IMPORT  read_push_btns
    IMPORT  display_digit
    IMPORT  LEDs
	IMPORT	uart_init
	IMPORT	GPIO_init
	; Import from string_library
	IMPORT  cmp_str
	IMPORT  numberString_to_int
	IMPORT  int_to_numberString
	IMPORT  newline
	IMPORT  output_character
	IMPORT  output_string
	IMPORT  println
	IMPORT  prompt
	IMPORT  read_character
	IMPORT  read_string
	IMPORT  reverse_string
	IMPORT  string_length
	; Import from graphics_library
	IMPORT	brick_setup
	IMPORT	change_character
	IMPORT	change_score_value
	IMPORT	change_time_value
	IMPORT	clear_screen
	IMPORT	cursor_position
	IMPORT	cursor_down
	IMPORT	cursor_left
	IMPORT	cursor_right
	IMPORT	cursor_up
	IMPORT	draw_board
	IMPORT	draw_bomberman
	IMPORT	draw_on_board
	IMPORT	check_location
	IMPORT	populate_array
	IMPORT	edit_array
	IMPORT	read_array
	; Exports
	EXPORT	lab7
	EXPORT	timer_init
	EXPORT	FIQ_Handler
	EXPORT	interrupt_init
	EXPORT	get_rand

IO0PIN      EQU 0xE0028000
	ALIGN
T0MR0		EQU	0xE0004018
	ALIGN
T1MR0		EQU	0xE0008018
	ALIGN
T0MCR		EQU	0xE0004014
	ALIGN
T1MCR		EQU	0xE0008014
	ALIGN

game_status			DCD	0x00000000
	ALIGN
level				DCD	0X00000000
	ALIGN
score				DCD	0x00000000
	ALIGN
time				DCD	0x00000078
	ALIGN
life_count			DCD	0x00000000
	ALIGN
lives				DCD	0x00000000
	ALIGN
bomb_status			DCD	0x00000000
	ALIGN
rgb_status			DCD	0x00000000
	ALIGN

rand_character		DCD	0x00000000
	ALIGN
time_flag			DCD	0x00000000
	ALIGN
player_input		DCD	0x00000000
	ALIGN
current_direction	DCD	0x00000000
	ALIGN


bomberman_x			DCD	0x00000000
	ALIGN
bomberman_y			DCD	0x00000000
	ALIGN
bomberman_status	DCD	0x00000000
	ALIGN
slow_enemy_1_x		DCD	0x00000016
	ALIGN
slow_enemy_1_y 		DCD	0x00000000
	ALIGN
slow_enemy_1_status	DCD	0x00000000
	ALIGN
slow_enemy_2_x 		DCD	0x00000000
	ALIGN
slow_enemy_2_y		DCD	0x0000000A
	ALIGN
slow_enemy_2_status	DCD	0x00000000
	ALIGN
fast_enemy_x		DCD	0x00000016
	ALIGN
fast_enemy_y		DCD	0x0000000A
	ALIGN
fast_enemy_status	DCD	0x00000000
	ALIGN
bomb_x				DCD	0x00000000
	ALIGN
bomb_y				DCD	0x00000000
	ALIGN


welcome	=		"Press any character...",0
	ALIGN
game_over_string = "You lose!",0
	ALIGN
clear_chars = 	0x1B,"[2J",0
	ALIGN



speed_array
			DCD	0x00465000	; Level 1 speed
			DCD	0x00384000	; Level 2 speed
			DCD	0x002A3000	; Level 3+ speed


lab7
			STMFD	sp!, {lr}
			; Program initalization routine is inline and starts here
			; Start by initializing hardware
			BL		GPIO_init
			BL		uart_init
			; Initialize game settings
			; Initialize game status to 0
			LDR		r4, =game_status
			MOV		r0, #0
			STR		r0, [r4]
			BL		RGB_update
			; Initialize time to 0
			LDR		r4, =time
			MOV		r0, #120
			STR		r0, [r4]
			; Initialize level to 0
			LDR		r4, =level
			MOV		r0, #0
			STR		r0, [r4]
			BL		seg_level
			; Initialize score to 0
			LDR		r4, =score
			MOV		r0, #0
			STR		r0, [r4]
			; Set all statuses to 1
			; Initialize bomberman_status to 1
			LDR		r4, =bomberman_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize slow_enemy_1_status to 1
			LDR		r4, =slow_enemy_1_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize slow_enemy_2_status to 1
			LDR		r4, =slow_enemy_2_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize fast_enemy_status to 1
			LDR		r4, =fast_enemy_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize number of lives to bit pattern for (15)
			LDR		r4, =life_count
			MOV		r0, #15
			STR		r0, [r4]
			BL		LEDs
			; Draw welcome screen
			BL		draw_welcome
			; Start the timers and interrupts
			BL		interrupt_init
			BL		timer_init
			; call level_init
			BL		level_init
while_true	; Loop forever while the interrupts handle the rest
			B		while_true
			; Return to caller
			LDMFD	sp!, {lr}
			BX		lr


level_init
			STMFD	sp!, {r0, r1, r2, r4, r5, r6, lr}
			; Increment level
			LDR		r4, =level
			LDR		r0, [r4]
			ADD		r0, r0, #1
			STR		r0, [r4]
			BL		seg_level
			; Initialize character positions
			; Initialize bomberman's position
			LDR		r4, =bomberman_x
			LDR		r5, =bomberman_y
			MOV		r0, #0
			STR		r0, [r4]
			STR		r0, [r5]
			; Initialize bomberman_status to 1
			LDR		r4, =bomberman_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize slowone's position
			LDR		r4, =slow_enemy_1_x
			MOV		r0, #22
			STR		r0, [r4]
			LDR		r4, =slow_enemy_1_y
			MOV		r0, #0
			STR		r0, [r4]
			; Initialize slow_enemy_1_status to 1
			LDR		r4, =slow_enemy_1_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize slowtwo's position
			LDR		r4, =slow_enemy_2_x
			MOV		r0, #0
			STR		r0, [r4]
			LDR		r4, =slow_enemy_2_y
			MOV		r0, #10
			STR		r0, [r4]
			; Initialize slow_enemy_2_status to 1
			LDR		r4, =slow_enemy_2_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize fastone's position
			LDR		r4, =fast_enemy_x
			MOV		r0, #22
			STR		r0, [r4]
			LDR		r4, =fast_enemy_y
			MOV		r0, #10
			STR		r0, [r4]
			; Initialize fast_enemy_status to 1
			LDR		r4, =fast_enemy_status
			MOV		r0, #1
			STR		r0, [r4]
			; Initialize game status to 1
			LDR		r4, =game_status
			MOV		r0, #1
			STR		r0, [r4]
			BL		RGB_update
			; Make sure bomb_status is 0
			LDR		r4, =bomb_status
			MOV		r0, #0
			STR		r0, [r4]
			; Increase speed
			LDR		r4, =level
			LDR		r0, [r4]
			CMP		r0, #3
			MOVGT	r0, #3
			SUB		r0, r0, #1
			LDR		r5, =speed_array
			LDR		r1, [r5, r0, LSL #2]
			LDR		r6, =T1MR0
			STR		r1, [r6]
			; Reset board and tracking array
			BL		draw_board
			BL		populate_array
			; Update score and time HUDs
			LDR		r4, =score
			LDR		r0, [r4]
			BL		change_score_value
			LDR		r4, =time
			LDR		r0, [r4]
			BL		change_time_value
			; Randomize bricks
			MOV		r1, #3
			LDR		r4, =level
			LDR		r2, [r4]
			SUB		r2, r2, #1
			MUL		r0, r1, r2
			ADD		r0, r0, #10
			BL		brick_setup
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, r4, r5, r6, lr}
			BX		lr



draw_welcome
			STMFD	sp!, {r0 ,r4, lr}
			BL		clear_screen
			LDR		r4, =welcome
			BL		println
			BL		read_character
			LDR		r4, =rand_character
			STR		r0, [r4]
			; Return to caller
			LDMFD	sp!, {r0, r4, lr}
			BX		lr



; routine to update bomberman on board
; Uses x and y coordinates in memory
; Author: MTH
; No inputs
bomberman_update
			STMFD	sp!, {r0-r6, r10, r11, lr}
			; Load bomberman x and y coordinates
			LDR		r4, =bomberman_x
			LDR		r0, [r4]
			LDR		r5, =bomberman_y
			LDR		r1, [r5]
			; Load last direction user inputed
			LDR		r6, =current_direction
			LDR		r3, [r6]
			; Check if input was w
			CMP		r3, #'w'
			SUBEQ	r1, r1, #1
			BEQ		bu_cont
			; Check if input was s
			CMP		r3, #'s'
			ADDEQ	r1, r1, #1
			BEQ		bu_cont
			; Check if input was a
			CMP		r3, #'a'
			SUBEQ	r0, r0, #1
			BEQ		bu_cont
			; Check if input was d
			CMP		r3, #'d'
			ADDEQ	r0, r0, #1
			BEQ		bu_cont
			; Reset user input
			MOV		r0, #0
			STR		r0, [r6]
			B		bu_exit
bu_cont
			MOV		r7, #0
			STR		r7, [r6]
			LDR		r7, =player_input
			STR		r3, [r7]
			MOV		r2, r0
			; Verify new location
			BL		read_array
			CMP		r0, #'Z'
			BEQ		bu_exit
			CMP		r0, #'#'
			BEQ		bu_exit
			CMP		r0, #'o'
			BEQ		bu_exit
			CMP		r0, #'x'
			BLEQ	DIE_BOMBERMAN
			BEQ		bu_exit
			CMP		r0, #'+'
			BLEQ	DIE_BOMBERMAN
			CMP		r0, #'+'
			BEQ		bu_exit
			; Location OK
			; Print new bomberman
			MOV		r0, r2
			MOV		r2, #'B'
			BL		draw_on_board
			BL		edit_array
			MOV		r10, r0
			MOV		r11, r1
			; Erase old bomberman
			LDR		r4, =bomberman_x
			LDR		r0, [r4]
			LDR		r5, =bomberman_y
			LDR		r1, [r5]
			; Check if current space is a bomb
			BL		read_array
			CMP		r0, #'o'
			BEQ		bu_str
			; Clear old bomberman
			MOV		r2, #' '
			LDR		r0, [r4]
			LDR		r1, [r5]
			BL		draw_on_board
			BL		edit_array
bu_str
			; Store new locations
			MOV		r0, r10
			MOV		r1, r11
			STR		r0, [r4]
			STR		r1, [r5]
bu_exit
			LDMFD	sp!, {r0-r6, r10, r11, lr}
			BX		lr
; No return arguments
			

DIE_BOMBERMAN
			STMFD	sp!, {r0, r1, r2, r4, r5, r10, r11, lr}
			; Decrement life count and displayed lives
			BL		LED_life
			; Check for 0 lives
			LDR		r4, =life_count
			LDR		r0, [r4]
			CMP		r0, #0
			BEQ		game_over
			BEQ		DB_exit
			; Respawn bomberman
			; Print new bomberman
			MOV		r0, #0
			MOV		r1, #0
			MOV		r2, #'B'
			BL		draw_on_board
			BL		edit_array
			MOV		r10, r0
			MOV		r11, r1
			; Erase old bomberman
			LDR		r4, =bomberman_x
			LDR		r0, [r4]
			LDR		r5, =bomberman_y
			LDR		r1, [r5]
			MOV		r2, #' '
			BL		draw_on_board
			BL		edit_array
			MOV		r0, r10
			MOV		r1, r11
			STR		r0, [r4]
			STR		r1, [r5]
			LDR		r4, =bomberman_status
			MOV		r0, #1
			STR		r0, [r4]
DB_exit
			; Return to caller
			LDMFD	sp!, {r0, r1, r2, r4, r5, r10, r11, lr}
			BX		lr

game_over
			STMFD	sp!, {lr}
			; handle game over stuff
			BL		clear_screen
			LDR		r4, =game_over_string
			BL		output_string
			LDR		r4, =score
			LDR		r0, [r4]
			BL		int_to_numberString
			BL		output_string
go_loop		
			B		go_loop
			; Return to caller
			LDMFD	sp!, {lr}
			BX		lr			



; Routine that updates both slow enemies on board
; Uses x and y coordinates in memory
; Author: MTH
; No inputs
slow_enemy_update
			STMFD	sp!, {r0-r5, r10, r11, lr}
			; Generate random number between 1 and 4
			MOV		r3, #0
			MOV		r0, #4
			BL		get_rand
			ADD		r0, r0, #1
se1_check
			; Load slow_enemy_1_status to see if it is dead
			LDR		r4, =slow_enemy_1_status
			LDR		r4, [r4]
			CMP		r4, #0
			BEQ		se2_check
			; Load slow_enemy_1 x and y locations
se1_loop
			LDR		r4, =slow_enemy_1_x
			LDR		r2, [r4]
			LDR		r5, =slow_enemy_1_y
			LDR		r1, [r5]
			CMP		r0, #4
			MOVGT	r0, #1
			; 1 = up
			CMP		r0, #1
			SUBEQ	r1, r1, #1
			BEQ		se1_cont
			; 2 = right
			CMP		r0, #2
			ADDEQ	r2, r2, #1
			BEQ		se1_cont
			; 3 = down
			CMP		r0, #3
			ADDEQ	r1, r1, #1
			BEQ		se1_cont
			; 4 = left
			CMP		r0, #4									 
			SUBEQ	r2, r2, #1
			BEQ		se1_cont
			B		se1_loop
se1_cont
			; Check location
			MOV		r6, r0 		
			MOV		r0, r2
			BL		read_array
			CMP		r0, #'Z'
			BEQ		se1_retry
			CMP		r0, #'#'
			BEQ		se1_retry
			CMP		r0, #'o'
			BEQ		se1_retry
			CMP		r0, #'B'
			BLEQ	DIE_BOMBERMAN
			B		se1_location_works
se1_retry
			; Increment random number if previous number was not valid
			MOV		r0, r6
			ADD		r0, r0, #1
			ADD		r3, r3, #1
			CMP		r3, #4
			BGE		se2_check	
			B		se1_loop
se1_location_works
			; Print new slow enemy
			MOV		r0, r2
			MOV		r2, #'x'
			BL		draw_on_board
			BL		edit_array
			MOV		r10, r0
			MOV		r11, r1
			; Load old location to clear old enemy
			LDR		r4, =slow_enemy_1_x
			LDR		r0, [r4]
			LDR		r5, =slow_enemy_1_y
			LDR		r1, [r5]
			MOV		r2, #' '
			BL		draw_on_board
			BL		edit_array
			; Store new locations
			MOV		r0, r10
			MOV		r1, r11
			STR		r0, [r4]
			STR		r1, [r5]
			; Get a new random number
			MOV		r0, #4
			BL		get_rand
			ADD		r0, r0, #1
			
se2_check
			; Check to see if slow enemy 2 is dead
			MOV		r3, #0
			LDR		r4, =slow_enemy_2_status
			LDR		r4, [r4]
			CMP		r4, #0
			BEQ		se_exit
se2_loop
			; Load current x and y locations
			LDR		r4, =slow_enemy_2_x
			LDR		r2, [r4]
			LDR		r5, =slow_enemy_2_y
			LDR		r1, [r5]
			CMP		r0, #4
			MOVGT	r0, #1
			; 1 = up
			CMP		r0, #1
			SUBEQ	r1, r1, #1
			BEQ		se2_cont
			; 2 = down
			CMP		r0, #2
			ADDEQ	r1, r1, #1
			BEQ		se2_cont
			; 3 = right
			CMP		r0, #3
			ADDEQ	r2, r2, #1
			BEQ		se2_cont
			; 4 = left
			CMP		r0, #4
			SUBEQ	r2, r2, #1
			BEQ		se2_cont
			B		se2_loop
se2_cont
			; Check location
			MOV		r6, r0 		
			MOV		r0, r2
			BL		read_array
			CMP		r0, #'Z'
			BEQ		se2_retry
			CMP		r0, #'#'
			BEQ		se2_retry
			CMP		r0, #'o'
			BEQ		se2_retry
			CMP		r0, #'B'
			BLEQ	DIE_BOMBERMAN
			B		se2_location_works
se2_retry
			; Increment random number if previous number was not valid
			MOV		r0, r6
			ADD		r0, r0, #1
			ADD		r3, r3, #1
			CMP		r3, #4
			BGE		se_exit	
			B		se2_loop
se2_location_works
			; Print new enemy
			MOV		r0, r2
			MOV		r2, #'x'
			BL		draw_on_board
			BL		edit_array
			MOV		r10, r0
			MOV		r11, r1
			; Load old location to clear old enemy
			LDR		r4, =slow_enemy_2_x
			LDR		r0, [r4]
			LDR		r5, =slow_enemy_2_y
			LDR		r1, [r5]
			MOV		r2, #' '
			BL		draw_on_board
			BL		edit_array
			; Store new locations
			MOV		r0, r10
			MOV		r1, r11
			STR		r0, [r4]
			STR		r1, [r5]
se_exit
			LDMFD	sp!, {r0-r5, r10, r11, lr}
			BX		lr
; No return arguments





; Routine that updates the fast enemy on board
; Uses x and y locations in memeory
; Author: MTH
; No inputs
fast_enemy_update
			STMFD	sp!, {r0-r5, r10, r11, lr}
			MOV		r0, #4
			BL		get_rand
			ADD		r0, r0, #1
fe1_loop
			LDR		r4, =fast_enemy_x
			LDR		r2, [r4]
			LDR		r5, =fast_enemy_y
			LDR		r1, [r5]
			CMP		r0, #4
			MOVGT	r0, #1
			; 1 = left
			CMP		r0, #1
			SUBEQ	r2, r2, #1
			BEQ		fe1_cont
			; 2 = right
			CMP		r0, #2
			ADDEQ	r2, r2, #1
			BEQ		fe1_cont
			; 3 = down
			CMP		r0, #3
			ADDEQ	r1, r1, #1
			BEQ		fe1_cont
			; 4 = up
			CMP		r0, #4									 
			SUBEQ	r1, r1, #1
			BEQ		fe1_cont
			B		fe1_loop
fe1_cont
			; Check location
			MOV		r6, r0 		
			MOV		r0, r2
			BL		read_array
			CMP		r0, #'Z'
			BEQ		fe1_retry
			CMP		r0, #'#'
			BEQ		fe1_retry
			CMP		r0, #'o'
			BEQ		fe1_retry
			CMP		r0, #'B'
			BLEQ	DIE_BOMBERMAN
			B		fe1_location_works
fe1_retry
			; Increment random number if previous number was not valid
			MOV		r0, r6
			ADD		r0, r0, #1	
			B		fe1_loop
fe1_location_works
			MOV		r0, r2
			MOV		r2, #'+'
			BL		draw_on_board
			BL		edit_array
			MOV		r10, r0
			MOV		r11, r1
			LDR		r4, =fast_enemy_x
			LDR		r0, [r4]
			LDR		r5, =fast_enemy_y
			LDR		r1, [r5]
			MOV		r2, #' '
			BL		draw_on_board
			BL		edit_array
			MOV		r0, r10
			MOV		r1, r11
			STR		r0, [r4]
			STR		r1, [r5]
			LDMFD	sp!, {r0-r5, r10, r11, lr}
			BX		lr
; No return arguments




; get_rand returns a random number between 0 and one minus the input value
; Author: MTH
; arg0: upper limit of random number
get_rand
			STMFD	sp!, {r1-r5, r10, lr}
			; move input to r1 so it is divisor for division
			MOV		r10, r0
			; Load user input from welcome screen
			LDR		r5, =rand_character
			LDR		r2, [r5]
			; Load Time Count register value
			LDR		r4, =0xE0004008
			LDR		r0, [r4]
			MUL		r3, r2, r0
			; Load time variable in memory
			LDR		r4, =time
			LDR		r1, [r4]
			ADD		r0, r3, r1
			; Load latest player input from UART
			LDR		r4, =player_input
			LDR		r2, [r4]
			; Mask out upper 6 bytes
			AND		r0, r0, #0x000000FF
			ADD		r0, r0, r2
			MOV		r1, r10
			; Take mod
			BL		div_and_mod
			; Move remainder to r0 so it is the return value
			MOV		r0, r1
			LDMFD	sp!, {r1-r5, r10, lr}
			BX		lr
; ret0: random number between 0 and one minus input




; Routine draws a bomb on screen
; Author: MTH
; No inputs
drop_bomb
			STMFD	sp!, {r0, r1, r4, r5, lr}
			; Start bomb status counter at 8
			LDR		r4, =bomb_status
			LDR		r0, [r4]
			CMP		r0, #0
			BGT		bd_exit
			MOV		r0, #8
			STR		r0, [r4]
			; Change game status to 2
			LDR		r4, =game_status
			MOV		r0, #2
			STR		r0, [r4]
			; Update rgb status and change rgb color
			LDR		r4, =rgb_status
			STR		r0, [r4]
			BL		RGB_update
			; Use current bomberman coordinates to draw bomb
			LDR		r4, =bomberman_x
			LDR		r0, [r4]
			LDR		r5, =bomberman_y
			LDR		r1, [r5]
			MOV		r2, #'o'
			BL		draw_on_board
			BL		edit_array
			; Store coordinates as bomb location
			LDR		r4, =bomb_x
			LDR		r5, =bomb_y
			STR		r0, [r4]
			STR		r1, [r5]
bd_exit
			LDMFD	sp!, {r0, r1, r4, r5, lr}
			BX		lr
; No outputs			




; Prints bomb explosion and checks what got destroyed
; Author: MTH
; No inputs
print_explosion
			STMFD	sp!, {r0-r7, lr}
			; Load bomb location
			LDR		r4, =bomb_x
			LDR		r6, [r4]
			LDR		r5, =bomb_y
			LDR		r7, [r5]
			MOV		r0, r6
			MOV		r1, r7
			; Check if anything got destroyed
			BL		explosion_check
			MOV		r1, #2
			; Sheck mod of x coordinate
			MOV		r0, r6
			BL		div_and_mod
			CMP		r1, #1
			; If an odd row, branch to check_y
			BEQ		check_y
			MOV		r1, r7
			MOV		r0, r6
			MOV		r2, #'|'
			; Print vertical explosion bars and check their locations
			SUB		r1, r1, #2
			CMP		r1, #0
			BLGE	draw_on_board
			BLGE	explosion_check
			ADD		r1, r1, #1
			CMP		r1, #0
			BLGE	draw_on_board
			BLGE	explosion_check
			ADD		r1, r1, #3
			CMP		r1, #10
			BLLE	draw_on_board
			BLLE	explosion_check
			SUB		r1, r1, #1
			CMP		r1, #10
			BLLE	draw_on_board
			BLLE	explosion_check


check_y		; check mod of y coordinate
			MOV		r0, r7
			MOV		r1, #2
			BL		div_and_mod
			CMP		r1, #1
			BEQ		pe_exit
			MOV		r1, r7
			MOV		r0, r6
			MOV		r2, #'-'
			; Print horizontal explosion bars and check their locations
			SUB		r0, r0, #4
			CMP		r0, #0
			BLGE	draw_on_board
			BLGE	explosion_check
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board
			BLGE	explosion_check
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board
			BLGE	explosion_check
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board
			BLGE	explosion_check

			ADD		r0, r0, #5
			CMP		r0, #22
			BLLE	draw_on_board
			BLGE	explosion_check
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board
			BLGE	explosion_check
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board
			BLGE	explosion_check
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board
			BLGE	explosion_check
pe_exit
			LDMFD	sp!, {r0-r7, lr}
			BX		lr
; No outputs


explosion_check
			STMFD	sp!, {r0-r10, lr}
			MOV		r5, r0
			MOV		r6, r1
			LDR		r7, =score
			LDR		r8, [r7]
			LDR		r9, =level
			LDR		r9, [r9]
			MOV		r3, #10
			MUL		r10, r9, r3
			BL		read_array
			CMP		r0, #'Z'
			BEQ		ec_exit
			; check if fast enemy
			LDR		r4, =fast_enemy_status
			CMP		r0, #'+'
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			ADDEQ	r8, r8, r10
			STREQ	r8, [r7]
			BEQ		ec_edit
			; check if brick
			CMP		r0, #'#'
			ADDEQ	r8, r8, r9
			STREQ	r8, [r7]
			BEQ		ec_edit
			; check if bomberman
		   	CMP		r0, #'B'
			LDREQ	r4, =bomberman_status
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			BEQ		ec_exit
			LDR		r4, =bomberman_x
			LDR		r4, [r4]
			CMP		r4, r5
			BNE		ec_cont
			LDR		r4, =bomberman_y
			LDR		r4, [r4]
			CMP		r4, r6
			LDREQ	r4, =bomberman_status
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			BEQ		ec_exit
ec_cont
			CMP		r0, #' '
			BEQ		ec_edit
			; check if slow enemy
			LDR		r4, =slow_enemy_1_x
			CMP		r0, #'x'
			BNE		ec_edit
			LDR		r4, [r4]
			CMP		r4, r5
			BNE		check_2
			LDR		r4, =slow_enemy_1_y
			LDR		r4, [r4]
			CMP		r4, r6
			LDREQ	r4, =slow_enemy_1_status
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			ADDEQ	r8, r8, r10
			STREQ	r8, [r7]
			BEQ		ec_edit
check_2
			LDR		r4, =slow_enemy_2_x
			LDR		r4, [r4]
			CMP		r4, r5
			BNE		ec_edit
			LDR		r4, =slow_enemy_2_y
			LDR		r4, [r4]
			CMP		r4, r6
			LDREQ	r4, =slow_enemy_2_status
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			ADDEQ	r8, r8, r10
			STREQ	r8, [r7]
			BEQ		ec_edit
			B		ec_exit

ec_edit
			MOV		r0, r5
			MOV		r1, r6
			MOV		r2, #' '
			BL		edit_array
ec_exit
			MOV		r0, r8
			BL		change_score_value
			LDMFD	sp!, {r0-r10, lr}
			BX		lr


clear_explosion
			STMFD	sp!, {r0-r7, lr}
			LDR		r4, =bomb_x
			LDR		r6, [r4]
			LDR		r5, =bomb_y
			LDR		r7, [r5]
			MOV		r0, r6
			MOV		r1, r7
			MOV		r2, #' '
			BL		draw_on_board
			MOV		r1, #2
			; check mod of x coordinate
			MOV		r0, r6
			BL		div_and_mod
			CMP		r1, #1
			BEQ		chck_y
			MOV		r1, r7
			MOV		r0, r6
			MOV		r2, #' '
			SUB		r1, r1, #2
			CMP		r1, #0
			BLGE	draw_on_board
			ADD		r1, r1, #1
			CMP		r1, #0
			BLGE	draw_on_board
			ADD		r1, r1, #3
			CMP		r1, #10
			BLLE	draw_on_board
			SUB		r1, r1, #1
			CMP		r1, #10
			BLLE	draw_on_board


chck_y		; check mod of y coordinate
			MOV		r0, r7
			MOV		r1, #2
			BL		div_and_mod
			CMP		r1, #1
			BEQ		ce_exit
			MOV		r1, r7
			MOV		r0, r6
			MOV		r2, #' '
			SUB		r0, r0, #4
			CMP		r0, #0
			BLGE	draw_on_board
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board
			ADD		r0, r0, #1
			CMP		r0, #0
			BLGE	draw_on_board

			ADD		r0, r0, #5
			CMP		r0, #22
			BLLE	draw_on_board
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board
			SUB		r0, r0, #1
			CMP		r0, #22
			BLLE	draw_on_board


ce_exit
			LDR		r4, =game_status
			MOV		r0, #1
			STR		r0, [r4]
			LDMFD	sp!, {r0-r7, lr}
			BX		lr

; Main LED handler that decrements LED representation of lives
; Author: MTH
; No input arguments
LED_life
			STMFD	sp!, {r0, r4, lr}
			; Load number of lives
			LDR		r4, =life_count
			LDR		r0, [r4]
			; Check for 4 lives; if 4, reduce to 3
			CMP		r0, #15
			MOVEQ	r0, #7
			BEQ		ll_end
			; Check for 3 lives; if 3, reduce to 2
			CMP		r0, #7
			MOVEQ	r0, #3
			BEQ		ll_end
			; Check for 2 lives; if 2, reduce to 1
			CMP		r0, #3
			MOVEQ	r0, #1
			BEQ		ll_end
			; Check for 1 lives; if 1, reduce to 0 and branch to game over
			CMP		r0, #1
			MOVEQ	r0, #0
			STREQ	r0, [r4]
			BLEQ	LEDs
			;BEQ		GAMEOVER
ll_end
			; Store lives back to memory and display value
			STR		r0, [r4]
			BL		LEDs
			LDMFD	sp!, {r0, r4, lr}
			BX		lr
; No output





; RGB updater that changes the rgb color when game status changes
; Before game(0):		White
; During game(1):		Green
; Bomb Explosion(2):	Red Blinking
; Pause(3):				Blue
; Game Over(4):			Purple
; Author: MTH
; No input arguments
RGB_update
			STMFD	sp!, {r0, r4, lr}
			; Load game_status
			LDR		r4, =game_status
			LDR		r0, [r4]
			CMP		r0, #0 					; Compare to 0 (Before game)
			; If game_status = 0, make rgb white
			BEQ		ru_change
			; If game_status = 1, make rgb green
			CMP		r0, #1
			MOVEQ	r0, #3
			BEQ		ru_change
			; If game_status = 2, make rgb red and branch to rgb_toggle
			CMP		r0, #2
			MOVEQ	r0, #6
			BEQ		ru_change
			; If game_status = 3, make rgb blue
			CMP		r0, #3
			MOVEQ	r0, #5
			BEQ		ru_change
			; If game_status = 4, make rgb purple
			CMP		r0, #4
			BEQ		ru_change
			B		ru_end
ru_change
			BL		rgb_set
ru_end
			LDMFD	sp!, {r0, r4, lr}
			BX		lr
; No output			





; 7 segment display updater that changes the 7seg to display the current level
; When program initiates, value is 0 then starts at 1 when game begins
; Author: MTH
; No input arguments
seg_level
			STMFD	sp!, {r0, r4, lr}
			; Load level
			LDR		r4, =level
			LDR		r0, [r4]
			; Display number on 7seg
			BL		display_digit
			LDMFD	sp!, {r0, r4, lr}
			BX		lr
; No output	



; Routine that will toggle the rgb between red and off
; Author: MTH
; No inputs
rgb_toggle
			STMFD	sp!, {r0, r4, lr}
			; Load rgb_status
			LDR		r4, =rgb_status
			LDR		r0, [r4]
			CMP		r0, #0	  				; Check what rgb currently is set to
			; If rgb_status = 0 change color to red
			MOVEQ	r0, #6
			BLEQ	rgb_set
			STREQ	r0,[r4]
			BEQ		rt_end
			; Else turn led off and store a 0 in rgb_status
			MOV		r0, #7
			BL		rgb_set
			MOV		r0, #0
			STR		r0, [r4]
rt_end
			LDMFD	sp!, {r0, r4, lr}
			BX		lr
; No outputs





timer_init
			; Store used registers to stack
			STMFD	sp!, {r0, r1, lr}
			; Set interrupt value for Timer0 Match Register 0
			LDR		r1, =T0MR0
			LDR		r0, =18432000		; One second
			STR		r0, [r1]
			; Set interrupt value for Timer1 Match Register 0
			LDR		r1, =T1MR0
			LDR		r0, =4608000		; 0.25 sec
			STR		r0, [r1]
			; Modify Match Control Register to interrupt and reset Timer Counter on match
			LDR		r1, =T0MCR
			MOV		r0, #0x03
			STR		r0, [r1]
			; Modify Match Control Register to interrupt and reset Timer Counter on match
			LDR		r1, =T1MCR
			MOV		r0, #0x03
			STR		r0, [r1]

			; Enable timer0 and reset counter
			LDR		r1, =0xE0004004		; T0TCR address
			LDR		r0, [r1]
			ORR		r0, r0, #2
			STR		r0, [r1]
			BIC		r0, r0, #2
			ORR		r0, r0, #1
			STR		r0, [r1]			
			; Enable timer0 and reset counter
			LDR		r1, =0xE0008004		; T1TCR address
			LDR		r0, [r1]
			ORR		r0, r0, #2
			STR		r0, [r1]
			BIC		r0, r0, #2
			ORR		r0, r0, #1
			STR		r0, [r1]

			LDMFD	sp!, {r0, r1, lr}
			BX		lr


interrupt_init       
			STMFD 	SP!, {r0-r1, lr}   			; Save registers 
			; Push button setup		 
			LDR 	r0, =0xE002C000
			LDR 	r1, [r0]
			ORR 	r1, r1, #0x20000000
			BIC 	r1, r1, #0x10000000
			STR 	r1, [r0]  					; PINSEL0 bits 29:28 = 10
	
			; Classify sources as IRQ or FIQ
			LDR 	r0, =0xFFFFF000
			LDR 	r1, [r0, #0xC]
			ORR 	r1, r1, #0x8000 			; External Interrupt 1
			ORR		r1, r1, #0x70				; UART0, TIMER0, TIMER1
			STR 	r1, [r0, #0xC]
						   
			; Enable Interrupts
			LDR 	r0, =0xFFFFF000
			LDR 	r1, [r0, #0x10] 
			ORR		r1, r1, #0x8000 			; External Interrupt 1
			ORR		r1, r1, #0x70				; UART0, TIMER0, TIMER1
			STR 	r1, [r0, #0x10]
	
			; External Interrupt 1 setup for edge sensitive
			LDR 	r0, =0xE01FC148
			LDR 	r1, [r0]
			ORR 	r1, r1, #2  				; EINT1 = Edge Sensitive
			STR 	r1, [r0]
	
			; UART0 setup to interrupt when data is received
			LDR		r0, =0xE000C004
			LDR		r1, [r0]
			ORR		r1, r1, #1					; UART0 interrupts processor when data received
			STR		r1, [r0]
	
			; Enable FIQ's, Disable IRQ's
			MRS 	r0, CPSR
			BIC 	r0, r0, #0x40
			ORR 	r0, r0, #0x80
			MSR 	CPSR_c, r0
	
			LDMFD 	SP!, {r0-r1, lr} 			; Restore registers
			BX 		lr             	   			; Return



FIQ_Handler
            STMFD	sp!, {r0-r12, lr}
			; Check for Timer 0 interrupt
			LDR		r0, =0xE0004000
			LDR		r1, [r0]
			AND		r1, r1, #1
			CMP		r1, #1
			BEQ		TIMER0
			; Check for Timer 1 Match register 0 interrupt
			LDR		r0, =0xE0008000
			LDR		r1, [r0]
			AND		r1, r1, #1
			CMP		r1, #1
			BEQ		TIMER1
			; Check for UART0 interrupt
			LDR		r0, =0xE000C008
			LDR		r1, [r0]
			AND		r0, r1, #1
			CMP		r0, #0
			BEQ		UART0
			; Check for EINT1 interrupt
			LDR 	r0, =0xE01FC140
			LDR 	r1, [r0]
			AND 	r2, r1, #2
			CMP 	r2, #2
			BEQ		EINT1
			; Otherwise, exit handler
			B		FIQ_Exit
						
			
TIMER0
			; Clear interrupt
            LDR     r4, =0xE0004000
			MOV		r5, #1
			STR		r5, [r4]
			; Check game_status if not in game or bomb on board, exit handler
			LDR		r4, =game_status
			LDR		r0, [r4]
			CMP		r0, #1
			BLT		FIQ_Exit
			CMP		r0, #2
			BGT		FIQ_Exit
			; Increment timer counter in memory
			LDR		r4, =time
			LDR		r0, [r4]
			SUB		r0, r0, #1
			STR		r0, [r4]
			BL		change_time_value
			; Check if result is 120, branch to game over if it is game over
			CMP		r0, #0
			BEQ		game_over
			B		FIQ_Exit
			
TIMER1
			; Clear interrupt
            LDR     r4, =0xE0008000
			MOV		r5, #1
			STR		r5, [r4]
			BL		check_stati
			; Update fast stuff everytime
			LDR		r4, =fast_enemy_status
			LDR		r0, [r4]
			CMP		r0, #1
			BLEQ	fast_enemy_update
			; Check time flag to alternate slow updates
			LDR		r4, =time_flag
			LDR		r0, [r4]
			CMP		r0, #0
			EOR		r0, r0, #1
			STR		r0, [r4]
			BEQ		FIQ_Exit
			; Update slow stuff
			BL		bomberman_update
			BL		slow_enemy_update
			; Check bomb_status
			LDR		r4, =bomb_status
			LDR		r0, [r4]
			CMP		r0, #0
			BEQ		TIMER1_cont
			SUB		r0, r0, #1
			STR		r0, [r4]
			BL		rgb_toggle
			CMP		r0, #2
			BLEQ	print_explosion
			CMP		r0, #1
			BLEQ	clear_explosion
			B		FIQ_Exit
TIMER1_cont
			LDR		r4, =bomberman_status
			LDR		r0, [r4]
			CMP		r0, #0
			BLEQ	DIE_BOMBERMAN
			LDR		r4, =game_status
			MOV		r0, #1
			STR		r0, [r4]
			BL		RGB_update
			B		FIQ_Exit

			
			
UART0
			LDR		r4, =0xE000C000
			LDR		r0, [r4]
			CMP		r0, #' '
			BLEQ	drop_bomb
			LDR		r4, =current_direction
			STR		r0, [r4]
			B		FIQ_Exit
			
EINT1
			; wait until button is pressed again	
			MOV		r0, #3
			LDR		r4, =game_status
			STR		r0, [r4]
			BL		RGB_update

			MOV		r2, #0						;	Local EINT1 interrupt flag
EINT1_loop
			LDR		r4, =IO0PIN
			LDR		r0, [r4]
			AND		r0, r0, #0x00004000
			CMP		r0, #0x00004000
			BEQ		EINT1_cont
			BNE		EINT1_loop
EINT1_cont
			LDR		r0, [r4]
			AND		r0, r0, #0x00004000
			CMP		r0, #0x00004000
			BEQ		EINT1_cont
EINT1_loop2
			LDR		r0, [r4]
			AND		r0, r0, #0x00004000
			CMP		r0, #0x00004000
			BNE		EINT1_loop2
			MOV		r0, #1
			LDR		r4, =game_status
			STR		r0, [r4]
			BL		RGB_update
			; exit handler
			LDR		r4, =0xE01FC140
			LDR		r0, [r4]
			ORR 	r0, r0, #2					; Clear Interrupt
			STR 	r0, [r4]
			B		FIQ_Exit
FIQ_Exit
            ; Exit handler
			LDMFD	sp!, {r0-r12, lr}
			SUBS	pc, lr, #4

check_stati
			STMFD	sp!, {r0, r4, lr}
			; Check if all enemies are dead
			LDR		r4, =slow_enemy_1_status
			LDR		r0, [r4]
			CMP		r0, #1
			BEQ		cs_exit
			LDR		r4, =slow_enemy_2_status
			LDR		r0, [r4]
			CMP		r0, #1
			BEQ		cs_exit
			LDR		r4, =fast_enemy_status
			LDR		r0, [r4]
			CMP		r0, #1
			BEQ		cs_exit
			; If all enemies are dead, call level_init
			BL		level_init
cs_exit
			LDMFD	sp!, {r0, r4, lr}
			BX		lr

	END