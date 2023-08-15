*-----------------------------------------------------------
* Title      : Operations
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

GS_PLAY_TOP_LEFT_X      EQU     0
GS_PLAY_TOP_LEFT_Y      EQU     0

GS_PLAY_BOT_RIGHT_X     EQU     186
GS_PLAY_BOT_RIGHT_Y     EQU     240

GS_PAUSE_TOP_LEFT_X     EQU     64
GS_PAUSE_TOP_LEFT_Y     EQU     60

GS_PAUSE_BOT_RIGHT_X    EQU     192
GS_PAUSE_BOT_RIGHT_Y    EQU     180




CLEAN_SCREEN:

    ;swap buffer
    move.w  #94, d0
    trap    #15

    ;drawing a black block over part of the screen to "clear it"
    clr.l   d1
    move.w  #80, d0
    trap    #15
    move.w  #81,d0
    trap    #15
    
    lea GAME_STATE, a0
    move.b  (a0), d0
    cmpi.b  #GAME_STATE_PLAYING, d0
    beq     CLEAN_PLAYING_SCREEN
    cmpi.b  #GAME_STATE_PAUSED, d0
    beq     CLEAN_PAUSE_SCREEN
    cmpi.b  #GAME_STATE_HI_SCORE, d0
    beq     CLEAN_HI_SCORE_SCREEN
    
    CLEAN_MENU_SCREEN:
        move.b  #11, d0
        move.w  #$FF00, d1
        trap    #15
        rts
    CLEAN_PLAYING_SCREEN:
        rts
        move.w  #GS_PLAY_TOP_LEFT_X, d1
        move.w  #GS_PLAY_TOP_LEFT_Y, d2 
        move.w  #GS_PLAY_BOT_RIGHT_X, d3
        move.w  #GS_PLAY_BOT_RIGHT_Y, d4
        
        lsl.w   #2, d1
        lsl.w   #2, d2
        lsl.w   #2, d3
        lsl.w   #2, d4
        move.b  #87, d0
        trap    #15
        rts
    CLEAN_PAUSE_SCREEN:
        move.w  #GS_PAUSE_TOP_LEFT_X, d1
        move.w  #GS_PAUSE_TOP_LEFT_Y, d2
        move.w  #GS_PAUSE_BOT_RIGHT_X, d3
        move.w  #GS_PAUSE_BOT_RIGHT_Y, d4
        
        lsl.w   #2, d1
        lsl.w   #2, d2
        lsl.w   #2, d3
        lsl.w   #2, d4
        move.b  #87, d0
        trap    #15
        rts
    CLEAN_HI_SCORE_SCREEN:
        ;I'll figure something out here... eventually...
        rts
    
    
    
UPDATE_SCORE:
    rts
    

;d5 is the position, d6 is the offset, d7 is the size, trap code is already set.


DRAW_SCALED_FROM_POSITION:
    move.w  d6, d1      ;lo x
    move.w  d6, d3      ;hi x
    subi.w  #1, d3
    swap.w  d6      
    move.w  d6, d2      ;lo y
    move.w  d6, d4      ;hi y
    subi.w  #1, d4
    add.w   d7, d3      ;adding x size
    swap    d7
    add.w   d7, d4      ;adding y size
    add.w   d5, d1      ;adding offsets
    add.w   d5, d3
    swap    d5
    add.w   d5, d2
    add.w   d5, d4
    swap    d5
    jsr DRAW_SCALED_SHAPE
    rts

;d0, d1, d2, d3, and d4 are set. This just multiplies their sizes by the pixel size and puts them in the right spot.



DRAW_SCALED_SHAPE:
    lsl.l   #PIXEL_SHIFT, d1
    lsl.l   #PIXEL_SHIFT, d2 
    lsl.l   #PIXEL_SHIFT, d3 
    lsl.l   #PIXEL_SHIFT, d4 
    trap    #15
    rts

;4(SP) is the reference to the object to inval.
INVAL_OBJECT:
    move.l  4(SP), a0
    move.l  #80, d0
    clr.l   d1
    trap    #15
    move.b  #81, d0
    trap    #15
        
    move.b  #87, d0
        
        
    move.w  GET_POSITION(a0), d2
    move.w  d2, d4
    move.w  (GET_POSITION+2)(a0), d1
    move.w  d1, d3
    add.w   GET_SIZE(a0), d4
    add.w   (GET_SIZE+2)(a0), d3 
        
    jsr DRAW_SCALED_SHAPE
    rts

;a0 is the location of the entity in memory, d0 is their new position. with X being the least significant word.
SET_COLLISION_ZONE:
    move.l  GET_POSITION(a0), d0
    clr.b   d4
    clr.l   d6
    clr.l   d5
    move.w  d0, d6      ;x
    lsl.w   #2, d6
    swap    d0
    move.w  d0, d5      ;y
    lsl.w   #2, d5      
    divu    #STAGE_BORDER_X_MAX, d6
    divu    #STAGE_BORDER_Y_MAX, d5
        
    move.b  d5, d4
    lsl.b   #2, d4
    add.b  d6, d4    
    move.b  d4, (GET_INFO+1)(a0)
    rts
    
 TEMP_SCALE_X:
    lsl.w   #2, d3
    lsl.w   #2, d1
    trap    #15
    lsr.w   #2, d3
    lsr.w   #2, d1
    rts
    
 TEMP_SCALE_Y:
    lsl.w   #2, d2
    lsl.w   #2, d4
    trap    #15
    lsr.w   #2, d2
    lsr.w   #2, d4
    rts

DRAW_GRID_LINES:
    move.b  #80, d0
    move.l  #$00808080, d1
    trap    #15
    
    move.b  #84, d0
    move.w  #0, d2
    move.w  #(STAGE_BORDER_Y_MAX<<2), d4
    
    
    move.w  #STAGE_BORDER_X_MAX, d3
    
   
    
    
    lsr.w   #1, d3
    move.w  d3, d1
    
    jsr TEMP_SCALE_X
    
    move.w  d3, d5
    lsr.w   #1, d3
    move.w  d3, d1
   
    jsr TEMP_SCALE_X
    
    add.w   d5, d3
    move.w  d3, d1
    
    jsr TEMP_SCALE_X
    
    move.w  #0, d1
    move.w  #(STAGE_BORDER_X_MAX<<2), d3
    
    move.w  #STAGE_BORDER_Y_MAX, d4
    

    
    lsr.w   #1, d4
    move.w  d4, d2
    jsr TEMP_SCALE_Y
    
    move.w  d4, d5
    lsr.w   #1, d4
    move.w  d4, d2
    
    jsr TEMP_SCALE_Y
    
    add.w   d5, d4
    move.w  d4, d2
    jsr TEMP_SCALE_Y
    rts
    
    
    
UPDATE_DELTA_TIME:
    lea     TIME_LAST_UPDATE, a0
    lea     DELTA_TIME, a1
    move.l  (a0), d2        ;storing old time, and subracting it from new time.
    move.b  #8, d0
    trap    #15
    move.l  d1, (a0)
    sub.l   d2, d1
    move.l  d1, (a1)
    rts
    
     

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
