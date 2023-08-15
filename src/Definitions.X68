*-----------------------------------------------------------
* Title      :  Definitions and Equates
* Written by :  Anthony Pizzigoni
* Date       :  7/3/2023
* Description:  Throwing general equates into here to make it less muddy everywhere else.
*-----------------------------------------------------------

STAGE_BORDER_X_MAX              EQU     186
STAGE_BORDER_Y_MAX              EQU     240

ENTITY_OFF_SCREEN_MAX           EQU     60        ;add 60 to their x or  and don't save it. if it is above 0, you're good. subtract this twice. if it is lower than max, then spawn it in.


PLAYER_SPAWN_POINT_X            EQU     85
PLAYER_SPAWN_POINT_Y            EQU     190

PIXEL_SHIFT                    EQU     2
ANGLE_MAX                       EQU         $1680


EDT_OFFSET_PLAYER               EQU         $00
EDT_OFFSET_SLIME                EQU         $01
EDT_OFFSET_BULLET               EQU         $02
EDT_OFFSET_ROBOT                EQU         $03


GET_VELOCITY                    EQU         0   ;Get the velocity, 1 byte, unsigned, 2 fractional bits. max velocity of 63.75 (FF)
GET_ACCELERATION                EQU         1   ;Get acceleration, 1 byte, signed, 4 fractional bits. Max Velocity of ~8 (7F)
GET_THETA                       EQU         2   ;Get velocity, 1 byte, the value is 1/4 of actual theta, as theta is only in chunks of 4
GET_ANG_VEL                     EQU         3   ;Get angular velocity, 1 byte, signed.
GET_SPRITE                      EQU         4   ;Go to sprite table and grip up this offset. 1 byte, unsigned. Sprite table holds a table of top left offsets and indexes that load these top left corners.
GET_PATH_INSTRUCTION            EQU         5   ;Get the offset for the Path that this object is following. 1 byte unsigned.
GET_PATH_INSTRUCTION_OFFSET     EQU         6   ;Get the offset of the offset (what stage it is on). 1 byte unsigned (if they go longer, use the FD command to link them.
GET_POWER                       EQU         7   ;Get the power of the object. Power changes between each entity. It could be damage they deal on contact, piercing, number of bombs, etc. 1 byte
GET_POSITION                    EQU         8   ;Get the top left of the object on screen. 1 long word. Vec2
GET_SIZE                        EQU         12  ;Get the width and height of the object on scree. 1 long word. Vec2
GET_COLLISION_BOX_TL            EQU         16  ;Get the top left of the collision box. 1 long word. Vec2. it is an offset from the top left corner.
GET_COLLISION_BOX_BOUNDS        EQU         20  ;Get the bounds of the collision box. 1 long word. Vec2.
GET_HEALTH                      EQU         22  ;Get the health of the object. 1 word, will have to check and see.
GET_INFO                        EQU         24  ;1 word. Most Significant Byte = "are they active" (FF = true, 00 = false). Least Significant Byte = $0("What quadrant and subquadrant are they in?")
GET_ENTITY_TYPE                 EQU         26  ;Most significant byte: What variation of that eneity. Least significant byte: what type of entity                                               
GET_ENTITY_PATH_ADDRESS         EQU         28  ;OR Path Handler address? The address where this entity's data is stored. 1 long.







COLOR_PLAYER_BULLET_OUTER       EQU         $2A6387
COLOR_PLAYER_BULLET_INNER       EQU         $E3F4FF
TRAP_PLAYER_BULLET_SHAPE        EQU         88


MAX_NUM_ENTITIES                EQU     75
MAX_NUM_PLAYERS                 EQU     1
MAX_NUM_PLAYER_BULLETS          EQU     8
MAX_NUM_ENEMIES                 EQU     32
MAX_NUM_ENEMY_BULLETS           EQU     30
MAX_NUM_PLAYER_SWORD            EQU     1
MAX_NUM_PICKUPS                 EQU     3

ENTITY_SIZE                     EQU     32




HUD_OFFSET_X                    EQU     748
HUD_OFFSET_Y                    EQU     -4

HUD_WIDTH                       EQU     70
HUD_HEIGHT                      EQU     240



SCREEN_SIZE_PIXELS_X        EQU     1024
SCREEN_SIZE_PIXELS_Y        EQU     960


GAME_STATE_MAIN_MENU        EQU     0 
GAME_STATE_PLAYING          EQU     1
GAME_STATE_PAUSED           EQU     2
GAME_STATE_HI_SCORE         EQU     3


STATUS_ALIVE                EQU     $FF
STATUS_DEAD                 EQU     $00








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
