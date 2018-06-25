#
# This is the makefile for libtermcap, GNO v2.0.6
#
# $Id: Makefile,v 1.4 1998/03/08 18:16:03 gdr-ftp Exp $
#

LIB	= termcap
SRCS	= termcap.asm
NO_REZ = 1

#LOCAL_SETUP	= local_setup
HDIR		= $(RELEASE_DIR)/usr/include

.INCLUDE: /src/gno/lib/lib.mk

termcap.o: termcap.asm termcap.mac

# If this target fails, do a manual update.
local_setup:
	cmp /usr/include/termcap.h termcap.h

release::
	$(INSTALL) -d $(HDIR)
	$(INSTALL) -d $(RELEASE_DIR)/usr/man/man3
	$(INSTALL) -d $(RELEASE_DIR)/usr/man/man5
	$(INSTALL) termcap.h $(HDIR)
	$(INSTALL) termcap.3G $(RELEASE_DIR)/usr/man/man3/termcap.3

install::
	$(INSTALL) termcap.h /usr/include/
	$(INSTALL) termcap.3G /usr/man/man3/termcap.3
	$(INSTALL) termcap.5G /usr/man/man3/termcap.5
