;******************************************************************************
;**                                                                          **
;**                   P I N B A L L   F A N T A S I E S                      **
;**                          TABLE1: PARTY LAND                              **
;**                                                                          **
;******************************************************************************

;REACHED THE SKY SKALL FôLJAS AV NèN TEXT

INCLUDELIB PLAND

flipgfxfilesize=1748
FIRSTMASK_GFXADR=BPL*(SPLH+BANH)
GFXADR_FOR_FLIP_ANIM_DATA=FIRSTMASK_GFXADR+BPL*40
springsourceadr=GFXADR_FOR_FLIP_ANIM_DATA-3*23	;3*23 éR FôR FJéDERNS GFX
springdestadr=(splh+556)*bpl+304/4

DATAFLIP SEGMENT PARA PUBLIC 'DATA'
MAXDIFS1=114+5
MAXDIFS2=114+5
MAXDIFS3=137+5
maxdifs=137
if create_flip_data
	LEFTFLIPTAB	DW 42*(2*MAXDIFS1) DUP (1)
	RIGHTFLIPTAB	DW 42*(2*MAXDIFS2) DUP (1)
	LEFTFLIP2TAB	DW 28*(2*MAXDIFS3) DUP (1)
	TEMPTAB		DW 2*MAXDIFS DUP (1)	
else
	extrn leftfliptab,rightfliptab,leftflip2tab
endif
DATAFLIP ENDS

DATA	SEGMENT PARA PUBLIC 'DATA'
	ASSUME CS:CODE,DS:DATA
MODUL	DB 'TABLE1.MOD',0,'$'
if create_flip_data
	flipdatafil_L	DB 'flipdata.1L',0
	flipdatafil_R	DB 'flipdata.1R',0
	flipdatafil_L2	DB 'flipdata.1L2',0
	flipgfxfil	DB 'flipgfx.1',0
	flipSTRUCfil	DB 'flipSTRU.1',0
endif
hi_score_file	db 'table1.hi',0
hi_score_list	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'TSP',0
		db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ICE',0
		db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'ANY',0
		db 0,0,0, 0,0,5, 0,0,0, 0,0,0,'J L',0


;******************************************************************************
;******************************** DEFINES *************************************
;******************************************************************************

INHIBIT_REVERSE_TIME=120
TOTCENT=16

;******************** SYSTEM **********************
MAX_NO_OF_LIGHTS_FLASHING=15
MAX_NO_OF_WAIT_SYNCS=50
NOOFTASKS=50
RGB_BUFFER_LEN=1000

;******************** FLIPPER & BALL **********************
BALLH=16
BANH=576
STARTX=310-BALLH/2
STARTY=543-BALLH/2

LEFTFLIPX=80-1
LEFTFLIPY=509+1
LEFTFLIP2X=16
LEFTFLIP2Y=227
RIGHTFLIPX=80+80+1
RIGHTFLIPY=509+1
F3TOP=144+80
F3HEIGHT=58 ;CP! GISSAT VéRDE!!!

;******************** FLASHING **********************
MATRIXCOLS=60F2H
matrixhi=60h
matrixlo=0F2h
BIT2COL			DB 0,0,0,0,9,2,42,0	;flipper fÑrgerna

DROPSPEED=7
HITSPEED=3
SNACKSPEED=8
ARROWSPEED=12
QUICK_ARROWSPEED=2	;?
PUKESPEED=2		;?
WHOLEPUKESPEED=2	;?
ROCKETSPEED=2		;?
TRAINSPEED=14		;!
TRAINSPEEDFAST=2	;?
EYESPEED=7		;?
TUNNELSPEED=8		;?
BALOONSPEED=9		;?
BALOONSPEEDFAST=2	;?
MADSPEED=2		;?
MADONSPEED=2		;?
WHEELSPEED=8		;?

QUICKFLASH_TIME=2*60	;?

PARTY_ON_SPEED=3	;?
SHOOT_AGAIN_SPEED=3	;?


;******************** GAME TIMING ********************
_5X_TIME=10*60		;!
DB_TIME=10*60		;!
TUNNEL_TIME=12*60	;10!
SKILL_SHOT_TIME=5*60	;?
PARTY_P_TIME=5*60	;?
PARTY_R_TIME=5*60	;?
PARTY_T_TIME=10*60	;!
MEGA_LAUGH_TIME=30*60	;!
;HAPPY_HOUR_TIME=30*60	;!

;******************** HOLES **********************
SNACKX=10-7		;!
SNACKY=260-7		;!
SNACKXS=0*TT/NN		;!
SNACKYS=-3000*TT/NN	;!
DRAGONX=264-7		;!
DRAGONY=317-7		;!
DRAGONXS=-690*TT/NN	;!
DRAGONYS=+1890*TT/NN	;!
DROPX=22-7		;!
DROPY=54-7		;!
DROPXS=0*TT/NN	;!
DROPYS=0*TT/NN		;!


;******************************************************************************
;****************************** GENERAL VARS **********************************
;******************************************************************************

if create_flip_Data
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

		DB    FlipperL,222
		DW    16,227,3,51,0,160,0,399,27,234,-1,(51*6*3)
		DW    0,0,0,13,13*ADJUST,-8*tt/nn,4*tt/nn,-68*tt/nn,48*tt/nn
		DW	?,?,?,?,LEFTFLIP2TAB,LEFTFLIP2TAB,maxdifs3*4
		DW    FLIPLEFT2

                DB    0,0
else
	extrn	fliplinfo:flipstruc
endif
NO_OF_RAMPS EQU 4
RAMPTABLE	DW	0,10*tt/nn
		DW	2,14*tt/nn
		DW	-2,14*tt/nn
		DW	-4,16*tt/nn
		DW	0,0
RAMPTABLe_hi	DW	0,10
		DW	2,14
		DW	-2,14
		DW	-4,16
		DW	0,0

SNACKSYNCER		DB ?		;SYNC ICE,SODA,POP LIGHTS
SNACKFLASHERS		LABEL BYTE	;STATUS OF LIGHTS
	ICEFLASHING	DB ?
	SODAFLASHING	DB ?
	POPFLASHING	DB ?
SNACKCOUNTER		DB ?		;WHICH IS NEXT SNACK?
D1DISABLED		DB ?		;UNDVIK MEGAHIT+HIT & DUBBELHIT
D2DISABLED		DB ?		;UNDVIK MEGAHIT+HIT & DUBBELHIT
D3DISABLED		DB ?		;UNDVIK MEGAHIT+HIT & DUBBELHIT
ARCADEON		DB ?
SYNCS_BEFORE_XRUT	DW ?
XRUT_OFFSET		DW ?
SLUMPCOUNTER		DB ?		;USED BY ARCADE
TOUCHERDISABLED		DB ?
SNACKDISABLED		DB ?
POPCOUNTER		DB ?
MBFLASHING		DB ?
HBFLASHING		DB ?
DBFLASHING		DB ?
_5XFLASHING		DB ?
ARROWSYNCER		DB ?		;SYNC MB,HB,DB LIGHTS
SKYRIDECOUNTER		DW ?
PUKECOUNTER		DW ?
_5MFLASHING		DB ?
BALLFLASHING		DB ?
JPFLASHING_NORMAL	DB ?
JPFLASHING_TIME		DB ?
PUKESYNCER		DB ?
TRAINSYNCER		DB ?
DRAGONWAITER		DW ?
TUNNELDOWNCOUNTER	DW ?
SKILLSHOTDOWNCOUNTER	DW ?
TUNNELWAITER		DW ?
CYCLONECOUNTER		DW ?				;HEXADECIMAL
cyclonecounterBCD	DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
CYCLONESCOREBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;BCD CODED
BALOONCOUNTER		DB ?
INH_REV			DB ?
INH_LOOP		DB ?
HAPPY_PENDING		DB ?
MEGA_PENDING		DB ?
XXBALLE			DB ?
XBALLS			DB ?
PUKEFORBIDDEN		DB ?
PARTYFLASH		DB FALSE
MUSICOK			DB ?
SNURR_READY		DB ?
DRAGON			DB ?
HANGSAVER		DW ?
OKEJHEJ			DB ?
HANGSAVER2		DW ?
CRAL			DB ?
CPVARIABEL		DB FALSE

SKILL_SCORE		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?
SKILL_SCORE2		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?
HAPPY_HOUR_TOTAL	DB ?,?,?, ?,?,?, ?,?,?, ?,?,?
MEGA_LAUGH_TOTAL	DB ?,?,?, ?,?,?, ?,?,?, ?,?,?

JACKVALUE		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?	;JACKPOT CURRENT
JACKRAISE		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;JACKPOT STEP
JACKINIT		DB 0,0,0, 0,1,0, 0,0,0, 0,0,0	;JACKPOT START

ETTA			DB 0,0,0, 0,0,0, 0,0,0, 0,0,1	;1
FEMMA			DB 0,0,0, 0,0,0, 0,0,0, 0,0,5	;5
TREA			DB 0,0,0, 0,0,0, 0,0,0, 0,0,3	;3
FEMHUNDRATUSEN		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
HUNDRATUSEN		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
BCDMILLION		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
BCD5MILLION		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;5,000,000
BCD7510			DB 0,0,0, 0,0,0, 0,0,7, 5,1,0	;7,510
BCD750			DB 0,0,0, 0,0,0, 0,0,0, 7,5,0	;750
BCD20070		DB 0,0,0, 0,0,0, 0,2,0, 0,7,0	;20,070
BCD1000			DB 0,0,0, 0,0,0, 0,0,1, 0,0,0	;1,000
BCD50030		DB 0,0,0, 0,0,0, 0,5,0, 0,3,0	;50,030
BCD50000		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
BCD5000			DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
BCD250000		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
BCD500000		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
BCD750000		DB 0,0,0, 0,0,0, 7,5,0, 0,0,0	;750,000
BONUS_X			DB ?
TEMPBONUSBCD		DB ?,?,?, ?,?,?, ?,?,?, ?,?,?


PLAYER_STRUC STRUC
	P_PUKE			DB 4 DUP(?)	;I ORDNINGEN SOM DE KOMMER I
	P_MAD			DB 3 DUP(?)	; LIGHTSTATUSLISTAN!!!!!!!
	P_CRAZY			DB 5 DUP(?)
	P_PARTY			DB 5 DUP(?)
	P_SIFFRORNA		DB 12 DUP(?)
	P_BONUSSIFFRORNA	DB 12 DUP(?)
	P_SKILL_SCORE		DB 12 DUP(?)
	P_SKILL_SCORE2		DB 12 DUP(?)
	P_HAPPY_HOUR_TOTAL	DB 12 DUP(?)
	P_MEGA_LAUGH_TOTAL	DB 12 DUP(?)
	P_CYCLONECOUNTERBCD	DB 12 DUP(?)
	P_CYCLONESCOREBCD	DB 12 DUP(?)
	P_CYCLONECOUNTER	DW ?
ENDS

PLAYER_AREA DB SIZE PLAYER_STRUC * NO_OF_PLAYERS DUP(?)

INHIBIT_REVERSE_COUNTER	DW ?
REVERSE_DOWN_COUNTER	DW ?
ANY_LOOP_DOWN_COUNTER	DW ?
DROP_TIME		DW ?
HAPPY_HOUR		DB ?
MEGA_LAUGH		DB ?
HOLDBONUSFLAG		DB ?


ARCADESLUMP	LABEL BYTE
		DB 10 DUP(0*2)		;XB
		DB 10 DUP(1*2)		;CRAZY LETTER
		DB 11 DUP(2*2)		;5M
		DB 11 DUP(3*2)		;1M
		DB 11 DUP(4*2)		;500K
		DB 11 DUP(5*2)		;NO SCORE
		DB 10 DUP(0*2)		;XB
		DB 10 DUP(1*2)		;CRAZY LETTER
		DB 11 DUP(2*2)		;5M
		DB 11 DUP(3*2)		;1M
		DB 11 DUP(4*2)		;500K
		DB 11 DUP(5*2)		;NO SCORE

ARCADEEFFECTS	LABEL WORD
		DW SPINXB_RUT
		DW SPINCL_RUT
		DW SPIN5M_RUT
		DW SPIN1M_RUT
		DW SPIN500K_RUT
		DW SPINNS_RUT

SPINXB		DW 0
		DB 100	;CP? (FLERA)
		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW sidelaneTS
		XBALL_TIME=160 ;CPW!

SPIN5M		DW SJINGLE15B
		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;5,000,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW fivemillionTS

SPIN1M		DW SJINGLE13B
		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW millionTS

SPIN500K	DW SJINGLE22
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW femhundraTS

SPINNS		DW 0
		DB 100
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DW nothingTS
		NOSCORE_TIME=45	;CPW!


CRAZY_ADVANCE_LIST	DB ?,41,38,34,31,28,-1


;******************************************************************************
;********************************* EFFECTS ************************************
;******************************************************************************

EFFECT_STRUC STRUC
	THEJINGLE	DW ?
	TSCORE		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	TBONUS		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0 ;12 ST!!
	DOTMATRIX	DW ?
ENDS

LOSTBALL	DW S_LOSTBALL	
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW ball_lostTS
if demover
MINUTE5		DW S_GAMEOVER2	
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW minute5TS
endif

MYSTERY		DW S_MYSTERY			;ARCADE HALL
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW mysteryTS
		MYSTERY_TIME=260 ;CPW!

PARTYSCORE1	DW SJINGLE26B			;PARTY P
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW party_pTS

PARTYSCORE2	DW SJINGLE26			;PARTY A
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW party_aTS

PARTYSCORE3	DW SJINGLE26B			;PARTY R
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW party_rTS

PARTYSCORE4	DW SJINGLE26B			;PARTY T
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW party_tTS

PARTYSCORE5	DW SJINGLE26			;PARTY Y
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW party_yTS

TSCORE1		DW SJINGLE13			;TUNNEL 1ST TIME
		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW millionTS
		TSCORE1_TIME=130 ;CPW!

TSCORE2		DW SJINGLE14			;TUNNEL 2ND TIME
		DB 0,0,0, 0,0,3, 0,0,0, 0,0,0	;3,000,000
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DW THREEmillionTS	;CP!
		TSCORE2_TIME=130 ;CPW!

TSCORE3		DW SJINGLE15			;TUNNEL 3RD TIME
		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;5,000,000
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DW fivemillionTS
		TSCORE3_TIME=130 ;CPW!

DSCORE		DW SJINGLE22			;DRAGON'S HEAD
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,3,0	;10,030
		DW DSCORETS

HSCORE		DW SJINGLE29			;NO DUCKS
		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
		DB 0,0,0, 0,0,0, 0,0,0, 0,4,0	;40	;CP?
		DW noducksTS

RSCORE1		DW SJINGLE22			;REVERSE 1ST TIME
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW RSCORE1TS

RSCORE2		DW SJINGLE22			;REVERSE 2ND TIME
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW RSCORE2TS

RSCORE3		DW SJINGLE22			;REVERSE 3RD TIME
		DB 0,0,0, 0,0,0, 7,5,0, 0,0,0	;750,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW RSCORE3TS

MILLION5	DW SJINGLE15			;DRAGON'S HEAD ONLY
		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;5,000,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW fivemillionTS
		MILLION5_TIME=160 ;CPW!

ALLDUCKS	DW SJINGLE1			;ALL DUCKS ARE DOWN
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW snackTS

SCORE1		DW SJINGLE19			;ICE
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW iceTS

SCORE2		DW SJINGLE20			;SODA
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
		DW sodaTS

SCORE3		DW SJINGLE21			;POP
		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
		DW popTS

MILLION		DW SJINGLE13			;LATE SKYRIDE ONLY
		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW millionTS

GETBONUS	DW 0				;GET BONUS MULTIPLYER
		DB 30
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW 0

M2		DW SJINGLE3			;MULTIPEL BONUS X2
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW bonusx2TS

M4		DW SJINGLE3			;MULTIPEL BONUS X4
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW bonusx4TS

M6		DW SJINGLE3			;MULTIPEL BONUS X6
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW bonusx6TS

M8		DW SJINGLE3			;MULTIPEL BONUS X8
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW bonusx8TS

HOLDBONUS	DW SJINGLE5			;REVERSE: HOLD BONUS
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW bonusheldTS
		
DOUBLEBONUS	DW SJINGLE6			;REVERSE: DOUBLE BONUS
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DW DOUBLEBTS

EXTRABALL1	DW SJINGLE17			;DRAGON'S HEAD: BALL
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW extraballTS
		EXTRABALL1_TIME=320 ;CPW! ;GNU

EXTRABALL2	DW SJINGLE17			;SL XB UTFôR DENNA!
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DB 0,0,0, 0,0,0, 0,0,5, 0,0,0	;5,000
		DW extraball2TS

ADVANCE3	DW SJINGLE7			;CRAZY LETTER SPOTTED
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW crazyletterTS

ADVANCE3B	DW SJINGLE7B			;CRAZY LETTER SPOTTED
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW crazyletterTS

THELOOP1	DW SJINGLE2			;LOOP 1ST TIME
		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW loopTS

THELOOP2	DW SJINGLE2			;LOOP 2ND TIME
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW loop2TS

THELOOP3	DW 0				;LOOP 3RD TIME
		DB 0
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
		DW loopTS

RIDE1		DW SJINGLE25			;SKYRIDE 1ST TIME
		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
		DB 0,0,0, 0,0,0, 0,1,0, 0,0,0	;10,000
		DW ride1TS

RIDE2		DW SJINGLE25			;SKYRIDE 2ND TIME
		DB 0,0,0, 0,0,0, 2,5,0, 0,0,0	;250,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW ride2TS

RIDE3		DW SJINGLE25			;SKYRIDE 3RD TIME
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
		DW ride3TS

CYCLCOUNT	DW SJINGLE16			;CYCLONEN OM EJ 5X
		DB 0,0,0, 0,0,0, 1,0,0, 0,0,0	;100,000
		DB 0,0,0, 0,0,0, 0,2,5, 0,0,0	;25,000
		DW cycloneTS

CYCLCOUNT2	DW SJINGLE16			;CYCLONEN OM 5X
		DB 0,0,0, 0,0,2, 5,0,0, 0,0,0	;2,500,000
		DB 0,0,0, 0,0,0, 5,0,0, 0,0,0	;500,000
		DW cycloneTS		;CP?

HIDDEN		DW 0				;HIDDEN ENTRANCE
		DB 20
		DB 0,0,0, 0,0,0, 0,5,0, 0,0,0	;50,000
		DB 0,0,0, 0,0,0, 0,2,0, 0,0,0	;20,000
		DW hiddenTS

SKILLCYCLONE	DW SJINGLE26			;SKILL EFFECT ;CP? PRIO=15?
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DW skillcycloneTS

SKILLTUNNEL	DW SJINGLE26B			;SKILL EFFECT
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DW skilltunnelTS

BYGELSETB	DW 0				;RéNNA SLUT
		DB 1
		DB 0,0,0, 0,0,0, 0,1,0, 0,4,0	;10,040
		DB 0,0,0, 0,0,0, 0,0,1, 0,0,0	;1,000
		DW 0

HAPPYHOUR	DW SJINGLE12			;HAPPY HOUR! (PARTY)
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW happyhourTS

EOHAPPYHOUR	DW SJINGLE27			;END OF HAPPY HOUR ("HAPPY")
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,1, 0,0,0, 0,0,0	;1,000,000
		DW 0

CRAZYSCORE	DW SJINGLE11			;MEGA LAUGH! (CRAZY)
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0
		DW megalaughTS

EOMEGALAUGH	DW SJINGLE28			;END OF MEGA LAUGH ("CRAZY")
		DB 0,0,0, 0,0,0, 0,0,0, 0,0,0	;0
		DB 0,0,0, 0,0,5, 0,0,0, 0,0,0	;5,000,000
		DW 0


;******************************************************************************
;**************************** SOUND STRUCTURES ********************************
;******************************************************************************

;SAMPLE,PERIOD,EFFECT,CHANNEL
SBASE		EQU	14H+2
SBRICKNER	DB	(SBASE+0),18,0,3
SBRICKUPP	DB	17H,23,0,3
SBUMPER1	DB	(SBASE+2),25,0,3
SBUMPER2	DB	(SBASE+2),23,0,3
SBUMPER3	DB	(SBASE+2),21,0,3
SFLIPPUPP	DB	(SBASE+3),22,0,3
SRINNER		DB	(SBASE+4+2),18,0,3
SNEWBALL	DB	(SBASE+4+2),18,0,3
SKICKER		DB	(SBASE+5+2),18,0,3
SFJADER		DB	1eh,18,0,3 ;(sbase+6)
SGROP		DB	(SBASE+1),23,0,3

EBASE		EQU	7H
SBYGEL1		DB	(EBASE+0),10,0,3
SBYGEL2		DB	(EBASE+0),12,0,3
SBYGEL3		DB	(EBASE+0),8,0,3
SBYGEL4		DB	(EBASE+0),17,0,3
SBYGEL5		DB	(EBASE+0),8,0,3
S_TOUCH1	DB	(EBASE+0),14,0,3
S_TOUCH2	DB	(EBASE+0),10,0,3
S_SCORELJUD	DB	(EBASE+0),18,0,3
S_ADDPLAYER2	DB	(EBASE+0),18,0,3

;***********************************************************************
;JINGLE,NOOFPTNS (0=4EVER),PRIORITY

emptyjingle equ 62
springjingle equ 0
mainjingle equ 1
lastmainpos equ 5
S_MULTILJUD	DB	39,1,255 ;255?
S_Empty		DB	62,0,1
S_Spring	DB	0,0,1
S_Main		DB	1,0,1
S_NoHigh	DB	8,0,1
S_Danger	DB	49,1,255
S_Tilt		DB	48,1,255
S_GameOver	DB	7,0,255	; ? 1
IF DEMOVER
S_GameOver2	DB	13,0,255
ELSE
S_GameOver2	DB	13,0,1
ENDIF
S_LostBall	DB	6,1,255 ;200
S_AddPlayer	DB	55,0,1
S_Lock		DB	0,1,90		;Bonus Locked
S_Mystery	DB	30,1,100
S_EndFig	DB	60,1,255	;60,0,1
S_Knacket	DB	58,1,255	;230
S_BEATEN	DB	58,1,200

;***********************************************************************

SJingle1	DB	50,1,20			;Ducks
SJingle2	DB	42,1,30			;Loop
SJingle3	DB	34,1,32			;X2X4X6X8
SJingle4	DB	24,3,200		;Jackpot
SJingle5	DB	20,1,31			;Hold Bonus
SJingle6	DB	21,1,33			;Double Bonus
SJingle7	DB	22,1,131		;MAD
SJingle7B	DB	22,1,90			;MAD (ARCADE)
SJingle8	DB	23,1,31			;PUKE1
SJingle9	DB	38,1,32			;PUKE2
SJingle10	DB	57,1,33			;PUKE3
SJingle11	DB	25,0,151		;Mega Laugh (150)
SJingle12	DB	43,0,151		;Happy Hour (150)
SJingle13	DB	35,1,100		;1 Million
SJingle13B	DB	35,1,90			;1 Million (ARCADE)
SJingle14	DB	36,1,140		;3 Million
SJingle15	DB	47,1,150		;5 Million
SJingle15B	DB	47,1,90			;5 Million (ARCADE)
SJingle16	DB	37,1,20			;Cyclone
SJingle17	DB	31,1,190		;Extra Ball
SJingle19	DB	51,1,33			;ICE
SJingle20	DB	53,1,32			;Soda
SJingle21	DB	52,1,31			;POP
SJingle22	DB	41,1,30			;Ballonger/250/500/750
SJingle25	DB	61,1,20			;Skyride
SJingle26	DB	56,1,35			;Spell PARTY
SJingle26B	DB	56,1,150		;Spell PARTY
SJingle27	DB	40,1,152 ;70		;Happy Hour End
SJingle28	DB	29,1,152 ;70		;Mega Laugh End
SJingle29	DB	49,1,5			;Nothing


;******************************************************************************
;***************************** DETECTION AREAS ********************************
;******************************************************************************

BumperLista_L	LABEL	WORD
		DW	211,252,235,276
		DW	Bumper1
		DW	268,263,292,287
		DW	Bumper2
		DW	185,283,209,307
		DW	Bumper3
		DW	-1,-1,-1,-1
		DW	-1

Bumper2Lista_L	LABEL	WORD
		DW	50,415,80,470
		DW	Kicker
		DW	219,415,249,470
		DW	Kicker
		DW	-1,-1,-1,-1
		DW	-1

bumper1		dw	sbumper1
		db	0,0,0, 0,0,0, 0,0,1, 0,0,0	;1,000
bumper2		dw	sbumper2
		db	0,0,0, 0,0,0, 0,0,1, 0,0,0	;1,000
bumper3		dw	sbumper3
		db	0,0,0, 0,0,0, 0,0,1, 0,0,0	;1,000
kicker		dw	skicker
		db	0,0,0, 0,0,0, 0,0,0, 5,0,0	;500

ZonLista_L	LABEL	WORD
		DW	130,196,146,204
		DW	TOUCHER
;		DW	145,274,170,330
;		DW	DropSetA
		DW	147,277,156,293
		DW	DROPA1
		DW	152,293,163,311
		DW	DROPA2
		DW	158,311,168,329
		DW	DROPA3
		DW	0

AreaLista_L	LABEL	WORD
		DW	90,15,130,40
		DW	Bygel11
		DW	200,15,240,40
		DW	Bygel9
		DW	160,35,182,55
		DW	GropC				;HIDDEN ENTRANCE
		DW	47,122,67,146
		DW	GropD				;THE TUNNEL
		DW	120,165,150,185
		DW	GropB				;ARCADE HALL
		DW	220,280,260,300
		DW	Bygel14
		DW	280,300,320,345	;Game On
		DW	Close1
		DW	260,312,268,321
		DW	GropE
		DW	25,435,35,445
		DW	Bygel3
		DW	263,435,273,445
		DW	Bygel4
		DW	5,455,15,465
		DW	Bygel1
		DW	284,455,294,465
		DW	Bygel2
		DW	305,455,320,512+28
		DW	Bygel12
		DW	305+3,512+28,320,576	;Spring Valid
		DW	Bygel28
		DW	0

AreaLista_U	LABEL	WORD
		DW	132,40,238,51		;SKY
		DW	Close2
		DW	167,6,201,40		;SKY
		DW	Close2
		DW	132,5,160,50		;STéNG SKYRIDE-GATEN
		DW	Close2
		DW	40,40,75,100
		DW	Bygel10
		DW	132,58,148,63
		DW	Bygel5
		DW	222,58,238,63
		DW	Bygel8
		DW	162,64,178,69
		DW	Bygel6
		DW	192,64,208,69
		DW	Bygel7
		DW	40,80,75,120
		DW	Open2
		DW	175,100,200,130
		DW	Bygel4b
		DW	260,130,280,150
		DW	Bygel13
		DW	3,245,22,270
		DW	GropA
		DW	0

AREALISTA_L_T	LABEL WORD
		DW	120,165,150,185
		DW	GropB				;ARCADE HALL
		DW	160,35,182,55
		DW	GropC_T				;HIDDEN ENTRANCE (TILT)
		DW	47,122,67,146
		DW	GropD_T				;THE TUNNEL (TILT)
		DW	0

AREALISTA_U_T	LABEL WORD
		DW	0

LEVEL1LISTA	LABEL	WORD	;AREOR SOM ANGER HOPP TILL LEVEL 1 FRèN LEVEL 2
		DW	10,100,40,200
		DW	300,140,320,160
		DW	275,165,300,220
		DW	60,185,100,220
		DW	195,175,215,200
		DW	300,240,320,340 ;AFTER SPRING
		DW	20,240,50,400 ;CP?
		DW	300,400,320,500 ;SPRING LANE LOW
		DW	260,450,277,470
		DW	0,450,50,470
		DW	-1

LEVEL2LISTA	LABEL	WORD	;AREOR SOM ANGER HOPP TILL LEVEL 2 FRèN LEVEL 1
;		DW	10,40,30,70 ;DRèP SON
		DW	215,160,235,190
		DW	50,165,85,185
		DW	300,210,320,240
		DW	3,245,22,270 ;SNACK-HèLET
		DW	300,360,320,400 ;SPRING LANE HIGH
		DW	-1


;******************************************************************************
;************************ DEMO MODE LIGHT FLASHING ****************************
;******************************************************************************

FLASHLIST	LABEL WORD
		T1=10			;PARTY
		T2=T1*6
		DW 0,T1*0,T2,T2,42
		DW 0,T1*1,T2,T2,43
		DW 0,T1*2,T2,T2,44
		DW 0,T1*3,T2,T2,45
		DW 0,T1*4,T2,T2,46

		T1=9			;CRAZY
		T2=T1*6-T1/2
		DW 0,T1*0,T2,T2,41
		DW 0,T1*1,T2,T2,38
		DW 0,T1*2,T2,T2,34
		DW 0,T1*3,T2,T2,31
		DW 0,T1*4,T2,T2,28

		T2=11			;X2,X4,X6,X8
		DW 0,0,T2,T2,47
		DW 0,0,T2,T2,49
		DW 0,T2,T2,T2,48
		DW 0,T2,T2,T2,50

		T2=17			;XB
		DW 0,0,T2,T2,39
		DW 0,0,T2,T2,40

		T2=8			;250K
		DW 0,0,T2,T2,26

		T2=10			;HIT
		DW 0,0,T2,T2,16
		DW 0,0,T2,T2,24
		DW 0,T2,T2,T2,18

		T1=5			;1ST,2ND,3RD
		T2=26
		DW 0,T1*0,T2,T2,22
		DW 0,T1*1,T2,T2,13
		DW 0,T1*2,T2,T2,15

		T2=8			;1M
		DW 0,T2/2,T2,T2,14

		T2=10			;MAD
		DW 0,0,T2,T2,6
		DW 0,0,T2,T2,9
		DW 0,T2,T2,T2,8

		T2=7			;PUKE
		DW 0,0,T2,T2,1
		DW 0,0,T2,T2,5
		DW 0,T2,T2,T2,2
		DW 0,T2,T2,T2,4

		DW -1


;******************************************************************************
;**************************** LIGHT PALETTE DATA ******************************
;******************************************************************************

NOOFLIGHTS=56

LON1	DB 128
	DB 2
	DB 95,0,0
	DB 64,0,0
LON2	DB 130
	DB 2
	DB 95,0,0
	DB 64,0,0
LON3	DB 132
	DB 1
	DB 95,0,0
LON4	DB 133
	DB 2
	DB 95,0,0
	DB 64,0,0
LON5	DB 135
	DB 2
	DB 95,0,0
	DB 64,0,0
LON6	DB 137
	DB 3
	DB 0,83,70
	DB 45,64,8
	DB 33,45,14
LON7	DB 140
	DB 2
	DB 95,64,64
	DB 85,45,45
LON8	DB 142
	DB 3
	DB 27,64,95
	DB 20,52,77
	DB 8,33,64
LON9	DB 145
	DB 3
	DB 0,83,70
	DB 45,64,8
	DB 33,45,64
LON10	DB 148
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON11	DB 153
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON12	DB 158
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON13	DB 156
	DB 2
	DB 95,70,27
	DB 77,52,8
LON14	DB 161
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON15	DB 164
	DB 3
	DB 0,95,14
	DB 46,64,8
	DB 33,45,14
LON16	DB 167
	DB 2
	DB 95,0,83
	DB 64,0,0
LON17	DB 169
	DB 5
	DB 95,64,64
	DB 95,0,0
	DB 64,0,0
	DB 95,95,95
	DB 64,64,64
LON18	DB 174
	DB 2
	DB 95,0,83
	DB 64,0,0
LON19	DB 176
	DB 2
	DB 27,64,95
	DB 8,39,70
LON20	DB 178
	DB 7
	DB 95,95,95
	DB 64,64,64
	DB 27,64,95
	DB 8,39,70
	DB 95,70,27
	DB 77,52,8
	DB 64,39,0
LON21	DB 185
	DB 5
	DB 95,95,95
	DB 95,70,27
	DB 77,52,8
	DB 64,39,0
	DB 52,14,14
LON22	DB 151
	DB 2
	DB 95,0,0
	DB 64,0,0
LON23	DB 195
	DB 9
	DB 8,39,70
	DB 83,45,45
	DB 95,64,64
	DB 45,64,8
	DB 33,45,14
	DB 95,95,95
	DB 95,70,27
	DB 77,52,8
	DB 64,39,0
LON24	DB 204
	DB 2
	DB 95,0,83
	DB 64,0,0
LON25	DB 206
	DB 3
	DB 0,95,14
	DB 45,64,8
	DB 33,45,14
LON26	DB 209
	DB 2
	DB 95,0,0
	DB 64,0,0
LON27	DB 211
	DB 2
	DB 95,0,0
	DB 64,0,0
LON28	DB 213
	DB 2
	DB 95,0,83
	DB 64,0,0
LON29	DB 215
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON30	DB 218
	DB 2
	DB 95,0,0
	DB 64,0,0
LON31	DB 220
	DB 2
	DB 95,0,0
	DB 64,0,0
LON32	DB 222
	DB 3
	DB 0,95,14
	DB 45,64,8
	DB 33,45,14
LON33	DB 225
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON34	DB 228
	DB 2
	DB 95,70,27
	DB 77,52,8
LON35	DB 230
	DB 2
	DB 95,0,0
	DB 64,0,0
LON36	DB 232
	DB 3
	DB 95,95,95
	DB 77,77,77
	DB 64,64,64
LON37	DB 235
	DB 2
	DB 27,64,95
	DB 8,39,70
LON38	DB 237
	DB 3
	DB 0,95,14
	DB 45,64,8
	DB 33,45,14
LON39	DB 240
	DB 2
	DB 95,0,0
	DB 64,0,0
LON40	DB 240
	DB 2
	DB 95,0,0
	DB 64,0,0
LON41	DB 244
	DB 2
	DB 27,64,95
	DB 8,39,70
LON42	DB 246
	DB 2
	DB 27,64,95
	DB 8,39,70
LON43	DB 248
	DB 2
	DB 95,0,83
	DB 64,0,0
LON44	DB 250
	DB 3
	DB 0,95,14
	DB 45,64,8
	DB 33,45,14
LON45	DB 253
	DB 2
	DB 95,0,83
	DB 64,0,0
LON46	DB 112
	DB 2
	DB 27,64,95
	DB 8,39,70
LON47	DB 114
	DB 2
	DB 27,64,95
	DB 8,39,70
LON48	DB 116
	DB 2
	DB 27,64,95
	DB 8,39,70
LON49	DB 118
	DB 2
	DB 27,64,95
	DB 8,39,70
LON50	DB 120
	DB 2
	DB 27,64,95
	DB 8,39,70
LON51	DB 190
	DB 5
	DB 95,0,0
	DB 95,95,95
	DB 64,0,0
	DB 64,64,64
	DB 89,55,55
LON52	DB 122
	DB 5
	DB 95,95,95
	DB 83,45,45
	DB 95,0,0
	DB 64,0,0
	DB 39,14,14
LON53	DB 107
	DB 5
	DB 95,95,95
	DB 83,45,45
	DB 95,0,0
	DB 64,0,0
	DB 39,14,14
LON54	DB 102
	DB 5
	DB 95,95,95
	DB 83,45,45
	DB 95,0,0
	DB 64,0,0
	DB 39,14,14
LON55	DB 255
	DB 1
	DB 58,20,20
LON56	DB 111
	DB 1
	DB 58,20,20

MATRIXON DB MATRIXLO ;(MATRIXCOL LOW BYTE)
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
	DW OFFSET LON39	;INTE CP. Ñndrad till lon39
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

MATRIXOFF DB MATRIXLO
	DB 3
	DB 3 DUP(33*64/100)

;******************************************************************************
;************************* GATES & BYGLARS DATA AREOR *************************
;******************************************************************************

GATE1OPEN_DATA		DB 18*2 DUP (0)
GATE1CLOSED_DATA	DB 18*2 DUP (?)

EXTRN	D1UP_DATA:BYTE
EXTRN	D1DOWN_DATA:BYTE
EXTRN	D2UP_DATA:BYTE
EXTRN	D2DOWN_DATA:BYTE
EXTRN	D3UP_DATA:BYTE
EXTRN	D3DOWN_DATA:BYTE

;******************************************************************************
;****************************** DOT MATRIX ************************************
;******************************************************************************

CLEARIT MACRO
ASSUME	DS:DATA
	DW _CLEAR4
ENDM

CLEARIT2 MACRO
ASSUME	DS:DATA
	DW _CLEAR2
ENDM

CLEARIT3 MACRO
ASSUME	DS:DATA
	DW _CLEAR3
ENDM

CLEARIT4 MACRO
ASSUME	DS:DATA
	DW _CLEAR4
ENDM

;************************************ TSAR ************************************

;*********************************************************
;******* OBS!!! KOM IHèG ATT ASSUMERA ANIMATIONER TILL DATA2 OCH 
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
		DW _WAITJINGLE,?
		CLEARIT
		DW _FLASHOFF,?
		DW _JMP,No_Bonus2TS

BeatenTS	LABEL WORD	;I SPELET
		DW _DOBEATEN,?
		CLEARIT
		DW _JINGLE,S_BEATEN
		DW _LASTJINGLE,3
		DW _SCROLL,BEATENSCROLL
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _WAITJINGLE,?
		CLEARIT
		DW _FLASHOFF,?
		DW 0

extraballTS	DW _CLEAR4
		dw _animation,_extraball
		DW _CLEAR4
		dw 0

extraball2TS	DW _CLEAR4
		dw _animation,_extraball
		dw  _CLEAR4
		DW _FLASHON,10
		DW _PRINT13,EXTRABALLTEXT,SW*4/4+TOTCENT+4
		DW _WAITJINGLE,?
		DW _CLEAR4
		DW _FLASHOFF,?
		DW 0

millionTS	LABEL WORD
		DW _CLEAR4
		assume	ds:data
		DW _FLASHON,1
		dw _number,offset ETTA
		assume	ds:data2
		dw _wait,40
		DW _FLASHOFF,?
		DW _CLEAR4
		dw _animation,_million
		DW _WAIT,10
		DW _CLEAR4
		DW 0
;*****************************************
ThreeMillionTS	LABEL WORD
		DW _CLEAR4
		assume	ds:data
		DW _FLASHON,1
		dw _number,offset TREA
		assume	ds:data2
		dw _wait,90
		DW _FLASHOFF,?
		DW _CLEAR4
		dw _animation,_millionFAST
		DW _WAIT,45
		DW _CLEAR4
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
fivemillionTS	DW _CLEAR4
		assume	ds:data
		DW _FLASHON,1
		dw _number,offset FEMMA
		assume	ds:data2
		dw _wait,55
		DW _FLASHOFF,?
		DW _CLEAR4
		dw _animation,_millionFAST
		DW _WAIT,35
		DW _CLEAR4
		DW 0
;*****************************************
clearTS		DW _CLEAR4
		dw 0

tomTS		DW _CLEAR4
		dw _wait,32767
		dw 0

cycloneTS	DW _CLEAR4
		assume	ds:data
		DW _FLASHON,1
		dw _number,offset cyclonecounterBCD
		assume	ds:data2
		dw _wait,40
		DW _FLASHOFF,?
		DW _CLEAR4
		dw _animation,_cyclone
		DW _CLEAR4
		dw 0

happyhourTS	LABEL WORD
		DW _EOSNURR,?
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,_HAPPY
		DW _CLEAR4
		ASSUME	DS:DATA
		DW _SCROLL,ALL_TARGA_
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		DW _COUNTDOWN,2,5,HAPPY_HOUR_TOTAL ;(THE FINAL?)
		CLEARIT
happy_endingTS	LABEL WORD
		ASSUME DS:DATA
		DW _JBCDZ,HAPPY_HOUR_TOTAL,no_happyTS
		DW _RULLGARDIN_UPP,HHTOTAL_text,1
		DW _WAIT,60		;cpw!
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER,happy_hour_total,SW*4/4+16*2/4 ;CP! RUTCENT
		DW _WAIT,80		;cpw!
		DW _FLASHOFF,1
		DW _TSEND,?
		CLEARIT
		DW 0

no_happyTS	LABEL WORD
		ASSUME	DS:DATA
		DW _PRINT13,NO_HAPPY_TEXT,SW*4/4
		DW _WAIT,80		;CPW!
		DW _TSEND,?
		CLEARIT
		DW 0


megalaughTS	LABEL WORD
		DW _EOSNURR,?
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,MEGAL
		DW _CLEAR4
		ASSUME DS:DATA
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		DW _COUNTDOWN,2,5,MEGA_LAUGH_TOTAL ;(THE FINAL?)
		CLEARIT
mega_endingTS	LABEL WORD
		ASSUME DS:DATA
		DW _JBCDZ,MEGA_LAUGH_TOTAL,no_megaTS
		dw _scroll,MLtotal_TEXT
		DW _WAIT,60		;CPW!
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13_NUMBER,mega_laugh_total,SW*4/4+16*2/4 ;CP! RUTCENT
		DW _WAIT,80		;CPW!
		DW _FLASHOFF,1
		DW _TSEND,?
		CLEARIT
		DW 0

no_megaTS	LABEL WORD
		ASSUME	DS:DATA
		DW _PRINT13,NO_MEGA_TEXT,SW*4/4
		DW _WAIT,80		;CPW!
		DW _TSEND,?
		CLEARIT
		DW 0

		assume ds:data2
party_pTS	DW _CLEAR4
		dw _animation,_party_p
		DW _CLEAR4
		dw 0 
party_aTS	DW _CLEAR4
		dw _animation,_party_a
		DW _CLEAR4
		dw 0 
party_rTS	DW _CLEAR4
		dw _animation,_party_r
		DW _CLEAR4
		dw 0 
party_tTS	DW _CLEAR4
		dw _animation,_party_t
		DW _CLEAR4
		dw 0 
party_yTS	DW _CLEAR4
		dw _animation,_party_y
		DW _CLEAR4
		dw 0 

mysteryTS	LABEL WORD		;NOTE:DECCOR MUST BE SET. (WAITJINGLE2)
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,_MYSTERY
		DW _WAITJINGLE2,?
		DW _EOSNURR,?
		DW _CLEAR4
		DW 0				;DOTRUT,OFFSET CS:NODOT

LMSPEED=7
loop2TS		LABEL WORD
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,_LOOP
		DW _WAIT,20
		DW _CLEAR4
		ASSUME	DS:DATA
		DW _FLASHON,LMSPEED
		DW _PRINT8,_ONEMOREFORMAD,SW*2*5/4+16*3/4
		ASSUME	DS:DATA2
		DW _WAIT,LMSPEED*4*2-LMSPEED
		DW _CLEAR4
		DW _FLASHOFF,?
		DW 0

loopTS		LABEL WORD
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,_LOOP
		DW _WAIT,20
		DW _CLEAR4
		ASSUME	DS:DATA
		DW _FLASHON,LMSPEED
		DW _PRINT5,_TWOMOREFORMAD,SW*2*6/4+16*3/4
		DW _WAIT,LMSPEED*4*2-LMSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

bonusx2TS	LABEL WORD
		ASSUME DS:DATA2
		DW _CLEAR4
		DW _ANIMATION,_BONUSX2
		DW _CLEAR4
		DW 0
bonusx4TS	DW _CLEAR4
		DW _ANIMATION,_BONUSX4
		DW _CLEAR4
		DW 0
bonusx6TS	DW _CLEAR4
		DW _ANIMATION,_BONUSX6
		DW _CLEAR4
		DW 0
bonusx8TS	DW _CLEAR4
		DW _ANIMATION,_BONUSX8
		DW _CLEAR4
		DW 0
jackpotTS	DW _CLEAR4
		DW _ANIMATION,_JACKPOT
		DW _CLEAR4
		DW 0

jackpot_special_hh_TS LABEL WORD
		DW _CLEAR4
		dw _animation,_jackpot
		DW _CLEAR4
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		dw _countdown2,2,5,happy_hour_total ;(the final?)
		DW _CLEAR4
		dw _jmp,happy_endingTS
		dw 0
jackpot_special_ml_TS LABEL WORD
		DW _CLEAR4
		dw _animation,_jackpot
		DW _CLEAR4
		DW _PRINT13,ZEROQ,SW*(2+2)/4+16*13/4
		dw _countdown2,2,5,MEGA_LAUGH_TOTAL ;(the final?)
		DW _CLEAR4
		dw _jmp,mega_endingTS
		dw 0


ball_lostTS	LABEL WORD
		CLEARIT

		DW _PRINT13,GETTING_SICK_TEXT,SW*2/4*2+8
		DW _WAIT,80	;CPW!
		CLEARIT

		DW _JBCDZ,BONUSSIFFRORNA,no_bonusTS
		DW _PRINT5,show_bonus_TEXT,SW*1*2/4+16*7/4
		DW _PRINT8_NUMBER_CENT,BONUSSIFFRORNA,7*2*SW/4+TOTCENT
		DW _WAIT,60	;CPW!
		DW _JINGLE,S_MULTILJUD

		DW _JBONUSX1,NoBonusXTS
		CLEARIT	;CP! CLEARIT éR ONôDIGT BRUTAL! TUFFT!!! (reds. anm.)
		DW _BONUS_X_CALCS,?
		DW _PRINT5,BONUS_X_TEXT,SW*1*2/4+16*7/4-4*2
		DW _PRINT8_NUMBER_CENT,BONUSSIFFRORNA,7*2*SW/4+TOTCENT
		DW _WAIT,60	;CPW!
		DW _JINGLE,S_MULTILJUD
NoBonusXTS	LABEL WORD

no_bonusTS	LABEL WORD
		DW _JBCDZ,CYCLONECOUNTERBCD,no_cyclonesTS
		CLEARIT
		DW _CALC_CYCLO	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5_NUMBER,CYCLONECOUNTERBCD,SW*1*2/4-16*10/4
		DW _PRINT5_number,HUNDRATUSEN,SW*1*2/4+16*8/4
		DW _PRINT5,show_CYCLONES_TEXT,SW*1*2/4-16*1/4
		DW _PRINT8_NUMBER_CENT,CYCLONESCOREBCD,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		DW _JINGLE,S_MULTILJUD
		CLEARIT

no_cyclonesTS	LABEL WORD
		DW _JBCDZ,HAPPY_HOUR_TOTAL,no_happy_stewartTS
		CLEARIT
		DW _CALC_HAPPY	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5,show_HAPPY_TEXT,SW*1*2/4
		DW _PRINT8_NUMBER_CENT,HAPPY_HOUR_TOTAL,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		DW _JINGLE,S_MULTILJUD
		CLEARIT
		
no_happy_stewartTS LABEL WORD
		DW _JBCDZ,MEGA_LAUGH_TOTAL,no_MEGA_LAUGHTS
		CLEARIT
		DW _CALC_MEGA	;CYCLONESCOREBCD & SIFFRORNA UPPDATERAS!
		DW _PRINT5,show_MEGA_TEXT,SW*1*2/4
		DW _PRINT8_NUMBER_CENT,MEGA_LAUGH_TOTAL,SW*2*7/4+TOTCENT
		DW _WAIT,120	;CPW!
		DW _JINGLE,S_MULTILJUD
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
if demover
		DW _DEMOVER_CHANGE_PLAYER
else
		dw _waitifmulti,2*60	;cpgnu? (visa score lite lÑngre)
		DW _MATRIXLGT,0
		clearit
		DW _CHANGE_PLAYER
endif
		CLEARIT
		dw _wait,32000
		DW 0

SORRYNOBONUSTEXT DB '  SORRY ',94,' NO BONUS  ',0

shoot_again_onTS LABEL BYTE	;Turn on shoot again . . . 
		CLEARIT
		DW _FLASHON,SHOOT_AGAIN_SPEED
		DW _SHOOT_AGAIN_ONN,1
		DW _PRINT13,SHOOT_AGAIN_TEXT,SW*2/4*2 ;+16*3/4		;CP!
		DW _NEW_BALL2
		DW _PARTYON,1	;CP?
		DW 0


out_of_ballsTS	LABEL WORD		;ér Stewarts fortfarande borta kanske?
		CLEARIT
		dw _matrixlgt,1
		dw _knacket,?
		dw _wait,120

check_xxballTS LABEL WORD
		DW _check_xxballs	;utfîr ev xxballs, hoppar sedan till after_xxballs!

after_xxballTS	LABEL WORD
		clearit
		dw _check_high,?
		DW _MATRIXLGT,0
		DW _2_DEMO_MODE


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

DRSPEED=13
DSCORETS	LABEL WORD
		CLEARIT
		DW _FLASHON,DRSPEED
		DW _PRINT13_NUMBER_CENT,BCD250000,2*2*SW/4+TOTCENT
		DW _WAIT,DRSPEED*2*3-DRSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

RSCORE1TS	LABEL WORD
		CLEARIT
		DW _FLASHON,DRSPEED
		DW _PRINT13_NUMBER_CENT,BCD250000,2*2*SW/4+TOTCENT
		DW _WAIT,DRSPEED*2*3-DRSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

RSCORE2TS	LABEL WORD
		CLEARIT
		DW _FLASHON,DRSPEED
		DW _PRINT13_NUMBER_CENT,BCD500000,2*2*SW/4+TOTCENT
		DW _WAIT,DRSPEED*2*3-DRSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

RSCORE3TS	LABEL WORD
		CLEARIT
		DW _FLASHON,DRSPEED
		DW _PRINT13_NUMBER_CENT,BCD750000,2*2*SW/4+TOTCENT
		DW _WAIT,DRSPEED*2*3-DRSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

snackTS		LABEL WORD
		ASSUME	DS:DATA
		dw _scroll,snacktext
		clearit
		dw 0

iceTS		LABEL WORD
		clearit
		DW _FLASHON,1
		dw _print13,icetext,sw*2*2/4+16*3/4+2
		DW _WAIT,140
		clearit
		DW _FLASHOFF,?
		dw 0

sodaTS		LABEL WORD
		clearit
		DW _FLASHON,1
		dw _print13,sodatext,sw*2*2/4+16*3/4+2
		DW _WAIT,140
		clearit
		DW _FLASHOFF,?
		dw 0

popTS		LABEL WORD
		clearit
		DW _FLASHON,1
		dw _print13,poptext,sw*2*2/4+16*2/4-2
		DW _WAIT,140
		clearit
		DW _FLASHOFF,?
		dw 0

noducksTS	LABEL WORD
		clearit
		DW _FLASHON,6
		dw _print13,nosnacktext,sw*2*2/4
		DW _WAIT,100-6*2
		clearit
		DW _FLASHOFF,?
		dw 0

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

hiddenTS	LABEL WORD
		DW _SCROLL,HIDDENTEXT
		DW _TSEND,?
		DW _WAIT,1
		DW 0

ride1TS		dw _scroll,ride1text		
		dw 0
ride2TS		dw _scroll,ride2text		
		dw 0
ride3TS		dw _scroll,ride3text		
		dw 0

skillcycloneTS	LABEL WORD
		clearit
		DW _FLASHON,1
		dw _print13,skillcycloneTEXT,sw*2*2/4
		dw _wait,40
		CLEARIT
		DW _FLASHOFF,?
		DW _FLASHON,10
		DW _PRINT13_NUMBER_CENT,SKILL_SCORE2,2*2*SW/4+TOTCENT
		DW _WAIT,10*2*3-10
		CLEARIT
		DW _FLASHOFF,?
		DW 0

skilltunnelTS	LABEL WORD
		clearit
		DW _FLASHON,1
		dw _print13,skilltunnelTEXT,sw*2*2/4
		dw _wait,40
		CLEARIT
		DW _FLASHOFF,?
		DW _FLASHON,10
		DW _PRINT13_NUMBER_CENT,SKILL_SCORE,2*2*SW/4+TOTCENT
		DW _WAIT,10*2*3-10
		CLEARIT
		DW _FLASHOFF,?
		dw 0

sidelaneTS	dw _scroll,SIDELANETEXT
		dw 0

crazyletterTS	LABEL	WORD
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,CRAZYLETTERTEXT,SW*2*2/4
		DW _WAIT,50
		DW _WAITJINGLE,?
		CLEARIT
		DW _FLASHOFF,?
		DW 0

nothingTS	LABEL	WORD
		CLEARIT
		DW _FLASHON,15
		dw _print13,nothingtext,sw*2*2/4+16*6/4
		DW _WAIT,15*3
		CLEARIT
		DW _FLASHOFF,?
		DW 0

femhundraTS	LABEL WORD
		CLEARIT
		DW _FLASHON,DRSPEED
		DW _PRINT13_NUMBER,OFFSET FEMHUNDRATUSEN,SW*2/4*2+16*1/4
		DW _WAIT,DRSPEED*2*3-DRSPEED
		CLEARIT
		DW _FLASHOFF,?
		DW 0

bonusheldTS	LABEL WORD
		CLEARIT
		DW _FLASHON,1
		DW _PRINT13,BONUSHELDTEXT,SW*2/4*2+2
		DW _WAIT,110
		CLEARIT
		DW _FLASHOFF,?
		DW 0

DoubleBTS	LABEL WORD
		CLEARIT
		DW _FLASHON,1
		dw _print13,DOUBLEBONUSTEXT,sw*2/4*2+2+2
		DW _WAIT,100
		CLEARIT
		DW _FLASHOFF,?
		DW 0

tiltTS		LABEL WORD
		DW _EOSNURR,?
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
		
NO_MEGA_TEXT	LABEL BYTE
NO_HAPPY_TEXT	DB 'TIME OUT ',94,' NO  BONUS',0

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

SNACKTEXT	DB 21 DUP (1)
		DB 'GO GET A SNACK DUDE'
		DB 21 DUP (1),255

ICETEXT 	DB 'COLD ICECREAM',0

SODATEXT	DB 'SODA WITH ICE',0

POPTEXT		DB 'EAT SOME POPCORNS',0
		

NOSNACKTEXT	dB 'HIT SOME DUCKS FIRST',0

GETTING_SICK_TEXT DB 'GETTING SICK HUH',0

PARTY_ON_TEXT DB ' PARTY ON  PLAYER  ',0
all_targa_	db 21 DUP (1),'ALL TARGETS SCORE 1000000',21 DUP(1),255	;CP!
hhtotal_text	db '  HAPPY HOUR TOTAL',0
ZEROQ		DB '0'+7,0
mltotal_text	db 21 DUP (1),'  MEGA LAUGH TOTAL  ',255
SHOOT_AGAIN_TEXT DB 'SHOOT AGAIN PLAYER  ',0
NO_OF_PLAYERS_TEXT DB 'PLAYERS X',0
NOLLA		DB '7',0
show_bonus_TEXT DB 'BONUS',0
show_totalbonus_TEXT DB 'TOTAL*BONUS',0
BONUS_X_TEXT 	DB 'BONUS*X*?',0
show_CYCLONES_TEXT DB '    CYCLONES X',0
SHOW_HAPPY_TEXT	DB '  HAPPY HOUR TOTAL',0
SHOW_MEGA_TEXT	DB '  MEGA LAUGH TOTAL',0

HIDDENTEXT	DB 21 DUP (1)
		DB 'YOU FOUND THE HIDDEN ENTRANCE ',94,' GO FOR THE CYCLONE' ;CP?
		DB 21 DUP (1),255

RIDE1TEXT	DB 21 DUP (1)
		DB 'DO THE SKYRIDE MAN '
		DB 21 DUP (1),255

RIDE2TEXT	DB 21 DUP (1)
		DB 'GO FOR IT AGAIN FELLOW'
		DB 21 DUP (1),255

RIDE3TEXT	DB 21 DUP (1)
		DB 'REACHED THE SKY'
		DB 21 DUP (1),255

SKILLCYCLONETEXT DB ' CYCLONE SKILL SHOT',0

SKILLTUNNELTEXT	db ' TUNNEL SKILL SHOT',0
		
CRAZYLETTERTEXT DB 'CRAZY LETTER SPOTTED',0
		
SIDELANETEXT	DB 21 DUP (1)
		DB 'SIDE LANE EXTRA BALL IS LIT'
		DB 21 DUP (1),255
		
nothingtext	DB  'NO SCORE',0
		
femhundratext	DB 21 DUP (1)
		db 'FEMHUNDRATUSEN'
		DB 21 DUP (1),255
		
bonusheldtext	db 'B O N U S   H E L D',0
DOUBLEBONUStext	db 'X9 DOUBLE BONUS X9',0	;9=2
		

fivetext	DB 21 DUP (1)
		db '5'
		DB 21 DUP (1),255
_onemoreformad	db 1+65-10,' MORE FOR MAD',0
_twomoreformad	db 2+65-10,' MORE FOR MAD',0
		
PF_TEXT		DB '  PINBALL FANTASIES',0
TRS_TEXT	DB ' THE REAL SIMULATOR',0
PL_TEXT		DB '     PARTY LAND',0
SCROLL_TEXT1	DB 21 DUP (' '),'ADD PLAYERS WITH F1 TO F8 OR ENTER ',21 DUP (' ')
		DB 'WINNERS DO NOT USE DRUGS',21 DUP (' '),255		
ALLTIME_TEXT	DB 'ALL TIME HIGHSCORES',0
fld_TEXT	DB '  FRONTLINE DESIGN',0
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
IF DEMOVER
playerstext	db 5+'7',' MIN DEMO',0		;8=1 (LôS EKVATIONEN!)
ELSE
playerstext	db 'PLAYER 8',0		;8=1 (LôS EKVATIONEN!)
ENDIF
BALLSTEXT	DB 'BALL 8',0		;8=1
hajjskar	db 'HIGHSCORE PL X ',92,'   ',93,0
stjaernor	db '********************',0
;******************************************************************************

DATA	ENDS


;***************************  Animations **************************************
DATA2 SEGMENT PARA PUBLIC 'DATA'
;*********************ANIMATIONS MALL*************************
	dw 1*4		;loop pos
	dw 15		;number of loops
	dw 5*4-4	;length of anim (5 frames * 4 bytes!)
_happy	dw happy_1,1;<---start!
	dw happy_2,2;<-, loop!
	dw happy_3,2;  I
	dw happy_4,2;  I 
	dw happy_5,2;__I
;**************************************************************

	dw 1*2		;loop pos
	dw 1		;number of loops
	dw 19*4	;length of anim (5 frames * 4 bytes!)
_cyclone	dw cyclo00,speed 
dw	cyclo01,speed
dw	cyclo02, speed
dw	cyclo03, speed
dw	cyclo04, speed
dw	cyclo05 ,speed
dw	cyclo06 ,speed
dw	cyclo07 ,speed
dw	cyclo08 ,speed
dw	cyclo09 ,speed
dw	cyclo10 ,speed
dw	cyclo11 ,speed
dw	cyclo12 ,speed
dw	cyclo13 ,speed
dw	cyclo14 ,speed
dw	cyclo15 ,speed
dw	cyclo16 ,speed
dw	cyclo17 ,speed
dw	cyclo18 ,40
	
	dw 0
	dw 20
	dw 4*3-4
_party_party dw party_1,1
	dw party_2,1
	dw party_3,2

	dw 0
	dw 20 	
	dw 4*3-4
_party_p dw party_1,1
	dw party_4,1
	dw party_5,2

	dw 0
	dw 20 	
	dw 4*3-4
_party_a dw party_1,1
	dw party_6,1
	dw party_7,2

	dw 0
	dw 20 	
	dw 4*3-4
_party_r dw party_1,1
	dw party_8,1
	dw party_9,2

	dw 0
	dw 20 	
	dw 4*3-4
_party_t dw party_1,1
	dw party_10,1
	dw party_11,2

	dw 0
	dw 20 	
	dw 4*3-4
_party_y dw party_1,1
	dw party_12,1
	dw party_13,2
	
	dw 0
	dw 1
megallen dw 4*28
megal	DW MEGAL00,4
dw	megal01,4
dw	megal02,4
dw	megal03 ,4
dw	megal04 ,4
dw	megal05 ,4
dw	megal06 ,4
dw	megal07 ,4
dw	megal08 ,4
dw	megal09 ,4
dw	megal10 ,4
dw	megal11 ,4
dw	megal12 ,4
dw	megal13 ,4
dw	megal14 ,4
dw	megal15 ,4
dw	megal16 ,4
dw	megal17 ,4
dw	megal18 ,4
dw	megal19 ,4
dw	megal20 ,4
dw	megal21 ,4
dw	megal22 ,4
dw	megal23 ,4
dw	megal24 ,4
dw	megal25 ,4
dw	megal26 ,4
dw	megal27,50
	
;*****************************
dw 1
dw 32*4
speed=7
_mystery dw	a_12_00,speed
dw	a_12_01,speed
dw	a_12_02,speed
dw	a_12_03 ,speed
dw	a_12_04 ,speed
dw	a_12_05 ,speed
dw	a_12_06 ,speed
dw	a_12_07 ,speed
dw	a_12_08 ,speed
dw	a_12_09 ,speed
dw	a_12_10 ,speed
dw	a_12_11 ,speed
dw	a_12_12 ,speed
dw	a_12_13 ,speed
dw	a_12_14 ,speed
dw	a_12_15 ,speed
dw	a_12_16 ,speed
dw	a_12_17 ,speed
dw	a_12_18 ,speed
dw	a_12_19 ,speed
dw	a_12_20 ,speed
dw	a_12_21 ,speed
dw	a_12_22 ,speed
dw	a_12_23 ,speed
dw	a_12_24 ,speed
dw	a_12_25 ,speed
dw	a_12_26 ,speed
dw	a_12_27 ,speed
dw	a_12_28 ,speed
dw	a_12_29 ,speed
dw	a_12_30 ,speed
dw	a_12_31 ,speed
;*************************

;*****************************
dw 1
dw 16*4
speed=3
_million dw	a_09_00,speed
dw	a_09_01,speed
dw	a_09_02,speed
dw	a_09_03 ,speed
dw	a_09_04 ,speed
dw	a_09_05 ,speed
dw	a_09_06 ,speed
dw	a_09_07 ,speed
dw	a_09_08 ,speed
dw	a_09_09 ,speed
dw	a_09_10 ,speed
dw	a_09_11 ,speed
dw	a_09_12 ,speed
dw	a_09_13 ,speed
dw	a_09_14 ,speed
dw	a_09_15 ,40
;*************************
dw 1
dw 16*4
speed=1
_millionFAST dw	a_09_00,speed
dw	a_09_01,speed
dw	a_09_02,speed
dw	a_09_03 ,speed
dw	a_09_04 ,speed
dw	a_09_05 ,speed
dw	a_09_06 ,speed
dw	a_09_07 ,speed
dw	a_09_08 ,speed
dw	a_09_09 ,speed
dw	a_09_10 ,speed
dw	a_09_11 ,speed
dw	a_09_12 ,speed
dw	a_09_13 ,speed
dw	a_09_14 ,speed
dw	a_09_15 ,40
;*************************
;*****************************
dw 2*4	;loop pos (word)
dw 5	;nof loops
dw 18*4	;length
speed=4
_jackpot dw	a_15_00,speed
dw	a_15_01,speed
dw	a_15_02,speed
dw	a_15_03 ,speed
dw	a_15_04 ,speed
dw	a_15_05 ,speed
dw	a_15_06 ,speed
dw	a_15_07 ,speed
dw	a_15_08 ,speed
dw	a_15_09 ,speed
dw	a_15_10 ,speed
dw	a_15_11 ,speed
dw	a_15_12 ,speed
dw	a_15_13 ,speed
dw	a_15_14 ,speed
dw	a_15_15 ,speed
dw	a_15_16 ,speed
dw	a_15_17 ,speed
dw	a_15_18 ,speed
;*************************

;*****************************
dw 1
dw 8*4
speed=2
_bonusx2 dw	a_03_00,speed
dw	a_03_01,speed
dw	a_03_02,speed
dw	a_03_03 ,speed
dw	a_03_04 ,speed
dw	a_03_05 ,speed
dw	a_03_06 ,speed
dw	a_03_07 ,40
;*************************
;*****************************
dw 1
dw 8*4
speed=2
_bonusx4 dw	a_04_00,speed
dw	a_04_01,speed
dw	a_04_02,speed
dw	a_04_03 ,speed
dw	a_04_04 ,speed
dw	a_04_05 ,speed
dw	a_04_06 ,speed
dw	a_04_07 ,40

;*************************
;*****************************
dw 1
dw 8*4
speed=2
_bonusx6 dw	a_05_00,speed
dw	a_05_01,speed
dw	a_05_02,speed
dw	a_05_03 ,speed
dw	a_05_04 ,speed
dw	a_05_05 ,speed
dw	a_05_06 ,speed
dw	a_05_07 ,40
;*************************
;*****************************
dw 1
dw 8*4
speed=2
_bonusx8 dw	a_06_00,speed
dw	a_06_01,speed
dw	a_06_02,speed
dw	a_06_03 ,speed
dw	a_06_04 ,speed
dw	a_06_05 ,speed
dw	a_06_06 ,speed
dw	a_06_07 ,40
;*************************
;*****************************
dw 1
dw 22*4
speed=4
_extraball dw	a_01_00,speed
dw	a_01_01,speed
dw	a_01_02,speed
dw	a_01_03 ,speed
dw	a_01_04 ,speed
dw	a_01_05 ,speed
dw	a_01_06 ,speed
dw	a_01_07 ,speed
dw	a_01_08 ,speed
dw	a_01_09 ,speed
dw	a_01_10 ,speed
dw	a_01_11 ,speed
dw	a_01_12 ,speed
dw	a_01_13 ,speed
dw	a_01_14 ,speed
dw	a_01_15 ,speed
dw	a_01_16 ,speed
dw	a_01_17 ,speed
dw	a_01_18 ,speed
dw	a_01_19 ,speed
dw	a_01_20 ,speed
dw	a_01_21 ,170
;*************************

;*****************************
dw 1
dw 35*4
_loop	dw	a_08_00,3
dw	a_08_01,3
dw	a_08_02,3
dw	a_08_03 ,3
dw	a_08_04 ,3
dw	a_08_05 ,3
dw	a_08_06 ,3
dw	a_08_07 ,3
dw	a_08_08 ,3
dw	a_08_09 ,3
dw	a_08_10 ,3
dw	a_08_11 ,3
dw	a_08_12 ,3
dw	a_08_13 ,3
dw	a_08_14 ,3
dw	a_08_15 ,3
dw	a_08_16 ,3
dw	a_08_17 ,3
dw	a_08_18 ,3
dw	a_08_19 ,3
dw	a_08_20 ,3
dw	a_08_21 ,3
dw	a_08_22 ,3
dw	a_08_23 ,3
dw	a_08_24 ,3
dw	a_08_25 ,3
dw	a_08_26 ,3
dw	a_08_27 ,3
dw	a_08_28 ,3
dw	a_08_29 ,3
dw	a_08_30 ,3
dw	a_08_31 ,3
dw	a_08_32 ,3
dw	a_08_33 ,3
dw	a_08_34 ,30
	
;*************************



extrn	MEGAL00,megal01,megal02 ,megal03 ,megal04 ,megal05 ,megal06 ,megal07 ,megal08 ,megal09 ,megal10,megal11 ,megal12 ,megal13 ,megal14 ,megal15 ,megal16 ,megal17 ,megal18 ,megal19 ,megal20 ,megal21 ,megal22 ,megal23 ,megal24 ,megal25 ,megal26 ,megal27:byte
extrn	a_09_00,a_09_01,a_09_02 ,a_09_03 ,a_09_04 ,a_09_05 ,a_09_06 ,a_09_07 ,a_09_08 ,a_09_09 ,a_09_10,a_09_11 ,a_09_12 ,a_09_13 ,a_09_14 ,a_09_15 
extrn	a_03_00,a_03_01,a_03_02 ,a_03_03 ,a_03_04 ,a_03_05 ,a_03_06 ,a_03_07  
extrn	a_04_00,a_04_01,a_04_02 ,a_04_03 ,a_04_04 ,a_04_05 ,a_04_06 ,a_04_07  
extrn	a_05_00,a_05_01,a_05_02 ,a_05_03 ,a_05_04 ,a_05_05 ,a_05_06 ,a_05_07  
extrn	a_06_00,a_06_01,a_06_02 ,a_06_03 ,a_06_04 ,a_06_05 ,a_06_06 ,a_06_07  
extrn	party_1,party_2 ,party_3 ,party_4 ,party_5 ,party_6 ,party_7 ,party_8 ,party_9 ,party_10,party_11 ,party_12 ,party_13 ,party_14 
extrn	cyclo00,cyclo01,cyclo02 ,cyclo03 ,cyclo04 ,cyclo05 ,cyclo06 ,cyclo07 ,cyclo08 ,cyclo09 ,cyclo10,cyclo11 ,cyclo12 ,cyclo13 ,cyclo14 ,cyclo15 ,cyclo16,cyclo17,cyclo18,cyclo19,cyclo20
extrn	a_12_00,a_12_01,a_12_02,a_12_03 ,a_12_04 ,a_12_05 ,a_12_06 ,a_12_07 ,a_12_08 ,a_12_09 ,a_12_10 ,a_12_11 ,a_12_12 ,a_12_13 ,a_12_14 ,a_12_15 ,a_12_16 ,a_12_17 ,a_12_18 ,a_12_19 ,a_12_20 ,a_12_21 ,a_12_22 ,a_12_23 ,a_12_24 ,a_12_25 ,a_12_26 ,a_12_27 ,a_12_28 ,a_12_29 ,a_12_30 ,a_12_31 ,a_12_32 ,a_12_33 ,a_12_34 ,a_12_35
extrn	a_08_00,a_08_01,a_08_02,a_08_03 ,a_08_04 ,a_08_05 ,a_08_06 ,a_08_07 ,a_08_08 ,a_08_09 ,a_08_10 ,a_08_11 ,a_08_12 ,a_08_13 ,a_08_14 ,a_08_15 ,a_08_16 ,a_08_17 ,a_08_18 ,a_08_19 ,a_08_20 ,a_08_21 ,a_08_22 ,a_08_23 ,a_08_24 ,a_08_25 ,a_08_26 ,a_08_27 ,a_08_28 ,a_08_29 ,a_08_30 ,a_08_31 ,a_08_32 ,a_08_33 ,a_08_34 
extrn	a_01_00,a_01_01,a_01_02,a_01_03 ,a_01_04 ,a_01_05 ,a_01_06 ,a_01_07 ,a_01_08 ,a_01_09 ,a_01_10 ,a_01_11 ,a_01_12 ,a_01_13 ,a_01_14 ,a_01_15 ,a_01_16 ,a_01_17 ,a_01_18 ,a_01_19 ,a_01_20 ,a_01_21 ,a_01_22  
extrn	a_15_00,a_15_01,a_15_02,a_15_03 ,a_15_04 ,a_15_05 ,a_15_06 ,a_15_07 ,a_15_08 ,a_15_09 ,a_15_10 ,a_15_11 ,a_15_12 ,a_15_13 ,a_15_14 ,a_15_15 ,a_15_16 ,a_15_17  ,a_15_18  
extrn	happy_1,happy_2 ,happy_3 ,happy_4 ,happy_5 
;megal11?
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
	CALL	CREATEGATE1
	CALL	SLACK_LIGHTS
	RETN


WHEN_NEW_GAME_RESET_TABLE:
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	MOVEBCD	JACKVALUE,JACKINIT
	CALL	RESET_VARS2
	CALL	RESET_VARS
	CALL	UPDATE_P_STRUC_4_ALL_PLAYERS
	MOV	XBALLS,0
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


;	CALL	INIT_JACK
RESET_VARS2:
	NIL	AX
	MOVE	ES,DS

	MOV	DI,OFFSET SIFFRORNA
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOV	CX,6
	REP	STOSW

	MOV	CYCLONECOUNTER,0
	MOV	DI,OFFSET CYCLONECOUNTERBCD
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET CYCLONESCOREBCD
	MOV	CX,6
	REP	STOSW

	MOV	DI,OFFSET SKILL_SCORE
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET SKILL_SCORE2
	MOV	CX,6
	REP	STOSW

	;cleara slutsiffrorna (di alla!) (Fîr knacket alltsÜ!!!)
	push	es
	move	es,ds
	MOV	di,offset last_text
	mov	al,' '
	mov	cx,8*2
	rep	stosb
	pop	es
;	MOV	XXBALLE,FALSE
	RETN



WHEN_NEW_BALL_RESET_TABLE:
	CALL	SLACK_LIGHTS
	CALL	RESETFLASHLIST
	CALL	RESET_VARS
	CALL	P_STRUC_2_VARS
	RETN

RESET_VARS:
	MOVE	ES,DS
	NIL	AX
	MOV	BONUS_TEXT[11],'8'
;	MOV	play_TEXT[18],'8'	;cpp
;	MOV	play_TEXT[8],'8'	;cpp
	MOV	DI,OFFSET HAPPY_HOUR_TOTAL
	MOV	CX,6
	REP	STOSW
	MOV	DI,OFFSET MEGA_LAUGH_TOTAL
	MOV	CX,6
	REP	STOSW

	MOV	BALLHIGH,FALSE

	MOV	SNACKSYNCER,0			;SYNCER VARS
	MOV	ARROWSYNCER,0
	MOV	PUKESYNCER,0
	MOV	TRAINSYNCER,0
	MOV	SNACKCOUNTER,0

	MOV	ICEFLASHING,FALSE		;FLASHING VARS
	MOV	SODAFLASHING,FALSE
	MOV	POPFLASHING,FALSE
	MOV	ARCADEON,FALSE
	MOV	MBFLASHING,FALSE
	MOV	BONUSMULTIPEL,1
	MOV	HBFLASHING,FALSE
	MOV	DBFLASHING,FALSE
	MOV	_5XFLASHING,FALSE
	MOV	_5MFLASHING,FALSE
	MOV	BALLFLASHING,FALSE
	MOV	JPFLASHING_NORMAL,FALSE
	MOV	JPFLASHING_TIME,FALSE

	MOV	D1DISABLED,FALSE		;DISABLE VARS
	MOV	D2DISABLED,FALSE
	MOV	D3DISABLED,FALSE
	MOV	TOUCHERDISABLED,FALSE
	MOV	SNACKDISABLED,FALSE
	MOV	INH_REV,FALSE
	MOV	INH_LOOP,FALSE
	MOV	INHIBIT_REVERSE_COUNTER,0
	MOV	PUKEFORBIDDEN,FALSE
	MOV	DRAGON,FALSE

	MOV	TUNNELDOWNCOUNTER,0		;SYNC COUNTERS
	MOV	ANY_LOOP_DOWN_COUNTER,0
	MOV	REVERSE_DOWN_COUNTER,0

	MOV	POPCOUNTER,0			;FEATURE COUNTERS
	MOV	SKYRIDECOUNTER,0
	MOV	PUKECOUNTER,0
	MOV	BALOONCOUNTER,0

	MOV	HAPPY_HOUR,FALSE		;MODE FLAGS
	MOV	MEGA_LAUGH,FALSE
	MOV	HOLDBONUSFLAG,FALSE

	MOV	EOTS,TRUE

	MOV	CRAZY_ADVANCE_LIST[0],0

	CALL	RESETFLASHLIST
	CALL	SLACK_LIGHTS

	LIGHTON	52
	LIGHTON	53
	LIGHTON	54
	LIGHTFLASH 14,TUNNELSPEED	;1M (TUNNEL)
	LIGHTFLASH 26,BALOONSPEED	;250K (REVERSE)

	CALL	DOLIGHTS		;FLUSH THE BUFFERT

	CALL	RESTORED1		;RESTORE DUCK TARGETS
	CALL	RESTORED2
	CALL	RESTORED3

	MOV	BONUS_X,1
;HéR VAR DEN! ;	mov	paRTYFLASh,false

	RETN

;******************************************************************************



DEMO_MUSIC PROC NEAR
	CMP	no_demomusic,TRUE
	JE	OOPS_HIGH ;CP!
	CMP	HIGHSCORE,TRUE
	JE	OOPS_HIGH ;CP!
	PLAYJINGLE S_NOHIGH
	MOV	AL,S_NOHIGH[2]
	MOV	LASTPRIORITY,AL
	MOV	LASTJINGLE,9 ;9=NOHIGH ;SVEN
	MOV	JINGLEJUMPCNT,1
OOPS_HIGH:
	mov	no_demomusic,false
	RETN
DEMO_MUSIC ENDP

GAME_MUSIC PROC NEAR
;	ADDTASK	TYSTAVOICE
	PLAYJINGLE S_ADDPLAYER ;S_SPRING
	MOV	AL,S_SPRING+2
	MOV	LASTPRIORITY,AL
	MOV	LASTJINGLE,0
	RETN
TYSTAVOICE:
;	WAITSYNCS 10 ;CPW!
;	SOUNDEFFECT 1eH,1	;TYSTA STéMMA 4
;	SUICIDE
GAME_MUSIC ENDP

;******************************** LOOSE BALL **********************************
LOOSE_BALL PROC NEAR
	MOV	LOOSING,TRUE
	MOV	SCREENFORCE2,576-SH_LO+SPLH ;CP?
	CMP	HI_RES,TRUE
	JNE	NOTHIRES14
	MOV	SCREENFORCE2,576-SH_HI+SPLH ;CP?
NOTHIRES14:
	SETBALLPOS DROPX,DROPY,DROPXS,DROPYS,FALSE ;INTE CP.
	MOV	ALLOWFLIP,FALSE	;KILL FLIPPERS!

	MOV	SPECIALMODE,FALSE
	MOV	HAPPY_HOUR,FALSE
	MOV	MEGA_LAUGH,FALSE
	
	CMP	SCORECHANGED,FALSE
	JNE	NOT_ITS_PARTY_ON

	MOV	CURRENT_PRIORITY,0
	MOV	BX,OFFSET party_onTS
	CALL	DO_MATRIX
	PLAYJINGLE S_SPRING ;FIAT DUO
	MOV	MUSICOK,TRUE
	ADDTASK	PARTY_ON_TASK1
	RETN

PARTY_ON_TASK1:		;WAIT FOR PARTY ON
	WAITSYNCS 30
	MOV	PARTYFLASH,TRUE
	CALL	NEW_BALL
	RETN	;PGA NEWBALL


NOT_ITS_PARTY_ON:
if demover
	cmp	fiveminutes,true
	je	endofsession
endif
	MOV	CURRENT_PRIORITY,0
	EFFECT	LOSTBALL	
	MOV	CURRENT_PRIORITY,0
	MOV	LASTJINGLE,62
;	MOV	LASTLOOPVAL,0
	ADDTASK SOUNDRINNER
	RETN

SOUNDRINNER:
	WAITSYNCS 5
	SOUNDEFFECT SRINNER,0
	SUICIDE

if demover
endofsession:
	effect	minute5
	retn	
endif

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

;*******************************
_DEMOVER_CHANGE_PLAYER:
	PUSH	BX
	CMP	HOLDBONUSFLAG,TRUE
	JNE	NOT_HB_TRUEDV
	MOV	SI,OFFSET TEMPSIFFRORNA		;HOLD THE BONUS!
	MOV	DI,OFFSET BONUSSIFFRORNA
	MOVE	ES,DS
	MOV	CX,6
	REP	MOVSW
NOT_HB_TRUEDV:
;	MOV	AL,1
;	ADD	AL,'7'	;SEPEKOMPENSERING
;	MOV	BALLSTEXT[5],AL

	INC	BALLSTEXT[5]	;CP! DEMOVER
	CMP	BALLSTEXT[5],'7'+10
	JB	NOIH
	MOV	BALLSTEXT[5],'7'
	CMP	BALLSTEXT[4],'7'+1
	JNE	DOMOV
	INC	BALLSTEXT[4]
	JMP	NOIH
DOMOV:	MOV	BALLSTEXT[4],'7'+1	;CP! DEMOVER
NOIH:
	CALL	VARS_2_P_STRUC			;STORE TABLE AND SCORE!
;	CALL	NEW_BALL
	ADDTASK NEW_BALL_TASK			;TO GAME FROM GAME
	POP	BX
	JMP	HU_
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
if	demover
else
	MOV	PLAYERSTEXT[7],0+'7'	
endif
;cpp	MOV	PLAY_TEXT[8],0+'7'
	MOV	AL,PLAYERS
	MOV	CS:SHOWER,AL
	inc	CS:SHOWER
	
	MOV	SISA,1
	mov	dotrut,offset WAITRUT
	jmp	normal_end	
_SHOW_SCORE:
IF DEMOVER
ELSE
	INC	PLAYERSTEXT[7]
ENDIF
;cpp	INC	PLAY_TEXT[8]
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
	
_knacket:
	mov	dotrut,offset knackrut1
	mov	sisa,1
	MOV	PLAYER,1		;FôR CHECK_XXBALL
	jmp	normal_end	


;tid mellan knack samt antal knack . . . 
	knacktid_HI=11 		;CPW!
	nof_banks_HI=22 	;CPW!
	knacktid_LO=9		;CPW!
	nof_banks_LO=23		;CPW!

knackrut1:
	PLAYJINGLE_PENETRATE S_endfig
	MOV	LASTJINGLE,62		;TYST EFTER FULLGJORD PENETRERING
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
	
	MOV	SI,NOF_BANKS_LO
	MOV	SISA,NOF_BANKS_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES32
	MOV	SI,NOF_BANKS_HI
	MOV	SISA,NOF_BANKS_HI
NOTHIRES32:
	
	MOV	CS:TIMGLAS,KNACKTID_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES30
	MOV	CS:TIMGLAS,KNACKTID_HI
NOTHIRES30:
	retn
timglas	dw ?
knackrut2:
	dec	cs:timglas
	jz	no_ret
	ret
no_ret:	
	push	si
	MOV	CS:TIMGLAS,KNACKTID_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES31
	MOV	CS:TIMGLAS,KNACKTID_HI
NOTHIRES31:
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
	;resten i deÑks e mellan nÜll Ü NIO!!!
	CMP	LAST_POS,DX
	JNE	NOT_THE_SAME
	INC	DX
	CMP	DX,10
	JB	NOW_ITS_OK
	MOV	DX,0
NOW_ITS_OK:
NOT_THE_SAME:
	mov	last_pos,dx
;	inc	last_pos
;	cmp	last_pos,10
;	jnae	over_iii
;	mov	last_pos,0
over_iii:
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
alla_glada db ?
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

;URBAN WAS HERE MAY 68
	mov	current_priority,0
	PLAYJINGLE S_Knacket
	MOV	JINGLEJUMPCNT,1
	mov	current_priority,0
	mov	lastjingle,55
	mov	si,0
retta_nuda:
	retn




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
IF	DEMOVER
ELSE
	MOV	PLAYERSTEXT[7],AL
ENDIF
	MOV	XXBALLE,TRUE
	MOV	MUSICOK,TRUE
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

	CMP	LIGHTSTATUS[51],TRUE		;LAUGH AGAIN?
	JE	LET_HIM_SHOOT_AGAIN2		;MEGA-HOPP

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
IF DEMOVER
ELSE
	MOV	PLAYERSTEXT[7],AL
ENDIF
;cpp	MOV	PLAY_TEXT[8],AL

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
	CMP	LIGHTSTATUS[51],TRUE		;LAUGH AGAIN?
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
;cpp	MOV	play_TEXT[18],AL

PLAYER_CHANGED:
	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
IF	DEMOVER
ELSE
	MOV	PLAYERSTEXT[7],AL
ENDIF
;cpp	MOV	play_TEXT[8],AL

	CALL	P_STRUC_2_VARS			;NEXT PLAYER!
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

LET_HIM_SHOOT_AGAIN2:		;2 INGèNGAR!
LET_HIM_SHOOT_AGAIN:		;2 INGèNGAR!
	DEC	XBALLS
	MOV	BX,OFFSET shoot_again_onTS
	MOV	NEXT_A,BX
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
	JNE	NOTHIRES15
	MOV	SCREENFORCE,BANH-(SH_HI-SPLH)
NOTHIRES15:
	MOV	CARMEN,-1
	call	zeroscore
	CALL	SLACK_LIGHTS
	MOV	ADDPLAYERS,TRUE
	LIGHTON	52
	LIGHTON	53
	LIGHTON	54
	SUICIDE

LOOSE_BALL ENDP



;******************************** NEW_BALL ************************************

NEW_BALL_TASK:
	WAITSYNCS 30
	CALL	NEW_BALL
	RETN	;PGA NEWBALL

NEW_BALL PROC NEAR	;ENDA SéTTET ATT Fè UT EN BOLL Pè BANAN!
	MOV	LOOSING,FALSE
	MOV	BALL_DOWN,FALSE
	MOV	I_UTSKJUT,TRUE

	CALL	WHEN_NEW_BALL_RESET
	CALL	WHEN_NEW_BALL_RESET_TABLE

	CMP	XBALLS,0
	JZ	NOLAUGHAGAINAGAIN
	LIGHTON 51
NOLAUGHAGAINAGAIN:

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



P_STRUC_2_VARS PROC NEAR	;INPUT:PLAYER
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA
				     
	UPDATE_LIGHT 1,PLAYER_AREA[BX+0].P_PUKE		;P
	UPDATE_LIGHT 2,PLAYER_AREA[BX+1].P_PUKE		;E
	UPDATE_LIGHT 4,PLAYER_AREA[BX+2].P_PUKE		;U
	UPDATE_LIGHT 5,PLAYER_AREA[BX+3].P_PUKE		;K

	UPDATE_LIGHT 6,PLAYER_AREA[BX+0].P_MAD		;M
	UPDATE_LIGHT 8,PLAYER_AREA[BX+1].P_MAD		;A
	UPDATE_LIGHT 9,PLAYER_AREA[BX+2].P_MAD		;D

	UPDATE_LIGHT 41,PLAYER_AREA[BX+0].P_CRAZY	;Y
	UPDATE_LIGHT 38,PLAYER_AREA[BX+1].P_CRAZY	;Z
	UPDATE_LIGHT 34,PLAYER_AREA[BX+2].P_CRAZY	;A
	UPDATE_LIGHT 31,PLAYER_AREA[BX+3].P_CRAZY	;R
	UPDATE_LIGHT 28,PLAYER_AREA[BX+4].P_CRAZY	;C

	UPDATE_LIGHT 42,PLAYER_AREA[BX+0].P_PARTY	;P
	UPDATE_LIGHT 43,PLAYER_AREA[BX+1].P_PARTY	;A
	UPDATE_LIGHT 44,PLAYER_AREA[BX+2].P_PARTY	;R
	UPDATE_LIGHT 45,PLAYER_AREA[BX+3].P_PARTY	;T
	UPDATE_LIGHT 46,PLAYER_AREA[BX+4].P_PARTY	;Y

	CALL	DOLIGHTS		;FLUSH THE BUFFERT

	MOVE	CYCLONECOUNTER,PLAYER_AREA[BX].P_CYCLONECOUNTER

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

	LEA	SI,PLAYER_AREA[BX].P_SKILL_SCORE
	MOV	DI,OFFSET SKILL_SCORE
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_SKILL_SCORE2
	MOV	DI,OFFSET SKILL_SCORE2
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_CYCLONECOUNTERBCD
	MOV	DI,OFFSET CYCLONECOUNTERBCD
	MOV	CX,12/2
	REP	MOVSW

	LEA	SI,PLAYER_AREA[BX].P_CYCLONESCOREBCD
	MOV	DI,OFFSET CYCLONESCOREBCD
	MOV	CX,12/2
	REP	MOVSW

	RETN
P_STRUC_2_VARS ENDP


VARS_2_P_STRUC PROC NEAR
	MOV	BL,PLAYER
	DEC	BL
	NIL	BH
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA

VARS_2_P_STRUC_2:		;USED BY WHEN_NEW_GAME_RESET!
	UPDATE_PSTRUC PLAYER_AREA[BX+0].P_PUKE,1	;P
	UPDATE_PSTRUC PLAYER_AREA[BX+1].P_PUKE,2	;E
	UPDATE_PSTRUC PLAYER_AREA[BX+2].P_PUKE,4	;U
	UPDATE_PSTRUC PLAYER_AREA[BX+3].P_PUKE,5	;K

	UPDATE_PSTRUC PLAYER_AREA[BX+0].P_MAD,6		;M
	UPDATE_PSTRUC PLAYER_AREA[BX+1].P_MAD,8		;A
	UPDATE_PSTRUC PLAYER_AREA[BX+2].P_MAD,9		;D

	UPDATE_PSTRUC PLAYER_AREA[BX+0].P_CRAZY,41	;Y
	UPDATE_PSTRUC PLAYER_AREA[BX+1].P_CRAZY,38	;Z
	UPDATE_PSTRUC PLAYER_AREA[BX+2].P_CRAZY,34	;A
	UPDATE_PSTRUC PLAYER_AREA[BX+3].P_CRAZY,31	;R
	UPDATE_PSTRUC PLAYER_AREA[BX+4].P_CRAZY,28	;C

	UPDATE_PSTRUC PLAYER_AREA[BX+0].P_PARTY,42	;P
	UPDATE_PSTRUC PLAYER_AREA[BX+1].P_PARTY,43	;A
	UPDATE_PSTRUC PLAYER_AREA[BX+2].P_PARTY,44	;R
	UPDATE_PSTRUC PLAYER_AREA[BX+3].P_PARTY,45	;T
	UPDATE_PSTRUC PLAYER_AREA[BX+4].P_PARTY,46	;Y

	CALL	DOLIGHTS		;FLUSH THE BUFFERT

	MOVE	PLAYER_AREA[BX].P_CYCLONECOUNTER,CYCLONECOUNTER

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

	LEA	DI,PLAYER_AREA[BX].P_SKILL_SCORE
	MOV	SI,OFFSET SKILL_SCORE
	MOV	CX,12/2
	REP	MOVSW

	LEA	DI,PLAYER_AREA[BX].P_SKILL_SCORE2
	MOV	SI,OFFSET SKILL_SCORE2
	MOV	CX,12/2
	REP	MOVSW

	LEA	DI,PLAYER_AREA[BX].P_CYCLONECOUNTERBCD
	MOV	SI,OFFSET CYCLONECOUNTERBCD
	MOV	CX,12/2
	REP	MOVSW

	LEA	DI,PLAYER_AREA[BX].P_CYCLONESCOREBCD
	MOV	SI,OFFSET CYCLONESCOREBCD
	MOV	CX,12/2
	REP	MOVSW

	RETN
VARS_2_P_STRUC ENDP



;******************************** TILT TILT TILT ******************************
HE_TILTED PROC NEAR
	MOV	ALLOWFLIP,FALSE
	PLAYJINGLE S_TILT	
	MOV	LASTJINGLE,62
	MOV	BX,OFFSET tiltTS
	CALL	DO_MATRIX
	CALL	RESETFLASHLIST
	CALL	SLACK_LIGHTS
	MOV	EOTS,TRUE
	RETN
HE_TILTED ENDP

HE_ALMOST_TILTED PROC NEAR
	PLAYJINGLE S_DANGER
	RETN
ENDP


;********************************* CHECK SHIFTKEYS ****************************

CHECK_SHIFTKEYS PROC NEAR
	CMP	PUKEFORBIDDEN,TRUE
	JE	NOPUKING
	CMP	SHIFTPRESSED,TRUE
	JNE	NO_SHIFT
	MOV	SHIFTPRESSED,FALSE
	MOV	DL,LIGHTSTATUS[5]	;K
	CMP	LIGHTSTATUS[2],TRUE	;E	;E -> K
	JNE	KILL_K
	LIGHTON	5			;K
	JMP	K_READY
KILL_K:	LIGHTOFF 5			;K
K_READY:
	CMP	LIGHTSTATUS[1],TRUE	;P	;P -> E
	JNE	KILL_E
	LIGHTON	2			;E
	JMP	E_READY
KILL_E:	LIGHTOFF 2			;E
E_READY:
	CMP	LIGHTSTATUS[4],TRUE	;U	;U -> P
	JNE	KILL_P
	LIGHTON	1			;P
	JMP	P_READY
KILL_P:	LIGHTOFF 1			;P
P_READY:
	CMP	DL,TRUE			;K	;K -> U
	JNE	KILL_U
	LIGHTON	4			;U
	JMP	U_READY
KILL_U:	LIGHTOFF 4			;U
U_READY:
NOPUKING:
NO_SHIFT:
	RETN
CHECK_SHIFTKEYS ENDP



;******************************** GATES ROUTINES ******************************

CREATE_MASK_DATA PROC NEAR	;FN: OPENS OR CLOSES GATES
				;INPUT: DS:SI=SOURCE, ES:DI=DEST
				;       DX=WIDTH, CX=HEIGHT
NEXTLINE2:
	PUSH	CX
	MOV	CX,DX
	PUSH	SI
	REP	MOVSB
	POP	SI
	ADD	SI,40
	POP	CX
	LOOP	NEXTLINE2
	RETN
CREATE_MASK_DATA ENDP


CREATEGATE1:
	ASSUME	DS:MASK2_2
	MOV	SI,OFFSET MASK22+15*40+112/8		;DI
	MOVE	DS,MASK2_2
	ASSUME	DS:DATA
	MOV	DI,OFFSET GATE1CLOSED_DATA		;SI
	MOVE	ES,DATA
	MOV	DX,2					;DX=WIDTH
	MOV	CX,18					;CX=HEIGHT
	CALL	CREATE_MASK_DATA
	MOVE	DS,DATA
	RETN
KRG1_SPARAMINNE:
	ASSUME	DS:MASK2_2
	MOV	DI,OFFSET MASK22+15*40+112/8		;DI
	MOVE	ES,MASK2_2
	ASSUME	DS:DATA
	MOV	DX,2					;DX=WIDTH
	MOV	CX,18					;CX=HEIGHT
	CALL	MOVE_MASK_DATA
	MOVE	DS,DATA
	RETN
KILLGATE1:
	MOV	SI,OFFSET GATE1OPEN_DATA		;SI
	CALL	KRG1_SPARAMINNE
	RETN
RESTOREGATE1:
	MOV	SI,OFFSET GATE1CLOSED_DATA		;SI
	CALL	KRG1_SPARAMINNE
	RETN

KRD1_SPARAMINNE:
	ASSUME	DS:MASK1_2
	MOV	DI,OFFSET MASK12+277*40+144/8		;DI
	MOVE	ES,MASK1_2
	ASSUME	DS:DATA
	MOV	DX,2					;DX=WIDTH
	MOV	CX,15					;CX=HEIGHT
	CALL	MOVE_MASK_DATA
	MOVE	DS,DATA
	RETN
KILLD1:
	MOV	SI,OFFSET D1DOWN_DATA		;SI
	CALL	KRD1_SPARAMINNE
	RETN
RESTORED1:
	MOV	SI,OFFSET D1UP_DATA		;SI
	CALL	KRD1_SPARAMINNE
	RETN

KRD2_SPARAMINNE:
	ASSUME	DS:MASK1_2
	MOV	DI,OFFSET MASK12+295*40+152/8		;DI
	MOVE	ES,MASK1_2
	ASSUME	DS:DATA
	MOV	DX,2					;DX=WIDTH
	MOV	CX,15					;CX=HEIGHT
	CALL	MOVE_MASK_DATA
	MOVE	DS,DATA
	RETN
KILLD2:
	MOV	SI,OFFSET D2DOWN_DATA		;SI
	CALL	KRD2_SPARAMINNE
	RETN
RESTORED2:
	MOV	SI,OFFSET D2UP_DATA		;SI
	CALL	KRD2_SPARAMINNE
	RETN

KRD3_SPARAMINNE:
	ASSUME	DS:MASK1_2
	MOV	DI,OFFSET MASK12+313*40+160/8		;DI
	MOVE	ES,MASK1_2
	ASSUME	DS:DATA
	MOV	DX,1					;DX=WIDTH
	MOV	CX,15					;CX=HEIGHT
	CALL	MOVE_MASK_DATA
	MOVE	DS,DATA
	RETN
KILLD3:
	MOV	SI,OFFSET D3DOWN_DATA		;SI
	CALL	KRD3_SPARAMINNE
	RETN
RESTORED3:
	MOV	SI,OFFSET D3UP_DATA		;SI
	CALL	KRD3_SPARAMINNE
	RETN



;****************************** DROP ZONE TASK ********************************

START_DROP_TIMED:	;THIS IS A TASK!
	CMP	SPECIALMODE,TRUE
	JE	SNABBHOPP
	MOV	AX,DROP_TIME
	WAITSYNCS AX
SNABBHOPP:
	CALL	START_DROP
	SUICIDE

START_DROP PROC NEAR	;THIS IS A PROC!
	SETBALLPOS DROPX,DROPY,0,0,FALSE
	ADDTASK	RULLGARDIN
	ADDTASK	DROPTASK1
	MOVE	SCROLLPOS,START_RASTER
	RETN
START_DROP ENDP
SCROLLSPEED=5
SCROLLEND=0
DROPTASK1:
	WAITSYNCS 30	;30 -> MAX 1.5 SKéRM RULLGARDIN
	LIGHTFLASH 3,DROPSPEED
	LIGHTFLASH 56,DROPSPEED
	ADDTASK	DROPTASK2
	SUICIDE
DROPTASK2:
	WAITSYNCS DROPSPEED*4-1
	MOV	SCREENFORCE,-1
	MOV	BP,SLUMP_COUNTERN
	AND	BP,127		;GE DROPPET ETT SLUMPARTAT UTSKJUT
	ADD	BP,DROPYS
	SETBALLPOS DROPX,DROPY,DROPXS,BP,TRUE
	SOUNDEFFECT SNEWBALL,0
	ENDFLASH 3
	ENDFLASH 56
	SUICIDE

RULLGARDIN:		;DETTA éR EN TASK-RUTIN!
	ADDTASK	RULLGARDINSLAV
	MOVE	SCROLLPOS,START_RASTER
	SUICIDE
RULLGARDINSLAV:
	SUB	SCROLLPOS,SCROLLSPEED
	CMP	SCROLLPOS,SCROLLEND
	JNL	SPNOK2
	MOVE	SCREENFORCE,SCROLLEND
	SUICIDE
SPNOK2:	MOVE	SCREENFORCE,SCROLLPOS
	RETN



;************************* SUPER MODES CHECKS *********************************

CHECK_PARTY_COMPLETE PROC NEAR	;FN: CHECK PARTY LIGHTS.
				;OUTPUT: -C- IF TIME FOR HAPPY HOUR
	CMP	WORD PTR [OFFSET LIGHTSTATUS+42],0FFFFH
	JNE	NHAPPY
	CMP	WORD PTR [OFFSET LIGHTSTATUS+44],0FFFFH
	JNE	NHAPPY
	CMP	LIGHTSTATUS[46],TRUE
	JNE	NHAPPY
	STC
	RETN
NHAPPY:	CLC
	RETN
CHECK_PARTY_COMPLETE ENDP

CHECK_PARTY PROC NEAR
	CALL	CHECK_PARTY_COMPLETE
	JNC	NO_HAPPY_HOUR
	CMP	SPECIALMODE,TRUE
	JNE	OK_2_BE_HAPPY
	MOV	HAPPY_PENDING,TRUE
	JMP	NO_HAPPY_HOUR
	
OK_2_BE_HAPPY:		;NOTE: CALL TO THIS POINT!
	;* * *   H A P P Y   H O U R   * * *

	EFFECT	HAPPYHOUR
	MOV	LASTJINGLE,43 ;SJINGLE12
	LIGHTOFF 42	;P
	LIGHTOFF 43	;A
	LIGHTOFF 44	;R
	LIGHTOFF 45	;T
	LIGHTOFF 46	;Y
	CMP	JPFLASHING_NORMAL,TRUE
	JE	DNSTART_FLASH
	CMP	JPFLASHING_TIME,TRUE
	JE	DNSTART_FLASH
	SYNCEDFLASH 35,TRAINSPEED,TRAINSYNCER	;JP
DNSTART_FLASH:
	MOV	JPFLASHING_TIME,TRUE
	MOV	HAPPY_HOUR,TRUE
	LIGHTFLASH 32,WHEELSPEED
	MOV	SPECIALMODE,TRUE
	MOV	SUPER_INIT,TRUE
NO_HAPPY_HOUR:
	RETN
CHECK_PARTY ENDP


CHECK_CRAZY PROC NEAR	;INPUT -C- IF CRAZY COMPLETED
	JNC	NOT_CRAZY_TODAY
	CMP	SPECIALMODE,TRUE
	JNE	OK_2_LAUGH
	MOV	MEGA_PENDING,TRUE
	JMP	NOT_CRAZY_TODAY
	
OK_2_LAUGH:		;NOTE: CALL TO THIS POINT
	; * * * M E G A   L A U G H * * *

	EFFECT	CRAZYSCORE
	MOV	LASTJINGLE,25 ;SJINGLE11
	CMP	JPFLASHING_NORMAL,TRUE
	JE	DNSTART_FLASH2
	CMP	JPFLASHING_TIME,TRUE
	JE	DNSTART_FLASH2
	SYNCEDFLASH 35,TRAINSPEED,TRAINSYNCER	;JP
DNSTART_FLASH2:
	MOV	JPFLASHING_TIME,TRUE
	MOV	MEGA_LAUGH,TRUE
	LIGHTFLASH 37,WHEELSPEED
	MOV	SPECIALMODE,TRUE
	MOV	SUPER_INIT,TRUE
NOT_CRAZY_TODAY:
	RETN
CHECK_CRAZY ENDP


;******************************************************************************
;***************************** BRICKOR & KNAPPAR ******************************
;******************************************************************************

;************************* ARCADE TOUCHER **********************
TOUCHER:					;TURNS ARCADE ON
	CMP	TOUCHERDISABLED,TRUE
	JE	TDIS
	SOUNDEFFECT S_TOUCH2,0
	MOV	TOUCHERDISABLED,TRUE
	ADDTASK	ENABLETOUCHER
	CMP	ARCADEON,TRUE
	JE	DONT_YOU_BOTHER
	MOV	ARCADEON,TRUE
	LIGHTFLASH 7,12		;ARCADE1
	LIGHTFLASH 55,12	;ARCADE2
DONT_YOU_BOTHER:
TDIS:	RETN
ENABLETOUCHER:
	WAITSYNCS 20
	MOV	TOUCHERDISABLED,FALSE
	SUICIDE

;************************* DUCK1 *************************
DROPA1:						;UPPER DUCK
	CMP	LIGHTSTATUS+52,TRUE
	JNE	DROPA1ISDOWN
	CMP	D1DISABLED,TRUE
	JE	NODROPA1
	MOV	D1DISABLED,TRUE			;AVOID MULTIPLE HIT
	LIGHTOFF 52				;D1 (DUCKS)
	ADDTASK	KILL_THE_D1			;DôDA BRICKA
	CALL	DROPSETA
	CALL	CHECKALLDUCKS
	JC	DA1_MEGAHIT
	ADDTASK	TURNINGONDUCK1
	LIGHTFLASH 16,HITSPEED			;H (HIT)
	MOV	CS:TOD1_CNT,0
DA1_MEGAHIT:
DROPA1ISDOWN:
NODROPA1:
	RETN
TOD1_CNT	DB ?
TURNINGONDUCK1:
	CMP	CS:TOD1_CNT,HITSPEED*4+1
	JNE	TOD1_NOTYET
	ENDFLASH 16				;H (HIT)
	MOV	D1DISABLED,FALSE
	MOV	BX,SAVESOURCE
	MOV	DS:[BX],OFFSET DUMRET
TOD1_NOTYET:
	INC	CS:TOD1_CNT
	RETN
KILL_THE_D1:
	WAITSYNCS 20
	CALL	KILLD1
	SUICIDE

;************************* DUCK2 *************************
DROPA2:						;MIDDLE DUCK
	CMP	LIGHTSTATUS+53,TRUE
	JNE	DROPA2ISDOWN
	CMP	D2DISABLED,TRUE
	JE	NODROPA2
	MOV	D2DISABLED,TRUE			;AVOID MULTIPLE HIT
	LIGHTOFF 53				;D2 (DUCKS)
	ADDTASK	KILL_THE_D2			;DôDA BRICKA
	CALL	DROPSETA
	CALL	CHECKALLDUCKS
	JC	DA2_MEGAHIT
	ADDTASK	TURNINGONDUCK2
	MOV	CS:TOD2_CNT,0
	LIGHTFLASH 18,HITSPEED			;I (HIT)
DA2_MEGAHIT:
DROPA2ISDOWN:
NODROPA2:
	RETN
TOD2_CNT	DB ?
TURNINGONDUCK2:
	CMP	CS:TOD2_CNT,HITSPEED*4+1
	JNE	TOD2_NOTYET
	ENDFLASH 18				;I (HIT)
	MOV	D2DISABLED,FALSE
	MOV	BX,SAVESOURCE
	MOV	DS:[BX],OFFSET DUMRET
TOD2_NOTYET:
	INC	CS:TOD2_CNT
	RETN
KILL_THE_D2:
	WAITSYNCS 20
	CALL	KILLD2
	SUICIDE


;************************* DUCK3 *************************
DROPA3:						;LOWER DUCK
	CMP	LIGHTSTATUS+54,TRUE
	JNE	DROPA3ISDOWN
	CMP	D3DISABLED,TRUE
	JE	NODROPA3
	MOV	D3DISABLED,TRUE			;AVOID MULTIPLE HIT
	LIGHTOFF 54				;D3 (DUCKS)
	ADDTASK	KILL_THE_D3			;DôDA BRICKA
	CALL	DROPSETA
	CALL	CHECKALLDUCKS
	JC	DA3_MEGAHIT
	ADDTASK	TURNINGONDUCK3
	MOV	CS:TOD3_CNT,0
	LIGHTFLASH 24,HITSPEED			;T (HIT)
DA3_MEGAHIT:
DROPA3ISDOWN:
NODROPA3:
	RETN
TOD3_CNT	DB ?
TURNINGONDUCK3:
	CMP	CS:TOD3_CNT,HITSPEED*4+1
	JNE	TOD3_NOTYET
	ENDFLASH 24				;T (HIT)
	MOV	D3DISABLED,FALSE
	MOV	BX,SAVESOURCE
	MOV	DS:[BX],OFFSET DUMRET
TOD3_NOTYET:
	INC	CS:TOD3_CNT
	RETN
KILL_THE_D3:
	WAITSYNCS 20
	CALL	KILLD3
	SUICIDE

DROPSETA:
	SOUNDEFFECT SBRICKNER,0
	MOV	SI,OFFSET BCD7510
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD
	CALL	ADDHAPPY
	ADDBONUS BCD750
	mov	scorechanged,true
	RETN

CHECKALLDUCKS:
	CMP	LIGHTSTATUS+52,FALSE
	JNE	NOTALLDOWN
	CMP	LIGHTSTATUS+53,FALSE
	JNE	NOTALLDOWN
	CMP	LIGHTSTATUS+54,FALSE
	JNE	NOTALLDOWN

	;*** ALL DUCKS IS DOWN ***
	EFFECT	ALLDUCKS
	MOV	D1DISABLED,TRUE
	MOV	D2DISABLED,TRUE
	MOV	D2DISABLED,TRUE
	ENDFLASH 16
	ENDFLASH 18
	ENDFLASH 24
	LIGHTFLASH 16,2
	LIGHTFLASH 18,2
	LIGHTFLASH 24,2
	ADDTASK TURNOFFDUCKS
	
	;*** UPDATE SNACKS ***
	MOV	BL,SNACKCOUNTER
	NIL	BH
	CMP	SNACKFLASHERS[BX],TRUE
	JE	ALLISFLASHING	;OM NéSTA FLASHAR, Sè FLASHAR ALLA!
	CMP	SNACKCOUNTER,1
	JE	ITISSODA
	JA	ITISPOP
ITISICE:
	SYNCEDFLASH 23,SNACKSPEED,SNACKSYNCER	;ICE
	MOV	ICEFLASHING,TRUE
	JMP	SNACKFLASHOK
ITISSODA:
	INVERTEDSYNCEDFLASH 17,SNACKSPEED,SNACKSYNCER	;SODA
	MOV	SODAFLASHING,TRUE
	JMP	SNACKFLASHOK
ITISPOP:
	SYNCEDFLASH 20,SNACKSPEED,SNACKSYNCER	;POP
	MOV	POPFLASHING,TRUE
	JMP	SNACKFLASHOK

ALLISFLASHING:	;CP? SKALL SNACKCOUNTER VERKLIGEN INCAS?
SNACKFLASHOK:
	INC	SNACKCOUNTER
	CMP	SNACKCOUNTER,3
	JNE	SNACKCOUNTEROK
	MOV	SNACKCOUNTER,0
SNACKCOUNTEROK:
;	STARTSCROLL SNACKTEXT ;CP!
	STC
	RETN
NOTALLDOWN:
	CLC
	RETN

TURNOFFDUCKS:
	WAITSYNCS 71	;CPW!
	ENDFLASH 16
	ENDFLASH 18
	ENDFLASH 24
	LIGHTON 52				;D1 (DUCKS)
	CALL	RESTORED1			;SéTT DIT BRICKA D1
	LOFF	16				;H
	LIGHTON 53				;D2 (DUCKS)
	CALL	RESTORED2			;SéTT DIT BRICKA D2
	LOFF	18				;I
	LIGHTON 54				;D3 (DUCKS)
	CALL	RESTORED3			;SéTT DIT BRICKA D2
	LOFF	24				;T
	SOUNDEFFECT SBRICKUPP,0
	MOV	D1DISABLED,FALSE
	MOV	D2DISABLED,FALSE
	MOV	D3DISABLED,FALSE
	SUICIDE
	
COMMENT\
USE THIS CODE IF HITS ARE VALID DURING MEGAHIT-FLASHING
	CMP	LIGHTSTATUS[52],FALSE
	JE	TON16
	LOFF	16
	JMP	L16OK
TON16:	LON	16
L16OK:	CMP	LIGHTSTATUS[53],FALSE
	JE	TON18
	LOFF	18
	JMP	L18OK
TON18:	LON	18
L18OK:	CMP	LIGHTSTATUS[54],FALSE
	JE	TON24
	LOFF	24
	JMP	L24OK
TON24:	LON	24
L24OK:
\

;******************************************************************************
;********************************** LOWER *************************************
;******************************************************************************

;**************************** THE REVERSE LOOP! *******************************

BYGEL11:				;LEFT OF HOLE
	CMP	LASTAREA,OFFSET BYGEL9
	JNE	NOTREVERSE
	CMP	INHIBIT_REVERSE_COUNTER,0
	JNZ	JUST_FORGET_IT
	CMP	INH_REV,TRUE		;SHOULD NEVER HAPPEN!
	JE	NOTREVERSE

	;*** REVERSE LOOP! ***
	CALL	JACKADD
	CALL	ADDMEGALAUGH
	CMP	ANY_LOOP_DOWN_COUNTER,0
	JZ	NO_PARTY_T3
	CALL	DO_PARTY_T
NO_PARTY_T3:

	MOV	ANY_LOOP_DOWN_COUNTER,PARTY_T_TIME
	MOV	REVERSE_DOWN_COUNTER,PARTY_P_TIME
	INC	BALOONCOUNTER
	CMP	BALOONCOUNTER,1+1
	JB	B250K
	JE	B500K

	;*** GIVE HIM 750K ***
	MOV	BALOONCOUNTER,0
	ENDFLASH 19	;750K
	LIGHTFLASH 19,BALOONSPEEDFAST	;750K
	LIGHTFLASH 25,BALOONSPEEDFAST	;500K
	LIGHTFLASH 26,BALOONSPEEDFAST	;250K
	EFFECT RSCORE3
	ADDTASK	TURN_OFF_BALOONS
	MOV	INH_REV,TRUE
	JMP	BALLONS_READY

B500K:	;*** GIVE HIM 500K ***
	ENDFLASH 25	;500K
	LON	25	;500K
	LIGHTFLASH 19,BALOONSPEED	;750K
	EFFECT RSCORE2
	JMP	BALLONS_READY

B250K:	;*** GIVE HIM 250K ***
	ENDFLASH 26	;250K
	LON	26	;250K
	LIGHTFLASH 25,BALOONSPEED	;500K
	EFFECT RSCORE1
BALLONS_READY:

	;*** CHECK MULTIPEL BONUSES ***
	CMP	MBFLASHING,TRUE
	JNE	MBNOTFLASHING
	MOV	MBFLASHING,FALSE
	ENDFLASH 29	;MB
	LOFF	29	;MB

	CMP	LIGHTSTATUS[47],TRUE	;X2
	JE	NOT_X2
	;*** MULTIPEL BONUS X2 ***
	LIGHTON	47	;X2
	EFFECT	M2
	MOV	BONUSMULTIPEL,2
	JMP	XX_OK
NOT_X2:	
	CMP	LIGHTSTATUS[49],TRUE	;X4
	JE	NOT_X4
	;*** MULTIPEL BONUS X4 ***
	LIGHTON	49	;X4
	EFFECT	M4
	MOV	BONUSMULTIPEL,4
	JMP	XX_OK
NOT_X4:
	CMP	LIGHTSTATUS[50],TRUE	;X6
	JE	NOT_X6
	;*** MULTIPEL BONUS X6 ***
	LIGHTON	50	;X6
	EFFECT	M6
	MOV	BONUSMULTIPEL,6
	JMP	XX_OK
NOT_X6:
	CMP	LIGHTSTATUS[48],TRUE	;X8
	JE	NOT_X8	;SHOULD NEVER HAPPEN!
	;*** MULTIPEL BONUS X8 ***
	LIGHTON	48	;X8
	EFFECT	M8
	MOV	BONUSMULTIPEL,8
XX_OK:
	ADD	BONUS_X,2
	CMP	BONUS_X,3
	JNE	DNDECBX
	DEC	BONUS_X
DNDECBX:
	inc	bonus_text[11]		;îka frÜn 1 ->2 ->4 ->6 ->8
	cmp	bonus_text[11],'8'+1 ;x2
	je	noxinc
	inc	bonus_text[11]
noxinc:
NOT_X8:

MBNOTFLASHING:

	;*** CHECK HOLD BONUS ***
	CMP	HBFLASHING,TRUE
	JNE	HBNOTFLASHING
	MOV	HBFLASHING,FALSE
	ENDFLASH 33	;HB
	LOFF	33	;HB
	EFFECT	HOLDBONUS
	MOV	HOLDBONUSFLAG,TRUE
HBNOTFLASHING:

	;*** CHECK DOUBLE BONUS ***
	CMP	DBFLASHING,TRUE
	JNE	DBNOTFLASHING
	MOV	DBFLASHING,FALSE
	ENDFLASH 36	;DB
	LOFF	36	;DB
	EFFECT	DOUBLEBONUS
	MOV	SI,OFFSET BONUSSIFFRORNA
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD
DBNOTFLASHING:
NOTREVERSE:
	RETN
JUST_FORGET_IT:
	MOV	INHIBIT_REVERSE_COUNTER,0
	RETN


TURN_OFF_BALOONS:
	WAITSYNCS 120	;CPW!
	ENDFLASH 19	;750K
	ENDFLASH 25	;500K
	ENDFLASH 26	;250K
	LIGHTFLASH 26,BALOONSPEED	;250K
	MOV	INH_REV,FALSE
	SUICIDE


;********************************* THE LOOP! **********************************

BYGEL9:					;RIGHT OF HOLE
	CMP	LASTAREA,OFFSET BYGEL11
	JNE	NOTLOOP
	CMP	INH_LOOP,TRUE
	JE	NOTLOOP

	;*** THE LOOP! ***
	CALL	JACKADD
	CALL	ADDMEGALAUGH
	CMP	ANY_LOOP_DOWN_COUNTER,0
	JZ	NO_PARTY_T2
	CALL	DO_PARTY_T
NO_PARTY_T2:
	MOV	ANY_LOOP_DOWN_COUNTER,PARTY_T_TIME
	
	CMP	LIGHTSTATUS[6],TRUE	;M
	JE	NOT_MAD_M
	;*** SPELLED M IN MAD ***
	EFFECT	THELOOP1
	LIGHTFLASH 6,MADONSPEED		;M
	ADDTASK	MAD_M_TASK
	JMP	MAD_OK
MAD_M_TASK:
	WAITSYNCS MADONSPEED*6+2
	ENDFLASH 6			;M
	MOV	LIGHTSTATUS[6],TRUE	;M
	SUICIDE
NOT_MAD_M:

	CMP	LIGHTSTATUS[8],TRUE	;A
	JE	NOT_MAD_A
	;*** SPELLED A IN MAD ***
	EFFECT	THELOOP2
	LIGHTFLASH 8,MADONSPEED		;A
	ADDTASK	MAD_A_TASK
	JMP	MAD_OK
MAD_A_TASK:
	WAITSYNCS MADONSPEED*6+2
	ENDFLASH 8			;A
	MOV	LIGHTSTATUS[8],TRUE	;A
	SUICIDE
NOT_MAD_A:

	;*** SPELLED D IN MAD ***
	MOV	LIGHTSTATUS[6],FALSE	;M
	MOV	LIGHTSTATUS[8],FALSE	;A
	LIGHTFLASH 6,MADSPEED	;M
	LIGHTFLASH 8,MADSPEED	;A
	LIGHTFLASH 9,MADSPEED	;D
	ADDTASK	TURN_OFF_MAD
	MOV	INH_LOOP,TRUE
	EFFECT	THELOOP3
	MOV	CPVARIABEL,FALSE
	CALL	CRAZY_LETTER_SPOTTED
	CALL	CHECK_CRAZY
MAD_OK:
NOTLOOP:
	RETN

TURN_OFF_MAD:
	WAITSYNCS 120	;CPW!
	ENDFLASH 6	;M
	ENDFLASH 8	;A
	ENDFLASH 9	;D
	MOV	INH_LOOP,FALSE
	SUICIDE
GNUOR DW 0
CRAZY_LETTER_SPOTTED PROC NEAR	;OUTPUT: -C- IF TIME FOR MEGA LAUGH
				; CRAL=AL FROM EFFECT ADVANCE3
	CALL	JACKADD
	CMP	CPVARIABEL,TRUE
	JE	DEN_ANDRA
	EFFECT	ADVANCE3
	JMP	DEN_ENA
DEN_ANDRA:
	EFFECT	ADVANCE3B
DEN_ENA:
	MOV	CRAL,AL
	INC CS:GNUOR
	DEBUGVAL 0,15,CS:GNUOR,"DOADVANCE NO:"
	MOV	SI,OFFSET CRAZY_ADVANCE_LIST
	CALL	DOADVANCE
	JNC	NO_MEGA_LAUGH
	LIGHTOFF 28	;C
	LIGHTOFF 31	;R
	LIGHTOFF 34	;A
	LIGHTOFF 38	;Z
	LIGHTOFF 41	;Y
	STC
	RETN
NO_MEGA_LAUGH:
	CLC
	RETN
CRAZY_LETTER_SPOTTED ENDP


;******************************** HIDDEN ENTRANCE *****************************

GROPC:					;HOLE
	MOV	EOTS,FALSE
	EFFECT	HIDDEN
	CALL	JACKADD
	LIGHTFLASH 11,6		;"L1Q"?
	MOV	_5XFLASHING,TRUE
	ADDTASK	HIDDENTASK0
	SETBALLPOS DROPX,DROPY,0,0,FALSE
	RETN

GROPC_T:
	SETBALLPOS DROPX,DROPY,0,0,FALSE
	CALL	START_DROP
	ENDFLASH 11		;5X
	RETN

HIDDENTASK0:
	WAITTS
	ADDTASK	HIDDENTASK1
	CALL	START_DROP
	SUICIDE

HIDDENTASK1:
	WAITSYNCS _5X_TIME-QUICKFLASH_TIME
	CMP	_5XFLASHING,FALSE
	JE	TOO_LATE
	ENDFLASH 11		;5X
	LIGHTFLASH 11,QUICK_ARROWSPEED
	ADDTASK	HIDDENTASK2
	SUICIDE
TOO_LATE:
	ENDFLASH 11		;5X
	LOFF	11
	SUICIDE

HIDDENTASK2:
	WAITSYNCS QUICKFLASH_TIME
	CALL	KILL_5X
	SUICIDE

KILL_5X PROC NEAR
	ENDFLASH 11
	LOFF	11
	MOV	_5XFLASHING,FALSE
	RETN
KILL_5X	ENDP



;******************************** THE TUNNEL **********************************

GROPD:					;TUNNEL
	CALL	JACKADD
	CALL	ADDMEGALAUGH
	CMP	SKILLSHOTDOWNCOUNTER,0
	JA	TUNNEL_SKILLSHOT
	CMP	REVERSE_DOWN_COUNTER,0
	JZ	NOT_PARTY_P
	CALL	PARTY_P
NOT_PARTY_P:
FROM_TUNNEL_SKILLSHOT:
	CMP	LIGHTSTATUS[12],TRUE		;IF 3M IS LIT: 5M
	JNE	NOT_TUNNEL_5M
	EFFECT	TSCORE3
	MOV	TUNNELDOWNCOUNTER,TUNNEL_TIME*2
	MOV	TUNNELWAITER,TSCORE3_TIME
	JMP	TSCORE_OK
NOT_TUNNEL_5M:
	CMP	LIGHTSTATUS[14],TRUE		;IF 1M IS LIT: 3M
	JNE	NOT_TUNNEL_3M
	EFFECT	TSCORE2
	MOV	TUNNELDOWNCOUNTER,TUNNEL_TIME*2
	ENDFLASH 12	;3M
	LIGHTON	12	;3M
	LIGHTFLASH 10,TUNNELSPEED	;5M
	MOV	TUNNELWAITER,TSCORE2_TIME
	JMP	TSCORE_OK
NOT_TUNNEL_3M:
	EFFECT	TSCORE1
	MOV	TUNNELDOWNCOUNTER,TUNNEL_TIME
	ENDFLASH 14	;1M
	LIGHTON	14	;1M
	LIGHTFLASH 12,TUNNELSPEED	;3M
	MOV	TUNNELWAITER,TSCORE1_TIME
TSCORE_OK:
	ADDTASK	RULLGARDIN
	ADDTASK	WAIT_FOR_TUNNEL_EFFECT
	CMP	SPECIALMODE,TRUE
	JE	SNABBHOPP3
	ADDTASK LOCK_BALL_IN_TUNNEL
SNABBHOPP3:
	MOV	INH_EFF,FALSE
	RETN

TUNNEL_SKILLSHOT:
	CALL	JACKADD
	MOV	SKILLSHOTDOWNCOUNTER,0
	MOV	SI,OFFSET BCDMILLION
	MOV	DI,OFFSET SKILL_SCORE
	CALL	ADDSCOREBCD			;S_S_S += 1E6

	MOV	SI,OFFSET SKILL_SCORE
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD			;SCORE += S_S
	EFFECT	SKILLTUNNEL
	MOV	INH_EFF,TRUE
	CALL	PARTY_P
	JMP	FROM_TUNNEL_SKILLSHOT

WAIT_FOR_TUNNEL_EFFECT:
	CMP	SPECIALMODE,TRUE
	JE	SNABBHOPP2
	WAITSYNCS TUNNELWAITER
SNABBHOPP2:
	MOV	SCREENFORCE,-1
	CALL	START_DROP
	SUICIDE

LOCK_BALL_IN_TUNNEL:
	WAITSYNCS 2
	SETBALLPOS DROPX,DROPY,0,0,FALSE
	SUICIDE

PARTY_P:
	CMP	LIGHTSTATUS[42],TRUE	;P IN PARTY
	JE	QUICK_BACK
	EFFECT	PARTYSCORE1
	LIGHTON	42			;P IN PARTY
	CALL	CHECK_PARTY
QUICK_BACK:
	RETN

GROPD_T:
	SETBALLPOS DROPX,DROPY,0,0,FALSE
	CALL	START_DROP
	RETN

;******************************* ARCADE HALL **********************************

GROPB:					;ARCADE
	ADD	SLUMPCOUNTER,21
	CALL	ADDMEGALAUGH
	CMP	TILTFLAG,TRUE
	JE	TILT_ARCADE
	CMP	ARCADEON,TRUE
	JNE	ARCADEOFF
	MOV	ARCADEON,FALSE
	ENDFLASH 7	;ARCADE1
	ENDFLASH 55	;ARCADE2
	LOFF	7
	LOFF	55
	MOV	AL,LASTJINGLE
	MOV	LASTLASTJINGLE,AL
	MOV	SNURR_READY,FALSE
	MOV	DECCOR,25 ;CPW!
	EFFECT	MYSTERY
	OR	AL,AL
	JNZ	TSISDONE
	MOV	SNURR_READY,TRUE
	CALL	SPINIT
	MOV	AL,LASTJINGLE
	MOV	LASTLASTJINGLE,AL
	JMP	NOTSDONE_MEN_JA_E_LIKA_GLA_FOR_DE
TSISDONE:
	MOV	LASTJINGLE,62	;QUIET
	MOV	CURRENT_PRIORITY,1
	MOV	JINGLE_READY_LOGIC,FALSE
	MOV	JINGLE_READY_ANIM,FALSE
	ADDTASK	WAIT_FOR_SPIN_TASK
NOTSDONE_MEN_JA_E_LIKA_GLA_FOR_DE:
	ADDTASK	RULLGARDIN
;	MOVE	SCREENFORCE,START_RASTER	;LOCK SCREEN
	SETBALLPOS DROPX,DROPY,0,0,FALSE	;LOCK BALL IN DRèP SON
	RETN

ARCADEOFF:
TILT_ARCADE:
	CALL	START_DROP
GBOK:	RETN

WAIT_FOR_SPIN_TASK:
	CMP	SPECIALMODE,TRUE
	JE	REALLY_READY
	CMP	SNURR_READY,TRUE
	JE	REALLY_READY
	RETN
REALLY_READY:
	CMP	TILTFLAG,TRUE
	JE	TILT_SPIN
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	JINGLEJUMPCNT,1
	MOV	CURRENT_PRIORITY,0 ;CP!?
	CALL	SPINIT
	SUICIDE

SPINIT	PROC NEAR
	;*** SPIN! ***
	;POéNG,BONUS,ANIM,JINGLE,TID,EXTRARUT
	MOV	BL,SLUMPCOUNTER		;SLUMP
	NIL	BH
	SHR	BX,1
	MOV	BL,ARCADESLUMP[BX]
	MOV	SI,BX
	ADD	SI,OFFSET ARCADEEFFECTS	;EFFECT CHOOSEN
	LODSW				;AX=OFFSET X-RUT
	ADDTASK	AX
	RETN
SPINIT	ENDP


TILT_SPIN:
	CALL	START_DROP
	SUICIDE

SPINXB_RUT:
	LIGHTON	39	;LEFT XB och RIGHT XB
	EFFECT	SPINXB
	OR	AL,AL
	JZ	NOSPINXB
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!?
	MOV	DROP_TIME,XBALL_TIME
	ADDTASK	START_DROP_TIMED
	SUICIDE

SPINCL_RUT:
	MOV	CPVARIABEL,TRUE
	CALL	CRAZY_LETTER_SPOTTED
	CALL	CHECK_CRAZY
	CMP	CRAL,0
	JZ	NOSPINCL
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!?
	MOV	HANGSAVER,140 ;154,153
	MOV	HANGSAVER2,180
	MOV	OKEJHEJ,FALSE
	ADDTASK	START_DROP_WHEN_READY
	SUICIDE

SPIN1M_RUT:
	EFFECT	SPIN1M
	OR	AL,AL
	JZ	NOSPIN1M
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!?
	MOV	HANGSAVER,120 ;136,124
	MOV	HANGSAVER2,150
	MOV	OKEJHEJ,FALSE
	ADDTASK	START_DROP_WHEN_READY
	SUICIDE

SPIN5M_RUT:
	EFFECT	SPIN5M
	OR	AL,AL
	JZ	NOSPIN5M
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!?
	MOV	HANGSAVER,110 ;121,121,121
	MOV	HANGSAVER2,140
	MOV	OKEJHEJ,FALSE
	ADDTASK	START_DROP_WHEN_READY
	SUICIDE

SPIN500K_RUT:
	EFFECT	SPIN500K
	OR	AL,AL
	JZ	NOSPIN500K
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!? JA JéVLIGT CP! MEN NU HAR FIXAT DET...
	MOV	HANGSAVER,45 ;53,53
	MOV	HANGSAVER2,70
	MOV	OKEJHEJ,FALSE
	ADDTASK	START_DROP_WHEN_READY
	SUICIDE

NOSPINXB:
NOSPINCL:
NOSPIN1M:
NOSPIN5M:
NOSPIN500K:
	;** NO SPIN - JUST DROP **
	MOV	DROP_TIME,10 ;CPW!
	ADDTASK	START_DROP_TIMED
	SUICIDE

SPINNS_RUT:
	EFFECT	SPINNS
	OR	AL,AL
	JZ	NOSPINNS
	MOV	AL,LASTLASTJINGLE
	MOV	LASTJINGLE,AL
	MOV	CURRENT_PRIORITY,0 ;CP!?
NOSPINNS:
	MOV	DROP_TIME,NOSCORE_TIME
	ADDTASK	START_DROP_TIMED
	SUICIDE

START_DROP_WHEN_READY:		;THIS REALLY IS A TASKROUTINE!
	DEC	HANGSAVER2
	JZ	HUPP
	CMP	HANGSAVER,0
	JE	BLAHA
	DEC	HANGSAVER
BLAHA:	CMP	OKEJHEJ,TRUE
	JE	HOPP1
	CMP	SPECIALMODE,TRUE
	JE	HUPP
	CMP	JINGLE_READY_LOGIC,TRUE
	JE	HOPP1
	RETN					;RETN
HOPP1:	MOV	OKEJHEJ,TRUE
	CMP	HANGSAVER,0
	JZ	HUPP
	RETN					;RETN
HUPP:	MOV	JINGLE_READY_LOGIC,FALSE
	MOV	HANGSAVER,65535			;BIG ENOUGH!
	MOV	HANGSAVER2,10			;DOESN'T MATTER!
COMMENT\
	PUSHA
	PUSH	ES
	MOV	BX,HANGSAVER
	DEBUGVAL 0,22,BX,"HANGSAVER: "
	POP	ES
	POPA
\
	CALL	START_DROP
	SUICIDE



;****************************** SNACK HOLE ************************************

GROPA:					;SNACKS (NOTE: BOTH HIGH & LOW)
	CMP	SNACKDISABLED,TRUE
	JE	NOT_NOW_STUPID
	MOV	SNACKDISABLED,TRUE
	ADDSCORE BCD50000
	ADDBONUS BCD5000
	CALL	ADDMEGALAUGH
	CMP	POPFLASHING,TRUE
	JNE	NOTPOPF
	EFFECT	SCORE3
	CALL	JACKADD
	INC	POPCOUNTER
	JMP	SNACKDONE
NOTPOPF:
	CMP	SODAFLASHING,TRUE
	JNE	NOTSODAF
	EFFECT	SCORE2
	CALL	JACKADD
	JMP	SNACKDONE
NOTSODAF:
	CMP	ICEFLASHING,TRUE
	JNE	NOTICEF
	EFFECT	SCORE1
	CALL	JACKADD
	JMP	SNACKDONE
NOTICEF:
	EFFECT	HSCORE
SNACKDONE:
	ENDFLASH 23	;ICE
	LOFF	23
	ENDFLASH 17	;SODA
	LOFF	17
	ENDFLASH 20	;POP
	LOFF	20
	
	CMP	POPFLASHING,TRUE		;IF POP: HB/DB/P(A)RTY ?
	JNE	NO_SPECIAL_POP

	CMP	LIGHTSTATUS[43],TRUE	;A (PARTY)
	JE	A_ALREADY_LIT

	;*** SPELLED A IN PARTY ***
	LIGHTON	43
	EFFECT	PARTYSCORE2
	CALL	CHECK_PARTY
A_ALREADY_LIT:

	CMP	POPCOUNTER,1
	JA	HIGH_POPCOUNTER

	;*** HOLD BONUS ACTIVATED ***
	CMP	HBFLASHING,TRUE		;DON'T THINK THIS COULD HAPPEN...
	JE	HB_ALLR_FL
	MOV	HBFLASHING,TRUE
	INVERTEDSYNCEDFLASH 33,ARROWSPEED,ARROWSYNCER	;"L2P"
HB_ALLR_FL:
	JMP	FROM_HB

HIGH_POPCOUNTER:
	;*** DOUBLE BONUS ACTIVATED ***
	CMP	DBFLASHING,TRUE
	JE	DB_ALLR_FL
	MOV	DBFLASHING,TRUE
	ADDTASK	TURNING_OFF_DB
	SYNCEDFLASH 36,ARROWSPEED,ARROWSYNCER
DB_ALLR_FL:

FROM_HB:	
NO_SPECIAL_POP:
	MOV	ICEFLASHING,FALSE
	MOV	SODAFLASHING,FALSE
	MOV	POPFLASHING,FALSE
	ADDTASK	SNACK_HOLE_TASK1
NOT_NOW_STUPID:
	RETN

TURNING_OFF_DB:
	WAITSYNCS DB_TIME-QUICKFLASH_TIME
	CMP	DBFLASHING,TRUE
	JNE	DNTODB
	ENDFLASH 36
	LIGHTFLASH 36,QUICK_ARROWSPEED
	ADDTASK	TURN_OFF_DB
DNTODB:	SUICIDE

TURN_OFF_DB:
	WAITSYNCS QUICKFLASH_TIME
	CMP	DBFLASHING,TRUE
	JNE	DNTOQDB
	ENDFLASH 36
	MOV	DBFLASHING,FALSE
DNTOQDB:
	SUICIDE

SNACK_HOLE_TASK1:
	MOV	HOLDSTILL,TRUE
	SETBALLPOS SNACKX,SNACKY,0,0,TRUE	;PUT BALL IN MIDDLE OF HOLE ;CP!
	WAITSYNCS 40 ;CPW!	;(EVEN IF SPECIALMODE=TRUE)
	ADDTASK SNACK_HOLE_TASK1B
	SUICIDE

SNACK_HOLE_TASK1B:
	MOV	HOLDSTILL,TRUE
	SETBALLPOS SNACKX,SNACKY,0,0,TRUE	;PUT BALL IN MIDDLE OF HOLE ;CP!
	CMP	SPECIALMODE,TRUE
	JE	SNABBHOPP4
	WAITSYNCS 130-40	;CPW!
SNABBHOPP4:
	SOUNDEFFECT SGROP,0
	MOV	HOLDSTILL,FALSE
	SETBALLPOS SNACKX,SNACKY,SNACKXS,SNACKYS,TRUE
	ADDTASK TURN_IT_ON_AGAIN
	SUICIDE

TURN_IT_ON_AGAIN:
	WAITSYNCS 60
	MOV	SNACKDISABLED,FALSE
	SUICIDE


;********************************* DUMMY AREA ********************************

BYGEL14:				;BEFORE BEGINNING OF REVERSE
	MOV	INHIBIT_REVERSE_COUNTER,0
	RETN


;*********************************** GAME ON **********************************

CLOSE1:					;GAME ON
	CMP	LASTAREA,OFFSET BYGEL12
	JNE	NOT_GAME_ON
	MOV	ADDPLAYERS,FALSE
	PLAYJINGLE S_MAIN
	MOV	LASTJINGLE,1
	MOV	BX,OFFSET PARTY_OFFTS
	CALL	DO_MATRIX
	MOV	I_UTSKJUT,FALSE		;TILLèTER INACTIVE-SLINGAN (DOTMATRIX)
	MOV	PARTYFLASH,FALSE
NOT_GAME_ON:
	RETN


;********************************* DRAGON'S HEAD ******************************

GROPE:					;DRAGON'S HEAD
	CMP	DRAGON,TRUE
	JE	DUMRET
	MOV	DRAGON,TRUE
	SETBALLPOS DRAGONX,DRAGONY,0,0,FALSE
	MOV	HOLDSTILL,TRUE
	CALL	ADDMEGALAUGH
	CALL	CHECK_JACKPOT
	JC	JP_IT_WAS
	CALL	CHECK_BALL
	JC	BALL_IT_WAS
	CALL	CHECK_5M
	JC	_5M_IT_WAS

	;*** NO SPECIAL EFFECTS IN DRAGON ***
	EFFECT	DSCORE
	MOV	DRAGONWAITER,85		;CPW!
JP_IT_WAS:
BALL_IT_WAS:
_5M_IT_WAS:
	ADDTASK	BEFOREFLASH
	RETN

CHECK_5M PROC NEAR	;FN: CHECKS THE EFFECT, IF POSITIVE: RUN IT AND RET -C-
	CMP	_5MFLASHING,TRUE
	JNE	NOT_5M_IT_IS
	;*** 5 MILLION ***
	EFFECT	MILLION5
	ENDFLASH 27	;5M
	LOFF	27
	MOV	_5MFLASHING,FALSE
	MOV	DRAGONWAITER,MILLION5_TIME
	CMP	SPECIALMODE,TRUE
	JNE	EJSNABBHOPP7
	MOV	DRAGONWAITER,15 ;CPW!
EJSNABBHOPP7:
	STC
	RETN
NOT_5M_IT_IS:
	CLC
	RETN
CHECK_5M ENDP

CHECK_BALL PROC NEAR	;FN: CHECKS THE EFFECT, IF POSITIVE: RUN IT AND RET -C-
	CMP	BALLFLASHING,TRUE
	JNE	NOT_BALL_IT_IS
	;*** BALL ***
	ENDFLASH 30	;BALL
	LOFF	30
	LIGHTON	51	;LAUGH AGAIN
	INC	XBALLS
	EFFECT	EXTRABALL1
	MOV	BALLFLASHING,FALSE
	MOV	DRAGONWAITER,EXTRABALL1_TIME
	CMP	SPECIALMODE,TRUE
	JNE	EJSNABBHOPP6
	MOV	DRAGONWAITER,15 ;CPW!
EJSNABBHOPP6:
	STC
	RETN
NOT_BALL_IT_IS:
	CLC
	RETN
CHECK_BALL ENDP

CHECK_JACKPOT PROC NEAR	;FN: CHECKS THE EFFECT, IF POSITIVE: RUN IT AND RET -C-
	CMP	JPFLASHING_NORMAL,TRUE
	JE	JACKPOT_NORMAL
	CMP	JPFLASHING_TIME,TRUE
	JNE	NOT_JACKPOT
JACKPOT_NORMAL:
	;*** JACKPOT ***
	MOV	JPFLASHING_NORMAL,FALSE
	MOV	JPFLASHING_TIME,FALSE
	ENDFLASH 35	;JP
	LOFF	35
	PLAYJINGLE SJINGLE4	;JP
	
	CMP	SPECIALMODE,TRUE
	JE	SPECIALAREN
	MOV	BX,OFFSET jackpotTS
	JMP	BX_OK
SPECIALAREN:
	cmp	happy_hour,true
	je	do_happy_jack
;megalaugh jack!
	MOV	BX,OFFSET jackpot_special_ml_TS
	jmp	bx_ok
do_happy_jack:

	MOV	BX,OFFSET jackpot_special_hh_TS
BX_OK:	CALL	DO_MATRIX
	
	
	MOV	SI,OFFSET JACKVALUE
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD
	CALL	INIT_JACK

	MOV	DRAGONWAITER,410 ;CPW!
		;I BôRJAN AV SISTA TAKTEN INNAN 123454321 KOMMER SNEWBALL!
	STC
	RETN
NOT_JACKPOT:
	CLC
	RETN
CHECK_JACKPOT ENDP

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


BEFOREFLASH:
	WAITSYNCS DRAGONWAITER
	LIGHTFLASH 21,EYESPEED	;EYES
	ADDTASK	DURINGFLASH
	SUICIDE

DURINGFLASH:
	WAITSYNCS EYESPEED*4-1
	ENDFLASH 21	;EYES
	SOUNDEFFECT SNEWBALL,0
	MOV	HOLDSTILL,FALSE
	SETBALLPOS DRAGONX,DRAGONY,DRAGONXS,DRAGONYS,FALSE
	MOV	DRAGON,FALSE
	SUICIDE




;********************************** BYGEL 3 ***********************************

BYGEL3:					;RéNNA SLUT VéNSTER
	EFFECT	BYGELSETB
	SOUNDEFFECT SBYGEL2,0
	RETN


BYGEL4:					;RéNNA SLUT HôGER
	EFFECT	BYGELSETB
	SOUNDEFFECT SBYGEL2,0
	RETN


;********************************* SL XB (L) **********************************

BYGEL1:					;EXTRA BALL LEFT
	CMP	LIGHTSTATUS[39],TRUE	;XB(L)
	JE	XB_IT_IS_L
	SOUNDEFFECT SBYGEL1,0
	ADDSCORE BCD50030
	RETN
XB_IT_IS_L:
	LIGHTOFF 39			;XB(L)
	LIGHTOFF 40			;XB(R)
	EFFECT	EXTRABALL2
	LIGHTON 51			;LAUGH AGAIN
	INC	XBALLS
	RETN


;********************************* SL XB (R) **********************************

BYGEL2:					;EXTRA BALL RIGHT
	CMP	LIGHTSTATUS[39],TRUE	;XB(R)
	JE	XB_IT_IS_R
	SOUNDEFFECT SBYGEL1,0
	ADDSCORE BCD50030
	RETN
XB_IT_IS_R:
	LIGHTOFF 39			;XB(L)
	LIGHTOFF 40			;XB(R)
	EFFECT	EXTRABALL2
	LIGHTON 51			;LAUGH AGAIN
	INC	XBALLS
	RETN


;***************************** SPRING INVALID *********************************

BYGEL12:				;SPRING INVALID
	MOV	SKILLSHOTDOWNCOUNTER,SKILL_SHOT_TIME
	MOV	SPRING_VALID,FALSE
	MOV	INHIBIT_REVERSE_COUNTER,INHIBIT_REVERSE_TIME
	RETN


;******************************* SPRING VALID *********************************

BYGEL28:				;SPRING VALID
	MOV	SPRING_VALID,TRUE
	RETN



;******************************************************************************
;*********************************** UPPER ************************************
;******************************************************************************


;******************************* SKYRIDE **************************************

CLOSE2:					;ENTERED SKY RIDE
	CMP	LASTAREA,OFFSET BYGEL10
	JNE	QC2
	CALL	ADDMEGALAUGH
	CALL	RESTOREGATE1

	CMP	ANY_LOOP_DOWN_COUNTER,0
	JZ	NO_PARTY_T1
	CALL	DO_PARTY_T
NO_PARTY_T1:
	MOV	ANY_LOOP_DOWN_COUNTER,PARTY_T_TIME

	INC	SKYRIDECOUNTER
	CMP	SKYRIDECOUNTER,3
	JB	NOT_ALL_ROCKETS

	;*** ALL 3 ROCKETS LIT ***
	EFFECT	RIDE3
	LIGHTFLASH 22,ROCKETSPEED
	LIGHTFLASH 13,ROCKETSPEED
	LIGHTFLASH 15,ROCKETSPEED
	ADDTASK	KILL_FLASHING_ROCKETS
	MOV	SKYRIDECOUNTER,0
	CMP	MBFLASHING,TRUE
	JE	MB_ALLR_FL
	CMP	LIGHTSTATUS[48],TRUE
	JE	NO_MORE_MB
	MOV	MBFLASHING,TRUE
	SYNCEDFLASH 29,ARROWSPEED,ARROWSYNCER	;MB
	EFFECT	GETBONUS
	JMP	ROCKETS_OK
MB_ALLR_FL:
NO_MORE_MB:
	JMP	ROCKETS_OK

NOT_ALL_ROCKETS:
	CMP	SKYRIDECOUNTER,1
	JNE	NOT_1ST_ROCKET

	;*** 1ST ROCKET ***
	LON	22	;1ST
	EFFECT	RIDE1
	JMP	ROCKETS_OK

NOT_1ST_ROCKET:
	;*** 2ND ROCKET ***
	EFFECT	RIDE2
	LON	13	;2ND

ROCKETS_OK:
QC2:	RETN

KILL_FLASHING_ROCKETS:
	WAITSYNCS 120	;CPW!
	ENDFLASH 22
	ENDFLASH 13
	ENDFLASH 15
	SUICIDE

DO_PARTY_T PROC NEAR
	CMP	LIGHTSTATUS[45],TRUE		;T IN PARTY
	JE	QDPT
	LIGHTON	45				;T IN PARTY
	EFFECT	PARTYSCORE4
	CALL	CHECK_PARTY
QDPT:	RETN
DO_PARTY_T ENDP


;***************************** BEFORE SKYRIDE *********************************

BYGEL10:				;BEFORE SKY RIDE
	CALL	KILLGATE1
	RETN


;********************************** PUKE **************************************

;******************** P *******************
BYGEL5:					;P (PUKE)
	SOUNDEFFECT SBYGEL1,0	;"BYGELSETC"
	CMP	LIGHTSTATUS[1],FALSE
	JNE	QB5
	MOV	LIGHTSTATUS[1],TRUE
	CALL	PUKEGROUP
	JC	PUKETIME
	MOV	PUKEFORBIDDEN,TRUE
	LIGHTFLASH 1,PUKESPEED
	ADDTASK	PUKEP1
QB5:	RETN
PUKEP1:
	WAITSYNCS PUKESPEED*6+1	;CPW!
	ENDFLASH 1
	MOV	PUKEFORBIDDEN,FALSE
	SUICIDE

;******************** E *******************
BYGEL8:					;E (PUKE)
	SOUNDEFFECT SBYGEL1,0	;"BYGELSETC"
	CMP	LIGHTSTATUS[2],FALSE
	JNE	QB8
	MOV	LIGHTSTATUS[2],TRUE
	CALL	PUKEGROUP
	JC	PUKETIME
	MOV	PUKEFORBIDDEN,TRUE
	LIGHTFLASH 2,PUKESPEED
	ADDTASK	PUKEP2
QB8:	RETN
PUKEP2:
	WAITSYNCS PUKESPEED*6+1	;CPW!
	ENDFLASH 2
	MOV	PUKEFORBIDDEN,FALSE
	SUICIDE

;******************** U *******************
BYGEL6:					;U (PUKE)
	SOUNDEFFECT SBYGEL1,0	;"BYGELSETC"
	CMP	LIGHTSTATUS[4],FALSE
	JNE	QB6
	MOV	LIGHTSTATUS[4],TRUE
	CALL	PUKEGROUP
	JC	PUKETIME
	LIGHTFLASH 4,PUKESPEED
	MOV	PUKEFORBIDDEN,TRUE
	ADDTASK	PUKEP4
QB6:	RETN
PUKEP4:
	WAITSYNCS PUKESPEED*6+1	;CPW!
	ENDFLASH 4
	MOV	PUKEFORBIDDEN,FALSE
	SUICIDE

;******************** K *******************
BYGEL7:					;K (PUKE)
	SOUNDEFFECT SBYGEL1,0	;"BYGELSETC"
	CMP	LIGHTSTATUS[5],FALSE
	JNE	QB7
	MOV	LIGHTSTATUS[5],TRUE
	CALL	PUKEGROUP
	JC	PUKETIME
	LIGHTFLASH 5,PUKESPEED
	MOV	PUKEFORBIDDEN,TRUE
	ADDTASK	PUKEP5
QB7:	RETN
PUKEP5:
	WAITSYNCS PUKESPEED*6+1	;CPW!
	ENDFLASH 5
	MOV	PUKEFORBIDDEN,FALSE
	SUICIDE

;************* PUKE LETTERS SHARED CODE *************
PUKEGROUP:				;OUTPUT: -C- IF TIME FOR PUKE
	ADDSCORE BCD20070	;"BYGELSETC"
	ADDBONUS BCD1000
	CALL	JACKADD
	CMP	LIGHTSTATUS[1],TRUE
	JNE	NOTALLPUKE
	CMP	LIGHTSTATUS[2],TRUE
	JNE	NOTALLPUKE
	CMP	LIGHTSTATUS[4],TRUE
	JNE	NOTALLPUKE
	CMP	LIGHTSTATUS[5],TRUE
	JE	LETSPUKE
NOTALLPUKE:
	CLC
	RETN
LETSPUKE:
	STC
	RETN

TURNOFFPUKE:
	WAITSYNCS 100	;CPW!
	ENDFLASH 1	;P
	ENDFLASH 2	;E
	ENDFLASH 4	;U
	ENDFLASH 5	;K
	LIGHTOFF 1
	LIGHTOFF 2
	LIGHTOFF 4
	LIGHTOFF 5
	SUICIDE

PUKETIME:		;THIS IS NOT A TASK ROUTINE!
	SYNCEDFLASH 1,WHOLEPUKESPEED,PUKESYNCER	;P
	SYNCEDFLASH 5,WHOLEPUKESPEED,PUKESYNCER	;K
	INVERTEDSYNCEDFLASH 2,WHOLEPUKESPEED,PUKESYNCER	;E
	INVERTEDSYNCEDFLASH 4,WHOLEPUKESPEED,PUKESYNCER	;U
	ADDTASK	TURNOFFPUKE

	INC	PUKECOUNTER
	CMP	PUKECOUNTER,1
	JNE	NOT_5M_ACT
	CMP	_5MFLASHING,TRUE
	JE	_5M_ALLR_FL
	SYNCEDFLASH 27,TRAINSPEED,TRAINSYNCER	;5M
	MOV	_5MFLASHING,TRUE
_5M_ALLR_FL:
	JMP	DRAGON_TRAIN_OK
NOT_5M_ACT:

	CMP	PUKECOUNTER,2
	JNE	NOT_BALL_ACT
	CMP	BALLFLASHING,TRUE
	JE	BALL_ALLR_FL
	INVERTEDSYNCEDFLASH 30,TRAINSPEED,TRAINSYNCER	;BALL
	MOV	BALLFLASHING,TRUE
BALL_ALLR_FL:
	JMP	DRAGON_TRAIN_OK
NOT_BALL_ACT:

	CMP	PUKECOUNTER,3
	JNE	NOT_JP_ACT
	CMP	JPFLASHING_NORMAL,TRUE
	JE	JP_ALLR_FL
	CMP	JPFLASHING_TIME,TRUE
	JE	JPISTIMED
	SYNCEDFLASH 35,TRAINSPEED,TRAINSYNCER	;JP
JPISTIMED:
	MOV	JPFLASHING_NORMAL,TRUE
;2 LAST SECONDS OF HAPPY HOUR + SPELLED COMPLETE PUKE 3RD TIME = BUG! ;CP?
JP_ALLR_FL:
NOT_JP_ACT:

DRAGON_TRAIN_OK:
	CMP	LIGHTSTATUS[46],TRUE
	JE	Y_ALLR_LIT

	;*** SPELLED Y IN PARTY ***
	LIGHTON	46
	EFFECT	PARTYSCORE5
	CALL	CHECK_PARTY
Y_ALLR_LIT:
	RETN


;******************************* DUMMY *********************************
OPEN2:					;BEFORE "BEFORE SKYRIDE"
	RETN

;***************************** SKY RIDE EXIT ********************************
BYGEL4B:				;SKY RIDE EXIT
	RETN


;********************************* CYCLONE ************************************

BYGEL13:				;CYCLONE BYGEL
	CALL	ADDMEGALAUGH
	CMP	SKILLSHOTDOWNCOUNTER,0
	JA	CYCLONE_SKILL_SHOT
	CMP	REVERSE_DOWN_COUNTER,0
	JZ	NOT_PARTY_R
	CALL	PARTY_R
NOT_PARTY_R:
FROM_CYCLONE_SKILLSHOT:
	CMP	_5XFLASHING,TRUE
	JE	THE_5X_OPTION
INHIBIT_ONE:
	INC	CYCLONECOUNTER
	mov	si,offset etta
	mov	di,offset cyclonecounterbcd
	call	addscorebcd
	mov	si,offset HUNDRATUSEN
	mov	di,offset CYCLONESCOREBCD
	call	addscorebcd
	CMP	CYCLONECOUNTER,1
	JE	INHIBIT_ONE
	EFFECT	CYCLCOUNT
	CALL	KILL_5X
	MOV	INH_EFF,FALSE
	RETN					;RETN

THE_5X_OPTION:
	ADD	CYCLONECOUNTER,5
	mov	si,offset femma
	mov	di,offset cyclonecounterbcd
	call	addscorebcd
	mov	si,offset FEMHUNDRATUSEN
	mov	di,offset CYCLONESCOREBCD
	call	addscorebcd
	EFFECT	CYCLCOUNT2
	CALL	KILL_5X
	CALL	KILL_5X
	MOV	INH_EFF,FALSE
	RETN					;RETN

CYCLONE_SKILL_SHOT:
	CALL	JACKADD		;CP? INGET JACKADD Pè CYCL., MEN 2 Pè SKILLS.!
	CALL	JACKADD
	EFFECT	SKILLCYCLONE
	MOV	SI,OFFSET BCDMILLION
	MOV	DI,OFFSET SKILL_SCORE2
	CALL	ADDSCOREBCD			;S_S_S2 += 1E6

	MOV	SI,OFFSET SKILL_SCORE2
	MOV	DI,OFFSET SIFFRORNA
	CALL	ADDSCOREBCD			;SCORE += S_S2
	EFFECT	SKILLCYCLONE
	MOV	INH_EFF,TRUE
	CALL	PARTY_R
	JMP	FROM_CYCLONE_SKILLSHOT

PARTY_R:
	CMP	LIGHTSTATUS[44],TRUE	;R IN PARTY
	JE	QUICK_BACK_2
	LIGHTON	44			;R IN PARTY
	EFFECT	PARTYSCORE3
	CALL	CHECK_PARTY
QUICK_BACK_2:
	CALL	KILL_5X
	RETN					;RETN


;******************************************************************************
UPDATE_COUNTERS PROC NEAR
	CMP	LOOSING,TRUE
	JE	COUNTERS_INH
	INC	SLUMPCOUNTER
	CMP	SKILLSHOTDOWNCOUNTER,0			;SKILL SHOT
	JZ	SKILLZERO
	DEC	SKILLSHOTDOWNCOUNTER
SKILLZERO:
	CMP	ANY_LOOP_DOWN_COUNTER,0			;ANY LOOP
	JZ	DNDALDC
	DEC	ANY_LOOP_DOWN_COUNTER
DNDALDC:
	CMP	REVERSE_DOWN_COUNTER,0			;REVERSE
	JZ	DNDRDC
	DEC	REVERSE_DOWN_COUNTER
DNDRDC:
	CMP	INHIBIT_REVERSE_COUNTER,0		;INHIBIT REVERSE
	JZ	DNDIRC
	DEC	INHIBIT_REVERSE_COUNTER
DNDIRC:
	INC	SNACKSYNCER				;SNACK SYNCER
	CMP	SNACKSYNCER,SNACKSPEED*2
	JNE	SNSOK
	MOV	SNACKSYNCER,0
SNSOK:
	INC	ARROWSYNCER				;ARROW SYNCER
	CMP	ARROWSYNCER,ARROWSPEED*2
	JNE	ARRSOK
	MOV	ARROWSYNCER,0
ARRSOK:
	INC	PUKESYNCER				;PUKE SYNCER
	CMP	PUKESYNCER,WHOLEPUKESPEED*2
	JNE	PSOK
	MOV	PUKESYNCER,0
PSOK:
	INC	TRAINSYNCER				;TRAIN SYNCER
	CMP	TRAINSYNCER,TRAINSPEED*2
	JNE	TRSOK
	MOV	TRAINSYNCER,0
TRSOK:	
	CMP	TUNNELDOWNCOUNTER,0			;TRAIN COUNTER
	JZ	TUNNELZERO
	DEC	TUNNELDOWNCOUNTER
	CMP	TUNNELDOWNCOUNTER,TUNNEL_TIME
	JNE	NOT_D2_3M
	ENDFLASH 10			;5M	;IF 5M -> 3M: KILL 5M & ACT 3M
	LOFF	10			;5M
	MOV	LIGHTSTATUS[12],FALSE	;3M
	LIGHTFLASH 12,TUNNELSPEED	;3M
	JMP	TUNNEL_FLASH_READY
NOT_D2_3M:
	CMP	TUNNELDOWNCOUNTER,0
	JNZ	NOT_D2_1M
	ENDFLASH 12			;3M	;IF 3M -> 1M: KILL 3M & ACT 1M
	LOFF	12			;3M
	MOV	LIGHTSTATUS[14],FALSE	;1M
	LIGHTFLASH 14,TUNNELSPEED	;1M
NOT_D2_1M:
TUNNELZERO:
TUNNEL_FLASH_READY:
COUNTERS_INH:
	RETN
UPDATE_COUNTERS	ENDP

ADDHAPPY PROC NEAR
	CMP	HAPPY_HOUR,TRUE
	JNE	NOTHAPPYADDING
	MOV	SI,OFFSET BCDMILLION
	MOV	DI,OFFSET HAPPY_HOUR_TOTAL
	CALL	ADDSCOREBCD
	MOV	SPECIAL_SCORE_CHANGED,TRUE
NOTHAPPYADDING:
	RETN
ADDHAPPY ENDP

ADDMEGALAUGH PROC NEAR
	CMP	MEGA_LAUGH,TRUE
	JNE	NOTMEGAADDING
	MOV	SI,OFFSET BCD5MILLION
	MOV	DI,OFFSET MEGA_LAUGH_TOTAL
	CALL	ADDSCOREBCD
	MOV	SPECIAL_SCORE_CHANGED,TRUE
NOTMEGAADDING:
	RETN
ADDMEGALAUGH ENDP

BUMPER_WAS_HIT_PROC PROC NEAR	;INPUT: HITPOINTER
	CALL	ADDHAPPY
	UPDAT_INFOBAR
	RETN
BUMPER_WAS_HIT_PROC ENDP



;********************************* DOT MATRIX CODE ****************************
_PARTYONN:
	MOVE	DS,DATA
	ASSUME	DS:DATA
	MOV	PARTYFLASH,TRUE
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
_PARTYON:		;BX NOT USED!
	MOV	PARTYFLASH,TRUE
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET PARTYRUT
	JMP	NORMAL_END

_PARTYOFF:	;TURN OFF PARTYON FLASHING (AND BRING BACK SCORE!)
;BUT THIS ROUTINE DOESN'T DO ANYTHING, DOES IT????????
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	JMP	NORMAL_END

_EOSNURR:
	MOV	SNURR_READY,TRUE
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

_JBONUSX1:
	CMP	BONUS_X,1
	Ja	QJBX1
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

_BONUS_X_CALCS:		;FN: MULTIPLIES THE BONUS
			;INPUT: BONUS_X, BONUSSIFFRORNA
			;OUTPUT: BONUSSIFFRORNA, BONUS_X_TEXT[8]
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


_CALC_MEGA:	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	PUSHA
	MOV	SI,OFFSET MEGA_LAUGH_TOTAL 	;ML_TOT -> TOTAL BONUS
	MOV	DI,OFFSET BONUSSIFFRORNA
	CALL	ADDSCOREBCD
	POPA
	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_3Q
	MOV	BX,0
_NEXTp_3Q:
	MOV	NEXT_A,BX
	RETN
_CALC_HAPPY:	
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	SISA,1
	PUSHA
	MOV	SI,OFFSET HAPPY_HOUR_TOTAL 	;ML_TOT -> TOTAL BONUS
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
	JNE	_NEXTp_3
	MOV	BX,0
_NEXTp_3:
	MOV	NEXT_A,BX
	RETN


READ_SPECIAL_MODE_COUNTER PROC NEAR

;[SEC_ASC] PEKAR Pè MSD, (0='*')	[SEC_ASC+1] PEKAR Pè LSD
;LéS AV BARA!
	MOVE	DS,DATA

	CMP	HAPPY_HOUR,TRUE
	JNE	OK_NOT_HH

	CMP	[SEC_ASC],'*'
	JNE	INTE_NU_INTE_02
	CMP	[SEC_ASC+1],'2'+7
	JNE	INTE_NU_INTE_02

	;*** SNABB FLASHA JP ***
	CMP	JPFLASHING_NORMAL,TRUE
	JE	NO_QUICK_FLASH
	CMP	JPFLASHING_TIME,TRUE
	JNE	NO_QUICK_FLASH
	ENDFLASH 35	;JP
	LIGHTFLASH 35,TRAINSPEEDFAST	;JP
NO_QUICK_FLASH:

INTE_NU_INTE_02:

	CMP	[SEC_ASC],'*'
	JNE	INTE_NU_INTE_00
	CMP	[SEC_ASC+1],'0'+7
	JNE	INTE_NU_INTE_00

	;*** KILL HAPPY HOUR ***
	mov	sisa,0
	MOV	SPECIALMODE,FALSE
	MOV	HAPPY_HOUR,FALSE
	ENDFLASH 32	;HH
	LOFF	32	;HH
	EFFECT	EOHAPPYHOUR
	MOV	LASTJINGLE,1
	ENDFLASH 35	;JP
	LOFF	35	;JP
	MOV	JPFLASHING_TIME,FALSE
	CMP	JPFLASHING_NORMAL,TRUE
	JNE	JP_NOT_FLASHING
	SYNCEDFLASH 35,TRAINSPEED,TRAINSYNCER	;JP
JP_NOT_FLASHING:
	CMP	MEGA_PENDING,TRUE
	JNE	INGET_PENDING
	;PENDING MEGA!
	MOV	MEGA_PENDING,FALSE
	ADDTASK MEGA_START
INGET_PENDING:

INTE_NU_INTE_00:
	JMP	HH_READY
OK_NOT_HH: ;********************************************************

	CMP	[SEC_ASC],'*'
	JNE	INTE_NU_INTE_02M
	CMP	[SEC_ASC+1],'2'+7
	JNE	INTE_NU_INTE_02M

	;*** SNABB FLASHA JP ***
	CMP	JPFLASHING_NORMAL,TRUE
	JE	NO_QUICK_FLASH_M
	CMP	JPFLASHING_TIME,TRUE
	JNE	NO_QUICK_FLASH_M
	ENDFLASH 35	;JP
	LIGHTFLASH 35,TRAINSPEEDFAST	;JP
NO_QUICK_FLASH_M:

INTE_NU_INTE_02M:

	CMP	[SEC_ASC],'*'
	JNE	INTE_NU_INTE_00M
	CMP	[SEC_ASC+1],'0'+7
	JNE	INTE_NU_INTE_00M

	;*** KILL MEGA LAUGH ***
	MOV	SPECIALMODE,FALSE
	MOV	MEGA_LAUGH,FALSE
	mov	sisa,0
	ENDFLASH 37	;ML
	LOFF	37	;ML
	EFFECT	EOMEGALAUGH
	MOV	LASTJINGLE,1
	ENDFLASH 35	;JP
	LOFF	35	;JP
	MOV	JPFLASHING_TIME,FALSE
	CMP	JPFLASHING_NORMAL,TRUE
	JNE	JP_NOT_FLASHING2
	SYNCEDFLASH 35,TRAINSPEED,TRAINSYNCER	;JP
JP_NOT_FLASHING2:
	CMP	HAPPY_PENDING,TRUE
	JNE	INGET_PENDING2
	;PENDING HAPPY!
	MOV	HAPPY_PENDING,FALSE
	ADDTASK HAPPY_START
	
INGET_PENDING2:
INTE_NU_INTE_00M:
HH_READY:
	RETN

HAPPY_START:
	WAITSYNCS 400
	CALL	OK_2_BE_HAPPY
	SUICIDE

MEGA_START:
	WAITSYNCS 400
	CALL	OK_2_LAUGH
	SUICIDE

READ_SPECIAL_MODE_COUNTER ENDP

_TSEND:	MOV	EOTS,TRUE
	MOV	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	JMP	NORMAL_END

_DOBEATEN:
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET WAITRUT
	INC	XBALLS
	PUSHA
	LIGHTON	51
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
	EXTRN FLIPL2
ELSE	
	EXTRN FLIPL2_1
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


