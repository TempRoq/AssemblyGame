*-----------------------------------------------------------
* Title      : Collision
* Written by : Anthony Pizzigoni
* Date       : 6-30-23
* Description: Handles what everything does on collision. Has a collision handling table.
*-----------------------------------------------------------
 
    ;COLLISION CHALLENGES:
    ;   * Backup as few registers as humanly possible. This will be called super often, so less memory reads is better.
    ;   * Optimize checks to be as fast as possible. The faster collision is, the better.
    ;       *   less outer loops = better. Try to set it so the thing with the least objects will be in d0/a0 and the most in d1/a1.
    
    HANDLE_COLLISION:
        ;PLAYER_BULLETS <==> ENEMIES.
     
        lea     ET_PLAYER_BULLETS_START, a0
        lea     ET_ENEMIES_START, a1
        move.l  #MAX_NUM_PLAYER_BULLETS, d0
        move.l  #MAX_NUM_ENEMIES, d1
        jsr COLLISION_LAYER_CHECKS
        
        ;ENEMIES <==> PLAYERS
        lea     ET_ENEMIES_START, a1
        lea     ET_PLAYER_START, a0
        move.l  #MAX_NUM_ENEMIES, d1
        move.l  #MAX_NUM_PLAYERS, d0
        jsr COLLISION_LAYER_CHECKS
        
        ;PLAYERS <==> ENEMY BULLETS
        lea     ET_ENEMY_BULLETS_START, a1
        lea     ET_PLAYER_START, a0
        move.l  #MAX_NUM_ENEMY_BULLETS, d1
        move.l  #MAX_NUM_PLAYERS, d0
        jsr COLLISION_LAYER_CHECKS

    
        ;PLAYER_SWORD <==> ENEMIES & ENEMY_BULLETS
        lea     ET_PLAYER_SWORD_START, a0
        lea     ET_ENEMIES_START, a1
        move.l  #MAX_NUM_PLAYER_SWORD, d0 
        move.l  #MAX_NUM_ENEMIES, d1
        add.l   #MAX_NUM_ENEMY_BULLETS, d1   ;In memory, they are right next to each other, so for now, this is a small optimization that can be made.
        jsr COLLISION_LAYER_CHECKS          
        
        ;PICKUPS <==> PLAYER
        lea     ET_PICKUPS_START, a1
        lea     ET_PLAYER_START, a0
        move.l  #MAX_NUM_PICKUPS, d1
        move.l  #MAX_NUM_PLAYERS, d0
        jsr COLLISION_LAYER_CHECKS
        rts
        
        
        
    ;a0 is the index of the checker layer (checker layer)
    ;d0 is the number of loops for a0 - 1
    ;a1 is the index the collisions
    ;d1 is the number of loops for a1 - 1.  
        
        
    COLLISION_LAYER_CHECKS:

        subi.w  #1, d0              ;subtracting 1 to account for 0 indexing.
        subi.w  #1, d1   
        swap    d0
        move.w  d1, d0
        swap    d0      

        lsl.l   #5, d0      
        lsl.w   #5, d1                  
        ;backing up inner loop max value in d0. Need an extra register, and keeping d7 open for returns.
        ;Ideally, collision checks should not back anything up because they will be called so much every single frame.
        lea CLOSE_COLLISION_TABLE, a2    
        CC_PB_OUTER_LOOP:
            move.b  (GET_INFO,a0, d0), d2         ;d2 holds player bullet info
            beq     ITERATE_OUT
            CC_PB_INNER_LOOP:
                move.b  GET_INFO(a1,d1), d3     ;d3 holds enemy info
                beq     ITERATE_IN
                                                ;at this point, both bullet and enemy are active and we do a collision check.
                move.b  (GET_INFO+1,a0, d0), d2    ;Getting collision quadrant
                ext.w   d2
                move.b  (GET_INFO+1,a1,d1), d3   ;Getting collision quadrant  
                ext.w   d3  
                lsl.w   #1, d2
                move.w  (a2, d2), d4
                btst  d3, d4
                beq     ITERATE_IN              ;if the bit is not set, there is no collision check.
                move.l  d0, -(SP)
                move.l  d1, -(SP)
                move.l  d2, -(SP)
                move.l  a0, -(SP)
                move.l  a1, -(SP)
                ext.l   d0
                jsr COLLISION_BOX_OVERLAP
                move.l  (SP)+, a1
                move.l  (SP)+, a0
                move.l  (SP)+, d2
                move.l  (SP)+, d1
                move.l  (SP)+, d0
                ITERATE_IN:
                subi.w  #ENTITY_SIZE, d1
                bge     CC_PB_INNER_LOOP
            
            ITERATE_OUT:
            swap    d0
            move.w  d0, d1
            swap    d0
            subi.w  #ENTITY_SIZE, d0
            bge     CC_PB_OUTER_LOOP
        rts

    ;arguments are in a0, d0, a1, and d1.
    ;(a0, d0) is the location of 1 object's data,
    ;(a1, d1) is the location of another object's data.
    ;return value in d7.b. $FF = there was a collision, $00 = there was no collision
    
    COLLISION_BOX_OVERLAP:
        ;Gets the top left corner of object, adds the Top Left Collision Box offset to them to get where the collision box starts.
        
        move.l  (GET_POSITION,a0,d0),d2
        move.l  (GET_POSITION,a1,d1),d3
        move.l  GET_COLLISION_BOX_TL(a0,d0),d4
        
        add.w   d4, d2
        swap    d2
        swap    d4
        add.w   d4, d2
        
        move.l  GET_COLLISION_BOX_TL(a1,d1),d4
        add.w   d4, d3
        swap    d3
        swap    d4
        add.w   d4, d3
        
        move.b  (GET_COLLISION_BOX_BOUNDS+1,a0, d0), d4             ;Y first, then X
        
        
        swap    d4
        move.b  (GET_COLLISION_BOX_BOUNDS,a0,d0),d4
        
        move.b  (GET_COLLISION_BOX_BOUNDS+1,a1, d1), d5
        swap    d5
        move.b  (GET_COLLISION_BOX_BOUNDS,a1, d1), d5
        ;d2 and d3 are set as XY right now. Collision box bounds are stored as YX, now at XY.
        ;TL Corners in d2 and d3, and their bounds are in d4 and d5 respectively.
        ;top left corner of object 1 y + height                  
        move.w  d2, d6
        add.w   d4, d6 
        cmp.w   d3, d6          ;if object2.y < object1.y + height, don't branch
        blt     NO_COLLISION
        
        move.w  d3, d6
        add.w   d5, d6
        cmp.w   d2, d6
        blt     NO_COLLISION    ;if object1.y < object2.y + height, don't branch
        
        swap    d2
        swap    d3
        swap    d4
        swap    d5
        
        move.w  d2, d6
        add.w   d4, d6
        cmp.w   d3, d6
        blt     NO_COLLISION    ;if object2.x < object1.x + width, don't branch
        
        move.w  d3, d6
        add.w   d5, d6
        cmp.w   d2, d6
        blt     NO_COLLISION    ;if object1.x < object2.x + width, don't branch
        
        COLLISION:
        jsr ON_COLLISION
        rts
        
        NO_COLLISION:
        rts
        
*                   COLLISION
*
*    Collision blocks are set up as such:
*    
*    0   1   2   3
*    4   5   6   7
*    8   9   A   B
*    C   D   E   F
*
*    The word offset in CLOSE_COLLISION_TABLE is the 1/16 screen space block that an object's top left is in
*    the bit offset is the 1/16 screen space block that the other object's top left is in.
*
*    So, for example, I want to see if an object in block 8 collided with an object in block D, you would go to word offset 8 ($3330 is stored there).
*    
*                                             FEDC   BA98    7654    3210
*                                               v
*    Next, you would do a btst check using D (0011   0011    0011    0000)
*    
*    That bit is set, which means that a collision *could* happen here, so you should run a collision check.


CLOSE_COLLISION_TABLE:     
    dc.w   $0033    ;0
    dc.w   $0077    ;1
    dc.w   $00EE    ;2
    dc.w   $00CC    ;3
    dc.w   $0333    ;4
    dc.w   $0777    ;5
    dc.w   $0EEE    ;6
    dc.w   $0CCC    ;7
    dc.w   $3330    ;8
    dc.w   $7770    ;9
    dc.w   $EEE0    ;A
    dc.w   $CCC0    ;B
    dc.w   $3300    ;C
    dc.w   $7700    ;D
    dc.w   $EE00    ;E
    dc.w   $CC00    ;F

;All function pointers












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
