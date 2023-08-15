*-----------------------------------------------------------
* Title      :  Debug
* Written by :
* Date       :
* Description:  Holds functions specifically for when debug mode is on. No functions take any arguments.
*-----------------------------------------------------------

SPAWN_DEBUG_ENEMIES:
    move.l  #0, -(SP)
    jsr     SET_STAGE_NUMBER
    adda.l  #4, SP
    jsr     SPAWN_NEXT_WAVE

*    move.w  #85, -(SP)
*    move.w  #60, -(SP)
*    move.w  #$0000, -(SP)           ;theta
*    move.w  #0, -(SP)           ;Formation offset
*    
*    jsr     SPAWN_FORMATION
*    
*    adda.l  #8, SP
*    
*    move.w  #85, -(SP)
*    move.w  #60, -(SP)
*    move.w  #$05A0, -(SP)           ;theta
*    move.w  #0, -(SP)           ;Formation offset
*    
*    jsr     SPAWN_FORMATION
*    
*    adda.l  #8, SP

*    
*    move.l  #$000005a0, -(SP)               ;No DelTheta + Theta
*    move.l  #$00000040, -(SP)               ;No ACC + Velocity
*    move.l  #0, -(SP)               ;Debug Path
*    move.l  #0, -(SP)               ;No Theta Initial
*    move.w  #80, -(SP)    ;Spawn Point X
*    move.w  #80, -(SP)    ;Spawn Point Y
*    move.l  #EDT_OFFSET_SLIME, -(SP)
*    jsr     TRY_SPAWN_ENTITY
*    adda.l  #24, SP
*    
*    move.l  #$00000000, -(SP)               ;No DelTheta + Theta
*    move.l  #$00000040, -(SP)               ;No ACC + Velocity
*    move.l  #0, -(SP)               ;Debug Path
*    move.l  #0, -(SP)               ;No Theta Initial
*    move.w  #80, -(SP)    ;Spawn Point X
*    move.w  #80, -(SP)    ;Spawn Point Y
*    move.l  #EDT_OFFSET_SLIME, -(SP)
*    jsr     TRY_SPAWN_ENTITY
*    adda.l  #24, SP
*    
*    move.l  #$00000000, -(SP)               ;No DelTheta + Theta
*    move.l  #$00000040, -(SP)               ;No ACC + Velocity
*    move.l  #0, -(SP)               ;Debug Path
*    move.l  #0, -(SP)               ;No Theta Initial
*    move.w  #85, -(SP)    ;Spawn Point X
*    move.w  #100, -(SP)    ;Spawn Point Y
*    move.l  #EDT_OFFSET_SLIME, -(SP)
*    jsr     TRY_SPAWN_ENTITY
*    adda.l  #24, SP
*    
*    move.l  #$00000000, -(SP)               ;No DelTheta + Theta
*    move.l  #$00000040, -(SP)               ;No ACC + Velocity
*    move.l  #0, -(SP)               ;Debug Path
*    move.l  #0, -(SP)               ;No Theta Initial
*    move.w  #85, -(SP)    ;Spawn Point X
*    move.w  #90, -(SP)    ;Spawn Point Y
*    move.l  #EDT_OFFSET_SLIME, -(SP)
*    jsr     TRY_SPAWN_ENTITY
*    adda.l  #24, SP
    rts
    
    
    
    
    
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
