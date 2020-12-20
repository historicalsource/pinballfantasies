SAVEPAL=0
keyhandler=65h
MONGI_RESIPLAY=0
MUSIKKAOS=0
DEBUG=0
DEMOVER=0
ARROWS=1
STAND_ALONE=0
CREATE_FLIP_DATA=0
GLAPP_SIZE=0
CENTSCREEN=3

TT EQU 5	;CP!
NN EQU 6
PUBLIC TT,NN

COMMENT\***********************************************************************
ALLA:
skydd - SLUMPEN!
testa pÜ flera datorer
cheats

GABRIEL:
LJUD FôR OFTA VID STONEBONE
CHECKSUMMA SKYDDET
*Kolla minneskrav jÑttenoga med stîrsta SDRen
*spela en massa pÜ magnus dator Ü din farsas notebook (m extern skÑrm)

JOHAN:
FELHANTERINGEN CP! (èTMINSTONE OUT OF MEM)
NYA FLD-LOGGAN! (FRONT.LBM Pè DIN DATOR)
TONINGEN SKA INTE SLUTA Pè BAJSBRUNT UTAN Pè SVART!
*Kolla minneskrav jÑttenoga med stîrsta SDRen
spela en massa pÜ TFT notebook + gotlandsdatorn

DANIEL:
SB16
JOHANS SYNDROM
PAS 16 (lÜna Steins)

?HéNGDE VID UPPSTART AV BILLION (STEWART)
?BALL STUCK AFTER PAUSE
?386SX16 FICK MEDIUM (INTERNAL)
??SCANDICS SYNDROM

(MUSIC ON/OFF BORDE STôDJA SUPERLéGEN (DVS ANDRA MAINSLINGOR éN S_MAIN)
(anvÑnd nya clears!!)
SPELTESTA BILLION
adlib och thing knÑpper till vid play sdr-laddning endast i introN?

******************************************************************************\

.286
JUMPS
LOCALS __

TRUE EQU 255
FALSE EQU 0

xst=165
yst=450
NOOFWAITSYNCS=0
NO_OF_PLAYERS=8 ;NOTE: F1-F8
inactivetime=12	;(secs)
TA_TID=15	;SYNCS EN KEY éR GILTIG EFTER DEN BLIVIT TRYCKT
SLIME_FACTOR_DEFAULT=11 ;5=OUT OF SCREEN 55=HARD
AWAYFROMMIDDLE=20
MOUSETOTAL=2
MOUSEMIDDLE=MOUSETOTAL/2

STACKEN SEGMENT PARA STACK 'STACK'
	DB 256 DUP (0)
STACKEN ENDS

includelib fantasie
;includelib cleaR
INCLUDE C:\source\MACROS1.ASM
INCLUDE C:\source\MACROS3.ASM
INCLUDE FANTASIE.MAC

SKALA56 MACRO SKALVAR 
MOV	AX,5		
IMUL	SKALVAR
MOV	CX,6
IDIV	CX
MOV	SKALVAR,AX
ENDM


if (bana EQ 1)
	INCLUDE pland.ASM
endif
if (bana EQ 2)
	INCLUDE sdev.ASM
endif
if (bana EQ 3)
	INCLUDE show.ASM
endif
if (bana EQ 4)
	INCLUDE stones.ASM
endif

flipstruc struc
typ		DB    1       ;Left/Right
LastFrame	DB    1       ;Blit again?
LeftX		DW    1       ;Leftmost block position
TopY		DW    1       ;Uppermost block position
FlipX		DW    1       ;Words wide
FlipY		DW    1       ;Lines high
FlipX1		DW    1       ;Left Border
FlipX2		DW    1       ;Right Border
FlipY1		DW    1       ;Upper Border
FlipY2		DW    1       ;Lower Border
RotCentX	DW    1
RotCentY	DW    1
PowerZonE	DW    1       ;Quadrants for power calculations
FlipSize	DW    1       ;Offset to next flipper
FlipVinkelHast	DW    1       ;Speed ∞/200:th second
FlipVinkel	DW    1       ;Angel from zero
FlipFrame	DW    1       ;Frame to use
FlipFrames	DW    1       ;Last frame
FlipFramesMax	DW    1
FlipAxUp	DW    1
FlipAxDown	DW    1
FlipMaxHastUp	DW    1
FlipMaxHastDown DW    1
LASTGFXFRAME	DW    0
FLIPGFXSTART	DW	?
FLIPMAXPEK	DW	?
FLIPTOPPEK	DW	?
FLIPPEK		DW	?
FLIPTAB		DW	?
FLIPDIFS	DW	?
FlipData	Dw    1       ;Data for flippers
ENDS
;****************************************************************
FLIPPERL EQU 2	;OBS! MèSTA VARA 2 FôR ATT DET SKA BLI RéTT SHIFTKEYS
FLIPPERR EQU 1

springh=17
NOT_PLAYING=60*INACTIVETIME
rotslowdown=2
PILHAST=1024 ;256+128 ;1024/4=256
SLOW=0
MARGIT=0
FLASHIT=0
SW=336
BPL=SW/4
HIRES=false
RES600=false
HZ50=FALSE

IF HIRES
	IF RES600
		SH=600
	ELSE
		SH=480
	ENDIF
ELSE
	IF HZ50
		SH=256
	ELSE
		SH_HI=350
		SH_LO=240
	ENDIF
ENDIF

SPLH=33
MAXGAPU_LO=(SH_LO-SPLH)/2-AWAYFROMMIDDLE-GLAPP_SIZE-BALLH/2
MAXGAPD_LO=(SH_LO-SPLH)/2+AWAYFROMMIDDLE-GLAPP_SIZE-BALLH/2
MAXGAPU_HI=(SH_HI-SPLH)/2-AWAYFROMMIDDLE-GLAPP_SIZE-BALLH/2
MAXGAPD_HI=(SH_HI-SPLH)/2+AWAYFROMMIDDLE-GLAPP_SIZE-BALLH/2

IF HIRES
	IF RES600
		LATE_INTERRUPT_RASTER = (SH/2-SPLH)/2+BALLH+SPLH ;600
	ELSE
		LATE_INTERRUPT_RASTER = (SH/2-SPLH)/2+BALLH	;480
	ENDIF
ELSE
	LATE_INTERRUPT_RASTER_HI = (SH_HI/2-SPLH)/2+BALLH	;480
	LATE_INTERRUPT_RASTER_LO = (SH_LO-SPLH)/2+F3HEIGHT/2 ;+BALLH	;240
ENDIF

IF RES600
	MIDDLE_RASTER = (SH-SPLH)/2+SPLH
ELSE
	MIDDLE_RASTER_LO = (SH_LO-SPLH)/2
	MIDDLE_RASTER_HI = (SH_HI-SPLH)/2
ENDIF

UPPER	EQU TRUE
LOWER	EQU FALSE

IF CREATE_FLIP_DATA
	PUBLIC FLIPLINFO
ENDIF

public exahitx,exahity,rotation,sc_X,sc_y,adjusttable,x_pos,y_pos,x_pos_hi,y_pos_hi,x_hast,y_hast,gfxmask21_offset,gfxmask23_offset,gfxmask13_offset,hitpointer,screenhast,screenpos,screenposy,materialdata,bumper2lista_l,bumperlista_l,gravx,gravy
public INSIDE_RASTINT,holdstill,ballhigh,hitvalue,materialbit,bumperwashit,ball_down,allowflip,shiftkeys,tiltflag,tiltkey
public moveflipmask

DATA	SEGMENT PARA PUBLIC 'DATA'
extrn MINUSHAST:word	;lÑgg dessa externer i datasegmentet
extrn pluSHAST:word
extrn bumperpower:word	
extrn kickerpower:word	
extrn kickminhast:word	
extrn TILTHASTFW:word	
extrn TILTHASTRV:word	

SOUNDCFG	DB "SOUND.CFG",0
DRV		DB "c:\Masm\DS20\RESIPLAY\resiplay.exe",15 DUP(0)
PARMS		DW 10 DUP(0)
LASTJINGLE	DB ?
LASTLASTJINGLE	DB ?
LASTPRIORITY	DB ?
JINGLEJUMPCNT	DB ?
;LASTLOOPVAL	DB ?
SLOWCNT			DB 0
;**************** STUDS-VARIABLER **************************************
PAUSEFLAG DB FALSE
TILTKEY DB FALSE
TILTFLAG DB FALSE
EVENDATA
TILTCOUNTER DW ?
STOTMAX EQU 2048
SCREENPOS DW 0
SCREENPOSY DW 0
SCREENHAST DW 0
muzik_off db false
kvot=4
MaterialData	dw    1792,1792/Kvot,400,-300,38,0,0,0
FLipprubber	dw    1792,1792/Kvot,400,-600,18,0,0,0	      ;Flipper
		dw    1792,1792/Kvot,400,-600,18,0,0,0
rubber		dw    896,896/Kvot,875,-200,38,0,0,0	      ;Rubber
		dw    1792,1792/Kvot,400,-300,38,0,0,0
staal		dw    30000,30000/Kvot,1000,-400,38,0,0,0     ;Spring Steel
Steel		dw    10000,10000/Kvot,450,-700,38,0,0,0      ;Steel
plastic 	dw    10000,10000/Kvot,400,-500,38,0,0,0      ;Plastic
bumperwashit	db false
ball_down	db false
hitpointer	dw ?
GFXMASK21_OFFSET dw FIRSTMASK_GFXADR 
GFXMASK23_OFFSET dw ?
gFXMASK13_OFFSET dw ?
springpos	db 0
realpos		db 0
SPRINGTASK	DW OFFSET SPRINGSTEEN
INSIDE_RASTINT	DB FALSE
INSIDE_BALLHANDLER DB FALSE
INSIDE_RESTOFVBLANK DB FALSE
SLIME_FACTOR	DW SLIME_FACTOR_DEFAULT ;5=OUT OF SCREEN 55=HARD
;**********************************************
ADJUST	EQU 55
;*******************************
	    dw adjust*2 dup(0)	;hîr
adjusttable dw	adjust*24 dup(0) ; ihop
;***********************************
hitvalue		db 0,0
materialbit		db 0,0
ROTATION		DW 0
SC_X			DW XST
SC_Y			DW YST
X_POS			DW 0
X_POS_HI		DW 0
Y_POS			DW 0
Y_POS_HI		DW 0
X_HAST			DW 0
Y_HAST 			DW 0
EXAHITX			DW 0
EXAHITY			DW 0
GRAVY			DW 10*tt/nn
GRAVX			DW 0
OLDPOS			DW ?
OLDSHIFT 		DW ?
oldx dw 0
oldy dw 25

IF HIRES
	SPLITLINE	DW SH-SPLH
ELSE
	SPLITLINE	DW ? ;HI:SH_HI-SPLH, LO:(SH_LO-33)*2
ENDIF

START_RASTER		DW ?
RASTERPOS		DW 0
STATUS			DB ?
LATEGFX			DB ?
VERYFIRSTPUT		DB ?
PUTITBETWEEN		DB ?
PUTF3BETWEEN		DB ?
FORCELATEF3		DB ?
BUFR			DW 0
FLIPPEKARE		DW ?
FLIPPTR			DW ?
FLIPADR			DW ?
FLIPXPOS		DW ?
FLIPYPOS		DW ?
FLIPSEG			DW ?
FLIPWIDTH		DW ?
FLIPHEIGHT		DW ?
FLIPSTORLEK		DW ?
FLIPLINESIZE		DW ?
ASSUME DS:DATAFLIP ;*******************************************
LEFTFLIP2PTR		DW OFFSET LEFTFLIP2TAB
LEFTFLIPPTR		DW OFFSET LEFTFLIPTAB
RIGHTFLIPPTR		DW OFFSET RIGHTFLIPTAB
ASSUME DS:DATA ;**************************************************
SHIFTKEYS		DB 0
INTERRUPTS_ON		DB false
HOLDSTILL		DB FALSE
uppstartad		db false
RGBBUFFER		DB RGB_BUFFER_LEN DUP(0)
RGBBUFPTR		DW RGBBUFFER
LASTCHECK		DW ?
LASTAREA		DW ?
BALLHIGH		DB ?
TASKLIST		DW NOOFTASKS DUP(DUMRET)
NO_OF_ACTIVE_TASKS	DW 0
SAVESOURCE		DW ?
SCREENFORCE		DW ?
SCREENFORCE2		DW -1
SCROLLPOS		DW ?
CURRENT_PRIORITY 	DB ?
SPRING_VALID		DB ?
SHIFTPRESSED		DB ?
KEYTASK			DW ?
JINGLE_READY_ANIM	DB TRUE
JINGLE_READY_LOGIC	DB TRUE
MATRIX_SPEED		DW ?
MATRIX_CNT		DW ?
MATRIX_ONOFF		DW ?
MATRIX_IS_FLASHING	DB ?
INTFLAG			DB FALSE
INH_EFF			DB ?
BONUSSIFFRORNA		DB 12 DUP(?) ;BCD CODED
TEMPSIFFRORNA		DB 12 DUP(?) ;BCD CODED
BONUSMULTIPEL		DW ?
ADDOR			DB 11 DUP(0), 1, 11 DUP(0)
ADDORPEK		DW ?
BONUSPEK		DW ?
LOOSING			DB ?
ALLOWFLIP		DB ?
first_time_you_fool	db true		;Jaaaa det rÑcker sÜ hÑr! (ANVéNDS éVEN VID ESC I CHUTEN)
if demover
MINUTE_5_COUNTER	DW 0
fiveminutes		db false
endif
BALLS			DB 12 DUP(0)	;FIRST 11 DIGITS MUST NEVER BE CHANGED
NO_OF_BALLS		DB 1 ;WILL BE CHANGED
SCORECHANGED		DB ?
SPECIAL_SCORE_CHANGED	DB ?
I_UTSKJUT		DB TRUE
behovs_provad		db false
SPECIALMODE		DB FALSE
ADDPLAYERS		DB true
SUPER_INIT		DB ?		;TRUE WHILE INITING SUPER MODE (FOR JP ETC)
NEXT_A			DW 0
DOTRUT			DW offset cs:nodot
sisa			dw 0
clearval		dw ?
slump_countern		dw ?
MAKE_BAD		DB false ;cpskydd (ska va true)
calamares_delay		db 0
already_beaten		db ?
VISAKEYS		DB ?
VISAPOANG		DW 0
STUDSSCOREN		DW 0
INHIBIT_COUNT_DOWN	DB ?		;(PENETRATION OF SPECIAL MODE)
EOTS			DB ?		;UPP TILL VARJE BANA ATT ANVéNDA
DOT_READY		DB ?
LAGERARBETAREN		DW ?
LILLE_LAGERARBETAREN	DB ?
PAUSE_LAGRET		DB 320/2*16/8+1 DUP(0)
PAUSE_TEXT		DB 'GAME PAUSED',0
INSIDE_DOLIGHTS		DB FALSE
SYNC_COUNTER		DW 0
INT_WAS_HERE		DB ?
INT_WAS_HERE2		DB ?
DNPRESSED		DB FALSE
MOUSEINSTALLED		DB ?
DECCOR			DW ?		;WAITJINGLE2
FFLAG			DB 0		;F11/F12
HI_RES			DB ?		;350 OR 240 LINES

FLASHSTRUC	STRUC
	LNUM		DB ?
	FLASHCOUNTER	DB ?
	TURNOFF		DB ?
	RESETFC		DB ?
ENDS
REALFLASHLIST	DB MAX_NO_OF_LIGHTS_FLASHING*SIZE FLASHSTRUC DUP(0)
LIGHTSTATUS	DB NOOFLIGHTS+1 DUP(0)
WAITLIST	DW MAX_NO_OF_WAIT_SYNCS DUP(0)

TOGGLAR_STRUCEN STRUC
	S_BALLS		DB ?
	S_ANGLE		DB ?
	S_SCROLLING	DB ?
	S_IM		DB ?
	S_RESOLUTION	DB ?
	S_MODE		DB ?
ENDS
TOGGLAREN DB SIZE TOGGLAR_STRUCEN DUP (0)

;cp cp cp cp!
hi_1		db '8     ',94,0
hi_2		db '9     ',94,0
hi_3		db '9'+1,'     ',94,0
hi_4		db '9'+2,'     ',94,0
ALFA_KEYS	DB 13 DUP(0),0,2 DUP(0),'QWERTYUIOP',0,0,0,0,'ASDFGHJKL',0,0,0,0,0,'ZXCVBNM',6 dup (0),'*',(128-50-7) dup (0),20 dup (0)
scan_code	db ?
sec_left	dw ?
sync_per_sec	dw 60
sync_left	dw ?
val_to_print	dw ?
time_left	dB ?
sec_asc		db ?,?,0
NODOTCOUNT	DW ?
fjanttext	dw ?
PRINTTASK	DW ?
AX_PRINT	DW ?
DI_PRINT	DW ?
clear_box_start dw ?
clear_box_bredd dw ?
clear_box_hojd dw ?
rullstart	dw ?
rulltext	dw ?
rull_pos	dw ?
stop_at_pos	dw ?
upp_add		dw ?
first_high	db false	;cp?
HIGHSCORE	DB false	;CP?
no_demomusic	db false	;cp?
DEMOMODE	DB TRUE
F1F8_CODE	DB ?	
OLD_F1F8_CODE	DB ?	
PLAYERS		DB 0
PLAYERS_CP	DB FALSE
CARMEN		DW ?
PLAYER		DB ?
ORGPLAYER	DB ?
extrn	sin:word,material:word
;fonter
TOM_BRUN DB 13 DUP(0)	 	;FôR è RôJJA MED ASSè!
extrn	font5,font8,font11,font13
densomsparhanhar db ?
TILTDISABLED	DB FALSE
dont_know_yet	db ?
AFTER_CHEAT	DB TRUE
cheatpekare	dw 0
cheatinput	db 12+2 dup (' ')

cheats		dw JOHANRUT
		db 'JOHAN$'

		dw TECHRUT
		db 'TECH$'

		dw TSPRUT
		db 'TSP$'

		DW DANIELRUT
		DB 'DANIEL$'

		DW GABRIELRUT
		DB 'GABRIEL$'

		DW CHEATRUT
		DB 'CHEAT$'

		DW TILTRUT
		DB 'EARTHQUAKE$'

		DW BALLSRUT
		DB 'EXTRA*BALLS$'

		DW SNAILRUT
		DB 'SNAIL$'

		DW FAIRPLAYRUT
		DB 'FAIR*PLAY$'

		dw robbanrut
		db 'ROBBAN$'

		dw steinrut
		db 'STEIN$'

		dw greetrut
		db 'GREET$'
		dw 255				;255 avslutar!!

SNAILSCROLL	DB 21 DUP (1),'I WOULD RATHER BE A SPARROW THAN A SNAIL',21 DUP(1),255
BALLSSCROLL	DB 21 DUP (1),'YOU WILL NOW GET 7 BALLS DUDE',21 DUP(1),255
FAIRPLAYSCROLL	DB 21 DUP (1),'ALL CHEATS ARE NOW RESET',21 DUP(1),255
TILTSCROLL	DB 21 DUP (1),'THE TILT FEATURE IS NOW DISABLED',21 DUP(1),255
CHEATSCROLL	DB 21 DUP (1),' THERE ARE A LOT OF NASTY CHEATS IN THIS GAME   SO JUST START TYPING ON YOUR KEYBOARD',21 DUP(1),255
johanscroll	DB 21 dup(1),'THE DOT MATRIX SYSTEM AND SOME OF THE GAME SYSTEM AND THE WHOLE OF THE SPEED DEVILS TABLE WERE PERFECTLY CODED BY JOHAN    ',21 DUP(1),255
DANIELSCROLL	DB 21 dup(1),'THE MUSIC PLAYER AND THE BALL CALCULATIONS AND THE BILLION DOLLAR GAMESHOW TABLE WERE SUPERBLY CODED BY DANIEL',21 DUP(1),255
GABRIELSCROLL	DB 21 dup(1),'THE GAME SYSTEM AND BOTH THE PARTYLAND AND STONES N BONES TABLES WERE CODED MEGA NICELY BY GABRIEL',21 DUP(1),255
TSPSCROLL	DB 21 DUP(1),'THE SPACEPIGS RULE FOREVER',21 DUP (1),255

greetSCROLL	DB 21 dup(1),'GREETINGS GO TO ALL THE GUYS WHO HELPED US BETA TEST THIS GAME'
		DB '         STEIN,  BJORN,  JENS,  RILLE,  ROBBAN     AND OF COURSE STEWART AND BAZZA'
		DB '            A MEGA GREET GOES TO ROBBAN FOR THE GUSPLAYER'
		DB '          DIGITAL ILLUSIONS - HOPE TO SEE YOU AGAIN SOON'
		db '          STEWART AND BAZZA - WE LOOK FORWARD TO MEETING YOU GUYS'
		DB '         GREETINGS TO ALL SPACEPIGS MEMBERS    HENRIK,  ERIK,  TOM     AND OF COURSE  -  OURSELVES'
		DB '      SPECIAL GREETS GO TO CASCADA AND THE CODEBLASTERS'
		DB '          TO TRITON AND FUTURE CREW - YOUR DEMOS ARE IMPRESSING'
		DB '          TO ALL OTHER GROUPS  -   KEEP UP THE GOOD WORK'
		DB '            ALL OF YOU GUYS STUDYING  MASTER OF SCIENCE  IN UPPSALA AND STOCKHOLM  -  BUY US A BEER IF YOU ENJOY THE GAME'
		DB '           ALSO GREETINGS TO THE CAPED CRUSADER OF THE FINGERBOBS (ATARI SCENE) TCC '
		DB 'SAYS HI TO CREEPER, OBERJE, DAWN, RACHAEL AND ANN. HI ALSO TO '
		DB 'THE GREAT BAZZA AT 21ST CENTURY.           '
		DB '           TO THE CODERS OF EMM386 AND QEMM DRIVERS - MAKE THE INTERRUPT HANDLING FASTER'
		DB '     RIGHT NOW THEY MAKE THE COMPUTER GO SOOOOOOO SLOW',21 DUP(1),255
ROBBANSCROLL	DB 21 dup(1),'THANX FOR THE GRAVIS ULTRASOUND PLAYER',21 DUP(1),255
STEINSCROLL	DB 21 dup(1),'HOPE WE CAN MAKE THAT VECTORGAME WE TALKED ABOUT',21 DUP(1),255
TECHSCROLL	DB 21 dup(1),'YEAH     YOU ARE PROBABLY WONDERING HOW IT IS POSSIBLE TO MAKE A GAME LIKE THIS ON THE PC'
		DB '                         FIRST OF ALL THE GAME IS CODED IN 100 PERCENT ASSEMBLER LANGUAGE              '
		DB '      WE RUN IN A SPECIAL VGA   320 X 240   OR   360 X 350   IN 256 COLOR MODE                        HARDWARE IS USED FOR SCROLLING THE TABLE           '
		DB '      THE FLIPPERS AND DOT MATRIX SCOREPANEL ARE DELTA ANIMATED AND TO MAKE THE GRAPHICS RUN FLICKER FREE WE ARE USING RASTER INTERRUPTS                      THE PALETTE IS USED FOR FLASHING THE LIGHTS      '
		DB '                     THE MUSIC ROUTINE HAS FEATURES SUCH AS SOFT CLIPPING AND INTERPOLATIVE MIXING          '
		DB '                  ALTOGETHER THIS MAKES THE GAME POSSIBLE TO RUN ON A 12 MHZ 286 WITH SOUNDBLASTER MUSIC AT 16KHZ IN EACH FRAME'
		DB 21 DUP (1),255

techTS		label worD
		clearit
		dw _scroll,TECHSCROLL
		dw 0
CHEATTS		label worD
		clearit
		dw _scroll,CHEATSCROLL
		dw 0
robbanTS	label worD
		clearit
		dw _scroll,robbanSCROLL
		dw 0
steinTS		label worD
		clearit
		dw _scroll,steinSCROLL
		dw 0
greetTS		label worD
		clearit
		dw _scroll,greEtSCROLL
		dw 0
DANIELTS		label worD
		clearit
		dw _scroll,DANIELSCROLL
		dw 0
GABRIELTS	label worD
		clearit
		dw _scroll,GABRIELSCROLL
		dw 0
JOHANTS		label worD
		clearit
		dw _scroll,JOHANSCROLL
		dw 0
tSPTS		label worD
		clearit
		dw _scroll,TSPSCROLL
		dw 0
QUAKETS		label worD
		clearit
		dw _scroll,TILTSCROLL
		dw 0
SnailTS		LABEL WORD
		CLEARIT
		DW _SCROLL,SNAILSCROLL
		DW 0
BallsTS		LABEL WORD
		CLEARIT
		DW _SCROLL,BALLSSCROLL
		DW 0
FairPlayTS	LABEL WORD
		CLEARIT
		DW _SCROLL,FAIRPLAYSCROLL
		DW 0

NewplayerTS	label word
		clearit
		dw _print5,playerstext,sw*2*2/4+16*1/4
		dw _print5,no_of_players_text,sw*2*10/4+16*1/4
		dw 0
;quitting frÜgan
quit_fragenTS	LABEL WORD
		CLEARIT
		dw _flashoff,?
		DW _PRINT13,quit_TEXT,sw*2/4*2+16*0/4
		dw _WAIT_YN,?
		dw _jmp,showhighsTS

HALL_DIG_BORTATS dw _wait,1 
		DW _LOCK,1
		dw 0
		
quit_TEXT	DB 'REALLY QUIT ','Z'+2,'Y OR N','Z'+3,0
quitgam_TEXT	DB ' END GAME  ','Z'+2,'Y OR N','Z'+3,0

DATA	ENDS

CODE	SEGMENT PARA PUBLIC 'CODE'
	ASSUME	CS:CODE,DS:DATA
	EXTRN	UNPKLBM:NEAR,kollakulan:near
	EXTRN	PUTBALL:NEAR,DELBALL:NEAR
	MARG	DB 0
	OLDMARG	DB 0

FANTASIES PROC FAR
	MOV	BP,DS	
	MOV	AH,4AH
	MOV	BX,LASTSEG
	SUB	BX,BP
	ADD	BX,1024/16
	INT	21H		;HéR FôRSVINNER BAN-GRAFIKEN
	MOV	AX,DATA
	MOV	DS,AX
IF STAND_ALONE
	MOV	TOGGLAREN.S_SCROLLING,1
ELSE
	MOV	AX,0200H	;RESIDENTA TOGGLAREN => LOKALA TOGGLAREN
	MOVE	ES,DS
	LEA	BX,TOGGLAREN
	INT	KEYHANDLER
ENDIF

if stand_alone
	mov	hi_res,true
else
	MOV	HI_RES,FALSE
	CMP	TOGGLAREN.S_RESOLUTION,0
	JZ	ITS_LOW_RES
	MOV	HI_RES,TRUE
ITS_LOW_RES:
endif

;HéR DANIEL!!!
	CMP	TOGGLAREN.S_ANGLE,0
	JZ	NORMAL_ANGLE
	CALL	TABLE_ANGLE
NORMAL_ANGLE:

	MOV	NO_OF_BALLS,3
	CMP	TOGGLAREN.S_BALLS,0
	JZ	ITS_3_BALLS
	MOV	NO_OF_BALLS,5
ITS_3_BALLS:

	CMP	TOGGLAREN.S_IM,0
	JE	ITS_ON_THE_MUSIC
	CALL	MUSIC_TOGGLE
ITS_ON_THE_MUSIC:

	CMP	TOGGLAREN.S_SCROLLING,1
	JB	CF11
	JA	CF9
	CALL	F10
	JMP	SHORT KLAR
CF9:	CALL	F9
	JMP	SHORT KLAR
CF11:	CALL	F11
KLAR:

if debug
	debugclear	
endif
IF DEBUG
	debugmess 0,0,"Pinball Fantasies PC by FrontLine Design"	
ENDIF
	cli	;CP!?
IF DEBUG
	debugmess 0,1,"Initing..."
ENDIF
	CALL	INIT_SIN
	CALL	INIT_SCROLL
	call	init_ballspeed
	CALL	INIT_MATRIX

	CALL	BREDDA_MASK
IF DEBUG
	debugmess 0,1,"Init gfx..."
ENDIF
	CALL	INIT_GFX
IF DEMOVER
ELSE
	CALL	INIT_HIGHS	
ENDIF
	MOVE	DS,DATA

	;************** CHECKSUMMA 1 START ***************
CHECK1_START:
	MOV	RGBBUFPTR,OFFSET RGBBUFFER
	CALL	RECALC_LIGHTS
	CALL	RECALCFLASHLIST

	CALL	MASKS2GFX	;INUTI LIGGER INIT_FLIPPERS (AV NèN ANLEDNING)
;FATALT_HOPP:
	CALL	INIT_SPRING
	CALL	INIT_KEY
	cmp	hi_res,true
	jne	notcalc3
	or	shiftkeys,100b
notcalc3:
	CALL	INIT_MOUSE
	CALL	INIT_SOUND
CHECK1_END:
	;************** CHECKSUMMA 1 END ***************

	MOVE	DS,DATA
	MOV	STATUS,LOWER			;INIT BEEM VARS
	MOV	VERYFIRSTPUT,TRUE
	MOV	LATEGFX,FALSE
	MOV	INTERRUPTS_ON,FALSE

	CALL	JUST_ONE_TIME_RESET
	CALL	JUST_ONE_TIME_RESET_TABLE

	sti


	call	go_DEMO_mode	;CP! DEMO MODE

	MOV	SCREENFORCE,BANH-(SH_LO-SPLH)
	CMP	HI_RES,TRUE
	JNE	NOTHIRES2
	MOV	SCREENFORCE,BANH-(SH_HI-SPLH)
	CALL	KILL_UPPER_LINE
NOTHIRES2:
	MOV	CARMEN,-1


if demover
	CALL	game_MUSIC	;cp! demo mode
else
	CALL	demo_MUSIC	;cp! demo mode
endif
	call	setscreenstart
	CALL	INIT_INTS	
	
	call	slack_lights_i_pelle

	CMP	TOGGLAREN.S_MODE,0
	JZ	DONOTCONV
	CALL	COLOR_2_BW
	call	pelle_2_bw
DONOTCONV:
	
	
;	XOR	BX,BX
;TONA:	ADD	BX,1
	mov	bx,256
	CALL	SETPAL
;	cmp	bx,256
;	jb	tona
		
	MOV	AX,4
	MOV	BX,2
	mov	cx,0	;0=use configurated rate
	INT	66H		;PLAY MODULE
	IF_ERROR 1,OUTOFMEMORY
	IF_ERROR 2,INIT_ERR
	


	mov	uppstartad,true
	MOV	INTERRUPTS_ON,TRUE  ;********** INTERRUPTS ENABLED! **********
IF DEBUG
	debugmess 0,1,"Running...                "
ENDIF
IF DEBUG
	MOV	AH,48H
	MOV	BX,0FFFFH
	INT	21H
	DEBUGVAL 0,22,BX,"Free memory after all: "
ENDIF
	jmp main
TABLE_ANGLE Proc Near 
;for (c=0;c<11;c++) ramptable[c]-=4;

	mov	bx,offset ramptable
	cmp	hi_res,false
	je	goda_grannar
	mov	bx,offset ramptable_hi
goda_grannar:
	mov	cx,no_of_ramps
luta:	sub	word ptr [bx+2],3
	add	bx,4
	loop	luta
	retn
TABLE_ANGLE EndP

init_ballspeed proc near ;ersÑtt den gamla med denna
cmp	hi_res,true
je	no_adde_malmberg

mov	bx,offset materialdata
mov	cx,8
mov	bp,5
mov	si,6
hemul:	mov	ax,[bx+6]
imul	bp
idiv	si
mov	[bx+6],ax
add	bx,16
loop	hemul

skala56 MINUSHASt
skala56 PLUSHAST	
skala56 bumperpower	
skala56 kickerpower	
skala56 kickminhast	
skala56 TILTHASTFW	
skala56 TILTHASTRV	

no_adde_malmberg:
retn	
init_ballspeed endp
;**********
already_quitting db false
checkquit:
	cmp	cs:already_quitting,true
	je	no_fragen_sie_bitte_die_ende
	mov	cs:keyboard_enabled,false
	mov	CS:ALREADY_QUITTING,TRUE
	mov	bx,offset quit_fragenTS
	call	do_matrix
no_fragen_sie_bitte_die_ende:
retn
;***********

KILL_UPPER_LINE PROC NEAR
	SETWRITE 1111B
	MOVE	ES,0A000H
	MOV	DI,SPLH*SW/4
	MOV	CX,320/4/2
	XOR	AX,AX
LUPPEN:	STOSW
	LOOP	LUPPEN
	RET
KILL_UPPER_LINE ENDP

checkpause:
if	demover
;	jmp	nopause
endif
	CMP	PAUSEFLAG,false
	JE	NOPAUSE
	mov	interrupts_on,false
	mov	al,15
	int	66h		;STOP
	CALL	PRINT_PAUSE
;	DEBUGMESS 20,6,"in i pauseloopen"
	mov	scan_code,-1

FEELP:	cmp	scan_code,1	;leverkorv
	je	kaka_calamares	;Esc pressed!!
kaka_pasa:
	cmp	scan_code,-1
	JE	FEELP
	cmp	scan_code,1
	je	kaka_calamares	;Esc pressed!! Y or N ????
judas:				;LÜt han lîpa!!
	mov	calamares_delay,30
	mov	scan_code,-1
;	DEBUGMESS 20,6,"ut ur den!!!!!!!"


	mov	cx,0	;0=use configurated rate
	MOV	AX,4
	MOV	BX,3
	INT	66H		;PLAY MODULE
	IF_ERROR 1,OUTOFMEMORY
	IF_ERROR 2,INIT_ERR
	CALL	RESTORE_AFTER_PAUSE
	mov	interrupts_on,true
	mov	pauseflag,false
NOPAUSE:
	RETN

lat_den_sta:
;=============== DETTA éR EN CP-LôSNING FôR ATT Fè TYST ======================
	MOVE	DS,DATA
	MOV	HOLDSTILL,TRUE
	CALL	RESTORE_AFTER_PAUSE
	mov	pauseflag,false
	
;MOV INTERRUPTS_ON,TRUE
;MOV CS:QUITTING,TRUE
;MOV SI,0 ;?
;RETN
	
	
	xor	muzik_off,true
;CP?	jz	its_off_not

;CP?	call	its_off	;Turn him on . . . not!
its_off_not:
	mov	cs:levin,true	;en riktig urban!!
	mov	si,0
	push	si
	MOV	CX,0
	MOV	AL,6
	INT	66H	;set vol
	mov	interrupts_on,true
	pop	si

	mov	cx,0	;0=use configurated rate
	MOV	AX,4
	MOV	BX,3
	INT	66H		;PLAY MODULE
;	IF_ERROR 1,OUTOFMEMORY
;	IF_ERROR 2,INIT_ERR
	JMP	QUIT	;CP!?
	
	MOV	CS:QUITTING,TRUE
	mov	si,1
	retn
;=============================================================================
kaka_calamares:
	PUSH	OFFSET quit_TEXT
	POP	AX_PRINT
	MOVE	DI_PRINT,sw*4/4
	call	print_it_klux
do_kk_again:
	mov	scan_code,-1
keck_agan:
	cmp	scan_code,-1
	je	keck_agan		;wait for keypress!
	mov	bx,offset alfa_keys
	mov	al,scan_code
	xlat
	cmp	al,'Y'		;y or anything!
	je	quitteras
	jmp	judas	;lÜt han gÜ!!
quitteras:
	jmp	lat_den_sta
;	jmp	judas


ifscan macro tangent,rutin
	local	nedu
	cmp	scan_code,tangent
	jne	nedu
	mov	scan_code,-1
	call	rutin
nedu:
	endm
ifscan_set macro tangent,var,val
	local	nedu
	cmp	scan_code,tangent
	jne	nedu
	mov	scan_code,-1
	mov	var,val
nedu:
	endm
checkgamequit:
	SETBALLPOS 300,570,0,0,FALSE
	MOV	CS:KEYBOARD_ENABLED,TRUE
	addtask	to_demo_from_game
	CALL	DEMO_MUSIC	;CP!???
	mov	scan_code,-1
	call	kill_flashor
	mov	bx,offset showhighsTS
	call	do_matrix
	retn
	
;checkgamequit:
	CMP	ADDPLAYERS,TRUE
	JE	NO_END_GAME
	PUSH	OFFSET quitgam_TEXT
	POP	AX_PRINT
	MOVE	DI_PRINT,sw*4/4
	call	print_it_klux
do_kks_again:
	mov	scan_code,-1
	MOV	CS:KEYBOARD_ENABLED,FALSE
	ADDTASK	ALLADIN
	RETN

NO_END_GAME:
	ADDTASK	END_GAMEN	;VID FLERA SPEL:POLYGAMI?
	RETN
	
ALLADIN:
kecks_agan:
	cmp	scan_code,-1
	je	RETSTICKA	;kecks_agan ;wait for keypress!
	MOV	CS:NEGERN,60	;Sè MAN HINNER STéDA TILLS FARBROR STEWI KOMMER
	mov	bx,offset alfa_keys
	mov	al,scan_code
	xlatb
	cmp	al,'Y'		;y or anything!
	je	end_gamen
ko_gamen:
	ADDTASK	CP_WAIT_FOR_MATRIX
	mov	bx,offset SHOWplayerSTS
	call	do_matrix
	SUICIDE
RETSTICKA:
retn
NEGERN	DB ?
CP_WAIT_FOR_MATRIX:
;	DEC	CS:NEGERN
;	JZ	JOBBA_DIG
	cmp	dotrut,offset nodot
	je	jobba_dig		;stÑdat Ü klart!!
	RETN
JOBBA_DIG:
	MOV	CS:KEYBOARD_ENABLED,TRUE
	mov	scan_code,-1
	SUICIDE
end_gamen:
	SETBALLPOS 300,570,0,0,FALSE
	addtask to_demolation_derby
	MOV	first_time_you_fool,true
	MOV	CS:NEGERN,6	;Sè bollen hinner slÑckas
	suicide
to_demolation_derby:
	DEC	CS:NEGERN
	jz	negressen
	retn
negressen:
	MOV	CS:KEYBOARD_ENABLED,TRUE
	addtask	to_demo_from_game
	CALL	DEMO_MUSIC	;CP!???
	mov	scan_code,-1
	SUICIDE

checkstartkeys:
	MOV	AL,SCAN_CODE
	CMP	AL,3BH
	JB	NOTF1F8
	CMP	AL,42H
	JA	NOTF1F8
	MOV	SCAN_CODE,-1
	CMP	ADDPLAYERS,FALSE
	JE	STARTDONE
	MOV	ADDPLAYERS,FALSE
	MOV	F1F8_CODE,AL	;=0: NOT PRESSED!
	MOV	OLD_F1F8_CODE,AL
	MOV	PLAYERS_CP,FALSE

NOTF1F8:
	CMP	AL,1CH
	JNE	NOTENTER
	MOV	SCAN_CODE,-1
	CMP	PLAYERS,8
	JNB	STARTDONE
	CMP	ADDPLAYERS,FALSE
	JE	STARTDONE
	CMP	PLAYERS_CP,FALSE
	JE	PLAYERS_NOT_CP
	MOV	PLAYERS,0
	MOV	PLAYERS_CP,FALSE
PLAYERS_NOT_CP:
	INC	PLAYERS
	MOV	AL,PLAYERS
	ADD	AL,3BH-1	;3BH=CODE FOR F1
	MOV	ADDPLAYERS,FALSE
	MOV	F1F8_CODE,AL
	MOV	OLD_F1F8_CODE,AL
	JMP	STARTDONE
NOTENTER:

STARTDONE:
	RETN

KEYBOARD_ENABLED DB true
SETTER DB 2
tiltkey2	db false
TILTLOGIC:
	CMP	TILTDISABLED,TRUE
	JE	RETTMIGGA
	pusha
	cmp	i_utskjut,true		;Ej skjutit ut den
	je	tiltdone
	CMP	TILTFLAG,TRUE		;redan 'tilt tilt tilt'
	JE	tiltDONE
	CMP	BALL_DOWN,TRUE		;Redan dîtt
	JE	TILTDONE
	CMP	cs:TILTKEY2,TRUE
	JE	TILTDONE		;REDAN BANKAT!!
	ADD	TILTCOUNTER,60

;	mov	bx,tiltcounter
;	debugval 0,12,bx,'tiltcounter='
	
	mov	cs:tiltkey2,true

	CMP	TILTCOUNTER,120		;Tvè ska gè
	JA	DOTIL
	CMP	TILTCOUNTER,60
	JBE	TILTDONE
	CALL	HE_ALMOST_TILTED	;Varningsjingle
	JMP	tiltDONE
DOTIL:	
	MOV	TILTFLAG,TRUE		;LÜt han fÜ 'tilt tilt tilt'
	CALL	HE_TILTED
	JMP	TILTDONE
	
TILTDONE:
	mov	scan_code,-1
	popa
RETTMIGGA:
	RETN
	
music_toggle:
	xor	muzik_off,true
	jnz	its_off

	mov	al,springjingle
	mov	s_spring,al
	mov	al,mainjingle
	mov	s_main,al
	mov	lastjingle,mainjingle
	CMP	SPRING_VALID,TRUE
	CMP	i_utskjut,TRUE
	JNE	NOSPRINGTUNE
	MOV	LASTJINGLE,SPRINGJINGLE
NOSPRINGTUNE:
	cmp	jinglejumpcnt,1
	jnl	mdone
	mov	jinglejumpcnt,1
	jmp	mdone
its_off:				;NEJ! STéNG AV!
	mov	al,emptyjingle
	mov	byte ptr s_spring,al
	mov	byte ptr s_main,al
	cmp	lastjingle,emptyjingle
	je	mdone
	addtask	turnoffmusic
notM:
mdone:	retn

turnoffmusic:
	mov	current_priority,0
	playjingle s_empty
	suicide

checkcheat:
	mov	bx,offset alfa_keys
	mov	al,scan_code
	cmp	al,-1
	je	novalidkey
	nil	ah
	xlat
	cmp	al,0
	je	novalidkey
	mov	densomsparhanhar,al
	move	es,data
	mov	scan_code,-1
	mov	bx,cheatpekare
	mov	[bx+offset cheatinput],al
	inc	cheatpekare
	cmp	cheatpekare,12		;av sÑkerhetsskÑl, ska aldrig hÑnda!!
	jbe	eatit
	mov	cheatpekare,0
	mov	cx,12
	mov	di,offset cheatinput
	mov	al,' '
	rep	stosb
;	debugmess 0,2,'overflow'
	retn
eatit:
;check it	
coulditbe:
	mov	si,offset cheats
	mov	dont_know_yet,false
	
checkit:	
	mov	di,offset cheatinput
	lodsw
	cmp	ax,255
	je	endofcheats	;inga cheats stÑmde!!
	mov	bx,ax		;fîr att kunna kalla pÜ bx om det stÑmde!!
	mov	dx,0
nexttest:
	lodsb
	cmp	al,'$'
	je	found

	cmp	dx,cheatpekare
	jae	nownaaaating
	inc	dx
	cmp	al,[di]
	jne	notfound
	inc	di
	jmp	nexttest
nownaaaating:
;	debugmess 0,1,'no naating'
;	debugmess 0,2,'no naating'
	mov	dont_know_yet,true
notfound:
	lodsb
	cmp	al,'$'
	je	checkit
	jmp	notfound
endofcheats:
	cmp	dont_know_yet,true
	je	norezza_ofit
	mov	cheatpekare,1
	mov	cx,11
	mov	di,offset cheatinput
	mov	al,densomsparhanhar
	stosb
	mov	al,' '
	rep	stosb
norezza_ofit:
	retn
novalidkey:
	retn

found:
	mov	cheatpekare,0
	call	bx
	retn

MAIN:
if debug
	MOV	AL,9
	INT	66H
	mov	BL,AL
	NIL	BH
	debugval 40,19,bx,"CURRENT POSITION: "
	mov	BL,LASTJINGLE
	NIL	BH
	debugval 0,19,bx,"LASTJINGLE: "
	cmp	dotrut,offset nodot
	je	ledignuju	
	debugmess 0,2,'DOT BUSY'
	jmp	ulurkur
	ledignuju:
	debugmess 0,2,'DOT FREE'
	ulurkur:
	debugbcd 50,0,siffrorna,"siffrorna="
endif


	cmp	cs:keyboard_enabled,false
	je	no_command_keys		;DÜ tangentbordet Ñr upptaget . . 

	;SKALL ALLTID FUNKA:
	IFSCAN	67,F9
	IFSCAN	68,F10
	CMP	FFLAG,11
	JNE	NF11
	CALL	F11
NF11:
	CMP	FFLAG,12
	JNE	NF12
	CALL	F12
NF12:

;******** if demomode ******
	cmp	demomode,true
	jne	no_demomode
	;Tangenter: f-keys + quit + cheats (om nÜn orkar!) JOHAN èRKADE
	call	checkstartkeys
	call	checkcheat
	ifscan	1,checkquit
	jmp	no_command_keys

no_demomode:
	cmp	loosing,true
	je	no_command_keys

;******** if in chute ******
if demover
else
	cmp	spring_valid,true	;cp!
	jne	no_chute
	ifscan	1,checkgamequit
	cmp	cs:keyboard_enabled,false
	je	no_command_keys		;DÜ tangentbordet Ñr upptaget . . 
	call	checkstartkeys
endif
no_chute:
;******** if ingame ********
	;Tangenter: pause
	IFSCAN	57,TILTLOGIC
	ifscan	50,music_toggle
	ifscan_set 25,pauseflag,true
	call	checkpause
no_command_keys:
	ifscan_set 1,SCAN_CODE,-1

	inc	slump_countern
	cmp	holdstill,false
	je	noskruv
	mova	rotation,slump_countern
	and	rotation,1023
	test	rotation,1
	jz	noskruv
	neg	rotation
noskruv:
IF DEBUG
	debugval 0,6,sc_y,"Ypos="
;	DEBUGVAL 0,8,FLIPLINFO.LASTGFXFRAME,"LASTGFXFRAME"
	MOV	BL,FLIPLINFO.LASTFRAME
	NIL	BH
;	DEBUGVAL 0,9,BX,"LASTFRAME"
;	DEBUGVAL 0,10,FLIPLINFO.FLIPFRAME,"FLIPFRAME"
	mov	bl,jingle_ready_anim
	nil	bh
;	debugval 40,2,bx,"jing_red_anim="
	mov	bl,jingle_ready_logic
	nil	bh
;	debugval 40,3,bx,"JING_RED_LOGIC"
	debugval 0,3,gravx,"X gravitation="
	debugval 0,4,gravy,"Y gravitation="
	debugval 0,5,sc_x,"Xpos="
	cmp	ballhigh,true
	je	notl
	debugmess 0,7,"Lower level"
notl:	
	cmp	ballhigh,true
	jne	noth
	debugmess 0,7,"Upper level"
noth:	
	mov	cx,word ptr hitvalue
	debugval 0,8,cx,"Material="
	debugval 0,9,rotation,"rotation="
	MOV	CL,CURRENT_PRIORITY
	MOV	CH,0
;	debugval 0,13,cx,"CURRENT PRIORITY: "
;	debugbcd 30,9,JACKVALUE,"JACKPOT="
;	debugbcd 0,9,player_area.p_siffrorna,"player_area PoÑng="
;	debugbcd 0,10,player_area.p_bonussiffrorna,"player_area Bonus="
	debugVAL 0,11,NO_OF_ACTIVE_TASKS,"No of active tasks="
;*******
	mov	ax,sc_y
	MOV	DX,0
	mov	bX,576/25+1
	div	bX
	mov	bp,ax
	mov	ax,sc_x
	MOV	DX,0
	mov	bX,320/40
	div	bX
	mov	si,ax
	add	si,40
;*******
	push	si bp
	mov	si,oldx
	mov	bp,oldy
	debugmess si,bp," "
	pop	bp si
	mov	oldx,si
	mov	oldy,bp
	debugmess si,bp,"O"
ENDIF
	
	CMP	CS:QUITTING,TRUE
	JE	QUIT
;	mov	time_left,true
	SET_ES	0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]	;CREATE MUSIC
	JMP	MAIN	
QUITTING DB FALSE

F9:	MOV	SLIME_FACTOR,9
	RETN

F10:	MOV	SLIME_FACTOR,SLIME_FACTOR_DEFAULT
	RETN

F11:	MOV	FFLAG,0
	MOV	SLIME_FACTOR,20
	RETN

F12:	MOV	FFLAG,0
	MOV	SLIME_FACTOR,40
	RETN

JUST_ONE_TIME_RESET:
	mov	current_prIORITY,0
	MOV	LASTJINGLE,0
	MOV	LASTPRIORITY,0
	MOV	PRINTTASK,OFFSET DUMRET
	mov	rullstart,0
	mov	rulltext,0
	mov	rull_pos,0
	mov	upp_add,0
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	rull_pos,0
	MOV	ALLOWFLIP,FALSE
if demover	
	MOV	F1F8_CODE,3bh ;CP! automatic 1 player in demo version
else
	MOV	F1F8_CODE,0 ;CP! not automatic 1 player in game version
	MOV	OLD_F1F8_CODE,0
endif
	MOV	HOJD_ADD,0
	MOV	NODOTCOUNT,NOT_PLAYING-2
	MOV	FJANTTEXT,FALSE
	MOV	CENT,FALSE
	
	CALL	RESETFLASHLIST
	CALL	RESET_TASK_LIST
	CALL	RESET_WAITLIST
	cmp	hi_res,true
	calle	hires_changes
	RETN
hires_changes:
	mov	sync_per_sec,71 ;?
	retn
RESET_WAITLIST:
	MOVE	ES,DS
	NIL	AX
	MOV	DI,OFFSET WAITLIST
	MOV	CX,MAX_NO_OF_WAIT_SYNCS
	REP	STOSW				;CP!
	RETN

WHEN_NEW_BALL_RESET:
	MOV	LASTCHECK,0
	MOV	SPRING_VALID,TRUE
	MOV	SHIFTPRESSED,FALSE
	MOV	KEYTASK,OFFSET DUMRET
	MOV	JINGLE_READY_ANIM,TRUE
	MOV	JINGLE_READY_LOGIC,TRUE
	MOV	INH_EFF,FALSE
	MOV	LOOSING,FALSE
	MOV	SPECIALMODE,FALSE
	MOV	INHIBIT_COUNT_DOWN,FALSE	;(PENETRATION OF SPECIAL MODE)
	MOV	DOT_READY,TRUE
	CALL	RESETFLASHLIST
	CALL	RESET_TASK_LIST
	CALL	RESET_WAITLIST

	CMP	PARTYFLASH,TRUE
	JE	NO_UPDAT_PLEASE
	MOV	MATRIX_IS_FLASHING,FALSE
	call	kill_flashor
;Fîr att inte senaste spelarens score skall synas!!
	CMP	VISAKEYS,TRUE
	JNE	NONEWPL	
	MOV	VISAKEYS,FALSE
;	updat_score
;	mov	bx,offset newplayerTS
;	call	do_matrix
	JMP	REDIGRET
NONEWPL:
	updat_score
	mov	bx,offset SHOWplayerSTS
	call	do_matrix
REDIGRET:
	retn
NO_UPDAT_PLEASE:
	RETN

RESET_TASK_LIST PROC NEAR
	MOV	AX,OFFSET DUMRET
	MOV	CX,NOOFTASKS
	MOV	BX,OFFSET TASKLIST
RESETNXTTASK:
	MOV	[BX],AX
	ADD	BX,2
	LOOP	RESETNXTTASK
	RETN
RESET_TASK_LIST ENDP

WHEN_NEW_GAME_RESET:
	MOV	CS:KEYBOARD_ENABLED,TRUE
	MOV	AFTER_CHEAT,FALSE
	MOV	BALLS[11],1
	MOV	AL,BALLS[11]
	ADD	AL,'7'	;SEPEKOMPENSERING
	MOV	BALLSTEXT[5],AL
	MOV	PLAYER,1
	MOV	AL,PLAYER
	ADD	AL,'7'	;SEPEKOMPENSERING
if	demover
else
	MOV	PLAYERSTEXT[7],AL
endif
;cpskydd	MOV	MAKE_BAD,true		;gnu urban
	;************** CHECKSUMMA 1 AVKéNNING ***************
	MOV	SI,OFFSET CHECK1_START
	MOV	CX,OFFSET CHECK1_END
	SUB	CX,SI
	XOR	AH,AH
	MOVE	DS,CODE
SVEN_BERTIL_TAUBE:
	LODSB
	ADD	AH,AL
	LOOP	SVEN_BERTIL_TAUBE
	MOVE	DS,DATA
	SUB	AH,2
COMMENT\		;* #CHK# kommentera bort...
PUSHA
MOV AL,AH
NIL AH
DCLS
DPRINTVAL AX," AX="
POPA
\

if (bana EQ 1)
	CMP	AH,197+7
endif
if (bana EQ 2)
	CMP	AH,165+7
endif
if (bana EQ 3)
	CMP	AH,37+7
endif
if (bana EQ 4)
	CMP	AH,83+7
endif
	JnE	WASnt_OKKK
	MOV	MAKE_BAD,false		;gnu urban
WASnt_OKKK:
	MOV	ADDPLAYERS,TRUE
	MOV	DOT_READY,TRUE
	mov	already_beaten,false
	MOV	VISAKEYS,TRUE
	RETN

INIT_ERR:
	SET_DS	DATA
	CALL	UNINST_KEY
	MOV	AX,0
	INT	66H
	MOV	AX,3
	INT	10H
	PRINTMESS "Can't init sound device!"
	MOV	AX,4C02H
	INT	21H

errorloadingmod:
	SET_DS	DATA
	CALL	UNINST_KEY
	MOV	AX,0
	INT	66H
	MOV	AX,3
	INT	10H
	PRINTMESS "Error loading module!"
	MOV	AX,4C04H
	INT	21H
cantfindmod:
	SET_DS	DATA
	CALL	UNINST_KEY
if mongi_resiplay
else
	MOV	AX,0
	INT	66H
endif
	MOV	AX,3
	INT	10H
	PRINTMESS "Can't find "
	mova	ds,data
	mov	dx,offset modul
	mov	ax,900h
	int	21h

if mongi_resiplay
	MOV	AX,0
	INT	66H
else
endif

	MOV	AX,4C04H
	INT	21H
OUTOFMEMORY:
	SET_DS	DATA
	CALL	UNINST_KEY
	MOV	AX,0
	INT	66H
	MOV	AX,3
	INT	10H
	PRINTMESS "Out of memory! The selected sounddriver requires more memory!",13,10,"Please refer to the manual!",13,10,13,10
	MOV	AX,4C01H
	INT	21H
levin	db false
ERRQUIT:
QUIT:	
IF STAND_ALONE
ELSE
	mov	interrupts_on,false
	mov	cs:fading,true
	call	readpal
	mov	si,256
gosp:	CMP	SYNC_COUNTER,0
	JZ	GOSP
	MOV	SYNC_COUNTER,0
	DEC	SI
	call	faderut
	push	si
	cmp	cs:levin,true
	je	goga_dada
	mova	es,0
	mov	ax,8
	pushf
	call	dword ptr es:[66h*4]
goga_dada:
	pop	si
	or	si,si
	jg	gosp
	
ENDIF
	MOV	AX,0
	INT	66H		;DISINST SOUND
	MOV	AX,0
	INT	33H			;RESET MOUSEDRIVER/CHECK IF MOUSE INSTALLED

	CALL	UNINST_KEY
IF DEMOVER
ELSE
	CALL	SAVE_HIGHS
ENDIF
IF STAND_ALONE
	MOV AX,3
	INT 10H
ENDIF
IF DEBUG
	debugmess 0,1,"Thanx for playing!"
ENDIF
	MOV	AX,4C00H
	INT	21H	


jcall dw 0
JINGLE_HANDLER PROC FAR
IF DEBUG
	inc	cs:jcall
	debugval 0,12,cs:jcall,"jinglecall no "
ENDIF
	SET_DS	DATA
	cli
	DEC	JINGLEJUMPCNT
IF DEBUG
	pushf
	mov	BL,LASTJINGLE
	NIL	BH
	debugval 0,19,bx,"LASTJINGLE: "
	mov	bL,jinglejumpcnt
	NIL	BH
	debugval 0,20,bx,"Jinglejumpcnt: "
;	mov	bL,LASTLOOPVAL
;	NIL	BH
;	debugval 0,21,bx,"LASTLOOPVAL: "
	popf
ENDIF
	JZ	JINGLEREADY
	JL	JINGLELOOP
	jmp	check_m_off
	retf
JINGLELOOP:
	MOV	JINGLEJUMPCNT,0
	jmp	check_m_off
	RETF	
JINGLEREADY:
	
	MOV	AL,LASTPRIORITY
	MOV	CURRENT_PRIORITY,AL
;	MOV	AL,LASTLOOPVAL
	MOV	JINGLEJUMPCNT,0 ;AL
	MOV	AL,LASTJINGLE
muzikof:
	MOV	JINGLE_READY_ANIM,TRUE
	MOV	JINGLE_READY_LOGIC,TRUE
check_m_off:
	sti
	cmp	muzik_off,false
	je	goretf
	cmp	al,lastmainpos
	ja	goretf
	mov	al,emptyjingle	
goretf:	RETF
ENDP

MASKS2GFX PROC NEAR
	PUSH	DS
	mov	bp,GFXMASK21_OFFSET
	MOVA	DS,MASK2_1
	MOVA	ES,0A000H
	MOV	DX,3C4H
	MOV	AL,2
	MOV	CX,4
	MOV	AH,10001B
BITPL:	PUSH	CX
	OUT	DX,AX
	ROL	AH,1
	MOV	DI,bp
	MOV	SI,CX
	DEC	SI
	XOR	SI,11B
	MOV	CX,510*40/4
FLYT:	MOVSB
	ADD	SI,3
	LOOP	FLYT
	POP	CX
	LOOP	BITPL
	MOV	BP,DI
	mova	ds,data
	mov	GFXMASK23_OFFSET,di
	PUSHA
	PUSH	ES
	CALL	INIT_FLIPPERS		;CP!?
	POP	ES
	POPA
	
	
	MOVA	DS,MASK2_3
	MOV	DX,3C4H
	MOV	AL,2
	MOV	CX,4
	MOV	AH,10001B
BITPL2:	PUSH	CX
	OUT	DX,AX
	ROL	AH,1
	MOV	DI,BP	;FIRSTPOS
	MOV	SI,CX
	DEC	SI
	XOR	SI,11B
	MOV	CX,510*40/4
FLYT2:	MOVSB
	ADD	SI,3
	LOOP	FLYT2
	POP	CX
	LOOP	BITPL2
	MOV	BP,DI
	mova	ds,data
	mov	GFXMASK13_OFFSET,di
	MOVA	DS,MASK1_3
	MOV	DX,3C4H
	MOV	AL,2
	MOV	CX,4
	MOV	AH,10001B
BITPL3:	PUSH	CX
	OUT	DX,AX
	ROL	AH,1
	MOV	DI,BP	;FIRSTPOS
	MOV	SI,CX
	DEC	SI
	XOR	SI,11B
	ADD	SI,230*40	;RESTEN FINNS I MARGINALEN
	MOV	CX,(576-230)*40/4
FLYT3:	MOVSB
	ADD	SI,3
	LOOP	FLYT3
	POP	CX
	LOOP	BITPL3

	MOV	DX,3C4H
	MOV	AL,2
	MOV	CX,4
	MOV	AH,10001B
BITPL4:	PUSH	CX
	OUT	DX,AX
	ROL	AH,1
	MOV	DI,SPLH*BPL+80	;FIRSTPOS
	MOV	SI,CX
	DEC	SI
	XOR	SI,11B
        MOV	CX,575
FLYT4:	
REPT 4
	MOVSB
	ADD	SI,3
ENDM
	ADD	DI,80
	LOOP	FLYT4
	POP	CX
	LOOP	BITPL4
	POP	DS
	RETN
ENDP
INIT_FLIPPERS PROC NEAR
	mov	si,offset adjusttable
	mov	cx,adjust*24
	mov	bx,adjust
makeadjust:
	mov	ax,adjust*24
	sub	ax,cx
	xor	dx,dx
	div	bx
	mov	[si],ax
	add	si,2
	loop	makeadjust

	MOVE	ES,0A000H
	MOV	DX,3C4H
	MOV	AX,0F02H
	OUT	DX,AX
	MOV	DI,0
	MOV	CX,SPLH*BPL
	MOV	AL,0
	REP	STOSB		;RENSA GRAFIKMINNET VID ARB. OMRèDET

if create_flip_data
	call	init_the_flips
else
	call	load_the_flips

	MOV	BX,OFFSET FLIPLINFO
	mov	[bx].flipdata,flipleft
	mov	[bx+size flipstruc].flipdata,flipright
	mov	[bx+2*(size flipstruc)].flipdata,flipleft2

	cmp	hi_res,true
	je	nosk56
	SKALA56 [BX].FLIPAXUP
	SKALA56 [BX].FLIPAXDOWN
	SKALA56 [BX].FLIPMAXHASTUP
	SKALA56 [BX].FLIPMAXHASTDOWN
FAN=SIZE FLIPSTRUC
	SKALA56 [BX+FAN].FLIPAXUP
	SKALA56 [BX+FAN].FLIPAXDOWN
	SKALA56 [BX+FAN].FLIPMAXHASTUP
	SKALA56 [BX+FAN].FLIPMAXHASTDOWN
	SKALA56 [BX+FAN*2].FLIPAXUP
	SKALA56 [BX+(FAN)*2].FLIPAXDOWN
	SKALA56 [BX+(FAN)*2].FLIPMAXHASTUP
	SKALA56 [BX+(FAN)*2].FLIPMAXHASTDOWN	;df ...slutar hÑr
nosk56:	
	add	[bx+size flipstruc].fliptab,8
	add	[bx+size flipstruc].fliptoppek,8
	add	[bx+size flipstruc].flippek,8
	add	[bx+size flipstruc].flipmaxpek,8
	push	bx
	add	bx,size flipstruc
	add	[bx+size flipstruc].fliptab,8*2
	add	[bx+size flipstruc].fliptoppek,8*2
	add	[bx+size flipstruc].flippek,8*2
	add	[bx+size flipstruc].flipmaxpek,8*2
	pop	bx
	
MASKAR:	CMP	[BX].TYP,0
	JZ	INGA_FLER_MASKAR
	mov	[bx].lastframe,-1	;force blit
	mov	ax,[bx].flipsize
	mov	cx,3
	nil	dx
	div	cx
	mov	[bx].flipsize,ax
	PUSH	BX
	CALL	ORMASKFLIP
	CALL	MOVEFLIPMASK
	POP	BX
	ADD	BX,SIZE FLIPstruc
	JMP	MASKAR
INGA_FLER_MASKAR:
endif
	RETN
load_the_flips:
	mov	si,0
	mova	ds,flipgfxseg
	assume ds:flipgfxseg
	mova	es,0a000h
bipl=1
rept 4
	setwrite bipl
	mov	cx,flipgfxfilesize
	SHR	CX,2
	MOV	DI,GFXADR_FOR_FLIP_ANIM_DATA
	rep	movsb
	bipl=bipl*2
endm
	assume	ds:data
	mova	ds,data
	retn
if create_flip_data
init_the_flips:
	MOV	BX,OFFSET FLIPLINFO
INIT_FLEPS:
	CMP	[BX].TYP,0
	JZ	FLEPS_INITED
	MOV	FLIPPEKARE,BX
	PUSH	BX
	;ES=FLIPSEG; CX=FLIPX; DX=FLIPY ;FLIPPTR=ADR TO FLIPANIMTAB
	MOVA	[BX].FLIPGFXSTART,CS:DIFPTR
	MOVA	ES,[BX].FLIPDATA
	MOV	CX,[BX].LEFTX
	MOV	DX,[BX].TOPY
	MOVA	FLIPPTR,[BX].FLIPTAB
	MOV	AX,[BX].FLIPX
	SHL	AX,1
	MOV	FLIPLINESIZE,AX
	SHL	AX,3
	MOV	FLIPWIDTH,AX
	MOVA	FLIPHEIGHT,[BX].FLIPY
	MOVA	FLIPSTORLEK,[BX].FLIPSIZE
	MOVA	CS:MAXDIFFAR,[BX].FLIPDIFS
	CALL	INIT_FLIPPER
	
	POP	BX
	CALL	ORMASKFLIP
	CALL	MOVEFLIPMASK
	ADD	BX,SIZE FLIPSTRUC
	JMP	INIT_FLEPS
	
FLEPS_INITED:
	assume	ds:dataflip
L_len=offset rightfliptab-offset leftfliptab
R_len=offset leftflip2tab-offset rightfliptab
L2_len=offset temptab-offset leftflip2tab
L_pos=offset leftfliptab
R_pos=offset rightfliptab
L2_pos=offset leftflip2tab
	assume	ds:data
	createfile flipdatafil_L
	mova	ds,dataflip
	writefile bx,L_len,L_pos
	closefile bx
	mova	ds,data
	createfile flipdatafil_R
	mova	ds,dataflip
	writefile bx,R_len,R_pos
	closefile bx
	mova	ds,data
	createfile flipdatafil_L2
	mova	ds,dataflip
	writefile bx,L2_len,L2_pos
	closefile bx
	mova	ds,data

	CREATEFILE FLIPSTRUCFIL			;SKRIV FLIPSTRUCKEN
	MOV	SI,OFFSET FLIPLINFO
	MOV	CX,(SIZE FLIPSTRUC)*3+2
	WRITEFILE BX,CX,SI
	CLOSEFILE BX

	mov	bp,cs:difptr
	mov	si,GFXADR_FOR_FLIP_ANIM_DATA
	sub	bp,si
	createfile flipgfxfil
	mova	ds,0a000h
	mov	cx,4
skriv_gfx:
	mov	dx,3ceh
	mov	ah,4
	sub	ah,cl
	mov	al,4
	out	dx,ax	;vÑlj lÑs plan
	writefile bx,bp,si
	loop	skriv_gfx
	mova	ds,data
	closefile bx
	retn
endif
MAXDIFFAR DW ?
DIV0:	IRET
MOVEFLIPMASK:	;BX PEKAR TILL FLIPPER
	MOV	CX,[BX].FLIPFRAME
	cmp	cl,[bx].lastframe
	je	dont_doit
	mov	[bx].lastframe,cl
	MOV	SI,[BX].LEFTX
	MOV	DI,[BX].TOPY
	MOV	BP,[BX].FLIPX
	SHL	BP,1
	MOV	DX,[BX].FLIPY
	PUSH	DS
	MOV	AX,[BX].FLIPSIZE
	MOVE	DS,[BX].FLIPDATA
	MOVE	ES,MASK1_2
	PUSH	DX
	MUL	CX
	PUSH	AX
	MOV	AX,40
	MUL	DI
	SHR	SI,3
	ADD	SI,AX
	MOV	DI,SI

	POP	SI
if create_flip_data
	ADD	SI,BP
	ADD	SI,BP
endif
	POP	DX
	MOV	CX,DX
MOVFLIP:
	PUSH	CX
	MOV	CX,BP
	REP	MOVSB
	POP	CX
if create_flip_Data
	ADD	SI,BP
	ADD	SI,BP
endif
	ADD	DI,40
	SUB	DI,BP
	LOOP	MOVFLIP
	POP	DS
dont_doit:
	RETN
ORMASKFLIP:		
	MOVE	ES,[BX].FLIPDATA
	MOV	SI,[BX].LEFTX
	MOV	DI,[BX].TOPY
	MOV	CX,[BX].FLIPFRAMES
	INC	CX
	MOV	BP,[BX].FLIPX
	SHL	BP,1
	MOV	DX,[BX].FLIPY
	PUSH	DS
	MOVE	DS,MASK1_2
	MOV	AX,40
	PUSH	DX
	MUL	DI
	POP	DX
	SHR	SI,3
	ADD	SI,AX
	MOV	DI,SI

	MOV	SI,BP
	SHL	SI,1
	XCHG	SI,DI
if create_flip_data
else
	mov	di,0
endif
	
ORFLIPS:
	PUSH	SI
	PUSH	CX
	MOV	CX,DX
ORFLIP:	
	PUSH	SI
	PUSH	CX
	MOV	CX,BP
ORRA:	LODSB
	OR	ES:[DI],AL
	INC	DI
	LOOP	ORRA
	POP	CX
	POP	SI

	ADD	SI,40
if create_flip_data
	ADD	DI,BP
	ADD	DI,BP
endif
	LOOP	ORFLIP
	POP	CX
	POP	SI
	LOOP	ORFLIPS
	POP	DS
        RETN
ENDP
IF CREATE_FLIP_DATA
INIT_FLIPPER PROC NEAR		;ES=FLIPSEG; CX=FLIPX; DX=FLIPY ;FLIPPTR=ADR TO FLIPANIMTAB
	MOV	FLIPSEG,ES
	MOV	FLIPXPOS,CX
	MOV	FLIPYPOS,DX
	MOV	AX,FLIPYPOS
	ADD	AX,SPLH
	MOV	BX,BPL
	MUL	BX
	MOV	BX,FLIPXPOS
	SHR	BX,2
	ADD	AX,BX
	MOV	FLIPADR,AX
	MOV	SI,AX	;(FLIPY+SPLH)*BPL+FLIPX/4
	MOV	DI,(800-60*2)*BPL+40
	PUSH	DI
	CALL	COPYFLIPBGR
	POP	DI
	MOV	BP,0
	MOV	AX,FLIPXPOS
	AND	AX,11B
	CALL	PUTFLIPPER
	OR	SHIFTKEYS,11B
	MOV	BX,FLIPPEKARE
	MOV	[BX].FLIPFRAME,0
	MOV	[BX].FLIPVINKELHAST,0
RITAFLIPPRAR:
	CALL	NESTAFRAME
	;BP=FLIPNO
	MOV	SI,FLIPADR	;(FLIPY+SPLH)*BPL+FLIPX/4
	MOV	DI,(800-60*2)*BPL
	ADD	DI,BUFR
	PUSH	DI
	CALL	COPYFLIPBGR
	POP	DI	
	PUSH	DI
	MOV	AX,FLIPXPOS
	AND	AX,11B
	CALL	PUTFLIPPER
	POP	DI
	PUSH	BP
	MOV	BP,40 ;60*BPL
	CMP	BUFR,0
	JZ	CORC
	NEG	BP
CORC:
	MOV	SI,FLIPPTR
	MOV	BX,FLIPPEKARE
	ADDA	FLIPPTR,[BX].FLIPDIFS
	MOVA	[BX].FLIPMAXPEK,FLIPPTR
	TEST	SHIFTKEYS,11B
	JZ	NOSI
	MOVA	[BX].FLIPTOPPEK,FLIPPTR
NOSI:	
	CALL	CMPFLIPBOX
	POP	BP
	XOR	BUFR,40 ;60*BPL
	MOV	AH,0
;	INT	keyhandler
	OR	BP,BP
	JNZ	RITAFLIPPRAR

	mov	bx,flippekare	
	CALL	SORTFLIPPERDATA
	
	MOV	BP,0
	MOV	DI,FLIPADR	;(FLIPY+SPLH)*BPL+FLIPX/4
	MOV	AX,FLIPXPOS
	AND	AX,11B
	CALL	PUTFLIPPER
	RETN
NESTAFRAME:	
	MOV	BX,FLIPPEKARE
	INC	[BX].FLIPFRAME
	TEST	SHIFTKEYS,11B
	JNZ	NODEC
	SUB	[BX].FLIPFRAME,2
NODEC:
	MOV	BP,[BX].FLIPFRAME
	CMP	BP,[BX].FLIPFRAMES
	JNE	DORET
	AND	SHIFTKEYS,11111100B
DORET:	RETN
ENDP
SORTFLIPPERDATA PROC NEAR
	MOV	SI,[BX].FLIPTAB
	MOV	CX,[BX].FLIPFRAMES
	INC	CX
	call	sortflip
	MOV	CX,[BX].FLIPFRAMES
;	inc	Cx
	MOV	SI,[BX].FLIPtoppek
	add	si,[BX].FLIPDIFS
	call	sortflip
	retn
sortflip:
	MOVA	DS,DATAFLIP
	MOVA	ES,DS
	ASSUME	DS:DATAFLIP	;*****************************************
SORTDATA:
	PUSH	CX SI bx
	
	ADD	SI,9*2
	MOV	DI,OFFSET TEMPTAB
	dec	cx
	jz	deunika
	cmp	cx,8
	jbe	sortera
	mov	cx,8
sortera:push	cx si
	mov	bp,cx

	mov	cx,[SI-9*2]	;ANTAL DELTA BYTES
	mov	bx,0
sorti:	push	cx si
	MOV	AX,DS:[SI+bx]
	cmp	ax,-1
	je	didfind
	
	mov	cx,bp
findit:	ADD	SI,CS:MAXDIFFAR
	CALL	FINDWORD
	JnC	DIDFIND
	loop	findit
	stosw
	pop	si
	mov	word ptr ds:[si+bx],-1	;markera att denna redan Ñr lagrad
	mov	ax,[si+bx+2]
	stosw

	jmp	short orvar
	
DIDFIND:
	pop	si
orvar:	pop	cx
	add	bx,4
	loop	sorti

	mov	ax,di
	sub	ax,offset temptab
	shr	ax,2
	shl	bp,1
	mov	ds:[si+bp-9*2],ax ;lagra antal delta som hittats hitils
	shr	bp,1

	pop	si cx
	loop	sortera
deunika:
	push	si		;flytta in de som var helt unika sist
	mov	cx,[si-9*2]
desista:lodsw		
	cmp	ax,-1
	je	nostor
	stosw
	movsw
	sub	si,2
nostor:	add	si,2
	loop	desista
	pop	si
	
	mov	cx,[si-9*2]
	mov	di,si
	mov	si,offset temptab
	shl	cx,1
	rep movsw		;lÑgg in den sorterade listan i orginalet
	
	POP	bx SI CX
	ADD	SI,CS:MAXDIFFAR
	LOOP	SORTDATA
	MOVA	DS,DATA
	RETN
FINDWORD:
	pusha
	mov	cx,CS:MAXDIFFAR ;Maxdifs-5
	SHR	CX,2
	SUB	CX,5
leta:	cmp	ds:[si],ax
	je	foudit
	add	si,4
	loop	leta
	popa	
	stc
	RETN
foudit:	popa
	clc
	retn
	ASSUME DS:DATA ;**********************************
ENDP
ENDIF
INIT_KEY PROC NEAR
	SET_ES	0
	CLI
	MOV	AX,OFFSET KEYINT
	XCHG	AX,ES:[9*4]
	MOV	CS:OLD9,AX
	MOV	AX,CS
	XCHG	AX,ES:[9*4+2]
	MOV	CS:OLD9+2,AX
	MOV	AX,OFFSET div0
	XCHG	AX,ES:[0*4]
	MOV	CS:OLD0,AX
	MOV	AX,CS
	XCHG	AX,ES:[0*4+2]
	MOV	CS:OLD0+2,AX
	STI
	RETN
OLD9	DW 0,0
old0	dw 0,0
ENDP
UNINST_KEY PROC NEAR
	SET_ES	0
	CLI
	MOVE	ES:[9*4],CS:OLD9
	MOVE	ES:[9*4+2],CS:OLD9+2
	MOVE	ES:[0*4],CS:OLD0
	MOVE	ES:[0*4+2],CS:OLD0+2
	STI
	RETN
ENDP

KEYINT	PROC NEAR
	PUSHA
        PUSH DS
	MOV AL,20H
	OUT 20H,AL
        MOVA DS,DATA
        IN AL,60H
        PUSH AX
        IN AL,61H
        OR AL,80H
        OUT 61H,AL
        AND AL,7FH
        OUT 61H,AL
        POP AX
	STI

;DPRINTVAL AX," AX="
;DPRINT " "

	test	al,80h
	jnz	no_alfa_key
	mov	scan_code,al
	MOV	CS:SETTER,TA_TID
IF SAVEPAL
CMP	AL,3
JNE	NO_UBBE_KUKEN
MOVE	ES:[9*4],CS:OLD9
MOVE	ES:[9*4+2],CS:OLD9+2
NO_UBBE_KUKEN:
ENDIF
no_alfa_key:
	
	CMP	CS:E0,TRUE
	JE	DOE0
	CMP	AL,0E0H
	JNE	NOTE0
	MOV	CS:E0,TRUE
	JMP	KEYDONE
NOTE0:
	CMP	AL,57H		;F11
	JNE	NOTF11
	MOV	FFLAG,11
	JMP	KEYDONE
NOTF11:
	CMP	AL,58H		;F12
	JNE	NOTF12
	MOV	FFLAG,12
	JMP	KEYDONE
NOTF12:
	CMP	AL,2AH
	JE	DSSK
	CMP	AL,38H
	JE	DSSK
	CMP	AL,1DH
	JE	DSSK
	JMP	SHORT NOTLSDN
DSSK:	TEST	SHIFTKEYS,10B
	JNZ	NOTLSDN
	OR	SHIFTKEYS,10B
	MOV	SHIFTPRESSED,TRUE	;LEFT SHIFT KEY PRESSED
	cmp	allowflip,false
	je	keydone
	soundeffect sflippupp,0
	JMP	KEYDONE
NOTLSDN:
	CMP	AL,36H
	JE	DSSKR
	JMP	SHORT NOTRSDN
DSSKR:	TEST	shiftkeys,1
	jnz	notrsdn
	OR	SHIFTKEYS,1
	MOV	SHIFTPRESSED,TRUE	;RIGHT SHIFT KEY PRESSED
	cmp	allowflip,false
	je	keydone
	soundeffect sflippupp,0
	JMP	KEYDONE		
NOTRSDN:
	CMP	AL,36H+80H
	JE	DSSKR2
	JMP	SHORT NOTRSUP
DSSKR2:	AND	SHIFTKEYS,0FEH
	JMP	KEYDONE		
NOTRSUP:

	CMP	AL,2AH+80H
	JE	DSSK2
	CMP	AL,38H+80H
	JE	DSSK2
	CMP	AL,1DH+80H
	JE	DSSK2
	JMP	SHORT NOTLSup
DSSK2:	AND	SHIFTKEYS,11111101B
	JMP	KEYDONE
NOTLSUP:

	CMP	AL,57
	JNE	NOTSPC
	CMP	TILTKEY,TRUE
	JE	KEYDONE
	MOV	TILTKEY,TRUE
	JMP	KEYDONE
NOTSPC:
	CMP	AL,57+80H
	JNE	NOTSPCU
	MOV	TILTKEY,FALSE
	MOV	cs:TILTKEY2,FALSE
	
	JMP	KEYDONE
NOTSPCU:
COMMENT\
	CMP	AL,44
	JNE	NOTZ
	MOV	CURRENT_PRIORITY,101
	JMP	KEYDONE
NOTZ:
\
if arrowS
	CMP	AL,2
	JNE	NOT2
	CLI
	MOV	INTERRUPTS_ON,FALSE
	SET_ES	0A000H
	MOV	AX,0DH
	INT	10H
	MOV	SI,0
	SET_DS	MASK2_2
	MOV	CX,200*40
	MOV	DI,0
	REP	MOVSB
	cli
	mov	dx,3d4h
	mov	ax,0ch
	out	dx,ax
	inc	al
	out	dx,ax
	JMP	$
NOT2:
	CMP	AL,72
	JNE	NOTPUP
	MOV	Y_HAST,-1*PILHAST
	MOV	X_HAST,0
	JMP	KEYDONE
NOTPUP:
	CMP	AL,75
	JNE	NOTPL
	MOV	X_HAST,-1*PILHAST
	MOV	Y_HAST,0
	JMP	KEYDONE
NOTPL:
	CMP	AL,77
	JNE	NOTPR
	MOV	X_HAST,1*PILHAST
	MOV	Y_HAST,0
	JMP	KEYDONE
NOTPR:
	CMP	AL,80
	JNE	NOTPDN
	MOV	Y_HAST,1*PILHAST
	MOV	X_HAST,0
	JMP	KEYDONE
NOTPDN:
endif
KEYDONE:
	POP	DS
	POPA
        IRET

E0	DB FALSE

DOE0:	MOV	CS:E0,FALSE
	CMP	DEMOMODE,TRUE
	JE	DOE0_DEMO
	
	CMP	AL,49H
	JNE	NOT_PGUP
;	AND	SHIFTKEYS,11111011B
	JMP	KEYDONE
NOT_PGUP:
	CMP	AL,51H
	JNE	NOT_PGDN
;	OR	SHIFTKEYS,00000100B
	JMP	KEYDONE
NOT_PGDN:

	CMP	AL,50H	;(ARROW DOWN)
	JNE	NOTARD
	MOV	SPRINGTASK,OFFSET SPRINGSTEEN
	MOV	DNPRESSED,TRUE
	JMP	KEYDONE
NOTARD:
	CMP	AL,80h+50H	;(ARROW DOWN up)
	JNE	NOTARdu
	MOV	SPRINGTASK,OFFSET SPRINGUP
	MOV	DNPRESSED,FALSE
	JMP	KEYDONE
NOTARdu:

	CMP	AL,38H	;right alt
	JE	DSSKR
	CMP	AL,1DH	;right ctrl
	JE	DSSKR
	CMP	AL,38H+80h	;right alt up
	JE	DSSKR2
	CMP	AL,1DH+80h	;right ctrl up
	JE	DSSKR2
	JMP	KEYDONE

NOTE0_DEMO:
	JMP	KEYDONE


DOE0_DEMO:
	CMP	AL,49H
	JNE	NOT_PGUP2
	AND	SHIFTKEYS,11111011B
	JMP	KEYDONE
NOT_PGUP2:
	CMP	AL,51H
	JNE	NOT_PGDN2
	OR	SHIFTKEYS,00000100B
	JMP	KEYDONE
NOT_PGDN2:
	JMP	KEYDONE

KEYINT	ENDP



MINIX		DW ?
THESCRPOS	DW ?
if create_flip_data
PUTFLIPPER PROC NEAR	;INPUT: BP=FLIP NO, DI=SCRPOS, AX=MINIX
	MOV	CS:THESCRPOS,DI
	MOV	CS:MINIX,AX
	SET_ES	FLIPSEG
	MOV	CX,FLIPHEIGHT	;CX=LINE COUNTER
	MOV	BX,0		;BX=Y COORD

SCANFLIPY:
	PUSH	CX
	MOV	CX,FLIPWIDTH	;CX=ROW COUNTER
	MOV	AX,0		;AX=X COORD

SCANFLIPX:
	PUSH	AX BX CX
	MOV	CX,BP
	CALL	READFLIPPIX
	MOV	BX,OFFSET BIT2COL
	XLATB
	OR	AL,AL
	JZ	NOPUT
	MOV	DL,AL
	POP	CX BX AX
	PUSH	AX BX CX

	MOV	DI,CS:THESCRPOS
	ADD	AX,CS:MINIX

	CALL	PUTFLIPPIX
NOPUT:	POP	CX BX AX
	INC	AX
	LOOP	SCANFLIPX

	INC	BX
	POP	CX
	LOOP	SCANFLIPY
	RETN
PUTFLIPPER ENDP
endif
SETSCREENSTART PROC NEAR
	MOV	BX,SC_Y
	PUSH	BP
	MOV	BP,(SH_LO-SPLH)/2-BALLH/2-AWAYFROMMIDDLE
	CMP	HI_RES,TRUE
	JNE	NOTHIRES3
	MOV	BP,(SH_HI-SPLH)/2-BALLH/2-AWAYFROMMIDDLE
NOTHIRES3:
	SUB	BX,BP
	POP	BP
	JNL	BXOK1
IF GLAPP_SIZE
	MOV	BX,-GLAPP_SIZE
ELSE	
	MOV	BX,0
ENDIF
	JMP	SHORT BXOK2
BXOK1:	PUSH	AX
	MOV	AX,BANH-(SH_LO-SPLH)
	CMP	HI_RES,TRUE
	JNE	NOTHIRES4
	MOV	AX,BANH-(SH_HI-SPLH)
NOTHIRES4:
	CMP	BX,AX
	POP	AX
	JB	BXOK2

	MOV	BX,BANH-(SH_LO-SPLH)+GLAPP_SIZE
	CMP	HI_RES,TRUE
	JNE	NOTHIRES5
	MOV	BX,BANH-(SH_HI-SPLH)+GLAPP_SIZE
NOTHIRES5:

BXOK2:	CMP	SCREENFORCE,-1
	JE	NOSCREENFORCE
	
	MOV	BX,SCREENFORCE		;THIS IS THE POWERFUL SCREEN FORCE
	ADD	BX,SPLH
	PUSH	BX
IF RES600
	MOV	BX,2
	ADD	BX,SCREENPOSY
ENDIF
	SETRASTERPOS bx
	POP	BX
	PUSH	BX
	SHL	BX,4
	MOV	RASTERPOS,BX
	POP	BX
	SUB	BX,SPLH
	MOV	START_RASTER,BX
	RETN

NOSCREENFORCE:
	cmp	screenforce2,-1
	je	nosf
	mov	bx,screenforce2
nosf:
	ADD	BX,SPLH
	PUSH	BX	
	mov	ax,bx
	mov	bx,rasterpos
	sar	bx,4
	sub	ax,bx

IF GLAPP_SIZE
	PUSHF		;df
	POP CX		
	CMP	SCREENFORCE2,-1	;INGET GLAPP OM SCREENFORCE!!!!!!!!!!!
	JNE	GLAPP_DONE
	PUSH CX
	POPF
	JS	MINSU
	SUB	AX,GLAPP_SIZE
	JNS	GLAPP_DONE
	XOR	AX,AX
	JMP	SHORT GLAPP_DONE
MINSU:	ADD	AX,GLAPP_SIZE
	JS	GLAPP_DONE
	XOR	AX,AX
ENDIF
GLAPP_DONE:
	MOV	BX,SLIME_FACTOR
	IMUL	BX
	MOV	BX,AX
	SAR	AX,2
	
	add	rasterpos,ax
	POP	BX
	MOV	AX,RASTERPOS
	SAR	AX,4
	SUB	BX,AX
	JNS	GAP_POS
	
	PUSH	BP
	MOV	BP,MAXGAPU_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES10
	MOV	BP,MAXGAPU_HI
NOTHIRES10:
	ADD	BX,BP
	POP	BP
	JG	BX_OKI
	SAL	BX,4
	ADD	RASTERPOS,BX
	JMP	SHORT BX_OKI
GAP_POS:

	PUSH	BP
	MOV	BP,MAXGAPD_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES11
	MOV	BP,MAXGAPD_HI
NOTHIRES11:
	SUB	BX,BP
	POP	BP
	JL	BX_OKI
	SAL	BX,4
	ADD	RASTERPOS,BX
BX_OKI:

	mov	bx,rasterpos
	sar	bx,4
	ADD	BX,SCREENPOSY
	push	bx
IF RES600
	MOV	BX,SCREENPOSY
	ADD	BX,2
ENDIF
;	MOV	BX,SPLH+BANH
	SETRASTERPOS bx
	pop	bx
	sub	bx,splh
	MOV	START_RASTER,BX
	RETN
SETSCREENSTART ENDP



PUTTHEBALL PROC NEAR	;FN: DELETES AND PUTS THE BALL.
			;INPUT: VERYFIRSTPUT, PUTITBETWEEN, PUTF3BETWEEN
			;       IF XXBETWEEN=TRUE THE FLIPPER(S) ARE DELTA
			;       MOVED BETWEEN THE DELETING AND THE PUTTING
			;       OF THE BALL.
IF MARGIT
	SETMARG	1
ENDIF
	PUSHA
	SET_ES	0A000H
	CMP	VERYFIRSTPUT,TRUE
	JE	DNDB
	MOV	DI,OLDPOS		;OLDPOS
	MOV	CX,OLDSHIFT		;OLDSHIFT
	MOV	SI,OFFSET UNDANSPR	;SAVEDDATA OFFSET
	SET_DS	HIDDEN1			;SAVEDDATA SEGMENT
	CALL	DELBALL
	SET_DS	DATA
DNDB:

	CMP	PUTITBETWEEN,TRUE
	JNE	DNDLF
	CALL	DOFLIPPER
DNDLF:	
	CMP	PUTF3BETWEEN,TRUE
	JNE	DNDLF2
	CALL	DOFLIPPER3
DNDLF2:	

IF MARGIT
	SETMARG	1
ENDIF
	MOV	VERYFIRSTPUT,FALSE
	MOV	DX,SC_X		;X POS
	MOV	SI,SC_Y		;Y POS
	CMP	HOLDSTILL,TRUE
	JE	NOTILTADD
	ADD	SI,SCREENPOSY
NOTILTADD:
	ADD	SI,SPLH
	MOV	DI,OFFSET UNDANSPR	;SAVEDDATA OFFSET
	MOV	BP,OFFSET HID1-SPLH*SW/8-576*2
	SET_ES	HIDDEN1			;SAVEDDATA SEGMENT
	CMP	BALLHIGH,FALSE
	JE	BLHA
	ADD	BP,42*576
BLHA:
	CALL	PUTBALL
	SET_DS	DATA
	MOV	OLDPOS,SI		;OLDPOS
	MOV	OLDSHIFT,DX		;OLDSHIFT

	POPA
IF MARGIT
	SETMARG	0
ENDIF
	RETN
PUTTHEBALL ENDP


VBLANK_INT:
	MOVE	DS,DATA
	INC	SYNC_COUNTER
	MOV	INT_WAS_HERE,TRUE
	MOV	INT_WAS_HERE2,TRUE
	CMP	INTERRUPTS_ON,TRUE
	JE	VBLANKOK
RETAF:	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF				;RET
VBLANKOK:
	OR	AX,AX
	MOV	TIME_LEFT,TRUE
	JZ	NO_MUSIC_CRISIS
	MOV	TIME_LEFT,FALSE
NO_MUSIC_CRISIS:

	cmp	calamares_delay,0	;tryck inte pÜ pause fîr tÑtt inpÜ!!
	je	docaldecc
	dec	calamares_delay
docaldecc:
	ADD	SLUMP_COUNTERN,1030

	CMP	DEMOMODE,TRUE
	JE	VBLANK_INT_DEMO

;********************* SPELETS RUTINER ***********************

	INC	SLOWCNT
	AND	SLOWCNT,SLOW
	JNZ	RETAF

	CMP	CS:LAST_WAS_VB,TRUE
	JE	RETAF

	MOV	AL,INSIDE_BALLHANDLER
	MOV	INSIDE_BALLHANDLER,TRUE
	CMP	AL,TRUE
	JE	RETAF
	CMP	AL,TRUE
	JE	RETAF
	
	SAVEGFXREGS
	MOV	PUTF3BETWEEN,FALSE
	MOV	FORCELATEF3,FALSE

	CMP	SC_Y,F3TOP-BALLH+2	;NO I: SC_Y + BALLH < F3TOP
	JB	NO_INTEFERRENCE
	CMP	SC_Y,F3TOP+F3HEIGHT-2	;NO I: SC_Y > F3TOP + F3HEIGHT
	JA	NO_INTEFERRENCE
	MOV	PUTF3BETWEEN,TRUE
	JMP	KEEP_COOL

NO_INTEFERRENCE:
	MOV	AX,F3TOP+F3HEIGHT/2-SH_LO/2
	CMP	HI_RES,TRUE
	JNE	NOTHIRES6
	MOV	AX,F3TOP+F3HEIGHT/2-SH_HI/2
NOTHIRES6:
	CMP	START_RASTER,AX
	JB	F3_IS_LOW
	MOV	FORCELATEF3,TRUE
	JMP	HIGH_F3_DONE
F3_IS_LOW:
	CALL	DOFLIPPER3
HIGH_F3_DONE:
KEEP_COOL:
	
	MOV	AX,START_RASTER
	PUSH	BP
	MOV	BP,MIDDLE_RASTER_LO
	CMP	HI_RES,TRUE
	JNE	NOTHIRES8
	MOV	BP,MIDDLE_RASTER_HI
NOTHIRES8:
	ADD	AX,BP
	POP	BP
	CMP	SC_Y,AX
	JB	BALL_HIGH

BALL_LOW:
	CMP	STATUS,UPPER
	JE	BALL_LOW_STATUS_HIGH

BALL_LOW_STATUS_LOW:
	MOV	PUTITBETWEEN,TRUE	;PUT IT BETWEEN
	CALL	PUTTHEBALL		;PUT THIS SYNC
	CALL	KOLLAKULAN		;CALC NEXT SYNC
	MOV	LATEGFX,FALSE
	JMP	BALLREADY

BALL_LOW_STATUS_HIGH:
	MOV	STATUS,LOWER
	CALL	DOFLIPPER		;DO FLIPPER
	CALL	KOLLAKULAN		;CALC NEXT SYNC
	MOV	LATEGFX,FALSE
	JMP	BALLREADY

BALL_HIGH:
	CMP	STATUS,UPPER
	JE	BALL_HIGH_STATUS_HIGH

BALL_HIGH_STATUS_LOW:
	MOV	STATUS,UPPER
	MOV	LATEGFX,TRUE		;PUT NEXT SYNC LAST
	MOV	PUTITBETWEEN,TRUE	;PUT IT BETWEEN
	CALL	PUTTHEBALL		;PUT THIS SYNC
	CALL	KOLLAKULAN		;CALC NEXT SYNC
	JMP	BALLREADY

BALL_HIGH_STATUS_HIGH:
	CALL	DOFLIPPER		;DO FLIPPER
	CALL	KOLLAKULAN		;CALC NEXT SYNC
	MOV	LATEGFX,TRUE		;PUT NEXT SYNC LAST

	MOV	AX,START_RASTER
	PUSH	BP
	MOV	BP,MIDDLE_RASTER_LO+5	;5=CPMARGINAL
	CMP	HI_RES,TRUE
	JNE	NOTHIRES9
	MOV	BP,MIDDLE_RASTER_HI+5	;5=CPMARGINAL
NOTHIRES9:
	ADD	AX,BP
	POP	BP
	CMP	AX,F3TOP
	JB	F3ISLOW
	JMP	BALLREADY

F3ISLOW:
	CALL	DOFLIPPER3

BALLREADY:
	CALL	DO_PHYSICS			;LEVELS,RAMPER,MM
	MOV	INSIDE_BALLHANDLER,FALSE
	CMP	INSIDE_RESTOFVBLANK,FALSE
	JE	DO_THE_REST
	RESTOREGFXREGS
	MOV	CS:LAST_WAS_VB,TRUE
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF

DO_THE_REST:
	MOV	CS:LAST_WAS_VB,TRUE
	MOV	INSIDE_RESTOFVBLANK,TRUE
	CALL	UPDATE_COUNTERS

	CALL	DO_ELECTRONICS
	CALL	SPRINGTASK	
IF MARGIT
SETMARG 14
ENDIF
	
	cmp	time_left,false
	je	skip_matrix		;no time left! Skip it!!	
;	mov	time_left,false		;ok, time was left last time!
	MOV	AL,CS:INSIDE_MATRIX
	MOV	CS:INSIDE_MATRIX,TRUE
	CMP	AL,TRUE
	JE	SKIP_MATRIX
	CALL	DO_THE_DOTMATRIX	;updatera dÜ matrixen!
	MOV	CS:INSIDE_MATRIX,FALSE
skip_matrix:
	CALL	DOLIGHTS

IF MARGIT
RESTOREMARG
ENDIF
IF MARGIT
SETMARG 0
ENDIF
	MOV	INSIDE_RESTOFVBLANK,FALSE
	RESTOREGFXREGS
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF

INSIDE_MATRIX	DB FALSE
LAST_WAS_VB	DB FALSE

;******************************************************************************


DO_THE_DOTMATRIX PROC NEAR		;JOHANS TUNGA RUTINER!
	CALL	DO_THE_ANIMATIONS
	MOV	AX,AX_PRINT
	MOV	DI,DI_PRINT
	CALL	PRINTTASK
	MOV	PRINTTASK,OFFSET DUMRET
	RETN
DO_THE_DOTMATRIX ENDP


DO_THE_ANIMATIONS PROC NEAR
	cmp	intflag,true	;gabriel vill ABSOLUT penetrera!!
	je	aterstallaren
laddanasta:
	MOV	DX,DOTRUT
	MOV	SI,SISA
	CALL	DX
	MOVE	DS,DATA
	MOV	SISA,SI
	CMP	SI,0
	JNE	NOTFREEYET	;JOBBAR Pè EN EFFEKT!
	MOV	DOTRUT,OFFSET CS:NODOT
	MOV	BX,NEXT_A
	CMP	BX,0
	JE	ts_slut	;NOMOREANIMS
	CALL	DO_SPEC_MATRIX	;ANIMATION SLUT, LADDA NéSTA?
	jmp	nomoreanims
ts_slut:
;	mov	behovs_provad,true
	CALL	KILL_FLASHOR		;cp!!??
	;dîda flashor

NOMOREANIMS:
	MOV	DOT_READY,TRUE
	JMP	HOPPA_FORBI
aterstallaren:	;(dan efter??)
	mov	intflag,false
	jmp	laddanasta
NOTFREEYET:
HOPPA_FORBI:
	RETN
DO_THE_ANIMATIONS ENDP



DO_MATRIX:
	call	kill_flashor
	MOV	DOT_READY,FALSE
	MOV	NODOTCOUNT,0
	MOV	BEHOVS_PROVAD,TRUE
DO_SPEC_MATRIX:
	UPDAT_SCORE
	JMP	[BX]

_ANIMATION:
	STARTANIM [BX+2]
	JMP	NORMAL_END
_SCROLL:
	STARTSCROLL [BX+2]
	JMP	NORMAL_END
_NUMBER:
	MOVE	SISA,[BX+2]
	MOV	DOTRUT,OFFSET SIFFRORRUT
	JMP	NORMAL_END		

_FLASHON:		;BX NOT USED!
	MOV	AX,[BX+2]	;AX=FLASHSPEED
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT
	MOV	MATRIX_SPEED,AX
	MOV	MATRIX_CNT,AX
	MOV	MATRIX_ONOFF,TRUE
	MOV	MATRIX_IS_FLASHING,TRUE
	JMP	NORMAL_END

print8_task:

	call	reset_numberbuf
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,8
	mov	hojd_add,bredd_1/4-sw*8*2/4
	mov	font_adr,offset font8
	call	print_number
	retn
print11_task:
	call	reset_numberbuf
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,11
	mov	hojd_add,bredd_1/4-sw*11*2/4
	mov	font_adr,offset font11
	call	print_number
	retn
print13_task:
	call	reset_numberbuf
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,13
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	call	print_number
	retn

print5_task:
	call	reset_numberbuf
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,5
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	call	print_number
	retn

_print11_number:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT11_task
	jmp	print_end
_print13_number:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT13_task
	jmp	print_end
_print8_number:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT8_task
	jmp	print_end

_print8_number_CENT:
	MOV	CENT,TRUE
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT8_task
	jmp	print_end

_print13_number_CENT:
	MOV	CENT,TRUE
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT13_task
	jmp	print_end

_print5_number:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	tabort_diovre_fnt,0
	PUSH	[BX+2]
	POP	si_siffror
	MOVE	DI_siffror,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT5_task
	jmp	print_end

_SOUND_EFFECT:
	move	sisa,1
	mov	dotrut,offset waitrut
	
	MOV	AX,[BX+2]
	MOV	CX,[BX+4]
	PUSH	BX
	SOUNDEFFECT2 AX,CL
	POP	BX

	JMP	PRINT_END
_lastjingle:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	ax,[bx+2]
	mov	lastjingle,al
	mov	si,77	;urko!
	jmp	normal_end	
_JINGLE:
	move	sisa,1
	mov	dotrut,offset waitrut
	
	MOV	SI,[BX+2]
	mov	current_priority,0
	mov	jinglejumpcnt,1
;	MOV	AL,BYTE PTR [SI]
;	MOV	LASTJINGLE,AL
;	MOV	LASTLOOPVAL,1
	PUSH	BX
	call	DoplaYJINGLE	;JOHAN SOM HAR SKRIVIT?
	POP	BX
	JMP	NORMAL_END
_COUNTDOWNCONTINUE:			;INPUT: ?,?, VALUE TO PRINT
	MOV	SUPER_INIT,FALSE
	MOV	SISA,1
	MOV	DOTRUT,OFFSET COUNTDOWN
	CALL	RESET_NUMBERBUF
	MOVE	VAL_TO_PRINT,[BX+6]
	MOV	SYNC_LEFT,1
	MOV	INHIBIT_COUNT_DOWN,FALSE
	JMP	THREE_END

_countdown:
MEGA_RESET:
	MOV	SUPER_INIT,FALSE
;input: seconds, value to print
	mov	sisa,1
	mov	dotrut,offset countdown
	call	reset_numberbuf
	move	val_to_print,[bx+6]
	mov	sync_left,1
	
	mov	[sec_asc],'A'-10+0
	mov	[sec_asc+1],'A'-10+1
	mov	al,[bx+2]
	add	[sec_asc],al
	mov	al,[bx+4]
	add	[sec_asc+1],al
	jmp	three_end

_countdown2:
;input: ?, ? (update panel!)
	CMP	SUPER_INIT,TRUE
	JE	MEGA_RESET
	mov	sisa,1
	mov	dotrut,offset countdown
	call	reset_numberbuf
	mov	sync_left,1
	jmp	three_end
	
countdown:
	CMP	INHIBIT_COUNT_DOWN,TRUE
	JE	INH_CD
	dec	sync_left
	jnz	no_rez_this_sync
	mova	sync_left,sync_per_sec

	cmp	[sec_asc+1],'A'-10
	jne	over_it_again
	cmp	[sec_asc],'*'
	je	uninstall_count
over_it_again:

	
	dec	[sec_asc+1]
	cmp	[sec_asc+1],'A'-10-1
	jnz	ingen_fara
	add	[sec_asc+1],10
	dec	[sec_asc]
	
ingen_fara:
	CMP	[SEC_ASC],'A'-10
	JNE	NOT_ZERO
	MOV	[SEC_ASC],'*'
NOT_ZERO:

;[SEC_ASC] PEKAR Pè MSD, (0='*')	[SEC_ASC+1] PEKAR Pè LSD
;LéS AV BARA!
	PUSHA	;CP!
	CALL	READ_SPECIAL_MODE_COUNTER
	POPA

	mov	hojd_1,11
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*11*2/4
	mov	font_adr,offset font11
	push	offset sec_asc
	pop	AX_PRINT
	MOVE	DI_PRINT,SW*6/4+16*18/4			;cpw!
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	mov	si,1
	retn
no_rez_this_sync:
INH_CD:
	mov	tabort_diovre_fnt,0
	move	si_siffror,val_to_print
	move	di_siffror,SW*4/4+16*2/4	;cpw!
	mov	printtask,offset print13_TASK
	mov	si,1
	retn
uninstall_count:
	
;	mov	specialmode,false
	mov	sisa,0	
	mov	si,0
	retn
_rullgardin_upp:
	mov	dotrut,offset rullgardin_upp
	move	rulltext,[bx+2]
	move	stop_at_pos,[bx+4]
	mov	rull_pos,16
	jmp	print_end

_rullgardin_ned:
	mov	dotrut,offset rullgardin_ned
	move	rulltext,[bx+2]
	move	stop_at_pos,[bx+4]
	mov	rull_pos,-13
	jmp	print_end

rullgardin_upp:
;rull_pos startvÑrde mÜste vara satt till 16!!!
	dec	rull_pos

	cmp	rull_pos,16-14
	jg	noradering_upp
	mov	ax,rull_pos
	add	ax,13
	mov	bx,sw*2/4
	mul	bx
	mov	clear_box_start,ax
	add	clear_box_start,2*sw/4
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2
	
noradering_upp:

	mov	hojd_1,13
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13

	call	putfont
	mov	ax,stop_at_pos
	cmp	rull_pos,ax
	je	rezzeta
	mov	si,1
	retn

rullgardin_ned:
;rull_pos startvÑrde mÜste vara satt till -13!!!
	inc	rull_pos

	cmp	rull_pos,1
	jl	noradering_ned
	mov	ax,rull_pos
	sub	ax,1
	mov	bx,sw*2/4
	mul	bx
	mov	clear_box_start,ax
	add	clear_box_start,2*sw/4
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
       	call	clear_box2
	
noradering_ned:
	mov	hojd_1,13
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13

	call	putfont
	mov	ax,stop_at_pos
	cmp	rull_pos,ax
	je	rezzeta
	mov	si,1
	retn
rezzeta:
	mov	si,0
	mov	tabort_diovre,0
	mov	tabort_diovre_fnt,0
	retn

putfont:
	mov	ax,rull_pos
	cmp	ax,0
	jge	kapa_ej_overkant

;Kapa i îverkant!

	neg	ax			;gîr ax positiv!
	mov	tabort_diovre,ax
	mov	tabort_diovre_fnt,ax	;sÜ mycket som skall kapas!
	mov	di,sw*2/4		;îversta rastern
	jmp	print_it
	
kapa_ej_overkant:
	
	cmp	ax,16-13	;matrixhojd-fonthojd
	jle	kapa_ej_nederkant
;	neg	ax		;-pos
;	add	ax,16		;=> ax=16-pos
	add	ax,13-16	
	mov	tabort_diovre,ax		;sÜ mycket som ska kapas!
	mov	tabort_diovre_fnt,0		;men inget i îvekant
	mov	ax,rull_pos
	inc	ax
	mov	bx,sw/4*2		;di=rull_pos*sw*2/4
	mul	bx
	mov	di,ax
	jmp	print_it
	
kapa_ej_nederkant:
	mov	tabort_diovre,0			;sÑtt ut hela!
	mov	tabort_diovre_fnt,0
;	mov	ax,rull_pos
	mov	bx,sw/4*2		;di=rull_pos*sw*2/4
	mul	bx
	mov	di,ax
	add	di,sw/4*2	
print_it:
	CMP	TABORT_DIOVRE,13
	JAE	SKIPIT_PRINT
	mov	ax,rulltext
	call	print_text
SKIPIT_PRINT:
	retn


clear_box2:
	;obs EJ en taskig rutin!!
	mov	cx,clear_box_hojd
	mov	di,clear_box_start
	move	es,0a000h

doline_clear2:
	push	cx
	mov	cx,clear_box_bredd
	push	di
	push	cx
	setwrite 1
	mov	al,matrixhi
	rep stosb
	pop	cx
	pop	di
	push	di
	setwrite 100b
	mov	al,matrixhi
	rep stosb
	pop	di
	pop	cx
	add	di,sw*2/4
	loop	doline_clear2

	retn


PP_DO_LINE PROC NEAR		;INPUT: ES:SI=SOURCE, LAGERARBETARNA=DEST
	MOV	CX,320/4
	MOV	DI,LAGERARBETAREN
	MOV	BYTE PTR DS:[DI],0
PP_NEXT_BYTE:
	PUSH	CX
	NIL	DH
	CMP	BYTE PTR ES:[SI],MATRIXLO
	JNE	ITS_GREY
	NOT	DH
ITS_GREY:
	AND	DH,LILLE_LAGERARBETAREN
	OR	DS:[DI],DH
	INC	SI
	ROR	LILLE_LAGERARBETAREN,1
	JNC	EJ_BYTE_AV_BYTE
	INC	DI
	MOV	BYTE PTR DS:[DI],0
EJ_BYTE_AV_BYTE:
	POP	CX
	LOOP	PP_NEXT_BYTE
	MOV	LAGERARBETAREN,DI
	RETN
PP_DO_LINE ENDP

PP_DO_BITPLANE PROC NEAR		;INPUT: RéTT BITPLAN SATT
	MOV	CX,16
	MOV	SI,SW*4/4/2
PP_NEXT_LINE:
	PUSH	CX SI
	CALL	PP_DO_LINE
	POP	SI CX
	ADD	SI,SW/4*2
	LOOP	PP_NEXT_LINE
	RETN
PP_DO_BITPLANE ENDP

PRINT_PAUSE:
	CALL	MATRIXON_
	CALL	DOLIGHTS
	MOV	LAGERARBETAREN,OFFSET PAUSE_LAGRET
	MOV	LILLE_LAGERARBETAREN,10000000B
	MOVE	ES,0A000H
	MOV	CX,4
PP_NEXT_BITPLANE:
	PUSH	CX
	MOV	AL,4
	SUB	AL,CL
	SETREAD	AL
	CALL	PP_DO_BITPLANE
	POP	CX
	DEC	CX
	LOOP	PP_NEXT_BITPLANE

	PUSH	OFFSET PAUSE_TEXT
	POP	AX_PRINT
	MOVE	DI_PRINT,sw*4/4+16*0/4+4*5-2
	call	print_it_klux
	CALL	MATRIXON_
	CALL	DOLIGHTS
	RETN
print_it_klux:
	MOV	CLEAR_BOX_START,SW/4*2
	MOV	CLEAR_BOX_BREDD,320/4
	MOV	CLEAR_BOX_HOJD,16
       	CALL	CLEAR_BOX2
	MOV	HOJD_1,13
	MOV	HOJD_ADD,BREDD_1/4-SW*13*2/4
	MOV	FONT_ADR,OFFSET FONT13
	MOV	TABORT_DIOVRE,0	
	MOV	TABORT_DIOVRE_FNT,0
	MOV	AX,AX_PRINT
	MOV	DI,DI_PRINT
	CALL	PRINT_TEXT
	retn
PP_DO_LINE2 PROC NEAR		;INPUT: ES:DI=DEST, LAGERARBETARNA=SOURCE
	MOV	CX,320/4
	MOV	SI,LAGERARBETAREN
PP_NEXT_BYTE2:
	PUSH	CX
	MOV	AL,DS:[SI]
	AND	AL,LILLE_LAGERARBETAREN
	MOV	AL,MATRIXLO
	JNZ	ITS_YELLOW
	MOV	AL,MATRIXHI
ITS_YELLOW:
	STOSB
	ROR	LILLE_LAGERARBETAREN,1
	JNC	EJ_BYTE_AV_BYTE2
	INC	SI
EJ_BYTE_AV_BYTE2:
	POP	CX
	LOOP	PP_NEXT_BYTE2
	MOV	LAGERARBETAREN,SI
	RETN
PP_DO_LINE2 ENDP

PP_DO_BITPLANE2 PROC NEAR		;INPUT: RéTT BITPLAN SATT
	MOV	CX,16
	MOV	DI,SW*4/4/2
PP_NEXT_LINE2:
	PUSH	CX DI
	CALL	PP_DO_LINE2
	POP	DI CX
	ADD	DI,SW/4*2
	LOOP	PP_NEXT_LINE2
	RETN
PP_DO_BITPLANE2 ENDP

RESTORE_AFTER_PAUSE PROC NEAR
	MOV	LAGERARBETAREN,OFFSET PAUSE_LAGRET
	MOV	LILLE_LAGERARBETAREN,10000000B
	MOVE	ES,0A000H
	MOV	CX,2
	MOV	AL,1
PP_NEXT_BITPLANE2:
	PUSH	AX CX
	SETWRITE AL
	CALL	PP_DO_BITPLANE2
	POP	CX AX
	SHL	AL,2
	LOOP	PP_NEXT_BITPLANE2
	RETN
RESTORE_AFTER_PAUSE ENDP

_print13:
	move	sisa,1
	mov	dotrut,offset waitrut
	MOV	HOJD_1,13
	MOV	HOJD_ADD,BREDD_1/4-SW*13*2/4
	MOV	FONT_ADR,OFFSET FONT13
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	MOVE	AX_PRINT,[BX+2]
	MOVE	DI_PRINT,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	jmp	print_end
_print11:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	hojd_1,11
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*11*2/4
	mov	font_adr,offset font11
	MOVE	AX_PRINT,[BX+2]
	MOVE	DI_PRINT,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	jmp	print_end
_print8:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	hojd_1,8
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*8*2/4
	mov	font_adr,offset font8
	MOVE	AX_PRINT,[BX+2]
	MOVE	DI_PRINT,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	jmp	print_end
_print5:
	move	sisa,1
	mov	dotrut,offset waitrut
	mov	hojd_1,5
	mov	tabort_diovre,0	
	mov	tabort_diovre_fnt,0
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	MOVE	AX_PRINT,[BX+2]
	MOVE	DI_PRINT,[BX+4]
	MOV	PRINTTASK,OFFSET PRINT_TEXT
	jmp	print_end
;******************************
print_END:
	ADD	BX,6
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_
	MOV	BX,0
_NEXTp_:
	MOV	NEXT_A,BX
	RETN
;******************************		
three_end:
	ADD	BX,6+2
	CMP	WORD PTR [BX],0
	JNE	_NEXTp_Q
	MOV	BX,0
_NEXTp_Q:
	MOV	NEXT_A,BX
	RETN

MATRIX_BLINKOR:
	CMP	MATRIX_IS_FLASHING,TRUE
	JNE	NOBLINKOR
	DEC	MATRIX_CNT
	JNZ	DUMRET
	MOVE	MATRIX_CNT,MATRIX_SPEED
	MOV	SI,OFFSET MATRIXOFF
	XOR	MATRIX_ONOFF,0FFH
	JZ	THE_OTHER
	MOV	SI,OFFSET MATRIXON
THE_OTHER:
	MOVE	ES,DS
	MOV	DI,RGBBUFPTR
	;FLYTTA [SI] TILL [DI] & UPPDAT RGBBUFPTR!
	MOVSB			;START COL
	LODSB			;AL=RGB LEN
	STOSB
	MOV	CL,AL
	NIL	CH
	REP	MOVSB		;R,G,B ETC
	MOV	RGBBUFPTR,DI
NOBLINKOR:
	RETN

MATRIXON_:
	MOV	SI,OFFSET MATRIXON
	MOVE	ES,DS
	MOV	DI,RGBBUFPTR
	;FLYTTA [SI] TILL [DI] & UPPDAT RGBBUFPTR!
	MOVSB			;START COL
	LODSB			;AL=RGB LEN
	STOSB
	MOV	CL,AL
	NIL	CH
	REP	MOVSB		;R,G,B ETC
	MOV	RGBBUFPTR,DI
;	CALL	DOLIGHTS
	RETN

MATRIXOFF_:
	MOV	SI,OFFSET MATRIXOFF
	MOVE	ES,DS
	MOV	DI,RGBBUFPTR
	;FLYTTA [SI] TILL [DI] & UPPDAT RGBBUFPTR!
	MOVSB			;START COL
	LODSB			;AL=RGB LEN
	STOSB
	MOV	CL,AL
	NIL	CH
	REP	MOVSB		;R,G,B ETC
	MOV	RGBBUFPTR,DI
;	CALL	DOLIGHTS
	RETN


_FLASHOFF:
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT
	CALL	KILL_FLASHOR
	JMP	NORMAL_END

_MATRIXLGT:
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT
	CMP	WORD PTR [BX+2],0
	JE	OFF_WITH_IT
	CALL	MATRIXON_
	JMP	BORT_LELLE_VAN	
OFF_WITH_IT:
	CALL	MATRIXOFF_
BORT_LELLE_VAN:
	JMP	NORMAL_END

_SETDECCOR:
	MOVE	SISA,1		;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT
	MOVE	DECCOR,DS:[BX+2]
	JMP	NORMAL_END

KILL_FLASHOR PROC NEAR
	pusha
	MOV	MATRIX_IS_FLASHING,FALSE
	MOV	SI,OFFSET MATRIXON
	MOVE	ES,DS
	MOV	DI,RGBBUFPTR
	;FLYTTA [SI] TILL [DI] & UPPDAT RGBBUFPTR!
	MOVSB			;START COL
	LODSB			;AL=RGB LEN
	STOSB
	MOV	CL,AL
	NIL	CH
	REP	MOVSB		;R,G,B ETC
	MOV	RGBBUFPTR,DI
	popa
	RETN
KILL_FLASHOR ENDP

_WAIT:
	MOVE	SISA,[BX+2]	;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT
;galopp
	JMP	NORMAL_END

_WAITifmulti:
	MOVE	SISA,[BX+2]	;HUR MÜNGA
	cmp	players,1
	jne	dowwe
	mov	sisa,2 ;cpgnu? venta inte om ej multiplayer
dowwe:	MOV	DOTRUT,OFFSET WAITRUT
;galopp
	JMP	NORMAL_END
_LOCK:
	MOVE	SISA,[BX+2]	;HUR MÜNGA
	MOV	DOTRUT,OFFSET LOCKRUT
;galopp
	JMP	NORMAL_END
LOCKRUT:
	MOV	SI,1
	RETN	
	
_WAIT_YN:
	MOVE	SISA,[BX+2]	;HUR MÜNGA
	MOV	DOTRUT,OFFSET WAITRUT_YN
;galopp
	JMP	NORMAL_END
endit:
	ADD	BX,2
	CMP	WORD PTR [BX],0
	JNE	_NEXT_hh
	MOV	BX,0
_NEXT_hh:
	MOV	NEXT_A,BX
	RETN
clearend:
	mov	si,0
	retn

_clear1:	;clear all matrix
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET rclear1
	mov	clearval,0
	jmp	endit
rclear1:
	add	clearval,2*sw/4
	move	clear_box_start,clearval
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,16
	call	clear_box2
	jmp	clearend

_clear2:	;clear from top to bottom
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET rclear2
	mov	clearval,0
	jmp	endit
rclear2:
	add	clearval,2*sw/4
	cmp	clearval,2*sw*18/4-2*SW/4
	je	clearend
	move	clear_box_start,clearval
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2
	mov	si,1
	retn
_clear3:	;clear from left to right
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET rclear3
	mov	clearval,sw*2/4-1
	jmp	endit
rclear3:
	add	clearval,1
	cmp	clearval,320/4+sw*2/4
	je	clearend
	move	clear_box_start,clearval
	mov	clear_box_bredd,1
	mov	clear_box_hojd,16
	call	clear_box2
	mov	si,1
	retn
_clear4:	;clear 4 raster top to bottom
	MOVE	SISA,1
	MOV	DOTRUT,OFFSET rclear4
	mov	clearval,0
	jmp	endit
rclear4:
	add	clearval,2*sw/4
	cmp	clearval,2*sw*5/4
	je	clearend

	move	clear_box_start,clearval
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2

	move	clear_box_start,clearval
	add	clear_box_start,4*2*sw/4
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2

	move	clear_box_start,clearval
	add	clear_box_start,8*2*sw/4
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2

	move	clear_box_start,clearval
	add	clear_box_start,12*2*sw/4
	mov	clear_box_bredd,320/4
	mov	clear_box_hojd,1
	call	clear_box2


	mov	si,1
	retn

	
_FADE:
	MOVE	SISA,[BX+2]	;HUR MÜNGA
	MOV	DOTRUT,OFFSET FADERUT
	PUSHA
	PUSH	ES
	MOV	CS:FADING,TRUE
	CALL	READPAL
	POP	ES
	POPA
;galopp
	JMP	NORMAL_END
FADING DB FALSE	
READPAL:
	MOV	DX,3C7H
	MOV	AL,0
	OUT	DX,AL
	MOV	DX,3C9H
	MOV	CX,3*256
	MOVA	ES,CS
	MOV	DI,OFFSET CS:PALLE
RPAL:
	IN	AL,DX
	STOSB
	LOOP	RPAL
	RETN
SETPAL:
	MOV	DX,3C8H
	MOV	AL,0
	OUT	DX,AL
	MOV	CX,3*256
	MOV	DI,OFFSET CS:PALLE
SPAL:
	MOV	AL,CS:[DI]
	XOR	AH,AH
	MUL	BX
	MOV	AL,AH
	MOV	DX,3C9H
	OUT	DX,AL
	INC	DI
	LOOP	SPAL
	RETN
PALLE	DB 3*256 DUP(32)
FADERUT:
	DEC	SI
	PUSHA
	PUSH	ES
	MOV	CX,SI
	TEST	CX,15
	JNZ	NONEW16
	MOV	AL,6
	INT	66H
NONEW16:MOV	BX,CX
	CALL	SETPAL
	POP	ES
	POPA
	RETN
_WAITJINGLE:
	MOV	DOtRUT,OFFSET WAITJINGLE
	JMP	NORMAL_END
_WAITJINGLE2:
	MOV	DOtRUT,OFFSET WAITJINGLE2
	JMP	NORMAL_END

WAITRUT:
	DEC	SI
	RETN	


WAITRUT_YN:
	mov	al,scan_code
	cmp	al,-1
	je	feltecken_du2	;ej tryckt!
	mov	scan_code,-1
	mov	bx,offset alfa_keys
	xlat
	cmp	al,0
	je	feltecken_du2	;felaktigt tecken!
	CMP	AL,'N'
	JE	NOKVTTER
	CMP	AL,'Y'
	JE	do_quit_mr
	jmp	nokvtter
do_quit_mr:
	MOV	CS:QUITTING,TRUE
NOKVTTER:
	mov	cs:already_quitting,false
	mov	cs:keyboard_enabled,true
	MOV	SI,0
	RETN	
feltecken_du2:
	MOV	SI,1
	RETN	

PARTYRUT:
;	DEC	SI
	RETN	

WAITJINGLE:
	mov	si,TRUE
	CMP	JINGLE_READY_ANIM,TRUE
	JNE	DUMRET
	MOV	SI,0
	RETN

WAITJINGLE2:		;WAITJINGLE2 HAR EN SPECIALARE FôR NOSOUND
			;OBS! DECCOR MèSTE VARA SATT INNAN DENNA RUT ANVéNDS.
	mov	si,TRUE
	PUSH	ES
	PUSHA
	SET_ES	0
	MOV	AX,21
	PUSHF
	CALL	DWORD PTR ES:[66H*4]	;TEST IF NOSOUND
	TEST	AL,1000B
	JNZ	ITWASNOSOUND
	CMP	JINGLE_READY_ANIM,TRUE
	JNE	QWJ2
	JMP	SHORT ENDOFIT
ITWASNOSOUND:
	DEC	DECCOR
	JZ	ENDOFIT
QWJ2:	POPA
	POP	ES
	RETN
ENDOFIT:
	POPA
	POP	ES
	NIL	SI
	RETN

PEKORB	DW SCORE
	DW CODE2
SIFFRORRUT:
	PUSHA
	MOV	BX,SW*2/4-16*2/4	;TJA, VADè CENTRERAD??
	MOVE	ES,CS
	CALL	DWORD PTR ES:PEKORB
	POPA
	UPDAT_SCORE
	MOV	SI,0
	RETN
;******************************
NORMAL_END:
	ADD	BX,4
	CMP	WORD PTR [BX],0
	JNE	_NEXT_
	MOV	BX,0
_NEXT_:
	MOV	NEXT_A,BX
	RETN
;******************************		
PEKOR	DW SCORE
	DW CODE2
NODOT:
;NO EFFECT IS RUNNING!!
;SHOW THE SCORE!
;	debugmess 0,1,'NODOT     '

	cmp	cs:keyboard_enabled,false
	je	i_show_naaathing	;if keyb disabled, a quest is on the screen!!
	CMP	NODOTCOUNT,NOT_PLAYING
	JE	SHOW_HI_ETC
	CMP	AFTER_CHEAT,TRUE
	JE	CHEATED
	CMP	DEMOMODE,TRUE
	JE	SHOW_HI_2
	
;	CMP	NODOTCOUNT,0
;	JNE	ONLY_SCORE	

	CMP	I_UTSKJUT,TRUE
	JE	ONLY_SCORE
	cmp	behovs_provad,true
	jne	only_score
	mov	behovs_provad,false	;skriv ut bara fîrsta gÜngen!
	MOV	BX,OFFSET showplayersTS
	CALL	DO_SPEC_MATRIX
	JMP	ONLY_SCORE
CHEATED:
	MOV	AFTER_CHEAT,FALSE
	MOV	BX,OFFSET showHighSTS
	CALL	DO_MATRIX
;	debugmess 0,0,"cheat"
	JMP	i_show_naaathing
SHOW_HI_ETC:
	cmp	spring_valid,true
	je	overitagain
	mov	fjanttext,true
if demover
	moval	play_text[8],'7'+1
else
	moval	play_text[8],playerstext[7]
endif
	moval	play_text[18],ballstext[5]
	MOV	BX,OFFSET showInfoTS
	CALL	DO_MATRIX
	JMP	OVERITAGAIN
SHOW_HI_2:
	MOV	BX,OFFSET AfterDemoModeTS	;cp!!??
	CALL	DO_MATRIX
	jmp	overitagain
overitagain_heter_nisse:
	mov	first_time_you_fool,false
OVERIT:	MOV	BX,OFFSET showHighSTS
	CALL	DO_MATRIX
OVERITAGAIN:

ONLY_SCORE:
	CALL	CHECKHIGHSCORE
	INC	NODOTCOUNT

	mov	si,offset siffrorna
	mov	bx,SW*2/4+(320-12*16)/4	;hîger justerad!
	MOVE	ES,CS
	CALL	DWORD PTR ES:PEKOR
i_show_naaathing:
	MOV	SI,0
	RETN	;DUMRET FôR DOTS

CHECKHIGHSCORE:
	pusha
	cmp	i_utskjut,true
	je	end_chkofhiscre
	cmp	specialmode,true
	je	end_chkofhiscre
	cmp	already_beaten,true
	je	end_chkofhiscre
	mov	di,offset hi_score_list
	MOV	SI,OFFSET SIFFRORNA
Hcheck_list:
	mov	cx,12
	mov	bx,0
Hcheck_num:
	mov	al,[di+bx]
	cmp	[si+bx],al
	jb	Hnot_beaten
	ja	Hbeaten
	inc	bx
	loop	Hcheck_num
Hnot_beaten:
end_chkofhiscre:
	popa
	RETN
Hbeaten:
	mov	already_beaten,true
	MOV	BX,OFFSET BEATENTS
	CALL	DO_MATRIX
	mov	behovs_provad,true
	popa
	RETN
	

;******
_beaten_matrix:
	pusha
	cmp	already_beaten,true
	je	bend_chkofhiscre
	mov	di,offset hi_score_list
	MOV	SI,OFFSET SIFFRORNA
bHcheck_list:
	mov	cx,12
	mov	bx,0
bHcheck_num:
	mov	al,[di+bx]
	cmp	[si+bx],al
	jb	bHnot_beaten
	ja	bHbeaten
	inc	bx
	loop	bHcheck_num
bHnot_beaten:
bend_chkofhiscre:
	popa
	add	bx,2
	jmp	[bx]

bHbeaten:
	mov	already_beaten,true
	popa
	mov	bx,offset beaten_bh_ts
	JMP	[BX]

	
print_siffror5__:
	;print_numbers input e si=offset till bcd:n, di=pos Ü skriva ut
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,5
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	call	print_number
	
	
print_siffror5:		;DETTA éR HéRMED EN TASKRUTIN!!!
	;print_numbers input e si=offset till bcd:n, di=pos Ü skriva ut
	mov	si,si_siffror
	mov	di,di_siffror
	mov	hojd_1,5
	mov	hojd_add,bredd_1/4-sw*5*2/4
	mov	font_adr,offset font5
	call	print_number
	SUICIDE

print_siffror8:			;CP!
	;print_numbers input e si=offset till bcd:n, di=pos Ü skriva ut
	mov	hojd_1,8
	mov	hojd_add,bredd_1/4-sw*8*2/4
	mov	font_adr,offset font8
	call	print_number
retn
print_siffror11:
	;print_numbers input e si=offset till bcd:n, di=pos Ü skriva ut
	mov	hojd_1,11
	mov	hojd_add,bredd_1/4-sw*11*2/4
	mov	font_adr,offset font11
	call	print_number
retn
print_siffror13:
	;print_numbers input e si=offset till bcd:n, di=pos Ü skriva ut
	mov	hojd_1,13
	mov	hojd_add,bredd_1/4-sw*13*2/4
	mov	font_adr,offset font13
	call	print_number
Retn




FLIPPRA:
IF DEBUG
	mov	cs:Reknare,0	;cp! debugging info
;	DEBUGVAL   0,5,[BX].LASTGFXFRAME,"LASTGFXFRAME: "
ENDIF
	SET_ES	0A000H
	MOV	DX,3C4H
	MOV	AX,0F02H
	OUT	DX,AX		;;ALLA BITPLAN Pè

	MOV	DX,3CEH
	MOV	AX,4105H
	OUT	DX,AX		;ARONSSON ON


	MOV	AX,[BX].TOPY
	ADD	AX,SPLH
	MOV	DI,BPL
	MUL	DI
	MOV	DI,AX
	MOV	AX,[BX].LEFTX
	SHR	AX,2
	ADD	DI,AX

	
	MOV	AX,[BX].FLIPFRAME
	MOV	CX,AX
	SUB	CX,[BX].LASTGFXFRAME
	XCHG	[BX].LASTGFXFRAME,AX
	JE	NOMOVE	;;OM 0: INGET JAG KAN GôRA
	JA	WAYUP
	NEG	CX
	MOV	DX,[BX].FLIPDIFS
	MUL	DX
	MOVE	[BX].FLIPPEK,[BX].FLIPMAXPEK
	SUB	[BX].FLIPPEK,AX
	JMP	DANIM
reknare dw 0
maxreknare dw 0
WAYUP:	
	MOV	DX,[BX].FLIPDIFS
	MUL	DX
	ADD	AX,[BX].FLIPTAB
	MOV	[BX].FLIPPEK,AX
DANIM:
	PUSH	0
	CMP	CX,9
	JBE	DELTA_ANIMERA
	POP	AX	;DUMMY POP
	MOV	AX,CX
	SUB	AX,9
	PUSH	AX
	MOV	CX,9
DELTA_ANIMERA:
	PUSH	CX DI
	PUSH	BX
	MOV	BX,[BX].FLIPPEK
;	debugclear
;	debugval 10,10,bx,"="
;	jmp	quit		
	MOVA	DS,DATAFLIP
	mov	si,cx
	dec	si
	shl	si,1
	MOV	CX,[BX+si]	;cp! ska va bx+si
	jcxz	nobytestoanim
IF DEBUG
	add	cs:reknare,cx
	CMP	CS:REKNARE,300
	JB	INGEN_HORSE
	DEBUGVAL 0,4,BX,"BX VA="
	DEBUGVAL 15,4,SI,"SI VA="
	DEBUGVAL 35,4,[BX+SI],"[BX+SI] VA="
	POP	BX
	MOVA	DS,DATA
	DEBUGVAL 20,5,[BX].LASTGFXFRAME,"NEW GFXFRAME: "
	JMP	QUIT
ENDIF
INGEN_HORSE:
	ADD	BX,2*9
	CALL	DELTANIM
nobytestoanim:
	MOVA	DS,DATA
	POP	BX
	ADDA	[BX].FLIPPEK,[BX].FLIPDIFS
	POP	DI CX
	LOOP	DELTA_ANIMERA
	POP	CX
IF DEBUG
	mov	cs:Reknare,0	;cp! debugging info
ENDIF
	OR	CX,CX
	PUSH	0
	JNZ	DELTA_ANIMERA
	POP	AX	;DUMMY POP
IF DEBUG
	mov	cx,cs:reknare
	cmp	cs:maxreknare,cx
	ja	nomove
	mov	cs:maxreknare,cx
	debugval 0,3,cs:maxreknare,"max antal deltade bytes per frame: "
ENDIF
NOMOVE:
	MOV	DX,3CEH
	MOV	AX,4005H
	OUT	DX,AX		;ARONSSON OFF
	RETN

DOFLIPPER:
IF MARGIT
	SETMARG	31
ENDIF
	MOV	BX,OFFSET FLIPLINFO
	CALL	FLIPPRA
	ADD	BX,(SIZE FLIPSTRUC)
	CALL	FLIPPRA			
IF MARGIT
	SETMARG	0
ENDIF
	RETN
DOFLIPPER3:
IF MARGIT
	SETMARG	15
ENDIF
	MOV	BX,OFFSET FLIPLINFO+(SIZE FLIPSTRUC)*2
	cmp	byte ptr [bx],0
	jz	no_upper_flip
	CALL	FLIPPRA			
no_upper_flip:
IF MARGIT
	SETMARG	0
ENDIF
	RETN

LATE_RASTER_INTERRUPT:
	MOVE	DS,DATA
	MOV	INT_WAS_HERE,TRUE
	MOV	INT_WAS_HERE2,TRUE
	CMP	SLOWCNT,0
	JNZ	RETTEF
	CMP	INTERRUPTS_ON,TRUE
	JE	LRINTOK
RETTEF:	
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF					;RET
LRINTOK:
	MOV	TIME_LEFT,TRUE
	OR	AX,AX
	JZ	NO_MUSIC_CRISIS3
	MOV	TIME_LEFT,FALSE
NO_MUSIC_CRISIS3:
	CMP	DEMOMODE,TRUE
	JE	LATE_RASTER_INTERRUPT_DEMO

;*********************** SPELETS RUTINER ****************************

	CMP	INSIDE_RASTINT,FALSE
	JNE	RETTEF
	
	CMP	CS:LAST_WAS_VB,TRUE
	JNE	RETTEF
	
	CALL	SETSCREENSTART
	CMP	INSIDE_BALLHANDLER,FALSE
	JNE	RETTEF

	MOV	INSIDE_RASTINT,TRUE
	SAVEGFXREGS
	CALL	KOLLAKULAN	;GîR TVÜ BERÑKNINGAR
	CMP	LATEGFX,TRUE
	JNE	NOLGFX
	MOV	PUTITBETWEEN,FALSE
	CALL	PUTTHEBALL
NOLGFX:	CMP	FORCELATEF3,TRUE
	JNE	NOFF3
	CALL	DOFLIPPER3
NOFF3:	

	MOV	AL,F1F8_CODE		;TAR HAND OM F1F8_CODE I GAMEMODE
	OR	AL,AL
	JZ	NOF1F8_TODAY
	MOV	F1F8_CODE,0
	SUB	AL,3BH-1	;3BH=CODE FOR F1
	MOV	PLAYERS,AL
	ADD	AL,'0'+7
	MOV	NO_OF_PLAYERS_TEXT[8],AL
	MOV	BX,OFFSET no_of_playersTS
	CALL	DO_MATRIX
	SOUNDEFFECT S_ADDPLAYER2,0
	mov	addplayers,false
	addtask	allow_addpl
NOF1F8_TODAY:
	RESTOREGFXREGS
	MOV	CS:LAST_WAS_VB,FALSE
	MOV	INSIDE_RASTINT,FALSE
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF

DOLON	PROC NEAR
	REALON	BL
	RETN
DOLON	ENDP

DOLOFF	PROC NEAR
	REALOFF	BL
	RETN
DOLOFF	ENDP

DOSUICIDE PROC NEAR
	MOV	BX,SAVESOURCE
	MOV	DS:[BX],OFFSET DUMRET
	DEC	NO_OF_ACTIVE_TASKS
	RETN
DOSUICIDE ENDP

DOWAITSYNCS PROC NEAR
	CMP	DS:[BX],DX
	JE	THISISIT
	INC	WORD PTR DS:[BX]
	CLC
	RETN
THISISIT:
	MOV	WORD PTR DS:[BX],0
	STC
	RETN
DOWAITSYNCS ENDP

DOLIGHTON PROC NEAR
	NIL	BH
	MOV	LIGHTSTATUS[BX],TRUE
	LON	BL
	RETN
DOLIGHTON ENDP

DOLIGHTOFF PROC NEAR
	NIL	BH
	MOV	LIGHTSTATUS[BX],FALSE
	LOFF	BL
	RETN
DOLIGHTOFF ENDP

DOLIGHTFLASH PROC NEAR
	MOV	BX,OFFSET REALFLASHLIST
NEXTFLASHPOST:
	CMP	[BX].LNUM,0
	JE	FOUNDFLASHPOST
	ADD	BX,SIZE FLASHSTRUC
	CMP	BX,MAX_NO_OF_LIGHTS_FLASHING*SIZE FLASHSTRUC+OFFSET REALFLASHLIST
	JNE	NEXTFLASHPOST
	JMP	CP_MEN_OKEJ
FOUNDFLASHPOST:
	MOV	[BX].LNUM,DL
	MOV	[BX].FLASHCOUNTER,AL
	MOV	[BX].TURNOFF,DH
	SHL	DH,1
	MOV	[BX].RESETFC,DH
CP_MEN_OKEJ:
	RETN
DOLIGHTFLASH ENDP

DOENDFLASH PROC NEAR
	MOV	BX,OFFSET REALFLASHLIST
NEXTFLASHPOST2:
	CMP	[BX].LNUM,DL
	JNE	WASNTTHISONE
	MOV	[BX].LNUM,0
	JMP	DONTBOTHER
WASNTTHISONE:
	ADD	BX,SIZE FLASHSTRUC
	CMP	BX,MAX_NO_OF_LIGHTS_FLASHING*SIZE FLASHSTRUC+OFFSET REALFLASHLIST
	JNE	NEXTFLASHPOST2
DONTBOTHER:
	RETN
DOENDFLASH ENDP

RESETFLASHLIST PROC NEAR
	MOV	CX,MAX_NO_OF_LIGHTS_FLASHING*SIZE FLASHSTRUC
	MOV	DI,OFFSET REALFLASHLIST
	MOVA	ES,DS
	NIL	AL
	REP	STOSB
	RETN
RESETFLASHLIST ENDP


FLASHTHELIGHTS PROC NEAR	;OBS! éNDRAR ENDAST PALETTEN, EJ STATUS!!!
	MOV	BX,OFFSET REALFLASHLIST
NEXTFLASHER:
	CMP	[BX].LNUM,0
	JZ	NOTTHISONE
	CMP	[BX].FLASHCOUNTER,0
	JNZ	NOTZEROISIT
GOTOZERO:
	PUSH	BX
	LON	[BX].LNUM
	POP	BX
	JMP	LETSINCIT
NOTZEROISIT:
	MOV	AL,[BX].TURNOFF
	CMP	[BX].FLASHCOUNTER,AL
	JNE	NOTOFFISIT
	PUSH	BX
	LOFF	[BX].LNUM
	POP	BX
	JMP	LETSINCIT
NOTOFFISIT:
	MOV	AL,[BX].RESETFC
	CMP	[BX].FLASHCOUNTER,AL
	JNE	NOTRESETISIT
	MOV	[BX].FLASHCOUNTER,0
	JMP	GOTOZERO
NOTRESETISIT:
LETSINCIT:
	INC	[BX].FLASHCOUNTER
NOTTHISONE:
	ADD	BX,SIZE FLASHSTRUC
	CMP	BX,MAX_NO_OF_LIGHTS_FLASHING*SIZE FLASHSTRUC+OFFSET REALFLASHLIST
	JNE	NEXTFLASHER
	RETN
FLASHTHELIGHTS ENDP

RECALC_LIGHTS PROC NEAR	;FN: DPAINT RGB VALUES -> MCGA RGB VALUES
	MOV	SI,OFFSET LON1
	MOV	DI,OFFSET LON1
	MOVE	ES,DS
NEXTPOST:
	LODSB			;START COL
	OR	AL,AL
	JZ	NOMOREPOSTS
	STOSB

	LODSB			;BLOCK LEN
	MOV	DL,3
	MUL	DL
	MOV	CX,AX
	STOSB

NEXTCOLOR:
	LODSB			;RECALC 0-100 -> 0-63
	MOV	DL,162		;(63/100*256=161.28)   AX=AL*162*256
	MUL	DL
	MOV	AL,AH
	STOSB
	LOOP	NEXTCOLOR
	JMP	NEXTPOST
NOMOREPOSTS:
	RETN
RECALC_LIGHTS ENDP

SLACK_LIGHTS PROC NEAR	;FN: TURNS OUT ALL LIGHTS
	cmp	uppstartad,true
	jne	dumret
	MOV	AX,1
SLAGAIN:PUSH	AX
	MOV	BX,AX
	MOV	LIGHTSTATUS[BX],FALSE
	MOV	BL,AL
	NIL	BH
	DEC	BX
	SHL	BX,1
	MOV	SI,LONINDEX[BX]
	MOVE	ES,DS

	CALL	SLACK_THIS_LIGHT

	POP	AX
	INC	AX
	CMP	AX,NOOFLIGHTS
	JBE	SLAGAIN
	RETN
SLACK_LIGHTS ENDP
SLACK_THIS_LIGHT PROC NEAR	;FN: SLéCKER RGBPOST. KOLLAR ATT DET GICK BRA!
				;INPUT: SI PEKAR Pè RGB-POSTEN
				;OUTPUT: SI PEKAR Pè NéSTA RGB-POST
	PUSH	AX BX CX DX BP
	MOV	BL,INTERRUPTS_ON
	MOV	INTERRUPTS_ON,FALSE
	MOV	BP,SI
TRY_IT_AGAIN2:
	MOV	INT_WAS_HERE2,FALSE
	;GôR POSTEN [SI] FAST SLACK!
	MOV	DX,3C8H
	LODSB			;AL=START COL
	OUT	DX,AL
	INC	DX
	LODSB			;AL=RGB DATA LEN
	MOV	CL,AL
	NIL	CH
REPUTA:	LODSB
	SHR	AL,1
	OUT	DX,AL
	LOOP	REPUTA
	CMP	INT_WAS_HERE2,FALSE
	JE	ITS_REALLY_OK2
	MOV	SI,BP
	JMP	TRY_IT_AGAIN2
ITS_REALLY_OK2:
	MOV	INTERRUPTS_ON,BL
	POP	BP DX CX BX AX
	RETN
SLACK_THIS_LIGHT ENDP
SLACK_THIS_LIGHT_i_pelle PROC NEAR	;FN: SLéCKER RGBPOST. KOLLAR ATT DET GICK BRA!
				;INPUT: SI PEKAR Pè RGB-POSTEN
				;OUTPUT: SI PEKAR Pè NéSTA RGB-POST
	PUSH	AX BX CX DX BP
	;GôR POSTEN [SI] FAST SLACK!
	LODSB			;AL=START COL
	mov	ah,3
	mul	ah
	add	ax,offset cs:palle
	mov	di,ax
	LODSB			;AL=RGB DATA LEN
	MOV	Cx,Ax
	xor	ch,ch
REPUTA7:LODSB
	SHR	AL,1
	mov	cs:[di],al
	inc	di
	LOOP	REPUTA7
	POP	BP DX CX BX AX
	RETN
SLACK_THIS_LIGHT_i_pelle ENDP

SLACK_LIGHTS_i_pelle PROC NEAR	;FN: TURNS OUT ALL LIGHTS
	MOV	AX,1
SLAGAIN2:PUSH	AX
	MOV	BX,AX
	MOV	LIGHTSTATUS[BX],FALSE
	MOV	BL,AL
	NIL	BH
	DEC	BX
	SHL	BX,1
	MOV	SI,LONINDEX[BX]
	MOVE	ES,DS

	CALL	SLACK_THIS_LIGHT_i_pelle

	POP	AX
	INC	AX
	CMP	AX,NOOFLIGHTS
	JBE	SLAGAIN2
	RETN
SLACK_LIGHTS_i_pelle ENDP

DOLIGHTS PROC NEAR
	CMP	INSIDE_DOLIGHTS,TRUE
	JE	DONT_BOTHER
	MOV	INSIDE_DOLIGHTS,TRUE
	CMP	CS:FADING,TRUE
	JE	ITSFADING

	MOV	SI,OFFSET RGBBUFFER
DONEXTLIGHT:
	CMP	SI,RGBBUFPTR
	JE	DONOMORE
	CALL	DO_THIS_LIGHT
	JMP	DONEXTLIGHT
ITSFADING:
DONOMORE:
	MOV	RGBBUFPTR,OFFSET RGBBUFFER
	MOV	INSIDE_DOLIGHTS,FALSE
DONT_BOTHER:
	RETN
DOLIGHTS ENDP

DO_THIS_LIGHT PROC NEAR		;FN: UTFôR RGBPOST. KOLLAR ATT DET GICK BRA!
				;INPUT: SI PEKAR Pè RGB-POSTEN
				;OUTPUT: SI PEKAR Pè NéSTA RGB-POST
	PUSH	AX BX CX DX BP
	MOV	BL,INTERRUPTS_ON
	MOV	INTERRUPTS_ON,FALSE
	MOV	BP,SI
TRY_IT_AGAIN:
	MOV	INT_WAS_HERE,FALSE
	;GôR POSTEN [SI]!
	MOV	DX,3C8H
	LODSB			;AL=START COL
	OUT	DX,AL
	INC	DX
	LODSB			;AL=RGB DATA LEN
	MOV	CL,AL
	NIL	CH
	REP	OUTSB
	CMP	INT_WAS_HERE,FALSE
	JE	ITS_REALLY_OK
	MOV	SI,BP
	JMP	TRY_IT_AGAIN
ITS_REALLY_OK:
	MOV	INTERRUPTS_ON,BL
	POP	BP DX CX BX AX
	RETN
DO_THIS_LIGHT ENDP



DO_ELECTRONICS PROC NEAR	;EXEKVERAS VARJE UTRéKNING, EJ VARJE SYNC
	PUSHA
	PUSH	ES
if demover
	INC	MINUTE_5_COUNTER
	CMP	MINUTE_5_COUNTER,5*60*60-2
	Jne	NOLIMIT
	mov	fiveminutes,true
;	MOV	SPECIALMODE,FALSE
;	MOV	INH_EFF,FALSE
	MOV	HOLDSTILL,TRUE
	PLAYJINGLE S_GAMEOVER2
	MOV	BX,OFFSET MINUTE5TS
	CALL	DO_MATRIX
;	EFFECT	MINUTE5
;	MOV	SPECIALMODE,TRUE
NOLIMIT:
endif

	CALL	CHECK_AREAS
	CALL	CHECK_TARGETS
	CALL	CHECK_SHIFTKEYS
	CALL	MATRIX_BLINKOR
;	CALL	DO_PHYSICS

	CALL	KEYTASK		;KEYTASK CHANGED BY KEYINT
	MOV	KEYTASK,OFFSET DUMRET
	CALL	DO_TASKS
	CALL	FLASHTHELIGHTS
	POP	ES
	POPA
	RETN
DO_ELECTRONICS ENDP

DO_PHYSICS PROC NEAR
	CMP	TILTCOUNTER,0
	JZ	NOTI
	DEC	TILTCOUNTER
NOTI:	CALL	CHECK_BUMPERS
	CALL	CHECK_RAMPS	
	CALL	CHECK_LEVELS
	CMP	BALL_DOWN,TRUE
	JNE	DONT_LOOSE_BALL
	CMP	LOOSING,TRUE
	JE	DONT_LOOSE_BALL
	CALL	LOOSE_BALL
DONT_LOOSE_BALL:
	RET
DO_PHYSICS ENDP

CHECK_RAMPS PROC NEAR
	MOV	SI,SC_X
	ADD	SI,8
	SHR	SI,3
	MOV	AX,SC_Y
	ADD	AX,8
	MOV	CX,40
	MUL	CX
	ADD	SI,AX
	
	DEC	SI
	MOV	CX,3
FINDRAMP:
	PUSH	SI CX
	call	get_hi_ramp_byte
	CMP	BALLHIGH,TRUE
	Je	GotLo
	CALL	GET_LO_RAMP_BYTE
GOTLO:	POP	CX SI 
	INC	SI
	OR	AL,AL
	JZ	GETRAMP
	LOOP	FINDRAMP
	JMP	NORAMP
GETRAMP:
	CMP	BX,NO_OF_RAMPS
	JAE	NORAMP
	SHL	BX,2
	cmp	hi_res,true
	je	hiramp
	MOVA	GRAVX,ramptable[BX]
	MOVA	GRAVY,ramptable[BX+2]
NORAMP:	RETN
hiramp:
	MOVA	GRAVX,ramptable_hi[BX]
	MOVA	GRAVY,ramptable_hi[BX+2]
	retn
get_hi_ramp_byte:
	push	si
	PUSH	SI
	MOV	AX,SI
	XCHG	AH,AL
	AND	AH,11B
	SHR	SI,2
	MOV	AL,4
	MOV	DX,3CEH
	OUT	DX,AX
	MOV	BX,GFXMASK21_OFFSET
	set_es	0a000h
	MOV	AL,BYTE PTR ES:[SI+BX]
	POP	SI
	SET_ES	MASK2_2
	OR	AL,BYTE PTR ES:[SI]
	SET_ES	0A000H
	SHR	SI,2
	ADD	SI,GFXMASK23_OFFSET
	MOV	BL,ES:[SI]	
	AND	BX,15
	pop si
	RETN
GET_LO_RAMP_BYTE:	
	push si
	SET_ES	MASK1_1
	MOV	AL,ES:[SI]
	SET_ES	MASK1_2
	OR	AL,ES:[SI]
	PUSH	AX
	SET_ES	0A000H
	CMP	SI,230*40
	JAE	GO_STD
	PUSH	SI
	MOV	AX,SI
	SHR	AX,4
	INC	AX
	MOV	CX,80
	MUL	CX
	SHR	SI,2
	ADD	SI,AX
	ADD	SI,SPLH*BPL
	MOV	BL,ES:[SI]
	POP	SI
	SHR	SI,2
	JMP	DONE_WEIRD
GO_STD:	SHR	SI,2
	ADD	SI,GFXMASK13_OFFSET
	MOV	BL,ES:[SI-(9200/4)]
DONE_WEIRD:
	POP	AX
	AND	BX,15
	pop si
	RETN
ENDP

CHECK_BUMPERS PROC NEAR
	CMP	BUMPERWASHIT,FALSE
	JE	NOBUMPA
	MOV	BUMPERWASHIT,FALSE
	MOV	BX,HITPOINTER
	LEA	SI,[BX+2]
	MOV	DI,OFFSET SIFFRORNA
	PUSH	BX
	CALL	ADDSCOREBCD
	POP	BX
	MOV	SCORECHANGED,TRUE
	MOV	BP,DS:[BX]
	SOUNDEFFECT DS:[BP],0
	CALL	BUMPER_WAS_HIT_PROC
NOBUMPA:
	RETN
ENDP	



DOADDTASK PROC NEAR	;INPUT:DX=OFFSET THETASK
	MOV	BX,OFFSET TASKLIST
HOWABOUTNEXTTASKTHEN:
	CMP	DS:[BX],OFFSET DUMRET
	JE	FOUNDFREETASK
	ADD	BX,2
	CMP	BX,NOOFTASKS*2+OFFSET TASKLIST
	JNE	HOWABOUTNEXTTASKTHEN
;	DEBUGMESS 40,2,"MAX NO OF TASKS"
	JMP	ERRQUIT
FOUNDFREETASK:
	INC	NO_OF_ACTIVE_TASKS
	MOV	DS:[BX],DX
IF DEBUG
	debugVAL 0,11,NO_OF_ACTIVE_TASKS,"No of active tasks="
ENDIF
	RETN
DOADDTASK ENDP

DO_TASKS PROC NEAR
	MOV	CX,NOOFTASKS
	MOV	BX,OFFSET TASKLIST
DONXTTASK:
	PUSH	CX
	PUSH	BX
	MOV	SAVESOURCE,BX
	CALL	[BX]				;MèSTE VARA [BX]!
	POP	BX
	POP	CX
	ADD	BX,2
	LOOP	DONXTTASK
	RETN
DO_TASKS ENDP


DOEFFECTBRACK PROC NEAR	;INPUT: SI=OFFSET EFFECT STRUCTURE
			;OUTPUT: AL=1 IF TS DONE ELSE AL=0
	LODSW					;OFFSET JINGLE STRUC
	OR	AX,AX
	JZ	NOJINGLE2
	PUSH	SI
	PLAYJINGLE AX
	POP	SI

JUMP_2_JUMP_2:
	UPDAT_INFOBAR

	pusha
	mov	di,offset siffrorna		;hela scoren!!
	call	addscorebcd
	MOV	SCORECHANGED,TRUE
	popa
	add	si,12				;SCORE SIZE=12
	pusha
	mov	di,offset BONUSsiffrorna
	call	addscorebcd
	popa
	add	si,12				;BONUS SIZE=12

	LODSW					;OFFSET DOT STRUC
	OR	AX,AX
	JZ	NO_EFF_IT_IS_STAR_WARS
	MOV	BX,AX
	CALL	DO_MATRIX			;KALLA Pè JOHAN!
	MOV	AL,1
	RETN
NO_EFF_IT_IS_STAR_WARS:
	MOV	AL,0
	RETN
NOJINGLE2:
	LODSB					;PRIORITY
	JMP	JUMP_2_JUMP_2
DOEFFECTBRACK ENDP


DOEFFECT PROC NEAR	;INPUT: SI=OFFSET EFFECT STRUCTURE
			;OUTPUT: AL=1 IF TS DONE ELSE AL=0
	LODSW					;OFFSET JINGLE STRUC
	OR	AX,AX
	JZ	NOJINGLE
	CMP	AL,BYTE PTR S_LOSTBALL	;CP!? (ANNARS HôRS INTE LOSTBALL!)
	JE	DOEFF
	CMP	INH_EFF,TRUE
	JE	NOEFF1
	CMP	SPECIALMODE,TRUE
	JE	NOEFF1
DOEFF:	PUSH	SI
	PLAYJINGLE AX
	POP	SI
NOEFF1:
JUMP_2_JUMP:
	PUSHF

;Gabriel! HÑr Ñr hur man addar pÜ en score!!
;detta Ñr upp till dig att rîja upp!	
;(si pekar pÜ effektscoren!!)
;JAHAPP, MEN DET éR JU REDAN GJORT!

	UPDAT_INFOBAR

	pusha
	mov	di,offset siffrorna		;hela scoren!!
	call	addscorebcd
	MOV	SCORECHANGED,TRUE
	popa
	add	si,12				;SCORE SIZE=12

	pusha
	mov	di,offset BONUSsiffrorna
	call	addscorebcd
	popa
	add	si,12				;BONUS SIZE=12

	POPF
	JC	SORRY_MORE_IMPORTANT_STUFF_TO_DO
	LODSW					;OFFSET DOT STRUC
	OR	AX,AX
	JZ	NO_EFF_IT_IS
	CMP	INH_EFF,TRUE
	JE	NOEFF2
	CMP	SPECIALMODE,TRUE
	JE	NOEFF2
	MOV	BX,AX
	CALL	DO_MATRIX			;KALLA Pè JOHAN!
	MOV	AL,1
	RETN
NOEFF2:
NO_EFF_IT_IS:
SORRY_MORE_IMPORTANT_STUFF_TO_DO:
	MOV	EOTS,TRUE
	MOV	AL,0
	RETN
NOJINGLE:
	LODSB					;PRIORITY
	CMP	AL,CURRENT_PRIORITY
	JMP	JUMP_2_JUMP
DOEFFECT ENDP

DOPLAYJINGLE PROC NEAR	;INPUT: SI=OFFSET JINGLE STRUCTURE
	OR	SI,SI
	JZ	NOPLAYJINGLE
	LODSB				;JINGLE NO
	NIL	AH
	MOV	BX,AX
	LODSB				;REPEAT ??? ;CP?
	;AL=REPEAT
	push	ax
	xchg	JINGLEJUMPCNT,AL
	mov	bp,ax
	LODSB				;PRIORITY
	CMP	AL,CURRENT_PRIORITY
	JB	NOTNOW_ASHOLE		;SAME PRIORITY OVERRIDES!
	MOV	CURRENT_PRIORITY,AL
	MOV	AL,16
	PUSH	BX
	INT	66H			;AL=FORCE POSITION, BX=THE POSITION
	POP	BX			;ret: AL=OLD POSITION
	
	pop	dx			; utifall att jinglehandlern har gjort
	mov	jinglejumpcnt,dl	; sitt under tiden.....
	
	MOV	JINGLE_READY_ANIM,FALSE
	MOV	JINGLE_READY_LOGIC,FALSE
IF DEBUG
	DEBUGVAL 0,17,BX,"SENASTE BEORDRAD JINGLE: "
ENDIF
	MOV	BL,AL
	XOR	BH,BH
IF DEBUG
	DEBUGVAL 0,15,BX,"RETURNED JINGLE POSITION: "
	INC	CS:JINGLEORDER
	DEBUGVAL 0,16,CS:JINGLEORDER,"JINGLE ORDER NO: "
ENDIF
	mov	bx,bp
	cmp	bl,0
	jg	noplayjingle
	CMP	AL,62
	JE	NOPLAYJINGLE
	MOV	LASTJINGLE,AL
NOPLAYJINGLE:
	CLC
	RETN
NOTNOW_ASHOLE:
	pop	ax	;trash
	STC
	RETN
JINGLEORDER DW 0
DOPLAYJINGLE ENDP


;******************************************************************************

DOADVANCE PROC NEAR	;FN: LIGHT NEXT LIGHT IN LIST
			;INPUT: SI=OFFSET TO THE LIST
			;	LIST STRUC: DB COUNTER,LNO1,LNO2,...,-1
			;OUTPUT: -C- IF END OF LIST REACHED
	PUSH	SI
	LODSB				;GET LIST COUNTER
	NIL	AH
	ADD	SI,AX
	LODSB				;AL=LIGHT TO LIGHTED
	PUSH	SI
	LIGHTON	AL			;TURN ON CORRECT LIGHT
	POP	SI
	LODSB				;AL=NEXT LIGHT, IF -1: END OF LIST
	CMP	AL,-1
	JE	REACHED_END_OF_LIST
	POP	SI
	INC	BYTE PTR [SI]		;INC LIST COUNTER
	CLC
	RETN
REACHED_END_OF_LIST:
	POP	SI
	MOV	BYTE PTR [SI],0		;RESET LIST COUNTER
	STC
	RETN
DOADVANCE ENDP

CHECK_TARGETS PROC NEAR
	CMP	TILTFLAG,TRUE
	JE	QCT
	CMP	EXAHITX,0
	JNZ	ITSAHIT
	CMP	EXAHITY,0
	JZ	NOHIT
ITSAHIT:
	MOV	CX,EXAHITX
	MOV	DX,EXAHITY
	ADD	DX,SCREENPOSY	;CP!?	DET SKA NOG VA Sè HéR
	MOV	EXAHITX,0
	MOV	EXAHITY,0
	MOV	SI,OFFSET ZONLISTA_L
	CMP	BALLHIGH,TRUE
	JE	NOHIT
	JMP	STARTITHERE3
NASTAAREA3:
	POP	SI
	ADD	SI,5*2
STARTITHERE3:
	PUSH	SI
	LODSW
	OR	AX,AX
	JZ	NOMOREAREAS3
	CMP	CX,AX
	JB	NASTAAREA3
	LODSW
	CMP	DX,AX
	JB	NASTAAREA3
	LODSW
	CMP	CX,AX
	JA	NASTAAREA3
	LODSW
	CMP	DX,AX
	JA	NASTAAREA3
	LODSW
	CALL	AX
NOMOREAREAS3:
	POP	SI
NOHit:
QCT:	RETN
CHECK_TARGETS ENDP

CHECK_LEVELS PROC NEAR
	MOV	CX,SC_X
	ADD	CX,BALLH/2
	MOV	DX,SC_Y
	ADD	DX,BALLH/2
	ADD	DX,SCREENPOSY	;CP!?	DET SKA NOG VA Sè HéR
	MOV	SI,OFFSET LEVEL1LISTA
	CMP	BALLHIGH,TRUE
	JE	BALLHGH2
	MOV	SI,OFFSET LEVEL2LISTA
BALLHGH2:
	JMP	STARTITHERE2
NASTAAREA2:
	POP	SI
	ADD	SI,4*2
STARTITHERE2:
	PUSH	SI
	LODSW
	CMP	AX,-1
	JE	NOMOREAREAS2
	CMP	CX,AX
	JB	NASTAAREA2
	LODSW
	CMP	DX,AX
	JB	NASTAAREA2
	LODSW
	CMP	CX,AX
	JA	NASTAAREA2
	LODSW
	CMP	DX,AX
	JA	NASTAAREA2
	NOT	BALLHIGH
NOMOREAREAS2:
	POP	SI
	RETN
CHECK_LEVELS ENDP


CHECK_AREAS PROC NEAR
	MOV	CX,SC_X
	ADD	CX,BALLH/2
	MOV	DX,SC_Y
	ADD	DX,BALLH/2
	ADD	DX,SCREENPOSY	;CP!?	DET SKA NOG VA Sè HéR
	MOV	SI,OFFSET AREALISTA_U
	CMP	BALLHIGH,TRUE
	JE	BALLHGH
	MOV	SI,OFFSET AREALISTA_L
BALLHGH:
	CMP	TILTFLAG,TRUE
	JNE	NOT_TILT_AREOR
	MOV	SI,OFFSET AREALISTA_U_T
	CMP	BALLHIGH,TRUE
	JE	BALLHGH3
	MOV	SI,OFFSET AREALISTA_L_T
BALLHGH3:
NOT_TILT_AREOR:
	JMP	STARTITHERE
NASTAAREA:
	POP	SI
	ADD	SI,5*2
STARTITHERE:
	PUSH	SI
	LODSW
	OR	AX,AX
	JZ	NOMOREAREAS
	CMP	CX,AX
	JB	NASTAAREA
	LODSW
	CMP	DX,AX
	JB	NASTAAREA
	LODSW
	CMP	CX,AX
	JA	NASTAAREA
	LODSW
	CMP	DX,AX
	JA	NASTAAREA
	LODSW
	CMP	LASTCHECK,AX
	JE	CALLREADY
	MOV	LASTCHECK,AX
	CALL	AX
	MOVE	LASTAREA,LASTCHECK
	JMP	CALLREADY
NOMOREAREAS:
	MOV	LASTCHECK,0
CALLREADY:
	POP	SI
	RETN
CHECK_AREAS ENDP

SPRINGIT:	;THIS not IS A TASK anymore, not TRIGGED BY KEYINT
	CMP	DNPRESSED,FALSE
	JE	NO_WAY
	CMP	SPRINGPOS,(SPRINGH-1)*2
	JAE	NO_WAY
	INC	SPRINGPOS
	CALL	PUTSPRING
NO_WAY:	RETN

SPRINGSTEEN:	;BRUCE!
	CMP	MOUSEINSTALLED,TRUE
	JNE	NOT_OKIDOK
	MOV	AX,03H
	INT	33H
	CMP	DL,MOUSEMIDDLE
	JB	MOVED_UP
	JNA	DIDNT_MOVE

	CMP	SPRINGPOS,(SPRINGH-1)*2	
	JAE	_4GETIT
	INC	SPRINGPOS
	JMP	SPRINGPOS_CALCED
MOVED_UP:
	CMP	SPRINGPOS,0
	JZ	_4GETIT
	DEC	SPRINGPOS
SPRINGPOS_CALCED:
	PUSH	BX
	CALL	PUTSPRING
	MOV	CX,0
	MOV	DX,MOUSEMIDDLE
	MOV	AX,04H
	INT	33H		;SET MOUSE YPOS TO MOUSEMIDDLE
	POP	BX
DIDNT_MOVE:
_4GETIT:
	TEST	BL,1
	JZ	NOSPRINGUP
	MOV	SPRINGTASK,OFFSET SPRINGUP
NOSPRINGUP:
NOT_OKIDOK:
	CALL	SPRINGIT
	RETN

springup:
	mov	Cl,springpos
	xor	Ch,Ch
	JCXZ	NOUP
	CMP	SPRING_VALID,FALSE
	JE	DOUP2
	cmp	hi_res,true
	je	nilsbedrupp
	mov	ax,(-5000/15)/2*TT/NN
	jmp	kukenkarl
nilsbedrupp:
	mov	ax,(-5000/15)/2
kukenkarl:
	imul	Cx
	mov	bp,ax
	mov	ax,slump_countern
	and	ax,255
	sub	bp,ax
	CMP	MAKE_BAD,TRUE
	JE	BADDAREN
	SETBALLSPEED 0,bp	;cp!
BADDAREN:
	mova	rotation,slump_countern
	and	rotation,15	;cp!?
DOUP2:	
	MOV	AL,SPRINGPOS
	XOR	AH,AH
	SHL	AX,6
	MOV	BL,(SPRINGH-1)*2
	DIV	BL		;AL=CALCULATED SPRING SOUND VOLUME
	soundeffect sfjader,AL
	mov	springpos,0
	call	putspring
	CMP	MOUSEINSTALLED,TRUE
	JNE	NO_M_INST
	MOV	AX,04H
	NIL	CX
	MOV	DX,MOUSEMIDDLE
	INT	33H		;SET MOUSE YPOS TILL MOUSEMIDDLE
NO_M_INST:
NOUP:
	MOV	SPRINGTASK,OFFSET SPRINGSTEEN		;INTE PRINCE
	retn

INIT_MOUSE:
	MOVE	ES,0
	CMP	WORD PTR ES:[33H*4],0
	JNE	OKIDOK
	CMP	WORD PTR ES:[33H*4+2],0
	JE	NOT_OKIDOKI
OKIDOK:	MOV	MOUSEINSTALLED,TRUE
	JMP	OVERHOPP
NOT_OKIDOKI:
	MOV	MOUSEINSTALLED,FALSE
OVERHOPP:
	MOVE	ES,0A000H
	MOV	AX,0
	INT	33H			;RESET MOUSEDRIVER/CHECK IF MOUSE INSTALLED
	CMP	AX,0
	JE	NOMOUSEINSTALLED
	MOV	AX,08H
	MOV	CX,0			;MIN MOUSE POS
	MOV	DX,MOUSETOTAL		;MAX MOUSE POS
	INT	33H
	MOV	AX,0FH
	MOV	CX,8
	MOV	DX,16*4
	INT	33H			;SET MICKEY TO PIXEL RATIO
	RETN
NOMOUSEINSTALLED:
	MOV	MOUSEINSTALLED,FALSE
	RETN

GATE_STRUC STRUC
	G_POS		DW ?
	G_NEG		DW ?
	G_WHERE		DW ?
	G_WIDTH		DW ?
	G_HEIGHT	DW ?
ENDS

MOVE_MASK_DATA PROC NEAR ;FN: OPENS OR CLOSES GATES
			 ;INPUT: DS:SI=SOURCE, ES:DI=DEST
			 ;       DX=WIDTH, CX=HEIGHT
NEXTLINE:
	PUSH	CX
	MOV	CX,DX
	PUSH	DI
	REP	MOVSB
	POP	DI
	ADD	DI,40
	POP	CX
	LOOP	NEXTLINE
	RETN
MOVE_MASK_DATA ENDP
MOVE_MASK_DATA_b PROC NEAR ;FN: OPENS OR CLOSES GATES
			 ;INPUT: DS:SI=SOURCE, ES:DI=DEST
			 ;       DX=WIDTH, CX=HEIGHT
NEXTLINE3:
	PUSH	CX
	MOV	CX,DX
	PUSH	DI
	REP	MOVSB
	add	si,dx
	add	si,dx
	POP	DI
	ADD	DI,40
	POP	CX
	LOOP	NEXTLINE3
	RETN
MOVE_MASK_DATA_b ENDP

DO_PUT_GATE_POS_HIGH:	;INPUT BX=OFFS GATE
	MOV	SI,[BX].G_POS
	MOV	DI,[BX].G_WHERE
	MOVE	ES,MASK2_2
	MOV	DX,[BX].G_WIDTH
	MOV	CX,[BX].G_HEIGHT
	ADD	SI,DX
	CALL	MOVE_MASK_DATA_B
	RETN

DO_PUT_GATE_NEG_HIGH:	;INPUT BX=OFFS GATE
	MOV	SI,[BX].G_NEG
	MOV	DI,[BX].G_WHERE
	MOVE	ES,MASK2_2
	MOV	DX,[BX].G_WIDTH
	MOV	CX,[BX].G_HEIGHT
	ADD	SI,DX
	CALL	MOVE_MASK_DATA_B
	RETN

DO_PUT_GATE_POS_LOW:	;INPUT BX=OFFS GATE
	MOV	SI,[BX].G_POS
	MOV	DI,[BX].G_WHERE
	MOVE	ES,MASK1_2
	MOV	DX,[BX].G_WIDTH
	MOV	CX,[BX].G_HEIGHT
	ADD	SI,DX
	CALL	MOVE_MASK_DATA_B
	RETN

DO_PUT_GATE_NEG_LOW:	;INPUT BX=OFFS GATE
	MOV	SI,[BX].G_NEG
	MOV	DI,[BX].G_WHERE
	MOVE	ES,MASK1_2
	MOV	DX,[BX].G_WIDTH
	MOV	CX,[BX].G_HEIGHT
	ADD	SI,DX
	CALL	MOVE_MASK_DATA_B
	RETN

INIT_INTS PROC NEAR
	MOV	AX,11				;INIT VBLANK INT
	MOV	BL,100
	MOV	DX,OFFSET VBLANK_INT
	MOVE	ES,CS
	INT	66H

	MOV	CX,LATE_INTERRUPT_RASTER_LO*2
	CMP	HI_RES,TRUE
	JNE	NOTHIRES1
	MOV	CX,LATE_INTERRUPT_RASTER_HI*2
NOTHIRES1:
	MOV	DX,OFFSET LATE_RASTER_INTERRUPT
	MOV	BL,200
	MOVE	ES,CS
	MOV	AX,12				;INIT RASTER INT
	INT	66H
	RETN
INIT_INTS ENDP

GO_GAME_MODE PROC NEAR	;TURNS OFF THE DEMO MODE AND STARTS THE GAME
	MOV	DEMOMODE,FALSE
	RETN
GO_GAME_MODE ENDP

GO_DEMO_MODE PROC NEAR	;TURNS ON THE DEMO MODE
	MOV	CS:ALREADY_QUITTING,FALSE
	MOV	CS:KEYBOARD_ENABLED,TRUE
	MOV	DEMOMODE,TRUE
	RETN
GO_DEMO_MODE ENDP


VBLANK_INT_DEMO:
	MOVE	DS,DATA
	SAVEGFXREGS

	CALL	FLASH
	CALL	MATRIX_BLINKOR
	
IF MARGIT
SETMARG 14
ENDIF
	
	cmp	time_left,false
	je	skip_matrixD		;no time left! Skip it!!
;	mov	time_left,false		;ok, time was left last time!

	MOV	AL,CS:INSIDE_MATRIX
	MOV	CS:INSIDE_MATRIX,TRUE
	CMP	AL,TRUE
	JE	SKIP_MATRIXD
	CALL	DO_THE_DOTMATRIX	;updatera dÜ matrixen!
	MOV	CS:INSIDE_MATRIX,FALSE
skip_matrixD:
	CALL	DOLIGHTS

IF MARGIT
RESTOREMARG
ENDIF
IF MARGIT
SETMARG 0
ENDIF

	RESTOREGFXREGS
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF
	

LATE_RASTER_INTERRUPT_DEMO:
	MOVE	DS,DATA
	CMP	INTERRUPTS_ON,TRUE
	JE	LRINTOKD
	MOV	AX,0 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER FèR HAN KLARA
	RETF					;RET
LRINTOKD:
	SAVEGFXREGS
	MOV	AX,BANH-(SH_LO-SPLH)
	CMP	HI_RES,TRUE
	JNE	NOTHIRES7
	MOV	AX,BANH-(SH_HI-SPLH)
NOTHIRES7:
	CMP	SCREENFORCE,AX
	JL	NOT_BOTTOM
	MOV	CARMEN,-1
NOT_BOTTOM:
	CMP	SCREENFORCE,0
	JG	NOT_TOP
	MOV	CARMEN,1
NOT_TOP:
	MOV	AX,CARMEN
	ADD	SCREENFORCE,AX
	CALL	SETSCREENSTART

	CMP	F1F8_CODE,0		;TAR HAND OM F1F8_CODE I DEMOMODE
	JZ	NOF1F8
	MOV	AL,F1F8_CODE
	MOV	F1F8_CODE,0
	SUB	AL,3BH-1	;3BH=CODE FOR F1
	MOV	PLAYERS,AL
	ADD	AL,'0'+7
	MOV	NO_OF_PLAYERS_TEXT[8],AL
	MOV	BX,OFFSET first_no_of_playersTS
	CALL	DO_MATRIX
	SOUNDEFFECT S_ADDPLAYER2,0

	MOV	SCREENFORCE,-1

	CALL	GO_GAME_MODE		;TO GAME FROM DEMO

	CALL	WHEN_NEW_GAME_RESET
	CALL	WHEN_NEW_GAME_RESET_TABLE
	
	CALL	GAME_MUSIC

	CALL	NEW_BALL

	MOV	ADDPLAYERS,FALSE
	ADDTASK	ALLOW_ADDPL	;TILLÜT INGA NYA ADDS FîRNS OM 30 SYNCAR

NOF1F8:
	RESTOREGFXREGS
	MOV	AX,12345 ;MEDDELA TILL MUSIKRUTINEN ATT KRISER KLARAR JAG
	RETF

ALLOW_ADDPL:
	WAITSYNCS 15
	MOV	ADDPLAYERS,TRUE
	SUICIDE

SNART_NEW_BALL:
	WAITSYNCS 30
	CALL	NEW_BALL_PART_TWO
	SUICIDE

;******************************************************************************


;*************************** Updatera alla spelares pstruc!!!! ***********
UPDATE_P_STRUC_4_ALL_PLAYERS:
	MOV	BX,0
	MOV	CX,8
THE_PLAYERS:
	PUSH	BX CX
	MOV	AX,SIZE PLAYER_STRUC
	MUL	BX
	MOV	BX,AX	;BX=INDEX TO CORRECT PLAYER DATA IN PLAYER_AREA
	CALL	VARS_2_P_STRUC_2
	POP	CX BX
	INC	BX
	LOOP	THE_PLAYERS
	RETN


FLASH	PROC NEAR
	MOVE	DS,DATA
	MOV	SI,OFFSET FLASHLIST
	MOVE	ES,DS
FLASHAGAIN:
	CMP	WORD PTR DS:[SI],-1
	JZ	NOMOREFLASHING
	PUSH	SI
	CALL	DOTHISFLASH
	POP	SI
	ADD	SI,10
	JMP	FLASHAGAIN
NOMOREFLASHING:
	RETN
FLASH	ENDP

DOTHISFLASH PROC NEAR	;INPUT:SI
	MOV	DI,SI
	LODSW
	INC	AX
	STOSW
	MOV	BP,AX
	LODSW
	MOV	DI,AX
	LODSW
	CMP	BP,AX
	JE	TURNITOFF
	LODSW
	CMP	BP,AX
	JE	TURNITON
TURNBACK:
	RETN
TURNITOFF:
	LODSW
	LODSW
	LOFF	AL
	JMP	TURNBACK
TURNITON:
	LODSW
	PUSH	SI
	PUSH	DI
	PUSH	ES
	LON	AL
	POP	ES
	POP	AX
	POP	DI
	SUB	DI,10
	STOSW
	JMP	TURNBACK
DOTHISFLASH ENDP

RECALCFLASHLIST PROC NEAR
	MOVE	ES,DS
	MOV	SI,OFFSET FLASHLIST
NEXTPOSTEN:
	CMP	WORD PTR DS:[SI],-1
	JE	NOMOREFPOSTS
	PUSH	SI
	MOV	DI,SI
	MOVSW		;CNT
	LODSW
	STOSW		;1ST
	MOV	BX,AX
	LODSW
	ADD	AX,BX
	MOV	BX,AX
	STOSW		;OFF
	LODSW
	ADD	AX,BX
	STOSW		;ON
	POP	SI
	ADD	SI,10
	JMP	NEXTPOSTEN
NOMOREFPOSTS:
	RETN
RECALCFLASHLIST ENDP

INIT_SOUND PROC NEAR
	OPENFILE SOUNDCFG
	JC	NOSOUNDCFG
if musikkaos
else
	READFILE BX,13,DRV	;get name of selected sound driver
endif
	CLOSEFILE BX

	MOV	AX,DS
	MOV	ES,AX
	MOV	AX,4B00H	;fn 4b = load and execute exe file
	MOV	BX,OFFSET PARMS
	MOV	DX,OFFSET DRV
	INT	21H		;LOAD DRIVER
	
	MOV	AL,19
	MOV	DX,OFFSET JINGLE_HANDLER
	MOVE	ES,CS
	INT	66H

	MOV	AX,18		;fn 18
	MOV	DX,OFFSET MODUL
	INT	66H		;LOAD MODULE
	IF_ERROR 1,outofmemory
	IF_ERROR 3,cantfindmod
	IF_ERROR 4,errorloadingmod
	
	SLACKDRIVELED	
	CLC	
	RETN
NOSOUNDCFG:
	MOV	AX,3
	INT	10H
	PRINTMESS "Can't find sound configurations file."
	STC
	RETN
ENDP
INIT_HIGHS PROC NEAR			;READ HIGH-SCORES
	OPENFILE HI_SCORE_FILE
	JC	NOFILE
	READFILE BX,16*4,HI_SCORE_LIST
	CLOSEFILE BX
NOFILE:	RETN
INIT_HIGHS ENDP
SAVE_HIGHS PROC NEAR			;WRITE HIGH-SCORES
	CREATEFILE HI_SCORE_FILE
	JC	NOFILE2
	WRITEFILE BX,16*4,HI_SCORE_LIST
	CLOSEFILE BX
NOFILE2:RETN
SAVE_HIGHS ENDP
INIT_MATRIX PROC NEAR
	PUSHA
	MOV	DOTRUT,OFFSET NODOT
	MOV	SISA,0
	MOV	BX,OFFSET CLEARTS
	CALL	DO_MATRIX		;RENSA UPP LITE!!

	UPDAT_SCORE
	POPA
	RETN
INIT_MATRIX ENDP
set_360x350:
		mov	ax,13h
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	dx,3C4h
		mov	al,4
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 4, memory mode select
		mov	dx,3C5h
		mov	al,6
		out	dx,al			; port 3C5h, EGA sequencr func
		mov	dx,3C4h
		mov	al,2
		out	dx,al			; port 3C4h, EGA sequencr index
						;  al = 2, map mask register
		mov	dx,3C5h
		mov	al,0Fh
		out	dx,al			; port 3C5h, EGA sequencr func

		mov	ax,0A000h
		mov	es,ax
		mov	cx,0ffffh
		mov	al,0
		mov	di,0
		cld
		rep	stosb

		mov	dx,3C2h
		mov	al,0A7H ;0E7h
		out	dx,al			; port 3C2h, EGA misl out reg
		mov	dx,3D4h
		mov	al,11h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 11h, light pen low
		mov	dx,3D5h
		in	al,dx			; port 3D5h, CGA/EGA indxd data
		and	al,7
		push	ax
		mov	dx,3D4h
		mov	al,11h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 11h, light pen low
		pop	ax
		mov	dx,3D5h
		out	dx,al			; port 3D5h, CGA/EGA indxd data

		mov	dx,3D4h
		mov	al,0
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 0, horiz char total
		mov	dx,3D5h
		mov	al,6Bh			; 'k'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,1
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 1, horiz char display
		mov	dx,3D5h
		mov	al,59h			; 'Y'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,2
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 2, horz sync position
		mov	dx,3D5h
		mov	al,5Ah			; 'Z'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,3
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 3, horiz sync width
		mov	dx,3D5h
		mov	al,8Eh
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,4
		out	dx,al			; port 3D4h, CGA/EGA reg index

		mov	dx,3D5h
		mov	al,5Eh-CENTSCREEN		; '^'
		out	dx,al			; port 3D5h, CGA/EGA indxd data

		mov	dx,3D4h
		mov	al,5
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 5, vert total adjust
		mov	dx,3D5h
		mov	al,8Ah-CENTSCREEN
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,6
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 6, vert char displayd
		mov	dx,3D5h
		mov	al,0BFH ;0Dh ;VERTICAL TOTAL
		out	dx,al			; port 3D5h, CGA/EGA indxd data

		mov	dx,3D4h
		mov	al,7
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 7, vert sync position
		mov	dx,3D5h
		mov	al,1FH ;3Eh			; '>'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,9
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 9, max raster address
		mov	dx,3D5h
		mov	al,40h			; '@'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,10h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 10h, light pen high
		mov	dx,3D5h
		mov	al,83H ;0EAh
		out	dx,al			; port 3D5h, CGA/EGA indxd data

		mov	dx,3D4h
		mov	al,12h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 12h, vert end scan line
		mov	dx,3D5h
		mov	al,05DH ;0DFh
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		
		mov	dx,3D4h
		mov	al,13h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 13h, offset line width
		mov	dx,3D5h
		mov	al,BPL/2 ;2Dh			; '-'
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		
		mov	dx,3D4h
		mov	al,14h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 14h, underline scan lin
		mov	dx,3D5h
		mov	al,0FH ;0
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,15h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 15h, vert start blankng
		mov	dx,3D5h
		mov	al,063H ;E7h
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,16h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 16h, vert end blanking
		mov	dx,3D5h
		mov	al,0BAH ;6
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		mov	dx,3D4h
		mov	al,17h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 17h, mode control
		mov	dx,3D5h
		mov	al,0E3h
		out	dx,al			; port 3D5h, CGA/EGA indxd data

	MOV	DX,3D4H			;SET HORIZ END
	MOV	AL,01H
	MOV	AH,80-1			;(DET MAN VILL HA GENOM 4)
	OUT	DX,AX

		mov	dx,3D4h
		mov	al,11h
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 11h, light pen low
		mov	dx,3D5h
		mov	al,0A5H ;0ACh
		out	dx,al			; port 3D5h, CGA/EGA indxd data

		
		retn

INIT_GFX PROC NEAR
	CALL	SET_MCGAB
	CALL	SET240
IF HZ50	
	call	set50hz
ENDIF	

	MOVE	DS,DATA
	CMP	HI_RES,TRUE
	JNE	NOTHIRES13
	CALL	SET_360X350
NOTHIRES13:

	CALL	SETSCREENSTART
IF RES600
ELSE
	CALL	SETSPLIT
ENDIF
	
	mov	bx,0	
	call	setpal	;slÑck skÑrmen SLéCK
	
	SET_ES	0A000H
	MOV	AX,STAGE1_1
	MOV	ES,AX
	MOV	AX,0		;xpos
	MOV	BX,0+SPLH	;ypos
	MOV	CX,SW
	MOV	BP,10b		;bp=0: sÑtt inte paletten
	MOV	DX,0		;es:dx=adress till bild
	CALL	UNPKLBM
	MOV	AX,STAGE1_2
	MOV	ES,AX
	MOV	AX,0		;xpos
	MOV	BX,144+SPLH		;ypos
	MOV	CX,SW
	MOV	BP,10b		;bp=0: sÑtt inte paletten
	MOV	DX,0		;es:dx=adress till bild
	CALL	UNPKLBM
	MOV	AX,STAGE1_3
	MOV	ES,AX
	MOV	AX,0		;xpos
	MOV	BX,288+SPLH		;ypos
	MOV	CX,SW
	MOV	BP,10b		;bp=0: sÑtt inte paletten
	MOV	DX,0		;es:dx=adress till bild
	CALL	UNPKLBM
	MOV	AX,STAGE1_4
	MOV	ES,AX
	MOV	AX,0		;xpos
	MOV	BX,432+SPLH		;ypos
	MOV	CX,SW
IFDEF HALFBRIGHT
	MOV	BP,110b		;bp=111: sÑtt paletten, HALFBRIGHT
ELSE
	MOV	BP,10b		;bp=11: sÑtt paletten, NO HALFBRIGHT
ENDIF

	MOV	DX,0		;es:dx=adress till bild
	CALL	UNPKLBM
	
	mov	si,dx
	mova	ds,stage1_4
	mov	di,offset CS:PALLE ;temporÑr lagringsplats
	mova	es,CS
	mov	cx,768
	rep	movsb
	mova	ds,data
		
COMMENT\
	MOV	AX,1000H
	MOV	BL,10H
	MOV	BH,1
	INT	10H
 \
	RETN
	
INIT_SPRING:
	CALL	PUTSPRINGINGFX
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	set_es	0a000h
	mov	al,00
	mov	di,(splh+banh)*bpl
	mov	cx,bpl*4
	rep	stosb
	call	putspring
	RETN
INIT_GFX ENDP
PUTSPRINGINGFX PROC NEAR
	PUSH	DS
	MOVA	DS,SPRINGSEG
	MOVA	ES,0A000H
	MOV	SI,0
	MOV	DI,SPRINGSOURCEADR
	MOV	DX,3C4H
	MOV	AL,2
	MOV	CX,23
SROW:	PUSH	CX
	MOV	AH,10001B
	MOV	CX,10
SPR:	PUSH	CX
	OUT	DX,AX
	MOVSB
	ROL	AH,1
	JC	NEWBYTE
	DEC	DI
NEWBYTE:POP	CX
	LOOP	SPR
	INC	DI
	POP	CX
	LOOP	SROW
	POP	DS
	RETN
	ENDP
putspring proc near
	mov	al,springpos
	shr	al,1
	sub	al,3
	mov	realpos,al
	mov	si,springsourceadr
	jge	goforit
	mov	realpos,0
	mov	bl,-3
	imul	bl
	add	si,ax
goforit:
		
	push	ds
	mov	ax,0a000h
	mov	es,ax
	mov	al,realpos
	mov	bl,bpl
	mul	bl
	add	ax,springdestadr
	mov	di,ax
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	
	cmp	realpos,0
	jz	noclear
	sub	di,bpl
	XOR	AX,AX
	mov	es:[di],ax
	mov	ax,0302h
	out	dx,ax
	XOR	AL,AL
	mov	es:[di+2],al			
	mov	ax,0f02h
	out	dx,ax
	add	di,bpl
noclear:	
	MOV	DX,3CEH
	mov	Ax,4105h
	out	dx,ax
	mov	cx,springh
	sub	cl,realpos
	mov	ax,es
	mov	ds,ax
	
	push	cx di SI
ritaspring:
	movsb
	movsb
	INC	SI
	add	di,bpl-2
	loop	ritaspring
	pop	SI di cx
	mov	dx,3c4h
	mov	ax,302h
	out	dx,ax
	add	di,2
ritaspring2:
	ADD	SI,2
	movsb
	add	di,bpl-1
	loop	ritaspring2
	
	mov	dx,3ceh
	mov	ax,4005h
	out	dx,ax
	
	pop	ds
	retn
putspring endp
Set50Hz         proc near
                mov     dx,3d4h
                mov     ax,0011h
                out     dx,ax           ;unprotect 0-7 in crtc!

                mov     ax,07006h
                out     dx,ax
                mov     ax,0ba07h       ;3e
                out     dx,ax
                mov     ax,02510h       ;ea
                out     dx,ax
                mov     ax,0011h       ;let be!
                out     dx,ax
                mov     ax,0ff12h       ;
                out     dx,ax
                mov     ax,0ff15h       ;b7
                out     dx,ax
                mov     ax,01116h ;28
                out     dx,ax
                mov     dx,3c4h
                mov     ax,0100h        ; synchronous reset
                out     dx,ax           ;
                mov     dx,3c2h         ;
                mov     al,0e3h         ; use 25 mHz dot clock, 480 lines res.
                out     dx,al           ;
                mov     dx,3c4h         ;
                mov     ax,0300h        ; restart sequencer
                out     dx,ax           ; running again
		retn
endp
setsplit PROC NEAR
vga:					;bit 0-8
	MOV	DX,3D4H
	MOV	AL,11H
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,127
	OUT	DX,AL		;OSKRIVSKYDDA
					;bit 0-8
	mov dx,3d4h
	mov al,18h

	MOV	SPLITLINE,(SH_LO-33)*2
	CMP	HI_RES,TRUE
	JNE	NOTHIRES12
	MOV	SPLITLINE,SH_HI-SPLH
NOTHIRES12:

	mov ah,BYTE PTR SPLITLINE
	DEC AH
	out dx,ax
					;bit 9

	mov al,BYTE PTR SPLITLINE+1
	and al,1
	shL al,4
	mov ah,al
	
	mov al,07
	out dx,al
	inc dx
	in al,dx
	dec dx
	and al,11101111b
	or al,ah
	mov ah,al
	mov al,7
	out dx,ax
					;bit 10
	mov dx,3d4h
	mov al,09
	out dx,al
	inc dx
	in al,dx
	dec dx
	and al,10111111b
	mov ah,al
	mov al,09
	out dx,ax
					;All 10 bits set	
	ret

SETSPLIT ENDP
BIOSDATA DB 64 DUP(0)
SET_MCGAB PROC NEAR
	SET_ES	CS
	MOV	AX,13H
IF	HIRES	
FINDMODE:
	PUSH	AX
	INT	10H
	MOV	AH,1BH
	MOV	BX,0
	MOV	DI,OFFSET CS:BIOSDATA
	INT	10H
	POP	AX
	CMP	WORD PTR BIOSDATA[27H],256
	JNE	NOTTHISMODE
IF	RES600
	CMP	BYTE PTR BIOSDATA[2AH],5	;600 LINJER
ELSE		
	CMP	BYTE PTR BIOSDATA[2AH],3	;480 LINJER
ENDIF	
	JE	MODEFOUND
NOTTHISMODE:	
	INC	AX
	JMP	FINDMODE
MODEFOUND:
ELSE
	INT	10H
ENDIF
	MOV	BX,SW	;CALC BX (SET LINE LENGTH)
	SHR	BX,3
	MOV	CX,320	;CALC CX (HORIZ END)
	SHR	CX,2
	DEC	CX
	MOV	DX,3D4H			;UNLOCK
	MOV	AL,11H
	MOV	AH,0
	OUT	DX,AX

	MOV	DX,3D4H			;SET HORIZ END
	MOV	AL,01H
	MOV	AH,CL			;(DET MAN VILL HA GENOM 4)
	OUT	DX,AX

	MOV	DX,3D4H			;SET LINE LENGTH (I MINNESUPPBYGGNADEN)
	MOV	AL,13H
	MOV	AH,BL
	OUT	DX,AX

	MOV	DX,3C4H			;SET MCGAB (NO CHAIN FOUR, USE 256KB)
	MOV	AL,04H
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,11110110B
	OUT	DX,AL
if hires
IF RES600
else
	JMP NO_1417
ENDIF
ENDIF
	MOV	DX,3D4H			;COUNT BY FOUR AND NO DOUBLE WORD MODE
	MOV	AL,14H
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,10111111B		;10011111B SVARAR MOT KOMMENTAREN
	OUT	DX,AL
	MOV	DX,3D4H			;MODE CONTROL (STANDARD ADRESSING MODE)
	MOV	AL,17H
	MOV	AH,11100011B
	OUT	DX,AX	
NO_1417:
if hires
ELSE
	MOV	DX,3CCH
	IN	AL,DX
	MOV	DX,3C2H
	OR	AL,11000000B
	OUT	DX,AL			;sÑtt 240-linjers skÑrmhîjd
endif
	
	RETN
SET_MCGAB ENDP
SET240	PROC NEAR
                mov    dx,03d4h
                mov    al,11h
                out    dx,al
                inc    dx
                in     al,dx
                and    al,7fh
                out    dx,al
                dec    dx
                cld
IF RES600		
                mov    si,offset xparabl
                mov    cx,1
ELSE
		MOV	SI,OFFSET XPARABL2
		MOV	CX,10		
ENDIF
xvploop:
                mov    ax,cs:[si]
                add    si,02h
                out    dx,ax
                jmp     $+2

                loop   xvploop
IF HIRES
	MOV	DX,3D4H
	MOV	AL,9
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,01111111B
	OUT	DX,AL
ENDIF

		RETN
		
xparabl  db 14h,00h

xparabl2  db 06h,0Dh ,07h,03eh ,09h,40H+80H,10h,0EAh ,11h,0ch ,12h,0dfh ,14h,00h
        db 15h,0eah,016h,06h,17h,0e3h

SET240	ENDP
READFLIPPIX PROC NEAR	;AX=X ;BX=Y ;CX=FLIP NO ;ES=SEGPTR TO FLIPS
	PUSH	AX
	MOV	AX,FLIPSTORLEK
	MUL	CX
	MOV	SI,AX		;SI=ADR TO FLIPPER AREA
	MOV	AX,FLIPLINESIZE
	ADD	AX,AX
	ADD	AX,FLIPLINESIZE
	MUL	BX
	ADD	SI,AX		;SI=ADR TO CORRECT LINE
	POP	AX
	MOV	CL,AL
	SHR	AX,3
	ADD	SI,AX		;SI=ADR TO BYTE CONTAINING FLIPPER PIXEL
	AND	CX,111B
	MOV	DL,128
	JCXZ	NOROR
	SHR	DL,CL		;DL=BITMASK IN BYTE
NOROR:	
	XOR	AL,AL
	TEST	BYTE PTR ES:[SI],DL
	JZ	NOTB0
	OR	AL,1
NOTB0:
	PUSH	SI
	ADD	SI,FLIPLINESIZE
	TEST	BYTE PTR ES:[SI],DL	
	POP	SI
	JZ	NOTB1
	OR	AL,10B
NOTB1:
	PUSH	SI
	ADD	SI,FLIPLINESIZE
	ADD	SI,FLIPLINESIZE
	TEST	BYTE PTR ES:[SI],DL
	POP	SI
	JZ	NOTB2
	OR	AL,100B
NOTB2:
	RETN
ENDP

PUTFLIPPIX PROC NEAR	;DI=SKéRM OFFSET ;AX,BX=X,Y ;DL=COLOR
	PUSH	ES
	MOV	CX,AX
	MOV	AL,BPL
	MUL	BL
	ADD	DI,AX
	MOV	AX,CX
	SHR	AX,2
	ADD	DI,AX
	AND	CX,11B
	MOV	AH,1
	JZ	NOSHL
	SHL	AH,CL	
NOSHL:	MOV	AL,2
	MOV	CL,DL
	MOV	DX,3C4H
	OUT	DX,AX
	SET_ES	0A000H
	MOV	ES:[DI],CL
	POP	ES
	RETN
ENDP
COPYFLIPBGR PROC NEAR	;SI=ADR TO SèS ;DI=ADR TO DEST
	PUSH	ES DS
	SET_ES	0A000H
	SET_DS	ES
	MOV	DX,3C4H
	MOV	AX,0F02H
	OUT	DX,AX
	MOV	DX,3CEH
	MOV	AX,4105H
	OUT	DX,AX
	MOV	CX,53
COPPYA:	PUSH	CX
	MOV	CX,20
	REP	MOVSB
	POP	CX
	ADD	DI,BPL-20
	ADD	SI,BPL-20
	LOOP	COPPYA
	MOV	AX,4005H
	OUT	DX,AX

	POP	DS ES
	RETN
ENDP
CMPFLIPBOX PROC NEAR	;DI=ADR TO NEW FLIPPER BOX ;BP=OFFSET FROM NEW TO OLD
			;DS:SI=ADR TO ADR-AREA
	MOV	CS:DIFCNT,0
	MOV	CS:ORGDI,DI
	PUSH	DS SI
	SET_DS	DATAFLIP
	SET_ES	0A000H
	MOV	DX,3C4H
	MOV	AX,0F02H
	OUT	DX,AX
	MOV	DX,3CEH
	MOV	AX,4105H
	OUT	DX,AX
	MOV	AX,4
	MOV	CX,53
CMPR:	PUSH	CX
	MOV	CX,16
CHECK4:	
	OUT	DX,AX
	MOV	BL,ES:[DI+BP]
	CMP	BL,ES:[DI]
	JE	LIKA
	SUB	DI,CS:ORGDI
	MOV	DS:[SI+2*9],DI	;2*9 éR FôR DE WORD SOM TALAR OM 
	ADD	DI,CS:ORGDI	;HUR MYCKET SOM BEHôVS FôR ETT Sè STORT HOPP
	INC	CS:DIFCNT
	PUSH	DI
	CALL	LOOK4BLOCK
	JC	COULDNTFIND	
	MOV	DS:[SI+2*9+2],DI
	ADD	SI,4
	POP	DI
	JMP	SHORT NEXT4
COULDNTFIND:
	MOV	BL,ES:[DI]	;LADDA LèSKRETSARNA MED DET MAN VILL HA
	MOV	DI,CS:DIFPTR
	MOV	DS:[SI+2*9+2],DI
	ADD	SI,4
	STOSB
	MOV	CS:DIFPTR,DI
	POP	DI
	JMP	SHORT NEXT4
LIKA:
	INC	AH
	AND	AH,11B
	JNZ	CHECK4
NEXT4:	MOV	AH,0
	INC	DI
	LOOP	CHECK4
	ADD	DI,BPL-16
	POP	CX
	LOOP	CMPR
	POP	SI
	MOVE	DS:[SI],CS:DIFCNT
	POP	DS
	MOV	AX,4005H
	OUT	DX,AX
IF DEBUG
	mov	ax,cs:difcnt
	cmp	cs:maxdifcnt,ax
	jae	dumret
	mov	cs:maxdifcnt,ax
	DEBUGVAL 0,23,CS:maxDIFCNT,"max ANTAL 4-BLOCK SOM SKILLDE: "
ENDIF
	RETN
maxdifcnt dw 0
LOOK4BLOCK:
	PUSH	AX BX CX SI
	MOV	AX,4
	OUT	DX,AX
	MOV	BL,ES:[DI]
	INC	AH
	OUT	DX,AX
	MOV	BH,ES:[DI]
	INC	AH
	OUT	DX,AX
	MOV	CL,ES:[DI]
	INC	AH
	OUT	DX,AX
	MOV	CH,ES:[DI]

	move	ds,data
	MOV	SI,GFXADR_FOR_FLIP_ANIM_DATA
	move	ds,dataflip
	
	
NEXTBLOCK:
	XOR	AH,AH
	OUT	DX,AX
	CMP	BYTE PTR ES:[SI],BL
	JNE	NOTTHISBLOCK
	INC	AH
	OUT	DX,AX	
	CMP	BYTE PTR ES:[SI],BH
	JNE	NOTTHISBLOCK
	INC	AH
	OUT	DX,AX	
	CMP	BYTE PTR ES:[SI],CL
	JNE	NOTTHISBLOCK
	INC	AH
	OUT	DX,AX	
	CMP	BYTE PTR ES:[SI],CH
	JNE	NOTTHISBLOCK
THISBLOCK:	;!
	MOV	DI,SI
	CLC	
UNIQUE:	POP	SI CX BX AX
	RETN		
NOTTHISBLOCK:
	INC	SI
	CMP	SI,CS:DIFPTR
	JB	NEXTBLOCK
	STC
	JMP	UNIQUE	
DIFCNT	DW	?
DIFPTR	DW	GFXADR_FOR_FLIP_ANIM_DATA
ORGDI	DW	?
ENDP
DELTANIM PROC NEAR ;BX=ADR TO ADR-LISTA ;SI=ADR TO GFXDELTA ;DI=ADR FOR OUTPUT
	MOV	AX,DI
DODELTA:
	MOV	DI,[BX]
	ADD	DI,AX		;CP! KAN GôRAS INNAN
	MOV	SI,[BX+2]
	DB	26H		;ES:
	MOVSB
	ADD	BX,4
	LOOP	DODELTA
	RETN
ENDP	
INIT_SIN:
	MOV	SI,OFFSET SIN
	MOV	CX,2048+2048/4
XCHGSIN:LODSB
	MOV	AH,AL
	LODSB
	MOV	DS:[SI-2],AX
	LOOP	XCHGSIN
	RETN	
BREDDA_MASK:
	PUSH	DS
	ASSUME	DS:HIDDEN1
	SET_DS	HIDDEN1
	SET_ES	DS
	MOV	DI,OFFSET HIDDA
	MOV	SI,OFFSET HID1
	CALL	BREDDA
	SET_DS	HIDDEN2
	SET_ES	DS
	MOV	DI,OFFSET HIDDA2
	MOV	SI,OFFSET HID2
	CALL	BREDDA
	ASSUME	DS:DATA
	POP	DS
	RETN
BREDDA:	
	MOV	CX,576
LINE1:	PUSH	CX
	MOV	CX,40
	REP	MOVSB
	ADD	DI,2
	POP	CX
	LOOP	LINE1
	RETN
DUMRET:	RETN
pelle_2_bw proc near
	mov	si,offset cs:palle
	mov	ax,cs
	mov	es,ax
	mov	cx,256
	xor	bh,bh
bmw:	mov	bl,es:[si]
	mov	ax,bx
	mov	bl,es:[si+1]
	add	ax,bx
	mov	bl,es:[si+2]
	add	ax,bx
	mov	bl,3
	div	bl
	mov	es:[si],al
	mov	es:[si+1],al
	mov	es:[si+2],al
	add	si,3
	loop	bmw
	retn
pelle_2_bw endp

COLOR_2_BW PROC NEAR	;FN: CONV PALETTE AND LIGHT RGB DATA TO BW
			;WARNING! MUST BE RUN AFTER THE MAIN RGB DATA
			;CONVERTER HAS FINISHED ITS JOB.
comment\
	MOV	BX,0			;START WITH COLOR 0
	MOV	CX,256			;256 COLORS
NEXT_COL:
	PUSH	CX
	CALL	GET_COLOR_DATA		;DH,CH,CL=COLOR DATA

	MOV	DL,DH
	NIL	DH
	MOV	AL,CH
	NIL	AH
	ADD	DX,AX
	MOV	AL,CL
	ADD	AX,DX
	MOV	CL,3
	DIV	CL
	MOV	CL,AL

	CALL	SET_COLOR_DATA_BW	;CL=COLOR DATA
	INC	BX
	POP	CX
	LOOP	NEXT_COL
\	
;*** THAT WAS THE PALETTE. NOW LET'S CONVERT THE RGB DATA ***

	MOVE	ES,DS
	MOV	SI,OFFSET LON1
	MOV	CX,NOOFLIGHTS+1
CONV_NEXT_POST:
	PUSH	CX
	INC	SI
	LODSB		;AL=RGB DATA LEN
	NIL	AH
	MOV	BL,3
	DIV	BL
	MOV	CX,AX
CONV_NEXT_RGB_BLOCK:
	PUSH	CX
	MOV	DI,SI
	NIL	AH
	LODSB
	MOV	DX,AX
	LODSB
	ADD	DX,AX
	LODSB
	ADD	AX,DX
	MOV	BL,3
	DIV	BL
	STOSB
	STOSB
	STOSB
	POP	CX
	LOOP	CONV_NEXT_RGB_BLOCK
	
	POP	CX
	LOOP	CONV_NEXT_POST

	RETN
COLOR_2_BW ENDP
comment\
GET_COLOR_DATA PROC NEAR	;FN: READ SINGLE COLOR FROM PALETTE
				;INPUT: BX=COLOR NO
				;OUTPUT: DH,CH,CL=COLOR DATA, BX UNTOUCHED
				;WARNING! USING BIOS!
	PUSH	BX
	MOV	AL,15H
	MOV	AH,10H
	INT	10H
	POP	BX
	RETN
GET_COLOR_DATA ENDP

SET_COLOR_DATA_BW PROC NEAR	;FN: WRITE SINGLE COLOR TO PALETTE
				;INPUT: BL=COL NO, CL=BW COLOR DATA
				;OUTPUT: BX UNTOUCHED
	MOV	DX,3C8H
	MOV	AL,BL
	OUT	DX,AL
	INC	DX
	MOV	AL,CL
	OUT	DX,AL	;OUT R
	OUT	DX,AL	;OUT G
	OUT	DX,AL	;OUT B
	RETN
SET_COLOR_DATA_BW ENDP
\
FANTASIES ENDP

addscoreBCD:
	;funkar typ: addbcd [di],[si], addera [di] med [si]
	antalsiffror=11 ;(999.999.999.999)
	mov	al,[di+antalsiffror]
	add	al,[si+antalsiffror]
	aaa
	mov	[di+antalsiffror],al
	pos=1
rept (antalsiffror)
	mov	al,[di-pos+antalsiffror]
	adc	al,[si-pos+antalsiffror]
	aaa
	mov	[di-pos+antalsiffror],al
	pos=pos+1
endm
	retn

DO_UPDATE_LIGHT PROC NEAR	;INPUT:AL=LINUM, AH=[STRUCADR]
	CMP	AH,TRUE
	JE	ITS_ON
	LIGHTOFF AL
	RETN
ITS_ON:	LIGHTON AL
	RETN
DO_UPDATE_LIGHT ENDP

DO_UPDATE_PSTRUC PROC NEAR	;INPUT:AL=LINUM, BX=STRUCADR
	PUSH	BX
	MOV	BL,AL
	NIL	BH
	MOV	AH,TRUE
	CMP	LIGHTSTATUS[BX],AH
	POP	BX
	JE	ITS_ON2
	MOV	BYTE PTR [BX],FALSE
	RETN
ITS_ON2:
	MOV	BYTE PTR [BX],TRUE
	RETN
DO_UPDATE_PSTRUC ENDP
TECHrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset TECHTS
	call	do_matrix
	retn
TSPrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset TSPTS
	call	do_matrix
	retn
JOHANrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset JOHANTS
	call	do_matrix
	retn
DANIELrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset DANIELTS
	call	do_matrix
	retn
GABRIELrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset GABRIELTS
	call	do_matrix
	retn
CHEATrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset CHEATTS
	call	do_matrix
	retn
TILTrut:
	MOV	AFTER_CHEAT,TRUE
	MOV	TILTDISABLED,TRUE
	mov	bx,offset QUAKETS
	call	do_matrix
	retn
robbanrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset robbanTS
	call	do_matrix
	retn
steinrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset steinTS
	call	do_matrix
	retn
greetrut:
	MOV	AFTER_CHEAT,TRUE
	mov	bx,offset GREETTS
	call	do_matrix
	retn

SNAILRUT:
	MOV	AFTER_CHEAT,TRUE
	MOV	BX,OFFSET SnailTS
	CALL	DO_MATRIX
	OR	SHIFTKEYS,00000100B
	RETN

BALLSRUT:
	MOV	AFTER_CHEAT,TRUE
	MOV	BX,OFFSET BallsTS
	CALL	DO_MATRIX
	MOV	NO_OF_BALLS,5
	RETN

FAIRPLAYRUT:
	MOV	AFTER_CHEAT,TRUE
	MOV	BX,OFFSET FairPlayTS
	CALL	DO_MATRIX
	AND	SHIFTKEYS,11111011B		;RESET SPEED
	MOV	TILTDISABLED,FALSE		;RESET TILT
	MOV	NO_OF_BALLS,3
	RETN

include print.asm
;INCLUDE BALLCODE.ASM
INCLUDE SCROLL.ASM
INCLUDE ANIMA.ASM
INCLUDE SCORE.ASM

CODE	ENDS

END	FANTASIES



