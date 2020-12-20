;******************************************************************************
;**                                                                          **
;**                   P I N B A L L   F A N T A S I E S                      **
;**                          TABLE: SPEED DEVILS                             **
;**                                                                          **
;******************************************************************************

INCLUDELIB Sdev.LIB

flipgfxfilesize=168
FIRSTMASK_GFXADR=BPL*(SPLH+BANH)
GFXADR_FOR_FLIP_ANIM_DATA=FIRSTMASK_GFXADR+BPL*40
springsourceadr=GFXADR_FOR_FLIP_ANIM_DATA-3*23	;3*23 éR FôR FJéDERNS GFX
springdestadr=(splh+556)*bpl+304/4
std_lgt_speed=15		;som pilarna blinkar i ju . . . 
TurboDelay=60*3
blet=1	;hur mÜnga ggr fîr lÑnge mellan looparna

DATAFLIP SEGMENT PARA PUBLIC 'DATA'
MAXDIFS1=114+5
MAXDIFS2=114+5
MAXDIFS3=114+5
maxdifs=114
if create_flip_data
	LEFTFLIPTAB	DW 42*(2*MAXDIFS1) DUP (1)
	RIGHTFLIPTAB	DW 42*(2*MAXDIFS2) DUP (1)
	LEFTFLIP2TAB	DW 30*(2*MAXDIFS3) DUP (1)
	TEMPTAB		DW 2*MAXDIFS DUP (1)	
else
	extrn	leftfliptab,rightfliptab,leftflip2tab
endif
DATAFLIP ENDS

DATA	SEGMENT PARA PUBLIC 'DATA'
	ASSUME CS:CODE,DS:DATA
MODUL	DB 'TABLE2.MOD',0,'$'
if create_flip_data
flipdatafil_L	DB 'flipdata.2L',0
flipdatafil_R	DB 'flipdata.2R',0
flipdatafil_L2	DB 'flipdata.2L2',0
flipgfxfil	DB 'flipgfx.2',0
flipSTRUCfil	DB 'flipSTRU.2',0
endif
hi_score_file	db 'table2.hi',0
hi_score_list	db 0,0,0, 1,0,0, 0,0,0, 0,0,0,'TSP',0
		db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'J L',0
		db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ICE',0
		db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'ANY',0

;******************************************************************************
;******************************** DEFINITIONS *********************************
;******************************************************************************
stones=0	;true
TOTCENT=16
CYCLONECOUNTER DW ?				;HEXADECIMAL
cyclonecounterBCD	DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
CYCLONESCOREBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
XXBALLE			DB ?

;******************** SYSTEM **********************
RGB_BUFFER_LEN=1500
MAX_NO_OF_LIGHTS_FLASHING=64
MAX_NO_OF_WAIT_SYNCS=50
NOOFTASKS=20

;******************** FLIPPER & BALL **********************
BALLH=16
BANH=576
STARTX=310-BALLH/2+3
STARTY=543-BALLH/2

F3TOP=168
F3HEIGHT=53

;******************** FLASHING **********************
MATRIXHI=62H
MATRIXLO=80H
MATRIXCOLS=MATRIXHI*256+MATRIXLO
BIT2COL			DB 0,0,0,0,31,1,52,0	;flipper fÑrgerna

PARTY_ON_SPEED=3	;?
SHOOT_AGAIN_SPEED=3	;?

POS_SYNCER		DB	?	;LIGHT SYNC

;******************** GAME TIMING ********************

;******************** HOLES **********************

;******************************************************************************
;****************************** GENERAL VARS **********************************
;******************************************************************************
if create_flip_data
FlipLInfo	DB    FlipperL,222
		DW    80,510,4,53,0,142,400,576,95,536,0,(53*8*3)
		DW    0,0,0,20,20*ADJUST,-7*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW	?,?,?,?,LEFTFLIPTAB,LEFTFLIPTAB,maxdifs1*4
		DW    FLIPLEFT

		DB    FlipperR,222
		DW    160,510,4,53,143,320,400,576,204,536,0,(53*8*3)
		DW    0,0,0,20,20*ADJUST,-7*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW	?,?,?,?,RIGHTFLIPTAB,RIGHTFLIPTAB,maxdifs2*4
		DW    FLIPRIGHT

		DB    FlipperR,222
		DW    144,168,4,53,0,320,100,300,188,198,0,(53*8*3)
		DW    0,0,0,14,14*ADJUST,-5*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW	?,?,?,?,LEFTFLIP2TAB,LEFTFLIP2TAB,maxdifs3*4
		DW    FLIPLEFT2+(4*(53*8*3))/16
                DB    0,0
else
	extrn	fliplinfo:flipstruc
endif
no_of_ramps equ 6
RAMPTABLE	DW	0,10*tt/nn
		DW	0,15*tt/nn
		DW	0,25*tt/nn
		DW	-1,10*tt/nn
		DW	0,20*tt/nn
		DW	12*tt/nn,10*tt/nn
		DW	0,0

RAMPTABLE_hi	DW	0,10
		DW	0,15
		DW	0,25
		DW	-1,10
		DW	0,20
		DW	12,10
		DW	0,0

PLAYER_STRUC STRUC
	P_SIFFRORNA		DB 12 DUP(?)
	P_BONUSSIFFRORNA	DB 12 DUP(?)
	p_cyclonecounterBCD	db 12 dup(?)
	p_cyclonecount		dw ?
	p_speeden		dw ?
	p_gearet		dw ?
	p_nextjump		dw ?
	p_nextoffroad		dw ?
	p_pos_light		dw ?
	p_pos_flash		dw ?
	p_goallight		db ?
	p_gear			db ?	;Gyllenhammar??
	p_ear			db ?
	p_aron			db ?
	p_rapa			db ?	;Ja hoppas den e bra . . 
	p_part1			db ?
	p_part2			db ?
	p_part3			db ?
	p_part4			db ?
	p_part5			db ?
	p_part1_l		db ?
	p_part2_l		db ?
	p_part3_l		db ?
	p_part4_l		db ?
	p_part5_l		db ?
	p_Carparten		DW ?
	p_hbcount		db ?
	p_tm_total		db 12 dup (?)
	p_or_total		DB 12 dup (?)
ENDS
PLAYER_AREA DB SIZE PLAYER_STRUC * NO_OF_PLAYERS DUP(0)
;******************************************************************************
;********************************* EFFECTS ************************************
;******************************************************************************

EFFECT_STRUC STRUC
	THEJINGLE	DW ?
	TSCORE		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	TBONUS		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	DOTMATRIX	DW ?
ENDS

Turboeffect	dw SJingle21
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw 0

jump_at		dw 0
		db 35
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw Jump_At_TS

offroad_at_10	dw 0
		db 35
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw offroad_At_10_TS
		
xball_at_20	dw 0
		db 35
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw Xball_At_20_TS

OffRoad_at	dw 0
		db 35
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw OffRoad_At_TS

		
SuperJack	dw SJingle3
		db 0,0,0, 0,5,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		dw SuperJackTS

JackPot		dw SJingle2
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw JackPotTS

SuperJack2	dw SJingle3
		db 0,0,0, 0,5,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		dw superJack2TS

		
HoldBonus	dw S_Lock
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw BonusHeldTS


NumberOne	dw SJingle18
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw 0
				
XBall		dw SJingle4
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW XballTS

litXBall	dw 0
		db 90
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW litXballTS
		dw 0

		
Jump		dw SJingle11
		db 0,0,0, 0,1,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW JumpTS

lgt_Jump	dw SJingle10
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW litJumpTS

Part1		dw SJingle15
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw Part1TS
Part2		dw SJingle15
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw Part2TS
Part3		dw SJingle15
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw Part3TS
Part4		dw SJingle15
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw Part4TS
Part5		dw SJingle15
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw Part5TS

GearChange	dw SJingle16
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,2,5, 0,0,0
		dw GearTS

Speedo		dw Sjingle8			;CP! Olika fîr varje speed!!
		db 0,0,0, 0,0,0, 2,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,2,5, 0,0,0
		DW PedalTS

		
OverTake	dw SJingle17
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		dw OverTakeTS

GoalLit		dw SJingle12
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW 0

GetGoal		dw SJingle7		;13
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW TurboTS
		
LOSTBALL	DW 0	;S_LOSTBALL
		DB 255
;		DD 0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW ball_lostTS


BygelSetA	DW S_Tilt			;sidotrill ned . . 
		db 0,0,0, 0,0,0, 0,5,0, 0,7,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW 0

BygelSetB	dw 0
		db 200				;rîrnedfall . . 
		db 0,0,0, 0,0,0, 0,1,0, 0,1,0
		db 0,0,0, 0,0,0, 0,0,1, 0,3,0
		DW 0

BygelSetC	dw 0
		db 200				;P I T
		db 0,0,0, 0,0,0, 0,1,0, 0,2,0
		db 0,0,0, 0,0,0, 0,0,1, 0,1,0
		DW 0
MBLit		dw Sjingle9			;Multi Bonus Lit	
		db 0,0,0, 0,0,0, 0,1,0, 0,2,0
		db 0,0,0, 0,0,0, 0,0,1, 0,1,0
		DW 0
		
BygelSetD	dw 0
		db 200				;Ut ur OffRoad . . 
		db 0,0,0, 0,0,0, 0,1,0, 0,4,0
		db 0,0,0, 0,0,0, 0,0,1, 0,5,0
		DW 0
		
BygelSetE	dw 0
		db 200				;In i offroad . . 
		db 0,0,0, 0,0,0, 0,1,0, 0,4,0
		db 0,0,0, 0,0,0, 0,0,1, 0,9,0
		DW 0
DB ?
Million		dw Sjingle6			;In i offroad, full bonus
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		dw MillionTS
DB ?
;Speeds (Loops get higher score for higher speeds)
SScore1		dw 0
		db 30
		db 0,0,0, 0,0,0, 0,2,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore2		dw 0
		db 30
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore3		dw 0
		db 30
		db 0,0,0, 0,0,0, 0,7,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore4		dw 0
		db 30
		db 0,0,0, 0,0,0, 1,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore5		dw 0
		db 30
		db 0,0,0, 0,0,0, 1,2,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore6		dw 0
		db 30
		db 0,0,0, 0,0,0, 1,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore7		dw 0
		db 30
		db 0,0,0, 0,0,0, 1,7,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore8		dw 0
		db 30
		db 0,0,0, 0,0,0, 2,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore9		dw 0
		db 30
		db 0,0,0, 0,0,0, 2,2,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore10	dw 0
		db 30
		db 0,0,0, 0,0,0, 2,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore11	dw 0
		db 30
		db 0,0,0, 0,0,0, 2,7,5, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS
SScore12	dw 0
		db 30
		db 0,0,0, 0,0,0, 3,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW MilesTS

			
;Multiply Bonus vill ligga tÑtt ihop ;-)
M2		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,0,0
		DW m2TS

M3		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,0,0
		DW m3TS
M4		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,2, 0,0,0
		DW m4TS
M5		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,3, 0,0,0
		DW m5TS
M6		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,4, 0,0,0
		DW m6TS
M7		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,5, 0,0,0
		DW m7TS
M8		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,6, 0,0,0
		DW m8TS
M9		DW SJingle1
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,7, 0,0,0
		DW m9TS

if demover
MINUTE5		DW S_GAMEOVER2	
;		DD 0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW minute5TS
endif
BONUS_X			DB ?
TEMPBONUSBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?

JACKVALUE		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;JACKPOT CURRENT
JACKRAISE		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;JACKPOT STEP
JACKINIT		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;JACKPOT START

etta	db 0,0,0,0,0,0,0,0,0,0,0,1
HUNDRATUSEN	db 0,0,0,0,0,0,1,0,0,0,0,0
BCDfemmillioner db 0,0,0,0,0,5,0,0,0,0,0,0
bcd7510	db 0,0,0,0,0,0,0,0,7,5,1,0
bcd7520	db 0,0,0,0,0,0,0,0,7,5,2,0
bcd550	db 0,0,0,0,0,0,0,0,0,5,5,0
bcd570	db 0,0,0,0,0,0,0,0,0,5,7,0
bcdhundratusen db 0,0,0,0,0,0,1,0,0,0,0,0
;******************************************************************************
;**************************** SOUND STRUCTURES ********************************
;******************************************************************************

;SAMPLE,PERIOD,EFFECT,CHANNEL

sbase		Equ	21+1

SBrickNer	db	(sbase+0),18,0,3
SBrickUpp	db	(sbase+1),18,0,3
SBumper		db	(sbase+2),18,0,3
SFlippUpp	db	(sbase+3),22,0,3
SRinner		db	(sbase+4),18,0,3
SNewBall	db	(sbase+6),18,0,3
SKicker		db	(sbase+7),18,0,3
SFjader		db	(sbase+8),18,0,3
SGrop		db	(sbase+1),18,0,3



;***********************************************************************

ebase		Equ	26+1

;????????????????????????????????????????????
S_AddPlayer2	db	(ebase+0),20,0,3
;????????????????????????????????????????????

SBygel1		db	(ebase+0),10,0,3
SBygel2		db	(ebase+0),12,0,3
SBygel3		db	(ebase+0),8,0,3
SBygel4		db	(ebase+0),17,0,3
SBygel5		db	(ebase+0),8,0,3
S_Touch1	db	(ebase+0),14,0,3
S_Touch2	db	(ebase+0),10,0,3
S_MultiLjud	db	(ebase+0),10,0,3
S_ScoreLjud	db	(ebase+0),18,0,3
S_TripCount	db	(ebase+0),15,0,3

;***********************************************************************
;*                 Here comes the jingles . . .                        *
;***********************************************************************
emptyjingle equ 55
springjingle equ 0
mainjingle equ 2
lastmainpos equ 9

S_Empty		db	55,0,0
S_Spring	db	0,0,0
S_Main		db	2,0,0
S_NoHigh	db	10,0,0
S_Danger	db	40,1,250
S_Tilt		db	39,1,250
S_GameOver	db	26,0,0
S_GameOver2	db	61,0,255	;0
S_LostBall	db	24,1,255	;200 ???
S_AddPlayer	db	0,0,0
S_Lock		db	27,1,90		;Bonus Locked
S_Mystery	db	0,0,0
S_EndFig	db	50,1,0
S_Knacket	db	51,1,230
S_BEATEN	DB	51,1,249

;***********************************************************************

SJingle1		db	25,1,60		;Multi Bonus
SJingle2		db	38,1,190	;Jackpot
SJingle3		db	41,4,200	;Super Jackpot
SJingle4		db	28,1,180	;Extra Ball
SJingle5		db	30,1,100	;Jackpot Lit
SJingle6		db	44,1,61		;Million
SJingle7		db	34,0,255	;Turbo (0)
SJingle8		db	42,1,50		;Add Speed
SJingle9		db	48,1,60		;Multi Bonus Lit
SJingle10		db	32,1,40		;Jump Lit
SJingle11		db	43,1,70		;Jump
SJingle12		db	45,1,100	;Goal Lit
SJingle13		db	46,1,200	;Goal
SJingle15		db	33,1,110	;Extra Features
SJingle16		db	29,1,80		;Change Gear
SJingle17		db	37,1,62		;Overtake
SJingle18		db	49,1,200	;Number One
SJingle19		db	31,1,100	;Double Bonus
SJingle20		db	36,1,255	;Turbo End (0)
SJingle21		db	24,1,30		;Ramps
SJingle22		db	56,0,254	;Off Road (0)
SJingle23		db	60,1,255	;Off Road End (60)

;******************************************************************************
;***************************** DETECTION AREAS ********************************
;******************************************************************************

BumperLista_L	dw	52,193,76,217
		dw	Bumper1
		dw	5,223,28,247
		dw	Bumper2
		dw	52,253,67,274
		dw	Bumper3
		dw	5,283,28,307
		dw	Bumper4
BumperLista_U	dw	-1,-1,-1,-1
		dw	0

Bumper2Lista_L	dw	50,415,80,470	;Just to add power
		dw	Kicker1		;No Scores or effects
		dw	219,415,249,470
		dw	Kicker2
Bumper2Lista_U	dw	-1,-1,-1,-1
		dw	0

bumper1		dw	sbumper
		db	0,0,0, 0,0,0, 0,0,1, 0,3,0	;1,030
bumper2		dw	sbumper
		db	0,0,0, 0,0,0, 0,0,1, 0,3,0	;1,030
bumper3		dw	sbumper
		db	0,0,0, 0,0,0, 0,0,1, 0,3,0	;1,030
bumper4		dw	sbumper
		db	0,0,0, 0,0,0, 0,0,1, 0,3,0	;1,030

kicker1		dw	skicker
		db	0,0,0, 0,0,0, 0,0,0, 5,1,0	;510
kicker2		dw	skicker
		db	0,0,0, 0,0,0, 0,0,0, 5,1,0	;510


ZonLista_L	label word


		DW	168,235,183,250,bricka_b
		DW	183,246,199,258,bricka_u
		DW	199,254,215,266,bricka_r

		DW	261,261,271,278,bricka_n
		DW	271,278,278,294,bricka_i
		DW	278,294,290,310,bricka_nn


		dw 0
comment\
		dw	168,235,215,265
		dw	TouchSetA		;B U R
		dw	261,261,290,310
		dw	TouchSetB		;N I N'
		\
ZonLista_U	label	word
		dw	0

AreaLista_L	label	word
		dw	260,35,275,60	;PITSTOP
		dw	GropA		

		dw	295,50,320,70	;Game On
		dw	Close1

		dw	140,50,170,70	;Jump
		dw	Bygel16

		dw	10,65,40,95
		dw	Bygel9		;OffRoad . . 

;		dw	255,85,285,110	;ingÜng till P I T
;		dw	Close2

		dw	140,90,160,110	;ingÜng under jump
		dw	Bygel17

;P I T
		dw	253,124,263,130
		dw	Bygel7
		dw	228,132,238,138
		dw	Bygel6
		dw	205,140,215,146
		dw	Bygel5
;UtgÜng Offroad
		dw	25,310,35,320
		dw	Bygel8

;Hîger och VÑnster Rîr
		dw	25,435,35,445
		dw	Bygel3
		dw	263,435,273,445
		dw	Bygel4
;Sidelanes
		dw	5,455,15,465
		dw	Bygel1
		dw	284,455,294,465
		dw	Bygel2
;Spring Invalid
		dw	300,480,320,500
		dw	Open2

		dw	305,512,320,576	;Spring Valid
		dw	Bygel28
		dw	0

AreaLista_U	label	word
		dw	145,13,180,35
		dw	Bygel10		;îvre loop

		dw	295,50,320,60	;nedslÑpp
		dw nedslapp
		
		dw	120,64,150,78
		dw	Bygel12		;Jump

		dw	1,250,20,290
		dw	Bygel11		;nedre loop

		dw	0

AREALISTA_L_T	LABEL WORD
AREALISTA_U_T	LABEL WORD
		DW	0

level1lista	label word
		dw	160,40,195,70
;		dw	295,50,320,70		;nedslÑpp


		dw	70,140,100,180
		dw	295,200,320,250
		dw	230,210,280,250
		dw	100,270,130,360
		dw	60,320,100,350
		dw	260,450,277,470
		dw	0,450,50,470
		dw	-1

level2lista	label	word
		dw	70,115,100,140
		dw	295,150,320,200
		dw	245,170,290,200
		dw	60,280,80,320
		dw	-1



;******************************************************************************
;************************ DEMO MODE LIGHT FLASHING ****************************
;******************************************************************************

FLASHLIST	LABEL WORD
		T1=5
		T2=T1*10
		DW 0,T1*0,T2,T2,42	;BONUS
		DW 0,T1*1,T2,T2,43
		DW 0,T1*2,T2,T2,44
		DW 0,T1*3,T2,T2,45
		DW 0,T1*4,T2,T2,46
		DW 0,T1*5,T2,T2,47
		DW 0,T1*6,T2,T2,48
		DW 0,T1*7,T2,T2,49

		T2=10			;BURNIN'
		DW 0,0,T2,T2,16
		DW 0,0,T2,T2,18
		DW 0,T2,T2,T2,17
		DW 0,0,T2,T2,19
		DW 0,0,T2,T2,21
		DW 0,T2,T2,T2,20

		T2=12			;P I T
		DW 0,0,T2,T2,6
		DW 0,0,T2,T2,8
		DW 0,T2,T2,T2,7

		T2=13			;G E A R
		DW 0,0,T2,T2,22
		DW 0,T2,T2,T2,23
		DW 0,0,T2,T2,24
		DW 0,T2,T2,T2,25

		T2=10			;VéXELLèDAN
		DW 0,0,T2,T2,26
		DW 0,T2,T2,T2,27
		DW 0,0,T2,T2,28
		DW 0,T2,T2,T2,29
		DW 0,0,T2,T2,30
		DW 0,T2,T2,T2,31
		
		T2=15			;TéNDSTIFT
		DW 0,0,T2,T2,55

		DW -1

;******************************************************************************
;**************************** LIGHT PALETTE DATA ******************************
;******************************************************************************

NOOFLIGHTS=67

LON1	DB 253		;XBALL
	DB 3
	DB 77,0,0
	DB 58,0,0
	DB 95,0,0

LON2	DB 250		;HOLDBONUS
	DB 3
	DB 77,0,0
	DB 58,0,0
	DB 95,0,0

LON3	DB 247		;SUPER
	DB 3
	DB 77,0,0
	DB 58,0,0
	DB 95,0,0

LON4	DB 244		;MB
	DB 3
	DB 58,0,0
	DB 77,0,0
	DB 95,0,0

LON14	DB 242		;GET PART 3
	DB 2
	DB 95,77,0
	DB 95,95,52

LON6	DB 240		;P
	DB 2
	DB 58,58,58
	DB 95,95,95
LON7	DB 238		;I
	DB 2
	DB 58,58,58
	DB 95,95,95
LON8	DB 236		;T
	DB 2
	DB 58,58,58
	DB 95,95,95
LON9	DB 234		;GOAL
	DB 2
	DB 95,95,95
	DB 58,58,58

LON10	DB 232		;GET PART 5
	DB 2
	DB 95,77,0
	DB 95,95,52
LON11	DB 230		;GET PART 1
	DB 2
	DB 95,77,0
	DB 95,95,52
LON12	DB 228		;GET PART 4
	DB 2
	DB 95,77,0
	DB 95,95,52
LON13	DB 226		;GET PART 2
	DB 2
	DB 95,77,0
	DB 95,95,52

LON5	DB 224		;JUMP
	DB 2
	DB 70,70,70
	DB 95,95,95

LON15	DB 221		;JP
	DB 3
	DB 77,0,0
	DB 58,0,0
	DB 95,0,0
LON16	DB 219		;B
	DB 2
	DB 70,70,70
	DB 95,95,95
LON17	DB 217		;U
	DB 2
	DB 70,70,70
	DB 95,95,95
LON18	DB 215		;R
	DB 2
	DB 70,70,70
	DB 95,95,95
LON19	DB 213		;N
	DB 2
	DB 27,64,39
	DB 14,83,72
LON20	DB 211		;I
	DB 2
	DB 27,64,39
	DB 14,83,72
LON21	DB 209		;N'
	DB 2
	DB 27,64,39
	DB 14,83,72
LON22	DB 207		;G
	DB 2
	DB 58,0,0
	DB 95,0,0
LON23	DB 205		;E
	DB 2
	DB 58,0,0
	DB 95,0,0
LON24	DB 203		;A
	DB 2
	DB 58,0,0
	DB 95,0,0
LON25	DB 201		;R
	DB 2
	DB 58,0,0
	DB 95,0,0
LON26	DB 199		;VéXEL 1
	DB 2
	DB 95,89,0
	DB 95,95,52
LON27	DB 197		;VéXEL 2
	DB 2
	DB 95,89,0
	DB 95,95,52
LON28	DB 195		;VéXEL 3
	DB 2
	DB 95,89,0
	DB 95,95,52
LON29	DB 193		;VéXEL 4
	DB 2
	DB 95,89,0
	DB 95,95,52
LON30	DB 191		;VéXEL 5
	DB 2
	DB 95,89,0
	DB 95,95,52
LON31	DB 189		;VéXEL 6
	DB 2
	DB 95,89,0
	DB 95,95,52

LON41	DB 188		;POS 1
	DB 1
	DB 95,95,52
LON40	DB 187		;POS 2
	DB 1
	DB 95,95,52

LON39	DB 186		;POS 3
	DB 1
	DB 95,89,0
LON38	DB 185		;POS 4
	DB 1
	DB 95,89,0

LON37	DB 184		;POS 5
	DB 1
	DB 95,77,0
LON36	DB 183		;POS 6
	DB 1
	DB 95,77,0

LON35	DB 182		;POS 7
	DB 1
	DB 58,58,83
LON34	DB 181		;POS 8
	DB 1
	DB 58,58,83

LON33	DB 180		;POS 9
	DB 1
	DB 70,39,64
LON32	DB 179		;POS 10
	DB 1
	DB 70,39,64
LON42	DB 177		;BONUS X2
	DB 2
	DB 58,0,0
	DB 95,0,0
LON43	DB 175		;BONUS X3
	DB 2
	DB 58,0,0
	DB 95,0,0
LON44	DB 173		;BONUS X4
	DB 2
	DB 58,0,0
	DB 95,0,0
LON45	DB 171		;BONUS X5
	DB 2
	DB 58,0,0
	DB 95,0,0
LON46	DB 169		;BONUS X6
	DB 2
	DB 58,0,0
	DB 95,0,0
LON47	DB 167		;BONUS X7
	DB 2
	DB 58,0,0
	DB 95,0,0
LON48	DB 165		;BONUS X8
	DB 2
	DB 58,0,0
	DB 95,0,0
LON49	DB 163		;BONUS X9
	DB 2
	DB 58,0,0
	DB 95,0,0
LON53	DB 162		;MOTOR
	DB 1
	DB 95,0,0
LON50	DB 160		;KJOLAR
	DB 2
	DB 58,0,0
	DB 95,0,0
LON51	DB 158		;FJéDRING
	DB 2
	DB 58,0,0
	DB 95,0,0
LON54	DB 156		;RATT
	DB 2
	DB 58,0,0
	DB 95,0,0
LON52	DB 154		;SPOJLER VINGE
	DB 2
	DB 58,0,0
	DB 95,0,0

LON55	DB 153		;TéNDSTIFT
	DB 1
	DB 95,0,0

LON56	DB 152-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
LON57	DB 150-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
LON58	DB 148-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
LON59	DB 146-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
LON60	DB 144-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
LON61	DB 142-1	;speedometer
	DB 2
	DB 58,58,58
	DB 95,95,95
	
LON62	DB 140-1	;speedometer
	DB 2
	DB 95,77,0
	DB 95,95,52

LON63	DB 138-1	;speedometer
	DB 2
	DB 95,77,0
	DB 95,95,52


LON64	DB 136-1	;speedometer
	DB 2
	DB 83,58,0
	DB 95,77,0

LON65	DB 134-1	;speedometer
	DB 2
	DB 83,58,0
	DB 95,77,0


LON66	DB 132-1	;speedometer
	DB 2
	DB 58,0,0
	DB 95,0,0

LON67	DB 130-1	;speedometer
	DB 2
	DB 58,0,0
	DB 95,0,0

MATRIXON DB matrixlo ;(MATRIXCOL LOW BYTE)
	DB 1
	DB 95,70,27

LONEND	DB 0

LONINDEX LABEL WORD
	DW OFFSET LON1
	DW OFFSET LON2
	DW OFFSET LON3
	DW OFFSET LON4
	DW OFFSET LON5
	DW OFFSET LON6
	DW OFFSET LON7
	DW OFFSET LON8
	DW OFFSET LON9
	DW OFFSET LON10
	DW OFFSET LON11
	DW OFFSET LON12
	DW OFFSET LON13
	DW OFFSET LON14
	DW OFFSET LON15
	DW OFFSET LON16
	DW OFFSET LON17
	DW OFFSET LON18
	DW OFFSET LON19
	DW OFFSET LON20
	DW OFFSET LON21
	DW OFFSET LON22
	DW OFFSET LON23
	DW OFFSET LON24
	DW OFFSET LON25
	DW OFFSET LON26
	DW OFFSET LON27
	DW OFFSET LON28
	DW OFFSET LON29
	DW OFFSET LON30
	DW OFFSET LON31
	DW OFFSET LON32
	DW OFFSET LON33
	DW OFFSET LON34
	DW OFFSET LON35
	DW OFFSET LON36
	DW OFFSET LON37
	DW OFFSET LON38
	DW OFFSET LON39
	DW OFFSET LON40
	DW OFFSET LON41
	DW OFFSET LON42
	DW OFFSET LON43
	DW OFFSET LON44
	DW OFFSET LON45
	DW OFFSET LON46
	DW OFFSET LON47
	DW OFFSET LON48
	DW OFFSET LON49
	DW OFFSET LON50
	DW OFFSET LON51
	DW OFFSET LON52
	DW OFFSET LON53
	DW OFFSET LON54
	DW OFFSET LON55
	DW OFFSET LON56
	DW OFFSET LON57
	DW OFFSET LON58
	DW OFFSET LON59
	DW OFFSET LON60
	DW OFFSET LON61
	DW OFFSET LON62
	DW OFFSET LON63
	DW OFFSET LON64
	DW OFFSET LON65
	DW OFFSET LON66
	DW OFFSET LON67

MATRIXOFF DB matrixlo
	DB 3
	DB 3 DUP(33*64/100)

;******************************************************************************
;************************* GATES & BYGLARS DATA AREOR *************************
;******************************************************************************
;*****************
SNACKX=263-7		;?		;CP! CP-METOD ATT HèLLA FAST BOLLEN!
SNACKY=48-7		;?
SNACKXS=-420*6*TT/NN	;?
SNACKYS=160*6*TT/NN	;?
;*****************
b_flashin db ?
u_flashin db ?
r_flashin db ?
n_flashin db ?
i_flashin db ?
nn_flashin db ?

flash7down dw ?
flash6down dw ?
flash5down dw ?
flash_pit_down dw ?
jackdown dw ?
mb_pa_lager	db ?
mb_gjorda	db ?
pos_light	dw ?
pos_flash	dw ?
loop_h	dw ?
loop_l	dw ?
loop_h_	dw ?
loop_l_	dw ?
jump_	dw ?
gearet	dw ?
gear_down dw ?
speeden	dw ?
PartList	dw part1,11
		dw part2,13
		dw part3,14		;cp!! 5??
		dw part4,12
		dw part5,10
CarParten	dw ?
NextOffRoad	dw 40	;?
NextJump	dw 30	;?
MilesCount	equ cyclonecounter	;dw ?
OffRoadMode	db ?
TurboMode	db ?
SnackDisabled	db ?
HOLDBONUSFLAG		DB ?
holdbonuscount db ?
NISSAN DB 0
PARTYFLASH		DB FALSE
MUSICOK			DB ?

;******************************************************************************
;****************************** DOT MATRIX ************************************
;******************************************************************************
clearit macro
assume ds:data2
	dw _CLEAR1
assume	ds:data
endm

;*********************************************************
;******* OBS!!! KOM IHèG ATT ASSUMERA ANIMATIONER TILL DATA2 OCH 
;******* SCROLLAR TILL DATA !!!!!
ASSUME	DS:DATA2

BEATENSCROLL	DB 21 DUP (1),'YOU HAVE BEATEN THE HIGHSCORE',21 DUP(1),255
EXTRABALLTEXT	DB 'EXTRA BALL',0

Beaten_bh_TS	LABEL WORD	;I BALL LOST SEKVENSEN
		DW _WAIT,1
		DW _DOBEATEN,?
		DW _WAIT,1
		CLEARIT
		DW _JINGLE,S_BEATEN
		DW _LASTJINGLE,EMPTYJINGLE
		DW _SCROLL,BEATENSCROLL
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _SETDECCOR,90
		DW _WAITJINGLE2,?
		CLEARIT
		DW _FLASHOFF,?
		DW _JMP,No_Bonus2TS

BeatenTS	LABEL WORD	;I SPELET
		DW _WAIT,1
		DW _DOBEATEN,?
		DW _WAIT,1
		CLEARIT
		DW _JINGLE,S_BEATEN
		DW _LASTJINGLE,3
		DW _SCROLL,BEATENSCROLL
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _WAIT,10*2*10
		CLEARIT
		DW _FLASHOFF,?
		DW 0


BCD50000000		DB 0,0,0, 0,5,0, 0,0,0, 0,0,0
supertext	db 'SUPER',0

SuperJackTS	LABEL WORD
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,SUPERTEXT,SW*4/4+7*4
		DW _WAIT,100
		DW _FLASHOFF,?
		CLEARIT
		ASSUME	DS:DATA2
		DW _ANIMATION,_JACKPOT
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER_CENT,BCD50000000,2*2*SW/4+TOTCENT
		DW _WAIT,100
		CLEARIT
		DW _FLASHOFF,?
		dw _return_of_the_evil_supermode,?
		dw 0

SuperJack2TS	LABEL WORD
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,SUPERTEXT,SW*4/4+7*4
		DW _WAIT,100
		DW _FLASHOFF,?
		CLEARIT
		ASSUME	DS:DATA2
		DW _ANIMATION,_JACKPOT
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER_CENT,BCD50000000,2*2*SW/4+TOTCENT
		DW _WAIT,100
		CLEARIT
		DW _FLASHOFF,?
		dw _turnonturbo
		dw 0
		
JackPotTS	label	word
		dw _CLEAR4
		dw _animation,_jackpot
		dw _CLEAR4
		dw _return_of_the_evil_supermode,?
		dw 0

OverTakeTS	label	word
		dw _CLEAR4
		dw _animation,_overtake
		dw _CLEAR4
		dw 0

millionTS	label	word
		dw _CLEAR4
		dw _animation,_million
		dw _CLEAR4
		dw 0

xballTS	label	word
		dw _CLEAR4
		dw _animation,_xballa
		DW _WAIT,30		;CPW!
		dw _CLEAR3
		dw 0
GEARTS	label	word
		dw _CLEAR4
		dw _animation,_gear
		dw _CLEAR4
		dw 0


m2TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m2
		dw _CLEAR4
		dw 0
m3TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m3
		dw _CLEAR4
		dw 0
m4TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m4
		dw _CLEAR4
		dw 0
m5tS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m5
		dw _CLEAR4
		dw 0
m6TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m6
		dw _CLEAR4
		dw 0
m7TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m7
		dw _CLEAR4
		dw 0
m8TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m8
		dw _CLEAR4
		dw 0
m9TS		label	word
		dw _CLEAR4
		dw _animation,_multi
		dw _animation,_m9
		dw _CLEAR4
		dw 0


;*****************************************
party_onTS	LABEL BYTE	;Turn on party on . . . 
		CLEARIT
		DW _FLASHON,PARTY_ON_SPEED
		DW _PARTYONN,1
		DW _PRINT13,PARTY_ON_TEXT,SW*4/4 ;+16*3/4		;CP!
		DW _PARTYON,1
		DW 0

party_offTS	LABEL WORD	;Turn it off	
		CLEARIT
		DW _PARTYOFF,1
		DW _FLASHOFF,1
		DW 0

;*****************************************
		ASSUME	DS:DATA2
clearTS		dw _CLEAR4
		dw 0

tomTS		dw _CLEAR4
		dw _wait,32767
		dw 0

assume	ds:data

OffRoadTS	LABEL WORD
		clearIT
		dw _scroll,go_for_some_text
		clearIT
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		dw _countdown,2,5,OR_total ;(the final?)
		clearIT
OffRoad_endingTS Label Word
		DW _JBCDZ,OR_TOTAL,no_orTS
		dw _rullgardin_upp,or_total_text,1

		dw _wait,60		;CPW!
		
		clearIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER,OR_total,SW*4/4+16*2/4 ;CP! RUTCENT
		dw _wait,80		;CPW!
		DW _FLASHOFF,1
		clearIT
		dw _TurnOffSpecialMode,?
		dw 0
no_orTS		DW _PRINT13,NO_or_TEXT,SW*4/4
		dw _wait,80		;CPW!
		CLEARIT
		dw _TurnOffSpecialMode,?
		DW 0
go_for_some_text db 21 dup (' '),'GO FOR SOME OFFROAD',21 dup (' '),255
OR_total_Text	db '   OFFROAD  TOTAL  ',0
		ASSUME	DS:DATA
no_or_text	db '      NO BONUS',0
or_total	db ?,?,?,?,?,?,?,?,?,?,?,?

;**********************************************************
BACK_2_TURBOTS LABEL WORD
		CLEARIT
		DW _COUNTDOWNCONTINUE,?,?,TM_TOTAL
		DW _JMP,AFTER_TMCDTS
		DW 0

TurboTS		LABEL WORD
		clearIT
		dw _rullgardin_upp,go_for_NISSE_text,1
		dw _wait,40
		ClearIT
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		dw _countdown,2,5,tm_total ;(the final?)
AFTER_TMCDTS LABEL WORD
		clearIT
TurboMode_endingTS Label Word
		DW _JBCDZ,TM_TOTAL,no_tmTS
		dw _rullgardin_upp,tm_total_text,1

		dw _wait,60		;CPW!
		
		clearIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER,tm_total,SW*4/4+16*2/4 ;CP! RUTCENT
		dw _wait,80		;CPW!
		DW _FLASHOFF,1
		clearIT
		dw _TurnOffSpecialMode,?
		dw 0
no_tmTS		DW _PRINT13,NO_tm_TEXT,SW*4/4
		dw _wait,80		;CPW!
		CLEARIT
		dw _TurnOffSpecialMode,?
		DW 0

go_for_nisse_text db '    TURBO  MODE     ',0
tm_total_Text	db '  TURBO MODE TOTAL  ',0
no_tm_text	db '      NO BONUS',0
tm_total	db ?,?,?,?,?,?,?,?,?,?,?,?

;***********************  NYA BALL LOST *******************

ASSUME	DS:DATA
show_cyclones_text	db '     MILES X ',0
show_or_text	db '   OFFROAD TOTAL',0
show_mega_text	db '  TURBOMODE TOTAL',0



ball_lostTS	LABEL WORD
		CLEARIT

		DW _PRINT13,GETTING_SICK_TEXT,SW*2/4*2
		DW _JINGLE,S_LOSTBALL
		DW _LASTJINGLE,55
		DW _SETDECCOR,70
		DW _WAITJINGLE2,?
		DW _JINGLE,S_Empty
		CLEARIT

		DW _JBCDZ,BONUSSIFFRORNA,no_bonusTS
		DW _PRINT5,show_bonus_TEXT,SW*1*2/4+16*7/4
		DW _PRINT8_NUMBER_CENT,BONUSSIFFRORNA,7*2*SW/4+TOTCENT
		DW _WAIT,60	;CPW!
		dw _Sound_Effect,s_MultiLjud,0

		DW _JBONUSX1,NoBonusXTS
		CLEARIT	;CP! CLEARIT éR ONôDIGT BRUTAL!
		DW _BONUS_X_CALCS,?
		DW _PRINT5,BONUS_X_TEXT,SW*1*2/4+16*7/4-4*2
		DW _PRINT8_NUMBER_CENT,BONUSSIFFRORNA,7*2*SW/4+TOTCENT
		DW _WAIT,60	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
NoBonusXTS	LABEL WORD

no_bonusTS	LABEL WORD
		DW _JBCDZ,CYCLONECOUNTERBCD,no_cyclonesTS
		CLEARIT
		DW _CALC_CYCLO	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5_NUMBER,CYCLONECOUNTERBCD,SW*1*2/4-16*9/4
		DW _PRINT5_number,HUNDRATUSEN,SW*1*2/4+13*8/4
		DW _PRINT5,show_CYCLONES_TEXT,SW*1*2/4-16*1/4
		DW _PRINT8_NUMBER_CENT,CYCLONESCOREBCD,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
		CLEARIT
no_cyclonesTS	LABEL WORD
		DW _JBCDZ,OR_TOTAL,no_happy_stewartTS
		CLEARIT
		DW _CALC_HAPPY	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5,show_or_TEXT,SW*1*2/4+16/4/2
		DW _PRINT8_NUMBER_CENT,or_TOTAL,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
		CLEARIT
		
no_happy_stewartTS LABEL WORD
		DW _JBCDZ,tm_TOTAL,no_MEGA_LAUGHTS
		CLEARIT
		DW _CALC_MEGA	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5,show_MEGA_TEXT,SW*1*2/4+16/4/2
		DW _PRINT8_NUMBER_CENT,tm_TOTAL,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
		CLEARIT
		
no_MEGA_LAUGHTS LABEL WORD
		DW _JBCDZ,BONUSSIFFRORNA,no_bonus2TS
		DW _PRINT5,show_totalbonus_TEXT,SW*1*2/4+16*4/4

		DW _PRINT8_NUMBER_CENT,BONUSSIFFRORNA,7*2*SW/4+TOTCENT

		DW _WAIT,60	;CPW!
		CLEARIT
		DW _PRINT8_NUMBER,BONUSSIFFRORNA,7*2*SW/4-16*4/4
		DW _FLORPA
		DW _WAIT,25	;CPW!
		dw _beaten_matrix
no_bonus2TS	LABEL WORD
		DW _KOLLA_XXBALL
		dw _waitifmulti,2*60	;cpgnu? (visa poeng lite lengre)
		DW _MATRIXLGT,0
		clearit

		DW _CHANGE_PLAYER
		CLEARIT
		dw _wait,32000
		DW 0
SORRYNOBONUSTEXT DB '  SORRY ',94,' NO BONUS  ',0

shoot_again_onTS LABEL BYTE	;Turn on shoot again . . . 
		CLEARIT
		DW _FLASHON,SHOOT_AGAIN_SPEED
		DW _SHOOT_AGAIN_ONN,1
		DW _PRINT13,SHOOT_AGAIN_TEXT,SW*4/4 ;+16*3/4		;CP!
		DW _NEW_BALL2
		DW _PARTYON,1	;CP?
		DW 0


out_of_ballsTS	LABEL WORD		;ér Stewarts fortfarande borta kanske?
		CLEARIT
		dw _matrixlgt,1
		dw _knacket,?
		DW _SETDECCOR,75
		DW _WAITJINGLE2,?

check_xxballTS LABEL WORD
		DW _check_xxballs	;utfîr ev xxballs, hoppar sedan till after_xxballs!

after_xxballTS	LABEL WORD

		clearit
		dw _check_high,?
		DW _MATRIXLGT,0
		DW _2_DEMO_MODE
		dw _wait,20000

AfterDemoModeTS Label Word
		DW _MATRIXLGT,0
		dw _wait,20
		dw _setloop,2,?
		DW _INIT_SCORE,?
		DW _JMP,UrbanOverTS

Once_MoreTS	LABEL WORD
		DW _INIT_SCORE,?

GameOverTS	LABEL WORD
		SHOWTIME=80
		DW _WAIT,SHOWTIME

UrbanOverTS	LABEL WORD
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,GAME_OVER_TEXT,SW*2*2/4
		DW _WAIT,30
		DW _FLASHOFF,?
		CLEARIT
		DW _SHOW_SCORE,OFFSET GAMEOVERTS
		dw _loop_,2,offset once_morets
		DW _WAIT,SHOWTIME
		CLEARIT
		DW _WAIT,20
		DW _JMP,ShowHighsTS
		DW 0
GAME_OVER_TEXT	DB '     GAME  OVER',0
;TUBORG!

;********************** SLUT Pè BALL LOST *******************
ASSUME	DS:DATA

showithi	macro
		DW _PRINT13,ALLTIME_TEXT,SW*2/4*2+16/4/2
		dw _wait,60

		DW _CLEAR2		
		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_1,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*0),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*0+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		DW _CLEAR3

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_2,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*1),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*1+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		DW _CLEAR2

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_3,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*2),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*2+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		DW _CLEAR3

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_4,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*3),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*3+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		DW _CLEAR2
		DW _FLASHOFF,1
endm


ShowInfoTS	LABEL WORD
		CLEARIT
		clearit
		DW _rullgardin_ned,PLAY_TEXT,1
		dw _wait,40*3
		DW _MATRIXLGT,0
		CLEARIT
		DW _PRINT13,JACK_TEXT,SW*4/4
		dw _print13_number,jackvalue,SW*4/4+8*16/4
		DW _FLASHON,1
		dw _wait,40*3
		DW _FLASHOFF,1
		CLEARIT
		dw _rullgardin_upp,BONUS_TEXT,1
		dw _wait,40*3
		CLEARIT
		showithi
		CLEARIT

		dw _print5,playerstext,sw*2*2/4+16*1/4
		dw _print5,ballstext,sw*2*10/4+16*1/4

		DW 0
				
ShowHighsTS	LABEL WORD
;TEXTER	
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,PF_TEXT,SW*2/4*2-2
		dw _wait,120
		DW _CLEAR2
		DW _FLASHOFF,1
		dw _rullgardin_upp,TRS_TEXT,1
		dw _wait,90
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,PL_TEXT,SW*2/4*2
		dw _wait,90
		DW _CLEAR3
		DW _FLASHOFF,1
;SCROLLA
		DW _SCROLL,SCROLL_TEXT1
;VISA HIGHSCORE
		showithi
;DI UPP è NED!
		CLEARIT
;		dw _rullgardin_NED,DIGITAL_TEXT,16
;		dw _rullgardin_upp,DIGITAL_TEXT,-13
;		dw _wait,40
;		CLEARIT
		dw _rullgardin_NED,fld_TEXT,16
		dw _rullgardin_upp,fld_TEXT,-13
		dw _wait,40
;SCROLLA SISTA
		DW _SCROLL,SCROLL_TEXT2
		CLEARIT
		DW _JMP,ShowHighsTS
		dw 0
			
ShowPlayersTS	label word
		clearit
		dw _print5,playerstext,sw*2*2/4+16*1/4
		dw _print5,ballstext,sw*2*10/4+16*1/4
		dw 0

first_no_of_playersTS LABEL WORD
		clearit
		dw _print5,playerstext,sw*2*2/4+16*1/4
		DW _PRINT13,NOLLA,SW*2*2/4+16*19/4		
no_of_playersTS	label word
		dw _print5,no_of_players_text,sw*2*10/4+16*1/4
		DW _WAIT_GAME_ON,?
		dw 0
mileswait=40
MilesTS		label word
		clearit
;		DW _SCROLL,miles_text
		dw _rullgardin_upp,miles_text,1
		dw _wait,mileswait-16
		DW _CLEAR2
;		clearit
		dw 0
PedalTS	label word
		clearit
		DW _SCROLL,Pedal_text
		dw 0
Part1TS		label word
		clearit
		DW _SCROLL,PART1_text
		dw 0
Part2TS		label word
		clearit
		DW _SCROLL,PART2_text
		dw 0
Part3TS		label word
		clearit
		DW _SCROLL,PART3_text
		dw 0
Part4TS		label word
		clearit
		DW _SCROLL,PART4_text
		dw 0
Part5TS		label word
		clearit
		DW _SCROLL,PART5_text
		dw 0
		
Jump_At_TS	label word
		clearit
;		DW _SCROLL,miles_text
		dw _rullgardin_upp,miles_text,1
		dw _wait,mileswait
		clearit
		dw _flashon,10
		dw _print11,jump_at_text,sw*2*3/4+4
		DW _WAIT,160
		dw _flashoff,1
		clearit
		dw 0

offroad_At_10_TS label word
		clearit
;		DW _SCROLL,miles_text
		dw _rullgardin_upp,miles_text,1
		dw _wait,mileswait
		clearit
		dw _flashon,10
		dw _print11,or_at_10_text,sw*2*3/4+4
		DW _WAIT,160
		dw _flashoff,1
		clearit
		dw 0

Xball_At_20_TS label word
		clearit
		dw _rullgardin_upp,miles_text,1
		dw _wait,mileswait
		clearit
;		DW _SCROLL,miles_text
		dw _flashon,10
		dw _print11,xb_at_20_text,sw*2*3/4+4
		DW _WAIT,160
		dw _flashoff,1
		clearit
		dw 0

OffRoad_At_TS	label word
		clearit
;		DW _SCROLL,miles_text
		dw _rullgardin_upp,miles_text,1
		dw _wait,mileswait
		clearit
		dw _flashon,10
		dw _print11,OffRoad_at_text,sw*2*3/4+4
		DW _WAIT,160
		dw _flashoff,1
		clearit
		dw 0
		
LitJumpTS	label word
		clearit
		dw _print11,lit_jump_text,sw*2*3/4+4
		DW _WAIT,160
		DW _CLEAR2
		dw 0
LitXBallTS	label word
		clearit
		dw _print11,lit_XBALL_text,sw*2*3/4
		DW _WAIT,160
		clearit
		dw 0
BonusHeldTS	label word
		clearit
		DW _PRINT13,BonusHeld_Text,SW*2/4*2
		DW _WAIT,90
		DW _CLEAR2
		dw 0
				
jump_at_text	db 'XXX LITES THE JUMP',0
offroad_at_text	db 'XXX LITES OFF ROAD',0
xb_at_20_text db '7'+2,'7 LITES EXTRA BALL',0
or_at_10_text db ' ','7'+1,'7 LITES OFF ROAD',0
BonusHeld_text	db ' B O N U S  H E L D ',0
lit_jump_text	db '  GO FOR THE JUMP   ',0
LIT_XBALL_TEXT	DB ' GET THE EXTRA BALL ',0
;miles_text	db 21 dup (' '),'xXXX MILES',21 dup (' '),255
miles_text	db '     XXX MILES      ',0
pedal_text	db 21 dup (' '),'PRESS THE PEDAL TO THE METAL',21 dup (' '),255
PART1_text	db 21 dup (' '),'YOU HAVE THE SPOILER KIT',21 dup (' '),255
PART2_text	db 21 dup (' '),'YOU HAVE THE TURBO CHARGER',21 dup (' '),255
PART3_text	db 21 dup (' '),'YOU HAVE THE HI',94,'SPEED WING',21 dup (' '),255
PART4_text	db 21 dup (' '),'YOU HAVE THE SPORTS BUMPERS',21 dup (' '),255
PART5_text	db 21 dup (' '),'YOU HAVE THE POWER STEERING',21 dup (' '),255
jmp_t=3

JumpTS		label word
		clearit
		DW _PRINT13,JUMP1,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP2,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP3,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP4,SW*2/4*2
		DW _WAIT,JMP_T*2
		DW _PRINT13,JUMP5,SW*2/4*2
		DW _WAIT,JMP_T*2
		DW _PRINT13,JUMP6,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP7,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP8,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP9,SW*2/4*2
		DW _WAIT,JMP_T*2
		DW _PRINT13,JUMP10,SW*2/4*2
		DW _WAIT,JMP_T*2
		DW _PRINT13,JUMP11,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP12,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP13,SW*2/4*2
		DW _WAIT,JMP_T
		DW _PRINT13,JUMP14,SW*2/4*2
		DW _WAIT,JMP_T
		DW _FLASHON,15
		dw _wait,15*3-1
		dw _flashoff,?
		
		DW _clear3
		DW 0

JUMP1		DB ' J                 ',0
JUMP2		DB '  U                ',0
JUMP3		DB '   M               ',0
JUMP4		DB '    P              ',0
JUMP5		DB '      ^            ',0
JUMP6		DB '        J          ',0
JUMP7		DB '         U         ',0
JUMP8		DB '          M        ',0
JUMP9		DB '           P       ',0
JUMP10		DB '             ^     ',0
JUMP11		DB '               J   ',0
JUMP12		DB '                U  ',0
JUMP13		DB '                 M ',0
JUMP14		DB '                  P',0

tiltTS		LABEL WORD
		CLEARIT
		dw _lastjingle,55
		DW _PRINT13,TILT_TEXT,sw*2/4*2+16*0/4
		DW _WAIT,32767
		DW 0
TILT_TEXT	DB ' TILT   TILT   TILT',0
last_text	db '                 ',0
flashlast	db '                 ',0
slutsiffra	db '0',0
startext	db '*',0
last_pos	dw 0

if demover
MINUTE5TS	LABEL WORD
		CLEARIT
		dw _scroll,MINUTE5TEXT
		DW _FLASHON,1
		dw _print13_number,offset SIFFRORNA,SW*4/4+16*2/4
		DW _WAIT,100
		DW _FLASHOFF,1
		dw _scroll,MINUTE5TEXTB
		DW _FADE,256
		DW _WAIT,100
		DW QUIT,?
		dw 0
MINUTE5TEXT	DB 21 DUP (1)
		DB "WELL DONE PLAYER 1 - YOU HAVE ACHEIVED THE MEGA SCORE OF"
		DB 21 DUP (1),255
MINUTE5TEXTB	DB 21 DUP (1)
		DB "LOOK OUT FOR PINBALL FANTASIES PC - FULL GAME AVAILABLE SOON"
		DB 21 DUP (1),255
endif
;***********************************************************		
GETTING_SICK_TEXT DB 'SLIDING OFF THE ROAD',0

PARTY_ON_TEXT DB ' PARTY ON  PLAYER  ',0
ZEROQ		DB '0'+7,0
SHOOT_AGAIN_TEXT DB 'SHOOT AGAIN PLAYER  ',0

NO_OF_PLAYERS_TEXT DB 'PLAYERS X',0
NOLLA		DB '7',0
show_bonus_TEXT DB 'BONUS',0
show_totalbonus_TEXT DB 'TOTAL*BONUS',0
BONUS_X_TEXT 	DB 'BONUS*X*?',0

		
fld_TEXT	DB '  FRONTLINE DESIGN',0

PF_TEXT		DB '  PINBALL FANTASIES',0
TRS_TEXT	DB ' THE REAL SIMULATOR',0
PL_TEXT		DB '    SPEED DEVILS',0
SCROLL_TEXT1	DB 21 DUP (' '),'ADD PLAYERS WITH F1 TO F8 OR ENTER',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' '),255		
ALLTIME_TEXT	DB 'ALL TIME HIGHSCORES',0
SCROLL_TEXT2	DB 21 DUP (' '),'FLIP WITH LEFT AND RIGHT ALT SHIFT OR CTRL KEYS',21 DUP (' ')
		DB 'PUSH TABLE WITH SPACE',21 DUP (' ')
		DB 'CONTROL SPRING WITH DOWN ARROW KEY OR MOUSE',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' ')
		DB 'P PAUSES GAME AND M TOGGLES INGAME MUSIC ON AND OFF',21 DUP (' ')
		DB 'ESC EXITS AND SAVES NEW HIGHSCORES',21 DUP (' '),255
DIGITAL_TEXT	DB '  DIGITAL ILLUSIONS',0

JACK_TEXT	DB 'JACKPOT IS',0
BONUS_TEXT	DB ' YOU HAVE  XX BONUS',0	;10
PLAY_TEXT	DB ' PLAYER 8    BALL 8 ',0	;8,18

INFO_TEXT	DB 21 DUP (' ')
		db ''
		DB 21 DUP (1),255

playerstext	db 'PLAYER 8',0		;8=1 (LôS EKVATIONEN!)
BALLSTEXT	DB 'BALL 8',0		;8=1

hajjskar	db 'HIGHSCORE PL X ',92,'   ',93,0
stjaernor	db '********************',0

;******************************************************************************

DATA	ENDS
;***************************  Animations **************************************
DATA2 SEGMENT PARA PUBLIC 'DATA'
;*********************ANIMATIONS MALL*************************
comment\
	dw 1*4		;loop pos
	dw 15		;number of loops
	dw 5*4-4	;length of anim (5 frames * 4 bytes!)
_happy	dw happy_1,1;<---start!
	dw happy_2,2;<-, loop!
	dw happy_3,2;  I
	dw happy_4,2;  I 
	dw happy_5,2;__I
\
multispeed=3
	dw 1
	dw 4*8
_multi	dw a_02_00,multispeed
	dw a_02_01,multispeed
	dw a_02_02,multispeed
	dw a_02_03,multispeed
	dw a_02_04,multispeed
	dw a_02_05,multispeed
	dw a_02_06,multispeed
	dw a_02_07,50

multispeed=3
	dw 1
	dw 4*7
_m2	dw a_03_00,multispeed
	dw a_03_01,multispeed
	dw a_03_02,multispeed
	dw a_03_03,multispeed
	dw a_03_04,multispeed
	dw a_03_05,multispeed
	dw a_03_06,50
multispeed=3
	dw 1
	dw 4*7
_m3	dw a_04_00,multispeed
	dw a_04_01,multispeed
	dw a_04_02,multispeed
	dw a_04_03,multispeed
	dw a_04_04,multispeed
	dw a_04_05,multispeed
	dw a_04_06,50
multispeed=3
	dw 1
	dw 4*7
_m4	dw a_05_00,multispeed
	dw a_05_01,multispeed
	dw a_05_02,multispeed
	dw a_05_03,multispeed
	dw a_05_04,multispeed
	dw a_05_05,multispeed
	dw a_05_06,50
multispeed=3
	dw 1
	dw 4*7
_m5	dw a_06_00,multispeed
	dw a_06_01,multispeed
	dw a_06_02,multispeed
	dw a_06_03,multispeed
	dw a_06_04,multispeed
	dw a_06_05,multispeed
	dw a_06_06,50
multispeed=3
	dw 1
	dw 4*7
_m6	dw a_07_00,multispeed
	dw a_07_01,multispeed
	dw a_07_02,multispeed
	dw a_07_03,multispeed
	dw a_07_04,multispeed
	dw a_07_05,multispeed
	dw a_07_06,50
multispeed=3
	dw 1
	dw 4*7
_m7	dw a_08_00,multispeed
	dw a_08_01,multispeed
	dw a_08_02,multispeed
	dw a_08_03,multispeed
	dw a_08_04,multispeed
	dw a_08_05,multispeed
	dw a_08_06,50
multispeed=3
	dw 1
	dw 4*7
_m8	dw a_09_00,multispeed
	dw a_09_01,multispeed
	dw a_09_02,multispeed
	dw a_09_03,multispeed
	dw a_09_04,multispeed
	dw a_09_05,multispeed
	dw a_09_06,50
multispeed=3
	dw 1
	dw 4*7
_m9	dw a_10_00,multispeed
	dw a_10_01,multispeed
	dw a_10_02,multispeed
	dw a_10_03,multispeed
	dw a_10_04,multispeed
	dw a_10_05,multispeed
	dw a_10_06,50
	
millionspeed=2
	dw 1
	dw 4*16
_million dw a_01_00,millionspeed
	dw a_01_01,millionspeed
	dw a_01_02,millionspeed
	dw a_01_03,millionspeed
	dw a_01_04,millionspeed
	dw a_01_05,millionspeed
	dw a_01_06,millionspeed
	dw a_01_07,millionspeed
	dw a_01_08,millionspeed
	dw a_01_09,millionspeed
	dw a_01_10,millionspeed
	dw a_01_11,millionspeed
	dw a_01_12,millionspeed
	dw a_01_13,millionspeed
	dw a_01_14,millionspeed
	dw a_01_15,50

overtakespeed=3

	dw 23*4		;loop pos
	dw 4		;number of loops
	dw 33*4-4		;length of anim
_overtake dw a_15_00,overtakespeed
	dw a_15_01,overtakespeed
	dw a_15_02,overtakespeed
	dw a_15_03,overtakespeed
	dw a_15_04,overtakespeed
	dw a_15_05,overtakespeed
	dw a_15_06,overtakespeed
	dw a_15_07,overtakespeed
	dw a_15_08,overtakespeed
	dw a_15_09,overtakespeed
	dw a_15_10,overtakespeed
	dw a_15_11,overtakespeed
	dw a_15_12,overtakespeed
	dw a_15_13,overtakespeed
	dw a_15_14,overtakespeed
	dw a_15_15,overtakespeed
	dw a_15_16,overtakespeed
	dw a_15_17,overtakespeed
	dw a_15_18,overtakespeed
	dw a_15_19,overtakespeed
	dw a_15_20,overtakespeed
	dw a_15_21,overtakespeed
	dw a_15_22,overtakespeed
	dw a_15_23,overtakespeed
	dw a_15_24,overtakespeed
	dw a_15_25,overtakespeed
	dw a_15_26,overtakespeed
	dw a_15_27,overtakespeed
	dw a_15_28,overtakespeed
	dw a_15_29,overtakespeed
	dw a_15_30,overtakespeed
	dw a_15_31,overtakespeed
	dw a_15_32,overtakespeed


xballspeed=3

	dw 1		;loop pos (1=none)
;	dw 4		;number of loops  (Only if loop enabled)
	dw 27*4		;length of anim (-1*4 if loop enabled)
_xballa dw a_12_00,xballspeed
	dw a_12_01,xballspeed
	dw a_12_02,xballspeed
	dw a_12_03,xballspeed
	dw a_12_04,xballspeed
	dw a_12_05,xballspeed
	dw a_12_06,xballspeed
	dw a_12_07,xballspeed
	dw a_12_08,xballspeed
	dw a_12_09,xballspeed
	dw a_12_10,xballspeed
	dw a_12_11,xballspeed
	dw a_12_12,xballspeed
	dw a_12_13,xballspeed
	dw a_12_14,xballspeed
	dw a_12_15,xballspeed
	dw a_12_16,xballspeed
	dw a_12_17,xballspeed
	dw a_12_18,xballspeed
	dw a_12_19,xballspeed
	dw a_12_20,xballspeed
	dw a_12_21,xballspeed
	dw a_12_22,xballspeed
	dw a_12_23,xballspeed
	dw a_12_24,xballspeed
	dw a_12_25,xballspeed
	dw a_12_26,50


jackpotspeed=3

	dw 1		;loop pos (1=none)
;	dw 4		;number of loops  (Only if loop enabled)
	dw 26*4		;length of anim (-1*4 if loop enabled)
_jackpot dw a_11_00,jackpotspeed
	dw a_11_01,jackpotspeed
	dw a_11_02,jackpotspeed
	dw a_11_03,jackpotspeed
	dw a_11_04,jackpotspeed
	dw a_11_05,jackpotspeed
	dw a_11_06,jackpotspeed
	dw a_11_07,jackpotspeed
	dw a_11_08,jackpotspeed
	dw a_11_09,jackpotspeed
	dw a_11_10,jackpotspeed
	dw a_11_11,jackpotspeed
	dw a_11_12,jackpotspeed
	dw a_11_13,jackpotspeed
	dw a_11_14,jackpotspeed
	dw a_11_15,jackpotspeed
	dw a_11_16,jackpotspeed
	dw a_11_17,jackpotspeed
	dw a_11_18,jackpotspeed
	dw a_11_19,jackpotspeed
	dw a_11_20,jackpotspeed
	dw a_11_21,jackpotspeed
	dw a_11_22,jackpotspeed
	dw a_11_23,jackpotspeed
	dw a_11_24,jackpotspeed
	dw a_11_25,50

gearspeeds=3

	dw 0*4		;loop pos (1=none)
	dw 4		;number of loops  (Only if loop enabled)
	dw 6*4-4	;length of anim (-1*4 if loop enabled)
_gear	dw a_14_00,gearspeeds
	dw a_14_01,gearspeeds
	dw a_14_02,gearspeeds
	dw a_14_03,gearspeeds
	dw a_14_04,gearspeeds
	dw a_14_05,gearspeeds

;****************************************************************
extrn	a_01_00,a_01_01,a_01_02	,a_01_03 ,a_01_04 ,a_01_05 ,a_01_06 ,a_01_07 ,a_01_08 ,a_01_09 ,a_01_10 ,a_01_11 ,a_01_12 ,a_01_13 ,a_01_14 ,a_01_15
extrn	a_02_00,a_02_01,a_02_02	,a_02_03 ,a_02_04 ,a_02_05 ,a_02_06 ,a_02_07 
extrn	a_03_00,a_03_01,a_03_02	,a_03_03 ,a_03_04 ,a_03_05 ,a_03_06
extrn	a_04_00,a_04_01,a_04_02	,a_04_03 ,a_04_04 ,a_04_05 ,a_04_06
extrn	a_05_00,a_05_01,a_05_02	,a_05_03 ,a_05_04 ,a_05_05 ,a_05_06
extrn	a_06_00,a_06_01,a_06_02	,a_06_03 ,a_06_04 ,a_06_05 ,a_06_06
extrn	a_07_00,a_07_01,a_07_02	,a_07_03 ,a_07_04 ,a_07_05 ,a_07_06
extrn	a_08_00,a_08_01,a_08_02	,a_08_03 ,a_08_04 ,a_08_05 ,a_08_06
extrn	a_09_00,a_09_01,a_09_02	,a_09_03 ,a_09_04 ,a_09_05 ,a_09_06
extrn	a_10_00,a_10_01,a_10_02	,a_10_03 ,a_10_04 ,a_10_05 ,a_10_06
extrn	a_11_00,a_11_01,a_11_02 ,a_11_03 ,a_11_04 ,a_11_05 ,a_11_06 ,a_11_07 ,a_11_08 ,a_11_09 ,a_11_10 ,a_11_11 ,a_11_12 ,a_11_13 ,a_11_14 ,a_11_15 ,a_11_16 ,a_11_17 ,a_11_18 ,a_11_19 ,a_11_20 ,a_11_21 ,a_11_22 ,a_11_23 ,a_11_24 ,a_11_25
extrn	a_12_00,a_12_01,a_12_02 ,a_12_03 ,a_12_04 ,a_12_05 ,a_12_06 ,a_12_07 ,a_12_08 ,a_12_09 ,a_12_10 ,a_12_11 ,a_12_12 ,a_12_13 ,a_12_14 ,a_12_15 ,a_12_16 ,a_12_17 ,a_12_18 ,a_12_19 ,a_12_20 ,a_12_21 ,a_12_22 ,a_12_23 ,a_12_24 ,a_12_25 ,a_12_26
extrn	a_14_00,a_14_01,a_14_02	,a_14_03 ,a_14_04 ,a_14_05
extrn	a_15_00,a_15_01,a_15_02 ,a_15_03 ,a_15_04 ,a_15_05 ,a_15_06 ,a_15_07 ,a_15_08 ,a_15_09 ,a_15_10 ,a_15_11 ,a_15_12 ,a_15_13 ,a_15_14 ,a_15_15 ,a_15_16 ,a_15_17 ,a_15_18 ,a_15_19 ,a_15_20 ,a_15_21 ,a_15_22 ,a_15_23 ,a_15_24 ,a_15_25 ,a_15_26 ,a_15_27 ,a_15_28 ,a_15_29 ,a_15_30 ,a_15_31 ,a_15_32 
comment\
extrn	a_01_00,a_01_01,a_01_02	,a_01_03 ,a_01_04 ,a_01_05 ,a_01_06 ,a_01_07 ,a_01_08 ,a_01_09 ,a_01_10 ,a_01_11 ,a_01_12 ,a_01_13 ,a_01_14 ,a_01_15 ,a_01_16 ,a_01_17 ,a_01_18 ,a_01_19 ,a_01_20 ,a_01_21 ,a_01_22  
extrn	a_03_00,a_03_01,a_03_02 ,a_03_03 ,a_03_04 ,a_03_05 ,a_03_06 ,a_03_07  
extrn	a_04_00,a_04_01,a_04_02 ,a_04_03 ,a_04_04 ,a_04_05 ,a_04_06 ,a_04_07  
extrn	a_05_00,a_05_01,a_05_02 ,a_05_03 ,a_05_04 ,a_05_05 ,a_05_06 ,a_05_07  
extrn	a_06_00,a_06_01,a_06_02 ,a_06_03 ,a_06_04 ,a_06_05 ,a_06_06 ,a_06_07  
extrn	a_08_00,a_08_01,a_08_02 ,a_08_03 ,a_08_04 ,a_08_05 ,a_08_06 ,a_08_07 ,a_08_08 ,a_08_09 ,a_08_10 ,a_08_11 ,a_08_12 ,a_08_13 ,a_08_14 ,a_08_15 ,a_08_16 ,a_08_17 ,a_08_18 ,a_08_19 ,a_08_20 ,a_08_21 ,a_08_22 ,a_08_23 ,a_08_24 ,a_08_25 ,a_08_26 ,a_08_27 ,a_08_28 ,a_08_29 ,a_08_30 ,a_08_31 ,a_08_32 ,a_08_33 ,a_08_34 
extrn	a_09_00,a_09_01,a_09_02 ,a_09_03 ,a_09_04 ,a_09_05 ,a_09_06 ,a_09_07 ,a_09_08 ,a_09_09 ,a_09_10	,a_09_11 ,a_09_12 ,a_09_13 ,a_09_14 ,a_09_15 
extrn	a_12_00,a_12_01,a_12_02 ,a_12_03 ,a_12_04 ,a_12_05 ,a_12_06 ,a_12_07 ,a_12_08 ,a_12_09 ,a_12_10 ,a_12_11 ,a_12_12 ,a_12_13 ,a_12_14 ,a_12_15 ,a_12_16 ,a_12_17 ,a_12_18 ,a_12_19 ,a_12_20 ,a_12_21 ,a_12_22 ,a_12_23 ,a_12_24 ,a_12_25 ,a_12_26 
extrn	a_15_00,a_15_01,a_15_02 ,a_15_03 ,a_15_04 ,a_15_05 ,a_15_06 ,a_15_07 ,a_15_08 ,a_15_09 ,a_15_10 ,a_15_11 ,a_15_12 ,a_15_13 ,a_15_14 ,a_15_15 ,a_15_16 ,a_15_17  ,a_15_18  
\
DATA2	ENDS

;******************************************************************************


;******************************************************************************
;**                                                                          **
;**                                C O D E                                   **
;**                                                                          **
;******************************************************************************

CODE	SEGMENT PARA PUBLIC 'CODE'
	ASSUME	CS:CODE,DS:DATA


;*********************************** INITS ************************************

JUST_ONE_TIME_RESET_TABLE:
	CALL	SLACK_LIGHTS
	RETN


WHEN_NEW_GAME_RESET_TABLE:
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	CALL	INIT_jack
	CALL	RESET_VARS
	CALL	UPDATE_P_STRUC_4_ALL_PLAYERS
	MOV	XxballE,FALSE
	MOV	MUSICOK,FALSE

	;cleara slutsiffrorna (di alla!) (Fîr knacket alltsÜ!!!)
	push	es
	move	es,ds
	MOV	di,offset last_text
	mov	al,' '
	mov	cx,8*2
	rep	stosb
	MOV	di,offset flashlast
	mov	al,' '
	mov	cx,8*2
	rep	stosb
	pop	es
	RETN


WHEN_NEW_BALL_RESET_TABLE:
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	CALL	RESET_VARS
	CALL	P_STRUC_2_VARS
	RETN

;************************ variables reset (allways!!) *********************
RESET_VARS:
	NIL	AX
	MOVE	ES,DS
	MOV	BONUS_TEXT[11],'8'
	MOV	play_TEXT[18],'8'
	MOV	play_TEXT[8],'8'
	MOV	DI,OFFSET SIFFRORNA
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET or_total
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET tm_total
	MOV	CX,6
	REP	STOSW

	MOV	POS_SYNCER,0		;SYNCER VARS
	mov	carparten,0
	mov	b_flashin,false
	mov	u_flashin,false
	mov	r_flashin,false
	mov	n_flashin,false
	mov	i_flashin,false
	mov	nn_flashin,false
	mov	flash7down,0
	mov	flash6down,0
	mov	flash5down,0
	mov	gear_down,0
	mov	flash_pit_down,0
	mov	mb_pa_lager,0
	mov	mb_gjorda,0
	mov	loop_l,0
	mov	loop_h,0
	mov	loop_l_,false
	mov	loop_h_,false
	mov	jump_,false
	MOV	BALLHIGH,FALSE
	MOV	HOLDBONUSFLAG,FALSE
	mov	holdbonuscount,0
	MOV	BONUS_X,1

	mov	ax,0
	MOV	DI,OFFSET cyclonecounterbcd
	MOV	CX,6
	REP	STOSW
	mov	cyclonecounter,0

	mov	nextjump,30
	mov	nextoffroad,40
	mov	speeden,0
	mov	gearet,0
	mov	pos_flash,0
	mov	pos_light,0

	mov	specialmode,false
	mov	turbomode,false
	mov	offroadmode,false
;HéR VAR DEN! ;	MOV	PARTYFLASH,false

	retn
;******************************************************************************



DEMO_MUSIC PROC NEAR
	CMP	HIGHSCORE,TRUE
;	JE	OOPS_HIGH ;CP!
	PLAYJINGLE S_NOHIGH
	MOV	AL,S_NOHIGH[2]
	MOV	LASTPRIORITY,AL
	MOV	LASTJINGLE,9 ;9=NOHIGH
	RETN
DEMO_MUSIC ENDP

GAME_MUSIC PROC NEAR
	PLAYJINGLE S_SPRING
	MOV	AL,S_SPRING+2
	MOV	LASTPRIORITY,AL
	MOV	LASTJINGLE,0
	RETN
GAME_MUSIC ENDP

;******************************** LOOSE BALL **********************************
LOOSE_BALL PROC NEAR
	MOV	LOOSING,TRUE
	MOV	SCREENFORCE2,576-SH_LO+SPLH ;CP?
	CMP	HI_RES,TRUE
	JNE	NOTHIRES16
	MOV	SCREENFORCE2,576-SH_HI+SPLH ;CP?
NOTHIRES16:
	SETBALLPOS 280,560,0,0,FALSE
	MOV	HOLDSTILL,TRUE
	MOV	ALLOWFLIP,FALSE	;KILL FLIPPERS!

	MOV	SPECIALMODE,FALSE

	MOV	CURRENT_PRIORITY,0
	EFFECT	LOSTBALL	
	ADDTASK SOUNDRINNER
	RETN

SOUNDRINNER:
	WAITSYNCS 5
	SOUNDEFFECT SRINNER,0
	SUICIDE

INIT_JACK PROC NEAR	;FN: JACKVALUE = JACKINIT
	MOVE	ES,DS
	MOV	CX,12/2
	MOV	SI,OFFSET JACKINIT
	MOV	DI,OFFSET JACKVALUE
	REP	MOVSW
	RETN
INIT_JACK ENDP

JACKADD PROC NEAR	;FN: JACKVALUE += JACKRAISE
	MOV	SI,OFFSET JACKRAISE
	MOV	DI,OFFSET JACKVALUE
	CALL	ADDSCOREBCD
	RETN
JACKADD ENDP

_FLORPA:
	MOV	CS:LB6CNT,0			;RESET FôRDRôJNINGS-RéKNAREN
	MOV	ADDORPEK,OFFSET ADDOR		;STARTA MED SISTA NUFFRAN
	MOV	BONUSPEK,OFFSET BONUSSIFFRORNA+11

	MOV	SI,OFFSET BONUSSIFFRORNA	;SPARA BONUSSIFFRORNA
	MOV	DI,OFFSET TEMPSIFFRORNA
	MOVE	ES,DS
	MOV	CX,6
	REP	MOVSW

	MOV	DOTRUT,OFFSET DO_FLORPA

	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_5
	MOV	BX,0
_NEXTp_5:
	MOV	NEXT_A,BX
	RETN
PLIPPA_SCORE:
	mov	si,offset siffrorna
	mov	bx,336*2/4+(320-12*16)/4	;hîger justerad!
	MOVE	ES,CS
	CALL	DWORD PTR ES:PEKOR
	MOV	SI,0
	RETN

LB6CNT	DW ?
DO_FLORPA:
	INC	CS:LB6CNT
	CMP	CS:LB6CNT,4 ;CPW!
	JE	LB6CNTOK
	MOV	SI,75
	RETN
LB6CNTOK:
	MOV	CS:LB6CNT,0

DO_IT_AGAIN_AND_DO_IT_NOW:
	MOV	BX,BONUSPEK
	MOV	AL,[BX]
	OR	AL,AL				;IS DIGIT ZERO?
	JZ	DIGIT_IS_ZERO
	DEC	BYTE PTR [BX]			;RéKNA NED BONUSEN
	JNZ	NO_WAITS_TODAY
	
	IFZEROBCD BONUSSIFFRORNA
	JNC	NO_WAITS_TODAY

	MOV	CS:LB6CNT,-10 ;CPW!
NO_WAITS_TODAY:

	MOV	SI,ADDORPEK			;RéKNA UPP POéNGEN
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD

	SOUNDEFFECT S_SCORELJUD,0

	JMP	STEP_DONE

DIGIT_IS_ZERO:
	;FLER SIFFROR?
	INC	ADDORPEK			;NEXT DIGIT IN POéNGEN
	CMP	ADDORPEK,OFFSET ADDOR+12
	JE	NO_MORE_NUFFROR
	DEC	BONUSPEK			;NEXT DIGIT IN BONUS
	JMP	DO_IT_AGAIN_AND_DO_IT_NOW

STEP_DONE:
	;SHOW BONUSSIFFRORNA & SIFFRORNA
	MOV	SI_siffror,OFFSET BONUSSIFFRORNA
	MOV	DI_siffror,7*2*SW/4-16*4/4	;10 RADER NED, 8 (12-4) TECKEN IN Pè RADEN!!
	MOV	TABORT_DIOVRE_FNT,0
	MOV	PRINTTASK,OFFSET PRINT8_task
	CALL	PLIPPA_SCORE
	MOV	SI,75		;AVINSTALLERA EJ!
	RETN

NO_MORE_NUFFROR:
	mov	clear_box_start,7*2*SW/4
	mov	clear_box_bredd,16*(12-1)/4-16*4/4
	mov	clear_box_hojd,10
	CALL	 clear_box2
	MOV	SI,0		;AVINSTALLERA!
	RETN

;******************************* ARNESSON


;*******************************
disa	dw ?
playerQ	db ?
hi_pos	dw ?
_check_high:
	MOV	SISA,1
	mov	al,players
	mov	cs:playerQ,0
	MOV	CS:DISA,0
	MOV	DOTRUT,offset SPINTSEL_IN_HIGH
	JMP	NORMAL_END

spintsel_in_high:

	LEA	SI,PLAYER_AREA.P_SIFFRORNA

	MOV	CX,4

	add	si,cs:disa
	add	cs:disa,size player_struc

	mov	di,offset hi_score_list

	inc	cs:playerQ
	mov	al,cs:playerQ
	cmp	al,players
	jna	check_list
	mov	first_high,false
	cmp	highscore,true
	je	no_sad_jingle

	mov	current_priority,0
	mov	jinglejumpcnt,1
	PLAYJINGLE S_GameOver
	mov	current_priority,0
	mov	no_demomusic,true
no_sad_jingle:
	mov	highscore,false
	mov	si,0
	retn				;fÑrdig!
	
check_list:
	push	cx
	mov	cx,12
	mov	bx,0
check_num:
	mov	al,[di+bx]
	cmp	[si+bx],al
	jb	not_beaten
	ja	beaten
	inc	bx
	loop	check_num
not_beaten:
	mov	bp,false
	jmp	poppera
beaten:
	pop	cx
	mov	cs:hi_pos,cx
;play the happy highscore jingle . . . 
;But only the first time!!
	cmp	first_high,true
	je	noplay_of_this	
	mov	first_high,true
	mov	current_priority,0
	mov	jinglejumpcnt,1
	mov	highscore,true
	playjingle_PENETRATE S_GameOver2	;(HiScore jingle)
noplay_of_this:
	mov	sisa,1
	mov	bp,true
	jmp	done_hi_check

poppera:
	pop	cx
	add	di,12+3+1		;12 nuffror, 3 bokstÑver
	loop	check_list

done_hi_check:
	mov	si,1
	cmp	bp,true
	jne	dont_getit
;*****************
;Print 'highscore pl x (   )' and install key-reader TS
	
	mov	al,cs:playerQ
	mov	hajjskar[13],al
	add	hajjskar[13],'7'
	
	mov	dotrut,offset get_it_from_keyboard

	mov	hojd_1,13
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	MOV	AX,offset hajjskar
	MOVE	DI,sw*2*2/4
	call	PRINT_TEXT
	
;*****************
	mov	si,1
	retn
	
dont_getit:
	retn

get_it_from_keyboard:
;************ insert in list
	push	es
	move	es,ds
	mov	cx,cs:hi_pos
	
	mov	si,offset hi_score_list+(12+3+1)*3-1
	mov	di,offset hi_score_list+(12+3+1)*4-1
	dec	cx
	jcxz	pos4

	mov	ax,12+3+1
	mul	cx
	mov	cx,ax
		
	std
	rep	movsb

pos4:	sub	di,(12+3+1)-1
	cld
	lea	si,player_area.p_siffrorna
	MOV	CX,SIZE	PLAYER_STRUC
	MOV	AL,CS:PLAYERQ
	dec	al
	NIL	AH
	MUL	CX
	ADD	SI,AX
	mov	cx,12
	rep	movsb		;mov in new hiscore
	pop	es
;di pekar dÑr namnet ska petas in!!
	mov	cs:nof_chars_to_read,3
	mov	cs:place_hi,di
	mov	scan_code,-1		;lÑs ev. tidigare tangenttryck!
	mov	dotrut,offset read_keyboardet
	mov	si,1
	retn
;*****************
place_hi	dw ?
nof_chars_to_read dw ?

read_keyboardet:
	push	es
	mov	al,scan_code
	cmp	al,-1
	je	feltecken_du	;ej tryckt!
	mov	scan_code,-1
	mov	bx,offset alfa_keys
	xlat
	cmp	al,0
	je	feltecken_du	;felaktigt tecken!
	move	es,ds
	mov	di,cs:place_hi
	stosb
	push	ax
	mov	cs:place_hi,di
	mov	ax,3
	sub	ax,cs:nof_chars_to_read
	mov	di,offset hajjskar+16
	add	di,ax
	pop	ax
	stosb		;skriv te skÑrm texten . . 
	dec	cs:nof_chars_to_read
	jnz	kvar_svar
	mov	sisa,60		;cpw!
	mov	dotrut,offset wait_a_little
	pop	es

	mov	hojd_1,13
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	MOV	AX,offset hajjskar
	MOVE	DI,sw*2*2/4
	call	PRINT_TEXT
	
	;cleara namnet!
	push	es
	move	es,ds
	mov	al,' '
	mov	cx,3
	mov	di,offset hajjskar+16
	rep stosb		;skriv te skÑrm texten . . 
	pop	es
	jmp	dont_write_play	
kvar_svar:
	pop	es
	mov	hojd_1,13
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	MOV	AX,offset hajjskar
	MOVE	DI,sw*2*2/4
	call	PRINT_TEXT

dont_write_play:
	mov	si,sisa
	retn
feltecken_du:
	pop	es
	mov	si,sisa
	retn
	
wait_a_little:
	dec	si
	cmp	si,30	;cpw!
	jne	dont_blame_me
	push	si
	mov	hojd_1,13
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	MOV	AX,offset stjaernor
	MOVE	DI,sw*2*2/4
	call	PRINT_TEXT
	pop	si
dont_blame_me:
	cmp	si,2
	jnbe	retta_oooo
	mov	dotrut,offset spintsel_in_high
	mov	si,1
retta_oooo:
	retn
_loop_:
	dec	cs:looper
	JZ	NOJUMPER_tomorrow
	add	bx,4
	mov	bx,[bx]
	MOV	NEXT_A,BX
	jmp	[bx]
	
looper	dw ?
_setloop:	
NOJUMPER_tomorrow:
;reinstall loop val
	mov	ax,[bx+2]
	mov	cs:looper,ax	

	MOV	SISA,1
	mov	dotrut,offset WAITRUT
	jmp	print_end	
	
_turnonturbo:
	endflash 9
	lightoff 9
	call	getthegoalyoufool
	mov	bx,offset turboTS
	mov	next_A,bx
	jmp	[bx]
	
_return_of_the_evil_supermode:
	CMP	INHIBIT_COUNT_DOWN,TRUE
	JNE	INGA_KONSTIGHETER
	MOV	INHIBIT_COUNT_DOWN,FALSE
	MOV	BX,OFFSET BACK_2_TURBOTS
	MOV	NEXT_A,BX
	MOV	TURBOMODE,TRUE
READY_2_CALL:
	JMP	[BX]
INGA_KONSTIGHETER:
	JMP	NORMAL_END




SHOWER	DB ?
player_adr	dw ?
_INIT_SCORE:
	mov	cs:player_adr,0
	sub	cs:player_adr,size player_struc
	MOV	PLAYERSTEXT[7],0+'7'
	MOV	PLAY_TEXT[8],0+'7'
	MOV	AL,PLAYERS
	MOV	CS:SHOWER,AL
	inc	CS:SHOWER
	
	MOV	SISA,1
	mov	dotrut,offset WAITRUT
	jmp	normal_end	
_SHOW_SCORE:
	INC	PLAYERSTEXT[7]
	INC	PLAY_TEXT[8]
	add	cs:player_adr,size player_struc
	DEC	CS:SHOWER
	JZ	NOJUMPER


	MOV	SISA,1
	mov	dotrut,offset ShowIt

	cmp	CS:SHOWER,1
	je	normal_end
	
	add	bx,2
	mov	bx,[bx]
	MOV	NEXT_A,BX
	RETN

NOJUMPER:
	MOV	SISA,1
	mov	dotrut,offset WAITRUT
	jmp	normal_end	

ShowIt:
	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOV	AX,offset PLAYERSTEXT
	MOVE	DI,sw*2*2/4
	call	PRINT_TEXT
;	mov	si,offset siffrorna

	mov	bx,cs:player_adr
	LEA	SI,PLAYER_AREA[BX].P_SIFFRORNA

	mov	bx,336*2/4+(320-12*16)/4	;hîger justerad!
	MOVE	ES,CS
	CALL	DWORD PTR ES:PEKOR
	MOV	SI,0
	RETN

_TurnOffSpecialMode:
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	mov	specialmode,false
	mov	current_priority,0
	jmp	Normal_End

_knacket:
	MOVE	CS:KNACKTIDEN,KNACKTID_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES34
	MOVE	CS:KNACKTIDEN,KNACKTID_HI
NOTHIRES34:
	mov	dotrut,offset knackrut1
	mov	sisa,1
	MOV	PLAYER,1		;FôR CHECK_XXBALL
	jmp	normal_end	


;tid mellan knack samt antal knack . . . 
	knacktid_HI=13		;CPW!
	knacktid_LO=11		;CPW!
	nof_banks=18		;CPW!
	knack_d_tid=5		;CPW!

knackrut1:
	PLAYJINGLE_PENETRATE S_endfig
	MOV	LASTJINGLE,55		;TYST EFTER FULLGJORD PENETRERING
	mov	dotrut,offset knackrut2
;gîr text me sista nuffrerna!!
	mov	cl,players
	nil	ch
	mov	di,offset last_text
	mov	ah,' '
	mov	bx,10	;nÑst sista!
	LEA	SI,PLAYER_AREA[BX].P_SIFFRORNA
	push	es
	move	es,data
	mov	bx,0
make_last:
	mov	al,ds:[si]
	add	si,size player_struc
	add	al,'7'
	stosw
	mov	word ptr offset [flashlast+bx],ax	;kopiera texten fîr senare blink

	add	bx,2
	loop	make_last

	pop	es
	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOV	AX,offset last_text
	MOVE	DI,sw*2/4
	call	PRINT_TEXT

	MOV	SI,NOF_BANKS
	MOV	SISA,NOF_BANKS

	MOVE	CS:TIMGLAS,KNACKTID_LO
	MOVE	CS:KNACKTIDEN,KNACKTID_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES33
	MOVE	CS:TIMGLAS,KNACKTID_HI
	MOVE	CS:KNACKTIDEN,KNACKTID_HI
NOTHIRES33:
	retn

TIMGLAS		DW ?
KNACKTIDEN	DW KNACKTID_LO

knackrut2:
	dec	cs:timglas
	jz	no_ret
	ret
no_ret:	
	push	si
	move	cs:timglas,cs:knacktiden
	mov	ax,last_pos
	;ax=linje adress, ett steg=32 pixel=> 1 steg= 8 adr.(mcgab)
	;(1 char=8*2 pix, 1 steg=2 char)
	shl	ax,3	
	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOVE	DI,sw*2*8/4
	add	di,ax
	MOV	AX,offset startext
	call	PRINT_TEXT
	mov	si,1
	
	;knacka(????) fram en ny slutsiffra!
	mov	ax,slump_countern
	mov	dx,0
	mov	cx,10
	div	cx
	;resten i deÑks e mellan nÜll Ü tiÜ

if stones
	inc	last_pos
	cmp	last_pos,10
	jnae	over_iii
	mov	last_pos,0
	sub	cs:knacktiden,knack_d_tid
over_iii:

else
	mov	last_pos,dx
endif
	mov	ax,last_pos
	add	ax,'7'
	mov	slutsiffra[0],al
	sub	ax,'7'
	shl	ax,3	
	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOV	AX_PRINT,offset slutsiffra
	MOVE	DI_PRINT,sw*2*8/4
	add	di_print,ax
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	pop	si
	dec	si
	cmp	si,0
	jne	retta_nuda
		
;kolla om siffrorna stÑmmer fîr nÜen . . .
	
	mov	cl,players
	nil	ch
	mov	si,offset last_text
	mov	bx,last_pos
	add	bx,'7'

	mov	di,offset flashlast
	
	move	es,data
	mov	cs:alla_glada,false
READ_NUFFROR:
	lodsw
	cmp	al,bl
	jne	gladgnu_tu
	mov	cs:alla_glada,true
	add	di,2
	loop	READ_NUFFROR
	jmp	ture_sventton_kravdes_har
gladgnu_tu:
	mov	ax,'**'
	stosw
	loop	READ_NUFFROR
ture_sventton_kravdes_har:
	cmp	cs:alla_glada,true
	je	gladgnu	
	mov	si,0
	jmp	retta_nuda	;-(  ingen glad  )-:

;Om javisst, spela glad gnu Ü flasha!
gladgnu:
	MOV	MATRIX_SPEED,3
	MOV	MATRIX_CNT,3
	MOV	MATRIX_ONOFF,TRUE
	MOV	MATRIX_IS_FLASHING,TRUE

	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOV	AX,offset flashlast
	MOVE	DI,sw*2/4
	call	PRINT_TEXT


	mov	current_priority,0
	PLAYJINGLE S_Knacket
	MOV	JINGLEJUMPCNT,1
	mov	current_priority,0
	mov	lastjingle,55
	mov	si,0
retta_nuda:
	retn

alla_glada db ?


_CHECK_XXBALLS:		;OBS! TVè INGèNGAR TILL DENNA RUTIN
			;INPUT: LAST_TEXT, LAST_POS, PLAYER, PLAYERS
			;OUTPUT: FT_PEKARE, PLAYER
TESTNEXTPL:
	PUSH	BX
	
	MOV	BL,PLAYER
	NIL	BH
	SHL	BX,1
	ADD	BX,OFFSET LAST_TEXT-2	;bx pekar pÜ spelare n's slutsiffra
	
	MOV	AL,[BX]
	MOV	WORD PTR [BX],'XX'	;DESTROY HIM MY ROBOTS!
	SUB	AL,'7'
	NIL	AH

	POP	BX

	CMP	LAST_POS,AX
	JE	THIS_ONE		;HAN SKA Fè XXBALL!!!

	INC	PLAYER			;INGEN XXBALL FôR HONOM!
	MOV	AL,PLAYER
	CMP	AL,PLAYERS
	JNA	TESTNEXTPL

	MOV	BX,OFFSET after_xxballTS
	MOV	NEXT_A,BX
	JMP	[BX]
	
THIS_ONE:
	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	PLAYERSTEXT[7],AL

	MOV	XXBALLE,TRUE
	MOV	BX,OFFSET shoOt_AGAIN_Onts
	MOV	NEXT_A,BX
	JMP	[BX]

;*********************************

_KOLLA_XXBALL:
	CMP	XXBALLE,FALSE
	JE	HU_	
	PUSH	BX
	CALL	VARS_2_P_STRUC			;STORE TABLE AND SCORE!
	POP	BX

	CMP	LIGHTSTATUS[55],TRUE		;LAUGH AGAIN?
	JE	LET_HIM_SHOOT_AGAIN		;MEGA-HOPP

	MOV	AL,PLAYER			;IS HE THE HIGHEST PLAYER?
	CMP	AL,PLAYERS
	JE	HIGHEST_PLAYER2

	INC	PLAYER				;CHANGE TO THE NEXT PLAYER!
	JMP	PLAYER_CHANGED2

HIGHEST_PLAYER2:
	MOV	BX,OFFSET AFTER_XXBALLTS
	MOV	NEXT_A,BX
	JMP	[BX]

PLAYER_CHANGED2:
	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	PLAYERSTEXT[7],AL

	MOV	BX,OFFSET CHECK_XXBALLTS
	MOV	NEXT_A,BX
	JMP	[BX]

;**********


_CHANGE_PLAYER:
	PUSH	BX
	CMP	HOLDBONUSFLAG,TRUE
	JNE	NOT_HB_TRUE
	MOV	SI,OFFSET TEMPSIFFRORNA		;HOLD THE BONUS!
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOVE	ES,DS
	MOV	CX,6
	REP	MOVSW
NOT_HB_TRUE:

	CALL	VARS_2_P_STRUC			;STORE TABLE AND SCORE!

	POP	BX
	CMP	LIGHTSTATUS[55],TRUE		;LAUGH AGAIN?
	JE	LET_HIM_SHOOT_AGAIN
	PUSH	BX

	MOV	AL,PLAYER			;IS HE THE HIGHEST PLAYER?
	CMP	AL,PLAYERS
	JE	HIGHEST_PLAYER

	INC	PLAYER				;CHANGE TO THE NEXT PLAYER!
	JMP	PLAYER_CHANGED

HIGHEST_PLAYER:
	INC	BALLS[11]
	MOV	AL,NO_OF_BALLS
	CMP	BALLS[11],AL
	JA	NO_MORE_BALLS
	MOV	PLAYER,1			;NEXT PLAYER IS FIRST PLAYER!
	MOV	AL,BALLS[11]
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	BALLSTEXT[5],AL
	MOV	play_TEXT[18],AL

PLAYER_CHANGED:

	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	PLAYERSTEXT[7],AL
	MOV	play_TEXT[8],AL

	ADDTASK	NEW_BALL_TASK			;TO GAME FROM GAME
	POP	BX

HU_:	ADD	BX,2		;TASKSYTEM, HOPPA TILL NéSTA/AVSLUT
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_7
	MOV	BX,0
	MOV	NEXT_A,BX
	RETN
_NEXTp_7:
	MOV	NEXT_A,BX
	JMP	[BX]

LET_HIM_SHOOT_AGAIN:		;2 INGèNGAR!
	MOV	BX,OFFSET shoot_again_onTS
	MOV	NODOTCOUNT,0
	UPDAT_SCORE
;	MOV	NEXT_A,BX	;CP?
	JMP	[BX]

_NEW_BALL2:
	PUSH	BX
	ADDTASK	NEW_BALL_TASK			;TO GAME FROM GAME
	POP	BX
	JMP	HU_


NO_MORE_BALLS:
	CALL	VARS_2_P_STRUC			;STORE LAST PLAYER'S SCORE TOO!
	POP	BX
	MOV	BX,OFFSET out_of_ballsTS
	MOV	NEXT_A,BX
	JMP	[BX]
	RETN


_2_DEMO_MODE:
	ADDTASK	TO_DEMO_FROM_GAME
	JMP	HU_	
zeroscore:
	push	es
	move	es,ds
	mov	cx,12/2
	mov	ax,0
	mov	di,offset siffrorna
	rep stosw
	pop	es
	retn
	
TO_DEMO_FROM_GAME:
	MOV	PLAYERS_CP,TRUE
	CALL	GO_DEMO_MODE			;TO DEMO FROM GAME
	MOV	SCREENFORCE,BANH-(SH_LO-SPLH)
	CMP	HI_RES,TRUE
	JNE	NOTHIRES17
	MOV	SCREENFORCE,BANH-(SH_HI-SPLH)
NOTHIRES17:
	MOV	CARMEN,-1
	call	zeroscore
	CALL	SLACK_LIGHTS
	MOV	ADDPLAYERS,TRUE
	SUICIDE


LOOSE_BALL ENDP



;******************************** NEW_BALL ************************************

NEW_BALL_TASK:
	WAITSYNCS 60
	CALL	NEW_BALL
	RETN	;PGA NEWBALL

NEW_BALL PROC NEAR	;ENDA SéTTET ATT Fè UT EN BOLL Pè BANAN!
	MOV	LOOSING,FALSE
	MOV	BALL_DOWN,FALSE
	MOV	I_UTSKJUT,TRUE

	CALL	WHEN_NEW_BALL_RESET
	CALL	WHEN_NEW_BALL_RESET_TABLE

	MOV	HOLDSTILL,TRUE
	SETBALLPOS STARTX-5-15,STARTY-5,0,0,FALSE
	MOV	SCREENFORCE2,-1 ;500

	CMP	ADDPLAYERS,TRUE
	JE	NOSP
	CMP	MUSICOK,TRUE
	JE	MUSIC_ALREADY_OK
	PLAYJINGLE S_SPRING
	MOV	MUSICOK,FALSE
MUSIC_ALREADY_OK:
NOSP:
	MOV	LASTJINGLE,0
	MOV	SCORECHANGED,FALSE

	CMP	ADDPLAYERS,TRUE
	JE	ITS_FROM_DEMO
	CALL	NEW_BALL_PART_TWO
	RETN

ITS_FROM_DEMO:
	ADDTASK	SNART_NEW_BALL
	RETN

NEW_BALL_PART_TWO:
	ADDTASK	SOUNDNEWBALL
	ADDTASK SETBALL
	ADDTASK SOUNDBRICKUPP

	MOV	ALLOWFLIP,TRUE
	MOV	TILTFLAG,FALSE
	MOV	TILTCOUNTER,0
	MOV	SCORECHANGED,FALSE
	RETN

SOUNDBRICKUPP:
	WAITSYNCS 5
	SOUNDEFFECT SBRICKUPP,0
	SUICIDE

SOUNDNEWBALL:
	WAITSYNCS 50
	SOUNDEFFECT SNEWBALL,0
	SUICIDE

SETBALL:
	WAITSYNCS 80
	SETBALLPOS STARTX-5,STARTY-5,10,0,FALSE
	MOV	HOLDSTILL,FALSE
	MOV	SCREENFORCE2,-1
	SUICIDE
;FIAT UNO
NEW_BALL ENDP

MOTA_BORT_INACTIVE_SLINGAN:
	;OBS! AVINSTALLERA DENNA GENOM "MOV I_UTSKJUT,FALSE"
	MOV	NODOTCOUNT,0
	CMP	I_UTSKJUT,FALSE
	JE	TA_BORT_MEJ
	RETN
TA_BORT_MEJ:
	SUICIDE


P_STRUC_2_VARS PROC NEAR	;INPUT: PLAYER
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA

	MOV	CX,12/2
	MOVE	ES,DS

	LEA	SI,PLAYER_AREA[BX].P_SIFFRORNA
	MOV	DI,OFFSET SIFFRORNA
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_BONUSSIFFRORNA
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_cyclonecounterBCD
	MOV	DI,OFFSET cyclonecounterBCD
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_or_total
	MOV	DI,OFFSET or_total
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_tm_total
	MOV	DI,OFFSET tm_total
	MOV	CX,12/2
	REP	MOVSW
	
	move	cyclonecounter,PLAYER_AREA[BX].P_cyclonecount

	move	nextjump,player_area[bx].p_nextjump
	move	nextoffroad,player_area[bx].p_nextoffroad
	move	speeden,player_area[bx].p_speeden
	move	gearet,player_area[bx].p_gearet

	move	pos_flash,player_area[bx].p_pos_flash
	move	pos_light,player_area[bx].p_pos_light

	moval	holdbonuscount,player_area[bx].p_hbcount

	moval	lightstatus[22],player_area[bx].p_gear
	moval	lightstatus[23],player_area[bx].p_ear
	moval	lightstatus[24],player_area[bx].p_aron
	moval	lightstatus[25],player_area[bx].p_rapa
	moval	lightstatus[50],player_area[bx].p_part1_l
	moval	lightstatus[51],player_area[bx].p_part2_l
	moval	lightstatus[52],player_area[bx].p_part3_l
	moval	lightstatus[53],player_area[bx].p_part4_l
	moval	lightstatus[54],player_area[bx].p_part5_l
	
	moval	lightstatus[10],player_area[bx].p_part1
	moval	lightstatus[11],player_area[bx].p_part2
	moval	lightstatus[12],player_area[bx].p_part3
	moval	lightstatus[13],player_area[bx].p_part4
	moval	lightstatus[14],player_area[bx].p_part5
	move	carparten,player_area[bx].p_carparten
	
	mov	al,player_area[bx].p_goallight
	mov	lightstatus[9],al

	call	update_my_lights
	RETN
	
P_STRUC_2_VARS ENDP

update_my_lights:
	mov	cx,gearet
	cmp	gearet,0
	je	kopplingenpaj
	mov	al,26
automatlada:
	push	ax cx
	lighton	al
	pop	cx ax
	inc	al
	loop	automatlada
kopplingenpaj:
;*********************
	nof_light=4
	start_light=22
	set_lights
;**********************

	nil	di
	mov	al,50
	mov	cx,5
nxt_flash:
	cmp	lightstatus[50+di],true
	jne	noflash_now
	push	ax bx di
	test	al,1
	jne	syncor_pynkor
	syncedflash al,pos_speed,pos_syncer
	jmp	ocktor_kompostor
syncor_pynkor:
	invertedsyncedflash al,pos_speed,pos_syncer
ocktor_kompostor:
	pop	di bx ax
noflash_now:
	inc	al
	inc	di
	loop nxt_flash


	nil	di
	mov	al,10
	mov	cx,5
nxt_flash2:
	cmp	lightstatus[10+di],true
	jne	noflash_now2
	push	ax bx di
	lightflash al,std_lgt_speed
	pop	di bx ax
noflash_now2:
	inc	al
	inc	di
	loop nxt_flash2
;*****************************************
	cmp	lightstatus[9],true
	jne	not_goal_left
	push	bx
	lon 9
	pop	bx
not_goal_left:
;******************************************************************************
;SÑtt di tÑnda i position . . . 
	MOVE	DS,DATA
	MOVE	ES,DATA

	mov	di,0
	mov	cx,POS_LIGHT
	cmp	cx,0
	je	noturesventon
ture:	
	mov	lightstatus[32+di],TRUE
	inc	di
	loop	ture
noturesventon:
	
	nof_light=10
	start_light=32
	set_lights
	
;è sÑtt di som blinkar . . . 
	mov	cx,pos_flash
	sub	cx,pos_light
	cmp	cx,0
	je	noneflashin
	mov	dx,pos_light	;den siste som e stadig . . 
	add	dx,32		;fîrsta i serien
litenlajla:
	pusha
	test	dl,1
	jne	inverted_fjong
	syncedflash dl,pos_speed,pos_syncer
	jmp	back_fjong	
inverted_fjong:
	invertedsyncedflash dl,pos_speed,pos_syncer
back_fjong:
	popa
	inc	dx
	loop	litenlajla	
noneflashin:
;******************************************************************************
;SÑtt di tÑnda i speedometern . . . 
	mov	di,0
	mov	cx,SPEEDEN
	cmp	cx,0
	je	noture02

	cmp	cx,12
	jb	overall
	mov	cx,12
overall:
ture02:	
	mov	lightstatus[56+di],TRUE
	inc	di
	loop	ture02
	
	nof_light=12
	start_light=56
	set_lights
noture02:
;******************************************************************************
	retn

VARS_2_P_STRUC PROC NEAR	;INPUT: PLAYER
				;2 ENTRIES TO THIS RUT
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA
VARS_2_P_STRUC_2:		;USED BY WHEN_NEW_GAME_RESET!
	MOV	CX,12/2
	MOVE	ES,DS

	LEA	DI,PLAYER_AREA[BX].P_SIFFRORNA
	MOV	SI,OFFSET SIFFRORNA
	MOV	CX,12/2
	REP	MOVSW

	LEA	DI,PLAYER_AREA[BX].P_BONUSSIFFRORNA
	MOV	SI,OFFSET BONUSSIFFRORNA
	MOV	CX,12/2
	REP	MOVSW

	LEA	dI,PLAYER_AREA[BX].P_cyclonecounterBCD
	MOV	sI,OFFSET cyclonecounterBCD
	MOV	CX,12/2
	REP	MOVSW

	move	PLAYER_AREA[BX].P_cyclonecount,cyclonecounter

	move	player_area[bx].p_nextjump,nextjump
	move	player_area[bx].p_nextoffroad,nextoffroad
	move	player_area[bx].p_speeden,speeden
	move	player_area[bx].p_gearet,gearet
	move	player_area[bx].p_pos_flash,pos_flash
	move	player_area[bx].p_pos_light,pos_light
	mov	al,lightstatus[9]
	mov	player_area[bx].p_goallight,al

	moval	player_area[bx].p_gear,lightstatus[22]
	moval	player_area[bx].p_ear,lightstatus[23]
	moval	player_area[bx].p_aron,lightstatus[24]
	moval	player_area[bx].p_rapa,lightstatus[25]

	moval	player_area[bx].p_part1,lightstatus[10]
	moval	player_area[bx].p_part2,lightstatus[11]
	moval	player_area[bx].p_part3,lightstatus[12]
	moval	player_area[bx].p_part4,lightstatus[13]
	moval	player_area[bx].p_part5,lightstatus[14]

	moval	player_area[bx].p_part1_l,lightstatus[50]
	moval	player_area[bx].p_part2_l,lightstatus[51]
	moval	player_area[bx].p_part3_l,lightstatus[52]
	moval	player_area[bx].p_part4_l,lightstatus[53]
	moval	player_area[bx].p_part5_l,lightstatus[54]

	moval	player_area[bx].p_hbcount,holdbonuscount

	move	player_area[bx].p_carparten,carparten
	RETN
VARS_2_P_STRUC ENDP



;******************************** TILT TILT TILT ******************************
HE_TILTED PROC NEAR
	MOV	ALLOWFLIP,FALSE
	MOV	LASTJINGLE,62
	PLAYJINGLE S_TILT	
	MOV	BX,OFFSET tiltTS
	CALL	DO_MATRIX
	CALL	RESETFLASHLIST
	CALL	SLACK_LIGHTS
	RETN
HE_TILTED ENDP

HE_ALMOST_TILTED PROC NEAR
	PLAYJINGLE S_DANGER
	RETN
ENDP

;********************************* CHECK SHIFTKEYS ****************************

CHECK_SHIFTKEYS PROC NEAR
	CMP	SHIFTPRESSED,TRUE
	JNE	NO_SHIFT
	MOV	SHIFTPRESSED,FALSE
;****************************************
;*          3 light rol                 *
;****************************************
	;bur
	start_light=16
	shift_light
	mov	b_flashin,false
	mov	u_flashin,false
	mov	r_flashin,false
	;nin
	start_light=19
	shift_light
	mov	n_flashin,false
	mov	i_flashin,false
	mov	nn_flashin,false
	
	cmp	flash_pit_down,0
	jne	no_allpit

	mov	flash6down,0
	mov	flash7down,0
	mov	flash5down,0
	start_light=6
	shift_light
no_allpit:
;****************************************
NO_SHIFT:
	RETN
CHECK_SHIFTKEYS ENDP



;******************************** GATES ROUTINES ******************************


;************************* SUPER MODES CHECKS *********************************



;******************************************************************************
;***************************** BRICKOR & KNAPPAR ******************************
;******************************************************************************
;B U R N I N'	;cpw!
b_light=16
u_light=17
r_light=18
n_light=19
i_light=20
nn_light=21
touch_speed=1	;hur snabb flash dÜ den blitt tÑffad
touch_time=10	;hur lÑnge flash (flash => stadig)
bur_time=40	;hur lÑnge B U R
nin_time=40	;hur lÑnge N I N
gear_time=45	;must be > than bur & nin time
gear_flash=2

nedslapp:
	mov	y_hast,0	
;	cmp	y_hast,-1		;y_hast positiv = pÜvÑg ned!!
;	jl	nope_ko
	mov	ballhigh,false		;slÑpp ned!! cp.
nope_ko:
	retn
	
bricka_b:

	cmp	b_flashin,true
	je	slut_b
	mov	b_flashin,true
	mov	lightstatus[b_light],true		;tÑnd logik!!
	call	bur_group
	jc	lit_A	;alla i B U R tÑnda => tÑnd A  (g e A r)
;	beep
	lightflash b_light,touch_speed	;flasha litet tag
	addtask	end_b			;task som stÑnger av flash
slut_b:	retn
end_b:
	WAITSYNCS 10 ;touch_time
;	beep
	ENDFLASH b_light	;lys stadigt (frÜn flash)
	cmp	b_flashin,true
	jne	b_suicide
	lon	b_light
	mov	b_flashin,false
b_suicide:
	SUICIDE
	
bricka_u:
	cmp	u_flashin,true
	je	slut_u
	mov	u_flashin,true
	mov	lightstatus[u_light],true		;tÑnd logik!!

	call	bur_group
	jc	lit_A	;alla i B U R tÑnda => tÑnd A  (g e A r)

	lightflash u_light,touch_speed	;flasha litet tag
	addtask	end_u			;task som stÑnger av flash
slut_u:	retn
end_u:
	WAITSYNCS touch_time
	ENDFLASH u_light	;lys stadigt (frÜn flash)
	cmp	u_flashin,true
	jne	u_suicide
	lon	u_light
	mov	u_flashin,false
u_suicide:
	SUICIDE

bricka_r:
	cmp	r_flashin,true
	je	slut_r
	mov	r_flashin,true
	mov	lightstatus[r_light],true		;tÑnd logik!!

	call	bur_group
	jc	lit_A	;alla i B U R tÑnda => tÑnd A  (g e A r)

	lightflash r_light,touch_speed	;flasha litet tag
	addtask	end_rr			;task som stÑnger av flash
slut_rr:	retn
end_rr:
	WAITSYNCS touch_time
	ENDFLASH r_light	;lys stadigt (frÜn flash)
	cmp	r_flashin,true
	jne	r_suicide
	lon	r_light
	mov	r_flashin,false
r_suicide:
	SUICIDE
;****************************

bricka_n:
	cmp	n_flashin,true
	je	slut_n
	mov	n_flashin,true
	mov	lightstatus[n_light],true		;tÑnd logik!!
	call	nin_group
	jc	lit_R	;alla i N I N tÑnda => tÑnd R  (g e a R)

	lightflash n_light,touch_speed	;flasha litet tag
	addtask	end_n			;task som stÑnger av flash
slut_n:	retn
end_n:
	WAITSYNCS touch_time
	ENDFLASH n_light	;lys stadigt (frÜn flash)
	cmp	n_flashin,true
	jne	n_suicide
	lon	n_light
	mov	n_flashin,false
n_suicide:
	SUICIDE

bricka_i:
	cmp	i_flashin,true
	je	slut_i
	mov	i_flashin,true
	mov	lightstatus[i_light],true		;tÑnd logik!!
	call	nin_group
	jc	lit_R	;alla i N I N tÑnda => tÑnd R  (g e a R)

	lightflash i_light,touch_speed	;flasha litet tag
	addtask	end_i			;task som stÑnger av flash
slut_i:	retn
end_i:
	WAITSYNCS touch_time
	ENDFLASH i_light	;lys stadigt (frÜn flash)
	cmp	i_flashin,true
	jne	i_suicide
	lon	i_light
	mov	i_flashin,false
i_suicide:
	SUICIDE

bricka_nn:
	cmp	nn_flashin,true
	je	slut_nn
	mov	nn_flashin,true
	mov	lightstatus[nn_light],true		;tÑnd logik!!
	call	nin_group
	jc	lit_R	;alla i N I N tÑnda => tÑnd R  (g e a R)

	lightflash nn_light,touch_speed	;flasha litet tag
	addtask	end_nn			;task som stÑnger av flash
slut_nn:	retn
end_nn:
	WAITSYNCS touch_time
	ENDFLASH nn_light	;lys stadigt (frÜn flash)
	cmp	nn_flashin,true
	jne	nn_suicide
	lon	nn_light
	mov	nn_flashin,false
nn_suicide:
	SUICIDE

;****************************
lit_A:
	mov	b_flashin,true
	mov	u_flashin,true
	mov	r_flashin,true
	lightflash b_light,touch_speed	;flasha litet tag
	lightflash u_light,touch_speed	;flasha litet tag
	lightflash r_light,touch_speed	;flasha litet tag
	mov	lightstatus[24],true	;tÑnd logik!!
	addtask	end_A			;task som stÑnger av flash
	call	check_gear		;for wear??
	jc	slut_A
	lightflash 24,touch_speed	;flasha litet tag
slut_A:	retn
end_A:
	WAITSYNCS bur_time
	ENDFLASH 24		;lys stadigt (frÜn flash)
	LON	24
	mov	lightstatus[b_light],false
	mov	lightstatus[u_light],false
	mov	lightstatus[r_light],false
	endflash b_light
	endflash u_light
	endflash r_light
	loff	 b_light
	loff	 u_light
	loff	 r_light
	mov	b_flashin,false
	mov	u_flashin,false
	mov	r_flashin,false
	SUICIDE

;****************************
lit_R:
	mov	n_flashin,true
	mov	i_flashin,true
	mov	nn_flashin,true
	lightflash n_light,touch_speed	;flasha litet tag
	lightflash i_light,touch_speed	;flasha litet tag
	lightflash nn_light,touch_speed	;flasha litet tag
	mov	lightstatus[25],true	;tÑnd logik!!
	addtask	end_R			;task som stÑnger av flash
	call	check_gear		;for wear??
	jc	slut_r
	lightflash 25,touch_speed	;flasha litet tag
slut_R:	retn
end_R:
	WAITSYNCS nin_time
	ENDFLASH 25		;lys stadigt (frÜn flash)
	LON	25
	mov	lightstatus[n_light],false
	mov	lightstatus[i_light],false
	mov	lightstatus[nn_light],false
	endflash n_light
	endflash i_light
	endflash nn_light
	loff	 n_light
	loff	 i_light
	loff	 nn_light
	mov	n_flashin,false
	mov	i_flashin,false
	mov	nn_flashin,false
	SUICIDE


bur_group:

	call	addoffroad

;hÑr addas score, jack, bonus + kollar om hela B U R e tÑnt!!
	ADDSCORE BCD7510
	ADDBONUS BCD550

	SOUNDEFFECT S_touch1,0	;cp?

	CMP	LIGHTSTATUS[16],TRUE
	JNE	NOTALLBUR
	CMP	LIGHTSTATUS[17],TRUE
	JNE	NOTALLBUR
	CMP	LIGHTSTATUS[18],TRUE
	JNE	NOTALLBUR
LETSBUR:
	CALL	JACKADD
	STC
	RETN
NOTALLBUR:
	CLC
	RETN
nin_group:

	call	addoffroad

;hÑr addas score, jack, bonus + kollar om hela B U R e tÑnt!!
	ADDSCORE BCD7520
	ADDBONUS BCD570
	SOUNDEFFECT S_touch1,0	;cp?

	CMP	LIGHTSTATUS[19],TRUE
	JNE	NOTALLBUR
	CMP	LIGHTSTATUS[20],TRUE
	JNE	NOTALLBUR
	CMP	LIGHTSTATUS[21],TRUE
	JNE	NOTALLnin
LETSnin:
	CALL	JACKADD
	STC
	RETN
NOTALLnin:
	CLC
	RETN
check_gear:
	cmp	lightstatus[22],true
	jne	no_gear
	cmp	lightstatus[23],true
	jne	no_gear
	cmp	lightstatus[24],true
	jne	no_gear
	cmp	lightstatus[25],true
	jne	no_gear
shift_up_man:
	call	increase_position
	CALL	INC_GEAR
	mov	lightstatus[22],false
	mov	lightstatus[23],false
	mov	lightstatus[24],false
	mov	lightstatus[25],false
	lightflash 22,gear_flash
	lightflash 23,gear_flash
	lightflash 24,gear_flash
	lightflash 25,gear_flash
	addtask	stop_gear
;	beep
	effect gearchange
	stc
	retn
no_gear:
	clc
	retn
stop_gear:
	waitsyncs gear_time
	endflash 22
	endflash 23
	endflash 24
	endflash 25
	loff	24
	loff	25	
	loff	22
	loff	23	
	suicide
GEAR_BASE=26
GEARKASSE_SPEED=1
gearkasse_time=30
Inc_Gear:
	mov	bx,gearet
	cmp	gearet,5
	je	no_shift_gear_kasse
	inc	gearet
	add	bx,gear_base
	LightON bl,gearkasse_speed
	retn
no_shift_gear_kasse:
	mov	gear_down,gearkasse_time
	lightflash 26,GEARKASSE_SPEED
	lightflash 27,GEARKASSE_SPEED
	lightflash 28,GEARKASSE_SPEED
	lightflash 29,GEARKASSE_SPEED
	lightflash 30,GEARKASSE_SPEED
	lightflash 31,GEARKASSE_SPEED

	RETN
gearkasse:
	mov	gearet,0
	endflash 26
	lightoff 26
	endflash 27
	lightoff 27
	endflash 28
	lightoff 28
	endflash 29
	lightoff 29
	endflash 30
	lightoff 30
	endflash 31
	lightoff 31
;tÑnd holdbonus dÜ hela gear e plockat
	cmp	lightstatus[2],true
	je	nohold			;inte tat den fîstÜss, dumhuve
	syncedflash 2,pos_speed,pos_syncer
	mov	holdbonuscount,0
	mov	lightstatus[2],true
nohold:
	retn
		
position_base=32
pos_speed=std_lgt_speed
goal_speed=std_lgt_speed
increase_position:
	mov	bx,pos_flash
	cmp	bx,10		;last pos
	je	all_pos_flashin
	mov	ax,bx
	add	ax,position_base
	push	ax
	syncedflash al,pos_speed,pos_syncer
	pop	ax
	inc	ax
	invertedsyncedflash al,pos_speed,pos_syncer
	add	pos_flash,2
	retn
all_pos_flashin:	
	effect	NumberOne	;-)  Meal???  
	
	retn
	
get_position:
	mov	bx,pos_light
	cmp	pos_flash,bx
	jbe	not_possible
	inc	pos_light
	mov	ax,bx
	add	ax,position_base
	push	ax
	endflash al
	pop	ax
	lighton	al
	effect	OverTake

	cmp	Pos_Light,10
	je	all_lit

	retn
not_possible:
	retn
all_lit:
	invertedsyncedflash 9,pos_speed,pos_syncer		;Goal Light
	lighton 9

	syncedflash 15,pos_speed,pos_syncer	;JackPot Light
	lighton 15		
	
	mov	jackdown,20*60			;Jack tiden ...

	effect GoalLit
	retn
jack_slack:
	lightoff 15
	endflash 15
	retn
;******************************************************************************
;********************************** LOWER *************************************
;******************************************************************************
GetTheGoalYouFool:

	lightoff 41
	lightoff 40
	lightoff 39
	lightoff 38
	lightoff 37
	lightoff 36
	lightoff 35
	lightoff 34
	lightoff 33
	lightoff 32
	mov	pos_light,0
	mov	pos_flash,0
	cmp	specialmode,true
	jne	OnlyTurbo
	;OffRoad mode is currently on!! Wait 'til it's off!
	addtask Goliat
	retn
OnlyTurbo:
	call	TurboModeInit
	retn	
Goliat:
	cmp	loosing,true
	je	killhimnow
	cmp	specialmode,true
	je	no_goliat

	call	TurboModeInit
killhimnow:
	suicide
no_goliat:
	retn
TurboModeInit:
	effect getgoal
	mov	specialmode,true
	mov	turbomode,true
	retn

;*************
DoTheOffRoad:
	cmp	specialmode,true
	jne	OnlyOffroad
	;Turbo mode is currently on!! Wait 'til it's off!
	addtask Goliat2
	retn
OnlyOffRoad:
	call	OffRoadModeInit
	retn	
Goliat2:
	cmp	loosing,true
	je	killhimnowandagain

	cmp	specialmode,true
	je	no_goliat2
	;Goal
	call	OffRoadModeInit
killhimnowandagain:
	suicide
no_goliat2:
	retn
OffRoadModeInit:
	mov	current_priority,0
	playjingle	sjingle22
	mov	specialmode,true
	mov	bx,offset OffRoadTS
	call	do_matrix
	mov	offroadmode,true	
	retn

;*************
GropA:			;PITSTOP
	cmp	lightstatus[3],true	;Super Jackpot
;	mov	lastjingle,2
	jne	nosuperjack
	endflash 3
	lightoff 3
	cmp	lightstatus[9],true	;Goal lit?
	jne	brakke	
	effect	superjack2		;fîrst super sen turbomode
	jmp	hmmmm_waitalittlelongerwhenmegascore
brakke:
	mov	inhibit_count_down,true
	MOV	CURRENT_PRIORITY,0
	effectbrack superjack		;brÑck turbomode

nosuperjack:

	cmp	lightstatus[9],true	;Goal lit? (but NOT super!)
	jne	NoGoal_now_sucker
	endflash 9
	lightoff 9
	call	getthegoalyoufool
NoGoal_now_sucker:
	cmp lightstatus[2],true
	jne	noholdbonusifimsorryforthisfuckinlonglabelorwhatdoyoumeanbythat
	effect holdbonus
	endflash 2
	lightoff 2
	MOV	HOLDBONUSFLAG,TRUE

noholdbonusifimsorryforthisfuckinlonglabelorwhatdoyoumeanbythat:
	CMP	SNACKDISABLED,TRUE
	JE	NOT_NOW_STUPID
	ADDTASK	SNACK_HOLE_TASK1
NOT_NOW_STUPID:
	RETN
hmmmm_waitalittlelongerwhenmegascore:
	CMP	SNACKDISABLED,TRUE
	JE	NOT_NOW_STUPID
	ADDTASK	SNACK_HOLE_TASK2
	jmp	not_now_stupid
	
;************* from snack logic *************

SNACK_HOLE_TASK1:
	MOV	HOLDSTILL,TRUE
	SETBALLPOS SNACKX,SNACKY,0,0,FALSE	;PUT BALL IN MIDDLE OF HOLE ;CP!
	WAITSYNCS 20 ;CPW!	;(EVEN IF SPECIALMODE=TRUE)
	ADDTASK SNACK_HOLE_TASK1B
	SUICIDE

SNACK_HOLE_TASK2:
	MOV	HOLDSTILL,TRUE
	SETBALLPOS SNACKX,SNACKY,0,0,FALSE	;PUT BALL IN MIDDLE OF HOLE ;CP!
	WAITSYNCS 150 ;CPW!	;(EVEN IF SPECIALMODE=TRUE)
	ADDTASK SNACK_HOLE_TASK1B
	SUICIDE

SNACK_HOLE_TASK1B:
	MOV	HOLDSTILL,TRUE
	SETBALLPOS SNACKX,SNACKY,0,0,FALSE	;PUT BALL IN MIDDLE OF HOLE ;CP!
	CMP	SPECIALMODE,TRUE
	JE	SNABBHOPP4
	WAITSYNCS 100-40	;CPW!
SNABBHOPP4:
	SOUNDEFFECT SGROP,0
	MOV	HOLDSTILL,FALSE
	SETBALLPOS SNACKX,SNACKY,SNACKXS,SNACKYS,FALSE
	ADDTASK TURN_IT_ON_AGAIN
	SUICIDE

TURN_IT_ON_AGAIN:
	WAITSYNCS 60
	MOV	SNACKDISABLED,FALSE
	SUICIDE

;********************************************

part_test:
	test_lgts 50,5
	jnc	rett_na
	lightoff 50
	lightoff 51
	lightoff 52
	lightoff 53
	lightoff 54
	
	endflash 50
	endflash 51
	endflash 52
	endflash 53
	endflash 54
	
	lightflash 50,1
	lightflash 51,1
	lightflash 52,1
	lightflash 53,1
	lightflash 54,1
	
	addtask	endflasha_carparts
	
	mov	CarParten,0	;Fîrste parten ju . . . 
rett_na:
	retn
	
endflasha_carparts:
	waitsyncs 60*2
	endflash 50
	endflash 51
	endflash 52
	endflash 53
	endflash 54
	suicide

bygel9:	;OffRoad bygeln
	cmp	TurboMode,true
	jne	NoTurboModeNownownow
	effect TurboEffect
	call	addTurboMode
NoTurboModeNownownow:

	effect	BygelSetE
	cmp	lightstatus[11],true
	jne	no_part_1
	lightoff 11
	endflash 11
	effect Part1
	mov	lightstatus[50],true
	invertedsyncedflash 50,pos_speed,pos_syncer
;	lightflash 50,std_lgt_speed	;Motorn???
	call	part_test
no_part_1:
	cmp	lightstatus[12],true
	jne	no_part_4
	lightoff 12
	endflash 12
	effect Part4
	mov	lightstatus[51],true
;	lightflash 51,std_lgt_speed	;Motorn???
	syncedflash 51,pos_speed,pos_syncer
	call	part_test
no_part_4:

	cmp	lightstatus[4],true	;Multiply Bonus??
	je	do_mb
back_test_it:
	mov	lightstatus[23],true
	CALL	JACKADD
	call	check_gear
	jc	no_b9
	lightflash 23,touch_speed
	addtask	stop_e
no_b9:	retn
stop_E:
	waitsyncs touch_time
	endflash 23
	lon	23
	suicide
do_mb:
	inc	bonus_text[11]
	inc	mb_gjorda
	inc	bonus_x
	dec	mb_pa_lager
	jnz	slack_inte
	lightoff	4
	endflash	4
slack_inte:
	nil	bx
	mov	dx,offset M2	;fîrsta MB effekten
	mb_base=42	;(fîrsta)
next_lght:
	cmp	lightstatus[mb_base+bx],false
	je	not_next_lght
	add	bx,1
	add	dx,size effect_struc
	cmp	bx,7		;nof bonus lgts-1
	jne	next_lght
not_next_lght:
	
	push	bx
	mov	si,dx
	call	doeffect
	pop	bx
	
	mov	lightstatus[mb_base+bx],true
	add	bl,mb_base
	call	dolon
	jmp	back_test_it

Bygel16:
	cmp	LastArea,offset cs:Bygel12
	je	Jump_man
	cmp	LastArea,offset cs:Bygel17
	jne	no_b16
;Get the bonus part??
	cmp	lightstatus[14],true
	jne	no_part_3
	lightoff 14
	endflash 14
	effect Part3
	mov	lightstatus[52],true
	invertedsyncedflash 52,pos_speed,pos_syncer
	call	part_test
no_part_3:
	cmp	lightstatus[10],true
	jne	no_part_5
	lightoff 10
	endflash 10
	effect Part5
	mov	lightstatus[54],true
	syncedflash 54,pos_speed,pos_syncer
	call	part_test
no_part_5:



;Get the x-ball??
	cmp	lightstatus[1],true
	jne	noxballs
	effect xball
	lightoff 1
	endflash 1
	lighton 55	;TÑndstift
noxballs:
	retn
Jump_Man:
;	inc	holdbonuscount
;	cmp	holdbonuscount,10
;	jne	nohold
;	cmp	lightstatus[2],true
;	je	nohold			;inte tat den fîstÜss, dumhuve
;	syncedflash 2,pos_speed,pos_syncer
;	mov	holdbonuscount,0
;	mov	lightstatus[2],true
;nohold:
	cmp	TurboMode,true
	jne	NoTurboModeNownow
	effect TurboEffect
	call	addTurboMode
NoTurboModeNownow:
	call	jackadd
	cmp	lightstatus[15],true	;JP lampan
	jne	No_JP_lgt
	mov	si,offset jackvalue
	mov	di,offset siffrorna
	call	addscorebcd
	call	init_jack
	cmp	turbomode,true
	jne	nobraccer
	MOV	CURRENT_PRIORITY,0
	effectbrack JackPot
	mov	inhibit_count_down,true
	jmp	knakelibrak
nobraccer:
	effect	jackpot
knakelibrak:
	lightoff 15
	endflash 15
	lighton	3			;Super JackPot
	syncedflash 3,pos_speed,pos_syncer
	addtask	turnoff_super
No_JP_lgt:
	cmp	lightstatus[5],true	;Jump lampan
	jne	No_Jump_lgt
	effect	Jump
	lightoff 5
	endflash 5
No_Jump_lgt:
	cmp	lightstatus[13],true
	jne	no_part_2
	lightoff 13
	endflash 13
	effect Part2
	mov	lightstatus[53],true
	syncedflash 53,pos_speed,pos_syncer
	call	part_test
no_part_2:
	mov	jump_,true
	call	speedometer
	mov	lightstatus[22],true
	CALL	JACKADD
	call	check_gear
	jc	no_b16
	lightflash 22,touch_speed
	addtask	stop_g
no_b16:
	retn
turnoff_super:
	waitsyncs 20*60
	endflash 3
	lightoff 3
	suicide

Bygel17:	;Fîre under Jump . . Hmmmm . . 
	retn
bygel12:	;JUMP bygeln
	retn
stop_g:
	waitsyncs touch_time
	endflash 22
	lon	22
	suicide

; P I T 
pit_time=20
pit_speed=1
;*************************************
bygel7:
	cmp	flash7down,0
	jne	no_flash7
	mov	lightstatus[8],true
	call	pit_group
	jc	no_flash7
	mov	flash7down,pit_time
	lightflash 8,pit_speed	
no_flash7:
	retn
	
Flash7end:
	endflash 8
	lon 8
	start_light=6
	nof_light=3
	set_lights
	retn
;*****************************
bygel6:
	cmp	flash6down,0
	jne	no_flash6
	lon 7 
	mov	lightstatus[7],true
	call	pit_group
	jc	no_flash6
	mov	flash6down,pit_time
	lightflash 7,pit_speed	
no_flash6:
	retn
	
Flash6end:
	endflash 7
	lon 7
	start_light=6
	nof_light=3
	set_lights
	retn
;*****************************
bygel5:
	cmp	flash5down,0
	jne	no_flash5
	lon 6
	mov	lightstatus[6],true
	call	pit_group
	jc	no_flash5
	mov	flash5down,pit_time
	lightflash 6,pit_speed	
no_flash5:
	retn
	
Flash5end:
	endflash 6
	lon 6
	start_light=6
	nof_light=3
	set_lights
	retn
;*****************************

Pit_Group:
	call	addoffroad

	SOUNDEFFECT S_touch1,0	;cp!!!
	effect BygelSetC
	test_lgts 6,3		;6=first lgt, 3=#lgts
	jc	enable_bonus
	clc
	retn
pit_time_all=pit_time*2
pit_all_speed=2
mb_speed=10
enable_bonus:
	cmp	flash_pit_down,0	;All PIT already megaflashin ???
	je	do_enable_mb_lgt
	clc
	retn

do_enable_mb_lgt:
	effect	MBLit
	mov	al,mb_gjorda
	add	al,mb_pa_lager
	cmp	al,8
	jb	no_millon_but_bonus
	effect	Million
	jmp	ret_urk
no_millon_but_bonus:
	inc	mb_pa_lager
	cmp	mb_pa_lager,1
	jne	dont_startflash
	mov	lightstatus[4],true
	lightflash	4,mb_speed
dont_startflash:
ret_urk:
	lightflash 6,pit_all_speed
	lightflash 7,pit_all_speed
	lightflash 8,pit_all_speed
	mov	flash_pit_down,pit_time_all
	stc
	retn
turn_pit_off:
	endflash 6
	endflash 7
	endflash 8
	lightoff 6	
	lightoff 7
	lightoff 8
	start_light=6
	nof_light=3
	set_lights
	retn

Bygel1:		;Sido nedfall
Bygel2:
	effect BygelSetA
	retn

Bygel3:		;Rîr nedfall
Bygel4:
	SOUNDEFFECT SBygel2,0
	effect BygelSetB
	retn
Bygel8:
	effect	BygelSetD
	retn
;*********************************** GAME ON **********************************

CLOSE1:					;GAME ON
	CMP	LASTAREA,OFFSET nedslapp
	JNE	NOT_GAME_ON
	MOV	ADDPLAYERS,FALSE
	PLAYJINGLE S_MAIN
	MOV	LASTJINGLE,1
	MOV	BX,OFFSET PARTY_OFFTS
	CALL	DO_MATRIX
	MOV	I_UTSKJUT,FALSE		;TILLèTER INACTIVE-SLINGAN (DOTMATRIX)
	MOV	PARTYFLASH,FALSE

;JOHAN SéGER ATT DETTA éR EXTRA SéKERT (DUBBEL SéKERHET)
	mov	spring_valid,false ;CP...

NOT_GAME_ON:
	RETN



;***************************** SPRING INVALID *********************************

open2:				;SPRING INVALID
	MOV	SPRING_VALID,FALSE
	RETN


;******************************* SPRING VALID *********************************

BYGEL28:				;SPRING VALID
	MOV	SPRING_VALID,TRUE
	RETN



;******************************************************************************
;*********************************** UPPER ************************************
;******************************************************************************
speedometer:
	cmp	loop_l_,true
	jne	no_speedup
	cmp	loop_h_,true
	jne	no_speedup
	cmp	Jump_,true
	jne	no_speedup
	effect	speedo
	mov	loop_l_,false
	mov	loop_h_,false
	mov	Jump_,false
speedometer_base=56
	mov	ax,speeden
	add	ax,56
	test	al,1
	jz	no_bonus_part
	push	ax
	call	CarPart
	pop	ax
no_bonus_part:
	cmp	al,67		;cp!!??
	jae	slack_speedometer
	inc	speeden
	lighton	al
	retn
slack_speedometer:		;Nja, den skulle ju fÜ lysa sÜ glatt . . 
	inc	speeden
	lon 67
no_speedup:
	retn
part_speed=std_lgt_speed
CarPart:
	cmp	CarParten,5
	je	all_parts_lit
	mov	bx,CarParten	;Inte CarPort alltsÜ  . . 
	inc	CarParten
	shl	bx,2		;Effekt+lnr
	add	bx,offset PartList
	mov	ax,[bx]
;fel stÑlle??
;	push	bx
;	effect	ax
;	pop	bx

	mov	ax,[bx+2]
	push	ax

	syncedflash al,pos_speed,pos_syncer

	pop	ax
	lighton	al
all_parts_lit:
	retn
		
betweenloops_time=blet*6*60+30
Bygel10:
;	mov	loop_l_,true	;Only when million!
	mov	loop_h,betweenloops_time
	cmp	loop_l,0
	je	not_2_loops_in_5_secs_1
	mov	loop_l,0
	call	two_in_5
not_2_loops_in_5_secs_1:
	call	loop_group
	retn
Bygel11:
;	mov	loop_h_,true	;Only when million!
	mov	loop_l,betweenloops_time
	cmp	loop_h,0
	je	not_2_loops_in_5_secs_2
	mov	loop_h,0
	call	two_in_5
not_2_loops_in_5_secs_2:
	call	loop_group
	retn
	
two_in_5:
	;Reset Loop Counters	AXL SAY DON'T!
;	mov	loop_h,0
;	mov	loop_l,0
;overtake??
	call	get_position
;million!
	effect Million
	mov	loop_l_,true
	mov	loop_h_,true
	retn

loop_group:
	CALL	JACKADD
	mov	cx,size effect_struc+1
	mov	ax,speeden
	cmp	ax,11
	jna	no_kris_lelle_van
	mov	ax,11
no_kris_lelle_van:
	mul	cx
	add	ax,offset SScore1
	mov	si,ax
	CALL	DOEFFECT
	cmp	TurboMode,true
	jne	NoTurboModeNow
	effect TurboEffect
	call	addTurboMode
NoTurboModeNow:
Again_Mile:
	inc	MilesCount
	mov	si,offset etta
	mov	di,offset cyclonecounterbcd
	call	addscorebcd
	Cmp	MilesCount,1
	je	Again_Mile
	
	cmp	MilesCount,20
	ja	NoAtAll
	cmp	Milescount,10
	jbe	NoXBall
	effect	xball_at_20
	;skriv ut xball at 20
	cmp	MilesCount,20
	jne	noxball
	lightflash 1,std_lgt_speed		;cp!
	lighton 1
	effect litxball
NoXBall:
	cmp	MilesCount,10
	je	dotheoffice
	ja	NoOffRoad
	effect	offroad_at_10
	jmp	NoOffRoad
dotheoffice:
	call	DoTheOffroad
NoOffRoad:
NoAtAll:
	mov	ax,MilesCount
	cmp	ax,NextJump
	jne	NoNextJump
	add	NextJump,20
	cmp	lightstatus[5],true
	je	already_lit_the_jump_light
	lighton 5
Jump_Speed=std_lgt_speed
	lightflash 5,Jump_Speed
	effect	lgt_Jump
already_lit_the_jump_light:
	jmp	did_jump
NoNextJump:
	mov	cx,nextjump
	sub	cx,ax
	cmp	cx,10
	jnb	did_jump
;***************************** lites the jump
	mov	ax,nextjump
	mov	di,2
	mov	cx,3
loopen_lejf:
	push	cx
	mov	dx,0
	mov	cx,10
	div	cx
	cmp	dx,0
	jne	nozero
	cmp	di,0
	jne	nozero
	mov	dx,'*'-'7'
nozero:
	add	dx,'7'
	mov	jump_at_text[di],dl
	pop	cx
	dec	di
	loop loopen_lejf
;*****************************
	effect	jump_at
did_jump:
	mov	ax,MilesCount

	mov	cx,NextOffRoad
	sub	cx,ax
	cmp	cx,10
	jnbe	NoNextOff
	cmp	ax,NextOffRoad
	jne	NoOffNowOr
	add	NextOffRoad,20
	call	DoTheOffroad
NoOffNowOr:
;***************************** lites the off road
	mov	ax,NextOffRoad
	mov	di,2
	mov	cx,3
loopen_lejfAron:
	push	cx
	mov	dx,0
	mov	cx,10
	div	cx
	cmp	dx,0
	jne	nozerohelge
	cmp	di,0
	jne	nozerohelge
	mov	dx,'*'-'7'
nozerohelge:
	add	dx,'7'
	mov	offroad_at_text[di],dl
	pop	cx
	dec	di
	loop loopen_lejfAron
;*****************************
	effect OffRoad_At

NoNextOff:
	
NotStandardSeries:
	;move miles to the scrolltext
	mov	bx,5+offset miles_text
	mov	ax,cyclonecounter
	call	put_in_text
	retn

;*****************************
;Input: Ax= NextRÑknare  Bx=offset till texten
Put_In_Text:
	PUSH	BX
	mov	di,2
	mov	cx,3
loopen_leffe:
	push	cx
	NIL	DX
	MOV	CX,10
	DIV	CX
	add	dx,'7'
	mov	[bx][di],dl
	pop	cx
	dec	di
	loop loopen_leffe
	POP	BX

LOOPEN_BERTIL:
	CMP	BYTE PTR [BX],'7'
	JNZ	AVBRYT_BRUTALT
	MOV	BYTE PTR [BX],'*'
	INC	BX
	LOOP	LOOPEN_BERTIL
AVBRYT_BRUTALT:
	RETN
;*****************************

comment\
	mov	cx,4
	nil	bx
	mov	dx,true
first_null	equ dx
	nil	first_null
lurken:
	mov	al,cyclonecounterbcd[8+bx]
	add	al,'0'

	cmp	al,'0'
	jne	setit_orc
	cmp	first_null,true
	je	dont_check_it_now
	mov	al,' '
	jmp	dont_check_it_now
setit_orc:
	mov	first_null,true
dont_check_it_now:
	add	al,'7'-'0'
;	mov	miles_text[21+bx],al
	mov	miles_text[5+bx],al
	inc	bx
	loop	lurken

	retn
\


;******************************************************************************
UPDATE_COUNTERS PROC NEAR
	INC	POS_SYNCER				;SNACK SYNCER
	CMP	POS_SYNCER,POS_SPEED*2
	JNE	SNSOK
	MOV	POS_SYNCER,0
SNSOK:
	DOWNCOUNT flash7down,flash7end 
	DOWNCOUNT flash6down,flash6end 
	DOWNCOUNT flash5down,flash5end 
	DOWNCOUNT flash_pit_down,turn_pit_off
	DOWNCOUNT LOOP_H,DUMRET
	DOWNCOUNT LOOP_L,DUMRET
	DOWNCOUNT GEAR_DOWN,GEARKASSE
	downcount jackdown,jack_slack
	RETN
UPDATE_COUNTERS	ENDP

ADDOffRoad PROC NEAR
	CMP	OffRoadMode,TRUE
	JNE	NOTOFFICEADDING
	MOV	SI,OFFSET BCDHUNDRATUSEN
	MOV	DI,OFFSET OR_TOTAL
	CALL	ADDSCOREBCD
	MOV	SPECIAL_SCORE_CHANGED,TRUE
NOTOFFICEADDING:
	RETN
ADDOffRoad ENDP

ADDTurboMode PROC NEAR
	CMP	TurboMode,TRUE
	JNE	NOTkluOFFICEADDING
	MOV	SI,OFFSET BCDfemmillioner
	MOV	DI,OFFSET tm_TOTAL
	CALL	ADDSCOREBCD
	MOV	SPECIAL_SCORE_CHANGED,TRUE
NOTkluOFFICEADDING:
	RETN
ADDTurboMode ENDP

BUMPER_WAS_HIT_PROC PROC NEAR	;INPUT: HITPOINTER
	call	addoffroad
	UPDAT_INFOBAR
	RETN
BUMPER_WAS_HIT_PROC ENDP



;********************************* DOT MATRIX CODE ****************************
_PARTYONN:
	MOVE	DS,DATA
	ASSUME	DS:DATA
	MOV	AL,PLAYER
	ADD	AL,'A'-10
	MOV	PARTY_ON_TEXT[18],AL
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	JMP	NORMAL_END

_SHOOT_AGAIN_ONN:
	MOVE	DS,DATA
	ASSUME	DS:DATA
	MOV	AL,PLAYER
	ADD	AL,'A'-10
	MOV	SHOOT_AGAIN_TEXT[19],AL
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	JMP	NORMAL_END

_beep:		;2 vars!!!
	beep
	jmp	normal_end

_PARTYON:		;BX NOT USED!
	MOV	PARTYFLASH,TRUE
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET PARTYRUT
	JMP	NORMAL_END

_PARTYOFF:	;TURN OFF PARTYON FLASHING (AND BRING BACK SCORE!)
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	JMP	NORMAL_END

_WAIT_GAME_ON:
	MOV	DOTRUT,OFFSET GONRUT
	MOV	SISA,44
	JMP	NORMAL_END
GONRUT:
	CMP	ADDPLAYERS,TRUE
	JE	INTE_SATT_IGANG
	MOV	SI,0
	RETN
INTE_SATT_IGANG:
	MOV	SI,34		;INTE 0 = INTE IGèNG !!
	RETN

	
_JBCDZ:
	IFZEROBCD [BX+2]
	JC	OVERIT_
	MOV	BX,[BX+4]
	SUB	BX,6
OVERIT_:
	ADD	BX,6
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_4
	MOV	BX,0
	MOV	NEXT_A,BX
	RETN
_NEXTp_4:
	MOV	NEXT_A,BX
	JMP	[BX]
	RETN
_BONUS_X_CALCS:		;FN: MULTIPLIES THE BONUS
			;INPUT: BONUS_X, BONUSSIFFRORNA
			;OUTPUT: BONUSSIFFRORNA
	PUSH	BX
	PUSH	ES
	MOVEBCD	TEMPBONUSBCD,BONUSSIFFRORNA
	MOV	CL,BONUS_X
	DEC	CL
	JZ	NO_X_BONUS
	NIL	CH
DO_IT_AGAIN:
	PUSH	CX
	MOV	SI,OFFSET TEMPBONUSBCD
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD
	POP	CX
	LOOP	DO_IT_AGAIN
NO_X_BONUS:	
	MOV	AL,BONUS_X
	ADD	AL,'7'
	MOV	BONUS_X_TEXT[8],AL
	POP	ES
	POP	BX
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	JMP	NORMAL_END

	
_JBONUSX1:
	CMP	BONUS_X,1
	JNE	QJBX1
	ADD	BX,2
	MOV	BX,[BX]
	MOV	NEXT_A,BX
	JMP	[BX]
QJBX1:	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	JMP	NORMAL_END	

_Jmp:
	add	bx,2
	mov	bx,[bx]
	MOV	NEXT_A,BX
	JMP	[BX]
	retn
	

_CALC_HAPPY:	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	PUSHA
	MOV	SI,OFFSET OR_TOTAL 	;ML_TOT -> TOTAL BONUS
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD
	POPA
	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_3E
	MOV	BX,0
_NEXTp_3E:
	MOV	NEXT_A,BX
	RETN

_CALC_mega:	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	PUSHA
	MOV	SI,OFFSET tm_TOTAL 	;ML_TOT -> TOTAL BONUS
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD
	POPA
	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_3Eh
	MOV	BX,0
_NEXTp_3Eh:
	MOV	NEXT_A,BX
	RETN



_CALC_CYCLO:
	PUSH	ES
	MOVE	ES,DS
	MOV	DI,OFFSET CYCLONESCOREBCD
	NIL	AX
	MOV	CX,12/2 ;(12/6=6!!!)
	REP	STOSW
	POP	ES
	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	MOV	CX,CYCLONECOUNTER
URBANLOOP:
	MOV	SI,OFFSET HUNDRATUSEN
	MOV	DI,OFFSET CYCLONESCOREBCD
	PUSH	CX BX
	CALL	ADDSCOREBCD
	POP	BX CX
	LOOP	URBANLOOP
	
	MOV	SI,OFFSET CYCLONESCOREBCD	;CYCLONES -> TOTAL BONUS
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD

	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_3gg
	MOV	BX,0
_NEXTp_3gg:
	MOV	NEXT_A,BX
	RETN
	
READ_SPECIAL_MODE_COUNTER PROC NEAR

;[SEC_ASC] PEKAR Pè MSD, (0='*')	[SEC_ASC+1] PEKAR Pè LSD
;LéS AV BARA!
	MOVE	DS,DATA
	cmp	[sec_asc],'*'
	jne	no_end
	cmp	[sec_asc+1],'0'+7	;???
	jne	no_end
	cmp	turbomode,true
	jne	noturboend
	playjingle_penetrate Sjingle20
	mov	lastjingle,3
noturboend:
	cmp	OffRoadmode,true
	jne	nooffrend
	playjingle_penetrate Sjingle23
	mov	lastjingle,3
nooffrend:
;	mov	specialmode,false
	mov	offroadmode,false
	mov	turbomode,false		;mega cp!!
	mov	current_priority,0
	mov	lastjingle,3
	mov	jinglejumpcnt,1
no_end:
	RETN
READ_SPECIAL_MODE_COUNTER ENDP

_DOBEATEN:
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	PUSHA
	LIGHTON	55
	POPA
	JMP	NORMAL_END


CODE	ENDS

;******************************************************************************
;************************* O T H E R   S E G M E N T S ************************
;******************************************************************************

HIDDEN1 SEGMENT PARA PUBLIC 'DATA'
	UNDANSPR DB 16*16 DUP (0)
	HIDDA	DB 576*2 DUP(0)
	EXTRN	HID1
HIDDEN1 ENDS

HIDDEN2 SEGMENT PARA PUBLIC 'DATA'
	HIDDA2	DB 576*2 DUP(0)
	EXTRN	HID2
HIDDEN2 ENDS

MASK1_2 SEGMENT PARA PUBLIC 'DATA'
	EXTRN MASK12
MASK1_2 ENDS

MASK1_1 SEGMENT PARA PUBLIC 'DATA'
	EXTRN MASK11
MASK1_1 ENDS

MASK2_2 SEGMENT PARA PUBLIC 'DATA'
	EXTRN MASK22
MASK2_2 ENDS

FLIPLEFT SEGMENT PARA PUBLIC 'DATA'
if create_flip_data
	EXTRN FLIPL
else
	extrn flipl_1
endif
FLIPLEFT ENDS

FLIPLEFT2 SEGMENT PARA PUBLIC 'DATA'
if create_flip_data
	EXTRN FLIPL2
else
	extrn flipr2_1
endif
FLIPLEFT2 ENDS

FLIPRIGHT SEGMENT PARA PUBLIC 'DATA'
if create_flip_data
	EXTRN FLIPR
else
	extrn flipR_1
endif
FLIPRIGHT ENDS

LASTSEG SEGMENT
LASTSEG ENDS

STAGE1_1 SEGMENT PARA PUBLIC 'DUMP'
	extrn st1
STAGE1_1 ENDS

STAGE1_2 SEGMENT PARA PUBLIC 'DUMP'
	extrn st2
STAGE1_2 ENDS

STAGE1_3 SEGMENT PARA PUBLIC 'DUMP'
	extrn st3
STAGE1_3 ENDS

STAGE1_4 SEGMENT PARA PUBLIC 'DUMP'
	extrn st4
STAGE1_4 ENDS

MASK1_3 SEGMENT PARA PUBLIC 'DUMP'
	EXTRN MASK13
MASK1_3 ENDS

MASK2_1 SEGMENT PARA PUBLIC 'DUMP'
	 EXTRN MASK21
MASK2_1 ENDS

MASK2_3 SEGMENT PARA PUBLIC 'DUMP'
	 EXTRN MASK23
MASK2_3 ENDS

FLIPGFXSEG SEGMENT PARA PUBLIC 'DUMP'
	EXTRN	FLIPGFX:BYTE
SISTAGFX LABEL BYTE
FLIPGFXSEG ENDS

SPRINGSEG SEGMENT PARA PUBLIC 'DUMP'
	EXTRN SPRING
SPRINGSEG ENDS
;******************************************************************************


