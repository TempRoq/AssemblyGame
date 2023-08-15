*-----------------------------------------------------------
* Title      : Player Stuff
* Written by : Anthony Pizzigoni
* Date       : 6-29-2023
* Description: Player functionality
*-----------------------------------------------------------
PLAYER_SPEED_NORMAL         EQU     8
PLAYER_SPEED_FOCUS          EQU     12
PLAYER_GUN                  EQU     $D0
PLAYER_SWORD_DAMAGE         EQU     $FF


;READ THE NOTES AT THE BOTTOM ABOVE MOVEMENT TABLE
     
PLAYER_UPDATE:



        
        lea     ET_PLAYER_START, a0
        
        move.b  GET_INFO(a0), d0
        cmpi.b  #STATUS_ALIVE, d0
        beq     PLAYER_IS_ALIVE
        
        
        ;SET GAME STATUS TO BE MAIN MENU OR HIGH SCORE
        
        
        rts
        
        PLAYER_IS_ALIVE:
        move.l  a0, -(SP)
        jsr INVAL_OBJECT 
        move.l  (SP)+, a0
        lea     ACTION_INPUT, a1
        move.l  (a1), d2                    ;all action inputs just pressed down this frame are in d2
        
        ;Determining what velocity to store for the player, focus velocity or default.
        move.b  #PLAYER_SPEED_NORMAL, GET_VELOCITY(a0)
        btst    #BIT_OFFSET_FOCUS, d2
        beq     PLAYER_NORMAL_SPEED
        move.b  #PLAYER_SPEED_FOCUS, GET_VELOCITY(a0)      
        PLAYER_NORMAL_SPEED: 
        
        lea     ACTION_INPUT_DOWN, a1
        move.l  (a1), d2
        btst    #BIT_OFFSET_PAUSE, d2
        beq     NO_PAUSE_INPUT
        lea     GAME_STATE, a1
        move.b  #GAME_STATE_PAUSED, (a1)
        rts 
        NO_PAUSE_INPUT:
      
        
        ;Player shoot
        btst    #BIT_OFFSET_SHOOT, d2
        beq     PLAYER_DONT_FIRE
        move.l  GET_POSITION(a0), -(SP)
        move.w  #$05A0, -(SP)           
        move.w  #1, -(SP)           
        jsr     SPAWN_FORMATION
        adda.l  #8, SP
        bra     PLAYER_DONT_SECONDARY
        PLAYER_DONT_FIRE:
        ;Player shoot... again!
        btst    #BIT_OFFSET_SECONDARY, d2
        beq     PLAYER_DONT_SECONDARY
        move.l  GET_POSITION(a0), -(SP)
        move.w  #$05A0, -(SP)           
        move.w  #1, -(SP)           
        jsr     SPAWN_FORMATION
        adda.l  #8, SP
        PLAYER_DONT_SECONDARY:
        
        ;checking directional button bits, using them to form a 1 byte value to serve as
        ;an offset in the movement table. Table holds normalized directional value in a long
        
        lea     ET_PLAYER_START, a0
        lea     MOVE_INPUT, a1
        lea     DELTA_TIME, a2
        move.l  (a2), d3
        move.l  (a1), d1
        
        clr.l   d0
        lea     MOVEMENT_TABLE, a1
        btst    #BIT_OFFSET_DOWN, d1
        beq     SKIP_DOWN
        bset    #2, d0
        SKIP_DOWN:
        btst    #BIT_OFFSET_UP, d1
        beq     SKIP_UP
        bset    #3, d0
        SKIP_UP:
        btst    #BIT_OFFSET_RIGHT, d1
        beq     SKIP_RIGHT
        bset    #4, d0
        SKIP_RIGHT:
        btst    #BIT_OFFSET_LEFT, d1
        beq     SKIP_LEFT
        bset    #5, d0
        SKIP_LEFT:
                      
        move.l  (a1, d0), d1    ;overwrite d1 with movement vector and be prepared to add it to stage boundaries
        move.b  GET_VELOCITY(a0), d0         ;Velocity
        move.l  GET_POSITION(a0), d2         ;Position (Y, X)
        muls.w  d1, d0                        ;Save the x velocity in d0
        asr.l   #2, d0                        ;d0 has 4 fractional bits now after multiplying velocity (2) and moveVector (2). shift right twice.
        muls.w  d3, d0
        asr.l   #3, d0
        add.w   d0, d2
        bge     NO_CLAMP_X_MIN
        clr.w   d2
        NO_CLAMP_X_MIN:
        swap    d1                            ;add the speed to X position, then clamp it between 0 and STAGE_BORDER_X_MAX - Width
        swap    d2
        clr.w   d0
        move.b  GET_VELOCITY(a0), d0
        muls.w  d1, d0                         ;d1 can be overwritten here forward
        asr.l  #2, d0                          ;adding the velocity
        muls.w  d3, d0
        asr.l   #3, d0
        add.w   d0, d2          
        bgt     NO_CLAMP_Y_MIN
        clr.w   d2
        NO_CLAMP_Y_MIN:
        move.w  #STAGE_BORDER_Y_MAX, d1        ;d1 will be the bounds of the stage - player's height
        sub.w   GET_SIZE(a0), d1
        cmp.w   d1, d2                         ;d2 is position
        blt     NO_CLAMP_Y_MAX
        move.w  d1, d2
        NO_CLAMP_Y_MAX:     
        swap    d2 
        swap    d1
        move.w  #STAGE_BORDER_X_MAX, d1
        sub.w   (GET_SIZE+2)(a0), d1
        cmp.w   d1, d2           
        blt     NO_CLAMP_X_MAX
        move.w  d1, d2  
        NO_CLAMP_X_MAX:     
        move.l  d2, GET_POSITION(a0)           ;NEW POSITION!
        move.l  d2, d0
        jsr SET_COLLISION_ZONE



*                                           
*                DRAWING TO SCREEN
*       
        lea     ET_PLAYER_START, a0
        jsr     DRAW_PLAYER
*        clr.l   d5
        ;d5 will have something with animations for it.
*        move.l  GET_SIZE(a0), d6 
*        move.l  GET_POSITION(a0), d7
*        lsl.l   #PIXEL_SHIFT, d7  
*        lea     SPR_PLAYER, a0
                
        ;jsr DISPLAY_BMP_DATA
        
        ;SEE WHAT NEEDS TO BE RESTORED HERE
        
        rts
        
       
    
    
MOVEMENT_TABLE                       ;upper word = y, lower word = x multiplier. this is basically a signed vector2 with 2 fractional bits.
    dc.l        $00000000            ;you pressed NOTHING! You LOSE. GOOD DAY, SIR.
    dc.l        $00040000            ;down    
    dc.l        $FFFC0000            ;up
    dc.l        $00000000            ;up and down; nothing!
    dc.l        $00000004            ;right
    dc.l        $00030003            ;right and down!
    dc.l        $FFFD0003            ;right and up
    dc.l        $00000004            ;right and up and down = only right
    dc.l        $0000FFFC            ;left
    dc.l        $0003FFFD            ;downleft
    dc.l        $FFFDFFFD            ;upleft
    dc.l        $0000FFFC            ;downupleft
    dc.l        $00000000            ;leftright
    dc.l        $00040000            ;lrdown    
    dc.l        $FFFC0000            ;lrup
    dc.l        $00000000            ;lrup and down; nothing!
 













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
