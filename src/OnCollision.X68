*-----------------------------------------------------------
* Title      :  OnCollision
* Written by :  Anthony Pizzigoni
* Date       :  7-6-23
* Description:  Handles everything that results from collision, as well as the OnCollision table.
*               Any collision function requires a0 being the actor and a1 being the actee. Moves to OnCollisionTable => (20*a0.type) + (4* a1.type)
*               For instance, a bullet collides with a player. Player never calls any function when colliding with a bullet, but the bullet hurts the player.
*               when the player is the actor, it goes to offset
*-----------------------------------------------------------
NUM_COLLISION_ROWS          EQU         6

NIL:
    rts
    
DESTROY_OBJ:

    move.b  #STATUS_DEAD, GET_INFO(a1)
    move.l  a0, -(SP)
    move.l  a1, -(SP)
    jsr KILL_ENTITY
    move.l  (SP)+, a1
    move.l  (SP)+, a0
    rts
    
CHECK_BULLET_PIERCE:
    
    rts

DEAL_DAMAGE:
    move.w  GET_HEALTH(a1), d0
    clr.w   d1
    move.b  GET_POWER(a0), d1
    sub.w   d1, d0
    move.w  d0, GET_HEALTH(a1)
    ble     KILL_OBJ
    rts     
    KILL_OBJ:
    move.l  a0, -(SP)
    move.l  a1, -(SP)
    jsr KILL_ENTITY
    move.l  (SP)+, a1
    move.l  (SP)+, a0
    rts
    
GIVE_BONUS:
    rts

;In this table, the TOP interacts with the SIDE
ON_COLLISION_FUNCTIONS:;PLAYER     PLAYER_BULLET    ENEMY   ENEMY_BULLET    SWORD(?)            PICKUP
    dc.l                NIL,        NIL,            DESTROY_OBJ,    DEAL_DAMAGE,    NIL,                GIVE_BONUS         ;PLAYER
    dc.l                NIL,        NIL,            DESTROY_OBJ,    NIL,      NIL,                NIL          ;PLAYER_BULLET
    dc.l                NIL, DEAL_DAMAGE,    NIL,    NIL,            DEAL_DAMAGE,        NIL                ;ENEMY
    dc.l                NIL,        NIL,            NIL,    NIL,            DESTROY_OBJ,        NIL                ;ENEMY_BULLET
    dc.l                NIL,        NIL,            NIL,    NIL,            NIL,                NIL                ;SWORD
    dc.l                NIL,        NIL,            NIL,    NIL,            NIL,                NIL                ;PICKUP
                         
    
    
;a0 and a1 are objects that are colliding.
ON_COLLISION:

    clr.l   d6
    clr.l   d7
    ext.l   d0
    ext.l   d1
    adda.l  d0, a0                                  ;a0 is player, a1 is slimberly
    adda.l  d1, a1
    
    move.b  (GET_ENTITY_TYPE+1)(a0), d6
    move.b  (GET_ENTITY_TYPE+1)(a1), d7
    lea     ON_COLLISION_FUNCTIONS, a2
    mulu.w  #NUM_COLLISION_ROWS, d7                 ;Getting the type of collision occuring for a1 onto a0.
    lsl.l   #2, d6
    lsl.l   #2, d7
    add.w   d6, d7
    move.l  (a2, d7), d0
    
    move.b  (GET_ENTITY_TYPE+1)(a1), d6                 ;Getting the type of collision ocurring for a1 onto a0
    move.b  (GET_ENTITY_TYPE+1)(a0), d7
    mulu.w  #NUM_COLLISION_ROWS, d7
    lsl.l   #2, d6
    lsl.l   #2, d7
    add.w   d6, d7
    move.l  (a2, d7), d1
    
    move.l  d0, a5
    move.l  d1, a6
    
    jsr     (a5)
    move.l  a1, a2
    move.l  a0, a1
    move.l  a2, a0
    jsr     (a6)
    
    rts
    
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
