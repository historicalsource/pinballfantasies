jumps
FLIPPERL EQU 2	;OBS! MèSTA VARA 2 FôR ATT DET SKA BLI RéTT SHIFTKEYS
FLIPPERR EQU 1
tt equ 5	;cpe 
nn equ 6
rotslowdown=2
SPLH=33
SW=336
BPL=SW/4
banh=576
STOTMAX EQU 2048
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
.286
false equ 0
true equ 255
include \source\macros1.asm
public kollakulan,flipper3
data segment para public 'data'
extrn exahitx,exahity,rotation,sc_X,sc_y,sin,adjusttable,x_pos,y_pos,x_pos_hi,y_pos_hi,x_hast,y_hast,gfxmask21_offset,gfxmask23_offset,gfxmask13_offset,hitpointer:word,screenhast,screenpos,screenposy,materialdata,bumper2lista_l,bumperlista_l,fliplinfo,gravx,gravy
extrn inside_rastint:byte,holdstill:byte,ballhigh:byte,hitvalue:byte,materialbit:byte,bumperwashit:byte,ball_down:byte,allowflip:byte,shiftkeys:byte,tiltflag:byte,tiltkey:byte
EVENDATA
XY_LIST			DW 16,8 ,16,9 ,16,10 ,15,11 ,15,12 ,14,13 ,13,14 ,12,15 ,11,15 ,10,16 ,9,16 ,8,16 ,7,16 ,6,16 ,5,15 ,4,15 ,3,14 ,2,13 ,1,12 ,1,11 ,0,10 ,0,9 ,0,8 ,0,7 ,0,6 ,1,5 ,1,4 ,2,3 ,3,2 ,4,1 ,5,1 ,6,0 ,7,0 ,8,0 ,9,0 ,10,0 ,11,1 ,12,1 ,13,2 ,14,3 ,15,4 ,15,5 ,16,6 ,16,7
SC_KV			DW ?
ANTALPIX		DB ?
EVENDATA
xtoadd	dw 0
ytoadd	dw 0
;********************************** RôR EJ
materialinfo label word
FRVAGG  DW      ?
FRBoLL	DW	?
STUTS	DW	?
MINSTHAST DW	?
INFVINK DW	?
;***********************************
MINUSHAST	DW -4100
PLUSHAST	DW 4100
bumperpower	DW -7000
kickerpower	DW -2000
kickminhast	DW -300
TILTHASTFW	DW 600
TILTHASTRV	DW -200
public MINUSHAST,PLUSHAST,bumperpower,kickerpower,kickminhast,TILTHASTFW,tILTHASTRv
data ends
MASK1_2 SEGMENT PARA PUBLIC 'DATA'
MASK1_2 ENDS
MASK2_2 SEGMENT PARA PUBLIC 'DATA'
MASK2_2 ENDS
MASK1_1 SEGMENT PARA PUBLIC 'DATA'
MASK1_1 ENDS
FlipBit			Equ	10b
RubberBit		Equ	3
StaalBit		Equ	110b
SteelBit		Equ	101b
PlastBit		Equ	7
cos equ offset sin+512*2
code segment para public 'code'
assume cs:code,ds:data
extrn moveflipmask:near
KollaKulan proc near
	CMP	CS:INKO,TRUE
	JE	INKOD
	MOV	CS:INKO,TRUE
	pusha
	call	sc_program
	popa
	MOV	CS:INKO,FALSE
INKOD:	retn
INKO	DB FALSE
KollaKulan endp
sc_program proc near
	CMP	HOLDSTILL,TRUE
	JE	NOMOVE
	
	call	sc_krock
	jc	sc_nocoll
	call	sc_newdir
sc_nocoll:
	call	tilt0
	call	sc_move		
	call	draw_flippers

	mov	al,shiftkeys	
	and	al,inside_rastint
	test	al,100b
	jnz	slutt
	
	call	sc_krock
	jc	sc_nocoll2
	call	sc_newdir
sc_nocoll2:
	call	tilt0
	call	sc_move		
	call	draw_flippers
SLUTT:	retn
NOMOVE:
	CALL	TILT0
	CALL	DRAW_FLIPPERS	
	mov	al,shiftkeys	
	and	al,inside_rastint
	test	al,100b
	jnz	slutt
	CALL	TILT0
	CALL	DRAW_FLIPPERS	
	JMP	SLUTT
sc_program endp
CHECKBOUNDS MACRO REG,MINST,MEST
	LOCAL	ND00,ND01	
	CMP	REG,MINST
	JGE	ND00
	MOV	REG,MINST
	JMP	SHORT ND01
ND00:	CMP	REG,MEST
	JLE	ND01
	MOV	REG,MEST
ND01:	
	ENDM
v_up equ dl
v_dn equ dh
v_left equ bh	
v_right equ bl	;mÜste vara bl
last_point equ ch
angel equ bp
kvartingar equ di
bit0=1
bit1=2
bit2=4
bit3=8
bit4=16
bit5=32
bit6=64
bit7=128
bit8=256
bit9=512
bit10=1024
bit11=2048
bit12=4096
bit13=8192
bit14=16384
bit15=32768
v_upleft=8
v_upright=4
v_dnright=2
v_dnleft=1
checkpoint macro bitno,vinkel,kvart,punktno
	local	nohit,notul,notur,notdl,notdr
	test	al,bitno
	jz	nohit
	add	angel,vinkel
	or	kvartingar,kvart
	mov	last_point,punktno
ifidn <kvart>,<v_upleft>
	inc	v_up
	inc	v_left
endif		
ifidn <kvart>,<v_upright>
	inc	v_up
	inc	v_right
endif		
ifidn <kvart>,<v_dnleft>
	inc	v_dn
	inc	v_left
endif		
ifidn <kvart>,<v_dnright>
	inc	v_dn
	inc	v_right
endif		
nohit:	endm	
checkpoint2 macro raster,byteno,bitno,vinkel,kvart,punktno
	mov	ax,es:[si+40*raster+byteno]
	rol	ax,cl
	checkpoint bitno,vinkel,kvart,punktno
	endm
;***********************************************************************
sc_krock proc near
sc_ch00:
	mov	ax,mask1_2
	CMP	BALLHIGH,FALSE
	JE	LOWER_PLANE
	MOV	AX,MASK2_2
LOWER_PLANE:
	mov	es,ax
	mov	ax,sc_y
	add	ax,screenposY
	dec	ax	;ringen Ñr runt bollen
	mov	si,40
	mul	si
	mov	si,ax
	mov	ax,sc_x
	dec	ax	;ringen Ñr runt bollen
	shr	ax,3
	add	si,ax	;si=adr till îversta vÑnstra byten i bollen
	mov	cx,sc_x
	dec	cx	;ringen Ñr runt bollen
	and	cl,111b
	inc	cl

	xor	v_up,v_up
	xor	v_dn,v_dn
	xor	v_left,v_left
	xor	v_right,v_right
	xor	angel,angel
	xor	kvartingar,kvartingar
		
	mov	ax,es:[si+1]
	rol	ax,cl
	checkpoint bit6,1616,v_upleft,35
	checkpoint bit7,1577,v_upleft,34
sc_kr:	mov	ax,es:[si]
	rol	ax,cl
	checkpoint bit0,1536,v_upleft,33
	checkpoint bit1,1495,v_upright,32
	checkpoint bit2,1456,v_upright,31
sc_k00l:mov	ax,es:[si+41]
	rol	ax,cl
	checkpoint bit4,1705,v_upleft,37
	checkpoint bit5,1668,v_upleft,36
sc_k00r:mov	ax,es:[si+40]	
	rol	ax,cl
	checkpoint bit3,1404,v_upright,30
	checkpoint bit4,1367,v_upright,29
sc_k01:
	checkpoint2 2,1,bit3,1762,v_upleft,38
	checkpoint2 2,0,bit5,1310,v_upright,28
sc_k02:
	checkpoint2 3,1,bit2,1822,v_upleft,39
	checkpoint2 3,0,bit6,1250,v_upright,27
sc_k03:
	checkpoint2 4,1,bit1,1879,v_upleft,40
	checkpoint2 4,0,bit7,1193,v_upright,26
sc_k04:
	checkpoint2 5,1,bit1,1916,v_upleft,41
	checkpoint2 5,0,bit7,1156,v_upright,25
sc_k05:
	checkpoint2 6,1,bit0,1968,v_upleft,42		;?????
	checkpoint2 6,-1,bit0,1104,v_upright,24
sc_k06:
	checkpoint2 7,1,bit0,2007,v_upleft,43		;???
	checkpoint2 7,-1,bit0,1065,v_upright,23
sc_k07:
	checkpoint2 8,1,bit0,0000,v_dnleft,0		;???
	checkpoint2 8,-1,bit0,1024,v_dnright,22
sc_k08:
	checkpoint2 9,1,bit0,0041,v_dnleft,1		;???
	checkpoint2 9,-1,bit0,0983,v_dnright,21
sc_k09:
	checkpoint2 10,1,bit0,0080,v_dnleft,2		;???
	checkpoint2 10,-1,bit0,0944,v_dnright,20
sc_k10:
	checkpoint2 11,1,bit1,0132,v_dnleft,3
	checkpoint2 11,0,bit7,0892,v_dnright,19
sc_k11:
	checkpoint2 12,1,bit1,0169,v_dnleft,4
	checkpoint2 12,0,bit7,0855,v_dnright,18
sc_k12:
	checkpoint2 13,1,bit2,0226,v_dnleft,5
	checkpoint2 13,0,bit6,0798,v_dnright,17
sc_k13:
	checkpoint2 14,1,bit3,0286,v_dnleft,6
	checkpoint2 14,0,bit5,0738,v_dnright,16
sc_k14:
	checkpoint2 15,1,bit4,0343,v_dnleft,7
	checkpoint bit5,0380,v_dnleft,8
sc_k14r:
	checkpoint2 15,0,bit3,0644,v_dnright,14
	checkpoint bit4,0681,v_dnright,15
	
sc_k15l:
	checkpoint2 16,1,bit6,0432,v_dnleft,9
	checkpoint bit7,0471,v_dnleft,10
sc_k15r:
	checkpoint2 16,0,bit0,0512,v_dnright,11
	checkpoint bit1,0553,v_dnright,12
	checkpoint bit2,0592,v_dnright,13
	
sc_k16:
	cmp	kvartingar,11
	je	scq0
	cmp	kvartingar,9
	je	scq0
	cmp	kvartingar,13
	je	scq0
	jmp	short scq1
scq0:					
	mov	ah,v_dn
	xor	al,al
	shl	ax,3
	add	angel,ax
	
scq1:	add	v_left,v_up
	add	v_dn,v_left
	add	v_right,v_dn
	jz	no_krock
	shr	v_right,1
	mov	antalpix,v_right
	mov	ax,angel
	xor	dx,dx
	xor	bh,bh	;bl=v_right
	div	bx
	and	ax,2047
	mov	sc_kv,ax		;krock_vinkel berÑknad!!!!
	
GET_MATERIAL:
	mov	bl,last_point
	xor	bh,bh
	shl	bx,2
	mov	cx,xy_list[bx]
	mov	bx,xy_list[bx+2]
	add	cx,sc_x
	DEC	CX
	add	bx,sc_y
	DEC	BX
	CMP	BX,576
	JgE	NO_KROCK		;NEDANFôR BANANS SLUT
	mov	ax,40
	add	bx,ScreenPosY
	;add screenposy,d1
	mul	bx
	mov	bx,cx
	shr	bx,3
	add	ax,bx
	mov	si,ax
	and	cl,111b
	mov	ch,128
	shR	ch,cl
	xor	cl,cl
	CMP	BALLHIGH,TRUE
	JE	GETHIMTRL
	set_es	mask1_1
	test	es:[si],ch
	jz	notm1
	mov	cl,1
notm1:
	set_es	mask1_2
	test	es:[si],ch
	jz	notm2
	or	cl,10B
notm2:
	mov	ax,si
	xchg	al,ah
	and	ah,11b
	mov	al,4
	mov	dx,3ceh
	out	dx,ax		;set read plane
	set_es	0a000h
	CMP	SI,230*40
	JAE	GO_STD2
	MOV	AX,SI
	SHR	AX,4
	INC	AX
	MOV	DX,80
	MUL	DX
	SHR	SI,2
	ADD	SI,AX
	ADD	SI,SPLH*BPL
	JMP	DONE_WEIRD2
GO_STD2:SUB	SI,230*40
	shr	si,2
	add	si,GFXMASK13_OFFSET
DONE_WEIRD2:
	test	es:[si],ch
	jz	notm3
	or	cl,100B
notm3:	jmp	storemtrl
gethimtrl:
	set_es	mask2_2
	test	es:[si],ch
	jz	notm2b
	or	cl,10b
notm2b:
	mov	ax,si
	xchg	al,ah
	and	ah,11b
	mov	al,4
	mov	dx,3ceh
	out	dx,ax		;set read plane
	shr	si,2
	add	si,GFXMASK21_OFFSET
	set_es	0a000h
	test	es:[si],ch
	jz	notm1b
	or	cl,1
notm1b:
	sub	si,GFXMASK21_OFFSET
	add	si,GFXMASK23_OFFSET
	test	es:[si],ch
	jz	notm3b
	or	cl,100b
notm3b:
storemtrl:
	mov	hitvalue,cl
;	MOV	SIFFRORNA+11,CL

	mov	ax,1408 		;(44/2048)*65536=1408
	mul	sc_kv
	add	ax,8000h
	adc	dx,0
	shl	dx,2
	mov	bx,dx
	mov	si,xy_list[bx]
	mov	di,xy_list[bx+2]
	add	si,sc_x
	add	di,sc_Y
	mov	exahitx,si
	mov	exahity,di

	mov	xtoadd,0
	mov	ytoadd,0

	push	si di	
	mov	cl,hitvalue
	xor	ch,ch
	mov	si,cx
	mov	materialbit,cl
	shl	si,4
	add	si,offset materialdata
	mov	di,offset materialinfo
	set_es	ds
	mov	cx,5
	rep     movsw
	pop	di si

	mov	cl,hitvalue	
	cmp	cl,flipbit
	je	findflip
        CMP	cl,PLASTBIT
	JE	CHECKBUMPER	;BUMPERS
	cmp	cl,rubberbit
	je	checkbumper2	;SIDE KICKERS
	clc
	retn
checkbumper2:
	mov	bx,OFFSET bumper2lista_L
	jmp	short searchbumper
checkbumper:
	mov	bx,offset bumperlista_L
searchbumper:
	CMP	TILTFLAG,TRUE
	JE	LASTBUMP
findbump:
	cmp	word ptr [bx],-1
	je	lastbump
	cmp	si,DS:[bx]
	jb	nobump
	cmp	di,[bx+2]
	jb	lastbump
	cmp	si,[bx+4]
	ja	nobump
	cmp	di,[bx+6]
	ja	nobump
	MOV	AX,[BX+8]
	MOV	HITPOINTER,AX
	;hitpointer, linkitem, hitgroup
	mov	bumperwashit,true
lastbump:
	clc
	retn
nobump:
	add	bx,10
	jmp	findbump	
findflip:
	mov	bx,offset FlipLInfo
findfliploop:	
	test	[bx].typ,0ffh
	jz	noflipfound
	cmp	si,[bx].flipx1
	jb	nextflipl
	cmp	si,[bx].flipx2
	ja	nextflipl
	cmp	di,[bx].flipy1
	jb	nextflipl
	cmp	di,[bx].flipy2
	jbe	thisflipl
nextflipl:
	add	bx,size flipstruc
	jmp	findfliploop
noflipfound:
	clc
	retn
	
thisflipl:
	cmp	[bx].typ,flipperR
	je	thisflipR
	sub	si,[bx].rotcentx
	js	flipfixl
	sub	di,[bx].rotcenty
	test	[bx].powerzone,0ffh
	jz	noswapl
	xchg	si,di
	mov	ax,di
	sar	ax,1
	or	ax,ax
	jns	nonegflipL2
	neg	ax
	jmp	nonegflipL2
noswapL:mov	ax,di
	or	ax,ax
	jns	nonegflipL
	neg	ax
nonegflipL:
	sar	ax,2
nonegflipL2:	
	add	si,ax
	neg	si
	mov	ax,[bx].flipvinkelhast
	imul	si
	mov	ytoadd,ax
	mov	ax,[bx].flipvinkelhast
	imul	di
	mov	xtoadd,ax
flipfixL:
	clc
	retn	
thisflipR:
	sub	si,[bx].rotcentx
	jns	flipfixR
	sub	di,[bx].rotcenty
	test	[bx].powerzone,0ffh
	jz	noswapR
	xchg	si,di
	mov	ax,di
	sar	ax,1
	jns	nonegflipR2
	neg	ax
	jmp	nonegflipR2
noswapR:neg	si
	neg	di
	mov	ax,di
	jns	nonegflipR
	neg	ax
nonegflipR:
	sar	ax,2
nonegflipR2:	
	add	si,ax
	neg	si
	mov	ax,[bx].flipvinkelhast
	imul	si
	mov	ytoadd,ax
	mov	ax,[bx].flipvinkelhast
	imul	di
	mov	xtoadd,ax
flipfixR:
	clc
	retn	
	

no_krock:
;	MOV	EXAHITX,0	;CP?
;	MOV	EXAHITY,0
	stc
	retn	
sc_krock endp
sc_newdir proc near
	mov	si,x_hast
	mov	di,y_hast
	add	si,xtoadd
	add	di,ytoadd
	add	di,screenhast
					;check speed bounds
	CHECKBOUNDS SI,MINUSHAST,PLUSHAST
	CHECKBOUNDS DI,MINUSHAST,PLUSHAST

	mov	bx,2048
	sub	bx,sc_kv
	and	bx,2047	;behîvs om sc_kv=0 (det kan nog va en bug, sa ulf)
	add	bx,bx
	mov	ax,cos[bx]
	imul	si
	mov	bp,dx
	mov	cx,ax
	mov	ax,sin[bx]
	imul	di
	sub	cx,ax
	sbb	bp,dx
rept 3	
	shl	cx,1
	rcl	bp,1	;bp=x cos(v)-y sin(v) (normalhast)
endm	
	mov	ax,sin[bx]
	imul	si
	mov	si,dx
      	mov	cx,ax
	mov	ax,cos[bx]
	imul	di
	add	cx,ax
	adc	si,dx
rept 3	
	shl	cx,1
	rcl	si,1	;si=x sin(v)+y cos(v)
endm	
	xchg	si,bp	;si=d0
	mov	di,BP	;di=d2
;****************
	or	si,si
	jz	toosloow2
	js	toosloow2
	neg	si

	cmp	si,minsthast
	jl	ok001
	xor	si,si
	jmp	toosloow

ok001:	mov	ax,16
	imul	di
	idiv	si
	or	ax,ax
	jns	ok000
	neg	ax	
ok000:	cmp	ax,infvink
	jb	ssab
	xor	si,si
	jmp	toosloow
ssab:	
	or	si,si
	jz	toosloow
	cmp	bumperwashit,false
	je	toosloow
	cmp	materialbit,rubberbit
	je	sidekick
	add	si,bumperpower	;BUMPER
	jmp	nobumperpower
sidekick:
	cmp	si,kickminhast
	jg	toosloow
	add	si,kickerpower	;KICKER
	jmp	short nobumperpower
toosloow:
	mov	bumperwashit,false
nobumperpower:
	mov	ax,si
	imul_256
	idiv	stuts
	sub	si,ax

	mov	cx,frvagg
	mov	bp,frboll
	cmp	si,-1023
	jl	sincos
	mov	ax,si
	neg	ax
	sar	ax,6
	inc	ax
	mov	bx,ax
	mul	cx
	mov	cx,ax
	mov	ax,bx
	mul	bp
	mov	bp,ax
	
sincos:
	mov	ax,rotation
	add	ax,screenhast	;make tilt instable
	sub	ax,di
	imul_256	
	push	ax dx
	JCXZ	NOTC
	idiv	cx	
NOTC:	mov	cx,ax
	pop	dx ax
	OR	BP,BP
	JZ	NOD
	idiv	bp
NOD:	add	di,cx
	sub	rotation,ax
	
	mov	ax,2048			;friktion y-led
	imul	di
	mov	di,2048+1
	idiv	di
	mov	di,ax
	
	mov	bx,sc_kv
	add	bx,bx
	mov	ax,cos[bx]
	imul	si
	mov	bp,dx
	mov	cx,ax
	mov	ax,sin[bx]
	imul	di
	sub	cx,ax
	sbb	bp,dx
	shl	cx,1
	rcl	bp,1	;bp=-x cos(v)+y sin(v)

	mov	ax,sin[bx]
	imul	si
	mov	si,dx
	mov	cx,ax
	mov	ax,cos[bx]
	imul	di
	add	cx,ax
	adc	si,dx
	shl	cx,1
	rcl	si,1	;si=x sin(v)+y cos(v)
	
	sub	bp,xtoadd
	sub	si,ytoadd
	sub	si,screenhast
	
	CHECKBOUNDS BP,MINUSHAST,PLUSHAST
	CHECKBOUNDS SI,MINUSHAST,PLUSHAST

	mov	x_hast,bp
	mov	y_hast,si

	CMP	ANTALPIX,6
	JB	NONEG2
	MOV	BX,SC_KV
	SHL	BX,1
	MOV	AX,-256*4
	IMUL	WORD PTR COS[BX]
	MOV	AX,DX
	CWD
	ADD	X_POS,AX
	ADC	X_pos_HI,DX
	MOV	AX,-256*4
	IMUL	WORD PTR SIN[BX]
	MOV	AX,DX
	CWD
	ADD	Y_POS,AX
	ADC	y_pos_HI,DX
NONEG2:	RETN
toosloow2:
	mov	bumperwashit,false
	retn
sc_newdir endp

sc_move proc near
	MOV	AX,Y_HAST
	cwd
	ADD	Y_pos,AX
	adc	y_pos_hi,dx
	mov	ax,y_pos
	mov	dx,y_pos_hi
	mov	bx,1024
	idiv	bx
	mov	sc_y,ax
	CMP	SC_Y,banh
	JL	FINY
	mov	ball_down,true
FINY:
	MOV	AX,X_HAST
	cwd
	ADD	x_pos,AX
	adc	x_pos_hi,dx
	mov	ax,x_pos
	mov	dx,x_pos_hi
	mov	bx,1024
	idiv	bx
	mov	sc_x,ax

	MOV	AX,GRAVY
	ADD	Y_HAST,AX
	MOV	AX,GRAVX
	ADD	X_HAST,AX
	

	mov	ax,rotation
	or	ax,ax
	jz	rotok
	js	slowrotneg
	sub	rotation,rotslowdown
	jg	rotok
	mov	rotation,0
	jmp	short rotok
slowrotneg:
	add	rotation,rotslowdown
	js	rotok
	mov	rotation,0
rotok:	retn
sc_move endp
draw_flippers proc near
	mov	bx,offset flipLinfo
draw_flip:
	cmp	[bx].typ,0
	jz	flippers_drawn
	mov	si,sc_x
	mov	di,sc_y
	cmp	si,[bx].flipx1
	jb	no_idea
	cmp	si,[bx].flipx2
	ja	no_idea
	cmp	di,[bx].flipy1
	jb	no_idea
	cmp	di,[bx].flipy2
	ja	no_idea
	CALL	MOVEFLIPMASK
no_idea:add	bx,size flipstruc
	jmp	draw_flip
flippers_drawn:	
	retn
draw_flippers endp
TILT0 PROC NEAR
	CMP	TILTKEY,FALSE
	JE	TILTDOWN
TILTUP:
	MOVA	SCREENHAST,TILTHASTFW
	MOV	AX,SCREENPOS
	ADD	AX,SCREENHAST
	MOV	SCREENPOS,AX
	CMP	AX,STOTMAX
	JBE	FLIPPER4
BENZ:	MOV	SCREENHAST,0
	MOV	SCREENPOS,STOTMAX
	JMP	SHORT FLIPPER4
TILTDOWN:
	MOVA	SCREENHAST,TILTHASTRV
	MOV	AX,SCREENPOS
	ADD	AX,SCREENHAST
	MOV	SCREENPOS,AX
	JGE	FLIPPER4
	MOV	SCREENHAST,0
	MOV	SCREENPOS,0
FLIPPER4:
	MOV	AX,SCREENPOS
	SHR	AX,9
	MOV	SCREENPOSY,AX
FLIPPER3:		
	
	MOV	BX,OFFSET FLIPLINFO
NEXTFLIPFIX:
	CMP	[BX].TYP,flipperL
	je	fixLflip
	CMP	[BX].TYP,flipperR
	je	fixRflip
	retn
fixRflip:
	test	SHIFTKEYS,1
	jz	downflip
	jmp	short upflip	
fixLflip:
	test	SHIFTKEYS,10b
	jz	downflip
UpFlip:	cmp	AllowFlip,false
	je	DownFlip
	MOV	AX,[BX].FLIPVINKELHAST 
	ADD	AX,[BX].FLIPAXUP
	CMP	AX,[BX].FLIPMAXHASTUP ;
	JLE	TOOSLOW	
	MOV	AX,[BX].FLIPMAXHASTUP
TooSlow:
	MOV	[BX].FLIPVINKELHAST,AX
	NEG	AX
	ADD	AX,[BX].FlipVinkel
	MOV	[bx].FlipVinkel,AX
	ShL	AX,1
	MOV	SI,AX
	MOV	AX,ADJUSTTABLE[SI]
	OR	AX,AX
	JNz	FLI03
	MOV	[BX].FlipVinkelHast,0
	MOV	[BX].FlipVinkel,0
	XOR	AX,AX
fli03:	Cmp	ax,[BX].FlipFrames
	JL	FLI01
	MOV	[BX].FLIPVINKELHAST,0
	MOVA	[BX].FLIPVINKEL,[BX].FLIPFRAMESMAX
	MOV	AX,[BX].FLIPFRAMES
fli01:	
	MOV	[BX].FLIPFRAME,AX
	ADD	BX,SIZE FLIPSTRUC
	JMP	NEXTFLIPFIX
	
downflip:
	
	MOV	AX,[BX].FLIPVINKELHAST 
	ADD	AX,[BX].FLIPAXdown
	MOV	[BX].FLIPVINKELHAST,AX
	NEG	AX
	ADD	AX,[BX].FlipVinkel
	MOV	[bx].FlipVinkel,AX
	ShL	AX,1
	MOV	SI,AX
	MOV	AX,ADJUSTTABLE[SI]
	OR	AX,AX
	Jnz	FLI02
	MOV	[BX].FlipVinkelHast,0
	MOV	[BX].FlipVinkel,0
	XOR	AX,AX
fli02:	Cmp	ax,[BX].FlipFrames
	JL	FLI00
	MOV	[BX].FLIPVINKELHAST,0
	MOVA	[BX].FLIPVINKEL,[BX].FLIPFRAMESMAX
	MOV	AX,[BX].FLIPFRAMES
fli00:	MOV	[BX].FLIPFRAME,AX
	ADD	BX,SIZE FLIPSTRUC
	JMP	NEXTFLIPFIX
TILT0 ENDP
code ends
end