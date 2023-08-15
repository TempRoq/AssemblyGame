*-----------------------------------------------------------
* Title      : Input_GETTER
* Written by : Anthony Pizzigoni
* Date       : 6-28-23
* Description: Reads the player's input and holds relevant controls and bit offsets for them.
*-----------------------------------------------------------
KEYCODE_FIRE        EQU     'Z'
KEYCODE_SECONDARY   EQU     'X'
KEYCODE_PAUSE       EQU     $0D
KEYCODE_FOCUS       EQU     $10

KEYCODE_LEFT        EQU     $25
KEYCODE_RIGHT       EQU     $27
KEYCODE_UP          EQU     $26
KEYCODE_DOWN        EQU     $28

TRAP_CODE_INPUT     EQU     19

BIT_OFFSET_SHOOT    EQU     24
BIT_OFFSET_SECONDARY   EQU  16
BIT_OFFSET_PAUSE    EQU     8
BIT_OFFSET_FOCUS    EQU     0

BIT_OFFSET_LEFT     EQU     24
BIT_OFFSET_RIGHT    EQU     16
BIT_OFFSET_UP       EQU     8
BIT_OFFSET_DOWN     EQU     0


    
    READ_INPUT:
    
    
    
        ;Setting input status for Firing, secondary fire, pausing, and focusing.
        clr.l   d4
        lea     ACTION_INPUT, a0
        lea     ACTION_INPUT_DOWN, a1
        move.l  (a0), d3                    ;d3 is the old action inputs. 
        move.w  #19, d0
     
        move.l  #KEYCODE_FIRE<<BIT_OFFSET_SHOOT+KEYCODE_SECONDARY<<BIT_OFFSET_SECONDARY+KEYCODE_PAUSE<<BIT_OFFSET_PAUSE+KEYCODE_FOCUS<<BIT_OFFSET_FOCUS, d1         ;keypresses for actions(shoot, secondary, pause, and focus
        trap    #15
        
        btst    #BIT_OFFSET_SHOOT, d3       ;check if old button was pressed down last frame. if so, not down.
        bne     NO_SHOOT_DOWN
        btst    #BIT_OFFSET_SHOOT, d1       ;check if new button is not pressed down this frame. if so, not down
        beq     NO_SHOOT_DOWN
        bset    #BIT_OFFSET_SHOOT, d4       ;d4 is going to be our "ActionInputDown" long.
        NO_SHOOT_DOWN:
        
        btst    #BIT_OFFSET_SECONDARY, d3
        bne     NO_SHOOT_SECONDARY
        btst    #BIT_OFFSET_SECONDARY, d1
        beq     NO_SHOOT_SECONDARY
        bset    #BIT_OFFSET_SECONDARY, d4
        
        NO_SHOOT_SECONDARY:
        
        btst    #BIT_OFFSET_PAUSE, d3
        bne     NO_PAUSE_DOWN
        btst    #BIT_OFFSET_PAUSE, d1
        beq     NO_PAUSE_DOWN
        bset    #BIT_OFFSET_PAUSE, d4
 
        NO_PAUSE_DOWN:
        
        btst    #BIT_OFFSET_FOCUS, d3
        bne     NO_FOCUS_DOWN
        btst    #BIT_OFFSET_FOCUS, d1
        beq     NO_FOCUS_DOWN      
        bset    #BIT_OFFSET_FOCUS, d4
        
        NO_FOCUS_DOWN:   
        move.l  d1, (a0)
        move.l  d4, (a1)
        
        
        ;SETTING INPUTS FOR MOVEMENT. Same as above, with setting button_down and normal button_up.
        lea     MOVE_INPUT, a0
        lea     MOVE_INPUT_DOWN, a1
        move.l  (a0), d3
        clr.l   d4 
        
        
        move.l  #KEYCODE_LEFT<<BIT_OFFSET_LEFT+KEYCODE_RIGHT<<BIT_OFFSET_RIGHT+KEYCODE_UP<<BIT_OFFSET_UP+KEYCODE_DOWN+BIT_OFFSET_DOWN<<BIT_OFFSET_DOWN, d1          ;keypresses for moving (left, right, up, down)
        trap    #15
        
        btst    #KEYCODE_LEFT, d1
        bne     NO_LEFT_DOWN
        btst    #KEYCODE_LEFT, d3
        beq     NO_LEFT_DOWN
        bset    #KEYCODE_LEFT, d4
        
        NO_LEFT_DOWN:
        
        btst    #KEYCODE_RIGHT, d1
        bne     NO_RIGHT_DOWN
        btst    #KEYCODE_RIGHT, d3
        beq     NO_RIGHT_DOWN
        bset    #KEYCODE_RIGHT, d4
        
        NO_RIGHT_DOWN:
        
        btst    #KEYCODE_UP, d1
        bne     NO_UP_DOWN
        btst    #KEYCODE_UP, d3
        beq     NO_UP_DOWN
        bset    #KEYCODE_UP, d4
        
        NO_UP_DOWN:
        
        btst    #KEYCODE_DOWN, d1
        bne     NO_DOWN_DOWN
        btst    #KEYCODE_DOWN, d3
        beq     NO_DOWN_DOWN
        bset    #KEYCODE_DOWN, d4
        
        NO_DOWN_DOWN:
       
        move.l  d1, (a0)
        move.l  d4, (a1)
        
        rts


ACTION_INPUT        dc.l    0
ACTION_INPUT_DOWN   dc.l    0
MOVE_INPUT          dc.l    0
MOVE_INPUT_DOWN     dc.l    0





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
