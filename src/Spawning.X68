*-----------------------------------------------------------
* Title      : SPAWNING
* Written by : ANTHONY PIZZIGONI
* Date       : 6-26-23
* Description: Level Spawning Algorithm. Takes in a series of 8 byte instructions that tell it when to spawn formations, with what path, and what will spawn the next wave.
*-----------------------------------------------------------


SPAWN_WAVE_SIZE             EQU     8

GET_SPAWN_HAS_NEXT_WAVE     EQU     0       ;if this is 00, then don't keep going
GET_SPAWN_FORMATION         EQU     1 
GET_SPAWN_POSITION_Y        EQU     2      
GET_SPAWN_POSITION_X        EQU     3
GET_SPAWN_THETA             EQU     4
GET_SPAWN_DELAY             EQU     6       ;how long until I spawn next wave?       
       
LEVEL_FLAG_INCOMPLETE         EQU       0
LEVEL_FLAG_COMPLETE           EQU       1
;This is called once the timer is activated
SPAWN_NEXT_WAVE:
    
    lea LEVEL_END_FLAG, a0
    move.b  (a0), d0
    cmpi.b  #LEVEL_FLAG_INCOMPLETE, d0
    beq     LEVEL_NOT_COMPLETED
    rts
    
    LEVEL_NOT_COMPLETED:
    clr.l   d0
    clr.l   d1
    clr.l   d2
    
    ;GETTING THE CURRENT WAVE TO SPAWN, AS WELL AS THE FORMATION OFFSET
    lea     CURR_LEVEL, a0
    move.b  (a0), d0
    lsl.w   #4, d0
    lea     LEVEL_DATA, a0
    move.l  (a0, d0), a0         ;a0 Holds the reference to the level binary.
    lea     CURR_FORMATION_SPAWN, a1
    clr.l   d0
    move.b  (a1), d0
    lsl.w   #3, d0               ;size of 8, so bit shift left by 3              
    adda.l   d0, a0              ;a0 Holds the reference to the current wave to spawn.
    addi.b  #1, (a1)             ;Updating CURR_FORMATION

    ;SPAWNING THE CURRENT FORMATION

    move.l  a0, -(SP)   ;not needed for function, more for backup.
    
    move.b GET_SPAWN_POSITION_Y(a0), d1
    swap    d1
    move.b  GET_SPAWN_POSITION_X(a0), d1
    move.l  d1, -(SP)
    move.w  GET_SPAWN_THETA(a0), -(SP)
    move.b  GET_SPAWN_FORMATION(a0), d2
    move.w  d2, -(SP)
    jsr     SPAWN_FORMATION
    adda.l  #8, SP
    move.l  (SP)+, a0  
    
    ;DEALING WITH NEXT WAVES, most is very self explanatory
    clr.l   d0
    
    move.b  GET_SPAWN_HAS_NEXT_WAVE(a0), d0
    beq     NO_NEXT_WAVE

    move.w  GET_SPAWN_DELAY(a0), d0
    move.l  #0, -(SP)
    move.l  #0, -(SP)
    lea     SPAWN_NEXT_WAVE, a1
    move.l  a1, -(SP) 
    move.l  d0, -(SP)
    jsr SET_TIMER
    adda.l  #16, SP
    rts 
    
    NO_NEXT_WAVE:
    lea LEVEL_END_FLAG, a0
    move.b  #LEVEL_FLAG_COMPLETE, (a0)
    rts 

;4(SP) = level 
;sets the current level to whatever is specified and resets the level   
SET_STAGE_NUMBER:
    lea CURR_LEVEL, a0
    move.l  4(SP), d0
    move.b  d0, (a0)
;move everything back to the initial 0 values.
RESET_LEVEL_SPAWNING:
    lea LEVEL_END_FLAG, a0
    move.b  #LEVEL_FLAG_INCOMPLETE, (a0)
    lea CURR_FORMATION_SPAWN, a0
    move.l  #0, (a0)
    rts

LEVEL_END_FLAG          dc.b    0           ;set to 1 once the level is done spawning stuff.
CURR_LEVEL              dc.b    0
CURR_FORMATION_SPAWN    dc.l    0

DEBUG_LEVEL     incbin      'data/stages/debug_stage'
STAGE_1         ;incbin      'data/stages/stage_1'
STAGE_2         ;incbin      'data/stages/stage_2'
STAGE_3         ;incbin      'data/stages/stage_3'
STAGE_4         ;incbin      'data/stages/stage_4'

LEVEL_DATA
    dc.l    DEBUG_LEVEL
    dc.l    STAGE_1
    dc.l    STAGE_2
    dc.l    STAGE_3
    dc.l    STAGE_4
;here's where level data is going to be stored at.


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
