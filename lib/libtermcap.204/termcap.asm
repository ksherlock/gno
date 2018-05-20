**************************************************************************
*
* GNO/Termcap Library
* Written by Tim Meekins
* Copyright 1992 by Tim Meekins and Procyon, Inc.
* All Rights Reserved
*
* This code is based loosely on the Berkeley C implementation of
* termcap.
*
* many optimizations by assuming tbuf does not wrap bank.
*
**************************************************************************

	keep	termcap
	mcopy	termcap.mac
	case	on
*
* Constants
*
BUFSIZ	gequ	1024
MAXHOP	gequ	32	;max number of tc= indirections
PBUFSIZ	gequ	512	;max length of filename path
PVECSIZ	gequ	32	;max number of names in path
MAXRETURNSIZE	gequ	64

dummy	START

	dc	c'GNO/Termcap 1.2'

	END

**************************************************************************
*
* tgetent - Get an entry for terminal name in buffer bp from the termcap file
*
**************************************************************************

tgetent	START

	using	~TERMGLOBALS

;fname	equ	1
;p	equ	fname+4
;home	equ	p+4
;termpath	equ	home+4
;cp	equ	termpath+4
;space	equ	cp+4

	subroutine (4:bp,4:name),(4:fname,4:p)


	ld4	pathbuf,p
	ld4	pathvec,fname
	ld4	pathvec,pvec
	mv4	bp,tbuf
;
; snag the $TERMCAP variable
;
	stz pathbuf_os+2
try_termcap	anop
	ReadVariable termcap_var
	ldx pathbuf_os+2
	bne found_var

;
; $TERMCAP can contain a path to use instead of 31/etc/termcap. Unlike
; Unix, $TERMCAP can only contain a path, not an termcap entry. If $TERMCAP
; does not hold a file name then a path of names is searched instead. The
; path is found in the $TERMPATH variable, or becomes
; "$HOME/termcap 31/etc/termcap" if no $TERMPATH exists.
;

try_termpath	anop
	ReadVariable termpath_var
	ldx pathbuf_os+2
	beq try_home


found_var	anop
	short a
	stz pathbuf,x
	long a
	jmp	tokenize


try_home	anop
	ReadVariable home_var
; append _PATH_DEF to pathbuf
	short a
	ldy #0
	ldx pathbuf_os+2
	beq home_loop
	lda #':'
	sta pathbuf,x
	inx

home_loop	anop
; short a from above.
	lda _PATH_DEF,y
	beq eos
	sta pathbuf,x
	inx
	iny
	bra home_loop
eos	anop
	sta pathbuf,x ; null-terminate.
	stx pathbuf_os+2 ; length
	long a


; The search path is now in pathbuf, tokenize it into individual
; files to check for.
;
tokenize	lda	#<pathbuf
	sta	[fname]
	ldy	#2
	lda	#^pathbuf
	sta	[fname],y
	add4	fname,#4,fname

tokloop	add4	p,#1,p
	lda	[p]
	and	#$FF
	beq	donetok
	cmp	#' '
	bne	tokloop
	short	a
	lda	#0
	sta	[p]
	long	a
eatspace	add4	p,#1,p
	lda	[p]
	and	#$FF
	beq	donetok
	cmp	#' '
	beq	eatspace
	lda	p
	sta	[fname]
	ldy	#2
	lda	p+2
	sta	[fname],y
	add4	fname,#4,fname
	bra	tokloop

donetok	lda	#0	;mark end of vector
	sta	[fname]
	ldy	#2
	sta	[fname],y

	pei	(name+2)	;find terminal entry in path
	pei	(name)
	pei	(bp+2)
	pei	(bp)
	jsr	tfindent

	return 2:@a

termcapstr	dc	c'TERMCAP',h'00'
termpathstr	dc	c'TERMPATH',h'00'
homestr	dc	c'HOME',h'00'	
_PATH_DEF	dc	c'termcap /etc/termcap',h'00'


termcap_str_gs	dc i2'7',c'TERMCAP',h'00'
termpath_str_gs	dc i2'8',c'TERMPATH',h'00'
home_str_gs	dc i2'4',c'HOME',h'00'


termcap_var	dc i2'3',a4'termcap_str_gs',a4'pathbuf_os',i2'0'
termpath_var	dc i2'3',a4'termpath_str_gs',a4'pathbuf_os',i2'0'
home_var	dc i2'3',a4'home_str_gs',a4'pathbuf_os',i2'0'

	END

**************************************************************************
*
* tfindent - reads through the list of files in pathvec as if they were one
* continuous file searching for terminal entries along the way. It will
* participate in indirect recursion is the call to tnchktc() finds a tc=
* field, which is only searched for in the current file and files ocurring
* after it in pathvec. The usable part of this vector is kept in the global
* variable pvec. Terminal entries may not be broken across files. Parse is
* very rudimentary; we just notice escaped newlines.
*
**************************************************************************

tfindent	PRIVATE

	using	~TERMGLOBALS

;tmp	equ	1
;ch	equ	tmp+4
;cnt	equ	ch+2
;i	equ	cnt+2
;cp	equ	i+2
;ibuf	equ	cp+4
;p	equ	ibuf+4
;opencnt	equ	p+4
;space	equ	opencnt+2

	lsubroutine (4:bp,4:name),(4:tmp,2:ch,2:cnt,2:i,4:cp,4:ibuf,4:p,2:opencnt)

	mv4	bp,tbuf
	mv4	pvec,p
	stz	opencnt

nextfile	stz	i
	stz	cnt

fileloop	ldy	#2
	lda	[p]
	ora	[p],y
	bne	gotfile
	ldy	#0	
	lda	opencnt
	bne	okexit
	dey
okexit	jmp	exit

gotfile        lda	[p],y
	sta	tmp+2
	lda	[p]
	sta	tmp
	ldy	#0
gotfile0	lda	[tmp],y
	and	#$FF
	beq	gotfile1
	sta	filename+2,y
	iny
	bra	gotfile0
gotfile1	sty	filename
	open	openparm
	bcc	gotfile2
	add4	p,#4,p
	jmp	fileloop

gotfile2	mv2	openref,(readref,closeref)
	ph4	#BUFSIZ
	jsl	~NEW
	sta	ibuf
	stx	ibuf+2
	sta	readbuf
	stx	readbuf+2

	inc	opencnt

readloop	mv4	bp,cp
readloop2	lda	i
	cmp	cnt
	bne	reader0

	read	readparm
	mv2	readcnt,cnt
	bne	okread

	close	closeparm
	add4	p,#4,p
	pei	(ibuf+2)
	pei	(ibuf)
	jsl	~DISPOSE
	jmp	nextfile	

okread	stz	i

reader0	ldy	i
	lda	[ibuf],y
	inc	i
	and	#$FF
	sta	ch

	cmp	#13
	beq	reader1
	cmp	#10
	bne	reader2

reader1	lda	cp+2
	cmp	bp+2
	bcc	breakloop2
	beq	reader1aa
	bra	reader1a
reader1aa	lda	cp
	cmp	bp
	beq	breakloop2
	bcc	breakloop2
reader1a	sub4	cp,#1,cp
	lda	[cp]
	and	#$FF
	cmp	#'\'
	beq	readloop2
	add4	cp,#1,cp
	bra	breakloop2	

reader2	add4	bp,#BUFSIZ,tmp
	lda	cp+2
	cmp	tmp+2
	beq	reader2a
	bcs	reader2b
reader2a	lda	cp
	cmp	tmp
	bcc	reader2c
reader2b	ErrWriteCString #errstr1		
	bra	breakloop2
reader2c	lda	ch
	sta	[cp]
	add4	cp,#1,cp
	jmp	readloop2

breakloop2	lda	#0
	sta	[cp]
;
; The real work for the match
;	
	pei	(name+2)
	pei	(name)
	jsr	tnamatch
	cmp	#0
	jeq	readloop

	close	closeparm
	pei	(ibuf+2)
	pei	(ibuf)
	jsl	~DISPOSE
	jsr	tnchktc
	tay

exit	lreturn 2:@y


openparm	dc	i2'3'
openref	dc	i2'0'
	dc	i4'filename'
	dc	i2'1'

readparm	dc	i2'4'
readref	dc	i2'0'
readbuf	dc	i4'0'
	dc	i4'BUFSIZ'
readcnt	dc	i4'0'

closeparm	dc	i2'1'
closeref	dc	i2'0'

errstr1	dc	c'Termcap entry too long',h'0d0a00'

filename	ds	256

	END

**************************************************************************
*
* Tnamatch deals with name matching. The first field of the termcap
* entry is a sequence of names separated by |'s, so we compare
* against each such name. The normal : terminator after the last
* name (before the first field) stops us.
*
* TODO: Update Bp to be Y indexed...
*
**************************************************************************

tnamatch	PRIVATE

	using	~TERMGLOBALS

;tmp	equ	1
;Np	equ	tmp+2
;Bp	equ	Np+4
;space	equ	Bp+4

	lsubroutine (4:np),(2:tmp,4:Np,4:Bp)

	mv4	tbuf,Bp

	ldy	#0
	lda	[Bp]
	and	#$FF
	cmp	#'#'
	beq	exit0

loop	mv4	np,Np

comploop	lda	[Np]
	and	#$FF
	beq	compbreak
	sta	tmp
	lda	[Bp],y
	and	#$FF
	cmp	tmp
	bne	compbreak
	iny
	inc	Np
	bne	comploop
	inc	Np+2
	bra	comploop

compbreak	lda	[Np]
	and	#$FF
	bne	scanner
	lda	[Bp],y
	and	#$FF
	beq	gotit
	cmp	#'|'
	beq	gotit
	cmp	#':'
	bne	scanner
gotit	ldy	#1
	bra	exit

scanner	lda	[Bp],y
	and	#$FF
	beq	exit0
	cmp	#':'
	beq	exit0
	iny
	cmp	#'|'
	beq	loop
	bra	scanner

exit0	ldy	#0
exit	lreturn 2:@y

	END
	
**************************************************************************
*
* tnchktc: check the last entry, see if it's tc=xxx. If so,
* recursively find xxx and append that entry (minus the names)
* to take the place of the tc=xxx entry. This allows termcap
* entries to say "like an HP2621 but doesn't turn on the labels".
* Note that this works because of the left to right scan.
*
**************************************************************************

tnchktc	PRIVATE

	using	~TERMGLOBALS

;retval	equ	1
;space	equ	retval+2

	lsubroutine ,(2:retval)

;
; not important for GNO right now...write it later :)
;
	ld2	1,retval

exit	lreturn 2:retval

	END

**************************************************************************
*
* Return the (numeric) option id.
* Numeric options look like
*     li#80
* i.e. the option string is separated from the numeric value by
* a # character. If the option is not found we return -1.
* Note that we handle octal numbers beginning with 0.
*
**************************************************************************

tgetnum	START

	using	~TERMGLOBALS

;tmp	equ	1
;retval	equ	tmp+2
;bp	equ	retval+2
;space	equ	bp+4

	subroutine (4:id),(2:tmp,2:retval,4:bp)

	mv4	tbuf,bp
	
	ldy	#-1
	sty	retval

loop           iny
loop2	lda	[bp],y
	and	#$FF
	jeq	exit
	cmp	#':'
	bne	loop

gotit	iny
	lda	[bp],y
	and	#$FF
	jeq	exit
	cmp	#':'
	beq	gotit
	eor	[id]
	and	#$FF
	bne	loop

	iny
	lda	[bp],y
	and	#$FF
	jeq	exit
	cmp	#':'
	beq	gotit
	xba
	eor	[id]
	and	#$FF00
	bne	loop

	iny
	lda	[bp],y
	and	#$FF
	cmp	#'@'
	jeq	exit
	cmp	#'#'
	bne	loop2

	iny

	stz	retval
	ldx	#0

	lda	[bp],y
	and	#$FF
	cmp	#'0'
	beq	dooct

decloop	lda	[bp],y
	and	#$FF
	cmp	#'0'
	bcc	exit
	cmp	#'9'+1
	bcs	exit
	sbc	#'0'-1
	sta	tmp

	lda	retval
	asl	a	;*2
	asl	a                  ;*4
	adc	retval	;*5
	asl	a	;*10
	adc	tmp	;+digit
	sta	retval
	iny
	bra	decloop		

dooct	lda	[bp],y
	and	#$FF
	cmp	#'0'
	bcc	exit
	cmp	#'7'+1
	bcs	exit
	sbc	#'0'-1
	sta	tmp

	lda	retval
	asl	a
	asl	a
	asl	a
	adc	tmp	;+digit
	sta	retval
	iny
	bra	dooct		

exit	return 2:retval

	END

**************************************************************************
*
* Handle a flag option.
* Flag options are given "naked", ie. followed by a : or the end
* of the buffer. Return 1 is we find the option, or 0 if it
* not given.
*
**************************************************************************

tgetflag	START

	using	~TERMGLOBALS

;bp	equ	1
;tmp	equ	bp+4
;retval	equ	tmp+2
;space	equ	retval+2

	subroutine (4:id),(4:bp,2:tmp,2:retval)

	stz	retval
	mv4	tbuf,bp
	ldy	#-1

loop           iny
loop2	lda	[bp],y
	and	#$FF
	beq	exit
	cmp	#':'
	bne	loop

gotit	iny

	lda	[bp],y
	and	#$FF
	beq	exit
	cmp	#':'
	beq	gotit	
	eor	[id]
	and	#$FF
	bne	loop

	iny
	lda	[bp],y
	and	#$FF
	beq	loop
	cmp	#':'
	beq	gotit
	xba
	eor	[id]
	and	#$FF00
	bne	loop

	iny
	lda	[bp],y
	and	#$FF
	beq	bingo
	cmp	#'@'
	beq	exit
	cmp	#':'
	beq	bingo

	bra	loop2

bingo	inc	retval

exit	return 2:retval

	END

**************************************************************************
*
* Get a string valued option.
* These are given as
*     cl=^Z
* Much decoding is done on the strings, and the strings are
* placed in area, which is a ref parameter which is updated.
* No checking on area overflow.
*
**************************************************************************

tgetstr	START

	using	~TERMGLOBALS

;retval	equ	1
;bp	equ	retval+4
;space	equ	bp+4

	subroutine (4:id,4:area),(4:retval,4:bp)

	stz	retval
	stz	retval+2
	mv4	tbuf,bp

loop	lda	[bp]
	and	#$FF
	jeq	exit
	cmp	#':'
	beq	gotit
	inc	bp
	bne	loop
	inc	bp+2
	bra	loop

gotit	inc	bp
	bne	gotit0
	inc	bp+2

gotit0	lda	[bp]
	and	#$FF
	beq	exit
	cmp	#':'
	beq	gotit
	inc	bp
	bne	gotit1
	inc	bp+2
gotit1	eor	[id]
	and	#$FF
	bne	loop

	lda	[bp]
	and	#$FF
	beq	exit
	cmp	#':'
	beq	gotit
	inc	bp
	bne	gotit2
	inc	bp+2
gotit2	ldy	#1
	eor	[id],y
	and	#$FF
	bne	loop

	lda	[bp]
	and	#$FF
	cmp	#'@'
	beq	exit
	cmp	#'='
	bne	loop

	inc	bp
	bne	add0
	inc	bp+2
add0	anop

	pei	(area+2)
	pei	(area)
	pei	(bp+2)
	pei	(bp)
	jsr	tdecode
	sta	retval
	stx	retval+2

exit	return 4:retval

	END

**************************************************************************
*
* Tdecode does the grung work to decode the
* string capability escapes.
*
**************************************************************************

tdecode	PRIVATE

;ch	equ	1
;cp	equ	ch+2
;space	equ	cp+4

	lsubroutine (4:str,4:area),(2:ch,4:cp)


	lda	[area]
	sta	cp
	ldy	#2
	lda	[area],y
	sta	cp+2

	ldy	#0

loop	lda	[str],y
	and	#$FF
	jeq	breakloop
	cmp	#':'
	jeq	breakloop
	iny

	cmp	#'^'
	bne	caseslash

	lda	[str],y
	and	#$1F
	iny
	bra	casebreak0

caseslash	cmp	#'\'
	bne	casebreak0

	lda	[str],y
	and	#$FF
	sta	ch
	iny

	ldx	#0
nextc	lda	dp1,x
	and	#$FF
	beq	nextslash
	cmp	ch
	beq	gotslash
	inx
	bra	nextc
gotslash	lda	dp2,x
	and	#$FF
	bra	casebreak0

nextslash	lda	ch
	cmp	#'0'
	bcc	casebreak0
	cmp	#'7'+1
	bcs	casebreak0

	sbc	#'0'-1
	sta	ch

	ldx	#2

	lda	[str],y
	and	#$FF
numloop	asl	ch
	asl	ch
	asl	ch
	sbc	#'0'-1
	tsb	ch
	iny
	dex
	beq	casebreak0
	lda	[str],y
	and	#$FF
	cmp	#'0'
	bcc	casebreak
	cmp	#'7'+1
	bcc	numloop

casebreak	lda	ch
casebreak0	sta	[cp]
	inc	cp
	jne	loop
	inc	cp+2
	jmp	loop

breakloop	lda	#0
	sta	[cp]
	inc	cp
	bne	breakloop0
	inc	cp+2
breakloop0	ldy	#2
	lda	[area]
	sta	str
	lda	[area],y
	sta	str+2
	lda	cp
	sta	[area]
	lda	cp+2
	sta	[area],y	

	lreturn 4:str

dp1	dc	c'E^\:nrtbf',h'00'
dp2	dc	h'1b',c'^\:',h'0a0d09080c'

	END

**************************************************************************
*
* Routine to perform cursor addressing.
* CM is a string containing printf type escapes to allow
* cursor addressing.  We start out ready to print the destination
* line, and switch each time we print row or column.
* The following escapes are defined for substituting row/column:
*
*      %d      as in printf
*      %2      like %2d
*      %3      like %3d
*      %.      gives %c hacking special case characters
*      %+x     like %c but adding x first
*
*      The codes below affect the state but don't use up a value.
*
*      %>xy    if value > x add y
*      %r      reverses row/column
*      %i      increments row/column (for one origin indexing)
*      %%      gives %
*      %B      BCD (2 decimal digits encoded in one byte)
*      %D      Delta Data (backwards bcd)
*
* all other characters are ``self-inserting''.
*
**************************************************************************

tgoto	START

	using	~TERMGLOBALS

;tmp	equ	1
;oncol	equ	tmp+2
;which	equ	oncol+2
;ch	equ	which+2
;dp	equ	ch+2
;retval	equ	dp+4
;cp	equ	retval+4
;space	equ	cp+4

	subroutine (4:CM,2:destcol,2:destline),(2:tmp,2:oncol,2:which,2:ch,4:dp,4:retval,4:cp)

	ld4	result,dp
	ld4	oops,retval
	mv4	CM,cp
	mv2	destline,which
	stz	oncol

	lda	cp
	ora	cp+2
	jeq	exit

	stz	added

loop	lda	[cp]
	and	#$FF
	jeq	doneloop
	sta	ch
	inc	cp
	bne	loop0
	inc	cp+2

loop0	cmp	#'%'
	beq	docase
	
	sta	[dp]
	inc	dp
	bne	loop
	inc	dp+2
	bra	loop

docase	lda	[cp]
	and	#$FF
	sta	ch
	inc	cp
	bne	docase0
	inc	cp+2

docase0	cmp	#'n'
	bne	case1

	lda	#$60
	tsb	destcol
	tsb	destline
	bra	loop

case1	cmp	#'d'
	bne	case2

	lda	which
	cmp	#10
	bcc	one
	cmp	#100
	bcc	two
	bra	case2a

case2	cmp	#'3'
	bne	case3

case2a	UDivide (which,#100),(@x,which)
	txa
	ora	#'0'
	sta	[dp]
	inc	dp
	bne	two
	inc	dp+2
	bra	two

case3	cmp	#'2'
	bne	case4

two	UDivide (which,#10),(@a,@x)
	ora	#'0'
	sta	[dp]
	txa
	inc	dp
	bne	one0
	inc	dp+2
	bra	one0
one	UDivide (which,#10),(@x,@a)
one0	ora	#'0'
	sta	[dp]
	inc	dp
	bne	swap
	inc	dp+2
swap	sub2	#1,oncol,oncol
setwhich	ldx	destcol
	lda	oncol
	bne	case3a
	ldx	destline
case3a	stx	which
	jmp	loop                      

case4	cmp	#'>'
	bne	case5

	lda	[cp]
	and	#$FF
	sta	tmp
	add4	cp,#1,cp
	lda	which
	cmp	tmp
	beq	case4a
	bcc	case4a
	lda	[cp]
	and	#$FF
	clc
	adc	which
	sta	which
case4a	inc	cp
	jne	loop
	inc	cp+2
	jmp	loop

case5	cmp	#'+'
	bne	case6
	
	lda	[cp]
	and	#$FF
	clc
	adc	which
	sta	which
	inc	cp
	bne	case6a
	inc	cp+2
	bra	case6a

case6	cmp	#'.'
	bne	case7
;
; 	This code is worth scratching your head at for a
; 	while.  The idea is that various weird things can
; 	happen to nulls, EOT's, tabs, and newlines by the
; 	tty driver, arpanet, and so on, so we don't send
; 	them if we can help it.
;
; 	Tab is taken out to get Ann Arbors to work, otherwise
; 	when they go to column 9 we increment which is wrong
; 	because bcd isn't continuous.  We should take out
; 	the rest too, or run the thing through more than
; 	once until it doesn't make any of these, but that
; 	would make termlib (and hence pdp-11 ex) bigger,
; 	and also somewhat slower.  This requires all
; 	programs which use termlib to stty tabs so they
; 	don't get expanded.  They should do this anyway
; 	because some terminals use ^I for other things,
; 	like nondestructive space.
;               
case6a	lda	which
	bne	case6b
	cmp	#4
	beq	case6b
	cmp	#10
	bne	case6c
case6b	lda	oncol
	ora	>UP
	ora	>UP+2
	beq	case6c		
;
; DO THIS LATER!!!!
;
case6c	lda	which
	sta	[dp]
	inc	dp
	jne	swap
	inc	dp+2
	jmp	swap

case7	cmp	#'r'
	bne	case8

	ld2	1,oncol
	jmp	setwhich

case8	cmp	#'i'
	bne	case9

	inc	destcol
	inc	destline
	inc	which
	jmp	loop

case9	cmp	#'%'
	bne	case10

	sta	[dp]
	inc	dp
	jne	loop
	inc 	dp+2
	jmp	loop

case10	cmp	#'B'
	bne	case11

	UDivide (which,#10),(@a,@x)
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	which
	sta	which
	txa
	adc	which
	sta	which
	jmp	loop

case11	cmp	#'D'
	bne	case12

	lda	which
	and	#$0F
	asl	a
	sta	tmp
	lda	which
	sec
	sbc	tmp
	sta	which
	jmp	loop

case12	bra	exit		

doneloop	anop
;
; ADD LATER
;
	ld4	result,retval

exit	return 4:retval

oops	dc	c'OOPS!',h'00'
added	ds	10
result	ds	MAXRETURNSIZE

	END

**************************************************************************
*
* Put the character string cp out, with padding.
* The number of affected lines is affcnt, and the routine
* used to output one character is outc.
*
**************************************************************************

tputs	START

	using	~TERMGLOBALS

;mspc10	equ	1
;tmp	equ	mspc10+2
;i	equ	tmp+2
;space	equ	i+2


	subroutine (4:cp,2:affcnt,4:outc),(2:mspc10,2:tmp,2:i)

	lda	cp
	ora	cp+2
	jeq	exit

	lda	outc
	sta	goout+1
	sta	goout2+1
	lda	outc+1
	sta	goout+2
	sta	goout2+2

	stz	i
;
; convert number representing the delay
;
loopnum	lda	[cp]
	and	#$FF
	cmp	#'0'
	bcc	endnum
	cmp	#'9'+1
	bcs	endnum	
	sta	tmp
	lda	i
	asl	a
	asl	a
	adc	i
	asl	a
	adc	tmp
	sbc	#'0'-1
	sta	i
	inc	cp
	bne	loopnum
	inc	cp+2
	bra	loopnum

endnum	lda	i
	beq	num0
	asl	a
	asl	a
	adc	i
	asl	a
	sta	i

num0	lda	[cp]
	and	#$FF
	cmp	#'.'
	bne	notdot

	add4	cp,#1,cp

	lda	[cp]
	and	#$FF
	cmp	#'0'
	bcc	notdot
	cmp	#'9'+1
	bcs	notdot
	sbc	#'0'-1
	clc
	adc	i
	sta	i
;
; only one digit to right of decimal point
;
dot2	lda	[cp]
	and	#$FF
	cmp	#'0'
	bcc	notdot
	cmp	#'9'+1
	bcs	notdot
	inc	cp
	bne	dot2
	inc	cp+2
	bra	dot2
;
; If the delay is followed by a '*', then
; multiply by the affected lines count.
;
notdot	cmp	#'*'
	bne	outstr
	inc	cp
	bne	nodota
	inc	cp+2	
nodota	lda	affcnt
	beq	putzero
	dec	a
	beq	outstr
	Multiply (i,affcnt),@ax
putzero	sta	i
;
; The guts of the string
;
outstr	lda	[cp]	
	and	#$FF
	beq	delay
	pha
	inc	cp
	bne	goout
	inc	cp+2
goout	jsl	$FFFFFF
	bra	outstr
;
; if no delay needed, or output speed is
; not comprehensible, then don't try to delay
;
delay	lda	i
	beq	exit
	lda	>ospeed
	beq	exit
	bmi	exit
	cmp	#15
	bcs	exit
;
; Round up by half a character frame,
; and then do the delay.
; Too bad there are no user program accessible programmed delays.
; Transmitting pad characters slows many
; terminals down and also loads the system.
;		
	asl	a
	tax
	lda	tmspc10,x
	sta	mspc10
	lsr	a
	clc
	adc	i
	sta	i

	UDivide (i,mspc10),(i,@x)
;delayloop	lda	>PC
delayloop	lda	#0
	pha
goout2	jsl	$FFFFFF
	dec	i
	bne	delayloop	

exit	return


tmspc10	dc	i2'1,2000,1333,909,743,666,500,333,166,83,55,41,20,10,5'
	dc	i2'1,1,1,1,1,1,1,1,1'

	END


**************************************************************************
*
* Global data used by Termcap
*
**************************************************************************

~TERMGLOBALS	PRIVDATA

pathbuf_os dc i2'PBUFSIZ+2',i2'0' ; -3 so it can be null-terminated.
pathbuf	ds	PBUFSIZ	;holds raw path of filenames
pathvec	ds	PVECSIZ*4	;to point to names in pathbuf
pvec	ds	4	;holds usable tail of path vector
tbuf	ds	4

	END

~GLOBALS	START

ospeed	ENTRY
	dc	i2'0'
PC	ENTRY
	dc	i2'0'
UP	ENTRY
	dc	i4'0'
BC	ENTRY
	dc	i4'0'

	END
