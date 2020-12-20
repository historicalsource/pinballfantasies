
;KOLLA Pè BUPPEN! (ILLEGAL SPARNING?)

;fADNINGAR GJORDA MED MACROT REPOUTSB, SOM E LITE SLîARE, TILLRÑCKLIGT?????

CHECK1NUM=4EH	;JéMT!
finmenu=1
showall=0	;visa mig ALLT! (Snuskigt???)
NOOFWORDS=64 ;OBS SôK SLUMPEN!
demover=0
keyhandler=65h
NOFILLIT=0
bpl=80
IF DEMOVER
trim=67000/16			;i paragrafer
ELSE
trim=+67000/16			;i paragrafer
ENDIF
pm_test=0
covtime=28
fl1storlek=110
THETRIM=22
checktrim=-223+14h+20h
checktrim2=24-52+24-138-3+24-61+24-96+24
firstpictime=1
t21sttime=349-28-THETRIM+3
vikingtime=658-17-THETRIM+1
fld_logotime=980-80+9+1-THETRIM+3
presenttime=0
fantasietime=50*30

infotime=0 ;60*25

GURKA=42

LINJEN=8
charwith=18
charheight=14
mellanrum=4
FONTW=18	;"BOKSTAV-MED"
sdrsizze=35	;ca sizen pÜ en sdr!!!
WORDLEN=8	;EVEN NUMBER!!!!
mod1size=252868
pos1=3		;mod1size/65536
pos2=56260	;mod1size-pos1*65536
nosnd_needed=530-sdrsizze		;ska ha ca 2 k mer (start!!)
needed=573-sdrsizze		;ska ha ca 2 k mer (start!!)
lsize=300		;obs!!!!! KOM I HèG è KOLLA!!!
basememreq_cp=(needed-lsize)			;free mem required (size needed-size of intro+size of start.exe)
nosoundmemreq_cp=(nosnd_needed-lsize)		;if no music, or XMS detected
nosoundmemreq=basememreq_cp/16*1000+trim-38000/16					;nosoundmemreq_cp/16*1000+trim
basememreq=basememreq_cp/16*1000+trim
DIST=10
musikkaos=0

menutime=9
texttime=7

intpic2pos=150
t21stpos=0
vikingpos=240
vikingadr=320/4*247
fld_logopos=246*2
nofcolors=64

TEXTCOLOR=60
clear_boxen macro vart_start,bredden,hojden
local	lajban_laban_o_lajla_samt_det_lilla_spoket_laban
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!!
	mov	cx,hojden
	mov	di,vart_start
lajban_laban_o_lajla_samt_det_lilla_spoket_laban:
	push	cx
	mov	cx,bredden
	rep	stosb
	add	di,80
	sub	di,bredden
	pop	cx
	loop	lajban_laban_o_lajla_samt_det_lilla_spoket_laban
endm

repoutsb	macro
	local lerum
lerum:
	outsb
	jmp	$+2
	loop	lerum		;nîdvÑndigt lÜngsam!!
endm	
STRLEN	MACRO DEST,TEXT		;DOES NOT INCLUDE ,0
	LOCAL	NXTCH,NOMRCC,TEMPCNT
	PUSHA
	MOV	CS:TEMPCNT,0
	MOV	SI,OFFSET TEXT
	NIL	BX
NXTCH:	LODSB
	OR	AL,AL
	JZ	NOMRCC
	INC	BX
	JMP	NXTCH
TEMPCNT	DB	?
NOMRCC:	MOV	CS:TEMPCNT,BL
	POPA
	MOV	DEST,CS:[OFFSET TEMPCNT]
ENDM


;SetWBPL <BPLmask>      Set write BPL mask
SetWBPL macro   BPLmask
                mov     dx,3c4h
                mov     ah,BPLmask
                mov     al,2
                out     dx,ax
                endm
;-)
;SetRBPL <BPL#>         Set read BPL# (remember: just ONE at the time)
SetRBPL macro   BPLnr
                mov     dx,3ceh
                mov     ah,BPLnr
                mov     al,4
                out     dx,ax
                endm
		
		

STRCOPY	MACRO DEST,SOURCE
	PUSHA
	PUSH	ES
	PUSH	OFFSET DEST
	PUSH	OFFSET SOURCE
	POP	SI
	POP	DI
	MOVE	ES,DS
	STRLEN	CL,SI
	NIL	CH
	INC	CX
	REP	MOVSB
	POP	ES
	POPA
ENDM

STRCOPY2 MACRO DEST,SOURCE	;DOES NOT COPY ,0
	PUSHA
	PUSH	ES
	PUSH	OFFSET DEST
	PUSH	OFFSET SOURCE
	POP	SI
	POP	DI
	MOVE	ES,DS
	STRLEN	CL,SI
	NIL	CH
	REP	MOVSB
	POP	ES
	POPA
ENDM




SIMINT MACRO INTNO
	MOVE	ES,0
	PUSHF
	CALL	DWORD PTR ES:[INTNO*4]
ENDM
savestack	macro
	move	cs:s_s,ss
	mov	cs:s_p,sp
endm
restorestack	macro
	move	ss,cs:s_s
	mov	sp,cs:s_p
endm

borland	macro
	push	es di cx
	mov	ax,0700h
	mov	di,0
	move	es,0b800h
	mov	cx,160*25/2
	rep	stosw
	pop	cx di es
endm

HUGO	MACRO NEBUL
	LOCAL	STRUMPA,FERTICH,SCHLUKA,DUNK
	MOV	DI,CS:PEKARN
	MOV	SI,OFFSET NEBUL
	MOVE	DS,DATA
	MOVE	ES,0B800H
STRUMPA:
	LODSB
	CMP	AL,'$'
	JE	FERTICH
	CMP	AL,13
	JE	SCHLUKA
	CMP	AL,10
	JE	DUNK
	STOSB
	INC	DI
	JMP	STRUMPA
SCHLUKA:
	MOV	AX,DI
	NIL	DX
	MOV	CX,160
	DIV	CX
	mov	bp,ax
	MUL	CX
	mov	di,ax

	MOV	Dx,Bp
	mov	dh,dl
	add	dh,2
	MOV	DL,0
	XOR	BX,BX
	MOV	AH,02H
	INT	10H

	JMP	STRUMPA
DUNK:
	ADD	DI,160
	JMP	STRUMPA
FERTICH:
	MOV	CS:PEKARN,DI
ENDM
SPYMESS MACRO MESSAGE
	LOCAL	MESS,GNU,FERTICH,STRUMPA,schluka,dunk
	JMP	GNU
MESS	DB	MESSAGE,'$'
GNU:	PUSHA
	PUSH	DS
	MOV	AX,CS
	MOV	DS,AX
	MOV	Dx,offset cs:mess
	mov	ax,900h
	int	21h
	pop	ds
	popa
	ENDM
comment\
SPYMESS MACRO MESSAGE
	LOCAL	MESS,GNU,FERTICH,STRUMPA,schluka,dunk
	JMP	GNU
MESS	DB	MESSAGE,'$'
GNU:	PUSHA
	PUSH	DS ES
	MOV	AX,CS
	MOV	DS,AX
	MOV	DI,CS:PEKARN
	MOV	SI,OFFSET CS:MESS
	MOVE	ES,0B800H
STRUMPA:
	LODSB
	CMP	AL,'$'
	JE	FERTICH
	CMP	AL,13
	JE	SCHLUKA
	CMP	AL,10
	JE	DUNK
	STOSB
	INC	DI
	JMP	STRUMPA
SCHLUKA:
	MOV	AX,DI
	NIL	DX
	MOV	CX,160
	DIV	CX
	mov	bp,ax
	MUL	CX
	mov	di,ax

	MOV	Dx,Bp
	mov	dh,dl
	add	dh,2
	MOV	DL,0
	XOR	BX,BX
	MOV	AH,02H
	INT	10H

	JMP	STRUMPA
DUNK:
	ADD	DI,160
	JMP	STRUMPA
FERTICH:
	MOV	CS:PEKARN,DI
	POP	ES DS
	POPA
	ENDM
\
SetLores        macro
                mov     dx,3d4h
                mov     ax,0c009h
                out     dx,ax
                endm

SetHires        macro
                mov     dx,3d4h
                mov     ax,4009h
                out     dx,ax
                endm
SetVga          macro
                ;sequencer!
                mov     dx,3c4h         ;mcga
                mov     ax,0604h        ;0e04h
                out     dx,ax           ;chain 4
                ;CRTC!
                mov     dx,3d4h
                mov     ax,0c11h
                out     dx,ax           ;unprotect 0-7 in crtc!
                mov     ax,5404h
                out     dx,ax           ;Start Hor Retrc.
		mov	ax,0b06h
		out	dx,ax
		mov	ax,3e07h
		out	dx,ax
		mov	ax,4009h
		out	dx,ax
		mov	ax,590fh
		out	dx,ax
		mov	ax,0ea10h
		out	dx,ax
		mov	ax,8c11h
		out	dx,ax
		mov	ax,0df12h
		out	dx,ax
		mov	ax,0014h
		out	dx,ax
		mov	ax,0e715h
		out	dx,ax
		mov	ax,0416h
		out	dx,ax
		mov	ax,0e317h
		out	dx,ax

                ;Grapic controler
                mov     dx,3ceh
                mov     ax,0005h        ;4005h
                out     dx,ax           ;mode reg.
                ;attribute
                mov     dx,3dah
                in      al,dx
                mov     dx,3c0h
                mov     al,20h+10h
                out     dx,al
                mov     al,25h          ;61h
                out     dx,al          ; mode contr
endm

cleargfx macro
LOCAL	TRULLE
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	mova	es,0a000h
	mov	cx,32760 ;vem vet, det kanske blir exception om den îverskrider
	xor	ax,ax
	mov	di,ax
TRULLE:	NOP
	stosw
	NOP
	LOOP	TRULLE	;TRULLSON ASSè!
endm

movpal	macro sseg,source,dseg,dest
	mov	si,source
	mov	di,dest
	push	ds
	move	ds,sseg
	move	es,dseg
	mov	cx,16*3
	rep movsb
	pop	ds
endm

checkquit macro
;	in	al,60h
;	cmp	al,cs:firstscan
;	mov	ax,1
;	int	16h
;	cmp	al,01
;	je	choosern_init
if demover
	cmp	cs:laddaden,true
	je	space2
ELSE
	cmp	cs:laddaden,true
	je	skip_the_intro_bra_att_hoppa_till_da
endif
endm
FILLMUSICBUF MACRO
	LOCAL	FILLA
PUSHA
PUSH	ES DS
	MOV	CX,100
FILLA:	PUSH	CX
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
	POP	CX
	LOOP	FILLA
POP	DS ES
POPA
ENDM

.286p
jumps
wait_sync macro	times
local	lo,ko,sko

	mov cx,times
	
lo:	push	cx
	synca
IF	NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	pop	cx
;	in	al,60h
;	cmp	al,cs:firstscan
	mov	ax,1
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
if	demover
	cmp	al,57
	jne	sko	
	mov	cs:laddaden,true
sko:
endif
	cmp	al,57
	je	skip_the_intro_bra_att_hoppa_till_da
;	je	ko
	loop	lo
ko:
endm

wait_music macro	times
local	lo,ko,sko,TRO

lo:
	MOVE	ES,0
	MOV	AX,22
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
	cmp	ax,times
	ja	ko
PUSH	AX
IF NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	mov	ax,1
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
POP	BP
if	demover
	CMP	AL,01
	JE	SPYAN_STEWART
	cmp	al,57
	jne	sko	
	mov	cs:laddaden,true
	JMP	KO
ELSE
	cmp	al,57
	jne	sko	
	mov	cs:laddaden,true
	JMP	KO
endif
	JMP	TRO
sko:
	MOV	AL,3
TRO:
	cmp	al,1
	je	SKO

	cmp	al,57
	jne	lo
if demover
;	mov	cs:laddaden,true
	jmp	lo	;space2
else
	jmp	LO	;skip_the_intro_bra_att_hoppa_till_da
endif
ko:
endm

wait_sync_spec macro	times
local	lo,ko,sko

	mov cx,times
lo:	push	cx
	synca
IF NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	pop	cx
;	in	al,60h
;	cmp	al,cs:firstscan
	mov	ax,1
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
if	demover
	cmp	al,57
	jne	sko	
	mov	cs:laddaden,true
sko:
endif
	cmp	al,57
;	je	skip_the_intro_bra_att_hoppa_till_da
	je	ko
	loop	lo
ko:
endm
wait_sync_spec2 macro	times
local	lo,ko,sko

	mov cx,times
lo:	push	cx
	synca
IF NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	pop	cx
;	in	al,60h
;	cmp	al,cs:firstscan
	mov	ax,1
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
if	demover
	cmp	al,57
	jne	sko	
	mov	cs:laddaden,true
sko:
endif
;	cmp	al,57
;	je	skip_the_intro_bra_att_hoppa_till_da
;	je	ko
	loop	lo
ko:
endm

wait_sync2 macro	times
local	lo,ko,moooo

	mov cx,times
	mov	cs:menunext,false

lo:	push	cx
	synca
IF NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	pop	cx

	mov	ax,1
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]

	cmp	al,01
	je	moooo
	cmp	al,3bh		;f1
	je	f1t
	cmp	al,3ch		;f2
	je	f2t
if finmenu
	cmp	al,3dh		;f3
	je	f3t
	cmp	al,3eh		;f4
	je	f4t
endif
	cmp	al,3fh		;f5
	je	f5t
if finmenu
	cmp	al,28		;enter
	je	moooo
else
	cmp	al,28		;enter
	je	ko
endif
	cmp	al,57
	je	moooo
	loop	lo
	jmp	moooo
f5t:
	mov	cs:menunext,true
	MOV	CS:INFO_TEXT,OFFSET CS:OPTIONS_INFO
	jmp	moooo
ko:
	xor	banpek,10b
	MOV	TEXTLISTA[0],OFFSET HITEXT1
	JZ	NEDU2
	MOV	TEXTLISTA[0],OFFSET HITEXT2
NEDU2:
moooo:
endm

fade	macro	hast,pal1seg,pal1adr,pal2seg,pal2adr
	local fada
	mov	cs:steg,hast
	mov	cL,cs:steg
;	INC	CL		;FôR ATT UNDVIKA BAJSET!!!
	XOR	CH,CH
fada:	move	ds,data
	mov	SI,pal2adr
	MOV	DI,pal1adr
	MOVA	ES,pal1seg
	push	ds
	mova	ds,pal2seg
	CALL	MAKE_PAL
	pop	ds
	synca
	CALL	SET_PAL
	PUSH	ES
	MOVE	ES,0
IF NOFILLIT
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	POP	ES
	LOOP	FADA
endm
fadeM	macro	hast,pal1seg,pal1adr,pal2seg,pal2adr
	local fada,slut,nosetv,oldvol
	mov	cs:steg,hast
	mov	cL,cs:steg
	XOR	CH,CH
fada:	move	ds,data
	mov	SI,pal2adr
	MOV	DI,pal1adr
	MOVA	ES,pal1seg
	push	ds
	mova	ds,pal2seg
	CALL	MAKE_PAL
	pop	ds
	synca
	CALL	SET_PAL
	mov	ax,cx
	xchg	al,ah
	xor	dx,dx
	mov	bx,hast
	div	bx
	push	cx
	mov	cx,ax
	and	ax,-16
	cmp	ax,cs:oldvol
	je	nosetV
	mov	cs:oldvol,ax
	mov	al,6
	int	66h
nosetV:	pop	cx
	PUSH	ES
	MOVE	ES,0
IF NOFILLIT
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	POP	ES
	LOOP	FADA
	jmp	slut
oldvol	dw	0
slut:
endm

;***************
fade1 macro val,steg

	mov	al,val
	mov	bl,steg ;+1
	sub	bl,cl
	mul	bl
	mov	bl,steg
	div	bl
	mov	dx,3c9h
	out	dx,al
endm
fade1B macro val,steg

	mov	al,val
	mov	bl,steg-1
	sub	bl,cl
	mul	bl
	mov	bl,steg
	div	bl
	mov	dx,3c9h
	out	dx,al
endm

fade3	 macro sped
	local gnuor
	mov	cx,sped
gnuor:
	mov	dx,3c8h
	mov	al,1
	out	dx,al
	
	fade1	52,sped
	fade1	52,sped
	fade1	62,sped
	mov	dx,3c8h
	mov	al,12
	out	dx,al
	fade1	37,sped
	fade1	37,sped
	fade1	45,sped
	mov	dx,3c8h
	mov	al,14
	out	dx,al
	fade1	17,sped
	fade1	17,sped
	fade1	25,sped
	synca

	loop	gnuor		
endm
fade3b	 macro sped
	local gnuor
	mov	cx,0
gnuor:
	mov	dx,3c8h
	mov	al,1
	out	dx,al
	
	fade1B	52,sped
	fade1B	52,sped
	fade1B	62,sped
	mov	dx,3c8h
	mov	al,12
	out	dx,al
	fade1B	37,sped
	fade1B	37,sped
	fade1B	45,sped
	mov	dx,3c8h
	mov	al,14
	out	dx,al
	fade1B	17,sped
	fade1B	17,sped
	fade1B	25,sped
	synca
	inc cx
	cmp cx,sped
	jne	gnuor		
endm
;************
fade256	macro	hast,pal1seg,pal1adr,pal2seg,pal2adr
	local fada
	mov	cs:steg,hast
	mov	cL,cs:steg
	XOR	CH,CH
fada:	move	ds,data
	mov	SI,pal2adr
	MOV	DI,pal1adr
	MOVA	ES,pal1seg
	push	ds
	mova	ds,pal2seg
	CALL	MAKE_PAL256
	pop	ds
	synca
	CALL	SET_PAL256
	PUSH	ES
IF NOFILLIT
	MOVE	ES,0
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR ES:[66H*4]
ENDIF
	POP	ES


	LOOP	FADA
endm
movepic	macro nisse,goran
	local	taljan
	mov	ax,0a000h
	mov	es,ax
	mov	ds,ax
	mov	cx,95	;Bildhîjd
	mov	di,nisse
	mov	si,goran
taljan:	push	cx
	mov	cx,55	;Linjebredd
	rep	movsb
	add	si,80-55
	add	di,80-55
	pop	cx
	loop	taljan
	move	ds,data
endm
SLACKA MACRO PLATS
	MOV	CS:FJUMPENS_BROR,PLATS
ENDM
slack	macro fjumpen
	LOCAL	NOTHING_NEW
	MOV	CX,fjumpen			;CALC CX (HORIZ END)
	CMP	CX,CS:FJUMPENS_FARSA
	JE	NOTHING_NEW
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
NOTHING_NEW:
endm
setscr	macro	pos
	mov	cx,pos
	mov	dx,3d4h
	mov	al,0dh
	mov	ah,cl
	out	dx,ax
	mov	ah,ch
	dec	al
	out	dx,ax
endm
stacken segment para stack 'stack'
	dw 1024 dup (0)
stacken ends
;********************************************* D A T A  S E G M E N T ********
data segment para public 'data'
pelle1	db 3*256 dup (0)
pelle2	db 3*256 dup (0)
SKIT	DB 'NILSBEDRUP '
pellevin1 dw offset pelle1
pellevin2 dw offset pelle2
buppen_filen dw ?
chksum	dw ?
rekord_tabell	DB 0,1,11 DUP(0),0,8,1 DUP(0),'QWERTYUIOP',0,0,13,0,'ASDFGHJKL',0,0,0,0,0,'ZXCVBNM',6 dup (0),' ',(128-50-7) dup (0),20 dup (0)
PM_MESS DB 13,10,13,10,'WARNING: Protected mode has been detected!',13,10,13,10
db 'This is probably because you have a memory manager such as',13,10
db 'EMM386 or QEMM installed. Please uninstall this memory manager driver!',13,10
db 'Refer to your manual for further information.',13,10
db 13,10,'Press ESCape to quit or P to proceed...$'
comment\
notenoughmess	db 'Pinball Fantasies requires at least 555 kbytes (568000) free base memory',13,10
		db "or 520 kbytes (530000) for 'Gravis UltraSound' or 'nosound' drivers.",13,10  
		db 'Please look in Your manual how to free up DOS memory!',13,10,'$',0
\
notenoughmess label byte
db    "You do not have enough free memory to run Pinball Fantasies.",13,10
db    "You need to have at least 530K (542700 bytes) free to run ",13,10
db    "the game if you are using a Gravis Ultrasound sound card or ",13,10
db    "are planning to run the game with no sound at all.",13,10,13,10
     
 db "If you want to have sound in the game, you will need at",13,10 
 db "least 560K (573440 bytes) free.",13,10,13,10
      
     db "Please type CHKDSK or MEM (DOS 4 or higher) at the dos prompt",13,10
     db "to display free memory.",13,10,13,10
     
     db 'Please refer to the "troubleshooting" section in your',13,10 
     db "instruction manual for guidance on how to free your ",13,10
     db "computers memory.",13,10,0,"$"

wordstruc struc
	THELINE DB ?
	CPVAL	DW ?
	THETEXT	DW WORDLEN/2 DUP (?)
	THEPAGE	DB ?
	CHKSUMA	DB ?
	THEWORD DB ?
ends
extrn ordlista:byte
THEPOST DW ?
lbredd=400
lhojd=40
loggasize=lbredd/2*lhojd
savearea1	db loggasize dup (?)
savearea2	db loggasize dup (?)
hi_score_file1	db 'table1.hi',0
hi_score_file2	db 'table2.hi',0
hi_score_file3	db 'table3.hi',0
hi_score_file4	db 'table4.hi',0
HI_SCORE_LIST LABEL BYTE
	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'TSP',0	;FEST-LANDET
	db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ICE',0
	db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'ANY',0
	db 0,0,0, 0,0,5, 0,0,0, 0,0,0,'J L',0
HI_SCORE_LIST2 LABEL BYTE
	db 0,0,0, 1,0,0, 0,0,0, 0,0,0,'TSP',0	;HASTIGHETSJéVLARNA
	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'J L',0
	db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ICE',0
	db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'ANY',0
HI_SCORE_LIST3 LABEL BYTE
	db 0,0,0, 1,0,0, 0,0,0, 0,0,0,'TSP',0	;MILJARDVISNINGEN
	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'ANY',0
	db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'J L',0
	db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'ICE',0
HI_SCORE_LIST4 LABEL BYTE
	db 0,0,0, 1,0,0, 0,0,0, 0,0,0,'TSP',0	;STENAR&BEN
	db 0,0,0, 0,5,0, 0,0,0, 0,0,0,'ICE',0
	db 0,0,0, 0,2,5, 0,0,0, 0,0,0,'ANY',0
	db 0,0,0, 0,1,0, 0,0,0, 0,0,0,'J L',0

;HéR!
MENU_ITEMS	LABEL WORD
		DW L_BALLS
		DW L_ANGLE
		DW L_SCROLLING
		DW L_IM
		DW L_RESOLUTION
		DW L_MODE
		DW L_SAVE
LAST_ITEM	LABEL WORD
HIGH_MENU=(LAST_ITEM-MENU_ITEMS)/2

MENU_ITEMS_UPDATES LABEL WORD
		DW L_BALLS_UPDATE
		DW L_ANGLE_UPDATE
		DW L_SCROLLING_UPDATE
		DW L_IM_UPDATE
		DW L_RESOLUTION_UPDATE
		DW L_MODE_UPDATE
		DW DUMRET

TOGGLAR_STRUCEN STRUC
	S_BALLS		DB ?
	S_ANGLE		DB ?
	S_SCROLLING	DB ?
	S_IM		DB ?
	S_RESOLUTION	DB ?
	S_MODE		DB ?
ENDS
TOGGLAREN DB SIZE TOGGLAR_STRUCEN DUP (0)
TOGGLAR_NAME	DB 'PINBALL.CFG',0

TEXTEN1		DB 'PLEASE ENTER WORD ',0,50 DUP (0)
TEXTEN2		DB ' ON',0
TEXTEN3		DB 'LINE ',0,20 DUP(0)
TEXTEN4		DB ' AT PAGE ',0
TEXTEN5		DB '.',0
TEMPTEXT	DB 10 DUP(0)
reserv		db 100 dup(0)
rensa_input	db 20 dup (' '),0
ALIGN 16
HEXTBL		DB "0123456789ABCDEF"

	DB 16 DUP (1)
	DB " HI HACKER!  PLEASE DON'T CRACK THIS PROGRAM! IT WAS MADE BY"
	DB " THE DEMO GROUP TSP. WE NEED THE MONEY TO BE ABLE TO KEEP ON"
	DB " CODING GAMES FOR THE PC! THIS PROGRAM ISN'T HARD TO CRACK, SO"
	DB " MAKE A DEMO INSTEAD TO PROVE YOUR SKILLS... IF YOU CRACK IT"
	DB " WE WILL HATE YOU 4EVER!  HAVE A NICE DAY! :-) "
	DB 16 DUP (2)

TEXTLISTA LABEL WORD
	DW HITEXT1	;OBS!!! Higscore vill ligga hÑr
;GNU
	dw -1
	dw -1
	DW TEXT1
	DW TEXT2
	dw -1
	dw -1
	DW TEXT3
	DW TEXT4
	DW -1
	DW -1
	DW 0
	DW 0
	DW 0
	DW 0

comment\
betatext db 0
	DB 'THIS IS A BETA VERSION',0
	DB 0
	DB 'DO NOT SPREAD',0
	DB 0
	DB 'ONLY FOR',0
	DB 'PETER ENGSTRAND',0
	DB 0
	DB 'HAVE FUN -  WE DONT',0
	DB 0
	DB 'PS  CHANGE TABLES',0
	DB 'WITH ENTER  DS',0
\
START_KEK LABEL BYTE		;CHECKSUMMA!!!!! ;-(
text1	db 'PINBALL FANTASIES PC',0
	db 'BY FRONTLINE DESIGN',0
	DB 0
	db 'PROGRAMMING BY:',0
	DB 'DANIEL FORSGREN',0
	DB 'GABRIEL BERGQVIST',0
	db 'JOHAN LUNDMARK',0
	DB 0
STOP_KEK LABEL BYTE
	DB 'PRODUCED BY:',0
	DB 'BARRY SIMPSON',0
	DB 'AND',0
	DB 'STEWART GILRAY',0
TEXT2	DB 0
	DB 0
	DB 'ORIGINAL AMIGA GAME BY',0
	DB 'DIGITAL ILLUSIONS',0
	DB 0
	DB 'ANDREAS AXELSSON',0
	DB 'MARKUS NYSTROM',0
	DB 'OLOF GUSTAVSSON',0
	DB 'ULF MANDORFF',0
	DB 'FREDRIK LILIEGREN',0
	DB 0
	DB 0
TEXT4	DB 0
	DB 0 
	DB 0 
	DB 0
	DB '-WINNERS-',0
	DB '-DO NOT USE-',0
	DB '-DRUGS-',0
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0
TEXT3	DB 'SELECTOR INSTRUCTIONS',0
	DB 0 
	DB 'F1 - PARTYLAND     ',0 
	DB 'F2 - SPEED DEVILS  ',0
	DB 'F3 - BILLION DOLLAR',0
	DB 'F4 - STONES N BONES',0
	DB 'F5 - OPTIONS MENU  ',0
	DB 0
	DB 'SPACE TO SKIP',0
	DB 'ESC TO QUIT',0
	DB 0
	DB 0

;HéR!
TRE		DB '3',0
FEM		DB '5',0
NORMAL		DB 'NORMAL',0
ZHIGH		DB 'HIGH  ',0
ZLOW		DB 'LOW   ',0

FIRM		DB 'HARD  ',0
SMOOTH		DB 'MEDIUM',0
SLIME		DB 'SOFT  ',0

ZARINEN		DW FIRM
		DW SMOOTH
		DW SLIME

ON		DB 'ON ',0
OFF		DB 'OFF',0
ZCOLOR		DB 'COLOR',0
MONO		DB 'MONO ',0

PIL	DB '>',0
MENUtext DB 'OPTIONS MENU',0 
	DB 0 
FIRSTCHOICE	LABEL BYTE
T_BALLS		DB '  BALLS:                '   ;3, 5
T_ANGLE		DB '  ANGLE:                '   ;NORMAL, HIGH
T_SCROLLING	DB '  SCROLLING:            '	;BRUTAL, FIRM, *SMOOTH*, SLIMY
T_IM		DB '  INGAME MUSIC:         '	;ON, OFF
T_RESOLUTION	DB '  RESOLUTION:           '	;NORMAL, HIGH
T_MODE		DB '  COLOR MODE:           '	;COLOR, MONOCHROME
	DB 0 
	DB '  SAVE AND EXIT         '
	DB 0
	DB 0
	DB 0
	DB 0
	DB 0

HITEXT1	LABEL BYTE
SPCS	LABEL BYTE
	DB '                        '
	DB '     PARTY LAND         '
	DB '  1.     -              '
	DB '  2.     -              '
	DB '  3.     -              '
	DB '  4.     -              '
	DB '                        '
	DB '     SPEED DEVILS       '
	DB '  1.     -              '
	DB '  2.     -              '
	DB '  3.     -              '
	DB '  4.     -              '
HITEXT2	DB '                        '
	DB '     BILLION DOLLAR     '
	DB '  1.     -              '
	DB '  2.     -              '
	DB '  3.     -              '
	DB '  4.     -              '
	DB '                        '
	DB '     STONES N BONES     '
	DB '  1.     -              '
	DB '  2.     -              '
	DB '  3.     -              '
	DB '  4.     -              '

	DB " HI HACKER!  READ THE NOTE ABOVE! "

PROTTXT		DB 0,0,'MANUAL PROTECTION',0,0
WHATS_HAPPENING	DB 24*2 DUP (' '),0 ,0,0,0
		DB 24*2 DUP(0)

WORDTXT	DB LINJEN DUP(0)
AFTER_PROT	DB 24 DUP (' '),5 DUP (0)
		DB 15 DUP (0)
soundcfg db 'Sound.Cfg',0,'$'
drv	db '\mAsM\ds20\rEsIpLaY\rEsIpLaY.eXe',13 dup (0),'$'
parms	db 20 dup (0)
intromod	db 'Intro.Mod',0,'$'
if	demover
intromod2	db 'Intro.Mod',0,'$'
else
intromod2	db 'Mod2.Mod',0,'$'
endif

vikingpaloff dw ?
t21stpaloff dw ?
T21ST_REAL_PAL DW ?
VIKING_REAL_PAL DW ?
intpic2paloff dw ?
demotext2paloff dw ?
fld_logopaloff dw ?
presentpaloff dw ?
blackpal db 256*3 dup(0)
whitepal db 256*3 dup (63)
blackpaloff=offset blackpal
whitepaloff=offset whitepal
egapal db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0
banpek	dw 0
if	demover
VARTABELL DW 0+20
tabletabell dw new_cov2seg
else
vartabell dw 0,240,240+14*2,240+14*4,240+95+14*4,240+95*2+14*4,240+95*3+14*4
tabletabell dw table0
	dw fontseg
	dw fontseg2
	dw table1
	dw table2
	dw table3
	dw table4
endif
tablepaloff dw ?,?,?,?,?,?,?
nuvarande db 3*64 dup (0)
RASTATAB label byte
rastas=8 ;7
Cnt =-(rastas-1)*(rastas-1)
rept 95/rastas+rastas+1		;trunk fel
 gnu=cnt
 rept rastas
  if (gnu GT -1)
  if (gnu LT 95)
   db gnu
  endif
  endif
 gnu=gnu+rastas-1
 endm
 db -1
cnt=cnt+rastas
endm

offret=0
fontlist label word
rept '-'
	dw -1	;240*80+80*14+4*19
endm
	DW 38*4+80*13+240*80		;-
	DW 36*4+80*13+240*80		;.
	dw 240*80+80*14+4*19		;\ (=SPACE)
rept 10		;the siffers!!
	dw offret+240*80
	offret=offret+4
endm
	DW 37*4+80*13+240*80		;:

rept 'A'-'0'-10-1	;the mellan bokstefhers!!
	dw 39*4+80*13+240*80
endm
rept 10		;the bokstefhers!!
	dw offret+240*80
	offret=offret+4
endm

rept 16
	dw offret+80*13+240*80
	offret=offret+4
endm
rept 255-'Z'
	dw -1	;240*80+80*14+4*19
endm
data ends

IF DEMOVER
fontseg		segment para public 'data'
font DB ?
ends

fontseg2		segment para public 'data'
font2 DB ?
ends
ELSE
fontseg		segment para public 'data'
extrn font:byte
ends

fontseg2		segment para public 'data'
extrn font2:byte
ends
ENDIF


intpic2seg	segment para public 'data'
extrn	intpic2:byte
ends

presentseg	segment para public 'data'
extrn	present:byte	
ends



fl1seg	segment para public 'data'
extrn	fl1:byte	
ends

fl2seg	segment para public 'data'
extrn	fl2:byte	
ends

if demover
new_cov2seg	segment para public 'data'
extrn	new_cov2:byte
ends

table0	segment para public 'data'
table_0 db ?
ends

table1	segment para public 'data'
table_1 db ?
ends

table2	segment para public 'data'
table_2 db ?
ends

table3	segment para public 'data'
table_3 db ?
ends

table4	segment para public 'data'
table_4 db ?
ends


else
table0	segment para public 'data'
extrn	table_0:byte
ends

table1	segment para public 'data'
extrn	table_1:byte
ends

table2	segment para public 'data'
extrn	table_2:byte
ends

table3	segment para public 'data'
extrn	table_3:byte
ends

table4	segment para public 'data'
extrn	table_4:byte
ends

endif

IF DEMOVER
hsl1seg	segment para public 'data'
hsl1 DB ?
ends

hsl2seg	segment para public 'data'
hsl2 DB ?
ends
ELSE
hsl1seg	segment para public 'data'
extrn	hsl1:byte
ends

hsl2seg	segment para public 'data'
extrn	hsl2:byte
ends
ENDIF
synca macro
	local venta
	push	es DS
	mov	ax,40h
	mov	es,ax
	MOV	AX,0
	MOV	DS,AX
venta:	
	MOV	AX,8
	PUSHF
	CALL	DWORD PTR DS:[66H*4]
	inc	cs:slumpen	
	cmp	byte ptr es:[76h],0
	jz	venta
	mov	byte ptr es:[76h],0
	pop	DS es
endm

include c:\source\macros1.asm
include fantasie.mac
include c:\source\macros3.asm

code segment para public 'code'
extrn	unpklbm16:near
extrn	unpklbm:near
firstscan db -1
start:

assume	cs:code
assume	ds:data
PUSHA
PUSH	DS
;==============================================================================

	PUSHA
	PUSH	DS ES

	CALL	LOAD_TOGGLAREN			;OPTIONS SCREEN SETUP
	JNC	TOGGLAREN_READY
	MOV	TOGGLAREN.S_SCROLLING,1
TOGGLAREN_READY:

	MOV	AH,2CH			;GET TIME
	INT	21H
	MOV	CS:SLUMPEN,DX

	POP	ES DS
	POPA

	mov	ax,0
	int	keyhandler	;kolla om fîrsta gÜngen . . 
	cmp	ah,false
	je	notfirstime_SO_NO_PMTEST
;******************************************************************************
;*                          Test protected mode                               *
;******************************************************************************
if pm_test
	SMSW AX
	TEST AX,1
	JZ	NO_PROTECTED_MODE
	JMP	_PM
else
	jmp	NO_PROTECTED_MODE
endif
bannumber db 1
_PM:	push	ds
;	debugmess 0,0,'pm detected'
	pusha
	push	es ds
	BorLand
	Hugo	PM_Mess
	pop	ds es
	popa
	pop	ds
;***** check keyb
IN_OCH_UT_IGEN:
	IN	AL,60H
	CMP	AL,19H
	je	no_protected_mode
	CMP	AL,01
	JNE	IN_OCH_UT_IGEN
;**************
	MOV	AX,4C01H
	INT	21H
NO_PROTECTED_MODE:
notfirstime_SO_NO_PMTEST:
;==============================================================================
POP	DS
POPA
;******************************************************************************
;	debugmess 0,0,'loading intro'


	move es,ds
	move ds,DATA
	mov bx,es
	mov cs:minneskillen,bx

	mov	ax,12h	;anders
	int	10h
	call	set_mcgab
	call	set240
	move es,ds
	move ds,data
	call	set_pal		;slÑck paletten	
	CALL	UNPKPICS
	mov bx,cs:minneskillen

	mov es,bx
	neg bx
if	demover		;ingen îverrÑnning!!
	add bx,qsune
else
	add bx,dumpningsplats
endif
	add bx,1024/16
	mov ax,4a00h
	int 21h			;shrink block

	call	init_sound

	mov ah,48h
	mov bx,0ffffh		;sÜ mycket minne har ingen!!
	int 21h
	PUSH	BX
;	debugval 0,5,bx,'Free mem after intro + SDR load'
	mov	ah,21
	int	66h
	test	al,1		;e de gus eller nosnd???
	POP	BX
	jne	gussan
	cmp bx,basememreq
	ja  enough_mem
	jmp	not_enough
gussan:
	cmp bx,nosoundmemreq
	ja  enough_mem
	jmp	not_enough


;
;********************  really intro ******************************************
;
enough_mem:

	move es,ds
	move ds,data
	jmp	minnesaron
minneskillen dw ?
minnesaron:
	CALL	MAKE_IT_NICE	;THE OPTIONS SCREEN

;******************** Om fîrsta gÜngen spela mod 1 ******************
	mov	ax,0
	int	keyhandler	;kolla om fîrsta gÜngen . . 
	cmp	ah,false
	je	notfirstime_sonofirsttimemoduleplaying
	MOV	DX,OFFSET introMOD
	jmp	moduleloaded
notfirstime_sonofirsttimemoduleplaying:
	MOV	DX,OFFSET introMOD2
moduleloaded:
	MOV	AX,18		;fn 18
	INT	66H		;LOAD MODULE
	IF_ERROR 1,outofmemory
	IF_ERROR 3,cantfindmod
	IF_ERROR 4,errorloadingmod


	move	ds,data
	move	es,data
	mov	dx,offset intromod
	openfile2 dx
	mov	buppen_filen,bx
	filepoint bx,pos1,pos2
	usel=offset chksum
	readfile bx,2,usel
	CLC	

;**************************** flyttad pga cp idÇ!!!

	CALL	READ_HIGHS
	mov	ax,11
	move	es,cs
	mov	dx,offset dumretf
	mov	bl,255
	int	66h		;ORDER VBLANK

	mov	ax,4
	mov	bx,11000
	mov	cx,0	;config's rate
	int	66h
	IF_ERROR 1,OUTOFMEMORY
	IF_ERROR 2,INIT_ERR

	mov	ax,12
	move	es,cs
	mov	dx,offset creatretf
	mov	cx,220+10
	mov	bl,255
	int	66h		;ORDER RASTER



if demover 
jmp	firsttime_init
endif

	mov	banpek,00b
	mov	cs:textpek,2
	mov	ax,0
	int	keyhandler
	cmp	bl,3
	jb	no_high_bana
	mov	banpek,10b
	mov	cs:textpek,4
	MOV	TEXTLISTA[0],OFFSET HITEXT2
no_high_bana:
	cmp	ah,true
	je	firsttime_init
	mov	cx,banpek
if finmenu
else
	MOV	CS:TEXTPEK,2
endif
	SYNCA
	setvga
	setlores
	call	set240
	SYNCA
	CALL	SET_EGAPAL
	jmp	choosern_init
firsttime_init:

;320*240,256
	setscr	0
	wait_music firstpictime
ALL_OVER_AGAIN:
	fade	20,data,blackpaloff,data,pellevin1
	wait_music t21sttime
	fade	20,data,pellevin1,data,blackpaloff
	checkquit
	setscr	vikingadr
	fade256	10,data,whitepaloff,data,pellevin2
	wait_music vikingtime
	fade256	20,data,pellevin2,data,blackpaloff
	checkquit

	fade256	1,data,blackpaloff,data,blackpaloff
	setscr	fld_logopos/4*320

	fade256	10,data,whitepaloff,fl1seg,fld_logopaloff
	wait_music fld_logotime
	fade256	20,fl1seg,fld_logopaloff,data,blackpaloff
	checkquit

	setscr	0
	
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
	move	es,0a000h
	mov	cx,320/4*240/2
	mov	di,0
	mov	ax,0
GNUOR:	stosw
	LOOP	GNUOR

	mova	es,cs
	mov	di,offset cs:faded_pal
	mov	cx,256*3
	xor	al,al
	rep	stosb		;rensa pallen sÜ att set_pal slÑcker
	CALL	SET_PAL256

	fillmusicbuf

	mov	ax,0
	mov	bx,0
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,presentseg
	call	unpklbm
	mov	presentpaloff,dx

	fade	8,data,blackpaloff,presentseg,presentpaloff
	wait_music presenttime
	fade	20,presentseg,presentpaloff,data,blackpaloff
	checkquit

	


	cleargfx
	CALL	BLANK_OFF

	MOV	AX,12H
	INT	10H  ;********************* 640*480,16 *******************
	CALL	BLANK_ON

	
;	setvga
;	sethires

	FILLMUSICBUF
	fade	1,data,blackpaloff,data,blackpaloff
	FILLMUSICBUF	
	
	CALL	BLANK_OFF
	CALL	SET_EGAPAL
	CALL	BLANK_ON
	FILLMUSICBUF
	
	mov	ax,0
	mov	bx,intpic2pos
	mov	cx,640
	mov	bp,0b
	mov	dx,0
	move	es,intpic2seg
	call	unpklbm
	mov	intpic2paloff,dx
	FILLMUSICBUF
	
	fade	20,data,blackpaloff,intpic2seg,intpic2paloff
	wait_music fantasietime
	fade	20,intpic2seg,intpic2paloff,data,blackpaloff
;************ HéRIFRèN
	fillmusicbuf
	checkquit
	jmp	trasselsudd
skip_the_intro_bra_att_hoppa_till_da:
	fade	1,data,blackpaloff,data,blackpaloff
	setvga
	sethires
	fade	1,data,blackpaloff,data,blackpaloff
trasselsudd:		;kan de bli rîrigare??

	SYNCA
	setvga
	setlores
	call	set240
	SYNCA
	CALL	SET_EGAPAL



;******************************************************************************
;*                            MANUAL SKYDDET                                  *
;******************************************************************************
JMP SVEN_GURKA

GetKey:
read_again_my_friend:	
	move	ds,data
	mov	ax,12h
	int	keyhandler	;report scancode 0=no key pressed     cp! calla isÑllet
	push	ax
	synca
	pop	ax
	cmp	al,0
	je	read_again_my_friend
	mov	bx,offset rekord_tabell
	xlatb
retn

GetKey2:
	move	ds,data
	mov	ax,12h
	int	keyhandler	;report scancode 0=no key pressed     cp! calla isÑllet
	push	ax
	synca
	pop	ax
	mov	bx,offset rekord_tabell
	xlatb
retn

PRINTA	MACRO	TEXT,SCR_DEST,COLOR
	LOCAL	TEXTEN,STARTA
	JMP	STARTA
TEXTEN	DB TEXT,0
STARTA:	PUSH	SCR_DEST
	PUSH	OFFSET TEXTEN
	MOV	DL,COLOR
	POP	BX
	POP	DI
	CALL	NXTCHAR
	ENDM

PRINTA2	MACRO	TEXTOFFS,SCR_DEST,COLOR
	PUSH	SCR_DEST
	LEA	AX,TEXTOFFS
	PUSH	AX
	MOV	DL,COLOR
	POP	BX
	POP	DI
	CALL	NXTCHAR2
	ENDM

INPUTA	MACRO	DATA_DEST,MAXLEN,SCR_DEST,COLOR
	PUSH	OFFSET DATA_DEST
	PUSH	SCR_DEST
	MOV	DH,MAXLEN
	MOV	DL,COLOR
	POP	DI
	POP	SI
	CALL	DOTHEINPUT
	ENDM

NXTCHAR:MOV	AL,CS:[BX]
	OR	AL,AL
	JZ	EOTXT
	PUSH	DI
	PUSH	BX
	PUSH	DX
	CALL	PUTCHAR2
	POP	DX
	POP	BX
	POP	DI
	INC	BX
	ADD	DI,FONTW
	JMP	NXTCHAR
EOTXT:	RETN

NXTCHAR2:
	MOV	AL,DS:[BX]
	OR	AL,AL
	JZ	EOTXT
	PUSH	DI
	PUSH	BX
	PUSH	DX
	CALL	PUTCHAR2
	POP	DX
	POP	BX
	POP	DI
	INC	BX
	ADD	DI,FONTW
	JMP	NXTCHAR2
BLANK_ON:
	PUSHA
	FILLMUSICBUF
	mov	ax,24
	mov	bl,255
	INT	66H		;order vblank
	POPA
	RETN
BLANK_OFF:
	PUSHA
	FILLMUSICBUF
	MOV	AX,24
	MOV	BL,0
	INT 66H
	POPA
	RETN

ANDHAMTNING PROC NEAR
FILLMUSICBUF
	PUSHA
	MOV	CX,20
KULO:
	push	es DS CX
	mov	ax,40h
	mov	es,ax
	MOV	AX,0
	MOV	DS,AX
ventaTT:	MOV	AX,8
	PUSHF
	CALL	DWORD PTR DS:[66H*4]
	cmp	byte ptr es:[76h],0
MOPAR:	;EJ KORTA LOOPAR!
REPT 1000
	NOP
ENDM
	jz	ventaTT
	mov	byte ptr es:[76h],0
	pop	CX DS es
	LOOP	KULO	
	POPA
	RETN
ANDHAMTNING ENDP

PUTCHAR2 PROC NEAR	;INPUT:AL=CHAR,DI=SCR_DEST,DL=COLOR
	MOV	BL,AL
	PUSH	BX
	PUSH	DI
	MOV	AX,DI
	NIL	DX
	MOV	BX,320
	DIV	BX
	MOV	DX,AX
	PUSH	DX		;YPOS Pè STACKEN
	MOV	BX,320
	MUL	BX
	POP	DX
	POP	DI
	SUB	DI,AX
	MOV	AX,DI
	POP	BX
;* buf1 *	;visa sid 0, skriv sid 1
	pusha
	MOVE	ES,0A000H
	MOVE	DS,DATA
	MOV	CS:SIDA,44580
	MOV	CS:FONTEN,0
	XCHG	AX,AX
	XCHG	AX,DX
	XCHG	DX,DX
	CALL	PUTCHAR

	synca
	setscr	44580
	synca

	popa
	XCHG	AX,AX
	XCHG	AX,DX
	XCHG	DX,DX

;* buf2 *	
	MOVE	ES,0A000H
	MOVE	DS,DATA
	MOV	CS:SIDA,0
	MOV	CS:FONTEN,0
	CALL	PUTCHAR

	synca
	setscr	0
	synca

	RETN

comment\
	SET_ES	0A000H
	NIL	AH
	SHL	AX,3
	MOV	BP,AX
	ADD	BP,OFFSET FONTMONO
	MOV	CX,8
NXTBYTE:PUSH	DI
	MOV	AL,10000000B
NXTPIXL:MOV	AH,DS:[BP]
	AND	AH,AL
	JZ	NTPIX
	MOV	BYTE PTR ES:[DI],DL
	JMP	PIXPUTREADY
NTPIX:	MOV	BYTE PTR ES:[DI],0
PIXPUTREADY:
	INC	DI
	SHR	AL,1
	OR	AL,AL
	JNZ	NXTPIXL
	POP	DI
	ADD	DI,320
	INC	BP
	LOOP	NXTBYTE
	RETN
\
PUTCHAR2 ENDP

DOTHEINPUT:
	MOV	BP,SI
	MOV	CX,SI
	ADD	CL,DH
	ADC	CH,0
NXTINP:
	CALL	WINDOWS_PRINT
	call	GetKey	;INT	16H (nÑstan)
	CMP	AL,13
	JE	ENTERT
	CMP	AL,8
	JE	BACKSPACE
	CMP	AL,32
	JB	NXTINP
	CMP	AL,122
	JA	NXTINP
	CMP	AL,96
	JBE	UCASE
	SUB	AL,32
UCASE:	MOV	BYTE PTR DS:[SI],AL
	MOV	BYTE PTR DS:[SI+1],0
;	PUSHA
;	CALL	PUTCHAR2
;	POPA
;	ADD	DI,FONTW
	CMP	SI,CX
	JE	NXTINP
	INC	SI
	JMP	NXTINP
ENTERT:	MOV	BYTE PTR DS:[SI],0
	RETN
BACKSPACE:
	CMP	SI,BP
	JE	NXTINP
	DEC	SI
	MOV	WORD PTR DS:[SI],0
;	SUB	DI,FONTW
;	PUSHA
;	MOV	AL,0		;INTE DU MIN BRUTUS!
;	CALL	PUTCHAR2
;	POPA
	JMP	NXTINP

VAL2DECASC MACRO STRINGEN,VALUE
	PUSHA
	PUSH	OFFSET STRINGEN
	PUSH	VALUE
	POP	AX
	POP	DI
	
	NIL	DX
	MOV	BX,10000
	DIV	BX
	PUSH	DX
	MOV	BX,OFFSET HEXTBL
	XLATB
	MOV	DS:[DI],AL

	POP	AX
	NIL	DX
	MOV	BX,1000
	DIV	BX
	PUSH	DX
	MOV	BX,OFFSET HEXTBL
	XLATB
	MOV	DS:[DI+1],AL

	POP	AX
	MOV	BL,100
	DIV	BL
	PUSH	AX
	MOV	BX,OFFSET HEXTBL
	XLATB
	MOV	DS:[DI+2],AL

	POP	AX
	MOV	AL,AH
	NIL	AH
	MOV	BL,10
	DIV	BL
	PUSH	AX
	MOV	BX,OFFSET HEXTBL
	XLATB
	MOV	DS:[DI+3],AL

	POP	AX
	MOV	AL,AH
	MOV	BX,OFFSET HEXTBL
	XLATB
	MOV	DS:[DI+4],AL
	MOV	BYTE PTR DS:[DI+5],0
	POPA
ENDM

ARRLEFT	MACRO STRINGEN,CHAREN
	LOCAL	NOMORE,NASTAC,NOBYTE,MOVSBL
	PUSHA
	PUSH	ES
	MOV	DH,CHAREN
	PUSH	OFFSET STRINGEN
	POP	BX
	PUSH	BX
	MOV	SI,BX
	NIL	CX
NASTAC:	LODSB
	CMP	AL,DH
	JNE	NOMORE
	CMP	BYTE PTR DS:[SI],0	;SI-1 OM DET BLIR FEL
	JZ	NOMORE
	INC	CX
	JMP	NASTAC
NOMORE:
	POP	DI
	JCXZ	NOBYTE
	MOVE	ES,DS
	MOV	SI,DI
	ADD	SI,CX
MOVSBL:	MOVSB
	CMP	BYTE PTR DS:[SI-1],0
	JNZ	MOVSBL
NOBYTE:	POP	ES
	POPA
ENDM


STRADD	MACRO DEST,SOURCE
	PUSHA
	PUSH	OFFSET DEST
	PUSH	OFFSET SOURCE
	POP	SI
	POP	DI
	STRLEN	AL,DI
	NIL	AH
	ADD	DI,AX
	STRCOPY	DI,SI
	POPA
ENDM
tudor:
	pusha
	move	es,0b000h
	mov	si,offset ordlista
	mov	di,0
	move	ds,data
	mov	cx,2000
huko:	movsb
	inc	di
	loop	huko
	popa
retn
SVEN_GURKA:
fillmusicbuf
;*************** TILL HIT
	mova	es,cs
	mov	di,offset cs:faded_pal
	mov	cx,256*3
	xor	al,al
	rep	stosb		;rensa pallen sÜ att set_pal slÑcker
	CALL	SET_PAL256
choosern_init:
if demover
	CALL	BLANK_OFF
	setvga
	setlores
	call	set240
	CALL	BLANK_ON
	
;	MOV	AX,0EH
;	SIMINT	10H			;640*200,16
endif
	
	FILLMUSICBUF
	cleargfx
	
if demover
	fade	1,data,blackpaloff,data,blackpaloff
else	
	SETLORES ;************************ 640*240*16 *********************
	fade	3,data,blackpaloff,data,blackpaloff
;	slackA 320
;	slack	1
endif	
if demover
else
;************ checksum!!!!
	mov	si,offset cs:START_KEK2
	mov	al,checktrim2
	mov	cx,offset cs:stop_kek2-offset cs:start_kek2
liiirarn:
	add	ax,cs:[si]
	inc	si
	loop	liiirarn
	nil	ah
	or	ax,ax
;	jne	pinball_fantasies_integretet_ar_krankt
;*********************



;erbjud vÑxling mellan 2 st 16-paletter
	synca
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,10h+20h
 	out	dx,al
	jmp	$+2
	inc	dl
	in	al,dx
	dec	dl
	or	al,80h
	out	dx,al
endif
	FILLMUSICBUF	
IF DEMOVER
	JMP	JAGARN
ELSE	
;setscr 240*80+95*3*80
;packa upp & spara bilderna RèTT!!
	mov	ax,hsl1seg
	call	packa_upde
	mov	di,offset savearea1
	call	rave_party
	mov	ax,hsl2seg
	call	packa_upde
	mov	di,offset savearea2
	call	rave_party
	jmp	jagarn
packa_upde:
	mov	cx,640
	mov	bx,0		
	mov	bp,0b
	mov	dx,0
	mov	es,ax
	mov	bx,0
	mov	ax,0
	call	unpklbm
ENDIF
retn

rave_party:
	call	aronsson_bort
	mov	bl,0
	mov	cx,4
	move	es,data
	move	ds,0a000h
ynkes:
	push	cx
	setrbpl	bl
	mov	si,0
	mov	cx,lhojd
lajlas_kusin:
	push	cx
	mov	cx,lbredd/8
	rep	movsb
	add	si,640/8-lbredd/8
	pop	cx
	loop	lajlas_kusin
	inc	bl
	pop	cx
	loop	ynkes
	move	ds,data
retn	

put_the_hslogo1:
	pusha
	mov	bx,cs:textpek
	cmp	textlista[bx-2],-1
	jne	nologga1
	mov	si,offset savearea2
	mov	bp,0+128/8+4+3
	call	perverted_rave_party
	add	cs:sida,80*10

nologga1:
	popa
retn
put_the_hslogo2:
	pusha
	mov	bx,cs:textpek
	cmp	textlista[bx-2],-1
	jne	nologga2
	mov	si,offset savearea1
	mov	bp,44580+128/8+4+3
pinball_fantasies_integretet_ar_krankt:
	call	perverted_rave_party
	add	cs:sida,80*10

nologga2:
	popa
retn

perverted_rave_party:
	call	aronsson_bort	;jasÜ aronsson fÜr inte va med pÜ rave
;bp = dest, si = sÜs
	mov	bl,1
	mov	cx,4
	move	es,0a000h
ynke:
	push	cx
	setwbpl bl
	mov	cx,loggasize
	mov	di,bp

	mov	cx,lhojd
lajlas_syssling:
	push	cx
	mov	cx,lbredd/8
	rep	movsb
	add	di,640/8-lbredd/8
	pop	cx
	loop	lajlas_syssling

	shl	bl,1
	pop	cx
	loop	ynke
retn	
	
jagarn:
if	demover
	slackA 320
	mov	cx,1
else
	slackA 130
	SYNCA
	mov	cx,7	;Fonten ligger pÜ slutet!! Inte lÑngre, de funkade ej!!
endif
	mov	bx,0		

makefjups:
	push	cx
;	mov	cx,320
	mov	cx,640
	CMP	BX,6
	JB	NOCHG
	MOV	CX,55*8
NOCHG:
	FILLMUSICBUF
	mov	bp,0b
	mov	dx,0
	mov	ax,tabletabell[bx]
	mov	es,ax
	push	bx
	mov	bx,vartabell[bx]
	mov	ax,0
	call	unpklbm
	FILLMUSICBUF
	pop	bx
	mov	tablepaloff[bx],dx
	add	bx,2
	pop	cx
	loop	makefjups
IF DEMOVER
ELSE
	call	aronsson
	call	crunchpics
	call	movelogobar
	call	copy_pf_loggan
ENDIF
if demover
else
	setscr 130/4/2
;	fade	1,tabletabell[0],tablepaloff[0],tabletabell[0],tablepaloff[0] ;SÑtt rÑtt!!
endif
if demover
;	mov	al,0
;	mov	bx,8
;	call	julius
	SETSCR	80*28
	SYNCA
	fade	40,data,blackpaloff,tabletabell[0],tablepaloff[0] ;SÑtt rÑtt!!
	jmp	demoversion
endif

SPRINTA MACRO THETEXT,THEPOS
	LOCAL	NXXXXT,ENDOFIT
	LEA	DI,THEPOS
	MOVE	ES,DS
	LEA	SI,THETEXT
	NIL	CH
NXXXXT:	MOV	CL,[SI]
	JCXZ	ENDOFIT
	MOV	[DI],CL
	INC	SI
	INC	DI
	JMP	SHORT NXXXXT
ENDOFIT:
	MOVE	ES,0A000H	;CP, OCH INTE NôDVéNDIGT!
ENDM

;*******************************************************************
;	debugmess 0,0,'yo man!'
	fade	3,data,blackpaloff,data,blackpaloff
nuvaranden=offset nuvarande
	mov	al,16
	mov	bx,10
	call	julius		;Ceasar sÑtter en palett!!
	mov	al,0
	mov	bx,10
	call	julius

	movpal	tabletabell[6],tablepaloff[6],data,nuvaranden+16*3
	movpal	tabletabell[8],tablepaloff[8],data,nuvaranden

	MOV	CS:CHANGE16PAL,TRUE

	slacka	130
	
	mov	cx,4
loket:
	push	cx
	synca
	pop	cx
	loop	loket

	MOV	CS:SIDOPEK,130/8
	MOV	CS:SIDOBAR,TRUE
	wait_sync_spec2 20
	slackA 320
;************************** HéR E NYA SKYDDET!!!!!!!!!! ***********************
	call	aronsson

	MOVE	DS,DATA
	MOVE	ES,DATA
;****************** checksummat ******************
start_kek2:
	mov	al,2eh		;Get CMos checksum!
	out	70h,al
	in	al,71h


	mov	bl,al
	mov	al,2fh
	out	70h,al
	in	al,71h
	mov	bh,al
	mov	ax,chksum
	XOR	BX,10010000B
	ROL	BX,1
	mov	chksum,bx
	SUB	ax,bx
	ADD	CS:AVSLUTA_PSEUDO,AX
	CMP	CS:AVSLUTA_PSEUDO,OFFSET CS:SHOWMENU
	MOV	CS:AVSLUTA_PSEUDO,OFFSET CS:AVSLUTA
	je	no_skydd	;lÜter faligt!! Ñr Ñnnu farligare!!!

	call	getkey2		;vill du se en stjÑrna, se(mikolon) pÜ mig! (e de erroR flynn??)

	MOVE	ES,0A000H
	NIL	DX
	MOV	ax,CS:SLUMPEN ;ax=slump

COMMENT\
	MOV	BX,NOOFWORDS
	DIV	BX
	MOV	AX,DX
\
	AND	AX,63

	mov	bx,size wordstruc
	mul	bx
	mov	thepost,ax

	mov	si,thepost
	mov	al,ordlista[si].theword		;word
	ror	al,1
;stop_kek2:

	xor	al,10100010b
	nil	ah
	VAL2DECASC TEMPTEXT,AX
	ARRLEFT TEMPTEXT,'0'
	STRADD	TEXTEN1,TEMPTEXT
	STRADD	TEXTEN1,TEXTEN2

	mov	si,thepost
	mov	al,ordlista[si].theline		;line
	ror	al,1
	xor	al,10100010b
	nil	ah
	VAL2DECASC TEMPTEXT,AX
	ARRLEFT TEMPTEXT,'0'
	STRADD	TEXTEN3,TEMPTEXT

	STRADD	TEXTEN3,TEXTEN4

	MOV	SI,THEPOST
	mov	al,ordlista[si].thepage		;page
	ror	al,1
	xor	al,10100010b
	nil	ah
	VAL2DECASC TEMPTEXT,AX
	ARRLEFT TEMPTEXT,'0'
	STRADD	TEXTEN3,TEMPTEXT
	
;	STRADD	TEXTEN3,TEXTEN5		;'.'!!!

;	PRINTA2 TEXTEN1,90*320+8,TEXTCOLOR
;	PRINTA2 TEXTEN2,100*320+8,TEXTCOLOR

	STRLEN	AL,TEXTEN1
	NIL	AH
	INC	AX		;NOLLAN OXè!
	MOV	DI,OFFSET WHATS_HAPPENING
	DATAMOV	DI,TEXTEN1,AX
	ADD	DI,AX
	STRLEN	AL,TEXTEN3
	NIL	AH
	INC	AX
	DATAMOV	DI,TEXTEN3,AX

;	SPRINTA TEXTEN1,PROTTXT+4*24
;	SPRINTA TEXTEN3,PROTTXT+5*24

	call	aronsson
	call	showtext_prot

NO_SKYDD:
stop_kek2:
;********************************SLUT Pè SKYDD*********************************
;******************************************************************************
	mov	cs:menubaren_on,true
	call	aronsson
	call	rastraclear
	mov	cs:deccet,menutime*60
	jmp	showpics
;******************************************************************************
;*                               The Chooser                                  *
;******************************************************************************
;
choosern:
	mov	cs:menubaren_on,true
	call	showtext
	cmp	cs:menunext,true
	jne	noshow
	mov	cs:menunext,false
	call	showmenu
noshow:

showpics:
	wait_sync_spec 20
	test	banpek,10b
	jne	pics2
	mov	al,16
	mov	bx,6
	call	julius		;Ceasar sÑtter en palett!!
	mov	al,0
	mov	bx,8
	call	julius
	
nuvaranden=offset nuvarande
	movpal	tabletabell[6],tablepaloff[6],data,nuvaranden+16*3
	movpal	tabletabell[8],tablepaloff[8],data,nuvaranden
;*********** set 2 palette modes (on rasterint)  **************
	MOV	CS:CHANGE16PAL,TRUE
	mov	bp,0
	call	rastra
	jmp	keyread
pics2:
	mov	al,16
	mov	bx,10
	call	julius
	mov	al,0
	mov	bx,12
	call	julius

	movpal	tabletabell[10],tablepaloff[10],data,nuvaranden+16*3
	movpal	tabletabell[12],tablepaloff[12],data,nuvaranden
;*********** set 2 palette modes (on rasterint)  **************
	MOV	CS:CHANGE16PAL,TRUE
	mov	bp,55*95*2
	call	rastra
	
	mov	cs:deccet,menutime*60
keyread:
	synca
	mov	ax,1		;Read key!!!
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
	cmp	al,01
	je	quit_ing
	
	cmp	al,3bh		;f1
	je	f1
	cmp	al,3ch		;f2
	je	f2
if finmenu
	cmp	al,3dh		;f3
	je	f3

	cmp	al,3eh		;f4
	je	f4
endif

	cmp	al,3fh		;f5
	je	f5

	cmp	al,39h	;space
	je	space

;if	finmenu
;	cmp	al,28	;entera
;	je	space
;else
	cmp	al,28	;entera
	je	entera
;endif

	dec	cs:deccet
	jz	WAITEND
	jmp	keyread
entera:
	xor	banpek,10b
;	MOV	CS:TEXTPEK,2
	add	cs:textpek,2
	mov	bx,cs:textpek
	cmp	word ptr [bx],0
	jnz	boxk
	mov	cs:textpek,offset textlista+2
boxk:
	MOV	TEXTLISTA[0],OFFSET HITEXT1
	JZ	NEDU
	MOV	TEXTLISTA[0],OFFSET HITEXT2
NEDU:

	CALL	RASTRACLEAR
	mov	cs:deccet,menutime*60
	jmp	SHOWPICS

space:
WAITEND:
	xor	banpek,10b
	MOV	TEXTLISTA[0],OFFSET HITEXT1
	JNZ	NEDU_DUDU
	MOV	TEXTLISTA[0],OFFSET HITEXT2
NEDU_DUDU:

	
	MOV	CS:DECCET,MENUTIME*60
	JMP	CHOOSERN
f5:
	call	showmenu	;jump into menu mode
	jmp	showpics	;when menu ready, show the pics again!
f1:
	mov	bl,1
	jmp	savebana
f2:
	mov	bl,2
	jmp	savebana
f3:
	mov	bl,3
	jmp	savebana
f4:
	mov	bl,4
	jmp	savebana
	
savebana:	
	mov	bh,0

if	finmenu
else
	add	bx,banpek
endif

	mov	ax,0ffffh
	int	keyhandler
	MOV	BX,OFFSET CS:AVSLUTA_PSEUDO-2
	INC	BX
	INC	BX
	MOV	AX,CS:[BX]
	jmp	AX
f1t:
	mov	bl,1
	jmp	savebana2
f2t:
	mov	bl,2
	jmp	savebana2
f3t:
	mov	bl,3
	jmp	savebana2
f4t:
	mov	bl,4
	jmp	savebana2
	
savebana2:
		
	mov	bh,0
if finmenu
else
	add	bx,banpek
endif
	mov	ax,0ffffh
	int	keyhandler
	setscr	44580		;bîr ligga pÜ rasterint
	fade3b	20


	call	aronsson
	call	clearall
	setscr	0		;bîr ligga pÜ rasterint
	MOV	CS:CHANGE16PAL,true

	pop	ax	;retn tabort
	MOV	BX,OFFSET CS:AVSLUTA_PSEUDO-2
	INC	BX
	INC	BX
	MOV	AX,CS:[BX]
	jmp	AX
deccet	dw ?
quit_ing:
grynet=offset nuvarande
	fadeM	80,data,grynet,data,blackpaloff
SPYAN_STEWART:
	cleargfx
	CALL	BLANK_OFF
	MOV	CS:CHANGE16PAL,FALSE
	mov	bx,0		;Quitta helt Ü hÜllet!!
	mov	ax,0ffffh
	int	keyhandler
;	mov	ax,3
;	int	10h

	;uninstall fn0
	mov	ax,0
	int	66h

	mov	ax,3
	int	10h

	MOVE	DS,DATA
	MOV	BX,BUPPEN_FILEN
	CLOSEFILE BX

	CALL	SAVE_TOGGLAREN
	CALL	BEFORE_STARTING

;	mov	ah,48h
;	mov	bx,0ffffh
;	int	21h

	mov	ax,4c00h
	int	21h

avsluta:
if	demover
else
	fadeM	80,data,grynet,data,blackpaloff
endif
	jmp	quit
not_enough:
	mov	bx,0		;Quitta helt Ü hÜllet!!
	mov	ax,0ffffh
	int	keyhandler
	
	;uninstall fn0
	mov	ax,0
	int	66h			;UNINST MS

	mov	ax,3
	int	10h
	mov	dx,offset notenoughmess
	mov	ax,900h
	int	21h	

	MOVE	DS,DATA
	MOV	BX,BUPPEN_FILEN
	CLOSEFILE BX

	CALL	SAVE_TOGGLAREN
	CALL	BEFORE_STARTING

;	mov	ah,48h
;	mov	bx,0ffffh
;	int	21h		;why?
	mov	ax,4c00h
	int	21h

julius:
	mov	si,tablepaloff[bx]
	push	ds
	mov	ds,tabletABELL[bx]
	MOV	CX,16*3
	mov	dx,3c8h
	;al Ñr: 0-15, 16-31
	out	dx,al
	mov	dx,3c9h
	repoutsb
;	rep	outsb
	pop	ds
retn

SHIFTPAL MACRO NO,SEGGE,OFFE
	LOCAL	SHIFFE
	MOV	CX,NO*3
	MOVA	ES,SEGGE
	MOVA	SI,OFFE
SHIFFE:	SHL	BYTE PTR ES:[SI],2
	INC	SI
	LOOP	SHIFFE
ENDM
SHIFT_UP_PALETTES:
	SHIFTPAL 32,t21st1seg,t21st_REAL_pal
	SHIFTPAL 256,viking2seg,viking_REAL_pal
	SHIFTPAL 256,fl1seg,fld_logopaloff
	SHIFTPAL 256,presentseg,presentpaloff
	SHIFTPAL 16,intpic2seg,intpic2paloff
IF DEMOVER
	SHIFTPAL 16,new_cov2seg,tablepaloff
ENDIF
	RETN
	
	in	al,60h
	mov	ah,al
feel_key:
	push	ax
	FILLMUSICBUF	
	pop	ax
	in	al,60h
	cmp	al,ah
	jne	fadedown

	jmp	feel_key	
fadedown:
;	fade	40,dtseg,demotext2paloff,data,blackpaloff

quit:
	;uninstall fn0
	mov	ax,0
	int	66h

	MOVE	DS,DATA
	MOV	BX,BUPPEN_FILEN
	CLOSEFILE BX

	CALL	SAVE_TOGGLAREN
	CALL	BEFORE_STARTING

;	mov	ah,48h
;	mov	bx,0ffffh
;	int	21h

	mov	ax,4c00h
	int	21h
	
SET_MCGAB PROC NEAR
	MOV	AX,9876
	MOV	BL,NUMRET
	INT	keyhandler

	MOV	AX,13H
	INT	10H

	MOV	DX,3D4H			;UNLOCK
	MOV	AL,11H
	MOV	AH,0
	OUT	DX,AX

	MOV	DX,3C4H			;SET MCGAB (NO CHAIN FOUR, USE 256KB)
	MOV	AL,04H
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	AND	AL,11110110B
	OUT	DX,AL

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

	MOV	DX,3CCH
	IN	AL,DX
	MOV	DX,3C2H
	OR	AL,11000000B
	OUT	DX,AL			;sÑtt 240-linjers skÑrmhîjd
;	CALL	BLANK_ON	
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
		MOV	SI,OFFSET XPARABL
		MOV	CX,10		
xvploop:
                mov    ax,cs:[si]
                add    si,02h
                out    dx,ax
                jmp     $+2

                loop   xvploop

		RETN
		

xparabl  db 06h,0Dh ,07h,03eh ,09h,40H+80H,10h,0EAh ,11h,0ch ,12h,0dfh ,14h,00h
        db 15h,0eah,016h,06h,17h,0e3h

SET240	ENDP
steg db 200

make_pal proc near
	;ds:si=pal1
	;es:di=pal2
	;cl=pos	

;(v1*(steg-pos)+v2*pos)/steg=v ;steg=antal steg Ü tona pÜ, pos=pos+1 v1=old v2=new
	;cs:bx=destpal
	
	mov	bx,offset cs:faded_pal
tona_next:
	lodsb			;ladda ax me v1
	mov	dl,cs:steg
	sub	dl,cl		;cl e pos
	mul	dl
	mov	bp,ax	;save v1*(steg-pos)
	mov	al,es:[di]	;ladda ax me v2
	inc	di
	
	mul	cl
	add	ax,bp
	div	cs:steg
	mov	cs:[bx],al
	inc	bx
	cmp	bx,offset cs:faded_pal+nofcolors*3
	jb	tona_next
	retn
endp
	
make_pal1 proc near
	;ds:si=pal1
	;es:di=pal2
	;cl=pos	
pusha
;(v1*(steg-pos)+v2*pos)/steg=v ;steg=antal steg Ü tona pÜ, pos=pos+1 v1=old v2=new
	;cs:bx=destpal
	
	mov	bx,offset cs:faded_pal
tona_next1:
	lodsb			;ladda ax me v1
	mov	dl,cs:steg
	sub	dl,cl		;cl e pos
	mul	dl
	mov	bp,ax	;save v1*(steg-pos)
	mov	al,es:[di]	;ladda ax me v2
	inc	di
	
	mul	cl
	add	ax,bp
	div	cs:steg
	mov	cs:[bx],al
	inc	bx
	cmp	bx,offset cs:faded_pal+3
	jb	tona_next1
	popa
	retn
endp		

set_pal proc near
	push	cx
	mova	ds,cs
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	cx,nofcolors*3
	mov	si,offset cs:faded_pal
	REPOUTSB
;	rep	outsb
	pop	cx
	mova	ds,data
	retn
endp
set_pal1 proc near
	push	cx
	mova	ds,cs
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	cx,3
	mov	si,offset cs:faded_pal
	REPOUTSB
;	rep	outsb
	pop	cx
	mova	ds,data
	retn
endp


make_pal256 proc near
	;ds:si=pal1
	;es:di=pal2
	;cl=pos	

;(v1*(steg-pos)+v2*pos)/steg=v ;steg=antal steg Ü tona pÜ, pos=pos+1 v1=old v2=new
	;cs:bx=destpal
	
	mov	bx,offset cs:faded_pal
tona_next256:
	lodsb			;ladda ax me v1
	mov	dl,cs:steg
	sub	dl,cl		;cl e pos
	mul	dl
	mov	bp,ax	;save v1*(steg-pos)
	mov	al,es:[di]	;ladda ax me v2
	inc	di
	
	mul	cl
	add	ax,bp
	div	cs:steg
	mov	cs:[bx],al
	inc	bx
	cmp	bx,offset cs:faded_pal+256*3
	jb	tona_next256
	retn
endp		
set_pal256 proc near
	push	cx
	mova	ds,cs
	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	cx,256*3
	mov	si,offset cs:faded_pal
	REPOUTSB
;	rep	outsb
	pop	cx
	mova	ds,data
	retn
endp
faded_pal db 256*3 dup(0)


unpkpics:
;packa upp bilderna
	mov	ax,0
	mov	bx,0+t21stpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,t21st1seg
	call	unpklbm
	MOVE	DS,DATA
	MOV	T21ST_REAL_PAL,DX
	mov	t21stpaloff,offset pelle1
	push	es ds
	move	es,data
	move	ds,t21st1seg
	mov	cx,256*3
	mov	si,dx
	mov	di,offset pelle1
	rep	movsb
	pop	ds es
	
	mov	ax,0
	mov	bx,139+t21stpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,t21st2seg
	call	unpklbm

	MOVE	DS,DATA
	mov	ax,0
	mov	bx,0+vikingpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,viking2seg
	call	unpklbm16
	MOVE	DS,DATA
	MOV	VIKING_REAL_PAL,DX
	mov	vikingpaloff,offset pelle2
	push	es ds
	move	es,data
	move	ds,viking2seg
	mov	cx,256*3
	mov	si,dx
	mov	di,offset pelle2
	rep	movsb
	pop	ds es

	mov	ax,0
	mov	bx,125+vikingpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,viking1seg	;ETT
	call	unpklbm	;16
	MOVE	DS,DATA

	mov	ax,0
	mov	bx,fld_logopos	;+20
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,fl1seg
	call	unpklbm16
	MOVE	DS,DATA
	mov	fld_logopaloff,dx

	mov	ax,0
	mov	bx,fld_logopos+fl1storlek;+20
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,fl2seg
	call	unpklbm
	MOVE	DS,DATA
retn

unpkpics2:
;packa upp bilderna
	CALL	ANDHAMTNING
	mov	ax,0
	mov	bx,0+t21stpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,t21st1seg
	call	unpklbm
	MOVE	DS,DATA
	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)
	
	mov	ax,0
	mov	bx,139+t21stpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,t21st2seg
	call	unpklbm
	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)

	MOVE	DS,DATA
	mov	ax,0
	mov	bx,0+vikingpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,viking2seg
	call	unpklbm16
	MOVE	DS,DATA
	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)

	mov	ax,0
	mov	bx,125+vikingpos
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,viking1seg	;ETT
	call	unpklbm	;16
	MOVE	DS,DATA
	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)

	mov	ax,0
	mov	bx,fld_logopos	;+20
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,fl1seg
	call	unpklbm16
	MOVE	DS,DATA

	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)
	mov	ax,0
	mov	bx,fld_logopos+fl1storlek;+20
	mov	cx,320
	mov	bp,10b
	mov	dx,0
	move	es,fl2seg
	call	unpklbm
	MOVE	DS,DATA
	CALL	ANDHAMTNING ;Tag lyft fîr att Üter kunna dyka pÜ djupt vatten!
			    ;(sÜdeles fîrhindra att datorn dyker!!!!)
retn

rastra:
	move	es,0a000h
	mov	bx,offset rastatab
next_raster:
	mov	al,[bx]
	cmp	al,-1
	je	next_sync
	push ax
	call	putraster
	pop ax
	call	putraster2
	inc	bx
	jmp	next_raster
next_sync:
	inc	bx
	cmp	byte ptr [bx],-1
	je	done_raster
	synca
	jmp	next_raster
done_raster:
	retn

rastraclear:
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!!
	mov	bx,offset rastatab
next_raster2:
	mov	al,[bx]
	cmp	al,-1
	je	next_sync2
	push ax
	call	clearraster
	pop ax
	call	clearraster2
	inc	bx
	jmp	next_raster2
next_sync2:
	inc	bx
	cmp	byte ptr [bx],-1
	je	done_raster2
	synca
	jmp	next_raster2
done_raster2:
	retn


putraster:
	push	ds
	move	ds,0a000h
	push	ax
	mov	cl,55
	mul	cl
	mov	di,80*dist+20
	mov	si,240*80+14*4*80
	add	si,bp
	add	si,ax
	pop	ax
	mov	cl,80
	mul	cl
	add	di,ax
	mov	cx,55
	rep	movsb
	pop	ds
	retn

putraster2:
	push	ds
	move	ds,0a000h
	mov	cl,55
	xchg	al,ah
	mov	al,94
	sub	al,ah
	push	ax
	mul	cl
	mov	di,80*(240-dist-95)+20
	mov	si,240*80+55*95+14*4*80
	add	si,bp
	add	si,ax
	pop	ax
	mov	cl,80
	mul	cl
	add	di,ax
	mov	cx,55
	rep	movsb
	pop	ds
	retn

clearraster:
	push	ds
	move	ds,0a000h
	mov	cl,80
	xchg	al,ah
	mov	al,94
	sub	al,ah
	mul	cl
	mov	di,80*dist+20
	add	di,ax
	mov	cx,55
	rep	stosb
	pop	ds
	retn
clearraster2:
	push	ds
	move	ds,0a000h
	mov	cl,80
	mul	cl
	mov	di,80*(240-dist-95)+20
	add	di,ax
	mov	cx,55
	rep	stosb
	pop	ds
	retn

clearall:
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!!
	mov	cx,240
	mov	di,128/8+4
lajban_lasse:
	push	cx
	mov	cx,55
	rep	stosb
	add	di,80-55
	pop	cx
	loop	lajban_lasse
	mov	cx,240
	mov	di,44580+128/8+4
lajban_laban:
	push	cx
	mov	cx,55
	rep	stosb
	add	di,80-55
	pop	cx
	loop	lajban_laban
	retn
clearalmostall:
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!!
	mov	cx,240
	mov	di,44580+128/8+4
lajban_laban_o_lajla:
	push	cx
	mov	cx,55
	rep	stosb
	add	di,80-55
	pop	cx
	loop	lajban_laban_o_lajla
	retn
	
clearalmostall2:
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!!
	mov	cx,CHARHEIGHT
	mov	di,128/8+4+80*2*18-80*4+80*(LINJEN-1)*18
lajban_laban_o_lajla2:
	push	cx
	mov	cx,55
	rep	stosb
	add	di,80-55
	pop	cx
	loop	lajban_laban_o_lajla2
	retn

clearalmostall3:
	move	es,0a000h
	mov	al,es:[128/8+3]		;dÑr Ñr det svart min vÑn!! (NEGER)
	mov	cx,CHARHEIGHT
	mov	di,128/8+4+44580+80*2*18-80*4+80*(LINJEN-1)*18
lajban_laban_o_lajla3:
	push	cx
	mov	cx,55
	rep	stosb
	add	di,80-55
	pop	cx
	loop	lajban_laban_o_lajla3
	retn

INIT_SOUND PROC NEAR
	OPENFILE SOUNDCFG
	JC	NOSOUNDCFG
if musikkaos
else
	READFILE BX,13,DRV	;get name of selected sound driver
endif
	CLOSEFILE BX

	savestack
	MOV	AX,DS
	MOV	ES,AX
	MOV	AX,4B00H	;fn 4b = load and execute exe file
	MOV	DX,OFFSET DRV
	MOV	BX,OFFSET PARMS
	INT	21H		;LOAD DRIVER
	restorestack
	MOV	DX,OFFSET DRV
;	jc	drv_not_found
	mov	ax,04d00h
	int	21h
	cmp	al,7
	je	cantfindultrasndstring
	RETN

NOSOUNDCFG:
	MOV	AX,3
	INT	10H
missmess equ "The sound configuration file 'SOUND.CFG' is missing from the",13,10,"game directory. Please run the SETSOUND program so that the",13,10,"file can be created.",13,10
	SPYMESS MiSSmess

	MOV	AX,4C04H	;CP!!! 4???
	INT	21H

	STC
	RETN
ENDP

CHANGE16PAL DB FALSE
Tabort:
	mov	cs:SidoBar,false
	jmp	nosido

creatretf:	;RASTERINT
	CMP	CS:SIDOBAR,TRUE
	JNE	NOSIDO

	Mov	Bx,Cs:SidoPek
	Dec	cs:sidopek
	Cmp	bx,-1
	Je	TaBort
	SetScr	Bx

NOSIDO:
	CMP	CS:CHANGE16PAL,TRUE
	JNE	NOC16
	cli
	mov	dx,3dah
l7:	in	al,dx
;	test	al,1
;	jz	l7
l8:;	in	al,dx
;	test	al,1
;	jnz	l8
rept 10
	jmp	$+2
endm
	mov	dl,0c0h
	mov	al,14h+20h
	out	dx,al
rept 10
	jmp	$+2
endm
	mov	al,0
	out	dx,al
	sti
COMMENT\
	IN	AL,60H
	CMP	AL,15
	JMP	NOCUTTODO
	MOV	AL,CS:CUTADD
	ADD	CS:CUTLEN,AL
	CMP	CS:CUTLEN,20
	JNE	NOT20
	NEG	CS:CUTADD
NOT20:	CMP	CS:CUTLEN,-20
	JNE	NOT02
	NEG	CS:CUTADD
NOT02:
	jmp	doc17
doc16:
	cmp	cs:cutlen,0
	jz	nocuttodo
doc17:
linesync macro
	local test1,test2	
	mov	dx,3dah
test1:	in	al,dx
	test	al,1
	jnz	test1
test2:	in	al,dx
	test	al,1
	jz	test2
endm
cli
	linesync
	mov	dx,3d4h
	mov	al,13h
	mov	ah,40
	add	ah,CS:cutlen
	out	dx,ax
	linesync
	linesync
	mov	dx,3d4h
	mov	al,13h
	mov	ah,40
	out	dx,ax
	
sti
	mov	al,0dh
	mov	ah,CS:cutlen
	MOV	AH,20
	SUB 	AH,CS:CUTLEN
	out	dx,ax
nocuttodo:
\
NOC16:	
	retf
CUTLEN DB 0
CUTADD DB 1
FJUMPENS_BROR DW 0
FJUMPENS_FARSA DW 0
SLUMPEN	DW ?
READREG	MACRO	PORT,INDEX
	MOV	DX,PORT
	MOV	AL,INDEX
	OUT	DX,AL
	INC	DX
	IN	AL,DX
	ENDM

WRITEREG MACRO	PORT,INDEX
	MOV	DX,PORT
	MOV	AH,AL
	MOV	AL,INDEX
	OUT	DX,AX
	ENDM

SAVEGFXREGS MACRO
	READREG	3C4H,2		;BITPLANMASK
	MOV	AH,AL
	READREG	3CEH,0		;SET/RESET
	PUSH	AX
	READREG	3CEH,1		;ENABLE SET/RESET
	MOV	AH,AL
	READREG	3CEH,4		;READ MAP SELECT
	PUSH	AX
	READREG	3CEH,5		;WRITEMODE
	MOV	AH,AL
	READREG	3CEH,8		;BITMASK
	PUSH	AX
;	MOV	DX,3CEH
;	MOV	AX,0FF08H
;	OUT	DX,AX		;BITMASK OUTAD
	PUSH	ES 0A000H
	POP	ES
	MOV	ES:[-90*14-1],AL
	POP	ES
	ENDM

RESTOREGFXREGS MACRO
	POP	AX
	PUSH	AX
	MOV	AL,AH
	WRITEREG 3CEH,5
	POP	AX
	WRITEREG 3CEH,8
	POP	AX
	PUSH	AX
	WRITEREG 3CEH,4
	POP	AX
	MOV	AL,AH
	WRITEREG 3CEH,1
	POP	AX
	PUSH	AX
	WRITEREG 3CEH,0
	POP	AX
	MOV	AL,AH
	WRITEREG 3C4H,2
	PUSH	ES 0A000H
	POP	ES
	MOV	AL,ES:[-90*14-1]
	POP	ES
	ENDM
general_info label byte
	db 'F1 -   PARTY'
	DB '        LAND'
	DB 'F2 -   SPEED'
	DB '      DEVILS'
	DB 'F3 - BILLION'
	DB '      DOLLAR'
	DB 'F4 -  STONES'
	DB "     N'BONES"
	DB 'F5 - OPTIONS'
	DB 'SPACE - SKIP'
options_info label byte
	db '  USE THE   '
	DB 'CURSOR KEYS '
	DB 'TO SELECT AN'
	DB '   OPTION   '
	DB '            '
	DB 'TOGGLE WITH '
	DB '  ENTER OR  '
	DB '  SPACEBAR  '
	DB '            '
	DB 'ESCAPE QUITS'
loggatime = 60*8
infotime = 60*8
pfcounter dw loggatime
menubaren_on db false
info_text dw general_info
info_text_2_USE dw general_info
pftasken dw infot
pftask:	dec	pfcounter
	cmp	pfcounter,0
	jg	dumret
	savegfxregs
	jmp	pftasken
loggan:
	cmp	pfcounter,-90
	jg	utmeloggan
	mov	pftasken,offset infot
	mov	pfcounter,loggatime
	jmp	endoftask
infot:
	cmp	pfcounter,-90
	jg	doclpf
	cmp	pfcounter,-90-12*10
	jg	prntchars
	mov	pftasken,offset loggan
	mov	pfcounter,infotime
endoftask:
	restoregfxregs
	retn
utmeloggan:
	call	aronsson
	mova	es,0a000h
	mova	ds,es
	mov	bp,pfcounter
	neg	bp
	sub	bp,89
	mov	ax,bp
	mov	si,-14
	imul	si
	mov	si,-90*14
	add	si,ax
	mov	di,95
	sub	di,bp
	mov	ax,bpl
	mul	di
	mov	di,ax
	add	di,2
	mov	ax,0
	mov	cx,14
	push	di si
	rep	movsb
	pop	si di
	add	di,44580
	mov	cx,14
	rep	movsb
	mova	ds,data
	jmp	endoftask
doclpf:
	MOVA	INFO_TEXT_2_USE,INFO_TEXT
	call	aronsson_bort
	setwbpl 1111b
	mov	dx,3ceh
	mov	al,0
	mov	ah,10b
	out	dx,ax
	inc	al
	mov	ah,0fh
	out	dx,ax
	MOV	BP,3
LOC_LOOP1:	
	mova	es,0a000h
	mov	di,95
	sub	di,pfcounter
	mov	ax,bpl
	mul	di
	mov	di,ax
	inc	di
	mov	ax,0
	mov	cx,7
	push	di
	rep	stosw
	pop	di
	add	di,44580
	mov	cx,7
	rep	stosw
	DEC	BP
	JZ	ENDOFTASK
	DEC	PFCOUNTER
	JMP	LOC_LOOP1
prntchars:
	call	aronsson_bort
	mova	es,0a000h
	setwbpl 10b
	MOV	DI,97*BPL+2
	MOV	AX,PFCOUNTER
	NEG	AX
	sub	ax,90
	MOV	BL,12
	DIV	BL
	MOV	CX,AX
	mov	bl,9
	MUL	BL
	MOV	BL,80
	MUL	BL
	ADD	AL,CH
	ADC	AH,0
	ADD	DI,AX	;DI=ADR TO PUT CHAR

	MOV	AL,12
	MUL	CL
	ADD	AL,CH
	ADC	AH,0
	MOV	BX,AX
	ADD	BX,INFO_TEXT_2_USE
	MOV	AL,CS:[BX]
	push	di ax
	CALL	WRITEROMCHAR	
	pop	ax di
	add	di,44580
	call	writeromchar
	jmp	endoftask
WRITEROMCHAR:
	MOV	CX,8
	MOV	BL,AL
	XOR	BH,BH
	shl	bx,3
	MOVA	DS,0F000H
	ADD	BX,0FA6EH
prntc:
	MOV	AL,DS:[BX]
	not	al
	MOV	ES:[DI],AL
	ADD	di,bpl
	inc	bx
	loop	prntc
	mova	ds,data
	retn
copy_pf_loggan:	
	call	aronsson
	mov	si,95*bpl+2
	mov	di,-90*14
	mova	ds,0a000h
	mova	es,ds
	mov	cx,90
rader:	push	cx
	mov	cx,14
	rep	movsb
	add	si,bpl-14
	pop	cx
	loop	rader
	mova	ds,data
;	mov	cs:menubaren_on,true
	retn	
DUMRET:RETN
dumretf:	;VBLANK
	add	CS:SLUMPEN,3	;INTE FJUMPEN!!
	SLACK	CS:FJUMPENS_BROR
	mova	es,40h
	mov	byte ptr es:[76h],0ffh
	CMP	CS:CHANGE16PAL,TRUE
	JNE	NOC162
	cli
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,14h+20h
rept 10
	jmp	$+2
endm
	out	dx,al
rept 10
	jmp	$+2
endm
	mov	al,1
	out	dx,al
	sti
noc162:
	cmp	menubaren_on,true
	calle	pftask
	retf	
s_p	dw ?
s_s	dw ?
sidobar DB FALSE
sIDOPEK DW ?
wbpl db ?
rbpl db ?
PUTCHAR:	;DX Points at X destination for char
		;AX Points at Y destination for char
		;BL Is the char
		;Segments: ds=data es=0A000h

		;cs:sida=adress till dest
		;cs:fonten=adress till fonten
			
	push	dx
	shr	dx,3
	mov	di,dx
	mov	dx,0
	mov	cx,80
	mul	cx
	add	di,ax
	pop	dx
	and	dx,0111b
	nil	bh
	shl	bx,1		;words pekare
	mov	si,fontlist[bx]
	CMP	SI,-1	;240*80+80*14+4*19
	JE	DONT_PUT_SPACE_YOU_BLOODY_FOOL
	add	si,cs:fonten
	move	ds,0a000h
	mov	wbpl,1
	mov	rbpl,0
	mov	cx,4
	add	di,cs:sida
bipl:	push	cx si di
	push	dx
	SETWBPL wbpl
	SETRBPL rbpl
	pop	dx
	shl	wbpl,1
	inc	rbpl
	
	mov	cx,14		;hîjd	
nextchar:
	push	cx
	mov	cl,dl

	mov	al,[si]
	mov	ah,0
	ror	ax,cl
	or	[di],al
	
	mov	al,[si+1]
	mov	ch,ah
	mov	ah,0
	ror	ax,cl
	or	al,ch
	or	[di+1],al
	
	mov	al,[si+2]
	mov	ch,ah
	mov	ah,0
	ror	ax,cl
	or	al,ch
	or	[di+2],al
	
	pop	cx
	add	si,80
	add	di,80
	loop	nextchar
	pop	di si cx
	loop	bipl
DONT_PUT_SPACE_YOU_BLOODY_FOOL:
	move	ds,data	
RETN
aronsson:
;set aronsson
	mov	dx,3ceh
	mov	ax,0105h
	out	dx,ax
;Ü bitplanen
	mov	dx,3c4h
	mov	ax,0f02h
	out	dx,ax
retn
aronsson_bort:
;set aronsson_bort
	mov	dx,3ceh
	mov	ax,0005h
	out	dx,ax
	retn
sida	dw ?
fonten	dw ?
writepage:
;bx pekar pÜ textstarten!! ds skall sjÑlvklart va data ;-)
	mov	cx,12
nextline:
	push	cx
	mov	cx,24
	PUSH	AX
	MOVE	ES,DATA
	MOV	DI,BX
	MOV	AL,0
	REPne	SCASB
	MOV	AX,CHARWITH
	MUL	CL
	SHR	AX,1
	mov	dx,128+charwith*2
	ADD	DX,AX
	NEG	CX
	ADD	CX,cs:kexchoklad2	;24
	POP	AX
	JCXZ	NOLINE

nextcharS:		;bx points to asc char, ax=xpos dx=ypos of char
			
	push	ax cx bx dx
	mov	bl,[bx]

	call	putchar
	pop	dx bx cx ax
	inc	bx
	add	dx,charwith
	loop	nextcharS

	add	ax,(charheight+mellanrum)	
	pop	cx
	loop	nextline
	retn
NOLINE:
	ADD	AX,(charheight+mellanrum)
	LOOP	NEXTLINE
	RETN

crunchpics:
	push	es ds
	move	ds,0a000h
	move	es,0a000h
	mov	di,240*80+14*4*80+55
	mov	si,240*80+14*4*80+80
	mov	cx,95*4-1
nasseslinje:
	push	cx
	mov	cx,55
	rep	movsb
	pop	cx
	add	si,80-55
	loop	nasseslinje
	pop	ds es

	push	ds
	move	ds,data		;checksumma!!!!

	mov	si,offset START_KEK
	mov	al,checktrim
	mov	cx,offset stop_kek-offset start_kek
liiir2:	add	al,byte ptr ds:[si]
	inc	si
	loop	liiir2
	mov	cs:kexchoklad,al	;SKA VA 14H+20H
	pop	ds
comment\
PUSHA
NIL AH
DCLS
DPRINTVAL AX," AX="
POPA
\
	retn
kexchoklad db 0
movelogobar:
	push	es ds
	move	ds,0a000h
	move	es,0a000h
	
	mov	cx,240*80
	mov	si,0
	mov	di,44580	;where the shit ends . . .
	rep	movsb

	mov	si,offset cs:START_KEK2
	mov	al,checktrim2
	mov	cx,offset cs:stop_kek2-offset cs:start_kek2
liiir:	add	ax,cs:[si]
	inc	si
	loop	liiir
	nil	ah
	mov	cs:kexchoklad2,ax

	CALL	UTSKRIVAREN

	pop	ds es
	retn
kexchoklad2	dw 0
;*****************
showtext_prot:
	call	rastraclear
	call	aronsson_bort
	
	mov	al,0
	mov	bx,6
	call	julius


	MOV	CS:CHANGE16PAL,false
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,14h+20h
	jmp	$+2
	jmp	$+2
	jmp	$+2
	out	dx,al
	jmp	$+2
	jmp	$+2
	jmp	$+2
	mov	al,0		;vÑlj 16 palette 0
	out	dx,al

	mov	dx,128+4+1
	mov	ax,14
	mov	bx,offset prottxt
	
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	call	writepage
	PUSHA
	fade3B	5
	SETSCR	44580
	SYNCA
	POPA
	mov	dx,128+4+1
	mov	ax,14
	mov	bx,offset PROTTXT
	mov	cs:sida,0
	mov	cs:fonten,0
	call	writepage
	
;hÑr ska de 3 fÑrgerna fÑjdas . . 
;	slackA	320
	synca
	fade3	20
	setscr	0		;bîr ligga pÜ rasterint
	synca
	call	aronsson
	call	clearalmostall
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,0
	mov	bx,offset protTXT
	call	writepage		;flerfÑrgsfont



	call	get_prot

	SYNCA
	SETSCR 0
	SYNCA

	call	aronsson
	call	clearalmostall
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	mov	bx,offset WORDTXT
	call	writepage		;3 fÑrgsfont

	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	mov	bx,offset PROTTXT
	call	writepage		;3 fÑrgsfont
	
	setscr	44580		;bîr ligga pÜ rasterint
	fade3b	20


	call	aronsson
	call	clearall
	setscr	0		;bîr ligga pÜ rasterint
	MOV	CS:CHANGE16PAL,true
retn

;*****************	
showtext:
	call	rastraclear
	call	aronsson_bort
	
	mov	al,0
	mov	bx,6
	call	julius

;	slackA	128/2
;	setscr	44580		;bîr ligga pÜ rasterint
;	fade3b	5

	MOV	CS:CHANGE16PAL,false
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h

;	mov	al,14h+20h
;********************************
;         checksumma
;********************************
	mov	al,cs:kexchoklad
	cmp	al,-10		;14h+20h
	je	ok		;atrapp!
	mov	cx,22
ok:
;********************************
	out	dx,al
	jmp	$+2
	mov	al,0		;vÑlj 16 palette 0
	out	dx,al

	mov	dx,128+4+1
	mov	ax,14
bupper:
	MOV	BX,CS:TEXTPEK
	ADD	CS:TEXTPEK,2
	mov	bx,TEXTLISTA[BX]		;offset texten
	cmp	bx,-1
	jne	nohisorry
	mov	bx,textlista[0]		;highs!!
nohisorry:
	CMP	BX,0
	JNE	NOREZ
	MOV	CS:TEXTPEK,2
;	mov	bx,TEXTLISTA[2]		;offset texten
	jmp	bupper	
NOREZ:

	
	PUSH	BX
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	call	put_the_hslogo2		;NÑrdÜ dÜ??
	call	writepage
	PUSHA
	fade3B	5
	SETSCR	44580
	SYNCA
	POPA
	mov	dx,128+4+1
	mov	ax,14
	POP	BX
	mov	cs:sida,0
	mov	cs:fonten,0
	call	put_the_hslogo1		;NÑrdÜ dÜ??
	call	writepage
	
;hÑr ska de 3 fÑrgerna fÑjdas . . 
;	slackA	320
	
	fade3	20
	setscr	0		;bîr ligga pÜ rasterint

	wait_sync2 60*texttime		;vÑnta med den snygga fonten pÜ . . .
	setscr	44580		;bîr ligga pÜ rasterint
	fade3b	20


	call	aronsson
	call	clearall
	setscr	0		;bîr ligga pÜ rasterint
	MOV	CS:CHANGE16PAL,true
retn


if demover
demoversion:
	fillmusicbuf
	mov	cs:mager,60*covtime
	movpal	tabletabell[0],tablepaloff[0],data,nuvaranden
keyread_demo:
	mov	ax,1		;Read key!!!
	move	es,0
	pushf
	call	dword ptr es:[keyhandler*4]
	cmp	al,01
	je	quit_ing
	
	cmp	al,39h	;space
	je	spruttan_bleble
	synca
	dec	cs:mager	
	jnz	keyread_demo	
	mov	al,23
	int	66H	;reset timer!!
	jmp	firsttime_again
spruttan_bleble:
	fadeM	40,tabletabell[0],tablepaloff[0],data,blackpaloff ;SÑtt rÑtt!!
space2:
	mov	bx,1
	mov	banpek,0
	jmp	savebana
mager	dw ?
firsttime_again:
	fade	40,tabletabell[0],tablepaloff[0],data,blackpaloff ;SÑtt rÑtt!!
	CALL	BLANK_OFF
	mov	ax,12h	;anders
	int	10h
	call	set_mcgab
	call	set240
	call	set_pal		;slÑck paletten	
	CALL	BLANK_ON
	fade256	4,data,blackpaloff,data,blackpaloff ;SÑtt rÑtt!!
	call	shift_up_palettes
	CALL	UNPKPICS2
	fade256	4,data,blackpaloff,data,blackpaloff
	mov	al,23
	int	66H	;reset timer!!
	jmp	firsttime_init
endif
TEXTPEK DW 2
SET_EGAPAL:
	mov	si,offset egapal
	mov	dx,3dah
	in	al,dx
	jmp	$+2
	jmp	$+2
	jmp	$+2
	mov	dx,3c0h
	mov	cx,16
set_ega_pal:
	mov	al,16
	sub	al,cl
	out	dx,al
	jmp	$+2
	jmp	$+2
	jmp	$+2
	outsb
	jmp	$+2
	jmp	$+2
	jmp	$+2
	loop	set_ega_pal
	MOV	al,20h
	out	dx,al
	RETN
laddaden	db false
READ_HIGHS PROC NEAR
	OPENFILE HI_SCORE_FILE1
	JC	NOHI1
	READFILE BX,16*4,HI_sCORE_LIST
	CLOSEFILE BX
NOHI1:	OPENFILE HI_SCORE_FILE2
	JC	NOHI2
	READFILE BX,16*4,HI_sCORE_LIST+16*4*1
	CLOSEFILE BX
NOHI2:	OPENFILE HI_SCORE_FILE3
	JC	NOHI3
	READFILE BX,16*4,HI_sCORE_LIST+16*4*2
	CLOSEFILE BX
NOHI3:	OPENFILE HI_SCORE_FILE4
	JC	NOHI4
	READFILE BX,16*4,HI_sCORE_LIST+16*4*3
	CLOSEFILE BX
NOHI4:
	CALL	MAKE_HI_TABLES
	RETN
REPMOVSB MACRO DE,SO,BY
	MOV	SI,OFFSET SO
	MOV	DI,OFFSET DE
	MOV	CX,BY
	REP	MOVSB
ENDM
MOVSCORE MACRO DE,SO
	LOCAL	LODE,NOMORELED,LUDDE
	MOV	SI,OFFSET SO
	MOV	DI,OFFSET DE
	MOV	CX,12
LODE:	LODSB
	CMP	AL,0
	JNZ	NOMORELED
	MOV	AL,' '
	STOSB
	LOOP	LODE
NOMORELED:
	ADD	AL,'0'
	STOSB
	DEC	CX
LUDDE:	LODSB
	ADD	AL,'0'
	STOSB
	LOOP	LUDDE
ENDM
TB=24
MAKE_HI_TABLES:
	MOVA	ES,DS
	REPMOVSB HITEXT1+TB*2+5,HI_SCORE_LIST+12,3
	REPMOVSB HITEXT1+TB*3+5,HI_SCORE_LIST+16+12,3
	REPMOVSB HITEXT1+TB*4+5,HI_SCORE_LIST+2*16+12,3
	REPMOVSB HITEXT1+TB*5+5,HI_SCORE_LIST+3*16+12,3
	REPMOVSB HITEXT1+TB*8+5,HI_SCORE_LIST2+12,3
	REPMOVSB HITEXT1+TB*9+5,HI_SCORE_LIST2+16+12,3
	REPMOVSB HITEXT1+TB*10+5,HI_SCORE_LIST2+2*16+12,3
	REPMOVSB HITEXT1+TB*11+5,HI_SCORE_LIST2+3*16+12,3
	REPMOVSB HITEXT2+TB*2+5,HI_SCORE_LIST3+12,3
	REPMOVSB HITEXT2+TB*3+5,HI_SCORE_LIST3+16+12,3
	REPMOVSB HITEXT2+TB*4+5,HI_SCORE_LIST3+2*16+12,3
	REPMOVSB HITEXT2+TB*5+5,HI_SCORE_LIST3+3*16+12,3
	REPMOVSB HITEXT2+TB*8+5,HI_SCORE_LIST4+12,3
	REPMOVSB HITEXT2+TB*9+5,HI_SCORE_LIST4+16+12,3
	REPMOVSB HITEXT2+TB*10+5,HI_SCORE_LIST4+2*16+12,3
	REPMOVSB HITEXT2+TB*11+5,HI_SCORE_LIST4+3*16+12,3
	
	MOVSCORE HITEXT1+TB*2+11,HI_SCORE_LIST+0
	MOVSCORE HITEXT1+TB*3+11,HI_SCORE_LIST+16
	MOVSCORE HITEXT1+TB*4+11,HI_SCORE_LIST+16*2
	MOVSCORE HITEXT1+TB*5+11,HI_SCORE_LIST+16*3
	MOVSCORE HITEXT1+TB*8+11,HI_SCORE_LIST2+0
	MOVSCORE HITEXT1+TB*9+11,HI_SCORE_LIST2+16
	MOVSCORE HITEXT1+TB*10+11,HI_SCORE_LIST2+16*2
	MOVSCORE HITEXT1+TB*11+11,HI_SCORE_LIST2+16*3

	MOVSCORE HITEXT2+TB*2+11,HI_SCORE_LIST3+0
	MOVSCORE HITEXT2+TB*3+11,HI_SCORE_LIST3+16
	MOVSCORE HITEXT2+TB*4+11,HI_SCORE_LIST3+16*2
	MOVSCORE HITEXT2+TB*5+11,HI_SCORE_LIST3+16*3
	MOVSCORE HITEXT2+TB*8+11,HI_SCORE_LIST4+0
	MOVSCORE HITEXT2+TB*9+11,HI_SCORE_LIST4+16
	MOVSCORE HITEXT2+TB*10+11,HI_SCORE_LIST4+16*2
	MOVSCORE HITEXT2+TB*11+11,HI_SCORE_LIST4+16*3
	RETN
READ_HIGHS ENDP

INIT_ERR:
	SET_DS	DATA
	MOV	AX,3
	INT	10H
cantimess equ    "Pinball Fantasies cannot find the soundcard you selected in ",13,10,"the SETSOUND program.  Please make sure the card is plugged ",13,10,"into your computer properly.  If it is, please run the ",13,10,"SETSOUND program again and re-select your soundcard.",13,10

	SPYMESS cantimess
	MOV	AX,0
	INT	66H
	MOV	AX,4C02H
	INT	21H

errorloadingmod:
	SET_DS	DATA
	MOV	AX,3
	INT	10H
	SPYMESS "Error loading module!"
	MOV	AX,0
	INT	66H
	MOV	AX,4C04H
	INT	21H
cantfindmod:
	SET_DS	DATA
	MOV	AX,3
	INT	10H
cantfmess equ     "Pinball Fantasies cannot find one of the music and sound",13,10,"effects files in the game directory.  Please re-install the ",13,10,"game to make sure all the files are properly copied to your",13,10,"hard disk.",13,10
 

	SPYMESS cantfmess
	MOV	AX,0
	INT	66H
	MOV	AX,4C04H
	INT	21H
OUTOFMEMORY:
	SET_DS	DATA
	MOV	AX,3
	INT	10H
	SPYMESS "Out of memory!"
	MOV	AX,0
	INT	66H
	MOV	AX,4C01H
	INT	21H

cantfindultrasndstring:
	SET_DS	DATA
	MOV	AX,3
	INT	10H
envmess equ    "    Pinball Fantasies cannot find the information it needs to use",13,10,"    your Gravis Ultrasound card.  Please refer to your Ultrasound     ",13,10,"    user manual and install your card again before attempting to     ",13,10,"    run the game.  If you have any further problems, please read ",13,10,'    the "troubleshooting" section in your Pinball Fantasies user',13,10,"    manual.",13,10,13,10,0,"$"
	SPYMESS envmess
	MOV	AX,4C05H ;cp!?
	INT	21H

get_prot:

nils_gurka:
input_pos=150*320+(80-55)*8
	INPUTA AFTER_PROT,20,input_pos,TEXTCOLOR

;	call	tudor		;DET ANAR VI INTE!  JORè, FôR HAN MEJJAR B000!

	move	ds,data
	mov	bx,offset AFTER_PROT
	mov	si,0			;si pekar pÜ kÜdposten (ej offset)!!!
	mov	si,thepost
	lea	si,ordlista[si].thetext
	
next_tst:
	mov	ah,byte ptr ds:[bx]
	inc	bx
	lodsb
	cmp	bx,offset AFTER_PROT+8
	jae	klart_som_korvspad2

	ror	al,1
	xor	al,10100010b

	cmp	al,0
	je	klart_som_korvspad
	cmp	al,ah
	je	next_tst
nils_bedrup:
;	mov	chksum,0	;Pajja keck summeringen fîr den fan! NEEEJ!!!
	MOVE	DS,DATA
	MOVE	ES,DATA
	DATAMOV	AFTER_PROT,SPCS,21
;	PRINTA2 rensa_input,input_pos,TEXTCOLOR
	jmp	nils_gurka		;YO!
klart_som_korvspad:	
	cmp	ah,0
	jne	nils_bedrup		;YO!
klart_som_korvspad2:
	
	MOVE	DS,DATA
	MOVE	ES,DATA

	MOV	BX,BUPPEN_FILEN
	MOV	AX,5700H
	INT	21H			;GET TIME'N'DATE
	PUSH	CX DX
	filepoint bx,pos1,pos2
	writefile bx,2,usel
	MOV	AX,5701H
	POP	DX CX
	INT	21H			;SET TIME'N'DATE
	
	retn

FELVARDE DW 27643

WINDOWS_PRINT:
PUSHA
PUSH	DS ES

;*
	synca
	setscr	0		;bîr ligga pÜ rasterint
	synca
	call	aronsson
	call	clearalmostall3
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,0
	mov	bx,offset WORDtxt
	call	writepage		;flerfÑrgsfont

	synca
	setscr	44580	;bîr ligga pÜ rasterint
	synca
	call	aronsson
	call	clearalmostall2
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,0
	mov	cs:fonten,0
	mov	bx,offset WORDtxt
	call	writepage		;flerfÑrgsfont

;*
POP ES DS
POPA
RETN
pilpos	dw ?
menu:
	MOV	CS:LOOSER_BUT_SAVER,FALSE
	mov	cs:pilpos,0
put_pilen:
	mov	ax,cs:pilpos
	cmp	ax,high_menu-1
	jne	nope_notthelastone
	inc	ax			;sÑtt den sista lite lÑngre ned!!!
nope_notthelastone:
	mov	cl,(charheight+mellanrum)
	mul	cl
	add	ax,50
	push	ax
	call	aronsson
	clear_boxen 50*80+175/8,3,122+18
	clear_boxen 50*80+175/8+44580,3,122+18
	call	aronsson_bort
	pop	ax
	call	putarrow
again_it:
	CMP	CS:LOOSER_BUT_SAVER,TRUE
	JNE	READ_again_my_friend_again
	RETN
read_again_my_friend_again:	
	mov	ax,12h
	int	keyhandler	;report scancode 0=no key pressed
	push	ax
	synca
	pop	ax
	cmp	al,0
	je	read_again_my_friend_again
		
	cmp	al,1
	je	exitera_dig
	cmp	al,80
	je	pilned
	cmp	al,72
	je	pilupp	;PINUPP?
	cmp	al,39h
	je	space_pigs
	cmp	al,28
	je	space_pigs
	jmp	read_again_my_friend_again
pilupp:
	dec	cs:pilpos
	cmp	cs:pilpos,-1
	jne	put_pilen
	mov	cs:pilpos,high_menu-1	;0
	JMP	PUT_PILEN
;	jmp	again_it	;no need to putit
pilned:
	inc	cs:pilpos
	cmp	cs:pilpos,high_menu+1-1
	jb	put_pilen
	mov	cs:pilpos,0	;high_menu-1
	JMP	PUT_PILEN
;	jmp	again_it	;no need to putit

	
space_pigs:
	mov	bx,cs:pilpos
	shl	bx,1
	pusha
	call	[bx+offset menu_items]
	popa
	jmp	again_it	
;******************************  the menu *************************************
;sîk menu items fîr att hitta menyn!!!
;kom i hÜg att lÑgg sparning av config vid quit (dÜ musik ej spelar!)
;radering i jÑmna bytes!!! Kan behîva trimmas!!!!!!!
;man kanske ska lÑgga in texten i options texten, sÜ det ser snyggt ut dÜ
;det tonas (den anvÑnds dÜ!)

;******************************************************************************

MAKE_IT_NICE PROC NEAR		;INITIATES THE TEXT
	MOV	CS:PILPOS,0
	MOV	CX,6
	LEA	BX,MENU_ITEMS_UPDATES
LOPPAN:	PUSH	CX BX
	CALL	[BX]
	CALL	UPDATE_TEXT
	INC	CS:PILPOS
	POP	BX CX
	ADD	BX,2
	LOOP	LOPPAN
	MOV	CS:PILPOS,0
	RET
MAKE_IT_NICE ENDP

NUMRET	DB CHECK1NUM

BEFORE_STARTING PROC NEAR	;UPDATES THE RESIDENT COPY OF TOGGLAREN!
	MOVE	ES,DS
	LEA	BX,TOGGLAREN
	MOV	AX,0100H
	INT	KEYHANDLER
	RET
BEFORE_STARTING ENDP

LOAD_TOGGLAREN PROC NEAR	;LOADS THE SAVED COPY OF TOGGLAREN
	MOVE	DS,DATA
	OPENFILE TOGGLAR_NAME
	JC	EQLT
	HOWMUCH	EQU SIZE TOGGLAR_STRUCEN
	READFILE BX,HOWMUCH,TOGGLAREN
	JC	EQLT
	CLOSEFILE BX
	CLC
EQLT:	RET
LOAD_TOGGLAREN ENDP

SAVE_TOGGLAREN PROC NEAR	;SAVES TOGGLAREN TO DISK
	CMP	CS:KEXCHOKLAD2,24
	JE	OVVVER
	MOV	AX,9876
	MOV	BX,CS:FELVARDE
	INT	KEYHANDLER
OVVVER:
	MOVE	DS,DATA
	CREATEFILE TOGGLAR_NAME
	JC	EQST
	HOWMUCH	EQU SIZE TOGGLAR_STRUCEN
	WRITEFILE BX,HOWMUCH,TOGGLAREN
;	JC	EQST
	CLOSEFILE BX
	CLC
EQST:	RET
SAVE_TOGGLAREN ENDP

UPDATEIT PROC NEAR		;UPDATES THE SCREEN AND THE TEXT
	;INPUT: BX=OFFSET TO STRING
	;       (CX=NUMBER OF CHARS IN ALTERNATIVE ("BALLS" => CX=5))
	CALL	UPDATE_TEXT
	CALL	UPDATE_SCREEN
	RET
UPDATEIT ENDP

UPDATE_TEXT PROC NEAR
	INC	CX			;LéGG Pè SPACE EFTER KOLON

	MOV	CX,13			;TVINGA DUBBEL VéNSTER-JUSTERING!

	MOV	DX,CS:PILPOS		;DX=RADEN (0-6)
	MOV	CS:CPLOSNING,BX

	MOV	AX,DX
	MOV	BX,24
	MUL	BX
	ADD	AX,CX
	ADD	AX,OFFSET FIRSTCHOICE+3	;AX=OFFSET IN THE TEXT
	
	MOV	BX,CS:CPLOSNING
	STRCOPY2 AX,BX			;UPDATE TEXT!
	
	RET
UPDATE_TEXT ENDP

UPDATE_SCREEN PROC NEAR
	MOV	AX,(14+4)*640
	MUL	DX
	MOV	BP,AX
	MOV	AX,18
	MUL	CX
	ADD	BP,AX
	ADD	BP,308-5*18		;BP=SCRPOS

	MOV	BX,CS:CPLOSNING
	STRLEN	AL,BX
	XOR	AH,AH
	MOV	BX,18
	MUL	BX
	SHR	AX,3
	ADD	AX,2			;1 FôR MEJ OCH 1 FôR DEJ!
	MOV	CS:BREDDEN,AX		;CS:BREDDEN=SUDDBREDD

	MOV	BX,CS:CPLOSNING
	CALL	TJOLAHOPP
	RET
CPLOSNING DW ?
UPDATE_SCREEN ENDP


;HéR!


;******************************************************************************
L_BALLS:
	XOR	TOGGLAREN.S_BALLS,1
	CALL	L_BALLS_UPDATE
	CALL	UPDATEIT
	RETN

L_BALLS_UPDATE:
	MOV	BX,OFFSET TRE			;BX=OFFSET STRING
	CMP	TOGGLAREN.S_BALLS,0
	JZ	IS_ZERO_1
	MOV	BX,OFFSET FEM			;BX=OFFSET STRING
IS_ZERO_1:
	MOV	CX,5
	RETN

;******************************************************************************

L_ANGLE:
	XOR	TOGGLAREN.S_ANGLE,1
	CALL	L_ANGLE_UPDATE
	CALL	UPDATEIT
	RETN

L_ANGLE_UPDATE:
	MOV	BX,OFFSET ZHIGH		;BX=OFFSET STRING
	CMP	TOGGLAREN.S_ANGLE,0
	JZ	IS_ZERO_2
	MOV	BX,OFFSET ZLOW			;BX=OFFSET STRING
IS_ZERO_2:
	MOV	CX,5
	RETN

;******************************************************************************

L_SCROLLING:
	INC	TOGGLAREN.S_SCROLLING
	CMP	TOGGLAREN.S_SCROLLING,2
	JNA	ITSOKI
	MOV	TOGGLAREN.S_SCROLLING,0
ITSOKI:	CALL	L_SCROLLING_UPDATE
	CALL	UPDATEIT
	RETN

L_SCROLLING_UPDATE:
	MOV	BL,TOGGLAREN.S_SCROLLING
	XOR	BH,BH
	SHL	BX,1
	MOV	BX,ZARINEN[BX]			;BX=OFFSET STRING
	MOV	CX,9
	RETN

;******************************************************************************

L_RESOLUTION:
	XOR	TOGGLAREN.S_RESOLUTION,1
	CALL	L_RESOLUTION_UPDATE
	CALL	UPDATEIT
	RETN

L_RESOLUTION_UPDATE:
	MOV	BX,OFFSET NORMAL		;BX=OFFSET STRING
	CMP	TOGGLAREN.S_RESOLUTION,0
	JZ	IS_ZERO_4
	MOV	BX,OFFSET ZHIGH			;BX=OFFSET STRING
IS_ZERO_4:
	MOV	CX,10
	RETN

;******************************************************************************

L_MODE:
	XOR	TOGGLAREN.S_MODE,1
	CALL	L_MODE_UPDATE
	CALL	UPDATEIT
	RETN

L_MODE_UPDATE:
	MOV	BX,OFFSET ZCOLOR		;BX=OFFSET STRING
	CMP	TOGGLAREN.S_MODE,0
	JZ	IS_ZERO_5
	MOV	BX,OFFSET MONO			;BX=OFFSET STRING
IS_ZERO_5:
	MOV	CX,4
	RETN

;******************************************************************************

L_IM:
	XOR	TOGGLAREN.S_IM,1
	CALL	L_IM_UPDATE
	CALL	UPDATEIT
	RETN

L_IM_UPDATE:
	MOV	BX,OFFSET ON			;BX=OFFSET STRING
	CMP	TOGGLAREN.S_IM,0
	JZ	IS_ZERO_6
	MOV	BX,OFFSET OFF			;BX=OFFSET STRING
IS_ZERO_6:
	MOV	CX,4
	RETN

;******************************************************************************




;******************************************************************************
L_SAVE:	;save it temprory (but NOT on disk!)
	MOV	CS:LOOSER_BUT_SAVER,TRUE
	retn
;*****************************************************************************
LOOSER_BUT_SAVER DB ?

bredden dw ?

tjolahopp:	
	mov	ax,cs:pilpos
	mov	cl,(charheight+mellanrum)
	mul	cl
	add	ax,50
	push	bx ax bp
	mov	cx,80
	mul	cx
	shr	bp,3
	add	bp,ax		;bp=start i bytes
	call	aronsson
	clear_boxen bp,cs:bredden,charheight
	add	bp,44580
	clear_boxen bp,cs:bredden,charheight
	call	aronsson_bort
	pop	bp ax bx
	mov	dx,bp		;startpos i pixel
	call	print_it
	retn
putarrow:
	mov	dx,175
	mov	bx,offset pil
	call	print_it
	retn

exitera_dig:
	retn
	

PRINT_IT:
	PUSHA
	PUSH	DS ES
	;bx=offset mess (0 terminated), ax=x, dx=y
	
;*
	pusha
	synca
	setscr	0
	synca
	popa

	pusha
	mov	cs:sida,44580
	mov	cs:fonten,0
	call	print_in_a_mess		;flerfÑrgsfont

	synca
	setscr	44580
	synca

	popa

	mov	cs:sida,0
	mov	cs:fonten,0
	call	print_in_a_mess		;flerfÑrgsfont

;*
	POP ES DS
	POPA
	RETN

print_in_a_mess:	;until 0
	move	ds,data
	move	es,0a000h	
nextchar__:		;bx points to asc char, ax=xpos dx=ypos of char
			
	push	ax cx bx dx
	mov	bl,[bx]
	cmp	bl,0
	je	endofmess
	call	putchar
	pop	dx bx cx ax
	inc	bx
	add	dx,charwith
	jmp	nextchar__
endofmess:
	pop	dx bx cx ax
	retn

showmenu:
	MOV	CS:INFO_TEXT,OFFSET CS:OPTIONS_INFO
	
	call	rastraclear
	call	aronsson_bort
	
	mov	al,0
	mov	bx,6
	call	julius


	MOV	CS:CHANGE16PAL,false
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,14h+20h
	out	dx,al
	jmp	$+2
	mov	al,0		;vÑlj 16 palette 0
	out	dx,al

	mov	dx,128+4+1
	mov	ax,14
	mov	bx,offset menutext
	
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	call	writepage
	PUSHA
	fade3B	5
	SETSCR	44580
	SYNCA
	POPA
	mov	dx,128+4+1
	mov	ax,14
	mov	bx,offset menuTeXT
	mov	cs:sida,0
	mov	cs:fonten,0
	call	writepage
	
;hÑr ska de 3 fÑrgerna fÑjdas . . 
;	slackA	320
	synca
	fade3	40
	setscr	0		;bîr ligga pÜ rasterint
	synca
	call	aronsson
	call	clearalmostall
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,0
	mov	bx,offset menuTeXT
	call	writepage		;flerfÑrgsfont
;***********************************
	;menu logic
	pusha
	call	menu
	popa
	;exit from menu
	MOV	CS:INFO_TEXT,OFFSET CS:GENERAL_INFO
;***********************************

if showall
;show all of it!!!!
	mov	cx,800
	mov	bx,0
lethal:
	add	bx,80
	mov	dx,3d4h
	mov	al,0dh
	mov	ah,bl
	out	dx,ax
	dec	al
	mov	ah,bh
	out	dx,ax
	pusha
	synca
	popa
	loop	lethal	
endif

	SYNCA
	SETSCR 0
	SYNCA

	call	aronsson
	call	clearalmostall
	call	aronsson_bort
	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	mov	bx,offset menuteXT
	call	writepage		;3 fÑrgsfont

	mov	dx,128+4+1
	mov	ax,14
	mov	cs:sida,44580
	mov	cs:fonten,80*14*2
	mov	bx,offset menuTeXT
	call	writepage		;3 fÑrgsfont
	
	setscr	44580		;bîr ligga pÜ rasterint
	fade3b	40


	call	aronsson
	call	clearall
	setscr	0		;bîr ligga pÜ rasterint
	MOV	CS:CHANGE16PAL,true
	retn
menunext db 0
PEKARN	DW 0
AVSLUTA_PSEUDO DW OFFSET CS:SHOWMENU

UTSKRIVAREN:
comment\
PUSHA
NIL AH
DCLS
DPRINTVAL AX," AX="
POPA
\
RETN

code ends

dumpningsplats segment
ends

t21st1seg	segment para public 'dump'
extrn	t21st1:byte
ends

t21st2seg	segment para public 'dump'
extrn	t21st2:byte
ends

viking1seg	segment para public 'dump'
extrn	viking1:byte
ends

viking2seg	segment para public 'dump'
extrn	viking2:byte
ends

qsune segment para public 'dump'
ends

end start


COMMENT\
item1:	
	;BALLS: 3,5
	XOR	TOGGLAREN.S_BALLS,1
	jNz	nike
	mov	bx,offset tre			;bx=OFFSET zeroterm. text
	mov	byte ptr ds:[offset i1+8],'3'	;CHANGE REALTEXT TOO!
	jmp	justdoit
nike:
	mov	bx,offset fem			;bx=OFFSET zeroterm. text
	mov	byte ptr ds:[offset i1+8],'5'	;CHANGE REALTEXT TOO!

justdoit:
	mov	cs:bredden,3	;RADERINGSBREDD fîr radering (i bytes) (trimma!)
	mov	bp,308		;RADERINGSSTART start i pixel (trimma!)
	;FINA: BX,BP,CS:BREDDEN
	call	tjolahopp	;rensa Ü skriv ut!!! (PIPPI LèNGSTRUMP!)
	retn

\

