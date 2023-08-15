*-----------------------------------------------------------
* Title      : Entity
* Written by : ANTHONY PIZZIGONI
* Date       : 6-26-23
* Description: Holds information about entities, the entity table, and the 
*-----------------------------------------------------------



    CLEAR_ENTITIES:
        move.l      #$FFFFFFFF, d1  ;emptying out the table.
        move.l      #$00FFFFFF, d2  ;specifically for setting that the object is inactive.
        lea         ENTITY_TABLE_START, a0
        move.b      #MAX_NUM_ENTITIES, d0
        subi.b      #1, d0
        ES_LOOP:
           move.l   d1, (a0)+
           move.l   d1, (a0)+
           move.l   d1, (a0)+
           move.l   d1, (a0)+
           move.l   d1, (a0)+
           move.l   d1, (a0)+
           move.l   d2, (a0)+
           move.l   d1, (a0)+   
           subi.b   #1, d0 
           bge      ES_LOOP 
        rts    

    ;a0 is the start of the index.
    ;d0 is the length. d1 is the entity offset.
    ;d2 as the point to spawn enemy from?
    
    ;CHANGED TO
    
    ;4(SP) is the entity offset
    ;8(SP) is the position to spawn them at
    ;12(SP) is the theta initial
    ;16(SP) is the path offset.
    ;20(SP) is initial speeds
    ;24(SP) is initial thetas
    
    TRY_SPAWN_ENTITY:
            clr.l   d5
            clr.l   d2
            
            move.l  4(SP), d1             ;d1 holds the entity offset
            lsl.l   #2, d1
           
            
            lea     ENTITY_DATA_TABLE, a1
            adda.l  d1, a1
            move.l  (a1), a1              ;this is the entity data in a1 right now.
            lea     ENTITY_TABLE_BOUNDS, a0
            
            move.w  GET_ENTITY_TYPE(a1), d2
            lsl.l   #3, d2
            move.l  (4, a0, d2), d0       ;d0 holds how many items to rifle through
            move.l  (a0, d2), a0          ;a0 holds where to start searching
            
            
            
            
            subi.b  #1, d0
            lsl.l   #5, d0              ;ENTITY SIZE = 32, so I can just shift the value to the left 5 times.
            
            ;mulu.w #ENTITY_SIZE, d0    ;in case this gets calle
            addi.l  #GET_INFO, d0
            move.l  #ENTITY_SIZE, d5
            
        SEARCH_FOR_NEXT_FREE:
            move.b  (a0, d0), d4
            beq     FOUND_OBJ       ;if it's not active, it will be 00.
            sub.l   d5, d0
            bge     SEARCH_FOR_NEXT_FREE 
            clr.l   d0
            rts
        FOUND_OBJ:
            
            ;finds data in entity table.
            adda.l  d0, a0
            suba.l  #GET_INFO, a0
            movea.l a0, a2
            
            
            move.l  (a1)+, (a2)+ 
            move.l  (a1)+, (a2)+
            move.l  8(SP), (a2)+
            adda.l  #4, a1
            move.l  (a1)+,(a2)+
            move.l  (a1)+,(a2)+
            move.l  (a1)+,(a2)+
            move.l  (a1)+,(a2)+
            move.l  #$FFFFFFFF, (a2)+               ;this needs to be a path handler address
                                            ;and that path handler address needs to take this

 
            move.b  #$FF, GET_INFO(a0)      
            move.l  12(SP), d1
            move.b  d1, GET_THETA(a0)
            
            ;Path offset being FFFF means it doesn't want a path handler. No path to follow. Good for basic ass bullets.
            move.l  16(SP), d1
            cmpi.b  #$FF, d1
            beq     NO_PATH_HANDLER
            move.l  24(SP), d0
            move.l  20(SP), d2
            move.l  a0, -(SP)       ;Entity
            move.l  d0, -(SP)   ;Initial Thetas
            move.l  d2, -(SP)   ;Initial SPeeds
            move.l  d1, -(SP)       ;PATH OFFSET
            jsr FIND_NEW_PATH_HANDLER
            adda.l  #12, SP
            move.l  (SP)+, a0
            move.l  a1, GET_ENTITY_PATH_ADDRESS(a0)
            NO_PATH_HANDLER:
            rts
     

    ENTITY_UPDATE:        
*                
*               PLAYER_BULLETS
*
                lea       ET_PLAYER_BULLETS_START, a6
                move.l    #(MAX_NUM_PLAYER_BULLETS-1), d7
                lsl.l     #5, d7                ;cuz size of 32 bytes. Easiest money of my life.
                
                
                EU_BULLET_LOOP:        
                move.b  (GET_INFO,a6, d7), d0        
                beq EU_BULLET_INACTIVE_OBJ     
                move.l  a6, a0
                adda.l  d7, a0
                move.l    a0, -(SP)
                jsr       INVAL_OBJECT
                move.l    (SP)+, a0
                  
                move.l  a6, -(SP)
                move.l  d7, -(SP)
                move.l  a0, -(SP)
                jsr PATH_UPDATES
                move.l  (SP)+, a0
                move.l  (SP)+, d7
                move.l  (SP)+, a6

                jsr       SET_COLLISION_ZONE
                jsr       DRAW_PLAYER_BULLET
                  
                EU_BULLET_INACTIVE_OBJ:  
                subi.l  #ENTITY_SIZE, d7
                bge     EU_BULLET_LOOP
                
*                
*               ENEMIES
*                
                
                lea ET_ENEMIES_START, a6
                move.l  #(MAX_NUM_ENEMIES-1), d7
                lsl #5, d7             
                
                EU_ENEMY_LOOP:
                move.b  (GET_INFO,a6, d7), d0
                beq     EU_ENEMY_INACTIVE
                move.l  a6, a0
                adda.l  d7, a0
                move.l  a0, -(SP)
                jsr     INVAL_OBJECT
                move.l  (SP)+, a0
                 
                
                move.l  a6, -(SP)
                move.l  d7, -(SP)
                move.l  a0, -(SP)
                jsr PATH_UPDATES
                move.l  (SP)+, a0
                move.l  (SP)+, d7
                move.l  (SP)+, a6
                
                jsr     SET_COLLISION_ZONE
                jsr     DRAW_SLIME
                
                EU_ENEMY_INACTIVE:
                
                subi.l  #ENTITY_SIZE, d7
                bge     EU_ENEMY_LOOP
                             
           rts
 

;4sp = entity to be removed.
KILL_ENTITY:

    
KILL_ENTITY_NO_POINTS:
    move.l  4(SP), a0
    move.b  #STATUS_DEAD, GET_INFO(a0)
    move.l  a0, -(SP)
    jsr INVAL_OBJECT
    adda.l  #4, SP
    
    rts


EN_FUNC_VAR_TABLE       ;Take Damage, die, collision, draw call, and color.

       

ENTITY_TABLE_START
ET_PLAYER_START
    ds.b        MAX_NUM_PLAYERS*ENTITY_SIZE                   
ET_PLAYER_BULLETS_START
    ds.b        MAX_NUM_PLAYER_BULLETS*ENTITY_SIZE
ET_PLAYER_SWORD_START
    ds.b        MAX_NUM_PLAYER_SWORD*ENTITY_SIZE
ET_ENEMIES_START
    ds.b        MAX_NUM_ENEMIES*ENTITY_SIZE
ET_ENEMY_BULLETS_START
    ds.b        MAX_NUM_ENEMY_BULLETS*ENTITY_SIZE
ET_PICKUPS_START
    ds.b        MAX_NUM_PICKUPS*ENTITY_SIZE
ET_END



ENTITY_NUM_ACTIVE
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0
    dc.l    0

;when iterating through to find what to spawn use this. based on the 'layer' of the object, finds an open entity spot in the pool. The rightmost 
ENTITY_TABLE_BOUNDS
    dc.l    ET_PLAYER_START, MAX_NUM_PLAYERS
    dc.l    ET_PLAYER_BULLETS_START, MAX_NUM_PLAYER_BULLETS
    dc.l    ET_ENEMIES_START, MAX_NUM_ENEMIES
    dc.l    ET_ENEMY_BULLETS_START, MAX_NUM_ENEMY_BULLETS
    dc.l    ET_PLAYER_SWORD_START, MAX_NUM_PLAYER_SWORD
    dc.l    ET_PICKUPS_START, MAX_NUM_PICKUPS 

PLAYER_DATA             INCBIN      'data/Entities/PlayerData.bin'
SLIME_DATA              INCBIN      'data/Entities/SlimeData.bin'
PLAYER_BULLET_DATA      INCBIN      'data/Entities/PlayerBulletData.bin'

ENTITY_DATA_TABLE:
    dc.l    PLAYER_DATA
    dc.l    SLIME_DATA
    dc.l    PLAYER_BULLET_DATA










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
