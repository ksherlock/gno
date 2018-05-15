/**
 ** GNO/Termcap 1.2 - C headers
 **
 ** Written by Tim Meekins
 ** Copyright 1992 by Procyon, Inc.
 **
 **/

#ifndef TERMCAP_H
#define TERMCAP_H

extern char PC;
extern char *BC;
extern char *UP;
extern short ospeed;

int tgetent(char *, char *);
int tgetnum(char *);
int tgetflag(char *);
char *tgetstr(char *, char **);
char *tgoto(char *, int, int);
void tputs(char *, int, int (*outc)());

#endif /* TERMCAP_H */
