;******************************************************************************
;**                                                                          **
;**                   P I N B A L L   F A N T A S I E S                      **
;**                   TABLE 3: BILLION DOLLAR GAME SHOW                      **
;**                                                                          **
;******************************************************************************
INCLUDELIB BILLION
INCLUDELIB CLEAR
flipgfxfilesize=220
FIRSTMASK_GFXADR=BPL*(SPLH+BANH)
GFXADR_FOR_FLIP_ANIM_DATA=FIRSTMASK_GFXADR+BPL*40
springsourceadr=GFXADR_FOR_FLIP_ANIM_DATA-3*23	;3*23 ŽR F™R FJŽDERNS GFX
springdestadr=(splh+556)*bpl+304/4
DATAFLIP SEGMENT PARA PUBLIC 'DATA'
MAXDIFS1=114+5
MAXDIFS2=114+5
MAXDIFS3=137+5
maxdifs=137
if create_flip_data
LEFTFLIPTAB	DW 42*(2*MAXDIFS1) DUP (1)
RIGHTFLIPTAB	DW 42*(2*MAXDIFS2) DUP (1)
LEFTFLIP2TAB	DW 26*(2*MAXDIFS3) DUP (1)
TEMPTAB		DW 2*MAXDIFS DUP (1)	
else	
	extrn	leftfliptab,rightfliptab,leftflip2tab
endif
DATAFLIP ENDS
DATA	SEGMENT PARA PUBLIC 'DATA'
	ASSUME CS:CODE,DS:DATA
	BALL_LOCK_YPOS EQU 537

MODUL	DB 'TABLE3.MOD',0,'$'
if create_flip_data
flipdatafil_L	DB 'flipdata.3L',0
flipdatafil_R	DB 'flipdata.3R',0
flipdatafil_L2	DB 'flipdata.3L2',0
flipgfxfil	DB 'flipgfx.3',0
flipSTRUCfil	DB 'flipSTRU.3',0
endif
hi_score_file	db 'table3.hi',0
hi_score_list	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'TSP',0
		db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ANY',0
		db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'J L',0
		db 0,0,0, 0,0,5, 0,0,0, 0,0,0,'ICE',0
;******************************************************************************
;******************************** DEFINITIONS *********************************
;******************************************************************************
TOTCENT=16

;******************** SYSTEM **********************
MAX_NO_OF_LIGHTS_FLASHING=30
MAX_NO_OF_WAIT_SYNCS=50
NOOFTASKS=20
RGB_BUFFER_LEN=500

;******************** FLIPPER & BALL **********************
BALLH=16
BANH=576
STARTX=310-BALLH/2+2
STARTY=543-BALLH/2

F3TOP=176
F3HEIGHT=53

;******************** FLASHING **********************
MATRIXlo=153
MATRIXhi=114
MATRIXCOLS=matrixhi*256+matrixlo
PARTY_ON_SPEED=3	;?
SHOOT_AGAIN_SPEED=3	;?
BIT2COL			DB 0,0,0,0,6,1,41,0	;flipper f„rgerna

;******************** GAME TIMING ********************
LM_TIME=10*60
TV_Time=4*60
BOAT_Time=10*60
HOUSE_Time=10*60
PLANE_Time=10*60
SJP_TIME=5*60
JP_TIME=25*60
TRIP_Time=4*60
CAR_Time=4*60
cash5_time=11*60 ;cpw!
MB_time=4*60 ;cpw!
sfspeed=10
LOOPS_N_TRAPS DB ?
PARTYFLASH		DB FALSE
syncflasher	db 0
evendata
LOOP_MILLION_COUNTER DW 0
SJP_counter	dw 0
JP_counter	dw 0
MBcounter	dw 0
TVcounter	dw 0
BOATcounter	dw 0
HOUSEcounter	dw 0
PLANEcounter	dw 0
TRIPcounter	dw 0
CARcounter	dw 0
cash5counter	dw 0
nextSPINtime	dw ?
SPINTIMES_HI	dw 15 dup(4),5,5,6,7,7,7,7,8,8,8,9,10,10,10,10,11,11,11,11,12,12,14,16,19,22,25,50,-1
SPINTIMES	dw 15 dup(4),5,5,5,6,6,6,6,7,7,7,8,8,8,8,9,9,10,10,12,14,17,20,24,32,47,-1
SPINcounter	dw ?
SPINlight	db 0
rm		db 0,0,0,0,0,0,0,0,0,0,0,0
Tjufemtusen	db 0,0,0,0,0,0,0,2,5,0,0,0
SPINscores	db 0,0,0,'*'-'A'+10,'*'-'A'+10,'*'-'A'+10,'*'-'A'+10,2,5,0,0,0 ;rensar tv† f”rsta
_50K		db 0,0,0,0,0,0,0,5,0,0,0,0
_100K		db 0,0,0,0,0,0,1,0,0,0,0,0
_250K		db 0,0,0,0,0,0,2,5,0,0,0,0
_500K		db 0,0,0,0,0,0,5,0,0,0,0,0
_1000K		db 0,0,0,0,0,1,0,0,0,0,0,0
_2500K		db 0,0,0,0,0,2,5,0,0,0,0,0
_5000K		db 0,0,0,0,0,5,0,0,0,0,0,0

CASHPOTSTEP	DB 0,0,0,0,0,0,0,0,7,1,3,0
CASHPOTSTEP2	DB 0,0,0,0,0,0,2,2,7,8,3,0

;******************** HOLES **********************

;******************************************************************************
;****************************** GENERAL VARS **********************************
;******************************************************************************
TURBOMODE DB FALSE
OFFROADMODE DB FALSE
TVflag	db ?
BILLION_ENABLED DB ?
TRIPflag db ?
CARflag db ?
HOUSEflag	db ?
BOATflag db ?
PLANEflag db ?
top_three db ?
all_six db ?
bonusmultiplier db ?
BONUSTABLE DB 2,3,4,6,8,10 ;DE OLIKA BONUSMULTIPLIERNA
BONUS_ANIMS DW _bonusx2TS,_bonusx3TS,_bonusx4TS,_bonusx6TS,_bonusx8TS,_bonusx10TS
SKILLCOUNTER equ cyclonecounterbcd
ETTA	DB 11 DUP(0),1
HUNDRATUSEN	db 0,0,0,0,0,0,1,0,0,0,0,0
BCDfemmillioner db 0,0,0,0,0,5,0,0,0,0,0,0
bcd7510	db 0,0,0,0,0,0,0,0,7,5,1,0
bcd7520	db 0,0,0,0,0,0,0,0,7,5,2,0
bcd550	db 0,0,0,0,0,0,0,0,0,5,5,0
bcd570	db 0,0,0,0,0,0,0,0,0,5,7,0
bcdhundratusen db 0,0,0,0,0,0,1,0,0,0,0,0

if create_flip_data
FlipLInfo	LABEL FLIPSTRUC
		DB    FlipperL,222
		DW    80,510,4,53,0,142,400,576,95,536,0,(53*8*3)
		DW    0,0,0,20,20*ADJUST,-7*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW    ?,?,?,?,LEFTFLIPTAB,LEFTFLIPTAB,MAXDIFS1*4
		DW    FLIPLEFT

		DB    FlipperR,222
		DW    160,510,4,53,143,320,400,576,204,536,0,(53*8*3)
		DW    0,0,0,20,20*ADJUST,-7*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW    ?,?,?,?,RIGHTFLIPTAB,RIGHTFLIPTAB,MAXDIFS2*4
		DW    FLIPRIGHT

		DB    FlipperR,222
		DW    240,176,3,51,220,320,0,250,286,182,-1,(51*6*3)
		DW    0,0,0,12,12*ADJUST,-9*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW    ?,?,?,?,LEFTFLIP2TAB,LEFTFLIP2TAB,MAXDIFS3*4
		Dw    flipLEFT2

		DB    0,0	;END OF FLIPSTRUC
else
	extrn fliplinfo:flipstruc
endif
no_of_ramps equ 5 ;cpw!?!?
RampTable  DW	0,10*tt/nn
	   DW	 4*tt/nn,13*tt/nn
	   DW	 0,15*tt/nn
	   DW	 2,10*tt/nn
	   DW	 6*tt/nn,14*tt/nn
	   DW	0,0		;ska den va me??? CP!!
RampTable_hi  DW	0,10
	   DW	 4,13-1
	   DW	 0,15-1
	   DW	 2,10-1
	   DW	 6,14-1
	   DW	0,0		;ska den va me??? CP!!


PLAYER_STRUC STRUC
	P_SIFFRORNA		DB 12 DUP(?)
	P_BONUSSIFFRORNA	DB 12 DUP(?)
	P_TOP_THREE		DB ?
	P_ALL_SIX		DB ?
	P_CYCLONECOUNTERBCD	DB 12 DUP(?)
	P_CYCLONECOUNTER	DW ?
ENDS

PLAYER_AREA DB SIZE PLAYER_STRUC * NO_OF_PLAYERS DUP(?)

CYCLONECOUNTER DW ?				;HEXADECIMAL
cyclonecounterBCD	DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
CYCLONESCOREBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
XXBALLE			DB ?


;******************************************************************************
;********************************* EFFECTS ************************************
;******************************************************************************

EFFECT_STRUC STRUC
	THEJINGLE	DW ?
	TSCORE		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	TBONUS		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	DOTMATRIX	DW ?
ENDS
SHOOTTHEBALL	DW	SJINGLE12
		DB	0,0,0, 0,0,0, 0,0,0, 0,0,0	;CP?
		DB	0,0,0, 0,0,0, 0,0,0, 0,0,0	;CP?
		DW	SHOOTTHEBALLTS		

BILLION		DW	SJINGLE1
		DB	0,0,1, 0,0,0, 0,0,0, 0,0,0	;CP?
		DB	0,0,0, 0,0,5, 0,0,0, 0,0,0	;CP?
		DW	BILLIONTS		


;BygelSetA		Dc.L	0,SBygel1,0,$50000,0,0,0
bygelsetA	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		dw 0

;BygelSetB	Dc.L	0,SBygel2,0,$10000,0,$1020,0
bygelsetB	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,2,0
		dw 0

;BygelSetC		Dc.L	0,0,0,$10000,0,$1030,R6
bygelsetC	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,3,0
		dw 0

;BygelSetD		Dc.L	0,0,0,$10000,0,$1040,R5
bygelsetD	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,4,0
		dw 0

;BygelSetE		Dc.L	0,0,0,$10000,0,$1050,R3
bygelsetE	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,5,0
		dw 0

;BygelSetF		Dc.L	0,0,0,$10000,0,$1060,0
bygelsetF	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,6,0
		dw 0

;BygelSetG		Dc.L	0,0,0,$10000,0,$1070,0
bygelsetG	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,7,0
		dw 0

;BygelSetH		Dc.L	0,0,0,$10000,0,$1080,R4
bygelsetH	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,8,0
		dw 0

;BygelSetI		Dc.L	0,0,0,$10000,0,$1090,R1
bygelsetI	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,9,0
		dw 0

;BygelSetJ		Dc.L	0,0,0,$10000,0,$1010,R2
bygelsetJ	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,1,0
		dw 0

;BygelSetK		Dc.L	0,0,0,$10000,0,$1030,0
bygelsetK	dw 0
		db 0
		db 0,0,0, 0,0,0, 0,1,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,1, 0,3,0
		dw 0


youwinTV 	dw sjingle7
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW youwinTVTS
youwinTrip 	dw sjingle7
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW youwinTRIPTS
youwinCAR	dw sjingle7
		db 0,0,0, 0,0,3, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW youwinCARTS

youwinBOAT 	dw sjingle7
		db 0,0,0, 0,0,5, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 2,5,0, 0,0,0
		DW youwinBOATTS
youwinHOUSE	dw sjingle7
		db 0,0,0, 0,0,7, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		DW youwinHOUSETS
youwinPLANE	dw sjingle7
		db 0,0,0, 0,1,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		DW youwinPLANETS
		
moneymania 	dw sjingle9
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW turboTS

moneymania2 	dw sjingle9
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW turbo2TS

JACKPOT 	dw sjingle14
JACKVALUE	db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW jackpotTS
		
JACKINIT	DB 0,0,0, 0,1,0, 0,0,0, 0,0,0		

S_JACKPOT 	dw sjingle15
		db 0,0,0, 0,5,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		DW 0

EXTRA_BALL 	dw sjingle11
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW _xtraballTS

RAISING_M 	dw sjingle16
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW rmTS


SKILLSHOt	DW sjingle6
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW skillshotTS

SKILLSHOt_XB	DW sjingle6
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW skillshotXBTS
		
cashpot		DW sjingle5
		;dd 0,0				;cp! fel po„ng&bonus
CASHPOTVAL	db 0,0,0, 0,0,0, 5,0,7, 5,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,1,0
		DW cashpotTS

cashpot5	DW sjingle18
		;dd 0,0				;cp! fel po„ng&bonus
CASHPOT5VAL	db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,1,0
		DW cashpot5TS

TouchB		DW 0
		DB 0
		db 0,0,0, 0,0,0, 0,0,7, 5,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,3,0
		DW 0

TouchC		DW 0
		DB 0
		db 0,0,0, 0,0,0, 0,0,7, 5,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,7,0
		DW 0

dollartouch	DW 0
		DB 0
		db 0,0,0, 0,0,0, 0,0,7, 5,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,1,0
		DW 0
		
dollartouch2	DW sjingle20
		db 0,0,0, 0,0,0, 0,0,7, 5,0,0
		db 0,0,0, 0,0,0, 0,0,0, 5,1,0
		DW 0
		
LOOPMILLION	DW SJINGLE17	
		db 0,0,0, 0,0,1, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,7,5, 0,0,0
		DW millionTS	;CP!

TVLIT		DW SJINGLE6
;		DD 0,0
		db 0,0,0, 0,0,0, 1,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,5, 0,0,0
		DW TVlitTS

TRIPLIT		DW SJINGLE6
;		DD 0,0
		db 0,0,0, 0,0,0, 2,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,5, 0,0,0
		DW TRIPlitTS

CARLIT		DW SJINGLE16
;		DD 0,0
		db 0,0,0, 0,0,1, 2,5,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,5, 0,0,0
		DW CARlitTS

BOATLIT		DW SJINGLE21
;		DD 0,0
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW BOATlitTS

HOUSElit	DW SJINGLE21
;		DD 0,0
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW HOUSElitTS

PLANELIT	DW SJINGLE21
;		DD 0,0
		db 0,0,0, 0,0,0, 5,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,5,0, 0,0,0
		DW PLANElitTS

LOSTBALL	DW S_LOSTBALL	
;		DD 0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW ball_lostTS
if demover
MINUTE5		DW S_GAMEOVER2	
;		DD 0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		db 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW minute5TS
endif
BONUS_X			DB ?
TEMPBONUSBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?


;******************************************************************************
;**************************** SOUND STRUCTURES ********************************
;******************************************************************************

sbase		Equ	16H

SBrickNer	DB  (sbase+0),18,0,3
SBrickUpp	DB  (sbase+1),18,0,3
SBumper 	DB  (sbase+2),18,0,3
SFlippUpp	DB  (sbase+3),22,0,3
SRinner 	DB  1ch,18,0,3		;CP?
SNewBall	DB  1ch,18,0,3
SKicker 	DB  1DH,18,0,3
SFjader 	DB  1eh,18,0,3
SGrop		DB  (sbase+1),18,0,3

;***********************************************************************

ebase		Equ	15

SBygel1 	DB  (ebase-8),10,0,3
SBygel2 	DB  (ebase-8),12,0,3
SBygel3 	DB  (ebase-8),8,0,3
SBygel4 	DB  (ebase+0),17,0,3
SBygel5 	DB  (ebase+0),8,0,3
S_Touch1	DB  (ebase-8),14,0,3
S_Touch2	DB  (ebase+0),10,0,3
S_MultiLjud	DB  (ebase-8),10,0,3
S_ScoreLjud	DB  (ebase+0),18,0,3
S_TripCount	DB  (ebase+0),15,0,3

;***********************************************************************
;JINGLE,NOOFPTNS (0=4EVER),PRIORITY

;S_MULTILJUD	 DB	 39,1,255 ;255?
emptyjingle equ 55
springjingle equ 0
mainjingle equ 1
lastmainpos equ 6
S_Empty 	DB  55,0,0
S_Spring	DB  0,0,0
S_Main		DB  1,0,0
S_NoHigh	DB  18,0,0
S_Danger	DB  44,1,255
S_Tilt		DB  43,1,255
S_GameOver	DB  28,0,0
S_GameOver2	DB  7,0,0
S_LostBall	DB  30,1,200
S_AddPlayer	DB  53,0,200

;S_AddPlayer2	DB  53,0,200	;cp!?
S_AddPlayer2	DB  (ebase+0),20,0,3 ;cp!?

S_Lock		DB  29,1,90	    ;Bonus Locked
S_Mystery	DB  49,1,150
S_EndFig	DB  52,1,0
S_Knacket	DB  54,1,230
S_BEATEN	DB	54,1,200	;CP!!!
S_BEATEN_XB	DB	54,1,200

;***********************************************************************
SJingle1		DB  23,3,200	    ;Billion
SJingle2		DB  27,1,10 ;Multi Bonus
SJingle3		DB  31,1,10 ;Jackpot Lit
SJingle4		DB  32,1,10 ;Ball Locked
SJingle5		DB  33,1,10 ;Cash Pot
SJingle6		DB  34,1,10 ;Ramp Count
SJingle7		DB  35,1,10 ;10 Millions
SJingle8		DB  36,1,10 ;Price lit
SJingle9		DB  38,0,255  ;Money Mania
SJingle10		DB  41,1,255 ;Money Mania End
SJingle11		DB  42,1,120	    ;Extra Ball
SJingle12		DB  47,1,10 ;Billion Lit
SJingle13		DB  48,1,10 ;Ball Lock Enabled
SJingle14		DB  50,1,110	    ;Jackpot
SJingle15		DB  51,1,150	    ;Super Jackpot
SJingle16		DB  45,1,110	    ;Million Plus
SJingle17		DB  46,1,50 ;Million
SJingle18		DB  56,1,10 ;5*Cash Pot
SJingle19		DB  57,1,110	    ;Extra Ball Lit
SJingle20		DB  58,1,150	    ;Spin Wheel Enabled
SJingle21		DB  59,1,110	    ;Price(2) Lit
SJingle22		DB  60,1,50 ;Ball Trap Open



;******************************************************************************
;***************************** DETECTION AREAS ********************************
;******************************************************************************

BumperLista_L	DW    44,145,68,169
		DW    Bumper1
		DW    74,201,98,226
		DW    Bumper2
		DW    11,231,35,247
		DW    Bumper3
BumperLista_U	DW    -1,-1,-1,-1
		DW    -1

Bumper2Lista_L	DW    50,415,80,470   ;Just to add power
		DW    Kicker	     ;No Scores or effects
		DW    219,415,249,470
		DW    Kicker
Bumper2Lista_U	DW    -1,-1,-1,-1
		DW    -1

bumper1 	dw	sbumper
		db	0,0,0, 0,0,0, 0,0,1, 0,0,0	;CP!!!
bumper2 	dw	sbumper
		db	0,0,0,0,0,0,0,0,1,0,0,0
bumper3 	dw	sbumper
		db	0,0,0,0,0,0,0,0,1,0,0,0
kicker		dw	skicker
		db	0,0,0,0,0,0,0,0,0,5,0,0

ZonLista_L	label word
		DW	159,122,180,131
		dw	dropa1
		DW	180,127,202,136
		dw	dropa2
		DW	139,225,148,244
		dw	dropb1
		DW	135,245,144,264
		dw	dropb2
		DW	30,264,39,283
		dw	dropc1
		DW	26,284,35,303
		dw	dropc2
		DW	0

AreaLista_L LABEL WORD
			DW    230,280,260,330 ;Game On
                        DW    Close1
			DW    305,512,320,576 ;Spring Valid
			DW    Bygel28
			DW    300,400,320,450 ;Spring invalid?
			DW    Open1
			DW    102,23,122,45
			DW    Bygel11		;l„ngst upp i loopen
			DW    190,25,210,45
			DW    Bygel12		;till h”ger i loopen
			DW    103,233,122,254
			DW    GropA
			DW    1,520,20,555 ;CP! SKA VA X1=0
			DW    GropB
			DW    1,460,25,500 ;CP! SKA VA X1=0
			DW    Close4
			DW    25,435,35,445
			DW    Bygel3
			DW    263,435,273,445
			DW    Bygel4
			DW    5,455,15,465
			DW    Bygel1
			DW    284,455,294,465
			DW    Bygel2
			DW    120,130,130,140	;SKILL
			DW    Bygel9
			DW    222,104,232,114
			DW    Bygel8
			DW    90,152,100,162
			DW    Bygel13
			DW    0

AreaLista_U	LABEL WORD
			DW    1,30,20,50	;CP! SKA VA X1=0
			DW    Bygel6
			DW    45,70,70,95
			DW    Close3
			DW    31,78,51,98
			DW    Bygel10
			DW    290,90,320,125
			DW    Bygel5
			DW    155,75,185,105
			DW    Bygel7
			DW    222,104,232,114
			DW    Bygel8
			DW    120,130,130,140
			DW    Bygel9
			DW    1,50,20,70	;cp x1 ska va 0
			DW    Bygel6b
COMMENT\
			DW    180,125,205,160
			DW    Open2
			DW    25,200,50,255
			DW    Close2
			DW    280,360,300,380
			DW    Open5
			DW    25,435,35,445
			DW    Open3
\
			DW    0

AREALISTA_L_T		LABEL WORD
			DW	1,520,20,555 ;CP! SKA VA X1=0
			DW	GropB
			DW	0

AREALISTA_U_T		LABEL WORD
			DW	0


LEVEL1LISTA	LABEL	WORD	;AREOR SOM ANGER HOPP TILL LEVEL 1 FRN LEVEL 2
	DW    100,70,125,98
	DW    250,70,270,100
	DW    255,85,277,120
	DW    210,110,250,140
	DW    290,125,320,145
	DW    140,125,170,170
	DW    95,155,120,190
	DW    260,450,277,470
	DW    20,450,50,470
	DW    0,525,25,555
	DW    -1

LEVEL2LISTA	LABEL	WORD	;AREOR SOM ANGER HOPP TILL LEVEL 2 FRN LEVEL 1
		DW    125,70,150,100
		DW    190,75,230,100
		DW    200,80,240,100
		DW    290,105,320,125
		DW    110,110,140,150
		DW    -1


;******************************************************************************
;************************ DEMO MODE LIGHT FLASHING ****************************
;******************************************************************************

FLASHLIST	LABEL WORD
		T2=15
		DW 0,0,T2,T2,1		;SKILL

		T2=12
		DW 0,0,T2,T2,6		;lock
		
		T1=6			;DOLLAR SIGNS
		T2=T1*2
		DW 0,0,T2,T2,2
		DW 0,T2,T2,T2,3
		
		T1=6			;SPIN DOCTORS
		T2=T1*8
		DW 0,T1*0,T2,T2,19
		DW 0,T1*1,T2,T2,20
		DW 0,T1*2,T2,T2,21
		DW 0,T1*3,T2,T2,22
		DW 0,T1*4,T2,T2,23
		DW 0,T1*5,T2,T2,24
		DW 0,T1*6,T2,T2,25
		DW 0,T1*7,T2,T2,26
		
		T1=12
		T2=T1
		DW 0,0,T2,T2,33
		DW 0,T1,T2,T2,34
		DW 0,0,T2,T2,35
		DW 0,T1+T1/2,T2,T2,36
		DW 0,T1/2,T2,T2,37
		DW 0,T1+T1/2,T2,T2,38
		DW -1

;******************************************************************************
;**************************** LIGHT PALETTE DATA ******************************
;******************************************************************************

NOOFLIGHTS=38

LON1	DB 254	;skill
	DB 2
	DB 64,0,0
	DB 95,0,0
	
LON2	DB 251	;$1
	DB 3
	DB 14,70,64
	DB 8,64,58
	DB 14,83,77
	
LON3	DB 248	;$2
	DB 3
	DB 14,70,64
	DB 8,64,58
	DB 14,83,77
	
LON4	DB 245	;loop mil
	DB 3
	DB 77,39,0
	DB 83,52,8
	DB 89,70,33
	
LON5	DB 243	;50M
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON6	DB 240	;lock
	DB 3
	DB 70,70,70
	DB 83,83,83
	DB 95,95,95
	
LON7	DB 235	;”vre bricka
	DB 5
	DB 14,33,52
	DB 8,39,64
	DB 27,52,77
	DB 45,64,77
	DB 70,70,70
	
LON8	DB 230	;nedre bricka
	DB 5
	DB 14,33,52
	DB 8,39,64
	DB 27,52,77
	DB 45,64,77
	DB 70,70,70

LON9	DB 225	;bricka
	DB 5
	DB 14,33,52
	DB 8,39,64
	DB 27,52,77
	DB 45,64,77
	DB 70,70,70

LON10	DB 220		;bricka
	DB 5
	DB 14,33,52
	DB 8,39,64
	DB 27,52,77
	DB 45,64,77
	DB 70,70,70
	
LON11	DB 218		;xb
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON12	DB 215		;Cx5
	DB 3
	DB 58,58,58
	DB 70,70,70
	DB 95,95,95
	
LON13	DB 213		;tv
	DB 2
	DB 8,39,64
	DB 39,64,95

LON14	DB 211		;trip
	DB 2
	DB 45,45,45
	DB 70,39,89
	
LON15	DB 209		;car
	DB 2
	DB 8,39,64
	DB 39,64,95
	
LON16	DB 207		;jp
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON17	DB 204		;col. prize
	DB 3	
	DB 58,58,58
	DB 70,70,70
	DB 95,95,95

LON18	DB 201		;spin wheel
	DB 3
	DB 14,33,52
	DB 8,39,64
	DB 27,52,77
	
LON19	DB 199		;spinindikator
	DB 2
	DB 0,58,27
	DB 0,95,0

LON20	DB 197
	DB 2
	DB 0,58,27
	DB 0,95,0

LON21	DB 195
	DB 2
	DB 0,58,27
	DB 0,95,0

LON22	DB 193
	DB 2
	DB 0,58,27
	DB 0,95,0

LON23	DB 191
	DB 2
	DB 0,58,27
	DB 0,95,0

LON24	DB 189
	DB 2
	DB 0,58,27
	DB 0,95,0

LON25	DB 187
	DB 2
	DB 0,58,27
	DB 0,95,0

LON26	DB 185
	DB 2
	DB 0,58,27
	DB 0,95,0
	
LON27	DB 183		;1 billion
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON28	DB 181		;boat
	DB 2
	DB 8,39,64
	DB 39,64,95
	
LON29	DB 179		;house
	DB 2
	DB 45,45,45
	DB 70,39,89
	
LON30	DB 177		;plane
	DB 2
	DB 8,39,64
	DB 39,64,95
	
LON31	DB 175		;mo' money
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON32	DB 173		;money mania
	DB 2
	DB 58,0,0
	DB 95,0,0
	
LON33	DB 170		;x2
	DB 3
	DB 58,58,58
	DB 70,70,70
	DB 95,95,95

LON34	DB 167		;x3
	DB 3
	DB 58,58,58
	DB 70,70,70
	DB 95,95,95

LON35	DB 164		;x4
	DB 3
	DB 58,58,58
	DB 70,70,70
	DB 95,95,95

LON36	DB 161		;x6
	DB 3
	DB 83,52,8
	DB 89,70,33
	DB 89,95,45
	
LON37	DB 158		;x8
	DB 3
	DB 83,52,8
	DB 89,70,33
	DB 89,95,45

LON38	DB 155		;x10
	DB 3
	DB 83,52,8
	DB 89,70,33
	DB 89,95,45

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

MATRIXOFF DB matrixlo
	DB 3
	DB 3 DUP(27*64/100)

;******************************************************************************
;************************* GATES & BYGLARS DATA AREOR *************************
;******************************************************************************
extrn gate1o:byte
extrn gate1c:byte
extrn gate2o:byte
extrn gate2c:byte
extrn gate3o:byte
extrn gate3c:byte
extrn gate4o:byte
extrn gate4c:byte
extrn gate5o:byte
extrn gate5c:byte
extrn gate6o:byte
extrn gate6c:byte,GATE7O,GATE7C,GATE8O,GATE8C

HOLDBONUSFLAG		DB ?

;******************************************************************************
;****************************** DOT MATRIX ************************************
;******************************************************************************
clearit macro
assume ds:data2
dw _animation,_clear
assume	ds:data
endm

;*********************************************************
;******* OBS!!! KOM IHG ATT ASSUMERA ANIMATIONER TILL DATA2 OCH 
;******* SCROLLAR TILL DATA !!!!!
ASSUME	DS:DATA2

BEATENSCROLL	DB 21 DUP (1),'YOU HAVE BEATEN THE HIGHSCORE',21 DUP(1),255
EXTRABALLTEXT	DB 'EXTRA BALL',0

Beaten_bh_TS	LABEL WORD	;I BALL LOST SEKVENSEN
		DW _DOBEATEN,?
		CLEARIT
		DW _JINGLE,S_BEATEN
		DW _LASTJINGLE,EMPTYJINGLE
		DW _SCROLL,BEATENSCROLL
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _WAIT,10*2*15
		CLEARIT
		DW _FLASHOFF,?
		DW _JMP,No_Bonus2TS

BeatenTS	LABEL WORD	;I SPELET
		DW _DOBEATEN,?
		CLEARIT
		DW _JINGLE,S_BEATEN
		DW _SCROLL,BEATENSCROLL
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _WAIT,10*2*5
		CLEARIT
		DW _FLASHOFF,?
		DW 0



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
clearTS		dw _animation,_clear
		dw 0

tomTS		dw _animation,_clear
		dw _wait,32767
		dw 0

ASSUME	DS:DATA

SHOOTTHEBALLTS	LABEL WORD
		CLEARIT
		DW _FLASHON,2
		DW _PARTYONN,?
		DW _PRINT13,SHOOTTHEBALLTEXT,SW*4/4
		DW _PARTYON,?
		DW 0

TVlitTS	label word
	clearit
	dw	_scroll,TVlitTEXT
	dw	0	
TVlitTEXT db 21 dup(1),'THE TV IS LIT',21 DUP(1),255
TRIPlitTS label word
	clearit
	dw	_scroll,TRIPlitTEXT
	dw	0	
TRIPlitTEXT db 21 dup(1),'YOU CAN ACTUALLY WIN A TRIP',21 DUP(1),255

CARlitTS label word
	clearit
	dw	_scroll,CARlitTEXT
	dw	0	
CARlitTEXT db 21 dup(1),'HOW ABOUT A BRAND NEW CAR',21 DUP(1),255

BOATlitTS label word
	clearit
	dw	_scroll,BOATlitTEXT
	dw	0	
boatLitTEXT db 21 dup(1),'PLAY WELL AND WIN A BOAT',21 DUP(1),255
HOUSElitTS label word
	clearit
	dw	_scroll,HOUSElitTEXT
	dw	0	
HOUSElitTEXT db 21 dup(1),'THE HOUSE CAN BE YOURS',21 DUP(1),255

PLANElitTS label word
	clearit
	dw	_scroll,PLANElitTEXT
	dw	0	
PLANElitTEXT db 21 dup(1),'YOU CAN WIN A PRIVATE JET',21 DUP(1),255

RMTEXT DB '  RAISING MILLIONS',0
rmTS	LABEL WORD
	CLEARIT
	DW _RULLGARDIN_UPP,rmTEXT,1
	DW _WAIT,40 ;CPW!
	DW _CLEAR2
	DW _PRINT13_NUMBER_CENT,RM,SW*4/4+TOTCENT
	DW _FLASHON,2
	DW _WAIT,60
	DW _FLASHOFF,1
	DW _CLEAR3
	DW 0
ASSUME DS:DATA2
millionTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_MILLION
	DW _ANIMATION,_CLEAR
	DW 0
BillionTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_BILLION
	DW _ANIMATION,_CLEAR
	DW 0
liteprize_rightTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_liteprize_right
	DW _ANIMATION,_CLEAR
	DW 0
liteprize_leftTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_liteprize_left
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx2TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x2
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx3TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x3
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx4TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x4
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx6TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x6
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx8TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x8
	DW _ANIMATION,_CLEAR
	DW 0
_bonusx10TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_multiply
	dw _animation,_x10
	DW _ANIMATION,_CLEAR
	DW 0
cashpotTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_cashpot
	DW _ANIMATION,_CLEAR
assume ds:data
	dw _print13_number_cent,cashpotval,SW*4/4+TOTCENT
	dw _flashon,1
	dw _wait,60
	dw _flashoff,1
assume ds:data2
	clearit
	DW 0
cashpot5TS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_cashpot5
	DW _ANIMATION,_CLEAR
assume ds:data
	dw _print13_number_cent,cashpot5val,SW*4/4+TOTCENT
	dw _flashon,1
	dw _wait,60
	dw _flashoff,1
assume ds:data2
	clearit
	DW 0
jackpotTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_jackpot
	DW _ANIMATION,_CLEAR
	DW 0
youwinTVTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_TV_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2
youwinTRIPTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_TRIP_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2
youwinCARTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_CAR_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2

youwinBOATTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_BOAT_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2
youwinHOUSETS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_HOUSE_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2
youwinPLANETS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_youwin
	DW _ANIMATION,_CLEAR
ASSUME DS:DATA
	DW _SCROLL,A_PLANE_TEXT
	DW _END_OF_SPIN,?
	DW 0
ASSUME DS:DATA2
_xtraballTS LABEL WORD
	DW _ANIMATION,_CLEAR
	DW _ANIMATION,_xtraball
	DW _ANIMATION,_CLEAR
	DW 0
ASSUME DS:DATA

skillshotTS label word
	clearit
	dw _flashon,1
	dw _number,skillcounter
	dw _wait,50	;cpw!
	dw _flashoff,1
	clearit
	dw _flashon,5
	dw _print8,skilltext,sw*2*5/4+16*0/4
	dw _wait,80	;cpw!
	dw _flashoff,1
	CLEARIT
	dw 0
skilltext db '  MONEY MANIA AT ',6+'7',' ',0
skillshotXBTS label word
	clearit
	dw _flashon,1
	dw _number,skillcounter
	dw _wait,50	;cpw!
	dw _flashoff,1
	clearit
	dw _flashon,5
	dw _print8,XB_TEXT,sw*2*5/4+16*0/4
	dw _wait,80	;cpw!
	dw _flashoff,1
	CLEARIT
	dw 0
xb_text db '89 LITES EXTRA BALL',0
flashmatrixTS label word
	dw _flashon,8
	dw _wait,75
	dw _flashoff,1
	dw _wait,30000
	dw 0
rensaTS label word
	clearit
	dw 0
rensa2TS label word
	clearit
	dw _wait,30000
	dw 0
spinTS	label word
		dw _print13_number
SPINscoreptr	dw offset spinscores
		dw SW*4/4+16*2/4
	dw _wait,30000
	dw 0



Turbo2TS	dw _animation,_clear
		DW _ANIMATION,_moneyM
		DW _ANIMATION,_CLEAR
		DW _SCROLL,ALLloopTEXT
		dw _jmp,initurboTS
		
turboTS		dw _animation,_clear
		DW _ANIMATION,_moneyM
		DW _ANIMATION,_CLEAR
		DW _SCROLL,ALLTARGETTEXT
initurboTS	dw _animation,_clear
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		dw _countdown,2,5,tm_total ;(the final?)
		dw _animation,_clear
TurboMode_endingTS Label Word
		DW _JBCDZ,TM_TOTAL,no_tmTS
		assume	ds:data
		dw _rullgardin_upp,tm_total_text,1
		DW _LIGHTFLASH,32
		assume	ds:data2
		dw _wait,60		;CPW!
		
		dw _animation,_clear
		DW _FLASHON,1
		assume	ds:data
		DW _PRINT13_NUMBER,tm_total,SW*4/4+16*2/4 ;CP! RUTCENT
		assume	ds:data2
		dw _wait,80		;CPW!
		DW _FLASHOFF,1
		dw _animation,_clear
		dw _TurnOffSpecialMode,?
		dw 0
no_tmTS		DW _PRINT13,NO_tm_TEXT,SW*4/4
		ASSUME	DS:DATA2
		dw _wait,80		;CPW!
		CLEARIT
		dw _TurnOffSpecialMode,?
		DW 0


go_for_nisse_text db '   MONEY MANIA      ',0
tm_total_Text	db '  MONEY MANIA TOTAL',0
alltargetTEXT	db 21 dup(' '),'ALL TARGETS SCORE 500000',21 DUP(' '),255
allloopTEXT	db 21 dup(' '),'ALL LOOPS SCORE 1000000',21 DUP(' '),255
A_TV_TEXT	db 21 dup(' '),'A 72 INCH TV WITH NO COMMERCIALS',21 DUP(' '),255
A_CAR_TEXT	db 21 dup(' '),'A SUPER TURBO EXTRA MEGA COOL CAR',21 DUP(' '),255
A_TRIP_TEXT	db 21 dup(' '),'A TRIP TO BEAUTIFUL SWEDEN',21 DUP(' '),255
A_BOAT_TEXT	db 21 dup(' '),'A NICE 5 MILLION DOLLAR BOAT',21 DUP(' '),255
A_HOUSE_TEXT	db 21 dup(' '),'A HUGE 50 ROOM MANSION',21 DUP(' '),255
A_PLANE_TEXT	db 21 dup(' '),'THE PRIVATE JET WITH CREW',21 DUP(' '),255
COMMENT\
Price4ATS		String	3,16,16,"_PLAY_WELL_AND_WIN_A_BOAT_"
Price5ATS		String	3,16,16,"_THE_HOUSE_CAN_BE_YOURS_"
Price6ATS		String	3,16,16,"_YOU_CAN_WIN_THE_PRIVATE_JET_"
Price4TS		String	3,16,16,"_A_NICE_µ00°000_DOLLAR_BOAT_"
Price5TS		String	3,16,16,"_A_HUGE_50_ROOM_MANSION_"
Price6TS		String	3,16,16,"_THE_PRIVATE_JET_WITH_CREW_"
\
		ASSUME	DS:DATA
no_tm_text	db '      NO BONUS',0
tm_total	db ?,?,?,?,?,?,?,?,?,?,?,?




;***********************  NYA BALL LOST *******************

ASSUME	DS:DATA
show_cyclones_text	db '    SKILLS X ',0
show_or_text	db ' MONEY MANIA TOTAL',0



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
		CLEARIT	;CP! CLEARIT ŽR ON™DIGT BRUTAL!
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
		DW _PRINT5_NUMBER,CYCLONECOUNTERBCD,SW*1*2/4-16*10/4
		DW _PRINT5_number,HUNDRATUSEN,SW*1*2/4+13*8/4
		DW _PRINT5,show_CYCLONES_TEXT,SW*1*2/4-16*1/4
		DW _PRINT8_NUMBER_CENT,CYCLONESCOREBCD,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
		CLEARIT
no_cyclonesTS	LABEL WORD
		DW _JBCDZ,TM_TOTAL,no_happy_stewartTS
		CLEARIT
		DW _CALC_HAPPY	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5,show_or_TEXT,SW*1*2/4+16/4/2
		DW _PRINT8_NUMBER_CENT,TM_TOTAL,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		dw _Sound_Effect,s_MultiLjud,0
		CLEARIT
		
no_happy_stewartTS LABEL WORD

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
		dw _waitifmulti,2*60 ;cpgnu? (visa poeng lite lengre)
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


out_of_ballsTS	LABEL WORD		;Žr Stewarts fortfarande borta kanske?
		CLEARIT
		dw _matrixlgt,1
		dw _knacket,?
		DW _SETDECCOR,120
		DW _WAITJINGLE2,?
check_xxballTS LABEL WORD
		DW _check_xxballs	;utf”r ev xxballs, hoppar sedan till after_xxballs!

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

;********************** SLUT P BALL LOST *******************

showithi	macro
		DW _PRINT13,ALLTIME_TEXT,SW*2/4*2+16/4/2
		dw _wait,40

		CLEARIT
		
		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_1,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*0),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*0+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		clearit

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_2,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*1),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*1+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		clearit

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_3,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*2),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*2+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		clearit

		DW _FLASHOFF,1
		DW _MATRIXLGT,0
		DW _PRINT13,hi_4,SW*2/4*2
		DW _PRINT13_NUMBER,(offset hi_score_list+(12+3+1)*3),4*SW/4+8*16/4
		DW _PRINT13,(offset hi_score_list+(12+3+1)*3+12),SW*2/4*2+2*16/4
		DW _FLASHON,1
		dw _wait,140
		clearit
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
;		DW _FLASHON,1
		DW _SCROLL,PL_TEXT
;		dw _wait,40
;		DW _FLASHOFF,1
;SCROLLA
		clearit
		DW _SCROLL,SCROLL_TEXT1
;VISA HIGHSCORE
		showithi
;DI UPP  NED!
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


tiltTS		LABEL WORD
		CLEARIT
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

GETTING_SICK_TEXT DB '    FALLING DOWN',0

PARTY_ON_TEXT DB 'PLAY MORE - PLAYER X',0
ZEROQ		DB '0'+7,0
SHOOT_AGAIN_TEXT DB 'SHOOT AGAIN PLAYER  ',0
SHOOTTHEBALLTEXT DB 'SHOOT THE BALL  PL ?',0

NO_OF_PLAYERS_TEXT DB 'PLAYERS X',0
NOLLA		DB '7',0
show_bonus_TEXT DB 'BONUS',0
show_totalbonus_TEXT DB 'TOTAL*BONUS',0
BONUS_X_TEXT 	DB 'BONUS*X*??',0

fld_TEXT	DB '  FRONTLINE DESIGN',0
		
PF_TEXT		DB '  PINBALL FANTASIES',0
TRS_TEXT	DB ' THE REAL SIMULATOR',0
PL_TEXT		DB 21 DUP (' '),'BILLION DOLLAR GAMESHOW',21 DUP (' '),255
SCROLL_TEXT1	DB 21 DUP (' '),'ADD PLAYERS WITH F1 TO F8',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' '),255		
ALLTIME_TEXT	DB 'ALL TIME HIGHSCORES',0
SCROLL_TEXT2	DB 21 DUP (' '),'FLIP WITH LEFT AND RIGHT ALT SHIFT OR CTRL KEYS',21 DUP (' ')
		DB 'PUSH TABLE WITH SPACE',21 DUP (' ')
		DB 'CONTROL SPRING WITH DOWN ARROW KEY','    ESC EXITS',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS    ',21 DUP (' ')
		DB 255
COMMENT\
PF_TEXT		DB '  PINBALL FANTASIES',0
TRS_TEXT	DB ' THE REAL SIMULATOR',0
PL_TEXT		DB '    PARTY LAND',0
SCROLL_TEXT1	DB 21 DUP (' '),'ADD PLAYERS WITH F1 TO F8 OR ENTER',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' '),255		
ALLTIME_TEXT	DB ' ALL TIMES HIGHSCORE',0
SCROLL_TEXT2	DB 21 DUP (' '),'FLIP WITH LEFT AND RIGHT ALT SHIFT OR CTRL KEYS',21 DUP (' ')
		DB 'PUSH TABLE WITH SPACE',21 DUP (' ')
		DB 'CONTROL SPRING WITH DOWN ARROW KEY OR MOUSE',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' ')
		DB 'P PAUSES GAME AND M TOGGLES INGAME MUSIC ON AND OFF',21 DUP (' ')
		DB 'ESC EXITS AND SAVES NEW HIGHSCORES',21 DUP (' '),255
\			
DIGITAL_TEXT	DB '  DIGITAL ILLUSIONS',0

JACK_TEXT	DB 'JACKPOT IS',0
BONUS_TEXT	DB ' YOU HAVE  XX BONUS',0	;10
PLAY_TEXT	DB ' PLAYER 8    BALL 8 ',0	;8,18

INFO_TEXT	DB 21 DUP (' ')
		db ''
		DB 21 DUP (1),255

playerstext	db 'PLAYER 8',0		;8=1 (L™S EKVATIONEN!)
BALLSTEXT	DB 'BALL 8',0		;8=1

hajjskar	db 'HIGHSCORE PL X ',92,'   ',93,0
stjaernor	db '********************',0

;******************************************************************************

DATA	ENDS







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

RESET_VARS PROC NEAR
	NIL	AX
	MOVE	ES,DS
	MOV	DI,OFFSET SIFFRORNA
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET TM_TOTAL
	MOV	CX,6
	REP	STOSW
	
	MOV	BALLHIGH,FALSE

	MOVEBCD	CASHPOTVAL,_500K


	MOV	TVFLAG,FALSE
	MOV	TRIPFLAG,FALSE
	MOV	CARFLAG,FALSE
	MOV	BOATFLAG,FALSE
	MOV	PLANEFLAG,FALSE
	MOV	HOUSEFLAG,FALSE

	MOV	TVCOUNTER,0
	MOV	TRIPCOUNTER,0
	MOV	CARCOUNTER,0
	MOV	BOATCOUNTER,0
	MOV	PLANECOUNTER,0
	MOV	HOUSECOUNTER,0

	MOV	BILLION_ENABLED,FALSE
	
	mov	bonusmultiplier,0
	MOV	BONUS_X,1
	MOV	WORD PTR BONUS_TEXT[10],'8 '
	CALL	RESETFLASHLIST
	CALL	SLACK_LIGHTS
;	CALL	KILL_FLASHOR			;DOT MATRIX FLASH RESET
	call	closegate1
	
	lighton	7		;sl„pp upp brickorna
	call	closegate3
	lighton	8
	call	closegate4
	lighton	9
	call	closegate5
	lighton	10
	call	closegate6

	endflash 1		
	lightflash 1,15	;blinka med skill-lampan (ska det ligga h„r?)

;HŽR VAR DEN! ;	mov	paRTYFLASh,false

	RETN
RESET_VARS ENDP

WHEN_NEW_GAME_RESET_TABLE:
	MOV	XxballE,FALSE
	MOVA	ES,DS
	MOV	DI,OFFSET CYCLONECOUNTERBCD
	MOV	CX,12/2
	NIL	AX
	REP	STOSW
	MOV	CYCLONECOUNTER,0
	
	MOV	TOP_THREE,FALSE
	MOV	ALL_SIX,FALSE
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	CALL	RESET_VARS
	CALL	UPDATE_P_STRUC_4_ALL_PLAYERS
	CALL	INITJACK
		;cleara slutsiffrorna (di alla!) (F”r knacket allts†!!!)
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
;	CALL	KILL_FLASHOR			;DOT MATRIX FLASH RESET
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	CALL	RESET_VARS
	CALL	P_STRUC_2_VARS
	CALL	closeGATE7
	CALL	closeGATE8
	RETN


;******************************************************************************



DEMO_MUSIC PROC NEAR
	CMP	HIGHSCORE,TRUE
;	JE	OOPS_HIGH ;CP!
	PLAYJINGLE S_NOHIGH
	MOV	AL,S_NOHIGH[2]
	MOV	LASTPRIORITY,AL
	MOV	LASTJINGLE,9 ;9=NOHIGH ;SVEN
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
	SETBALLPOS 135,28,0,0,FALSE	;CP!!!!!!! LŽGG BOLLEN P BŽTTRE STŽLLE
	mov	holdstill,true
	MOV	ALLOWFLIP,FALSE	;KILL FLIPPERS!

	MOV	SPECIALMODE,FALSE

	MOV	CURRENT_PRIORITY,0
	EFFECT	LOSTBALL	
	MOV	LASTJINGLE,emptyjingle
	ADDTASK SOUNDRINNER
	RETN

SOUNDRINNER:
	WAITSYNCS 5
	SOUNDEFFECT SRINNER,0
	SUICIDE

_FLORPA:
	MOV	CS:LB6CNT,0			;RESET F™RDR™JNINGS-RŽKNAREN
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
	mov	bx,336*2/4+(320-12*16)/4	;h”ger justerad!
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
	DEC	BYTE PTR [BX]			;RŽKNA NED BONUSEN
	JNZ	NO_WAITS_TODAY
	
	IFZEROBCD BONUSSIFFRORNA
	JNC	NO_WAITS_TODAY

	MOV	CS:LB6CNT,-10 ;CPW!
NO_WAITS_TODAY:

	MOV	SI,ADDORPEK			;RŽKNA UPP POŽNGEN
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD

	SOUNDEFFECT S_SCORELJUD,0

	JMP	STEP_DONE

DIGIT_IS_ZERO:
	;FLER SIFFROR?
	INC	ADDORPEK			;NEXT DIGIT IN POŽNGEN
	CMP	ADDORPEK,OFFSET ADDOR+12
	JE	NO_MORE_NUFFROR
	DEC	BONUSPEK			;NEXT DIGIT IN BONUS
	JMP	DO_IT_AGAIN_AND_DO_IT_NOW

STEP_DONE:
	;SHOW BONUSSIFFRORNA & SIFFRORNA
	MOV	SI_siffror,OFFSET BONUSSIFFRORNA
	MOV	DI_siffror,7*2*SW/4-16*4/4	;10 RADER NED, 8 (12-4) TECKEN IN P RADEN!!
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
	retn				;f„rdig!
	
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
	add	di,12+3+1		;12 nuffror, 3 bokst„ver
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
;di pekar d„r namnet ska petas in!!
	mov	cs:nof_chars_to_read,3
	mov	cs:place_hi,di
	mov	scan_code,-1		;l„s ev. tidigare tangenttryck!
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
	je	kvar_svar	;ej tryckt!
	mov	scan_code,-1
	mov	bx,offset alfa_keys
	xlat
	cmp	al,0
	je	kvar_svar	;felaktigt tecken!
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
	stosb		;skriv te sk„rm texten . . 
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
	rep stosb		;skriv te sk„rm texten . . 
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



SHOWER	DB ?
player_adr	dw ?
_INIT_SCORE:
	mov	cs:player_adr,0
	sub	cs:player_adr,size player_struc
	MOV	PLAYERSTEXT[7],0+'7'
	MOV	AL,PLAYERS
	MOV	CS:SHOWER,AL
	inc	CS:SHOWER
	
	MOV	SISA,1
	mov	dotrut,offset WAITRUT
	jmp	normal_end	
_SHOW_SCORE:
	INC	PLAYERSTEXT[7]
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

	mov	bx,336*2/4+(320-12*16)/4	;h”ger justerad!
	MOVE	ES,CS
	CALL	DWORD PTR ES:PEKOR
	MOV	SI,0
	RETN
_END_OF_SPIN:
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	PUSH	BX
	ADDTASK	END_OF_SPIN
	POP	BX
	JMP	NORMAL_END

_TurnOffSpecialMode:
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	mov	specialmode,false
	PUSH	BX
	ENDFLASH 32
	LIGHTOFF 32	;CP!?	(SLŽCK MONEYMANIA-LAMPAN)
	POP	BX
	mov	current_priority,0
	jmp	Normal_End
_LIGHTFLASH:
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	PUSH	BX
	LIGHTFLASH 32,3
	POP	BX
	jmp	Normal_End

_knacket:
	mov	dotrut,offset knackrut1
	mov	sisa,1
	MOV	PLAYER,1		;F™R CHECK_XXBALL
	jmp	normal_end	


;tid mellan knack samt antal knack . . . 
	knacktid=14 ;12	;CPW!
	nof_banks=15	;CPW!

knackrut1:
	PLAYJINGLE_PENETRATE S_endfig
	MOV	LASTJINGLE,62		;TYST EFTER FULLGJORD PENETRERING
	mov	dotrut,offset knackrut2
;g”r text me sista nuffrerna!!
	mov	cl,players
	nil	ch
	mov	di,offset last_text
	mov	ah,' '
	mov	bx,10	;n„st sista!
	LEA	SI,PLAYER_AREA[BX].P_SIFFRORNA
	push	es
	move	es,data
	mov	bx,0
make_last:
	mov	al,ds:[si]
	add	si,size player_struc
	add	al,'7'
	stosw
	mov	word ptr offset [flashlast+bx],ax	;kopiera texten f”r senare blink

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


	mov	si,nof_banks
	mov	sisa,nof_banks
	mov	cs:timglas,knacktid
	retn
timglas	dw ?
knackrut2:
	dec	cs:timglas
	jz	no_ret
	ret
no_ret:	
	push	si
	mov	cs:timglas,knacktid
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
	;resten i de„ks e mellan n†ll † NI
	CMP	LAST_POS,DX
	JNE	ITS_ALRIGHT
	NEG	DX
	ADD	DX,9
ITS_ALRIGHT:
	mov	last_pos,dx
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
		
;kolla om siffrorna st„mmer f”r n†en . . .
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

;Om javisst, spela glad gnu † flasha!
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

_CHECK_XXBALLS:		;OBS! TV INGNGAR TILL DENNA RUTIN
			;INPUT: LAST_TEXT, LAST_POS, PLAYER, PLAYERS
			;OUTPUT: FT_PEKARE, PLAYER
TESTNEXTPL:
	PUSH	BX
	
	MOV	BL,PLAYER
	NIL	BH
	SHL	BX,1
	ADD	BX,OFFSET LAST_TEXT-2	;bx pekar p† spelare n's slutsiffra
	
	MOV	AL,[BX]
	MOV	WORD PTR [BX],'XX'	;DESTROY HIM MY ROBOTS!
	SUB	AL,'7'
	NIL	AH

	POP	BX

	CMP	LAST_POS,AX
	JE	THIS_ONE		;HAN SKA F XXBALL!!!

	INC	PLAYER			;INGEN XXBALL F™R HONOM!
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

	CMP	LIGHTSTATUS[31],TRUE		;LAUGH AGAIN?
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
	pop	bx
	CMP	LIGHTSTATUS[31],TRUE		;LAUGH AGAIN?
	JE	LET_HIM_SHOOT_AGAIN
	push	bx
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
PLAYER_CHANGED:

	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	PLAYERSTEXT[7],AL

	ADDTASK	NEW_BALL_TASK			;TO GAME FROM GAME
	POP	BX

HU_:	ADD	BX,2		;TASKSYTEM, HOPPA TILL NŽSTA/AVSLUT
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_7
	MOV	BX,0
	MOV	NEXT_A,BX
	RETN
_NEXTp_7:
	MOV	NEXT_A,BX
	JMP	[BX]

;GNUERNA
LET_HIM_SHOOT_AGAIN:		;2 INGNGAR!
	MOV	BX,OFFSET shoot_again_onTS
	MOV	NODOTCOUNT,0
	UPDAT_SCORE
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
;	CALL	DEMO_MUSIC	;CP! DET SKALL REDAN VARA GJORT!
	call	zeroscore
	CALL	SLACK_LIGHTS
	MOV	ADDPLAYERS,TRUE
	SUICIDE




;TUBORG!


COMMENT\
	;CP! RENSA MATRIX OCH RITA SLUTSIFFROR!
	ADDTASK KNACK_SEKVENS
	SUICIDE

KNACK_SEKVENS:
	;CP! KNACKA!
KNACK_KLART:
;	ADDTASK LYCKY_GUY ;CP! OM NGON FICK EN X-BALL
	ADDTASK	AFTER_KNACK
	SUICIDE

AFTER_KNACK:
	;CP! KOLLA OM NN FICK HIGHSCORE!
HIGH_READY:
	ADDTASK SHOW_SCORES
	SUICIDE

SHOW_SCORES:	;NOTE: TRIGGED BY AFTER_KNACK--- AND SHOW_GAME_OVER---
	;CP! RŽKNARE1 = 0: KOLLA OM ALLA VISADE 2 GGR.
	;                   VISA SEDAN POŽNG F™R SPELARE (SPELARE-RŽKNARE).
	;             = CA 2*60: ADDTASK SHOW_GAME_OVER.
;	ADDTASK SHOW_GAME_OVER
	ADDTASK TO_DEMO_FROM_GAME
	SUICIDE

SHOW_GAME_OVER:
	;CP! VISA "GAME OVER"
	ADDTASK SGO_TASK2
	SUICIDE

SGO_TASK2:
	WAITSYNCS 45 ;CPW!
	ADDTASK SHOW_SCORES
	SUICIDE
\

LOOSE_BALL ENDP



;******************************** NEW_BALL ************************************

NEW_BALL_TASK:
	WAITSYNCS 60
	CALL	NEW_BALL
	RETN	;PGA NEWBALL

NEW_BALL PROC NEAR	;ENDA SŽTTET ATT F UT EN BOLL P BANAN!
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
	PLAYJINGLE S_SPRING
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
;	UPDAT_INFOBAR	;CP? JOHAN FR FIXA DETTA!
	CMP	I_UTSKJUT,FALSE
	JE	TA_BORT_MEJ
	RETN
TA_BORT_MEJ:
	SUICIDE


P_STRUC_2_VARS PROC NEAR	;INPUT:PLAYER
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA

	MOVEBCD	SIFFRORNA,PLAYER_AREA[BX].P_SIFFRORNA
	MOVEBCD	BONUSSIFFRORNA,PLAYER_AREA[BX].P_BONUSSIFFRORNA
	MOVEBCD	CYCLONECOUNTERBCD,PLAYER_AREA[BX].P_CYCLONECOUNTERBCD
	MOVA	CYCLONECOUNTER,PLAYER_AREA[BX].P_CYCLONECOUNTER
	MOVAL	TOP_THREE,PLAYER_AREA[BX].P_TOP_THREE
	MOVAL	ALL_SIX,PLAYER_AREA[BX].P_ALL_SIX
	CMP	TOP_THREE,FALSE
	JE	NO_PRIZES
	MOV	TVFLAG,2
	MOV	TRIPFLAG,2
	MOV	CARFLAG,2
	LIGHTON 13
	LIGHTON 14
	LIGHTON 15
	CMP	ALL_SIX,FALSE
	JE	NO_PRIZES
	MOV	BOATFLAG,2
	MOV	HOUSEFLAG,2
	MOV	PLANEFLAG,2
	LIGHTON 28
	LIGHTON 29
	LIGHTON 30
NO_PRIZES:	
	RETN
P_STRUC_2_VARS ENDP


VARS_2_P_STRUC PROC NEAR	;INPUT: PLAYER
				;2 ENTRIES TO THIS RUT
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA
VARS_2_P_STRUC_2:		;USED BY WHEN_NEW_GAME_RESET!
	MOVEBCD	PLAYER_AREA[BX].P_SIFFRORNA,SIFFRORNA
	MOVEBCD	PLAYER_AREA[BX].P_BONUSSIFFRORNA,BONUSSIFFRORNA
	MOVEBCD	PLAYER_AREA[BX].P_CYCLONECOUNTERBCD,CYCLONECOUNTERBCD
	MOVA	PLAYER_AREA[BX].P_CYCLONECOUNTER,CYCLONECOUNTER
	MOVAL	PLAYER_AREA[BX].P_TOP_THREE,TOP_THREE
	MOVAL	PLAYER_AREA[BX].P_ALL_SIX,ALL_SIX
	RETN
VARS_2_P_STRUC ENDP



;******************************** TILT TILT TILT *****************************
HE_TILTED PROC NEAR
	MOV	ALLOWFLIP,FALSE
	PLAYJINGLE S_TILT	
	MOV	LASTJINGLE,EMPTYJINGLE
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

NO_SHIFT:
	RETN
CHECK_SHIFTKEYS ENDP



;******************************** GATES ROUTINES ******************************
opengate1:
	mov	si,offset gate1o
	jmp	gogate1
closegate1:
	mov	si,offset gate1c
gogate1:
	mova	es,mask2_2
	mov	di,40*96
	mov	cx,25
	mov	dx,3
	call	MOVE_mask_DATA
	retn

opengate2:
	mov	si,offset gate2o
	jmp	gogate2
closegate2:
	mov	si,offset gate2c
gogate2:
	mova	es,mask1_2
	mov	di,40*305+272/8+1
	mov	cx,34
	mov	dx,2
	call	MOVE_mask_DATA
	retn
opengate3:
	mov	si,offset gate3o
	jmp	gogate3
closegate3:
	mov	si,offset gate3c
gogate3:
	mova	es,mask1_2
	mov	di,136/8+40*227
	mov	cx,16
	mov	dx,2
	call	MOVE_mask_DATA
	retn
opengate4:
	mov	si,offset gate4o
	jmp	gogate4
closegate4:
	mov	si,offset gate4c
gogate4:
	mova	es,mask1_2
	mov	di,136/8+40*247
	mov	cx,16
	mov	dx,1
	call	MOVE_mask_DATA
	retn
opengate5:
	mov	si,offset gate5o
	jmp	gogate5
closegate5:
	mov	si,offset gate5c
gogate5:
	mova	es,mask1_2
	mov	di,32/8+266*40
	mov	cx,16
	mov	dx,1
	call	MOVE_mask_DATA
	retn
opengate6:
	mov	si,offset gate6o
	jmp	gogate6
closegate6:
	mov	si,offset gate6c
gogate6:
	mova	es,mask1_2
	mov	di,24/8+286*40
	mov	cx,16
	mov	dx,2
	call	MOVE_mask_DATA
	retn
opengate7:
	mov	si,offset gate7o
	jmp	gogate7
closegate7:
	mov	si,offset gate7c
gogate7:
	mova	es,mask2_2
	mov	di,22+163*40
	mov	cx,20
	mov	dx,4
	ADD	SI,DX
	call	MOVE_mask_DATA_b
	retn

opengate8:
	mov	si,offset gate8o
	jmp	gogate8
closegate8:
	mov	si,offset gate8c
gogate8:
	mova	es,mask1_2
	mov	di,511*40
	mov	cx,14
	mov	dx,4
	ADD	SI,DX
	call	MOVE_mask_DATA_b
	retn

dropb1:
	CALL	ADDMONEY
	CMP	LIGHTSTATUS[7],FALSE
	JE	DUMRET
	EFFECT	TOUCHB
	soundeffect s_touch2,0
	call	opengate3
	lightoff 7
	CMP	LIGHTSTATUS[8],FALSE
	JNE	DUMRET
	ADDTASK	UP_B
	retn
dropb2:
	CALL	ADDMONEY
	CMP	LIGHTSTATUS[8],FALSE
	JE	DUMRET
	EFFECT	TOUCHB
	soundeffect s_touch2,0
	call	opengate4
	lightoff 8
	CMP	LIGHTSTATUS[7],FALSE
	JNE	DUMRET
	ADDTASK	UP_B
	retn
UP_B:	WAITSYNCS 60
	SOUNDEFFECT SBRICKUPP,0
	LIGHTON 7
	LIGHTON 8
	CALL	CLOSEGATE3
	CALL	CLOSEGATE4
	SUICIDE	
dropC1:
	CALL	ADDMONEY
	CMP	LIGHTSTATUS[9],FALSE
	JE	DUMRET
	EFFECT	TOUCHC
	soundeffect s_touch2,0
	call	opengate5
	lightoff 9
	CMP	LIGHTSTATUS[10],FALSE
	JNE	DUMRET
	ADDTASK	UP_C
	retn
dropC2:
	CALL	ADDMONEY
	CMP	LIGHTSTATUS[10],FALSE
	JE	DUMRET
	EFFECT	TOUCHC
	soundeffect s_touch2,0
	call	opengate6
	lightoff 10
	CMP	LIGHTSTATUS[9],FALSE
	JNE	DUMRET
	ADDTASK	UP_C
	retn
UP_C:	WAITSYNCS 60
	SOUNDEFFECT SBRICKUPP,0
	LIGHTON 9
	LIGHTON 10
	CALL	CLOSEGATE5
	CALL	CLOSEGATE6
	SUICIDE	
;************************* SUPER MODES CHECKS *********************************



;******************************************************************************
;***************************** BRICKOR & KNAPPAR ******************************
;******************************************************************************
dropa1:
	CALL ADDMONEY
	soundeffect s_touch2,0
	cmp	lightstatus[3],true
	je	doret1
	lightflash 2,6
	mov	lightstatus[2],true
	addtask flasha2
	effect	dollartouch
	retn	
dropa2:
	CALL	ADDMONEY
	soundeffect s_touch2,0
	cmp	lightstatus[2],true
	jne	doret2
doret1:	lightflash 2,2
	lightflash 3,2
	addtask	flasha23
	effect	dollartouch2
	endflash 18
	invertedsyncedflash 18,sfspeed,syncflasher
	mov	lightstatus[18],true
	call	opengate1	;open gate to spin wheel
	retn
doret2:	lightflash 3,6
	mov	lightstatus[3],true
	addtask flasha3
	effect	dollartouch
	retn	
flasha2:
	waitsyncs 25
	endflash 2
	lighton 2
	suicide
flasha3:
	waitsyncs 25
	endflash 3
	lighton 3
	suicide
flasha23:
	waitsyncs 60
	endflash 2
	lightoff 2
	endflash 3
	lightoff 3
	suicide



;******************************************************************************
;********************************** LOWER *************************************
;******************************************************************************


;*********************************** GAME ON **********************************

CLOSE1:					;GAME ON
	CMP	LASTAREA,OFFSET open1
	JNE	NOT_GAME_ON
	call	closegate2
	MOV	ADDPLAYERS,FALSE
	PLAYJINGLE S_MAIN
	MOV	LASTJINGLE,1
	MOV	BX,OFFSET PARTY_OFFTS
	CALL	DO_MATRIX
	MOV	I_UTSKJUT,FALSE		;TILLTER INACTIVE-SLINGAN (DOTMATRIX)
	MOV	PARTYFLASH,FALSE
NOT_GAME_ON:
	RETN

close4:
	call	closegate8
	retn

;***************************** SPRING INVALID *********************************

open1:				;SPRING INVALID
	MOV	SPRING_VALID,FALSE
	call	opengate2
	RETN


;******************************* SPRING VALID *********************************

BYGEL28:				;SPRING VALID
	MOV	SPRING_VALID,TRUE
	RETN
;******************************************************************************
GOT_THE_BILLION:
	MOV	BILLION_ENABLED,FALSE
	EFFECT	BILLION
	ENDFLASH 27
	LIGHTFLASH 27,4
	ADDTASK	TURNOFF_BILLION
	mov	holdstill,TRUE
	setballpos 4,529,0,0,false
	RETN
TURNOFF_BILLION:
	waitsyncs 5*50 ;cpw!
	ENDFLASH 27
	LIGHTOFF 27
	LIGHTOFF 13
	LIGHTOFF 14
	LIGHTOFF 15
	LIGHTOFF 28
	LIGHTOFF 29
	LIGHTOFF 30
	MOV	TVFLAG,FALSE
	MOV	TRIPFLAG,FALSE
	MOV	CARFLAG,FALSE
	MOV	BOATFLAG,FALSE
	MOV	PLANEFLAG,FALSE
	MOV	HOUSEFLAG,FALSE
	MOV	TOP_THREE,FALSE
	MOV	ALL_SIX,FALSE

	mov	y_hast,-3500
	SOUNDEFFECT SNEWBALL,0
	MOV	HOLDSTILL,FALSE

	SUICIDE
DONT_NOW:
	mov	holdstill,TRUE
	setballpos 4,529,0,0,false
	ADDTASK	SLAPP_HONOM
	RETN		
SLAPP_HONOM:
	WAITSYNCS 30
	mov	y_hast,-3500
	SOUNDEFFECT SNEWBALL,0
	MOV	HOLDSTILL,FALSE
	SUICIDE
	
gropB:	call	opengate8
	CMP	SPECIALMODE,TRUE
	JE	DONT_NOW
	CMP	TILTFLAG,TRUE
	JE	DONT_NOW
	CMP	BILLION_ENABLED,TRUE
	JE	GOT_THE_BILLION		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	mov	holdstill,true
	cmp	lightstatus[17],0
	jnz	noclose1
	call	closegate1	;st„ng till spin wheel
noclose1:
	setballpos 4,529,0,0,false
			;spin wheel (lights 19-26)
	playjingle s_mystery	
	mov	nextspintime,offset SPINtimes_hi
	cmp	hi_res,true
	je	nohej
	mov	nextspintime,offset SPINtimes
nohej:
	mov	bx,nextspintime
	mova	SPINcounter,[bx]
	mov	bx,offset rensa2TS
	call	do_matrix
	mov	al,19
	add	al,spinlight
	lightoff al
	cmp	lightstatus[17],1
	jne	nofusk	
	mov	al,0		;fuska s† att lampan stannar p† r„tt sak!
	cmp	tvflag,1
	je	dosp
	mov	al,1
	cmp	tripflag,1
	je	dosp
	mov	al,2
	cmp	carflag,1
	je	dosp
	mov	al,6
	cmp	boatflag,1
	je	dosp
	mov	al,5
	cmp	houseflag,1
	je	dosp
	mov	al,4
	cmp	planeflag,1
	je	dosp
nofusk:	mov	al,byte ptr slump_countern
dosp:	cmp	hi_res,true
	jne	noth
	sub	al,2
noth:
	mov	spinlight,al
	and	spinlight,7

	MOV	SCREENFORCE2,270
	CMP	HI_RES,TRUE
	JNE	NOTHIRES35
	MOV	SCREENFORCE2,220
NOTHIRES35:

	retn
nextSPIN:
	add	nextspintime,2
	mov	bx,nextspintime
	cmp	word ptr [bx],-1
	je	last_spin
	mova	spincounter,[bx]
	mov	al,19
	add	al,spinlight
	lightoff al
	inc	spinlight
	and	spinlight,7
	mov	al,19
	add	al,spinlight
	lighton al
	mov	al,12
	mul	spinlight
	add	ax,offset spinscores
	mov	spinscoreptr,ax	;addressen till current po„ng
	mov	bx,offset spinTS
	call	do_matrix
	retn
last_spin:
	mov	bx,offset flashmatrixTS
	call	do_matrix
	cmp	lightstatus[17],1
	jne	no_prize_to_collect
	addtask	you_win
	retn
no_prize_to_collect:
	addtask	end_of_spin
	retn
end_of_spin:
	waitsyncs 100	;cpw!
	mov	screenforce2,-1
	cmp	spinscoreptr,offset spinscores
	jne	adds
	mov	spinscoreptr,offset tjufemtusen
adds:
	mov	si,spinscoreptr
	mov	di,offset siffrorna
	call	addscorebcd
	mov	bx,offset rensaTS
	call	do_matrix
	mov	holdstill,false
	mov	y_hast,-3500*TT/NN
	endflash 18
	lightoff 18
	suicide
you_win:
	cmp	top_three,true
	je	gottopthree
	cmp	tvflag,2
	je	won_tv
	endflash 13
	lighton 13
	mov	tvflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinTV
	jmp	endofyw
won_tv:cmp	tripflag,2
	je	won_trip
	endflash 14
	lighton 14
	mov	tripflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinTRIP
	jmp	endofyw
won_trip:
	endflash 15
	lighton 15
	ENDFLASH 17
	LIGHTOFF 17
	mov	CARflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinCAR
	syncedFLASH 16,sfspeed,syncflasher
	MOV	LIGHTSTATUS[16],1	;ENABLE JACKPOT
	MOV	JP_COUNTER,JP_TIME
	mov	top_three,true
	call	closegate1 ;st„ng till spin wheel
	jmp	endofyw
endofyw:
	suicide
gottopthree:	
	cmp	BOATflag,2
	je	won_BOAT
	endflash 28
	lighton 28
	mov	BOATflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinBOAT
	jmp	endofyw
won_BOAT:
	cmp	HOUSEflag,2
	je	won_HOUSE
	endflash 29
	lighton 29
	mov	HOUSEflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinHOUSE
	jmp	endofyw
won_HOUSE:
	endflash 30
	lighton	30 
	ENDFLASH 17
	LIGHTOFF 17
	mov	PLANEflag,2
	MOV	CURRENT_PRIORITY,0
	effect	youwinPLANE
;	LIGHTFLASH 16,10
;	MOV	LIGHTSTATUS[16],1	;ENABLE JACKPOT
;	MOV	JP_COUNTER,JP_TIME
	mov	all_six,true
	call	closegate1	;st„ng till spin wheel
	jmp	endofyw
LOCK_THE_BALL:
	LIGHTON	6
	SYNCEDFLASH 27,SFSPEED,SYNCFLASHER
	EFFECT	SHOOTTHEBALL
	MOV	LASTJINGLE,0	;EFTER BILLION LIT SKA DEN SPELA S_SPRING
	SETBALLPOS STARTX,STARTY,10,0,FALSE
	mov	holdstill,false
	MOV	CURRENT_PRIORITY,0
	MOV	LASTJINGLE,0
	CALL	OPENGATE1	;™PPNA TILL SPIN WHEEL
	MOV	BILLION_ENABLED,TRUE
	RETN	
gropA:	mov	holdstill,true
	CMP	SPECIALMODE,TRUE
	JE	RELEASE_HIM
	CMP	ALL_SIX,TRUE
	JE	LOCK_THE_BALL
	CALL	JACKADD
	cmp	cash5counter,0
	jnz	cash_times_5
	effect	cashpot
go_cashpot:
	addtask	release_ball
	retn
cash_times_5:
	mov	cash5counter,10	;st„ng av cash5lampan
	mov	cx,5
addcash:
	addbcd	cashpot5val,cashpotval
	loop	addcash
	effect	cashpot5
	jmp	go_cashpot
release_ball:
	mov	holdstill,true
	SETBALLPOS 103,233,0,0,FALSE
	waitsyncs 200-40
	lighton	6
	addtask	basil_fawlty
	mova	es,ds
	mov	di,offset cashpot5val
	mov	cx,6
	nil	ax
	rep	stosw
	suicide
basil_fawlty:	;old chap
	waitsyncs 40
	CALL	RELEASE_IT
	suicide
RELEASE_HIM:
	MOV	HOLDSTILL,TRUE
	LIGHTON	6
	ADDTASK	SLAPP2
	RETN
SLAPP2:
	SETBALLPOS 103,233,0,0,FALSE
	WAITSYNCS 30
	CALL	RELEASE_IT
	SUICIDE
RELEASE_IT:
	lightoff 6
	SOUNDEFFECT SGROP,0
	SETBALLPOS 103,233,100*TT/NN,1700*TT/NN,FALSE
	mov	holdstill,false
	RETN
	
bygel5:
	CALL	CASHADD
	CALL	ADDMONEY2
	effect	bygelsetC	;he's on the right ramp
	mov	CARcounter,CAR_time
	call	opengate7
	CMP	JP_COUNTER,0
	JZ	NO_JP2
	MOV	JP_COUNTER,1	;S ATT LAMPAN SLOCKNAR VID NŽSTA DOWNCOUNT
	EFFECT	JACKPOT
	CALL	INITJACK
	MOV	SJP_COUNTER,SJP_TIME
	LIGHTFLASH 5,10
	PLAYJINGLE SJINGLE3
NO_JP2:
	mov	TVcounter,TV_time
	retn
endcash5:
	endflash 12
	lightoff 12
	retn
bygel7:			;clockwise ramp
	CALL	CASHADD
	CALL	JACKADD
	CALL	ADDMONEY2
	effect	bygelsetE
	CMP	SJP_COUNTER,0
	JZ	NO_SJP7
	EFFECT	S_JACKPOT
	MOV	SJP_COUNTER,1	;S ATT DEN SLŽCKS VID NŽSTA DOWNCOUNT
NO_SJP7:
	mov	cash5counter,cash5_time
	endflash 12
	invertedsyncedflash 12,sfspeed,syncflasher	;cash*5 enabled
	CMP	CARCOUNTER,0
	JZ	NOCAR
	cmp	carFLAG,1
	jAE	noCAR
	mov	CARcounter,0
	mov	CARflag,1
	effect	CARlit
	syncedFLASH 15,sfspeed,syncflasher
	cmp	tripflag,0
	jz	dumret
	cmp	tvflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn
noCAR:
	cmp	PLANEflag,0
	jnz	noHOUSE2
	cmp	CARcounter,0
	jz	noHOUSE2
	CMP	TOP_THREE,TRUE
	JNE	NOHOUSE2
	mov	CARcounter,0
	cmp	all_six,true
	je	nohouse2
	jmp	show_where_plane
	
noHOUSE2:
	cmp	MBcounter,0
	jz	RAISING_MILLIONS
	cmp	bonusmultiplier,6
	je	DUMRET
	inc	bonusmultiplier
	MOV	BL,BONUSMULTIPLIER
	NIL	BH
	dec	bl
	SHL	BX,1
	mov	al,current_priority	;GNU
	cmp	al,byte ptr sjingle2+2	;GNU
	ja	noeff			;GNU
	mov	bx,BONUS_ANIMS[BX]
	call	do_matrix
	playjingle sjingle2
noeff:	mov	al,bonusmultiplier
	dec	al
	MOV	BX,OFFSET BONUSTABLE
	XLATB
	MOV	BONUS_X,AL
	CMP	AL,10
	MOV	BONUS_TEXT[10],' '
	JNE	NOTB10
	MOV	BONUS_TEXT[10],'8'
	XOR	AL,AL
NOTB10:
	ADD	AL,'7'
	MOV	BONUS_TEXT[11],AL
	mov	al,bonusmultiplier
	add	al,32
	lighton	al
	RETN
RAISING_MILLIONS:
	CMP	CARCOUNTER,0
	JZ	DUMRET
	INC	RM[5]
	INC	BYTE PTR RAISING_M[5+2]
	EFFECT	RAISING_M
	RETN
bygel11:
	effect	bygelsetI
	cmp	lastarea,OFFSET bygel12
	jne	dumret
;he did the reverse loop
	cmp	BOATcounter,0
	jz	noBOAT
	CMP	BOATflag,0
	JNZ	noBOAT
	mov	BOATcounter,0
	mov	BOATflag,1
	effect	BOATlit
	syncedFLASH 28,sfspeed,syncflasher
	cmp	HOUSEflag,0
	jz	dumret
	cmp	PLANEflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn
noBOAT:
	cmp	HOUSEcounter,0
	jz	noHOUSE
	cmp	HOUSEflag,0
	jnz	noHOUSE
	mov	HOUSEflag,1
	effect	HOUSElit
	invertedsyncedflash 29,sfspeed,syncflasher
	cmp	PLANEflag,0
	jz	dumret
	cmp	BOATflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn
noHOUSE:
	retn
bygel12:	
	CALL	ADDMONEY2
	effect	bygelsetJ
	cmp	lastarea,offset bygel11
	jne	dumret
;he did the loop...
	CMP	LIGHTSTATUS[11],0
	JZ	NOXB
	EFFECT	EXTRA_BALL
	ENDFLASH 11
	LIGHTOFF 11
	LIGHTON	31
NOXB:
	cmp	PLANEcounter,0
	jz	noPLANE
	CMP	PLANEflag,0
	JNZ	noPLANE
	mov	PLANEcounter,0
	mov	PLANEflag,1
	effect	PLANElit
	syncedFLASH 30,sfspeed,syncflasher
	cmp	HOUSEflag,0
	jz	dumret
	cmp	BOATflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn

noPLANE:
	call	closegate7	;v„xla till v„nster bana
	mov	MBcounter,MB_time
	mov	TRIPcounter,TRIP_time
	retn
	
close3:
	retn
bygel10:
	effect	bygelsetH
	cmp	lastarea,offset close3
	jne	dumret
	CALL	JACKADD
	CALL	CASHADD
	CALL	ADDMONEY2
	CALL	ANOTHER_SKILL
	cmp	TVcounter,0		;he did a skill shot
	jz	notTV
	cmp	all_six,true
	je	dumret
	cmp	top_three,true
	je	show_where_boat
	CMP	TVFLAG,0
	JNZ	NOTTV
	mov	TVcounter,0
	mov	TVflag,1
	effect	TVlit
	syncedFLASH 13,sfspeed,syncflasher
	cmp	carflag,0
	jz	dumret
	cmp	TRIPflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn
show_where_boat:
	CMP	BOATflag,0
	jnz	dumret
	mov	bx,offset liteprize_rightTS
	call	do_matrix
	mov	boatcounter,boat_time
	retn
show_where_house:
	CMP	HOUSEflag,0
	jnz	dumret
	mov	bx,offset liteprize_rightTS
	call	do_matrix
	mov	HOUSEcounter,hOUse_time
	retn
show_where_plane:
	CMP	PLANEflag,0
	jnz	dumret
	mov	bx,offset liteprize_leftTS
	call	do_matrix
	mov	PLANEcounter,PLANE_time
	retn
notTV:
	cmp	TRIPcounter,0
	jz	noTRIP
	cmp	all_six,true
	je	noTRIP
	cmp	top_three,true
	je	show_where_house
	mov	TRIPcounter,0
	cmp	TRIPflag,0
	jnz	noTRIP
	mov	TRIPflag,1
	effect	TRIPlit
	invertedsyncedFLASH 14,sfspeed,syncflasher
	cmp	carflag,0
	jz	dumret
	cmp	tvflag,0
	jz	dumret
	invertedsyncedflash 17,sfspeed,syncflasher
	mov	lightstatus[17],1
	call	opengate1
	retn
noTRIP:
	RETN
another_skill:
	ADDBCD	SKILLCOUNTER,ETTA
	INC	CYCLONECOUNTER
	cmp	cyclonecounter,1
	je	another_skill
	MOV	AX,CYCLONECOUNTER
	MOV	BL,6
	DIV	BL
	OR	AH,AH
	JZ	MONEY_MANIA
	
	CMP	AL,1
	JB	NO_PUT
	JE	NEXT_IS_XB
	INC	AL
	MUL	BL
	mov	bx,offset SKILLTEXT+16 ;vilken text † stoppa in v„rdet i
	CMP	AX,100
	JB	NOIB
	INC	BX
NOIB:	Call Put_In_Text
NO_PUT:
	EFFECT	SKILLSHOT
	retn
money_mania:
	CMP	AL,1
	JE	N_MM
	CMP	AL,2
	JE	X_BALL
	TEST	AL,1
	JNZ	LT_MM
N_MM:
	EFFECT MONEYMANIA
	MOV	TURBOMODE,TRUE
	MOV	SPECIALMODE,TRUE
	MOV	LOOPS_N_TRAPS,FALSE
	lighton	32	
	retn
LT_MM:
	EFFECT	MONEYMANIA2
	MOV	TURBOMODE,TRUE
	MOV	SPECIALMODE,TRUE
	MOV	LOOPS_N_TRAPS,TRUE
	lighton	32	
	retn
	
X_BALL:
	PLAYJINGLE SJINGLE19
	invertedsyncedFLASH 11,sfspeed,syncflasher
	MOV	LIGHTSTATUS[11],1
	RETN
NEXT_IS_XB:
	EFFECT	SKILLSHOT_XB
	RETN
	;*****************************
;Input: Ax= NextR„knare  Bx=offset till texten
Put_In_Text:
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
	mov	[bx][di],dl
	pop	cx
	dec	di
	loop loopen_lejf
	retn
;*****************************

;******************************************************************************
;*********************************** UPPER ************************************
;******************************************************************************
bygel1:
	effect	bygelsetA
	soundeffect sbygel1,20h
	retn
bygel2:
	effect	bygelsetA
	soundeffect sbygel1,20h
	retn
bygel3:
	effect	bygelsetB
	soundeffect sbygel2,0
	retn
bygel4:
	effect	bygelsetB
	soundeffect sbygel2,0
	retn
bygel8:
	effect	bygelsetF
	retn
bygel9:
	effect	bygelsetG
	retn
bygel13:
	effect	bygelsetK
	retn
BYGEL6B:
	CALL	JACKADD
	RETN
BYGEL6:
	CALL	CASHADD
	effect	bygelsetD
	CMP	LOOP_MILLION_COUNTER,0
	MOV	LOOP_MILLION_COUNTER,LM_TIME
	JZ	NO_MILLION
	EFFECT	LOOPMILLION
NO_MILLION:
	CMP	LIGHTSTATUS[17],1
	JNE	NO_FORVANTAN
	PLAYJINGLE SJINGLE21	;DU KOMMER ATT VINNA ETT PRIS
NO_FORVANTAN:
	ENDFLASH 4
	syncedFLASH 4,sfspeed,syncflasher
	RETN



;******************************************************************************
UPDATE_COUNTERS PROC NEAR
	downcount SJP_COUNTER,NO_SJP
	CMP	SJP_COUNTER,2*60
	JNE	NOTSJP2
	ENDFLASH 5
	LIGHTFLASH 5,2
	JMP	NOTSJP2
NO_SJP:	ENDFLASH 5
	LIGHTOFF 5
	RETN
NOTSJP2:
	downcount JP_COUNTER,NO_JP
	CMP	JP_COUNTER,2*60
	JNE	NOTJP2
	ENDFLASH 16
	LIGHTFLASH 16,2
	JMP	NOTJP2
NO_JP:	ENDFLASH 16
	LIGHTOFF 16
	RETN
NOTJP2:
	synccount syncflasher,sfspeed
	downcount SPINcounter,nextSPIN
	downcount MBcounter,dumret
	downcount TVcounter,dumret
	downcount BOATcounter,dumret
	downcount TRIPcounter,dumret
	downcount CARcounter,dumret
	downcount CAsh5counter,endcash5
	cmp	cash5counter,2*60
	jne	notfastend
	endflash 12
	lightflash 12,2
notfastend:
	DOWNCOUNT LOOP_MILLION_COUNTER,ENDLM
	CMP	LOOP_MILLION_COUNTER,2*60
	JNE	NOHST_FLASH
	ENDFLASH 4
	LIGHTFLASH 4,3
NOHST_FLASH:	
	RETN
ENDLM:	ENDFLASH 4	;STŽNG AV LOOP MILLION LAMPAN
	LOFF 4
	RETN
UPDATE_COUNTERS	ENDP


BUMPER_WAS_HIT_PROC PROC NEAR	;INPUT: HITPOINTER
	CALL	ADDMONEY
	UPDAT_INFOBAR
	RETN
BUMPER_WAS_HIT_PROC ENDP
JACKADD PROC NEAR
	ADDBCD	JACKVALUE,_100K
	RETN
INITJACK:
	MOVEBCD JACKVALUE,JACKINIT
	RETN
ENDP
CASHADD PROC NEAR
	ADDBCD	CASHPOTVAL,CASHPOTSTEP    
	RETN
ENDP
CASHADD2 PROC NEAR
	ADDBCD	CASHPOTVAL,CASHPOTSTEP2    
	RETN
ENDP
ADDMONEY PROC NEAR
	CMP	SPECIALMODE,TRUE
	JNE	DUMRET
	CMP	TURBOMODE,TRUE
	JNE	DUMRET
	CMP	LOOPS_N_TRAPS,TRUE
	JE	DUMRET
	ADDBCD	TM_TOTAL,_500K
	RETN
ENDP
ADDMONEY2 PROC NEAR
	CMP	SPECIALMODE,TRUE
	JNE	DUMRET
	CMP	TURBOMODE,TRUE
	JNE	DUMRET
	CMP	LOOPS_N_TRAPS,FALSE
	JE	DUMRET
	ADDBCD	TM_TOTAL,_1000K
	RETN
ENDP

;********************************* DOT MATRIX CODE ****************************
_PARTYONN:
	MOVE	DS,DATA
	ASSUME	DS:DATA
	MOV	AL,PLAYER
	ADD	AL,'A'-10
	MOV	PARTY_ON_TEXT[18],AL
	MOV	SHOOTTHEBALLTEXT[19],AL
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
_PARTYON:		;BX NOT USED!
	MOV	PARTYFLASH,TRUE
	MOVE	SISA,1		;HUR M†NGA
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
	MOV	SI,34		;INTE 0 = INTE IGNG !!
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
	MOV	BONUS_X_TEXT[8],1+'7'
	MOV	BONUS_X_TEXT[9],0+'7'
	MOV	AL,BONUS_X
	ADD	AL,'7'
	CMP	AL,10+'7'
	JNB	ITS10
	MOV	BONUS_X_TEXT[8],AL
	MOV	BONUS_X_TEXT[9],' '
ITS10:
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
_CALC_HAPPY:	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	PUSHA
	MOV	SI,OFFSET TM_TOTAL 	;ML_TOT -> TOTAL BONUS
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

_Jmp:
	add	bx,2
	mov	bx,[bx]
	MOV	NEXT_A,BX
	JMP	[BX]
	retn
	
_NEXTp_3Q:
_NEXTp_3:
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

;[SEC_ASC] PEKAR P MSD, (0='*')	[SEC_ASC+1] PEKAR P LSD
;LŽS AV BARA!
	MOVE	DS,DATA
	cmp	[sec_asc],'*'
	jne	no_end
	cmp	[sec_asc+1],'0'+7	;???
	jne	no_end
	cmp	turbomode,true
	jne	noturboend
	playjingle_penetrate Sjingle10
	mov	lastjingle,3
noturboend:
	cmp	OffRoadmode,true
	jne	nooffrend
	playjingle_penetrate Sjingle10
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
	LIGHTON	31
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
IF CREATE_FLIP_DATA
	EXTRN FLIPL
ELSE
	EXTRN FLIPL_1
ENDIF
FLIPLEFT ENDS

FLIPLEFT2 SEGMENT PARA PUBLIC 'DATA'
IF CREATE_FLIP_DATA
	EXTRN FLIPR2
ELSE
	EXTRN FLIPR2_1
ENDIF
FLIPLEFT2 ENDS

FLIPRIGHT SEGMENT PARA PUBLIC 'DATA'
IF CREATE_FLIP_DATA
	EXTRN FLIPR
ELSE
	EXTRN FLIPR_1
ENDIF
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

;***************************  Animations **************************************
DATA2 SEGMENT PARA PUBLIC 'DATA'
;*********************ANIMATIONS MALL*************************
comment\
	dw 1*4		;loop pos
	dw 15		;number of loops (1=NOLOOP)
	dw 5*4-4	;length of anim (5 frames * 4 bytes!) (IF LOOP=> -4)
_happy	dw happy_1,1;<---start!
	dw happy_2,2;<-, loop!
	dw happy_3,2;  I
	dw happy_4,2;  I 
	dw happy_5,2;__I
\
;*______________________/Billion Dollar GameShow\______________________*
;		Bredd:		Antal:		Anim:
;Multiply	6		7		3
;2,3,4 . . 	12	    alla i anim 4 !!
;MoneyMania	40		9		5
;JackPot	40		37		1	;Puhhhh vicken j„vla mega anim!!!  den e 15 h”g †x†!!!
;ExtraBall	40		17		2
;Million	40		16		8
;Billion	32		16		9

;YouWin		24		16		7	;Olika h”jd p† alla!!!

extrn	a_01_00,a_01_01,a_01_02	,a_01_03 ,a_01_04 ,a_01_05 ,a_01_06 ,a_01_07 ,a_01_08 ,a_01_09 ,a_01_10 ,a_01_11 ,a_01_12 ,a_01_13 ,a_01_14 ,a_01_15,a_01_16,a_01_17,a_01_18,a_01_19,a_01_20,a_01_21,a_01_22,a_01_23,a_01_24,a_01_25,a_01_26,a_01_27,a_01_28,a_01_29,a_01_30,a_01_31,a_01_32,a_01_33,a_01_34,a_01_35,a_01_36,a_01_37
extrn	a_02_00,a_02_01,a_02_02	,a_02_03 ,a_02_04 ,a_02_05 ,a_02_06 ,a_02_07  ,a_02_08 ,a_02_09 ,a_02_10 ,a_02_11 ,a_02_12 ,a_02_13 ,a_02_14 ,a_02_15,a_02_16,a_02_17
extrn	a_03_00,a_03_01,a_03_02	,a_03_03 ,a_03_04 ,a_03_05 ,a_03_06 ,A_03_07
extrn	a_14_00,a_24_00,a_34_00	,a_44_00 ,a_54_00 ,a_64_00 
extrn	a_05_00,a_05_01,a_05_02	,a_05_03 ,a_05_04 ,a_05_05 ,a_05_06 ,A_05_07,A_05_08
extrn	a_06_00,a_06_01,a_06_02	,a_06_03 ,a_06_04 ,a_06_05 ,a_06_06,a_06_07 ,a_06_08 ,a_06_09 ,a_06_10 ,a_06_11
extrn	a_07_00,a_07_01,a_07_02	,a_07_03 ,a_07_04 ,a_07_05 ,a_07_06,a_07_07 ,a_07_08 ,a_07_09 ,a_07_10 ,a_07_11 ,a_07_12 ,a_07_13 ,a_07_14 ,a_07_15
extrn	a_08_00,a_08_01,a_08_02	,a_08_03 ,a_08_04 ,a_08_05 ,a_08_06,a_08_07 ,a_08_08 ,a_08_09 ,a_08_10 ,a_08_11 ,a_08_12 ,a_08_13 ,a_08_14 ,a_08_15
extrn	a_09_00,a_09_01,a_09_02	,a_09_03 ,a_09_04 ,a_09_05 ,a_09_06,a_09_07 ,a_09_08 ,a_09_09 ,a_09_10 ,a_09_11 ,a_09_12 ,a_09_13 ,a_09_14 ,a_09_15
extrn	a_10_00,a_10_01,a_10_02
extrn	a_10b00,a_10b01,a_10b02

	dw 0		;adressen till bilden f”re den f”rsta i loopen
	dw 10		;antal loopar
	dw 2*4		;adressen till den sista bilden i loopen
_liteprize_right label word
	dw a_10_00,15
	dw a_10_01,15
	dw a_10_02,15

	dw 0
	dw 10
	dw 2*4
_liteprize_left label word
	dw a_10b00,15
	dw a_10b01,15
	dw a_10b02,15
 
MONEYMSPEED=5
	DW 0
	dw 5
	dw 4*9-4
_moneyM dw a_05_00,MONEYMSPEED
	dw a_05_01,MONEYMSPEED
	dw a_05_02,MONEYMSPEED
	dw a_05_03,MONEYMSPEED
	dw a_05_04,MONEYMSPEED
	dw a_05_05,MONEYMSPEED
	dw a_05_06,MONEYMSPEED
	dw a_05_07,MONEYMSPEED
	dw a_05_08,MONEYMSPEED

multiplyspeed=3
	dw 1
	dw 4*7
_multiply label word
	dw a_03_00,multiplyspeed
	dw a_03_01,multiplyspeed
	dw a_03_02,multiplyspeed
	dw a_03_03,multiplyspeed
	dw a_03_04,multiplyspeed
	dw a_03_05,multiplyspeed
	dw a_03_06,multiplyspeed
	
	dw 1,4*1
_x2	dw a_14_00,50
	dw 1,4*1
_x3	dw a_24_00,50
	dw 1,4*1
_x4	dw a_34_00,50
	dw 1,4*1
_x6	dw a_44_00,50
	dw 1,4*1
_x8	dw a_54_00,50
	dw 1,4*1
_x10	dw a_64_00,50

cashpotspeed=2
	dw 1
	dw 4*10
_cashpot label word
	dw a_06_00,cashpotspeed
	dw a_06_01,cashpotspeed
	dw a_06_02,cashpotspeed
	dw a_06_03,cashpotspeed
	dw a_06_04,cashpotspeed
	dw a_06_05,cashpotspeed
	dw a_06_06,cashpotspeed
	dw a_06_07,cashpotspeed
	dw a_06_08,cashpotspeed
	dw a_06_09,90

cashpot5speed=2
	dw 4*10-4
	dw 5
	dw 4*12-4
_cashpot5 label word
	dw a_06_00,cashpot5speed
	dw a_06_01,cashpot5speed
	dw a_06_02,cashpot5speed
	dw a_06_03,cashpot5speed
	dw a_06_04,cashpot5speed
	dw a_06_05,cashpot5speed
	dw a_06_06,cashpot5speed
	dw a_06_07,cashpot5speed
	dw a_06_08,cashpot5speed
	dw a_06_09,cashpot5speed
	dw a_06_10,20
	dw a_06_11,20
millionspeed=2
	dw 1
	dw 4*16
_million label word
	dw a_08_00,millionspeed
	dw a_08_01,millionspeed
	dw a_08_02,millionspeed
	dw a_08_03,millionspeed
	dw a_08_04,millionspeed
	dw a_08_05,millionspeed
	dw a_08_06,millionspeed
	dw a_08_07,millionspeed
	dw a_08_08,millionspeed
	dw a_08_09,millionspeed
	dw a_08_10,millionspeed
	dw a_08_11,millionspeed
	dw a_08_12,millionspeed
	dw a_08_13,millionspeed
	dw a_08_14,millionspeed
	dw a_08_15,50

Billionspeed=2
	dw 1
	dw 4*16
_Billion label word
	dw a_09_00,Billionspeed
	dw a_09_01,Billionspeed
	dw a_09_02,Billionspeed
	dw a_09_03,Billionspeed
	dw a_09_04,Billionspeed
	dw a_09_05,Billionspeed
	dw a_09_06,Billionspeed
	dw a_09_07,Billionspeed
	dw a_09_08,Billionspeed
	dw a_09_09,Billionspeed
	dw a_09_10,Billionspeed
	dw a_09_11,Billionspeed
	dw a_09_12,Billionspeed
	dw a_09_13,Billionspeed
	dw a_09_14,Billionspeed
	dw a_09_15,50

youwinspeed=2
	dw 1
	dw 4*16
_youwin dw a_07_00,youwinspeed
	dw a_07_01,youwinspeed
	dw a_07_02,youwinspeed
	dw a_07_03,youwinspeed
	dw a_07_04,youwinspeed
	dw a_07_05,youwinspeed
	dw a_07_06,youwinspeed
	dw a_07_07,youwinspeed
	dw a_07_08,youwinspeed
	dw a_07_09,youwinspeed
	dw a_07_10,youwinspeed
	dw a_07_11,youwinspeed
	dw a_07_12,youwinspeed
	dw a_07_13,youwinspeed
	dw a_07_14,youwinspeed
	dw a_07_15,50

xtraballspeed=5
	dw 1
	dw 4*17
_xtraball dw a_02_00,xtraballspeed
	dw a_02_01,xtraballspeed
	dw a_02_02,xtraballspeed
	dw a_02_03,xtraballspeed
	dw a_02_04,xtraballspeed
	dw a_02_05,xtraballspeed
	dw a_02_06,xtraballspeed
	dw a_02_07,xtraballspeed
	dw a_02_08,xtraballspeed
	dw a_02_09,xtraballspeed
	dw a_02_10,xtraballspeed
	dw a_02_11,xtraballspeed
	dw a_02_12,xtraballspeed
	dw a_02_13,xtraballspeed
	dw a_02_14,xtraballspeed
	dw a_02_15,xtraballspeed
	dw a_02_16,150

jpspeed=4
	dw 1
	dw 4*37
_jackpot dw a_01_00,jpspeed
	dw a_01_01,jpspeed
	dw a_01_02,jpspeed
	dw a_01_03,jpspeed
	dw a_01_04,jpspeed
	dw a_01_05,jpspeed
	dw a_01_06,jpspeed
	dw a_01_07,jpspeed
	dw a_01_08,jpspeed
	dw a_01_09,jpspeed
	dw a_01_10,jpspeed
	dw a_01_11,jpspeed
	dw a_01_12,jpspeed
	dw a_01_13,jpspeed
	dw a_01_14,jpspeed
	dw a_01_15,jpspeed
	dw a_01_16,jpspeed
	dw a_01_17,jpspeed
	dw a_01_18,jpspeed
	dw a_01_19,jpspeed
	dw a_01_20,jpspeed
	dw a_01_21,jpspeed
	dw a_01_22,jpspeed
	dw a_01_23,jpspeed
	dw a_01_24,jpspeed
	dw a_01_25,jpspeed
	dw a_01_26,jpspeed
	dw a_01_27,jpspeed
	dw a_01_28,jpspeed
	dw a_01_29,jpspeed
	dw a_01_30,jpspeed
	dw a_01_31,jpspeed
	dw a_01_32,jpspeed
	dw a_01_33,jpspeed
	dw a_01_34,jpspeed
	dw a_01_35,jpspeed
	dw a_01_36,50
;**************************************************************
	dw 1
	dw 4*4
_clear	dw clear2,1
	dw clear3,1
	dw clear4,1
	dw clear5,1
;****************************************************************
extrn clear2,clear3,clear4,clear5:byte

DATA2	ENDS

;******************************************************************************

