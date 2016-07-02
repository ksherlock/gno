/*-
 * Copyright (c) 1987, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#ifdef __ORCAC__
#pragma lint -1
#endif

#ifndef lint
static const char copyright[] =
"@(#) Copyright (c) 1987, 1993\n\
	The Regents of the University of California.  All rights reserved.\n";
#endif /* not lint */

#if 0
#ifndef lint
static char sccsid[] = "@(#)printenv.c	8.2 (Berkeley) 5/4/95";
#endif /* not lint */
#endif

#include <sys/cdefs.h>
//__FBSDID("$FreeBSD$");

#include <sys/types.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void	usage(void);

#ifdef __ORCAC__
#include <types.h>
#include <shell.h>

static struct ResultBuf255 name  = { 255 };
static struct ResultBuf255 value  = { 255 };

#else
extern char **environ;
#endif



#if defined(__STACK_CHECK__)
#include <gno/gno.h>
static void
stackResults(void) {
	fprintf(stderr, "stack usage:\t ===> %d bytes <===\n",
		_endStackCheck());
}
#endif


/*
 * printenv
 *
 * Bill Joy, UCB
 * February, 1979
 */
int
main(int argc, char **argv)
{
	char *cp, **ep;
	size_t len;
	int ch;

#ifdef __STACK_CHECK__
	_beginStackCheck();
	atexit(stackResults);
#endif

	while ((ch = getopt(argc, argv, "")) != -1)
		switch(ch) {
		case '?':
		default:
			usage();
		}
	argc -= optind;
	argv += optind;

	if (argc == 0) {
#ifdef __ORCAC__
		static ReadIndexedGSPB dcb = { 4, &name, &value };
		
		for (dcb.index = 1;;++dcb.index) {
			ReadIndexedGS(&dcb);
			if (_toolErr) {
				exit(1);
			}
			if (name.bufString.length == 0) break;
			(void)printf("%.*s=%.*s\n", 
				name.bufString.length, name.bufString.text,
				value.bufString.length, value.bufString.text
			);
		}
#else
		for (ep = environ; *ep; ep++)
			(void)printf("%s\n", *ep);
#endif
		exit(0);
	}
	len = strlen(*argv);
#ifdef __ORCAC__
	{
		static ReadVariableGSPB dcb = { 3, &name.bufString, &value };

		if (len > 255) {
			exit(1);
		}

		name.bufString.length = len;
		memcpy(name.bufString.text, *argv, len);

		ReadVariableGS(&dcb);
		if (_toolErr) {
			exit(1);
		}
		/* no way to differentiate an empty variable from a missing variable. */
		if (value.bufString.length) {
			(void)printf("%.*s\n",
				value.bufString.length,	value.bufString.text
			);
			exit(0);
		}
	}

#else
	for (ep = environ; *ep; ep++)
		if (!memcmp(*ep, *argv, len)) {
			cp = *ep + len;
			if (!*cp || *cp == '=') {
				(void)printf("%s\n", *cp ? cp + 1 : cp);
				exit(0);
			}
		}
#endif
	exit(1);
}

void
usage(void)
{
	(void)fprintf(stderr, "usage: printenv [name]\n");
	exit(1);
}

