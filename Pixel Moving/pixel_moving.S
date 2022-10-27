.org $8000

start:
LDX #$FF
TXS
LDA #1
STA $0288
LDA #$88
STA $02

loop:
LDX $02
JSR movements
LDA #0 ; black
STA $0200, X
LDA #1
LDY $02
STA $0200, Y

JMP loop

JMP start

movements:
LDA $4000
AND #$01
BNE up
LDA $4000
AND #$02
BNE down
LDA $4000
AND #$04
BNE left
LDA $4000
AND #$08
BNE right

RTS

up:
SEC
LDA $02
SBC #$10
STA $02
RTS

down:
CLC
LDA $02
ADC #$10
STA $02
RTS

left:
LDA $02
SBC #$01
STA $02
RTS

right:
LDA $02
ADC #$01
STA $02
RTS

.goto $FFFA
.dw start ; non maskable
.dw start ; reset
.dw start ; interrupt