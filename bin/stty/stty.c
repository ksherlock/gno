/*
 * stty.c
 *
 * Set terminal parameters
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <sgtty.h>
#include <sys/ioctl.h>
#include <gno/gno.h>
#include <unistd.h>

struct sgttyb sg;
struct tchars tc;
struct ltchars ltc;
struct winsize wz;
long localmode;


/* B0 - B57600 are defined before these others */
enum {
    LCRTERA_ON = 18,
    LCRTERA_OFF,
    LCTLECH_ON,
    LCTLECH_OFF,

    COOKED_ON,

    SUSP_C,
    STOP_C,
    START_C,
    QUIT_C,
    ERASE_C,
    INTR_C,
    EOF_C,
    WERASE_C,
    RPRNT_C,
    FLUSH_C,
    LNEXT_C,
    DSUSP_C
};


char *baudtbl[] = {
"0",
"50",
"75",
"110",
"134.5",
"150",
"57600",
"300",
"600",
"1200",
"1800",
"2400",
"4800",
"9600",
"19200",
"38400"};

#if 0
typedef struct opts {
    char *name;
    int item;
} opts_s;
opts_s options[] = {
    "75",	B75,
    "110",	B110,
    "134",	B134,
    "150",	B150,
    "300",	B300,
    "600",	B600,
    "1200",	B1200,
    "1800",	B1800,
    "2400",	B2400,
    "4800",	B4800,
    "9600",	B9600,
    "19200",	B19200,
    "38400",	B38400,
    "57600",	B57600,
    "lcrtera", 	LCRTERA_ON,
    "-lcrtera", LCRTERA_OFF,
    "crterase", LCRTERA_ON,
    "-crterase",        LCRTERA_OFF,
    "lctlech",	LCTLECH_ON,
    "-lctlech",	LCTLECH_OFF,
    "ctlecho",  LCTLECH_ON,
    "-ctlecho", LCTLECH_OFF,
    "crmod",	CRMOD_ON,
    "-crmod",	CRMOD_OFF,
    "nl",       CRMOD_ON,
    "-nl",      CRMOD_OFF,
    "echo",	ECHO_ON,
    "-echo",	ECHO_OFF,
    "raw",	RAW_ON,
    "-raw",     RAW_OFF,
    "cooked",	RAW_OFF,
    "cbreak",	CBREAK_ON,
    "-cbreak",	CBREAK_OFF,
    "susp",	SUSP_C,
    "stop",	STOP_C,
    "start",	START_C,
    "quit",	QUIT_C,
    "erase",	ERASE_C,
    "intr",	INTR_C,
    "eof",	EOF_C,
    "werase",   WERASE_C,
    "rprnt",    RPRNT_C,
    "flush",    FLUSH_C,
    "lnext",    LNEXT_C,
    "dsusp",    DSUSP_C,
    "",		0
};

int lookup(char *s)
{
int i;

    for (i = 0; options[i].item; i++) {
        if (!strcmp(options[i].name,s)) return (options[i].item);
    }
    return 0;
}
#endif
enum {
    TSPEED,
    TMODE,
    TLMODE,
    TCHAR,
    TOTHER,
};
typedef struct opts {
    char *name;
    int type;
    int value;
} opts_s;
/* pre-sorted */
opts_s options[] = {
    { "110",      TSPEED, B110 },
    { "1200",     TSPEED, B1200 },
    { "134",      TSPEED, B134 },
    { "150",      TSPEED, B150 },
    { "1800",     TSPEED, B1800 },
    { "19200",    TSPEED, B19200 },
    { "2400",     TSPEED, B2400 },
    { "300",      TSPEED, B300 },
    { "38400",    TSPEED, B38400 },
    { "4800",     TSPEED, B4800 },
    { "57600",    TSPEED, B57600 },
    { "600",      TSPEED, B600 },
    { "75",       TSPEED, B75 },
    { "9600",     TSPEED, B9600 },
    { "cbreak",   TMODE,  CBREAK },
    { "cooked",   TOTHER, COOKED_ON },
    { "crmod",    TMODE,  CRMOD },
    { "crterase", TLMODE, LCRTERA_ON },
    { "ctlecho",  TLMODE, LCTLECH_ON },
    { "dsusp",    TCHAR,  DSUSP_C },
    { "echo",     TMODE,  ECHO },
    { "eof",      TCHAR,  EOF_C },
    { "erase",    TCHAR,  ERASE_C },
    { "even",     TMODE,  EVENP },
    { "flush",    TCHAR,  FLUSH_C },
    { "intr",     TCHAR,  INTR_C },
    { "lcase",    TMODE,  LCASE },
    { "lcrtera",  TLMODE, LCRTERA_ON },
    { "lctlech",  TLMODE, LCTLECH_ON },
    { "lnext",    TCHAR,  LNEXT_C },
    { "nl",       TMODE,  CRMOD },
    { "odd",      TMODE,  ODDP },
    { "quit",     TCHAR,  QUIT_C },
    { "raw",      TMODE,  RAW },
    { "rprnt",    TCHAR,  RPRNT_C },
    { "start",    TCHAR,  START_C },
    { "stop",     TCHAR,  STOP_C },
    { "susp",     TCHAR,  SUSP_C },
    { "tabs",     TMODE,  XTABS },
    { "tandem",   TMODE,  TANDEM },
    { "werase",   TCHAR,  WERASE_C },
};


int lookup(char *s) {
    unsigned negate = 0;
    unsigned item;

    // binary search...
    unsigned begin = 0;
    unsigned end = sizeof(options) / sizeof(options[0]);
    unsigned mid;
    int cmp;

    if (s[0] == '-') { negate = 1; ++s; }

    for (;;) {
        mid = (begin+end)>>1;
        cmp = strcmp(options[mid].name, s);
        if (cmp == 0) {
            int type = options[mid].type;
            int value = options[mid].value;

            if (type == TMODE) {
                if (negate) sg.sg_flags &= ~value;
                else sg.sg_flags |= value;
                return 0;
            }
            if (type == TLMODE) {
                if (negate) ++value;
                return value;
            }
            if (negate) return -1;
            if (type == TSPEED) {
                sg.sg_ispeed = sg.sg_ospeed = value;
                return 0;
            }
            return value;
        }
        if (cmp < 0) {
            begin = mid + 1;
            if (begin >= end) return -1;
        } else {
            end = mid;
            if (end <= begin) return -1;
        }
    }
    return -1;

}


void usage(void)
{
    fputs("usage: stty [option ...]\n", stderr);
    exit(1);
}

char parsechar(char *s)
{
int x;
int l = strlen(s);

    if (s[0] == '^') {
	if (l != 2) usage();
	if (s[1] == '?') return 0x7f;
        else return toupper(s[1])-64;
    }
    if (s[0] == '\\') {
        char *cp = NULL;
        long l;
        if (!isdigit(s[1])) usage();
        l = strtol(s+1, &cp, 0);
        if (l < 0 || l > 255 || *cp) usage();
        return l;
    }
    if (l == 5 && !strcmp(s, "undef")) return 0xff;
    if (l != 1) usage();
    return s[0];
}


char *dash[] = {"","-"};

char *doctrl(char c)
{
static char ss[3] = "  ";

    if (c == (char)-1) c = ' ';
    if (c == 0x7F) {
    	ss[0] = '^';
	ss[1] = '?';
    }
    else if (c < 32) {
        ss[0] = '^';
        ss[1] = c + '@';
    }
    else {
        ss[0] = c;
        ss[1] = ' ';
    }
    return ss;
}

void printCurSettings(void)
{
    printf("old tty, speed %s baud, %d rows, %d columns\n",
    	baudtbl[sg.sg_ispeed & 0xF],wz.ws_row,wz.ws_col);
    printf("%seven %sodd %sraw %snl %secho %slcase %standem %stabs %scbreak\n",
    	dash[(sg.sg_flags & EVENP) == 0],
	dash[(sg.sg_flags & ODDP) == 0],
	dash[(sg.sg_flags & RAW) == 0],
	dash[(sg.sg_flags & NLDELAY) == 0],
	dash[(sg.sg_flags & ECHO) == 0],
	dash[(sg.sg_flags & LCASE) == 0],
	dash[(sg.sg_flags & TANDEM) == 0],
	dash[(sg.sg_flags & XTABS) == 0],
	dash[(sg.sg_flags & CBREAK) == 0]);
    printf("%stilde %sflusho %slitout %spass8 %snohang\n",
	dash[(localmode & LTILDE) == 0],
	dash[(localmode & LFLUSHO) == 0],
	dash[(localmode & LLITOUT) == 0],
	dash[(localmode & LPASS8) == 0],
	dash[(localmode & LNOHANG) == 0]);
    printf("%spendin %snoflsh\n",
	dash[(localmode & LPENDIN) == 0],
	dash[(localmode & LNOFLSH) == 0]);

    fputs("erase  kill   werase rprnt  flush  lnext  susp   intr   quit   stop   eof\n", stdout);
    printf("%-7s",doctrl(sg.sg_erase));
    printf("%-7s",doctrl(sg.sg_kill));
    printf("%-7s",doctrl(ltc.t_werasc));
    printf("%-7s",doctrl(ltc.t_rprntc));
    printf("%-7s",doctrl(ltc.t_flushc));
    printf("%-7s",doctrl(ltc.t_lnextc));
    printf("%2s",doctrl(ltc.t_suspc));
    printf("/%2s  ",doctrl(ltc.t_dsuspc));
    printf("%-7s",doctrl(tc.t_intrc));
    printf("%-7s",doctrl(tc.t_quitc));
    printf("%2s",doctrl(tc.t_stopc));
    printf("/%2s  ",doctrl(tc.t_startc));
    printf("%-7s\n",doctrl(tc.t_eofc));
}

#if defined(__STACK_CHECK__)
static void
stackResults(void) {
    fprintf(stderr, "stack usage:\t ===> %d bytes <===\n",
        _endStackCheck());
}
#endif

int main(int argc, char *argv[])
{
int i,item;
char c;

#ifdef __STACK_CHECK__
    _beginStackCheck();
    atexit(stackResults);
#endif

    ioctl(STDIN_FILENO,TIOCGETP,&sg);
    ioctl(STDIN_FILENO,TIOCGETC,&tc);
    ioctl(STDIN_FILENO,TIOCGLTC,&ltc);
    ioctl(STDIN_FILENO,TIOCLGET,&localmode);
    ioctl(STDIN_FILENO,TIOCGWINSZ,&wz);
    if (argc < 2) {
    	printCurSettings();
        exit(0);
    }

    for (i = 1; i < argc; ++i) {
      item = lookup(argv[i]);
      if (item >= SUSP_C) c = parsechar(argv[++i]);
      switch (item) {
        case 0: break;
        case INTR_C:
	        tc.t_intrc = c;
        	break;
	case SUSP_C:
	        ltc.t_suspc = c;
        	break;
        case DSUSP_C:
                ltc.t_dsuspc = c;
                break;
        case STOP_C:
            	tc.t_stopc = c;
        	break;
	case START_C:
	        tc.t_startc = c;
        	break;
        case QUIT_C:
	        tc.t_quitc = c;
        	break;
	case ERASE_C:
		sg.sg_erase = c;
		break;
	case EOF_C:
		tc.t_eofc = c;
		break;
        case WERASE_C:
                ltc.t_werasc = c;
                break;
        case FLUSH_C:
                ltc.t_flushc = c;
                break;
        case LNEXT_C:
                ltc.t_lnextc = c;
                break;
        case RPRNT_C:
                ltc.t_rprntc = c;
                break;

        case COOKED_ON:
        	sg.sg_flags &= ~RAW;
        	break;

        case LCTLECH_ON:
        	localmode |= LCTLECH;
	        break;
	case LCTLECH_OFF:
		localmode &= ~LCTLECH;
        	break;
        case LCRTERA_ON:
        	localmode |= LCRTERA;
	        break;
	case LCRTERA_OFF:
		localmode &= ~LCRTERA;
		break;
        default:
                printf("unknown mode %s\n", argv[i]);
                usage();
                break;
      }
    }
    ioctl(STDIN_FILENO,TIOCSETP,&sg);
    ioctl(STDIN_FILENO,TIOCSETC,&tc);
    ioctl(STDIN_FILENO,TIOCSLTC,&ltc);
    ioctl(STDIN_FILENO,TIOCLSET,&localmode);
}
