.define idCenterPos $0288
.define centerScreenValue #$88
.define accumulatorTempAddress $03
.define vsyncCounter $00
.define old_vsyncCounter $01
.define videoOutput $0200
.define joy $4000
.define dir $04
.define fps #15
.define rand $0F
.define bgColor #0
.define appleColor #1
.define applePos $05
.define startPlayerLen #01
.define playerLen $02
.define playerColor #$A2
.define playerHead $10
.define playerBody $11
.define K_UP #$01
.define K_DOWN #$02
.define K_LEFT #$04
.define K_RIGHT #$08
.define verticalMovement #$10
.define horizontalMovement #$01

.org $8000
LDX #$FF
TXS

start:
JSR init
JSR loop

init:
LDA playerColor
STA idCenterPos
LDA centerScreenValue
STA playerHead
LDA startPlayerLen
STA playerLen

init_loop:
JSR randomCounter
JSR get_directions
JSR draw_snake
LDA dir
CMP #$00
BEQ init_loop
JSR set_new_apple
RTS

loop:
JSR randomCounter
JSR check_collisions
JSR get_directions
JSR check_update
JSR draw_body
JSR movements
JSR draw
JMP loop

skip_cycle:
PLA 
PLP
JMP loop

exit_subroutine:
RTS

randomCounter:
INC rand
RTS

check_collisions:

check_apple_collision:
LDA applePos
CMP playerHead
BNE check_snake_collision
INC playerLen
JSR set_new_apple

check_snake_collision:
LDA playerLen
CMP #$05
BMI exit_subroutine
LDX #$03

snake_loop:
LDA playerHead, X
CMP playerHead
BEQ collisions_w_self
INX
CPX playerLen
BNE snake_loop
RTS

collisions_w_self:
JMP game_over

get_directions:
LDA joy
CMP #$00
BEQ exit_subroutine
CMP dir
BNE change_dir
RTS

change_dir:
TAX
LDA dir
CMP K_UP
BEQ k_up
CMP K_DOWN
BEQ k_down
CMP K_LEFT
BEQ k_left
CMP K_RIGHT
BEQ k_right
STX dir
RTS

k_left:
CPX K_RIGHT
BEQ exit_subroutine
STX dir
RTS

k_right:
CPX K_LEFT
BEQ exit_subroutine
STX dir
RTS

k_down:
CPX K_UP
BEQ exit_subroutine
STX dir
RTS

k_up:
CPX K_DOWN
BEQ exit_subroutine
STX dir
RTS

check_update:
LDA vsyncCounter
CMP old_vsyncCounter
BEQ skip_cycle
STA old_vsyncCounter
CMP fps
BNE skip_cycle
RTS

draw_body:
LDY playerHead
LDA playerLen
CMP startPlayerLen
BEQ exit_subroutine
LDX playerLen
DEX
DEX
LDY playerBody, X

header:
LDA playerHead, X
STA playerBody, X
DEX
BPL header
RTS

movements:
LDA dir
AND K_UP
BNE move_up
LDA dir
AND K_DOWN
BNE move_down
LDA dir
AND K_LEFT
BNE move_left
LDA dir
AND K_RIGHT
BNE move_right
RTS

move_left:
LDA playerHead
LDX #0

left_loop:
CPX #4
BEQ wall_collision
SEC
ROR A
INX
BCC left_loop
LDA playerHead
SBC horizontalMovement
STA playerHead
RTS

move_right:
LDA playerHead
LDX #0
right_loop:
CPX #4
BEQ wall_collision
CLC
ROR A
INX
BCS right_loop
LDA playerHead
ADC horizontalMovement
STA playerHead
RTS

move_up:
SEC
LDA playerHead
CMP #$10
BMI wall_collision
SBC verticalMovement
STA playerHead
RTS

move_down:
CLC
LDA playerHead
CMP #$F0
BPL wall_collision
CLC
LDA playerHead
ADC verticalMovement
STA playerHead
RTS

wall_collision:
JMP game_over

draw:
LDA bgColor
STA videoOutput, Y
JSR draw_apple
JSR draw_snake
RTS

draw_snake:
LDA playerColor
LDY playerHead
STA videoOutput, Y
RTS

draw_apple:
LDA dir
CMP #0
BEQ draw_snake
LDA appleColor
LDY applePos
STA videoOutput, Y
RTS

get_random:
LDA rand
ADC vsyncCounter
LDX dir

random_loop:
ADC playerLen
DEX
BNE random_loop
RTS

set_new_apple:
JSR get_random
STA applePos
RTS

nmi:
STA accumulatorTempAddress
LDA vsyncCounter
STA old_vsyncCounter
DEC vsyncCounter
BEQ reset_vsync
LDA accumulatorTempAddress
RTI

reset_vsync:
LDA fps
STA vsyncCounter
LDA accumulatorTempAddress
RTI

game_over:
LDA #$00
LDX #0

clear_zero_page:
STA $00, X
INX
BNE clear_zero_page

clear_stack:
STA $0100, X
INX
BNE clear_stack

clear_video_output:
STA videoOutput, X
INX
BNE clear_video_output

JMP start

.goto $FFFA
.dw nmi ; non maskable
.dw start ; reset
.dw start ; interrupt