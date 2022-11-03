.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014
.define JOYPAD1 $4016
.define NAMETABLE0 #$20
.define NAMETABLE1 #$24
.define NAMETABLE_START #0
.define PALET #$3F
.define BACKGROUND_PALETTES #$00
.define SPRITES_PALETTES #$10
.define UPDATES $00
.define BUTTONS $01
.define SCROLLX $02
.define BGCOUNTER $03
.define BACKGROUND_TABLE_COUNTER $04
.define BACKGROUND_LINE_COUNTER $05
.define MARIOX $06
.define MARIOY $07
.define SPRITES #$02
.define YELLOW #$28
.define PURPLE #$23
.define SKINCOLOR #$18
.define RED #$15
.define BLACK #$3F

.org $8000
LDX #$FF
TXS

start:
    LDA #%10010000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    LDA #0
    STA UPDATES
    LDA #$70
    STA MARIOY
    LDA #$78
    STA MARIOX

setSprites:
    LDX #0
    setSpritesLoop:
        
setPalettes:
    ; palette for sprites
    LDA PALET
    STA PPUADDR
    LDA SPRITES_PALETTES
    STA PPUADDR
    LDA BLACK
    STA PPUDATA
    LDA RED
    STA PPUDATA
    LDA SKINCOLOR
    STA PPUDATA
    LDA YELLOW
    STA PPUDATA
    ; palette for background
    LDA PALET
    STA PPUADDR
    LDA BACKGROUND_PALETTES
    STA PPUADDR
    LDA BLACK
    STA PPUDATA
    LDA PURPLE
    STA PPUDATA
    LDA YELLOW
    STA PPUDATA
    LDA PURPLE
    STA PPUDATA
   
setBackground:
    ; NAMETABLE0
    LDA NAMETABLE0
    STA PPUADDR
    LDA NAMETABLE_START
    STA PPUADDR
    LDA #0
    STA BGCOUNTER
    STA BACKGROUND_TABLE_COUNTER
    STA BACKGROUND_LINE_COUNTER
    JSR drawBackground
    ; NAMETABLE1
    LDA NAMETABLE1
    STA PPUADDR
    LDA NAMETABLE_START
    STA PPUADDR
    LDA #0
    STA BGCOUNTER
    STA BACKGROUND_TABLE_COUNTER
    STA BACKGROUND_LINE_COUNTER
    JSR drawBackground

loop:
    LDA UPDATES
    CMP #1
    BNE loop
    DEC UPDATES
    JSR drawMario
    JMP loop

drawBackground:
    LDA BGCOUNTER
    LDX BACKGROUND_LINE_COUNTER
    CPX #$0F
    BMI drawLines
    BEQ drawLines
    drawWhite:
    LDA #$00
    STA PPUDATA
    CPX #$1F
    BEQ resetLineCounter
    INC BACKGROUND_LINE_COUNTER
    INC BGCOUNTER
    JMP drawBackground
    drawLines:
    LDA BACKGROUND_TABLE_COUNTER
    STA PPUDATA
    CMP #$FF
    BEQ backgroundExit
    INC BACKGROUND_TABLE_COUNTER
    INC BGCOUNTER
    INC BACKGROUND_LINE_COUNTER
    JMP drawBackground

    resetLineCounter:
        LDA #0
        STA BACKGROUND_LINE_COUNTER
        JMP drawBackground

    backgroundExit:
    RTS

drawMario:
    LDX MARIOX
    LDY MARIOY
    LDA #$00
    STA OAMADDR
    TYA 
    STA OAMDATA
    LDA #$32
    STA OAMDATA
    LDA #0
    STA OAMDATA
    TXA 
    STA OAMDATA
    ADC #$07
    TAX 
    TYA 
    STA OAMDATA
    ADC #$08
    TAY 
    LDA #$33
    STA OAMDATA
    LDA #0
    STA OAMDATA
    TXA 
    STA OAMDATA
    SBC #$07
    TAX 
    TYA 
    STA OAMDATA
    LDA #$42
    STA OAMDATA
    LDA #0
    STA OAMDATA
    TXA 
    STA OAMDATA
    ADC #$07
    TAX 
    TYA 
    STA OAMDATA
    ADC #$08
    TAY 
    LDA #$43
    STA OAMDATA
    LDA #0
    STA OAMDATA
    TXA 
    STA OAMDATA
    SBC #$07
    TAX 
    RTS

readjoy:
    LDA #$01
    STA JOYPAD1
    STA BUTTONS
    LSR a
    STA JOYPAD1

joyloop:
    LDA JOYPAD1
    LSR a
    ROL BUTTONS
    BCC joyloop
    RTS

nmi:
    PHA 
    JSR readjoy
    LDA BUTTONS

    scrolling:
        CMP #$01
        BEQ rightKey
        CMP #$02
        BEQ leftKey
        CMP #$04
        BEQ downMovement
        CMP #$08
        BEQ upMovement
        JMP scrollEnds

        leftKey:
            LDA MARIOX
            CMP #$78
            bpl leftMovement
            JMP decrementScroll 

        rightKey:
            LDA MARIOX
            CMP #$78
            BMI rightMovement
            JMP addingScroll

        addingScroll:
            LDA SCROLLX
            CMP #$ff
            BEQ rightMovement
            INC SCROLLX
            LDA SCROLLX
            STA PPUSCROLL
            LDA #$00
            STA PPUSCROLL
            JMP scrollEnds

        decrementScroll:
            LDA SCROLLX
            CMP #$00
            BEQ leftMovement
            DEC SCROLLX
            LDA SCROLLX
            STA PPUSCROLL
            LDA #$00
            STA PPUSCROLL
            JMP scrollEnds

        upMovement:
            LDA MARIOY
            CMP #$00
            BEQ scrollEnds
            DEC MARIOY
            JMP scrollEnds

        downMovement:
            LDA MARIOY
            CMP #$DF
            BEQ scrollEnds
            INC MARIOY
            JMP scrollEnds

        leftMovement:
            LDA MARIOX
            CMP #$00
            BEQ scrollEnds
            DEC MARIOX
            JMP scrollEnds

        rightMovement:
            LDA MARIOX
            CMP #$EF
            BEQ scrollEnds
            INC MARIOX
            JMP scrollEnds

    scrollEnds:
    INC UPDATES
    PLA 
    RTI 

irq:
RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin "mario0.chr"
.incbin "aiv256.chr"