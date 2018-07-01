/*
 * Copyright (c) 1995 Peter Wemm <peter@freebsd.org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, is permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice immediately at the beginning of the file, without modification,
 *    this list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. This work was done expressly for inclusion into FreeBSD.  Other use
 *    is permitted provided this notation is included.
 * 4. Absolutely no warranty of function or purpose is made by the author
 *    Peter Wemm.
 * 5. Modifications may be freely made to this file providing the above
 *    conditions are met.
 *
 * $Id: libutil.h,v 1.1 1997/02/28 04:42:01 gdr Exp $
 */

#ifndef _LIBUTIL_H_
#define	_LIBUTIL_H_

#ifndef _SYS_CDEFS_H_
#include <sys/cdefs.h>
#endif

/* Avoid pulling in all the include files for no need */
struct termios;
struct winsize;
struct utmp;

__BEGIN_DECLS
void	hexdump(const void *_ptr, int _length, const char *_hdr, int _flags);
void	login __P((struct utmp *ut));
int	login_tty __P((int fd));
int	logout __P((char *line));
void	logwtmp __P((char *line, char *name, char *host));
int	openpty __P((int *amaster, int *aslave, char *name,
		     struct termios *termp, struct winsize *winp));
__END_DECLS


/* Flags for hexdump(3). */
#define	HD_COLUMN_MASK		0xff
#define	HD_DELIM_MASK		0xff00
#define	HD_OMIT_COUNT		(1L << 16)
#define	HD_OMIT_HEX		(1L << 17)
#define	HD_OMIT_CHARS		(1L << 18)

#endif /* !_LIBUTIL_H_ */
