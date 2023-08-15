*-----------------------------------------------------------
* Title      :  Gun
* Written by :  Anthony Pizzigoni
* Date       :  7/10/23
* Description:  Positions in memory relating to guns
*-----------------------------------------------------------
TOTAL_NUM_GUNS
GUN_SIZE            EQU     8

GUN_THETA           EQU     0   ;unsigned
GUN_DELTA_THETA     EQU     2   ;unsigned
GUN_DELAY_HUNDS     EQU     4
FORMATION_OFFSET    EQU     6

;4(SP) = timer reference
FIRE_GUN_AT_POSITION:
    move.l  4(sp), a0
    move.l  GET_FUNC_INPUT_1(a0), a1    ;reference to the enemy to get their position
    
    ;if the enemy is alive, then you can fire. Otherwise, rts.
    
    move.l  GET_POSITION(a1), d0        ;Enemy's position
    move.l  GET_FUNC_INPUT_2(a0), d1    ;offset of the gun to use in least significant word, how much delta theta needs to be multiplied by
    ;set theta to be on the stack, after each fire, increment it.
    
    ;jsr SPAWN_BULLETS
    ;
   
   
   
;GUN_BANK   INCBIN      'data/guns.bin'    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
