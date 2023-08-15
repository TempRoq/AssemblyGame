*-----------------------------------------------------------
* Title      : PATHING
* Written by : ANTHONY PIZZIGONI
* Date       : 6-26-23, Uprooted on 7-11-23
* Description: This holds a reference to all path handlers, which is a 16 byte data structure
* that holds values relating to objects following a set path on screen. Paths are parsed in PATH_NODES.X68.
* Path Handlers interact with the entities that hold them to feed them velocity and theta which are updated
* here based on delta time, acceleration, and delta theta.
*-----------------------------------------------------------

PATH_HANDLER_SIZE       EQU     16

GET_PATH_ADDR           EQU     0
GET_PH_ACC              EQU     4
GET_PH_VEL              EQU     6
GET_PH_DEL_THET         EQU     8
GET_PH_THETA            EQU     10
GET_PH_FLAG             EQU     12
GET_PATH_NODE_OFFSET    EQU     14

THETA_FRAC_BITS         EQU     4
SPEED_FRAC_BITS         EQU     6
DELTA_TIME_FRAC_BITS    EQU     3

ENTITY_VEL_MAX   EQU     $8000


;Clears all path handlers to have cleared flags and everything else is set to FFFF
CLEAR_PATH_HANDLERS:
    lea PATH_HANDLER_BANK, a0
    move.b  #(MAX_NUM_ENTITIES-1), d7
    move.b  #1, d6
    move.l  #$0000FFFF, d0
    move.l  #$FFFFFFFF, d1
    CLEAR_PATH_HANDLER_LOOP:
    move.l  d1, (a0)+
    move.l  d1, (a0)+
    move.l  d1, (a0)+
    move.l  d0, (a0)+
    sub.b   d6, d7
    bge CLEAR_PATH_HANDLER_LOOP
    rts
    
    

    

;4(SP) is the path offset                   >>Consider making equates
;8(SP) is initial Speeds
;12(SP) is initial thetas
;16(SP) is the object that owns this path handler.
FIND_NEW_PATH_HANDLER:
    clr.l   d6
    clr.l   d7
    lea     PATH_BANK, a1
    move.l  4(SP), d7
    lsl.l   #2, d7
    move.l  (a1, d7), d4    ;this is the address of the path to follow, stored in d4
    lea     PATH_HANDLER_BANK, a1
    move.b  #(MAX_NUM_ENTITIES-1), d7
    move.b  #PATH_HANDLER_SIZE, d6
    lsl.l   #4, d7          ;size of a path handler is 16 bytes
    
    FNPH_LOOP:
    move.b  (GET_PH_FLAG, a1,d7), d5
    beq     FOUND_NEW_PATH              ;if the zero flag is set, you moved 0000, which means "not set".
    sub.l   d6, d7
    bge FNPH_LOOP
    clr.b   d7
    rts  
    
    ;Set timer for updating the Current Path Node
    ;with input1 being the address, input 2 being the entity,
    ;the function being NEXT_PATH_NODE, and the time being the timer.
    FOUND_NEW_PATH:  
    adda.l  d7, a1                      ;a1 is the address of the new path handler. Instantiating it here.
    move.b  #$FF,   GET_PH_FLAG(a1)
    move.l  d4,     GET_PATH_ADDR(a1)
    move.w  #0,     GET_PATH_NODE_OFFSET(a1)
    move.l  8(SP),GET_PH_ACC(a1)
    move.l  12(SP),GET_PH_DEL_THET(a1)
    
    move.l  GET_PATH_ADDR(a1), a2
    clr.w   d0
    move.w  GET_PATHNODE_TIME_ELAPSED(a2), d0
    move.l  a1, -(SP)           ;arg2 = Path Handler to update
    move.l  16(SP), -(SP)       ;arg1 = entity
    lea     NEXT_PATH_NODE, a6                      
    move.l  a6, -(SP)   ;this = function            , 8sp
    move.l  d0, -(SP)               ; Value for Timer, 4sp
    jsr     SET_TIMER
    adda.l  #12, SP
    move.l  (SP)+, a1
    
    rts

               
;let 4(SP) be a reference to the entity calling it
PATH_UPDATES:
    clr.l   d2
    clr.l   d1
    clr.l   d0
    lea DELTA_TIME, a0
    move.l  (a0), d0
    move.l  4(SP), a0
    move.l  GET_ENTITY_PATH_ADDRESS(a0), a1
    
    
    
*    Acceleration and velocity are 1 word apiece and use 8 fractional bits.
*    velocity is unsigned, acceleration is signed.
*    due to this, have to have a clamp that checks whether an underflow or an overflow has happened
*    when an object accelerates beyond any bound of the clamp, velocity is clamped

    
    
    ;UPDATING VELOCITY BASED ON ACCELERATION
    move.w  GET_PH_ACC(a1), d1
    mulu.w  d0, d1
    lsr.l   #DELTA_TIME_FRAC_BITS, d1
    lsr.l   #SPEED_FRAC_BITS, d1
    move.w  GET_PH_VEL(a1), d2
    add.w   d1, d2      
    cmpi.w  #ENTITY_VEL_MAX, d2
    blo     NO_PH_VEL_CLAMP                     ;if the unsigned value is less than the velocity clamp, then it's already clamped. Otherwise, it is either an underflow or overflow.
    ;Stop accelerating, maintain speed
    move.w  #0, d2
    cmpi.w  #0, d1  
    blt     ENTITY_VELOCITY_UNDERFLOW       ;if d1 is negative, then that means that you underflowed, so set velocity to 0.
    move.w  #ENTITY_VEL_MAX, d2
    ENTITY_VELOCITY_UNDERFLOW:
    NO_PH_VEL_CLAMP:
    move.w  d2, GET_PH_VEL(a1)
    
    
    
    ;UPDATING THETA BASED ON DELTA THETA and clamp.
    move.w  GET_PH_DEL_THET(a1), d1
    mulu.w  d0, d1            
    lsr.w   #DELTA_TIME_FRAC_BITS, d1
    move.w  GET_PH_THETA(a1), d2
    
    add.w   d1, d2
    
    divu    #ANGLE_MAX, d2
    clr.w   d2
    swap    d2
    
*    bge     THETA_ABOVE_ZERO
*    add.w   #ANGLE_MAX, d2
*    
*    THETA_ABOVE_ZERO:
*    
*    cmp.w   #ANGLE_MAX, d2
*    blt     THETA_BELOW_MAX
*    sub.w   #ANGLE_MAX, d2
*    
    THETA_BELOW_MAX:
    
    move.w  d2, GET_PH_THETA(a1)
    lsr.l   #THETA_FRAC_BITS, d2        ;
    move.l  d2, -(SP)
    
    ;Getting the movement vector and storing it in d2(X) and d4(Y)
    jsr     GET_VECTOR              
    move.l  (SP)+, d4               
    move.w  d4, d2
    clr.w   d4
    swap    d4                      
    
    lea DELTA_TIME, a0
    move.l  (a0), d0
    move.l  4(SP), a0
    move.l  GET_ENTITY_PATH_ADDRESS(a0), a1
    
    clr.l   d1
    clr.l   d3

    ;UPDATING POSITION  
    
    move.l  GET_POSITION(a0), d3
    
    
    
    move.w  GET_PH_VEL(a1), d1              ;Velocity in d1
    
    muls.w  d1, d2                        ;Velocity * movement vector.x(with 2 frac bits)
    lsr.l   #SPEED_FRAC_BITS, d2            ;bit shift it right to account for built in speed fractional bits
              ;bit shift it right to account for built in fractional bits for the vector
    muls.w  d0, d2                          ;x movement * delta time, multiply to account for delta time.
    lsr.l   #VECTOR_FRAC_BITS, d2
    lsr.l   #DELTA_TIME_FRAC_BITS, d2

    clr.l   d5
    clr.l   d6
    move.w  d2, d6                         
    add.w   d3, d6                          ;get new x in d6
    move.w  #ENTITY_OFF_SCREEN_MAX, d5      ;take max off screen in d5
    add.w   d5, d6                          ;add to position.
    blt     TOO_FAR_OFF_SCREEN              ;if this "new position" is greater than 0, then you are beyond the minimum.
    
    
    sub.w   d5, d6                          ;subtract minimum twice and see if it is below the max x border
    sub.w   d5, d6
    cmpi.w  #STAGE_BORDER_X_MAX, d6
    bgt     TOO_FAR_OFF_SCREEN
    
    muls.w  d1, d4                          ;Same as X above
    lsr.l   #SPEED_FRAC_BITS, d4
    muls.w  d0, d4
    lsr.l   #VECTOR_FRAC_BITS, d4
    lsr.l   #DELTA_TIME_FRAC_BITS, d4
    clr.l   d5
    clr.l   d6
    swap    d3
    
    move.w  d4, d6                          
    add.w   d3, d6
    move.w  #ENTITY_OFF_SCREEN_MAX, d5
    add.w   d5, d6
    blt     TOO_FAR_OFF_SCREEN
    
    sub.w   d5, d6
    sub.w   d5, d6
    cmpi.w  #STAGE_BORDER_Y_MAX, d6
    bgt     TOO_FAR_OFF_SCREEN
    swap    d3
    
    ;d2 is updated x, d4 is updated y. Check if they are outside entity bounds.

    
    add.w   d2, d3                          ;adding to position.
    swap    d3
    add.w   d4, d3
    swap    d3
    move.l  d3, GET_POSITION(a0)      
    rts
    
    TOO_FAR_OFF_SCREEN:
    move.l  a0, -(SP)
    jsr     KILL_ENTITY_NO_POINTS
    move.l  (SP)+, a0
    rts
    
;4(SP) is a reference to the entity calling it
;8(SP) is the address of the path handler being killed
KILL_PATH:
    lea 8(SP), a0
    move.b  #0, GET_PH_FLAG(a0)
    rts

*ASSUMPTIONS:
*    d0 is set to a path node.
*    a0 is a reference to the location in memory where the instruction is called from (the path parser / array / whatever
*    just so we can modify certain values without changing the path itself. This is so the "F" instructions can work
    ;To save checks, we assume that we are firing a gun at this point.
FACE_PLAYER:

    rts



CURR_PATH_HANDLER    dc.l      0
PATH_HANDLER_BANK    ds.b      (PATH_HANDLER_SIZE*MAX_NUM_ENTITIES)

P_DEBUG         incbin      'data/Paths/DebugPath'
P_LINE          incbin      'data/Paths/P_Line'
P_LINE_SHOOT    ;incbin      'data/Paths/P_Line'
P_CIRCLE        ;incbin     'data/Paths/P_Circle'
P_BOX           ;incbin     'data/Paths/P_Box'


PATH_BANK         
    dc.l    P_DEBUG, P_LINE, P_LINE_SHOOT, P_CIRCLE, P_BOX











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
