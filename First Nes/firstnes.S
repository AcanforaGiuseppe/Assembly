.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUADDR $2006
.define PPUDATA $2007

.org $8000

start:
LDA #$3F
STA PPUADDR
LDA #0
STA PPUADDR

LDA #$26
STA PPUDATA

LDA #$11
STA PPUDATA

LDA #$33
STA PPUDATA

LDA #$06
STA PPUDATA

LDA #%00000000
STA PPUCTRL

LDA #%00011010
STA PPUMASK

loop:
INC $0000
JMP loop

nmi:
RTI

irq:
RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin "mario0.chr"
.fill 4096 $aa