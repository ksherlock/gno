#ifndef NOTCDA
#pragma cda "GNO Snooper III" Start ShutDown
#endif

#pragma optimize - 1
#pragma lint - 1

#define KERNEL
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <locator.h>
#include <memory.h>
#include <misctool.h>
#include <orca.h>

#include <gno/conf.h>
#include <gno/kvm.h>
#include <gno/proc.h>
#include <gno/signal.h>
#include <gno/wait.h>
//#include <gno/kerntool.h>

/* ORCA Console control codes */
#define CURSOR_ON 0x05
#define CURSOR_OFF 0x06
#define HOME 0x0c
#define CLEAR_EOL 29
#define CLEAR_EOS 11
#define CURSOR_MOTION 30

/* cursor keys */
#define LEFT 0x08
#define RIGHT 0x15
#define UP 0x0b
#define DOWN 0x0a
#define ESC 0x1b


#ifndef udispatch
#define udispatch 0xE10008
#endif

#define __INLINE(arg) inline(arg, udispatch)

pascal int kernVersion(void) __INLINE(0x0403);
pascal int kernStatus(void) __INLINE(0x0603);

pascal int kern_kill(int pid, int sig, int *errno) __INLINE(0x0A03);

pascal kvmt *kern_kvm_open(int *errno) __INLINE(0x1103);
pascal int kern_kvm_close(kvmt *k, int *errno) __INLINE(0x1203);
pascal struct pentry *kern_kvm_getproc(kvmt *kd, int pid, int *errno)
    __INLINE(0x1303);
pascal struct pentry *kern_kvm_nextproc(kvmt *kd, int *err) __INLINE(0x1403);
pascal int kern_kvm_setproc(kvmt *kd, int *err) __INLINE(0x1503);


typedef struct refTabStruct {
    word refnum;
    word type;
    word count;
} refTabStruct;

typedef struct refTabStruct *refTabPtr, **refTabHand;

typedef struct pipeData {
    refTabHand refHand;
    word refHandSize;
} pipeData, *pipeDataPtr;

struct savedInfo {
    int tblockCP;
    int tcount;
    int tbufState;
    int ttruepid;
    int tcurProcInd;
    int tgsosDebug;
};

struct snoop {
    kernelStruct *kp;
    void *pipeT;
    void *refTrack;
    void (*queueSig)(int, int);
    struct savedInfo *si;
    word *ttyStruct;
    word *pgrpInfo;
    pipeDataPtr pipeDat;
};

static char *sig_names[32] = {
    "",
    "SIGHUP",
    "SIGINT",
    "SIGQUIT",
    "SIGILL",
    "SIGTRAP",
    "SIGABRT",
    "SIGEMT",
    "SIGFPE",
    "SIGKILL",
    "SIGBUS",
    "SIGSEGV",
    "SIGSYS",
    "SIGPIPE",
    "SIGALRM",
    "SIGTERM",
    "SIGURG",
    "SIGSTOP",
    "SIGTSTP",
    "SIGCONT",
    "SIGCHLD",
    "SIGTTIN",
    "SIGTTOU",
    "SIGIO",
    "SIGXCPU",
    "SIGXFSZ",
    "SIGVTALRM",
    "SIGPROF",
    "SIGWINCH",
    "SIGINFO",
    "SIGUSR1",
    "SIGUSR2"
};



/* clang-format off */
asm int ReadKey(void) {
    sep #0x20
loop:
    lda >0xe0c000
    bpl loop
    sta >0xe0c010
    rep #0x20
    and #0x7f
    rtl
}
/* clang-format on */

int ReadInt(void) {
    unsigned i = 0;
    unsigned c;
    unsigned rv = 0;

    while (1) {
        c = ReadKey();
        if (c == 0x1b) {
            rv = -1;
            break;
        }
        if (c == 13) {
            if (i == 0)
                rv = -1;
            break;
        } else if ((c == 8) || (c == 0x7f)) {
            if (i) {
                fputs("\x08 \x08", stdout);
                /*
                putchar(8);
                putchar(' ');
                putchar(8);
                */
                i--;
                rv /= 10;
            }
        } else if ((c >= '0') && (c <= '9')) {
            if (i < 5) {
                putchar(c);
                i++;
                rv *= 10;
                rv += c - '0';
                continue;
            }
        }
        SysBeep();
    }
    return rv;
}

void killproc(struct snoop *sn, const char *name, int signal) {
    int pid;

    printf("Select process to %s: ", name);
    pid = ReadInt();

    if (pid == -1)
        return;
    if (kern_kill(pid, 0, &errno)) /* validate the process ID */
    {
        fputs(" Invalid Process ID\n\n", stdout);
        return;
    }
    (*sn->queueSig)(pid, signal);
    fputs(" Signal queued.\n", stdout);
}

char *getstate(int st) {
    char *s;
    switch (st) {
    case procUNUSED:
        s = "defunct";
        break;
    case procRUNNING:
        s = "running";
        break;
    case procNEW:
    case procREADY:
        s = "ready";
        break;
    case procBLOCKED:
        s = "blocked";
        break;
    case procSUSPENDED:
        s = "suspend";
        break;
    case procWAITSIGCH:
    case procWAIT:
        s = "waiting";
        break;
    case procPAUSED:
        s = "paused";
        break;
    case procSLEEP:
        s = "sleeping";
        break;
    default:
        s = "unknown";
        break;
    }
    return s;
}

void print_pr_header(void) {
    fputs(" PID    STATE   TTY pgrp userID    TIME COMMAND\n", stdout);
}

void print_pr(const struct pentry *pr, const kvmt *ps) {
    const char *cmd;
    char *s;
    int state;


    state = pr->processState;
    s = getstate(state);
    cmd = pr->args;
    if (cmd == NULL)
        cmd = "<forked>";
    else
        cmd += 8;
    printf("%4d %8s tty%02d   %02d   %04X %6lus %-20s\n", ps->pid, s,
           pr->ttyID, pr->pgrp, pr->userID, pr->ticks / 60, cmd);

    if (state == procSUSPENDED) {
        state = pr->stoppedState;
        printf("    old state: %s\n", getstate(state));
    }

    if (state == procBLOCKED)
        printf("       on sem: %c/%d\n", (pr->psem & 0x8000) ? 'k' : 'u',
               pr->psem & 0x7FFF);

}


void details(kvmt *ps) {
    int pid;
    struct pentry *pr;
    unsigned page = 0;
    unsigned c;

    enum { MaxPage = 4 };

    fputs("Select process to detail: ", stdout);
    pid = ReadInt();

    if (pid == -1)
        return;
    pr = kern_kvm_getproc(ps, pid, &errno);
    if (pr == NULL) {
        fputs(" Invalid process ID\n\n", stdout);
        return;
    }

    putchar(CURSOR_OFF);

    redraw:
    putchar(HOME);
    if (page == 0) {
        /* Details */
        print_pr_header();
        print_pr(pr, ps);
        putchar('\n');

        printf("A:%04X X:%04X Y:%04X S: %04X D:%04X B:%02X K:%02X PC:%04X\n\n",
               pr->irq_A, pr->irq_X, pr->irq_Y, pr->irq_S, pr->irq_D, pr->irq_B,
               pr->irq_K, pr->irq_PC);

        printf("toolStack: %d,parent: %d\n", pr->t2StackPtr, pr->parentpid);
        printf("SANEwap: %04X\n", pr->SANEwap);

    }
    if (page == 1) {
        /* Files */
        fdtablePtr files;
        files = pr->openFiles;
        fputs("Files\n\n", stdout);
        if (files) {
            unsigned count = files->fdCount;
            unsigned i = 0;
            fdentry *fd;
            while (count && i < files->fdTableSize) {
                fd = &files->fds[i];
                if (fd->refNum){
                    --count;
                    printf("  % 2u", i + 1);
                    switch(fd->refType) {
                    case rtGSOS:
                        printf(" gs/os(%u)", fd->refNum);
                        break;
                    case rtPIPE:
                        printf(" pipe(%u)", fd->refNum);
                        break;
                    case rtTTY:
                        printf(" tty%02u", fd->refNum - 1);
                        break;
                    case rtSOCKET:
                        printf(" socket(%u)", fd->refNum);
                        break;
                    default:
                        printf(" unknown(%u)", fd->refNum);
                        break;
                    }
                    putchar('\n');
                }
                ++i;
            }
        }
    }
    #if 0
    /* ... environment variables actually stored elesehwere */
    if (page == 2) {
        /* environment */
        char **env = pr->env;
        fputs("Environment\n\n", stdout);
        if (env) {
            unsigned i;

            for (i = 0; ; ++i) {
                char *cp = env[i];
                if (!cp) break;

                fputs(cp, stdout);
                putchar('\n');
            }
        }
    }
    #endif
    if (page == 2) {
        char **prefix = pr->prefix;
        unsigned i;

        fputs("Prefix\n\n", stdout);
        if (prefix) {

            for (i = 0; i < 33 ; ++i) {
                GSString255Ptr str = (GSString255Ptr)prefix[i];
                if (!str) continue;
                if (!str->length) continue;
                printf("  % 2u: %.*s\n", i, str->length, str->text);
            }
        }    
    }
    if (page == 3) {
        struct sigrec *siginfo = pr->siginfo;

        fputs("Signals\n\n", stdout);
        if (siginfo) {
            unsigned i;
            void *fn;
            unsigned line;
            unsigned long mask = 0x00000001;

            unsigned long blocked = siginfo->signalmask;
            unsigned long pending = siginfo->sigpending;

            printf("  mask:    %08lx\n", blocked);
            printf("  pending: %08lx\n", pending);


            line = 5;
            for (i = 1; i <32; ++i, mask <<= 1) {
                fn = siginfo->v_signal[i];

                if (i & 0x01) {
                    putchar(30);
                    putchar(32 + 0);
                    putchar(32 + line);
 
                } else {
                    putchar(30);
                    putchar(32 + 40);
                    putchar(32 + line);
                    ++line;
                }
                printf("%2d %-8s ", i, sig_names[i]+3);
                if (blocked & mask) fputs("blocked, ", stdout); 
                if (pending & mask) fputs("pending, ", stdout); 
                if (fn == SIG_DFL) fputs("default", stdout);
                else if (fn == SIG_IGN) fputs("ignored", stdout);
                else printf("%02x/%04x",
                    (unsigned)((unsigned long)fn >> 16), (unsigned)fn);

                //fputc('\n', stdout);
            }

/*

*/
        }
    }
    if (page == 4) {
        chldInfoPtr ptr = pr->waitq;

        fputs("Waiting Children\n\n", stdout);

        fputs("PID Status\n", stdout);
        while (ptr) {
            unsigned w_status = ptr->status.w_status;
            unsigned st = WEXITSTATUS(w_status);

            printf("%4d", ptr->pid);
            if (WIFEXITED(w_status)) {
                printf("exited (%d)", st);
            } else if (WIFSTOPPED(w_status)) {
                printf("stopped (%d - %s)", st, st < NSIG ? sig_names[st] : "");
            } else {
                printf("terminated (%d - %s)", st, st < NSIG ? sig_names[st] : "");                
            }
            fputc('\n', stdout);
            ptr = ptr->next;
        }

    }

    for(;;) {
        c = ReadKey();
        if (c == LEFT) {
            if (page == 0) page = MaxPage;
            else --page;
            goto redraw;
        }
        if (c == RIGHT) {
            if (page >= MaxPage) page = 0;
            else ++page;
            goto redraw;
        }
        putchar(CURSOR_ON);
        return;
    }
}

void dumppgrp(struct snoop *sn) {
    int i;
    fputs("\npgrp: ", stdout);
    for (i = 0; i < 15; i++)
        printf("[%d] ", sn->pgrpInfo[i]);
    fputs("\nttyStruct: ", stdout);
    for (i = 0; i < 32; i++)
        printf("[%d] ", sn->ttyStruct[i]);
    putchar('\n');
    ReadKey();
}

void dumpfdtab(struct snoop *sm) {
    refTabPtr rtp = *(sm->pipeDat->refHand);
    int i, x, y;

    for (i = 0; i < (sm->pipeDat->refHandSize / sizeof(refTabStruct)); i++) {
        if (rtp[i].refnum == 0)
            continue;
        printf("[%d,", y = rtp[i].refnum);
        x = rtp[i].type;
        switch (x) {
        case rtGSOS:
            fputs("GSOS,", stdout);
            break;
        case rtPIPE:
            printf("PIPE(%d),", y);
            break;
        case rtTTY:
            printf("tty%02d,", y - 1);
            break;
        case rtSOCKET:
            fputs("socket,", stdout);
            break;
        default:
            fputs("UNK,", stdout);
        }
        printf("%d] ", rtp[i].count);
    }
    putchar('\n');
    ReadKey();
}

void Start(void) {
    kvmt *ps = 0;
    struct pentry *pr;
    unsigned c;
    int i, t;
    long msg;
    handle h = 0;
    struct snoop *sn;

    static struct {
        word blockLen;
        char name[21];
    } snoopermsg = {21 + 2, "\p~PROCYON~GNO~SNOOPER"};

    kernStatus();
    if (_toolErr) {
        /* don't execute if GNO is not started up */
        fputs("GNO Not Active\n\r", stdout);
        goto exit;
    }

    h = NewHandle(1l, userid() & 0xF0FF, 0x0000, 0l);
    if (!h) {
        fputs("Couldn't allocate memory for Snooper Info\n\r", stdout);
        goto exit;
    }

    msg = MessageByName(0, (Pointer)&snoopermsg);
    MessageCenter(2, (word)msg, h);
    HLock(h);
    sn = (struct snoop *)(((byte *)*h) + 0x1D);

    t = sn->si->tblockCP;
    printf("Blocked: %d\n", (t == -1) ? t : (t / 128));

    ps = kern_kvm_open(&errno);
    if (!ps) {
        fputs("error in kvm_open\n", stdout);
        goto exit;
    }

redraw:
    fputs("GNO Snooper 3.0\n\n", stdout);
    #if 0
    printf("handle: %06lX ptr: %06lX\n", (unsigned long)h, (unsigned long)sn);
    #endif

    print_pr_header();

    kern_kvm_setproc(ps, &errno);
    i = 0;
    while ((pr = kern_kvm_nextproc(ps, &errno)) != NULL) {
        print_pr(pr, ps);
        i++;
        if (i > NPROC) {
            fputs("process table corrupted\n", stdout);
            goto exit;
        }
    }
    fputs(
        "\n\nD)etails T)erminate S)uspend K)ill P)rocess Groups F)iles Q)uit: ",
        stdout);
tryagain:
    c = toupper(ReadKey());
    putchar('\r');

    if (c == 'D') {
        details(ps);
        goto redraw;
    }
    if (c == 'K') {
        killproc(sn, "kill", SIGKILL);
        goto redraw;
    }
    if (c == 'T') {
        killproc(sn, "terminate", SIGTERM);
        goto redraw;
    }
    if (c == 'S') {
        killproc(sn, "suspend", SIGSTOP);
        goto redraw;
    }
    if (c == 'F') {
        dumpfdtab(sn);
        goto redraw;
    }
    if (c == 'P') {
        dumppgrp(sn);
        goto redraw;
    }
    if (c != 'Q') {
        SysBeep();
        goto tryagain;
    }
    kern_kvm_close(ps, &errno);
    DisposeHandle(h);
    return;

exit:
    if (h)
        DisposeHandle(h);
    if (ps)
        kern_kvm_close(ps, &errno);
    ReadKey();
    return;
}

void ShutDown(void) {}

#ifdef NOTCDA
int main(int argc, char *argv[]) { Start(); }
#endif
