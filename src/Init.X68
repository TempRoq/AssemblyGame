*-----------------------------------------------------------
* Title      :  Initialization
* Written by :  Anthony Pizzigoni
* Date       :  7-10-23
* Description:  Initialize
*-----------------------------------------------------------



INIT:
   move.b  #93, d0
    move.b  #2, d1
    trap    #15
    
    lea     TIME_LAST_UPDATE, a0
    move.b  #8, d0
    trap    #15
    move.l  d1, (a0)
    
    
    
    move.w  #92, d0
    move.b  #17, d1
    trap    #15


       ;set screen size
    move.w  #SCREEN_SIZE_PIXELS_X, d1   
    swap    d1
    move.w  #SCREEN_SIZE_PIXELS_Y, d1
    move.w  #33, d0
    trap    #15
    clr.l   d0
    clr.l   d1
    rts
    
CREATE_HUD:
    ;Draws the hud on the untraversable part of the screen.
    lea SPR_HUD, a0
    clr.l   d5
    move.w  #HUD_HEIGHT, d6
    swap    d6
    move.w  #HUD_WIDTH, d6
    move.w  #HUD_OFFSET_Y, d7
    swap    d7
    move.w  #HUD_OFFSET_X, d7
    jsr DISPLAY_BMP_DATA
    
    move.w  #94, d0     
    trap    #15
    
    ;Swap buffers and do it again!
    lea SPR_HUD, a0
    clr.l   d5
    move.w  #HUD_HEIGHT, d6
    swap    d6
    move.w  #HUD_WIDTH, d6
    move.w  #HUD_OFFSET_Y, d7
    swap    d7
    move.w  #HUD_OFFSET_X, d7
    jsr DISPLAY_BMP_DATA
    rts

RESET_INIT:
    move.w  #11, d0         ;clears the screen
    move.w  #$FF00, d1
    trap    #15
    

    lea GAME_STATE, a0      
    move.b  #GAME_STATE_PLAYING, (a0)
    
    move.w  #94, d0
    trap    #15
    rts
    


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
