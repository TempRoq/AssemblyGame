*-----------------------------------------------------------
* Title      : PATH_NODE
* Written by : Anthony Pizzigoni
* Date       : 7/11/23
* Description: Path nodes are the core of the pathing system, which hold an instruction, a 
*-----------------------------------------------------------
PATH_NODE_SIZE                  EQU        8

GET_PATHNODE_END                EQU        0        ;1 byte
GET_PATHNODE_TYPE               EQU        1        ;1 byte
GET_PATHNODE_TIME_ELAPSED       EQU        2        ;1 word?
GET_PATHNODE_ARG_1              EQU        4        ;1 word?
GET_PATHNODE_ARG_2              EQU        6        ;1 word?


PATHNODE_TYPE_SET_THETAS        EQU         0       
PATHNODE_TYPE_ADD_THETAS        EQU         1
PATHNODE_TYPE_SET_SPEEDS        EQU         2
PATHNODE_TYPE_ADD_SPEEDS        EQU         3
PATHNODE_TYPE_SPAWN_FORM        EQU         4
PATHNODE_TYPE_JUMP_TO_PATH      EQU         5
PATHNODE_TYPE_RESET_PATH        EQU         6

;4(SP) = Entity
;8(SP) = Path handler to Update


NEXT_PATH_NODE:
    ;Get Path[PATH_NODE_OFFSET]
    ;Use its flag to determine which instruction to do in Instruction bank
    ;Set timer for PathNodeUpdate after Path.TIME_BETWEEN.
    ;Inc Path[PATH_NODE_OFFSET] by 1
    move.l  4(SP), a0
    move.l  8(SP), a1
    
    move.l  GET_PATH_ADDR(a1), a2
    clr.l   d0
    move.w  GET_PATH_NODE_OFFSET(a1), d0
    lsl.l   #3, d0
    adda.l  d0, a2                  ;a0 has entity, a1 has the path handler, a2 has the current node on path, 
    clr.l   d0
    lea     INSTRUCTION_BANK, a3
    move.b  GET_PATHNODE_TYPE(a2), d0
    lsl.l   #2, d0                  ;multiply by 4 to account for size of an instruction. Finding instruction in the instruction bank.
    adda.l  d0, a3
    move.l  (a3), a3
    
    
    move.b  GET_PATHNODE_END(a2), d0
    movem.l d0/a0/a1/a3, -(SP)
    jsr     (a3)                    ;Passing arguments because these functions will NEVER be called outside of  here.
    movem.l (SP)+, d0/a0/a1/a3
    
    move.b  d0, d1
    beq     NO_NEXT_PATH_TIMER
    
    
    ;Path node offset needs to be updated and the timer needs to be called IFF GET_PATHNODE_END == 00.
    addi.w  #1, GET_PATH_NODE_OFFSET(a1)
    adda.l  #PATH_NODE_SIZE, a2
    clr.l   d0
    move.l  a1, -(SP)           ;path handler       at input 2
    move.l  a0, -(SP)           ;entity             at input 1
    lea     NEXT_PATH_NODE, a3
    move.l  a3, -(SP)
    move.w  GET_PATHNODE_TIME_ELAPSED(a2), d0
    move.l  d0, -(SP)
    jsr SET_TIMER
    adda.l  #16, SP
    NO_NEXT_PATH_TIMER:
    rts
    

SET_THETAS:
    clr.w   GET_PH_DEL_THET(a1)
    clr.w   GET_PH_THETA(a1)
ADD_THETAS:
    move.w  GET_PATHNODE_ARG_1(a2), d0
    add.w  d0, GET_PH_DEL_THET(a1)
    
    
    ;adding theta, clamping it between 0 and angle max, then putting that value in theta.
    move.w  GET_PATHNODE_ARG_2(a2), d0
    move.w  GET_PH_THETA(a1), d1
    add.w   d1, d0
    divu    #ANGLE_MAX, d0
    swap    d0
    
    move.w  d0, GET_PH_THETA(a1)
    rts

SET_SPEEDS:
    clr.w   GET_PH_ACC(a1)
    clr.w   GET_PH_VEL(a1)
ADD_SPEEDS:
    move.w  GET_PATHNODE_ARG_1(a2), d0
    add.w  d0, GET_PH_ACC(a1)
    move.w  GET_PATHNODE_ARG_2(a2), d0
    add.w  d0, GET_PH_VEL(a1)
    
    rts
    
SPAWN_FORM:
    clr.l   d1
    clr.l   d2
    move.l  GET_POSITION(a0), d0
    move.w  GET_PATHNODE_ARG_1(a2), d1
    move.w  GET_PATHNODE_ARG_2(a2), d2
    move.l  d0, -(SP)
    move.w  d1, -(SP)
    move.w  d2, -(SP)
    jsr SPAWN_FORMATION
    adda.l  #8, SP
    rts    
JUMP_TO_PATH:
    clr.l   d0
    clr.l   d1
    move.w  GET_PATHNODE_ARG_1(a2), d0      ;d0 = path offset
    lsl.l   #2, d0
    lea PATH_BANK, a3
    move.l  (a3, d0), GET_PATH_ADDR(a1)
    move.w  GET_PATHNODE_ARG_2(a2), GET_PATH_NODE_OFFSET(a1)
    subi.w  #1, GET_PATH_NODE_OFFSET(a1)
    rts
   

;Set path node offset to be -1 and for the current node in memory to be 1 path node behind where it should be, to account for incrementation.
LOOP_OVER_PATH:
    move.w  #-1, GET_PATH_NODE_OFFSET(a1)
    move.l  GET_PATH_ADDR(a1), a2
    suba.l  #PATH_NODE_SIZE, a2  
    rts
    
    
INSTRUCTION_BANK
    dc.l    SET_THETAS
    dc.l    ADD_THETAS
    dc.l    SET_SPEEDS
    dc.l    ADD_SPEEDS
    dc.l    SPAWN_FORM
    dc.l    JUMP_TO_PATH
    dc.l    LOOP_OVER_PATH
    
    
TEST_AREA:
    rts
    

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
