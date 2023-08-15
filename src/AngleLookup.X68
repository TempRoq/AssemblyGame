*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:

*    When calling a sin value, call sin + an offset = the angle in degrees.
*        For instance, sin(45) is the same as calling 45(SIN_VALUE)
*    When calling a cos value, call cos + a negative offset corresponding to the angles in degrees
*        For instance, cos(45) is the same as calling
*    These use (8) decimal bits
*-----------------------------------------------------------
         ; first instruction of program



;4(SP) = angle measure between 0 and 360 ($0 and $168)
;Returns the movement vector, and overwrites 4(SP)

VECTOR_FRAC_BITS        EQU     4
NUM_ANGLES              EQU     90

GET_VECTOR:
    move.l  4(SP), d0
    ;360 degrees, 90 accounted for angles along the unit circle, so we bitshift right by 2 to divide by 4
    ;BUT we have words, which are size 2, so we would bit shift left by 1 to multiply by 2 bytes for the offset
    ;together, we just bitshift to the right by 1 bit and get the angle at that offset!
    ;However, doing it in this way makes it so we could get an odd number. instead of bit shifting right then left,
    ;we just bit shift right and clear the rightmost bit to get the same effect.
    
    
    lsr.w   #1, d0
    bclr.l  #0, d0
    
*    divu.w  #NUM_ANGLES, d0         ;upper word will have remainder, this has the quotient.
*    swap    d0
*    clr.l   d1
*    move.w  d0, d1          ;move remainder into d0
*    lsr.l   #1, d1
*    swap    d0

    lea     SIN_VALUE, a0
    move.w  (a0,d0),d1 
    swap    d1
    
    lea     COS_VALUE, a0
    move.w  (a0, d0), d1
    move.l  d1, 4(SP)  
    rts
       
    


;All values in the table use 8 decimal bits and each the difference between each offset is 4 degrees
SIN_VALUE:
    
	dc.w    $000
	dc.w    $011
	dc.w    $023
	dc.w    $035
	dc.w    $046
	dc.w    $057
	dc.w    $068
	dc.w    $078
	dc.w    $087
	dc.w    $096
	dc.w    $0A4
	dc.w    $0B1
	dc.w    $0BE
	dc.w    $0C9
	dc.w    $0D4
	dc.w    $0DD
	dc.w    $0E6
	dc.w    $0ED
	dc.w    $0F3
	dc.w    $0F8
	dc.w    $0FC
	dc.w    $0FE
	dc.w    $100        ;Where 90 will be
	dc.w    $0FF
	dc.w    $0FE
	dc.w    $0FC
	dc.w    $0F8
	dc.w    $0F3
	dc.w    $0ED
	dc.w    $0E6
	dc.w    $0DD
	dc.w    $0D4
	dc.w    $0C9
	dc.w    $0BE
	dc.w    $0B1
	dc.w    $0A4
	dc.w    $096
	dc.w    $087
	dc.w    $078
	dc.w    $068
	dc.w    $057
	dc.w    $046
	dc.w    $035
	dc.w    $023
	dc.w    $011
	dc.w    $000
	dc.w    $FFEF
	dc.w    $FFDD
	dc.w    $FFCB
	dc.w    $FFBA
	dc.w    $FFA9
	dc.w    $FF98
	dc.w    $FF88
	dc.w    $FF79
	dc.w    $FF6A
	dc.w    $FF5C
	dc.w    $FF4F
	dc.w    $FF42
	dc.w    $FF37
	dc.w    $FF2C
	dc.w    $FF23
	dc.w    $FF1A
	dc.w    $FF13
	dc.w    $FF0D
	dc.w    $FF08
	dc.w    $FF04
	dc.w    $FF02
	dc.w    $FF00
	dc.w    $FF01
	dc.w    $FF02
	dc.w    $FF04
	dc.w    $FF08
	dc.w    $FF0D
	dc.w    $FF13
	dc.w    $FF1A
	dc.w    $FF23
	dc.w    $FF2C
	dc.w    $FF37
	dc.w    $FF42
	dc.w    $FF4F
	dc.w    $FF5C
	dc.w    $FF6A
	dc.w    $FF79
	dc.w    $FF88
	dc.w    $FF98
	dc.w    $FFA9
	dc.w    $FFBA
	dc.w    $FFCB
	dc.w    $FFDD
	dc.w    $FFEF
COS_VALUE:
	dc.w    $100
	dc.w    $0FF
	dc.w    $0FD
	dc.w    $0FA
	dc.w    $0F6
	dc.w    $0F0
	dc.w    $0E9
	dc.w    $0E2
	dc.w    $0D9
	dc.w    $0CF
	dc.w    $0C4
	dc.w    $0B8
	dc.w    $0AB
	dc.w    $09D
	dc.w    $08F
	dc.w    $07F
	dc.w    $070
	dc.w    $05F
	dc.w    $04F
	dc.w    $03D
	dc.w    $02C
	dc.w    $01A
	dc.w    $000
	dc.w    $FFF8
	dc.w    $FFE6
	dc.w    $FFD4
	dc.w    $FFC3
	dc.w    $FFB1
	dc.w    $FFA1
	dc.w    $FF90
	dc.w    $FF80
	dc.w    $FF71
	dc.w    $FF63
	dc.w    $FF55
	dc.w    $FF48
	dc.w    $FF3C
	dc.w    $FF31
	dc.w    $FF27
	dc.w    $FF1E
	dc.w    $FF17
	dc.w    $FF10
	dc.w    $FF0A
	dc.w    $FF06
	dc.w    $FF03
	dc.w    $FF01
	dc.w    $FF00
	dc.w    $FF01
	dc.w    $FF03
	dc.w    $FF06
	dc.w    $FF0A
	dc.w    $FF10
	dc.w    $FF17
	dc.w    $FF1E
	dc.w    $FF27
	dc.w    $FF31
	dc.w    $FF3C
	dc.w    $FF48
	dc.w    $FF55
	dc.w    $FF63
	dc.w    $FF71
	dc.w    $FF81
	dc.w    $FF90
	dc.w    $FFA1
	dc.w    $FFB1
	dc.w    $FFC3
	dc.w    $FFD4
	dc.w    $FFE6
	dc.w    $000               ;270 degrees
	dc.w    $008
	dc.w    $01A
	dc.w    $02C
	dc.w    $03D
	dc.w    $04F
	dc.w    $05F
	dc.w    $070
	dc.w    $080
	dc.w    $08F
	dc.w    $09D
	dc.w    $0AB
	dc.w    $0B8
	dc.w    $0C4
	dc.w    $0CF
	dc.w    $0D9
	dc.w    $0E2
	dc.w    $0E9
	dc.w    $0F0
	dc.w    $0F6
	dc.w    $0FA
	dc.w    $0FD
	dc.w    $0FF


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
