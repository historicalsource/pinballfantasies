demover=0
keyhandler=65h
jumps
include c:\source\macros1.asm
rate=20000
basememreq=585000	;free mem required
nosoundmemreq=450000	;if no music, or XMS detected
xmssize=220000		;minimum XMS size

GURKA=42
MONOVALUE=72-GURKA
COLORVALUE=73-GURKA

.286P

stacken segment para stack 'stack'
	dw 256 dup(0)
stacken ends

data	segment para public 'data'
parm		db 30 dup (0)
notfound	db 'not loaded! Reinstall program.',13,10,'$'
IF DEMOVER
introname	db 'Demo.Prg',0,'$'
ELSE
introname	db 'Intro.prg',0,'$'
ENDIF
comment\
errlist		dw offset error1
		dw offset error2
		dw offset error3
		dw offset error4
error1		db 'Unexpected out of memory! Free up DOS memory!',13,10,'$'
error2		db 'Can not init sound device! Please run the SETSOUND program!',13,10,'$'
error3		db 'Can not find game file! Please reinstall game!',13,10,'$'
error4		db 'Error in game files!  Please reinstall game!',13,10,'$'
error5		db '
unknowntxt	db 'Unknown error! Please reinstall game and try again!',13,10,'$'
CRITICAL	DB 'Critical Error! (Drive not ready?)',13,10,'$',0
\
COMMENT\
IF DEMOVER
ELSE
BADPARM		DB 13,10,"Pinball Fantasies (c) 1993-94 21st Century Entertainment Ltd.",13,10,13,10
		DB "Usage: PINBALL [options]",13,10,13,10
		DB "Options",13,10,13,10
		DB "       /h  -  Hi resolution graphics mode.",13,10,13,10
		DB "       /m  -  Monochrome graphics mode, suitable for monochrome",13,10
		DB "              monitors used on a VGA video card."
		DB 13,10,13,10,"$"
ENDIF
\
banor	label byte
namelen=12
if demover
f1name		db 'Pland.Prg',0,'$'
else
f1name		db 'Table1.Prg',0,'$'
endif
f2name		db 'Table2.Prg',0,'$'
f3name		db 'Table3.Prg',0,'$'
f4name		db 'Table4.Prg',0,'$'
data ends
savestack	macro
	move	cs:s_s,ss
	mov	cs:s_p,sp
endm
restorestack	macro
	move	ss,cs:s_s
	mov	sp,cs:s_p
endm

code	segment para public 'code'
	assume cs:code,ds:data

START	PROC FAR
	PUSHA
	PUSH	DS

COMMENT\
IF DEMOVER
ELSE
	MOV	CL,DS:[80H]
	XOR	CH,CH
	DEC	CX
	JLE	PARMS_READY		;NO PARMS AT ALL

	MOV	BP,CX
	MOV	SI,82H
READ_MORE:
	CALL	SKIP_BLANKS
	JC	PARMS_READY
	CMP	BYTE PTR DS:[SI],'M'
	JE	ITS_MONO
	CMP	BYTE PTR DS:[SI],'m'
	JE	ITS_MONO
	CMP	BYTE PTR DS:[SI],'H'
	JE	ITS_HIRES
	CMP	BYTE PTR DS:[SI],'h'
	JE	ITS_HIRES
	JMP	INVALID_PARMS

ITS_MONO:
	INC	SI
	MOV	CS:MONOMODE,MONOVALUE
	JMP	READ_MORE

ITS_HIRES:
	INC	SI
	MOV	CS:HI_RES,TRUE
	JMP	READ_MORE

SKIP_BLANKS:	;OUTPUT: SI POINTS TO THE NEXT NON-BLANK CHAR
		; -C- IF LAST CHAR IS READ
	MOV	AX,SI
	SUB	AX,82H
	CMP	AX,BP
	JE	TESTAT_DEN_SISTA
	MOV	CX,30
TRY_NEXT:
	CMP	BYTE PTR DS:[SI],' '
	JE	BLANK
	CMP	BYTE PTR DS:[SI],'/'
	JE	BLANK
	CMP	BYTE PTR DS:[SI],'-'
	JE	BLANK
	CMP	BYTE PTR DS:[SI],0
	JE	BLANK
	CLC
	RETN
BLANK:	MOV	AX,SI
	SUB	AX,82H
	INC	AX
	CMP	AX,BP
	JE	TESTAT_DEN_SISTA
	INC	SI
	LOOP	TRY_NEXT
TESTAT_DEN_SISTA:
	STC
	RETN

INVALID_PARMS:
	POP	DS
	POPA
	MOVE	DS,DATA
	MOV	AX,3
	INT	10H
	MOV	DX,OFFSET BADPARM
	MOV	AX,0900H
	INT	21H
	JMP	QUITTA
ENDIF
PARMS_READY:
\

	POP	DS
	POPA

	move es,ds
	move ds,DATA
	mov ax,4a00h
	mov bx,es
	neg bx
	add bx,endofprog
	add bx,1024/16
	int 21h			;shrink block

	jmp	enough_mem
bannumber db 1
INT24H_SEG DW ?
INT24H_ADR DW ?
int9_ip dw ?
int9_cs dw ?
int16h_ip dw ?
int16h_cs dw ?
in_hyperspace db false
s_p	dw ?
s_s	dw ?
scan	db ?
	
enough_mem:
;install keyints . . . 

	move	es,0

	PUSHF
	CLI
	move	int9_ip,es:[9*4]
	move	int9_cs,es:[9*4+2]
	mov	es:[9*4],offset keyint
	move	es:[9*4+2],cs	

	move	int16h_ip,es:[keyhandler*4]
	move	int16h_cs,es:[keyhandler*4+2]
	mov	es:[keyhandler*4],offset int16h
	move	es:[keyhandler*4+2],cs

	MOVE	INT24H_ADR,ES:[24H*4]
	MOVE	INT24H_SEG,ES:[24H*4+2]
	NEEEEJ	EQU OFFSET BAD24H
	MOVE	ES:[24H*4],NEEEEJ
	MOVE	ES:[24H*4+2],CS

	POPF
	move	es,DATA	


ONCE_AGAIN:
;Intro and chooser . . . 
	move	ds,DATA
	move	es,DATA
	pusha
	savestack
	mov ax,4b00h
	mov bx,offset parm
	mov dx,offset introname
	int 21h		;load and execute program
	restorestack
	popa
	move	ds,DATA
	mov dx,offset introname
	jc file_not_found
	
	;Check if any errors was detected in prog.(eg. Mod not found, out of mem)
	mov	ax,4d00h
	int	21h
	cmp	ax,0
	jne	PrintGameErrors
	
	mov	cs:first_time,false	

;******************* cp cp cp! ta bort i riktiga!

;	mov	ax,3
;	int	10h
;*******************

;Ladda bana . . . 
	cmp	bannumber,0
	je	quit		;esc pressed!!!!
	move	ds,DATA
	pusha
	savestack
	mov al,cs:bannumber
	mov	ah,0
	mov cx,namelen
	mul cx
	mov dx,ax
	add dx,offset banor-namelen
	mov bx,offset parm
	mov ax,4b00h
	int 21h		;load and execute program
	restorestack
	popa
	move	ds,DATA
	pushf
	mov al,cs:bannumber
	mov ah,0
	mov cx,namelen
	mul cx
	mov dx,ax
	add dx,offset banor-namelen
	popf
	jc file_not_found
;********** ska de vara h„r???
	;Check if any errors was detected in prog.(eg. Mod not found, out of mem)
	mov	ax,4d00h
	int	21h
	cmp	ax,0
	jne	PrintGameErrors
;****************
	jmp	once_again
;******************************************************************************
;*                          Print Error Messages                              *
;******************************************************************************
PrintGameErrors:
jmp	Equit
comment\
;	al=1 Out of mem
;	al=2 Can't init sound
;	al=3 file not found
;	al=4 Error in file
;
	move	ds,data
	cmp	al,4
	ja	unknownerror
	mov	bx,offset errlist
	nil	ah
	shl	ax,1
	add	bx,ax
	mov	dx,[bx]
	MOV	AX,900H
;	INT	21H
;	mov	ax,900h
;     	int	21h	
	jmp	quit
unknownerror:
	mov	dx,offset unknowntxt
	MOV	AX,900H
	INT	21H
;	mov	ax,900h
;     	int	21h	
	jmp	quit
	
;drv_not_found:
	pusha
	mov	dx,offset error2
	mov	ax,900h
       	int	21h	

	mov	cx,13
	mov	al,0
;	mov	di,offset drv
	move	es,data
	rep scasb
	inc	di
	mov	al,'$'
	stosb
	popa
;	mov	dx,offset drv
	jmp	yo	
\
file_not_found:
	pusha
	mov	ax,3
	int	10h
	popa
yo:
	MOV	AX,900H
	INT	21H
	mov	dx,offset notfound
	mov	ax,900h
       	int	21h	
	jmp	quit

Equit:
quit:
	PUSHF
	CLI
	move	es,0
	move	es:[9*4],int9_ip
	move	es:[9*4+2],int9_cs
	move	es:[keyhandler*4],int16h_ip
	move	es:[keyhandler*4+2],int16h_cs
	MOVE	ES:[24H*4],INT24H_ADR
	MOVE	ES:[24H*4+2],INT24H_SEG
	POPF
quitta:	
	mov	ax,4c00h
	int	21h

TOGGLAR_STRUCEN STRUC
	S_BALLS		DB ?
	S_ANGLE		DB ?
	S_SCROLLING	DB ?
	S_IM		DB ?
	S_RESOLUTION	DB ?
	S_MODE		DB ?
ENDS
RESIDENTA_TOGGLAREN DB SIZE TOGGLAR_STRUCEN DUP (0)

first_time db true
int16h:
	push	ax
	cmp	ax,0
	jne	no_first_time_ask
	pop	ax
	mov	ah,cs:first_time
	mov	bl,cs:bannumber
	iret
no_first_time_ask:
	cmp	ax,0ffffh
	jne	no_savenumber
	mov	cs:bannumber,bl		;Vilken bana (1-4)!! 0=Esc pressed!!
no_savenumber:

	CMP	AX,0100H	;LOKALA TOGGLAREN => RESIDENTA TOGGLAREN
	JNE	INTE_JAG
	;INPUT: ES:BX=OFFSET TO LOKALA TOGGLAREN
	PUSH	ES DS
	MOVE	DS,ES
	MOVE	ES,CS
	MOV	SI,BX
	LEA	DI,RESIDENTA_TOGGLAREN
	MOV	CX,SIZE TOGGLAR_STRUCEN
	REP	MOVSB
	POP	DS ES
	JMP	INTE_JAG_HELLER
INTE_JAG:

	CMP	AX,0200H	;RESIDENTA TOGGLAREN => LOKALA TOGGLAREN
	JNE	INTE_JAG_HELLER_OXO_KANSKE
	;INPUT: ES:BX=OFFSET TO LOKALA TOGGLAREN
	PUSH	DS
	MOVE	DS,CS
	MOV	DI,BX
	LEA	SI,RESIDENTA_TOGGLAREN
	MOV	CX,SIZE TOGGLAR_STRUCEN
	REP	MOVSB
	POP	DS
	JMP	INTE_JAG_HELLER
INTE_JAG_HELLER_OXO_KANSKE:

	CMP	AX,12H			;text input
	JNE	INTE_JAG_heller
	pop	ax
	mov	ah,0
	mov	al,cs:scan
	mov	cs:scan,0	
	iret
inte_jag_heller:
	pop	ax
	mov	ah,0
	mov	al,cs:scan	;nja, n†got minskad funktion . . 
	mov	cs:scan,0	
	iret
	
KEYINT:	;int 9
	PUSHA
        PUSH DS
	MOV AL,20H
	OUT 20H,AL
	MOVE DS,DATA
        IN AL,60H
        PUSH AX
        IN AL,61H
        OR AL,80H
        OUT 61H,AL
        AND AL,7FH
        OUT 61H,AL
        POP AX
	test	al,80h
	jnz	no_alfa_key

	MOV	CS:SCAN,AL	;REKORDKORV??
no_alfa_key:
	POP	DS
	POPA
        IRET

BAD24H_RETURN	DB 3	;3=SOMETHING IS WRONG!
			;2=ABORT
			;1=RETRY
			;0=IGNORE
BAD24H:
	MOV	AL,CS:BAD24H_RETURN
	DEC	CS:BAD24H_RETURN
	JNL	JUST_IRET
	MOV	CS:BAD24H_RETURN,3
JUST_IRET:
	IRET

START	ENDP
CODE	ENDS
endofprog segment
ends
end	staRT


