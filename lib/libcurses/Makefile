#	From: @(#)Makefile	8.2 (Berkeley) 1/2/94
#	$Id: Makefile,v 1.2 1998/01/26 06:08:43 taubert Exp $

#CFLAGS+=#-DTFILE=\"/dev/ttyp0\"
CFLAGS+=-D_CURSES_PRIVATE -I${PWD}
#LDADD+= -ltermcap
LIB=	curses
SRCS=	addbytes.c addch.c addnstr.c box.c clear.c clrtobot.c clrtoeol.c \
	cr_put.c ctrace.c cur_hash.c curses.c delch.c deleteln.c delwin.c \
	erase.c fullname.c getch.c getstr.c id_subwins.c idlok.c initscr.c \
	insch.c insertln.c longname.c move.c mvwin.c newwin.c overlay.c \
	overwrite.c printw.c _putchar.c putchar.c refresh.c scroll.c \
	setterm.c standout.c toucholap.c touchwin.c tscroll.c tstp.c tty.c \
	unctrl.c
# Having trouble with this puppy
_SRCS=	scanw.c
MAN3=	curses.3

#beforeinstall:
#	-cd ${.CURDIR}; cmp -s curses.h ${DESTDIR}/usr/include/curses.h || \
#	    install -c -o ${BINOWN} -g ${BINGRP} -m 444 curses.h \
#	    ${DESTDIR}/usr/include

CFLAGS+=-Slibcurses_
OPTIMIZE=79
DEBUG=	25

.INCLUDE: /src/gno/lib/lib.mk
