#ifndef NOTCDA
#pragma cda "GNO Snooper" Start ShutDown
#endif

#pragma lint -1
#pragma optimize 79

/*#pragma optimize -1*/
#define KERNEL
//#include <stdio.h>
#include "31/Libraries/ORCACDefs/stdio.h"
#include "31/Libraries/ORCACDefs/stdlib.h"
#include "31/Libraries/ORCACDefs/string.h"
#include "31/Libraries/ORCACDefs/ctype.h"

#include <memory.h>
#include <texttool.h>
#include <locator.h>
#include <orca.h>
#include <errno.h>

#include <signal.h>

#include <gno/conf.h>
#include <gno/proc.h>
#include <gno/kvm.h>
#include <gno/kerntool.h>

extern int errno;                       /* global error number */


#define kill(a,b) Kkill(a,b,&errno)
#define kvm_open() Kkvm_open(&errno)
#define kvm_close(a) Kkvm_close(a,&errno)
#define kvmgetproc(a,b) Kkvm_getproc(a,b,&errno)
#define kvmsetproc(a) Kkvm_setproc(a)
#define kvmnextproc(a) Kkvm_nextproc(a,&errno)


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

struct snoop2 {
    kernelStruct *kp;
    void *pipeT;
    void *refTrack;
    void (*queueSig)(int,int);
    struct savedInfo *si;
    word *ttyStruct;
    word *pgrpInfo;
    pipeDataPtr pipeDat;
};

int getapid(void)
{
/*char s[7];*/
unsigned i = 0;
unsigned c;
unsigned n = 0;

    while (1) {
        asm {
            sep #0x20
            poll:
            lda >0x00c000
            bpl poll
            sta >0x00c010
            rep #0x20
            and #0x7f
            sta c
        }

        if (c == 13) {
            putchar('\n');
            if (i == 0) return -1;
            return n;
        } else if ((c == 8) || (c == 0x7f)) {
            if (i) {
                putchar(8);
                putchar(' ');
                putchar(8);
                i--;
                n /= 10;
            }
        }
        else if ((c >= '0') && (c <= '9')) {
            if (i < 5) {
                putchar(c);
                /*s[i] = c;*/
                i++;
                n *= 10; n += c - '0';
            }
        }
    }
}


void killproc(struct snoop2 *sn, const char *reason, int sig)
{
int pid;

    printf("\nSelect process to %s: ", reason);
    pid = getapid();
    if (pid < 0) return;

    if (kill(pid,0)) /* validate the process ID */
    {
        printf("Invalid Process ID\n");
        return;
    }
    (*sn->queueSig)(pid,sig);
}

char *getstate(int st)
{
char *s;
    switch (st) {
      case procUNUSED:      s = "defunct"; break;
      case procRUNNING:     s = "running"; break;
      case procNEW:
      case procREADY:       s = "ready"; break;
      case procBLOCKED:     s = "blocked"; break;
      case procSUSPENDED:   s = "suspend"; break;
      case procWAITSIGCH:
      case procWAIT:        s = "waiting"; break;
      case procPAUSED:      s = "paused"; break;
      case procSLEEP:       s = "sleeping"; break;
      default:              s = "unknown"; break;
    }
    return s;
}

void details(kvmt *ps)
{
int pid;
struct pentry *pr;
char *s,*cmd;

    fputs("\nSelect process to detail: ", stdout);
    pid = getapid();
    if (pid < 0) return;

    pr = kvmgetproc(ps,pid);
    if (pr == NULL) { fputs("Invalid process ID\n", stdout); return; }

    fputs(" PID  STATE    TTY   userID   TIME COMMAND\n", stdout);

    s = getstate(pr->processState);
    cmd = pr->args;
    if (cmd == NULL) cmd = "<forked>";
    else cmd += 8;
    printf("%4d %8s tty%02d (%04X) %6lus %-20s\n", ps->pid, s, pr->ttyID,
             pr->userID,pr->ticks / 60,cmd);
    if (pr->processState == procWAIT)
        printf("     on sem %c/%d\n",(pr->psem & 0x8000) ? 'k' : 'u',
                pr->psem & 0x7FFF);
    if (pr->processState == procSUSPENDED) printf("    old state: %s\n",
            getstate(pr->stoppedState));
    printf("A:%04X X:%04X Y:%04X S: %04X D:%04X B:%02X K:%02X PC:%04X\n",
       pr->irq_A,pr->irq_X,pr->irq_Y,pr->irq_S,pr->irq_D,pr->irq_B,pr->irq_K,
       pr->irq_PC);
    printf("toolStack: %d,parent: %d\n",pr->t2StackPtr,pr->parentpid);
    printf("SANEwap: %04X\n",pr->SANEwap);
    ReadChar(0);
}

void xdetails(kvmt *ps)
{
int pid;
struct pentry *pr;
char *s,*cmd;

    fputs("\nSelect process to detail: ", stdout);
    pid = getapid();
    if (pid < 0) return;

    pr = kvmgetproc(ps,pid);
    if (pr == NULL) { fputs("Invalid process ID\n", stdout); return; }

    printf("parent:     %u\n", pr->parentpid);
    printf("psem:       %u\n", pr->psem);
    printf("prefix:     %p\n", pr->prefix);
    printf("args:       %p\n", pr->args);
    printf("env:        %p\n", pr->env);
    printf("siginfo:    %p\n", pr->siginfo);
    printf("last tool:  %x\n", pr->lastTool);
    printf("flags:      %x\n", pr->flags);
    printf("pgrp:       %x\n", pr->pgrp);
    printf("exit code:  %u\n", pr->exitCode);
    printf("LInfo:      %p\n", pr->LInfo);
    printf("queue link: %p\n", pr->queueLink);
    printf("wait queue: %p\n", pr->waitq);
    printf("wait done:  %x\n", pr->waitdone);
    printf("fl pid:     %x\n", pr->flpid);
    printf("msg:        %x\n", pr->msg);
    

    ReadChar(0);

}

void dumppgrp(struct snoop2 *sn)
{
int i;
    fputs("\npgrp: ", stdout);
    for (i = 0; i < 15; i++) printf("[%d] ",sn->pgrpInfo[i]);
    putchar('\n');
    fputs("ttyStruct: ", stdout);
    for (i = 0; i < 32; i++) printf("[%d] ",sn->ttyStruct[i]);
    fputs("\nPress return:", stdout);
    ReadChar(0);
    putchar('\n');
}

void dumpfdtab(struct snoop2 *sm)
{
refTabPtr rtp = *(sm->pipeDat->refHand);
int i,x,y;

    for (i = 0; i < (sm->pipeDat->refHandSize / sizeof(refTabStruct)); i++) {
        if (rtp[i].refnum == 0) continue;
        printf("[%d,",y = rtp[i].refnum);
        x = rtp[i].type;
        switch (x) {
          case rtGSOS: fputs("GSOS,", stdout); break;
          case rtPIPE: printf("PIPE(%d),",y); break;
          case rtTTY: printf("tty%02d,",y-1); break;
          case rtSOCKET: fputs("socket,", stdout); break;
          default: fputs("UNK,", stdout);
        }
        printf("%d] ",rtp[i].count);
    }
    putchar('\n');
    ReadChar(0);
    putchar('\n');
}

void Start(void)
{
kvmt *ps;
struct pentry *pr;
char *s,c;
int i = 0,t;
char *cmd;
long msg;
handle h;
struct snoop2 *sn;


static struct {
    word blockLen;
    char name[22];
} snoopermsg = { 2 + 21, "\p~PROCYON~GNO~SNOOPER" };


    h = NULL;
    ps = NULL;

    kernStatus();
    if (toolerror()) {
        /* don't execute if GNO is not started up */
        fputs("GNO Not Active\n", stdout);
        goto exit;
    }

        
    h = NewHandle(1l,userid() & 0xF0FF, 0x0000, 0l);
    if (h == (handle)0l) {
        fputs("Couldn't allocate memory for Snooper Info\n", stdout);
        goto exit;
    }

    msg = MessageByName(0,(Pointer)&snoopermsg);
    MessageCenter(2,(word)msg,h);
    HLock(h);
    sn = (struct snoop2 *) (((byte *)*h)+0x1D);

    t = sn->si->tblockCP;
    printf("Blocked: %d\n", (t == -1) ? t : (t /128));
        
    ps = kvm_open();
    if (ps == NULL) {
        fputs("error in kvm_open\n", stdout);
        goto exit;
    }

    for(;;) {

            fputs("GNO Snooper 2.0\n\n", stdout);
            printf("handle: %06lX ptr: %06lX\n",h,sn);


            fputs(" PID  STATE    TTY   pgrp userID   TIME COMMAND\n", stdout);

            kvmsetproc(ps);
            while ((pr = kvmnextproc(ps)) != NULL) {
                s = getstate(pr->processState);
                cmd = pr->args;
                if (cmd == NULL) cmd = "<forked>";
                else cmd += 8;
                printf("%4d %8s tty%02d  %02d (%04X) %6lus %-20s\n",
                    ps->pid,
                    s,
                    pr->ttyID,
                    pr->pgrp,
                    pr->userID,
                    pr->ticks / 60,
                    cmd);
                if (pr->processState == procWAIT)
                    printf("     on sem %c/%d\n",(pr->psem & 0x8000) ? 'k' : 'u',
                        pr->psem & 0x7FFF);
                i++;
                if (i > NPROC) {
                    fputs("process table corrupted\n", stdout);
                    goto exit;
                }
            }
            fputs("\nD)etails, T)erminate, S)uspend, K)ill, P)rocess Groups, F)iles, Q)uit: ", stdout);

        tryagain:

            c = toupper(ReadChar(0) & 0x7F);
            switch (c) {
                case 'D': details(ps); break;
                case 'X': xdetails(ps); break;
                case 'K': killproc(sn, "kill", SIGKILL); break;
                case 'S': killproc(sn, "suspend", SIGSTOP); break;
                case 'T': killproc(sn, "terminate", SIGTERM); break;
                case 'F': dumpfdtab(sn); break;
                case 'P': dumppgrp(sn); break;
                case 'Q':
                    kvm_close(ps);
                    DisposeHandle(h);
                    return;
                default: goto tryagain;
            }
        }

exit:
    if (ps) kvm_close(ps);
    if (h) DisposeHandle(h);
    ReadChar(0);
    return;
}

void ShutDown(void)
{
}

#ifdef NOTCDA
int main(int argc, char *argv[])
{
    Start();
}
#endif
