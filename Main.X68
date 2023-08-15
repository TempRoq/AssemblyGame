*-----------------------------------------------------------
* Title      : Main Game Loop
* Written by : ANTHONY PIZZIGONI
* Date       : 6-26-23
* Description: Holds the main loops for the different phases of gameplay.


*    [GIVE DESCRIPTION OF GAME]
*    [GIVE CONTROLS]
*    OR LINK TO README




*-----------------------------------------------------------


    ORG    $1000
    
    INCLUDE                             'src/Definitions.X68'
    INCLUDE                             'src/Graphics.X68'
    INCLUDE                             'src/Operations.X68'
    INCLUDE                             'src/Pathing.X68'
    INCLUDE                             'src/PathNodes.X68'
    INCLUDE                             'src/DrawBitmaps.X68'
    INCLUDE                             'src/Input.X68'
    INCLUDE                             'src/Formation.X68'
    INCLUDE                             'src/AngleLookup.X68'
    INCLUDE                             'src/Player.X68'
    INCLUDE                             'src/Spawning.X68'
    INCLUDE                             'src/Entity.X68' 
    INCLUDE                             'src/Timer.X68'
    INCLUDE                             'src/OnCollision.X68'
    INCLUDE                             'src/Collision.X68'
    INCLUDE                             'src/Init.X68'
    INCLUDE                             'src/Debug.X68'
    
    
DEBUG_ON            EQU         1
    
    
START:   
    jsr INIT

    RESET:
    
    jsr     RESET_INIT
    jsr     CLEAR_TIMERS
    jsr     CLEAR_ENTITIES
    jsr     CLEAR_PATH_HANDLERS
    jsr     CREATE_HUD              ;spawning the hud here for now.
    jsr     RESET_LEVEL_SPAWNING
    
    SPAWN_NEW_PLAYER:               
    move.l  #0, -(SP)               ;No DelTheta + Theta
    move.l  #0, -(SP)               ;No ACC + Velocity
    move.l  #$FFFFFFFF, -(SP)       ;No Path Handler pls...
    move.l  #0, -(SP)               ;No Theta Initial
    move.w  #PLAYER_SPAWN_POINT_X, -(SP)    
    move.w  #PLAYER_SPAWN_POINT_Y, -(SP)    
    move.l  #EDT_OFFSET_PLAYER, -(SP)                       ;Entity 0, which is Player.
    jsr     TRY_SPAWN_ENTITY
    adda.l  #24, SP
    

    move.b  #DEBUG_ON, d0
    beq NO_DEBUG_ENEMIES
    jsr     SPAWN_DEBUG_ENEMIES
    NO_DEBUG_ENEMIES:
    jsr UPDATE_DELTA_TIME
    
    

    MAIN_LOOP_START: 
     
        jsr UPDATE_DELTA_TIME
        jsr CLEAN_SCREEN  
        
        move.b  #DEBUG_ON, d0
        beq     NO_DEBUG_LINES
        jsr DRAW_GRID_LINES
        
        NO_DEBUG_LINES:
        
        jsr READ_INPUT 
        lea GAME_STATE, a0
        clr.l   d7
        move.b  (a0), d7
        lsl.w   #2, d7
        lea GAME_LOOP_FUNC_TABLE, a0
        move.l  (a0, d7), a0
        jsr (a0)
        bra MAIN_LOOP_START


        
        MENU:
            ;Interpret input
            ;Draw stuff to screen
            rts

        GAME:     
            jsr PLAYER_UPDATE               ;interpret input and update location
            jsr ENTITY_UPDATE               ;pathing, sending things to spawn, updating animations (if I get that far), etc              
            jsr HANDLE_COLLISION            ;I hit something. What now?
            jsr UPDATE_TIMERS               ;So objects don't act funky when spawning in here. 
            ;Draw Score to Screen
            ;Audio
            rts
        
        PAUSE:
            ;Interpret pause inputs.
            ;Draw objects
            ;Draw Menu
            rts
        
        HI_SCORE:
            ;Collect Hi-Score inputs
            ;Draw objects and write text to screen
            rts
           
        
        
        
    
    
    
    
    
    

    SIMHALT             ; halt simulator
    
    
SCORE               dc.l        0    
TIME_LAST_UPDATE    dc.l        0
DELTA_TIME          dc.l        0       ;SET ME! In hundredths of a second!
GAME_STATE          dc.b        0

;HISCORES       INCBIN      'hiscores.bin'      ;hiscores
;PLAYERPREFS    INCBIN      'playerprefs.bin'   ;settings

GAME_LOOP_FUNC_TABLE    dc.l    MENU, GAME, PAUSE, HI_SCORE
    
    END    START        










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
