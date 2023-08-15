*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Written by :
* Date       :
* Description:

* In this exercise, you will create a subroutine that can display
*   a chunk of a .bmp file. The arguments required for your subroutine are:
*   - Pointer to .bmp file (NOT a pointer to the pixel data)
*   - Top, Left corner (x,y) of the bitmap chunk you want to display
*   - Width and Height of the bitmap chunk you want to display
*   - Top, Left corner (x,y) on the output screen to display your chunk
* You will need to handle 24-bit and 32-bit bitmaps
*debug if not bitmap
* edge cases (not a file)
*-----------------------------------------------------------
    
    ;a0 = reference to bitmap.
      ;Pointer to bmp file is already handled
    ;d5 = top left corner of bitmap X and Y is gonna be handled by d1. Least significant bytes are the X, most significant bytes are the Y
        ;Potential checks: Make sure that X and Y are within the bounds of the picture
    ;d6 = Width and height of bitmap chunk to display will be handled by d2. least significant bytes are X, most significant bytes are Y
        ;potential checks: Make sure that X and Y + corners doesn't take you out of the image. If it does, throw an error
    ;d7 = top left corner of hte output screen to display chunk. will be in d3
        
DISPLAY_BMP_DATA:
   ValidBMP:
        ;LSB in d4 will be set based on the status of the display.
            ;0 = no errors
            ;1 = invalid bmp file/not a bmp file
            ;2 = topleft corner of bmp is invalid
            ;3 = Width and height of d2 is invalid
            ;4 = this is not a 24 or 32-bit bitmap.
            ;if LSB is not 0 by the end of this, go to RestoreRegisters.
                ;Nothing will be displayed and our "error flag" will be set,
                ;to be parsed outside the subroutine

    ;Loading in the width Backup and the "whattoadd"

    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d3
    clr.l   d4            
    move.b 10(a0), d3           ;Saving start offset into d3
    
    move.b  $1C(a0), d4         ;bits per pixel
    
    lea END_LINE_ADD, a1

    
    move.b  $13(a0),d2   ;pic width
    lsl.w   #8, d2
    move.b  $12(a0),d2
    
    add.w  d6, d2       ;picwidth + chunkwidth
    lsl.l   #2, d2
    cmpi.b  #32, d4

    beq TwentyFourBitEndLineChange
    lsr.l   #2, d2
    move.l  d2, d1
    add.l   d1, d2
    add.l   d1, d2
    
    
    TwentyFourBitEndLineChange:
    move.w  d2, (a1)    ;END_LINE_ADD has what to add/subtract at the end/beginning of a line respectively
    lea WIDTH_BACKUP, a2
    move.w  d6, (a2)
    add.w   d6, (a2)
    add.w   d6, (a2)
    add.w   d6, (a2)
    
    ;Height measurements in LSW d5 and d6
    
    clr.w   d2
    move.b  $13(a0),d2   ;pic width
    lsl.w   #8, d2
    move.b  $12(a0),d2
        
    move.b  $17(a0),d1   ;pic height
    lsl.w   #8, d1
    move.b  $16(a0),d1
    
    ;to get starting position, you need to get:
    ;4((TLC.y + height)*totalwidth + (TLC.x + chunkWidth))  OR 3x

    swap    d5
    swap    d6
    clr.l   d0
    
    move.w  d1, d0
    sub.w  d6, d0                          
    sub.w   d5, d0      
    mulu.w  d2, d0      ;Image is stored as bottom left = 0,0
    swap    d5
    swap    d6
    clr.l   d1

    move.w  d6, d1
    add.l   d1, d0
    move.w  d5, d1
    add.l   d1, d0 

    lsl.l   #2, d0      ;d0 is now 4((TLC.y + height)*totalwidth + (TLC.x + chunkWidth)) 
    
    
    cmpi.b  #32, d4     ;if 24 bit, then don't change the value in d0. otherwise, redo the change and multiply by 3.
    beq     TwentyFourBitOffsetChange
    lsr.l   #2, d0
    move.l  d0, d1
    add.l   d1, d0
    add.l   d1, d0
    
    TwentyFourBitOffsetChange:
    add.l   d3, d0
    adda.l  d0, a0   

    lsl.w   #2, d6
    swap    d6
    lsl.w   #2, d6                  ;Width related stuff in LSW d5 and d6
    clr.l   d1
    cmpi.b  #32, d4
    beq     OUTERLOOP32 

 
    DisplayBitmap:
        ;Displaying a 24 bit bitmap. Separated for speed. Instead of doing a cmp and beq call every pixel drawn, do it once and instead make this large. They use the same code anyways.
        OuterLoop24:
        swap    d6
            InnerLoop24:
            clr.l   d1
            suba.l  #3, a0
            move.b  (a0), d1
            lsl.l   #8, d1
            move.b  1(a0), d1
            lsl.l   #8, d1
            move.b  2(a0), d1
            
            
            move.l  #80, d0
            trap    #15
            move.l  #81, d0
            trap    #15
                                        ; DRAWRECTANGLE:
            move.w  #87, d0             ; Drawing rectangles instead of pixels
            move.w  d7, d1
            swap    d7
            move.w  d7, d2
            swap    d7
            add.w   d6, d1
            swap    d6
            add.w   d6, d2
            swap    d6
            move.w  d1, d3
            subi.w  #4, d1
            move.w  d2, d4
            subi.w  #4, d2
            trap    #15
            
            
            subi.w  #4, d6          ;sub from x. 
            bgt     InnerLoop24
        
        adda.w  (a1), a0                ;must account for dead space.
        add.w   (a2), d6
        
        swap    d6
        subi.w  #4, d6
        bgt OuterLoop24
        bra RESTOREREGISTERS
    
    
        OuterLoop32:
        swap    d6
            InnerLoop32:
            move.w  #80, d0
            move.l  -(a0), d1
            lsr.l   #8, d1

            trap    #15
            move.w  #81, d0
            trap    #15
            
            move.w  #87, d0             ;Drawing rectangles instead of pixels
            move.w  d7, d1
            swap    d7
            move.w  d7, d2
            swap    d7
            add.w   d6, d1
            swap    d6
            add.w   d6, d2
            swap    d6
            
            move.w  d1, d3
            addi.w  #4, d3
            move.w  d2, d4
            addi.w  #4, d4
            trap    #15
            
            
            subi.w  #4, d6          ;sub from x. 
            bne     InnerLoop32
        
        adda.w  (a1), a0                ;must account for dead space.
        add.w   (a2), d6
        swap    d6
        subi.w  #4, d6
        bne OuterLoop32
    RestoreRegisters:
        ;Moves values from the stack / an address back to registers
        ;increments the stack pointer back
        ;DO NOT SET D0 HERE.    
    rts


WIDTH_BACKUP            ds.w    1
END_LINE_ADD            ds.w    1

EOF















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
