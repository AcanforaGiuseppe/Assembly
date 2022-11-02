.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define JOYPAD1 $4016
.define scrollX $01
.define buttons $02

start:
LDA #%10000000
STA PPUCTRL

LDA #%00001110
STA PPUMASK

LDA #$3F
STA PPUADDR
LDA #00
STA PPUADDR

LDA #$0B
STA PPUDATA
LDA #$28
STA PPUDATA
LDA #$11
STA PPUDATA
LDA #$05
STA PPUDATA

LDA #$20
STA PPUADDR
LDA #$00
STA PPUADDR

LDA #$02
STA PPUDATA
LDA #$FD
STA PPUDATA

loop:
  JMP loop

; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta JOYPAD1
    sta buttons
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta JOYPAD1
joyloop:
    lda JOYPAD1
    lsr a           ; bit 0 -> Carry
    rol buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc joyloop
    rts

nmi:
PHA
JSR readjoy
PLA

LDA buttons
AND #%00000011
BEQ skipscroll
INC scrollX

skipscroll: 

 LDA scrollX
 STA PPUSCROLL
 LDA #$00
 STA PPUSCROLL

  RTI

irq:
  RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin "mario0.chr"
.incbin "aiv256.chr"