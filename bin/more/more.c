/*
    more.cc

    Revision history:

    v2.1  - termcap, $LINES, $COLUMNS, $MORE, -s, -c
    v2.0  - now sets tty to cbreak mode, since TTY's cooked mode has
            changed.
    v1.31 - uses fstat to check whether output is a tty, instead of
            _Direction
    v1.3  - now prints name of file in block if multiple files specified
*/


#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/signal.h>
#include <sys/stat.h>
#include <termcap.h>
#include <unistd.h>
#include <paths.h>

#include <sgtty.h>
#include <sys/ioctl.compat.h>

#ifdef __ORCAC__
#include <gno/gno.h>
#include <texttool.h>
#endif

#pragma lint -1

unsigned MAX_LINE;
unsigned MAX_COL;

char *tcap_so, *tcap_se, *tcap_cl;
char termcap[1030], capability[100];

#if 0
int tcap_putc(int c) {
    putchar(c);
    return 0;
}
#endif

#define tcap_putc buf_putc

const char *basename(const char *cp) {
    const char *rv = cp;
    unsigned i;
    for (i = 0;; ++i) {
        char c = cp[i];
        if (c == 0)
            return rv;
        if (c == ':' || c == '/')
            rv = cp + 1 + i;
    }
}

char getcharacter(int fd) {
    char c;

#ifdef __ORCAC__
    if (fd == -1)
        c = ReadChar(0);
    else
        read(fd, &c, 1);
#else
    if (fd == -1)
        c = 0;
    else
        read(fd, &c, 1);
#endif
    return c;
}

struct sgttyb sg;
int tty;
int oldsg_flags;

#pragma databank 1
void inthndl(int sig) { exit(sig); }
#pragma databank 0

/* called by atexit */
void reset_tty(void) {

    sg.sg_flags = oldsg_flags;
    ioctl(tty, TIOCSETP, &sg);
    close(tty);
}

void quit(int code) {
    reset_tty();
    exit(code);
}

char i_buf[1024];
unsigned b_ind = 0;
int b_size = 0;
int b_ref;
unsigned b_eof;
unsigned long b_mark;

int buf_open(const char *name) {
    int fd;
    fd = open(name, O_RDONLY);
    b_ind = 0;
    b_size = 0;
    b_mark = 0l;
    b_eof = 0;
    return (b_ref = fd);
}

void buf_fd_open(int fd) {
    b_ind = 0;
    b_size = 0;
    b_mark = 0l;
    b_ref = fd;
    b_eof = 0;
}

int buf_peek(void) {

    if (b_ind >= b_size) {
        if (b_eof)
            return EOF;
        b_size = read(b_ref, i_buf, 1024);
        b_ind = 0;
        if (b_size <= 0) {
            b_eof = 1;
            b_size = 0;
            return EOF;
        }
    }
    return i_buf[b_ind];
}

int buf_getc(void) {
    char c;

    if (b_ind >= b_size) {
        if (b_eof)
            return EOF;
        b_size = read(b_ref, i_buf, 1024);
        b_ind = 0;
        if (b_size <= 0) {
            b_eof = 1;
            b_size = 0;
            return EOF;
        }
    }

    c = i_buf[b_ind++];
    b_mark = b_mark + 1l;
    return c;
}

#define OBUFSIZE 1024
char o_buf[OBUFSIZE];
unsigned b_oind = 0;
int b_oref = STDOUT_FILENO;

void buf_flush(void) {
    #if !defined(__ORCAC__)
    int i;
    for (i = 0; i <  b_oind; ++i)
        if (o_buf[i] == '\r') o_buf[i] = '\n';
    #endif
    write(b_oref, o_buf, b_oind);
    b_oind = 0;
}

int buf_putc(int c) {
    if (b_oind == OBUFSIZE)
        buf_flush();
    o_buf[b_oind++] = c;
    return 0;
}
#define buf_putx(S) buf_puts2(S, sizeof(S) - 1)

void buf_puts2(const char *s, int l) {

    if (!l)
        return;

    if (l + b_oind >= OBUFSIZE) {
        if (b_oind)
            buf_flush();
        write(b_oref, s, l);
        return;
    }
    memcpy(o_buf + b_oind, s, l);
    b_oind += l;
}
void buf_puts(const char *s) {

    if (!s)
        return;

    buf_puts2(s, strlen(s));
}

void buf_stderr(void) {
    if (b_oref != STDERR_FILENO) {
        if (b_oind)
            buf_flush();
        b_oref = STDERR_FILENO;
    }
}

void buf_stdout(void) {
    if (b_oref != STDOUT_FILENO) {
        if (b_oind)
            buf_flush();
        b_oref = STDOUT_FILENO;
    }
}

int s_flag = 0;
int c_flag = 0;
int e_flag = 0;

void erase_line(unsigned chars) {
    while (chars-- > 0)
        buf_putx("\b \b");

/*
    tputs(tcap_cr,1,tcap_putc);
    tputs(tcap_ce,1,tcap_putc);
*/
}

unsigned errors = 0;
unsigned didpipe = 0;
/*
 * returns: 0 -> eof, 1 -> quit, 2 -> abort.
 *
 */
int pager(const char *path, unsigned printName, unsigned standardOut) {

    static struct stat sb;
    const char *truncated;
    int file;
    unsigned ispipe;
    int c, quit;

    unsigned line = 1;
    unsigned col = 1;
    unsigned prev_col = 0;

    if (c_flag) {
        tputs(tcap_cl, 1, tcap_putc);
        buf_flush();
    }
    if (path && path[0] == '-' && path[1] == 0) path = NULL;

    if (path) {
        ispipe = 0;
        truncated = basename(path);
        stat(path, &sb);
        if (sb.st_mode & S_IFDIR) {
            /* fprintf(stderr, "more: %s is a directory\n", path); */
            buf_stderr();
            buf_putx("more: ");
            buf_puts(path);
            buf_putx(" is a directory\r");
            buf_stdout();
            errors++;
            return 0;
        }
        file = buf_open(path);
        if (file < 0) {
            /* perror(path); */
            buf_stderr();
            buf_puts(path);
            buf_putx(": ");
            buf_puts(strerror(errno));
            buf_putc('\r');
            buf_stdout();
            errors++;
            return 0;
        }

    } else {
        /* pipe */

        if (isatty(STDIN_FILENO)) {
            buf_stderr();
            buf_putx("Can't take input from a terminal\r");
            buf_stdout();
            errors++;
            return 0;
        }

        if (didpipe) {
            buf_stderr();
            buf_putx("Can view standard input only once\r");
            buf_stdout();
            errors++;
            return 0;
        }
        didpipe = 1;

        ispipe = 1;
        truncated = "stdin";
        file = STDIN_FILENO;
        buf_fd_open(file);
    }

    if (printName) {
        buf_putx("::::::::::::::::\r");
        buf_puts(truncated);
        buf_putx("\r::::::::::::::::\r");
        line = 3;
    }

    prev_col = 0;
    quit = 0;

    while (!quit) {

        c = buf_getc();
        if (c == EOF)
            break;

        if (c == '\f') {
            buf_putx("^L\r");
            line = MAX_LINE;
            col = prev_col = 1;
        } else if (c == '\n') {
            if (s_flag && col == 1 && prev_col == 1)
                continue;
            buf_putc('\r');
            line++;
            prev_col = col;
            col = 1;
        } else if (c == '\r') {
            if (buf_peek() == '\n') {
                /*  IBM silly CR & LF EOL */
                buf_getc();
            }

            if (s_flag && col == 1 && prev_col == 1)
                continue;
            buf_putc('\r');
            line++;
            prev_col = col;
            col = 1;
        } else {
            buf_putc(c);
            /* backspace if col == 1 ? */
            if (c == '\b')
                col--;
            else if (c > 32)
                col++;
            if (col > MAX_COL) {
                /* should check auto wrap, add nl? */
                col = 1;
                line++;
            }
        }
        if ((line == MAX_LINE) && standardOut) {
            unsigned l;
            unsigned start, end;

            tputs(tcap_so, 1, tcap_putc);

            start = b_oind;

            if (!ispipe) {
                unsigned percent;

                percent = (b_mark * 100) / sb.st_size;

                /* printf(" - %s (%2d%%) - ",truncated,(int)percent); */

                buf_putx(" - ");
                buf_puts(truncated);
                buf_putx(" (");

                if (percent >= 100) {
                    buf_putx("100");
                }
                else if (percent >= 10) {
                    buf_putc(" 123456789"[percent / 10]);
                    buf_putc("0123456789"[percent % 10]);
                } else {
                    buf_putc("0123456789"[percent]);
                }
                buf_putx("%) - ");


            } else {
                buf_putx(" - (more) - ");
            }

            end = b_oind;
            if (start > end)
                end += OBUFSIZE;
            l = end - start;

            tputs(tcap_se, 1, tcap_putc);
            buf_flush();
            c = getcharacter(tty);
            c &= 0x7f;

            if (c == 'q' || c == 'Q')
                quit = 1;
            if (c == 27)
                quit = 2;
            if (c == 10 || c == 13)
                line--;
            else
                line = 1;
            col = 1;

            if (line == 1 && c_flag) {
                tputs(tcap_cl, 1, tcap_putc);
            } else {
                erase_line(l);
            }
            buf_flush();
        }
    }

    if (col > 1)
        buf_putc('\r');
    buf_flush();

    if (!ispipe)
        close(file);

    return quit;
}

void init_term(void) {

    char *cp, *pcap;

    if ((cp = getenv("TERM")) && (tgetent(termcap, cp) == 1)) {
        pcap = capability;
        tcap_so = tgetstr("so", &pcap);
        tcap_se = tgetstr("se", &pcap);
        tcap_cl = tgetstr("cl", &pcap);
    }

    if (!tcap_cl || !*tcap_cl)
        tcap_cl = "\f";

    MAX_LINE = MAX_COL = 0;
    if ((cp = getenv("LINES"))) {
        MAX_LINE = atoi(cp);
    }
    if ((cp = getenv("COLUMNS"))) {
        MAX_COL = atoi(cp);
    }
    if (!MAX_LINE) MAX_LINE = tgetnum("li");
    if (!MAX_COL) MAX_COL = tgetnum("co");

    if (!MAX_LINE) MAX_LINE = 24;
    if (!MAX_COL) MAX_COL = 80;


    tty = open(_PATH_TTY, O_RDONLY);

    /* turn off echo mode */
    ioctl(tty, TIOCGETP, &sg);

    oldsg_flags = sg.sg_flags;
    sg.sg_flags &= ~ECHO;
    sg.sg_flags |= CBREAK;

    atexit(reset_tty);
    signal(SIGINT, inthndl);

    ioctl(tty, TIOCSETP, &sg);
}

void argscan(const char *cp) {
    unsigned i;
    /* from $MORE or argv. */
    if(!cp) return;

    for (i = 0;; ++i) {
        char c = cp[i];

        switch (c) {
        case 0:
            return;
            break;
        case 's':
            s_flag = 1;
            break;
        case 'c':
            c_flag = 1;
            break;
        case 'e':
            e_flag = 1;
            break;
        }
    }


}

#if defined(__STACK_CHECK__)
static void
stackResults(void) {
    fprintf(stderr, "stack usage:\t ===> %d bytes <===\n",
        _endStackCheck());
}
#endif


int main(int argc, char **argv) {
    int i;
    int standardOut;

#ifdef __STACK_CHECK__
    _beginStackCheck();
    atexit(stackResults);
#endif

    init_term();
    errors = 0;
    didpipe = 0;


    /* buf_putc(6); tcap_vi -> invisible cursor */

    standardOut = isatty(STDOUT_FILENO);

    argscan(getenv("MORE"));

    for (i = 1; i < argc; ++i) {
        char *cp = argv[i];
        if (cp[0] != '-' || cp[1] == 0) break;
        argscan(cp);
    }
    argc -= i;
    argv += i;


    buf_stdout();

    if (argc == 0) {
        pager(NULL, 0, standardOut);
    } else {
        for (i = 0; i < argc; ++i) {
            int quit;
            char *cp = argv[i];

            quit = pager(cp, argc > 1, standardOut);

            if (quit == 2)
                break;

            if (standardOut && (i + 1) < argc) {
                char c;
                tputs(tcap_so, 1, tcap_putc);
                buf_putx("hit a key for next file");
                tputs(tcap_se, 1, tcap_putc);
                buf_flush();
                c = getcharacter(tty);
                erase_line(23);
                buf_flush();
                c &= 0x7f;
                if (c == 27 || c == 'q' || c == 'Q')
                    break;
            }
        }
    }
    buf_flush();
    /* putchar(5);  tcap_ve -> end invisible cursor */
    exit(errors > 0);
}

