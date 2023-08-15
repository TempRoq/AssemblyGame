*-----------------------------------------------------------
* Title      :  Graphics (Choosing what to draw)
* Written by :  Anthony Pizzigoni
* Date       :  7-3-23
* Description:  Everything calls here for drawing graphics to the screen, which calls actual bitmap renderers.
*-----------------------------------------------------------
   

SPR_HUD      INCBIN      'bmps/hud.bmp'
SPR_SLIME    INCBIN      'bmps/slime.bmp'    
SPR_PLAYER   INCBIN      'bmps/character.bmp'

TRAP_ELLIPSE_DRAW      EQU     88
TRAP_RECT_DRAW         EQU     87



;sprite table. Each enemy's sprite sheet is loaded in here.
GET_ENEMY:
    ds.l    SPR_SLIME



DRAW_PLAYER:

    
    move.l  d7, -(SP)
    
    move.l  #$00D08080, d1
    move.l  #80, d0
    trap    #15
    move.l  #81, d0
    trap    #15
    move.l  #TRAP_RECT_DRAW,d0
    
    move.l  GET_POSITION(a0), d5
    
    move.l  #$00050003, d6
    move.l  #$00020004, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00050000, d6
    move.l  #$00020002, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00070001, d6
    move.l  #$00030002, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$000A0002, d6
    move.l  #$00060006, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00040004, d6
    move.l  #$00040002, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00050008, d6
    move.l  #$00020002, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00070007, d6
    move.l  #$00030002, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    move.l  #$00090003, d6
    move.l  #$00030004, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    
    
    move.l  (SP)+, d7
    rts






DRAW_SLIME:
    move.l  d7, -(SP)
    move.l  #$00FFFFFF, d1
    move.l  #80, d0
    trap    #15
    move.l  #81, d0
    trap    #15
    
    move.l  #TRAP_RECT_DRAW, d0
    move.l  GET_POSITION(a0), d5
    move.l  #$00000002, d6
    move.l  #$00090006, d7
    jsr DRAW_SCALED_FROM_POSITION
    move.l  #$00020000, d6
    move.l  #$0009000B, d7
    jsr DRAW_SCALED_FROM_POSITION
    
    clr.l   d1
    move.l  #80, d0
    trap    #15
    move.l  #81, d0
    trap    #15
    
    move.l  #TRAP_RECT_DRAW, d0
    move.l  #$00030002, d6
    move.l  #$00020002, d7
    jsr DRAW_SCALED_FROM_POSITION
    move.l  #$00050008, d6
    jsr DRAW_SCALED_FROM_POSITION
    move.l  #$00060004, d6
    move.l  #$00010002, d7
    jsr DRAW_SCALED_FROM_POSITION
    move.l  (SP)+, d7
    rts
    
DRAW_ROBOT:

    rts
    
;Requires (a0) to be the location of the bullet in memory
DRAW_PLAYER_BULLET:
    
     move.b  #80, d0
     move.l  #COLOR_PLAYER_BULLET_OUTER, d1
     trap    #15    
                
     move.b  #81, d0
     move.l  #COLOR_PLAYER_BULLET_INNER, d1
     trap    #15



    move.w  GET_POSITION(a0), d2     ;move y position to d2 and d4
    move.w  d2, d4
    move.w  (GET_POSITION+2)(a0), d1 ;move x and 
    move.w  d1, d3
    move.l  GET_SIZE(a0), d0
    add.w   d0, d3
    swap    d0
    add.w   d0, d4
    clr.l   d0
    move.b  #TRAP_PLAYER_BULLET_SHAPE, d0     ;make them circles!
    jsr DRAW_SCALED_SHAPE
    rts

DRAW_ENEMY_BULLET:
    move.w  GET_POSITION(a0), d2     ;move y position to d2 and d4
    move.w  d2, d4
    move.w  (GET_POSITION+2)(a0), d1 ;move x and 
    move.w  d1, d3
    move.l  GET_SIZE(a0), d0
    add.w   d0, d3
    swap    d0
    add.w   d0, d4
    clr.l   d0
    move.b  #TRAP_PLAYER_BULLET_SHAPE, d0     ;make them circles!
    jsr DRAW_SCALED_SHAPE
    rts

;4(SP) = 
DRAW_SEVEN_SEGMENT:




    rts


COLOR_BANK_LENGTH       dc.b    3

COLOR_BANK
    dc.l    $00FF0000, $0000FF00, $000000FF 
    
DRAW_FUNCTIONS:
    dc.l    DRAW_PLAYER, DRAW_SLIME, DRAW_ROBOT, DRAW_PLAYER_BULLET

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
