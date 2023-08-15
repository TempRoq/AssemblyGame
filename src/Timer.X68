*-----------------------------------------------------------
* Title      : Timer
* Written by : Anthony Pizzigoni
* Date       : 6-29-23
* Description: Handles timers
*
*
*NOTE: If the game begins to hang for zero reasons and it has to do with timers,
*it is because callilng a timer when all are filled causes an infinite loop will occur.
*
*Implementd as such because it is fast, easy to read, easy to understand, and if timers are being overwritten, then I would need to know IMMEDIATELY.
*-----------------------------------------------------------


;Each timer is gonna be in seconds



NUM_TIMERS       EQU     150

TIMER_SIZE      EQU     16

GET_TIME_REMAINING   EQU    0           ;lw
GET_FUNCTION_ADDR    EQU    4            ;lw
GET_FUNC_INPUT_1     EQU    8           ;2 lws
GET_FUNC_INPUT_2     EQU    12
    

    
CLEAR_TIMERS:
    lea ALL_TIMERS, a0
    move.l  #$FFFFFFFF, d0
    move.l  #NUM_TIMERS, d7
    CLEAR_TIMER_LOOP:
    move.l  d0, (a0)+
    move.l  d0, (a0)+
    move.l  d0, (a0)+
    move.l  d0, (a0)+
    subi.l  #1, d7
    bgt CLEAR_TIMER_LOOP
    lea CURR_TIMER, a0
    move.l  #0, (a0)
rts


;4 SP = Value to put in timer
;8 SP = Function Address
;12 SP = Function Input 1
;16 SP = Function Input 2




SET_TIMER:

    move.l  4(SP), d0
    bne     NOT_INSTANT_TIMER
    
    ;in the event that the timer is 0, call the function instantly.
    
    move.l  16(SP), d0
    move.l  12(SP), d1
    move.l  8(SP), a0
    move.l  d0, -(SP)
    move.l  d1, -(SP)
    jsr     (a0)
    adda.l  #8, SP  
    rts
    
    NOT_INSTANT_TIMER:
    lea CURR_TIMER, a0
    move.l  (a0), d0
    lsl.l   #4, d0                                  ;getting the offset based on CurrTimer and size of a timer.
    lea ALL_TIMERS, a1
    IS_IT_EMPTY:
    move.l  (GET_TIME_REMAINING, a1,d0), d1         ;if the time remaining is <= 0, then that timer is no longer in use.
    ble MOVE_VALUES
    
    ;subtract 
    subi.l  #TIMER_SIZE, d0                         
    bge IS_IT_EMPTY
    addi.l  #(NUM_TIMERS<<4), d0                    ;going to be called when d0 is at "index -1", and adding the total length to hit index 99.
    bge IS_IT_EMPTY
    rts
   
    MOVE_VALUES:
        adda.l  d0, a1  
        move.l  4(SP), GET_TIME_REMAINING(a1)
        move.l  8(SP), GET_FUNCTION_ADDR(a1)
        move.l  12(SP), GET_FUNC_INPUT_1(a1)
        move.l  16(SP), GET_FUNC_INPUT_2(a1)
        lea CURR_TIMER, a0
        lsr.l   #4, d0
        move.l  d0, (a0)
    rts

UPDATE_TIMERS:
    ;subtract delta time from every timer. 
    clr.l   d7
    lea     DELTA_TIME, a0
    move.l  (a0), d0
    move.l  #TIMER_SIZE, d1
    lea     ALL_TIMERS, a0
    move.l  #NUM_TIMERS, d7
    
    UP_TIM_LOOP:
    move.l  GET_TIME_REMAINING(a0), d2
    ble     INC_LOOP               ;if the timer is 0, then don't bother updating it.
    sub.l   d0, d2
    move.l  d2, GET_TIME_REMAINING(a0)
    bgt     INC_LOOP
    ;if they hit or go below 0, set the time remaining to 0 and go to FUNC_ADDR with this timer's address in the stack
    ;(because you're just gonna read GET_FUNC_INPUT_1 and GET_FUNC_INPUT_2 from here).
    
    move.l  d7, -(SP)
    move.l  d1, -(SP)
    move.l  d0, -(SP)  
    move.l  a0, -(SP)
    
    move.l  GET_FUNC_INPUT_2(a0), -(SP)
    move.l  GET_FUNC_INPUT_1(a0), -(SP)
    move.l  GET_FUNCTION_ADDR(a0), a1
    jsr     (a1)
    
    adda.l  #8, SP
    move.l  (sp)+, a0
    move.l  (sp)+, d0
    move.l  (SP)+, d1
    move.l  (SP)+, d7


    INC_LOOP:  
    adda.l   d1, a0
    subi.b  #1, d7
    bne UP_TIM_LOOP
    rts

    
CURR_TIMER      dc.l       0       
ALL_TIMERS      ds.b       NUM_TIMERS*TIMER_SIZE










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
