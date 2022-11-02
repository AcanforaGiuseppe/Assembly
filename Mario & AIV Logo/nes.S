.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define JOYPAD1 $4016
.define JOYPAD2 $4017

.define SCROLL_X $00
.define buttons $01

start:
    LDA #%10000000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$19
    STA PPUDATA
    LDA #$05
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$0F
    STA PPUDATA

    ; load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$21
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$24
    STA PPUDATA

    ; load second sprite palette
    LDA #$16
    STA PPUDATA
    LDA #$17
    STA PPUDATA
    LDA #$18
    STA PPUDATA
    LDA #$19
    STA PPUDATA

    ; load background tiles
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$02
    STA PPUDATA
    LDA #$FD
    STA PPUDATA
    LDA #$FE
    STA PPUDATA

    LDA #0
    STA OAMADDR
    LDA #$22
    STA OAMDATA
    LDA #$02
    STA OAMDATA
    LDA #%10000001
    STA OAMDATA
    LDA #$22
    STA OAMDATA

    LDA #4
    STA OAMADDR
    LDA #$00
    STA OAMDATA
    LDA #$F6
    STA OAMDATA
    LDA #%00000000
    STA OAMDATA
    LDA #$11
    STA OAMDATA

loop:
    JMP loop

readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL buttons
    BCC joyloop
    RTS

nmi:
    PHA
    JSR readjoy
    PLA
    LDA buttons
    AND #%00000001
    BEQ loadscroll
    INC SCROLL_X
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    STA OAMDATA
    LDA #4
    STA OAMADDR
    LDA SCROLL_X
    STA OAMDATA
loadscroll:
    LDA SCROLL_X
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL
    RTI

irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin mario0.chr
.incbin aiv256.chr