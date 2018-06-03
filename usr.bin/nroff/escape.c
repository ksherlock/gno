/*
 *	escape.c - Escape and special character input processing portion of
 *	           nroff word processor
 *
 *	adapted for atariST/TOS by Bill Rosenkranz 11/89
 *	net:	rosenkra@hall.cray.com
 *	CIS:	71460,17
 *	GENIE:	W.ROSENKRANZ
 *
 *	original author:
 *
 *	Stephen L. Browning
 *	5723 North Parker Avenue
 *	Indianapolis, Indiana 46220
 *
 *	history:
 *
 *	- Originally written in BDS C;
 *	- Adapted for standard C by W. N. Paul
 *	- Heavily hacked up to conform to "real" nroff by Bill Rosenkranz
 *      - Heavily modified by Devin Reade to avoid memory trashing bugs.
 *
 * $Id: escape.c,v 1.2 1997/03/20 06:40:50 gdr Exp $
 */

#ifdef __ORCAC__
segment "escape____";
#pragma noroot
#pragma optimize 79
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef __GNO__
#include <err.h>
#else
#include "unix/err.h"
#endif

#ifdef sparc
#include "unix/sunos.h"
#endif

#include "nroff.h"
#include "escape.h"
#include "macros.h"

const char *specialchar (const char *s);

/*
 * expesc
 *
 *	Expand escape sequences in the buffer <src>, placing the results
 *	in buffer <dest>.  If the number of characters written into <dest>
 *	would be more than <len-1> characters, then abort with an error
 *	message.
 */
void
expesc (char *src, char *dest, size_t len) {
    register char  *s;
    register char  *t;
    register char  *pstr;
    register int	i;
    register int	val;
    register int	autoinc;
    char		c;
    char		fs[5];				/* for font change */
    char		nrstr[20];
    char		fmt[20];
    char		name[10];
    int		nreg;
    char	       *pfs;
    int		inc;
    int		tmp;
    char		delim;
    const char *percent = "%";
    char *scratch;
    
    
    s = src;
    t = dest;
    
    
    /*
     *   if escape parsing is not on, just copy string
     */
    if (dc.escon == NO) {
	if (strlen(src) > len-1) {
	    errx(-1, "buffer overflow at %s:%d", __FILE__, __LINE__);
	}
	strcpy (dest, src);
	return;
    }

    /*
     *   do it...
     */
    while (*s != EOS) {
	if (*s != dc.escchr) {
	    /*
	     *   not esc, continue...
	     */
	    *t++ = *s++;
	} else if (*(s + 1) == dc.escchr) {
	    /*
	     *   \\			escape escape
	     */
	    *t++ = *s++;
	    ++s;
	} else {
	    switch(*(s+1)) {


	    case 'n':
		/*
		 *   \nx, \n(xx		register
		 *
		 *   first check for \n+... or \n-... (either form)
		 */
		s += 2;
		autoinc = 0;
		if (*s == '+') {
		    autoinc = 1;
		    s += 1;
		}
		if (*s == '-') {
		    autoinc = -1;
		    s += 1;
		}
		
		
		/*
		 *   was this \nx or \n(xx form?
		 */
		if (isalpha (*s)) {
		    /*
		     *   \nx form. find reg (a-z)
		     */
		    nreg = tolower (*s) - 'a';
		    
		    
		    /*
		     *   was this \n+x or \n-x? if so, do the
		     *   auto incr
		     */
		    if (autoinc > 0) {
			dc.nr[nreg] += dc.nrauto[nreg];
		    } else if (autoinc < 0) {
			dc.nr[nreg] -= dc.nrauto[nreg];
		    }
		    
		    /*
		     *   display format
		     */
		    if (dc.nrfmt[nreg] == '1') {
			/*
			 *   normal decimal digits
			 */
			t += itoda (dc.nr[nreg], t, 6) - 1;
		    } else if (dc.nrfmt[nreg] == 'i') {
			/*
			 *   lower roman
			 */
			t += itoroman (dc.nr[nreg], t, 24) - 1;
		    } else if (dc.nrfmt[nreg] == 'I') {
			/*
			 *   upper roman
			 */
			t += itoROMAN (dc.nr[nreg], t, 24) - 1;
		    } else if (dc.nrfmt[nreg] == 'a') {
			/*
			 *   lower letters
			 */
			t += itoletter (dc.nr[nreg], t, 12) - 1;
		    } else if (dc.nrfmt[nreg] == 'A') {
			/*
			 *   upper letters
			 */
			t += itoLETTER (dc.nr[nreg], t, 12) - 1;
		    } else if (dc.nrfmt[nreg] & 0x80) {
			/*
			 *   zero-filled decimal
			 */
			sprintf (fmt, "%%0%dld", (int)(dc.nrfmt[nreg] & 0x7F));
			fmt[5] = '\0';
			sprintf (nrstr, fmt, (long) dc.nr[nreg]);
			tmp = dc.nrfmt[nreg] & 0x7F;
			nrstr[tmp] = '\0';
			
			strcpy (t, nrstr);
			t += strlen (nrstr);
		    } else {
			/*
			 *   normal (default)
			 */
			t += itoda (dc.nr[nreg], t, 6) - 1;
		    }
		    ++s;
		} else if (*s == '%') {
		    /*
		     *   \n% form. find index into reg struct
		     */
		    FINDREG(percent, nreg, scratch);
		    if (nreg < 0) {
			errx(-1, "no register match (%)");
		    }
		    
		    
		    /*
		     *   was this \n+% or \n-%? if so, do the
		     *   auto incr
		     */
		    if (autoinc > 0) {
			rg[nreg].rval += rg[nreg].rauto;
		    } else if (autoinc < 0) {
			rg[nreg].rval -= rg[nreg].rauto;
		    }
		    
		    
		    /*
		     *   display format
		     */
		    if (rg[nreg].rfmt == '1') {
			/*
			 *   normal decimal digits
			 */
			t += itoda (rg[nreg].rval, t, 6) - 1;
		    } else if (rg[nreg].rfmt == 'i') {
			/*
			 *   lower roman
			 */
			t += itoroman (rg[nreg].rval, t, 24) - 1;
		    } else if (rg[nreg].rfmt == 'I') {
			/*
			 *   upper roman
			 */
			t += itoROMAN (rg[nreg].rval, t, 24) - 1;
		    } else if (rg[nreg].rfmt == 'a') {
			/*
			 *   lower letters
			 */
			t += itoletter (rg[nreg].rval, t, 12) - 1;
		    } else if (rg[nreg].rfmt == 'A') {
			/*
			 *   upper letters
			 */
			t += itoLETTER (rg[nreg].rval, t, 12) - 1;
		    } else if (rg[nreg].rfmt & 0x80) {
			/*
			 *   zero-filled decimal
			 */
			sprintf (fmt, "%%0%dld",
				 (int)(rg[nreg].rfmt & 0x7F));
			fmt[5] = '\0';
			sprintf (nrstr, fmt, (long) rg[nreg].rval);
			tmp = rg[nreg].rfmt & 0x7F;
			nrstr[tmp] = '\0';
			
			strcpy (t, nrstr);
			t += strlen (nrstr);
		    } else {
			/*
			 *   normal (default)
			 */
			t += itoda (rg[nreg].rval, t, 6) - 1;
		    }
		    s += 1;
		} else if (*s == '(') {
		    /*
		     *   \n(xx form. find index into reg struct
		     */
		    s += 1;
		    name[0] = *s;
		    name[1] = *(s + 1);
		    if (name[1] == ' '  || name[1] == '\t'
			||  name[1] == '\n' || name[1] == '\r') {
			name[1] = '\0';
		    }
		    name[2] = '\0';
		    FINDREG(name, nreg, scratch);
		    if (nreg < 0) {
			errx(-1, "no register match (%s)", name);
		    }
		    
		    
		    /*
		     *   was this \n+(xx or \n-(xx? if so, do the
		     *   auto incr
		     */
		    if (rg[nreg].rflag & RF_WRITE) {
			if (autoinc > 0) {
			    rg[nreg].rval += rg[nreg].rauto;
			} else if (autoinc < 0) {
			    rg[nreg].rval -= rg[nreg].rauto;
			}
		    }
		    
		    
		    /*
		     *   display format
		     */
		    if (rg[nreg].rfmt == '1') {
			/*
			 *   normal decimal digits
			 */
			t += itoda (rg[nreg].rval, t, 6) - 1;
		    } else if (rg[nreg].rfmt == 'i') {
			/*
			 *   lower roman
			 */
			t += itoroman (rg[nreg].rval, t, 24) - 1;
		    } else if (rg[nreg].rfmt == 'I') {
			/*
			 *   upper roman
			 */
			t += itoROMAN (rg[nreg].rval, t, 24) - 1;
		    } else if (rg[nreg].rfmt == 'a') {
			/*
			 *   lower letters
			 */
			t += itoletter (rg[nreg].rval, t, 12) - 1;
		    } else if (rg[nreg].rfmt == 'A') {
			/*
			 *   upper letters
			 */
			t += itoLETTER (rg[nreg].rval, t, 12) - 1;
		    } else if (rg[nreg].rfmt & 0x80) {
			/*
			 *   zero-filled decimal
			 */
			sprintf (fmt, "%%0%dld",
				 (int)(rg[nreg].rfmt & 0x7F));
			fmt[5] = '\0';
			sprintf (nrstr, fmt, (long) rg[nreg].rval);
			tmp = rg[nreg].rfmt & 0x7F;
			nrstr[tmp] = '\0';
			
			strcpy (t, nrstr);
			t += strlen (nrstr);
		    } else {
			/*
			 *   normal (default)
			 */
			t += itoda (rg[nreg].rval, t, 6) - 1;
		    }
		    s += 2;
		}

		break;


	    case '"':	/*   \"		comment				*/
		*s = EOS;
		*t = *s;
		return;

	    case '*':	/*   \*x, \*(xx		string			*/
		/*
		 
		 */
		s += 2;
		if (*s == '(') {
		    /*
		     *   \*(xx form
		     */
		    s += 1;
		    name[0] = *s;
		    name[1] = *(s + 1);
		    name[2] = '\0';
		    pstr = getstr (name);
		    if (!pstr) {
			errx(-1,"string not found ( %s )", name);
		    }
		    while (*pstr) {
			*t++ = *pstr++;
		    }
		    s += 2;
		} else {
		    /*
		     *   \*x form
		     */
		    name[0] = *s;
		    name[1] = '\0';
		    pstr = getstr (name);
		    if (!pstr) {
			errx(-1, "string not found ( %s )", name);
		    }
		    while (*pstr) {
			*t++ = *pstr++;
		    }
		    s += 1;
		}
		break;

	    case 'f':	/*   \fx	font				*/
		s += 2;
		pfs = fs;		/* set up ret string */
		fs[0] = '\0';
		
		/*
		 *  it parses 1-2 char of s and returns esc seq for
		 *  \fB and \fR (\fI is same as \fB)
		 */
		fontchange (*s, pfs);
		
		/*
		 *   imbed the atari (vt52) escape seq
		 */
		while (*pfs) {
		    *t++ = *pfs++;
		}
		++s;			/* skip B,I,R,S,P */
		break;

	    case '(':	/*   \(xx	special char			*/
	    {
	    	char *cp;
	    	s += 2;
	    	cp = specialchar(s);
	    	while (*cp) *t++ = *cp++;
			s  += 2;
		}
		break;

	    case 'e':	/*   \e		printable version of escape	*/
		*t++ = dc.escchr;
		s   += 2;
		break;

	    case '-':	/*   \-		minus				*/
	    case '`':	/*   \`		grave, like \(ga		*/
	    case '\'':	/*   \'		accute, like \(aa		*/
	    case '.':	/*   \.		period				*/

		/* verbatim */
		*t++ = *(s+1);
		s  += 2;
		break;

	    case ' ':	/*   \(space)	non-breaking space				*/
	    case '~':   /* paddable non-breaking space */
		/* verbatim */
		*t++ = NBSP;
		s  += 2;
		break;


	    case '0':	/*   \0		digital width space		*/
		*t++ = NBSP;
		s  += 2;
		break;

	    case '|':	/*   \|		narrow width char (0 in nroff)	*/
	    case '^':	/*   \^		narrow width char (0 in nroff)	*/
	    case '&':	/*   \&		non-printing zero width		*/
	    case '!':	/*   \!		transparent copy line		*/
	    case '$':	/*   \$N	interpolate arg 1<=N<=9		*/
	    case 'a':	/*   \a						*/
	    case 'b':	/*   \b'abc...'					*/
	    case 'c':	/*   \c						*/
	    case 'd':	/*   \d						*/
	    case 'k':	/*   \kx					*/
	    case 'l':	/*   \l'Nc'					*/
	    case 'L':	/*   \L'Nc'					*/
	    case 'p':	/*   \p						*/
	    case 'r':	/*   \r						*/
	    case 's':	/*   \sN,\s+-N					*/
	    case 'u':	/*   \u						*/
	    case 'w':	/*   \w'str'					*/
	    case 'x':	/*   \x'N'					*/
	    case '{':	/*   \{						*/
	    case '}':	/*   \}						*/
	    case '\n':	/*   \(newline)	ignore newline			*/
	    case '\r':	/*   \(newline)	ignore newline			*/

		s += 2;	/* currently ignored */
		break;

	    case '%':	/*   \%		hyphen				*/
		*t++ = '-';
		*t++ = '-';
		s += 2;
		break;

	    case 'h':	/*   \h'N'	horiz motion*/
		s    += 2;
		delim = *s++;
		val   = atoi (s);
		for (i = 0; i < val; i++) {
		    *t++ = NBSP;
		}
		while (*s != delim) {
		    if (*s == 0) {
			break;
		    }
		    s++;
		}
		if (*s) {
		    s++;
		}
		break;

	    case 'o':	/*   \o'abc...'		overstrike*/
		s  += 2;
		delim = *s++;
		while (*s != EOS && *s != delim) {
		    *t++ = *s++;
		    *t++ = 0x08;
		}
		s++;
		break;

	    case 't':	/*   \t		horizontal tab*/
		*t++ = '\t';
		s += 2;
		break;

	    case 'v':	/*   \v'N'	vert tab*/
		s    += 2;
		delim = *s++;
		val   = atoi (s);
		for (i = 0; i < val; i++) {
		    *t++ = 0x0A;
		}
		while (*s != delim) {
		    if (*s == 0) {
			break;
		    }
		    s++;
		}
		if (*s) {
		    s++;
		}
		break;

	    case 'z':	/*   \zc	print c w/o spacing*/
		s  += 2;
		*t++ = *s++;
		*t++ = 0x08;
		break;

	    default:	/*   \X		any other character not above*/
		s   += 1;
		*t++ = *s++;
		break;
	    }
	}
    }
    
    /*
     *   end the string and return it in original buf
     */
    *t = EOS;

	if (strlen(dest) > len-1) {
	    errx(-1, "buffer overflow at %s:%d", __FILE__, __LINE__);
	}

    strcpy (src, dest);
}



/*
 * fontchange
 *	handles \fx font change escapes for R,B,I,S,P (atari-specific)
 *	resets current and last font in dc struct (last used for .ft
 *	with no args)
 */

void
fontchange (char fnt, char *s) {
    int	tmp;
    unsigned i;
    
    *s = '\0';
    switch (fnt) {
    case 'R':				/* Times Roman */
	if (dc.dofnt == YES) {
#ifdef SHORT_STANDOUT
		i = 0;
		if (dc.fontbits & (1 << 2)) s[i++] = E_ITALIC;
		if (dc.fontbits & (1 << 3)) s[i++] = E_BOLD;
		s[i++] = 0;
		dc.fontbits = 0;
#else
	    strcpy (s, e_standout);
#endif
	}
	dc.lastfnt = dc.thisfnt;
	dc.thisfnt = 1;
	break;
    case 'I':				/* Times italic */
	if (dc.dofnt == YES) {
#ifdef SHORT_STANDOUT
	    s[0] = S_ITALIC; s[1] = 0;
	    dc.fontbits |= (1 << 2);
#else
	    strcpy (s, s_italic);
#endif
	}
	dc.lastfnt = dc.thisfnt;
	dc.thisfnt = 2;
	break;
    case 'B':				/* Times bold */
	if (dc.dofnt == YES) {
#ifdef SHORT_STANDOUT
	    s[0] = S_BOLD; s[1] = 0;
	    dc.fontbits |= (1 << 3);
#else
	    strcpy (s, s_bold); 
#endif
	}
	dc.lastfnt = dc.thisfnt;
	dc.thisfnt = 3;
	break;
    case 'S':				/* math/special */
	*s = '\0';
	dc.lastfnt = dc.thisfnt;
	dc.thisfnt = 4;
	break;
    case 'P':				/* previous (exchange) */
	if (dc.dofnt == YES) {
	    if (dc.lastfnt == 1) {
#ifdef SHORT_STANDOUT
		i = 0;
		if (dc.fontbits & (1 << 2)) s[i++] = E_ITALIC;
		if (dc.fontbits & (1 << 3)) s[i++] = E_BOLD;
		s[i++] = 0;
		dc.fontbits = 0;
#else
		strcpy (s, e_standout); /* to R */
#endif
	    } else if (dc.lastfnt == 2) {
#ifdef SHORT_STANDOUT
		s[0] = S_ITALIC; s[1] = 0;
		dc.fontbits |= (1 << 2);
#else
		strcpy (s, s_italic); /* to I */
#endif
	    } else if (dc.lastfnt == 3) {
#ifdef SHORT_STANDOUT
		s[0] = S_BOLD; s[1] = 0;
		dc.fontbits |= (1 << 3);
#else
		strcpy (s, s_bold); /* to B */
#endif
	    } else {
		*s = '\0';		/* nothing */
	    }
	}
	tmp        = dc.thisfnt;		/* swap this/last */
	dc.thisfnt = dc.lastfnt;
	dc.lastfnt = tmp;
	break;
    default:
	*s = '\0';
	break;
    }
    
    set_ireg (".f", dc.thisfnt, 0);
}



#if 0		/* using macro version */

/*
 * findreg
 *
 *	find register named 'name' in pool. return index into array or -1
 *	if not found.
 */
int
findreg (register char *name) {
    register int	i;
    register char  *prname;
    
    for (i = 0; i < MAXREGS; i++) {
	prname = rg[i].rname;
	if (*prname == *name && *(prname + 1) == *(name + 1)) {
	    break;
	}
    }
    return ((i < MAXREGS) ? i : -1);
}

#endif
