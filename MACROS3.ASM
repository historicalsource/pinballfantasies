;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                            บ
;บ                              F.L.D. Macros (3)                             บ
;บ                                                                            บ
;บ                                Debug Macros                                บ
;บ                                                                            บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

CODE SEGMENT PARA PUBLIC 'CODE'
THE_X	DW 0
THE_Y	DW 0
ENDS

debugval macro x,y,value,message
	LOCAL	MESS,GNU,gnet,done
	JMP	SHORT GNU
MESS	DB	MESSAGE,0
GNU:	PUSHA
	PUSH	es
	push	value
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	ax,0b000h
	mov	es,ax
	mov	si,offset cs:mess
	mov	ax,y
	mov	bx,160
	mul	bx
	add	ax,x
	add	ax,x
	mov	di,ax	
	mov	ah,07h
gnet:
	lodsb
	or	al,al
	jz	done
	stosw
	jmp	gnet
done:	
	pop	ds

	pop	ax
	xor	dx,dx
	mov	bx,10000
	div	bx
	mov	ah,7
	add	al,'0'
	stosw
	mov	ax,dx

	xor	dx,dx
	mov	bx,1000
	div	bx
	mov	ah,7
	add	al,'0'
	stosw
	mov	ax,dx

	xor	dx,dx
	mov	bx,100
	div	bx
	mov	ah,7
	add	al,'0'
	stosw
	mov	ax,dx

	xor	dx,dx
	mov	bx,10
	div	bx
	mov	ah,7
	add	al,'0'
	stosw
	mov	ax,dx

	mov	ah,7
	add	al,'0'
	stosw
	
	pop	es
	popa
	endm
debugbcd macro x,y,value,message
	LOCAL	MESS,GNU,gnet,done,skriv
	JMP	SHORT GNU
MESS	DB	MESSAGE,0
GNU:	PUSHA
	PUSH	es ds
	mov	ax,cs
	mov	ds,ax
	mov	ax,0b000h
	mov	es,ax
	mov	si,offset cs:mess
	mov	ax,y
	mov	bx,160
	mul	bx
	add	ax,x
	add	ax,x
	mov	di,ax	
	mov	ah,07h
gnet:
	lodsb
	or	al,al
	jz	done
	stosw
	jmp	gnet
done:	
	pop	ds

	mov	si,offset value
	mov	cx,12
	mov	ah,7
skriv:	lodsb	
	add	al,'0'
	stosw
	loop	skriv
	pop	es
	popa
	endm
		
debugmess macro x,y,message
	LOCAL	MESS,GNU,gnet,done
	JMP	SHORT GNU
MESS	DB	MESSAGE,0
GNU:	PUSHA
	PUSH	DS es
	mov	ax,cs
	mov	ds,ax
	mov	ax,0b000h
	mov	es,ax
	mov	ax,y
	mov	bx,160
	mul	bx
	add	ax,x
	add	ax,x
	mov	di,ax	
	mov	si,offset cs:mess
	mov	ah,07h
gnet:
	lodsb
	or	al,al
	jz	done
	stosw
	jmp	gnet
done:	
	POP	es DS
	POPA
	endm
debugclear macro
	pusha
	push es
	mov	ax,0b000h
	mov	es,ax
	xor	ax,ax
	xor	di,di
	mov	cx,80*25
	rep	stosw
	pop es
	popa
	endm	

DPRINT	MACRO MESSAGE
	LOCAL	VRRR,MARKER1,MARKER2,OKKKO
	JMP	VRRR
MARKER1	DB MESSAGE
MARKER2	LABEL BYTE
VRRR:	PUSHA
	MOV	SI,CS:THE_X
	MOV	DI,CS:THE_Y
	DEBUGMESS SI,DI,MESSAGE
	MOV	AX,OFFSET MARKER2
	SUB	AX,OFFSET MARKER1
	ADD	CS:THE_X,AX
	CMP	CS:THE_X,79
	JNA	OKKKO
	SUB	CS:THE_X,80
	INC	CS:THE_Y
	CMP	CS:THE_Y,23
	JNAE	OKKKO
	DCLS
OKKKO:	POPA
ENDM

DPRINTVAL MACRO VALUE,MESSAGE
	LOCAL	VRRR,MARKER1,MARKER2,OKKKO
	PUSHA
	PUSH	VALUE
	PUSH	CS:THE_X
	PUSH	CS:THE_Y
	POP	DI
	POP	BP
	POP	AX
	DEBUGVAL BP,DI,AX,MESSAGE
	JMP	VRRR
MARKER1	DB MESSAGE
MARKER2	LABEL BYTE
VRRR:	MOV	AX,OFFSET MARKER2
	SUB	AX,OFFSET MARKER1
	ADD	AX,5
	ADD	CS:THE_X,AX
	CMP	CS:THE_X,79
	JNA	OKKKO
	SUB	CS:THE_X,80
	INC	CS:THE_Y
	CMP	CS:THE_Y,23
	JNAE	OKKKO
	DCLS
OKKKO:	POPA
ENDM

DCLS	MACRO
	DEBUGCLEAR
	MOV	CS:THE_X,0
	MOV	CS:THE_Y,0
ENDM

DEBUG_SAVE MACRO REGISTER
	PUSHF
	PUSHA
	PUSH DS
	PUSH ES
	PUSH	REGISTER
	MOVE	DS,DATA
	POP	URBL1
	MOV	AH,3CH
	MOV	CX,0000H	;CH=0, CL=FILE ATTRIBUTE BYTE
	MOV	DX,OFFSET FILENM
	INT	21H
	MOV	BX,AX
	;BX=HANDLE
	MOV	CX,2
	MOV	DX,OFFSET URBL1
	MOV	AH,40H
	INT	21H
	;BX=HANDLE
	MOV	AX,3E00H
	INT	21H
	POP ES
	POP DS
	POPA
	POPF
ENDM

DEBUG_SAVE2 MACRO UFFE
	PUSHF
	PUSHA
	PUSH DS
	PUSH ES
	PUSH	OFFSET UFFE
	POP	URBL2
	MOV	AX,DATA
	MOV	DS,AX
	MOV	AH,3CH
	MOV	CX,0000H	;CH=0, CL=FILE ATTRIBUTE BYTE
	MOV	DX,OFFSET FILENM2
	INT	21H
	MOV	BX,AX
	;BX=HANDLE
	MOV	CX,2
	MOV	DX,OFFSET URBL2
	MOV	AH,40H
	INT	21H
	;BX=HANDLE
	MOV	AX,3E00H
	INT	21H
	POP ES
	POP DS
	POPA
	POPF
ENDM

DDUMP	MACRO SEG,ADR
	LOCAL	THENEXT
	DCLS
	PUSHA
	PUSH	DS
	PUSH	ES
	PUSH	SEG
	PUSH	OFFSET ADR
	POP	SI
	POP	DS
	MOVE	ES,0B000H
	NIL	DI
	MOV	CX,80*24
	MOV	AH,7
THENEXT:LODSB
	STOSW
	LOOP	THENEXT
	POP	ES
	POP	DS
	POPA
ENDM

DHEXDUMP MACRO SEG,ADR
	LOCAL	NEXTLINE,NEXTROW
	DCLS
	PUSHA
	PUSH	DS
	PUSH	ES
	MOV	CX,
NEXTROW:

NEXTLINE:
	
	POP	ES
	POP	DS
	POPA
ENDM

