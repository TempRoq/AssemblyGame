*-----------------------------------------------------------
* Title      : FORMATION
* Written by :
* Date       :
* Description: Entity formations are a series of long words that tell you what enemy to spawn, and their x and y position offsets.
*-----------------------------------------------------------

FORMATION_NODE_SIZE         EQU     16

GET_FORMATION_ENTITY        EQU     0
GET_FORMATION_EN_VAR        EQU     1
GET_FORMATION_THETA         EQU     2
GET_FORMATION_PATH          EQU     3
GET_FORMATION_POS           EQU     4
GET_FORMATION_IN_DEL_THET   EQU     8               ;1 word for initial theta, 1 word for delta_theta 
GET_FORMATION_IN_THETA      EQU     10
GET_FORMATION_IN_ACC        EQU     12              ;1 word for initial vel, 1 word for acceleration 
GET_FORMATION_IN_VEL        EQU     14

*    TO BE MOVED.
*    GET REFERENCE TO FORMATION TO SPAWN
*    lea     FORMATION_BANK, a1
*    move.b  GET_SPAWN_FORMATION(a0), d0
*    lsl.w   #2, d0
*    move.l  (a1, d0), a1        ;a1 holds the current formation's address
    
;4SP = formation offset
;6sp = totalThetaOffset
;8sp = formation Spawning Position
SPAWN_FORMATION:
    clr.l   d1
    clr.l   d5
    lea ENTITY_DATA_TABLE, a0
    lea FORMATION_BANK, a1
    move.w  4(SP), d1       ;formation offset
    lsl.l   #2, d1
    adda.l  d1, a1         
    move.l  (a1), a1        ;Now at the formation data. 
    clr.l   d1
    
    SP_FORM_LOOP:
        clr.l   d0
        move.w  6(SP), d0       ;d0 it total formation's theta offset
        move.l  8(SP), d4       ;position offset
        move.b  GET_FORMATION_ENTITY(a1), d1
        cmpi.b  #$FF, d1 ;no entity has an offset of FF, so we know it's not workin
        beq     STOP_SPAWN_FORM
        
        clr.l   d2
        ;move.b  GET_FORMATION_THETA(a1), d2
        ;lsl.w   #4, d2                          ;Formation theta has no frac bits and is half of what it should be.
        add.l   d2, d0                          ;adding wave's theta offset to formation node's theta offset
        move.l  GET_FORMATION_POS(a1), d3
        add.w   d3, d4
        swap    d3
        swap    d4
        add.w   d3, d4
        swap    d4
        clr.l   d5
        move.b  GET_FORMATION_PATH(a1), d5
        move.w  GET_FORMATION_IN_THETA(a1), d1
        add.w   6(SP), d1
        move.l  a0, -(SP)
        move.l  a1, -(SP)

        
        move.w  d1, -(SP)
        move.w  GET_FORMATION_IN_DEL_THET(a1), -(SP)
        move.w  GET_FORMATION_IN_VEL(a1), -(SP)
        move.w  GET_FORMATION_IN_ACC(a1), -(SP)
       
        move.l  d5, -(SP)       ;path offset
        move.l  d0, -(SP)       ;Theta Initial for the entity
        move.l  d4, -(SP)       ;position to spawn.
        clr.l   d1  
        move.b  GET_FORMATION_ENTITY(a1), d1
        move.l  d1, -(SP)       ;entity offset
        
        jsr     TRY_SPAWN_ENTITY
        
        adda.l  #24, SP
        move.l  (SP)+, a1
        move.l  (SP)+, a0
        adda.l  #FORMATION_NODE_SIZE, a1
        bra     SP_FORM_LOOP
    
    STOP_SPAWN_FORM:
    rts
    
    
F_SPAWN_DEBUG   incbin      'data/Formations/F_SPAWN_DEBUG'
F_SPAWN_PLAYER  ;incbin     'data/Formations/F_SPAWN_PLAYER'
F_SPAWN_BASIC   ;incbin     'data/Formations/F_SPAWN_BASIC'
PG_DEBUG        incbin      'data/Guns/DEBUG_GUN'
    
FORMATION_BANK
    dc.l    F_SPAWN_DEBUG
    dc.l    PG_DEBUG

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
