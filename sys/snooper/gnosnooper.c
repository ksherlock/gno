#ifndef NOTCDA
#pragma cda "GNO Snooper" Start ShutDown
#endif

/*#pragma optimize -1*/
#define KERNEL
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <texttool.h>
#include <locator.h>
#include <orca.h>
#include <gno/gno.h>
#include <gno/conf.h>
#include <gno/proc.h>
#include <gno/kvm.h>

struct snoop1 {
    word blockLen;
    char name[21];
} snoopermsg;

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
char s[7];
unsigned i = 0;
char c;

    while (1) {
        c = ReadChar(0);
        if (c == 13) {
            WriteChar(13);
            WriteChar(10);
            if (i == 0) return -1;
            s[i] = 0;
            return atoi(s);
        } else if ((c == 8) || (c == 0x7f)) {
            if (i) {
                WriteChar(8);
                WriteChar(' ');
                WriteChar(8);
                i--;
            }
        }
        else if ((c >= '0') && (c <= '9')) {
            if (i < 5) {
                WriteChar(c);
                s[i] = c;
	        i++;
	    }
	}
    }
}

void killproc(struct snoop2 *sn)
{
int pid;

    WriteCString("\r\nSelect process to terminate: ");
    pid = getapid();
    if (pid == -1) return;
    if (kill(pid,0)) /* validate the process ID */
    {
    	printf("Invalid Process ID\n");
	return;
    }
    (*sn->queueSig)(pid,9);
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
      default:              s = "unknown"; break;
    }
    return s;
}

void details(kvmt *ps)
{
int pid;
struct pentry *pr;
char *s,*cmd;

    WriteCString("\r\nSelect process to detail: ");
    scanf("%d",&pid);
    pr = kvmgetproc(ps,pid);
    if (pr == NULL) { printf("Invalid process ID\n"); return; }

    printf(" PID  STATE    TTY   userID   TIME COMMAND\n");

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

void dumppgrp(struct snoop2 *sn)
{
int i;
    printf("\npgrp: ");
    for (i = 0; i < 15; i++) printf("[%d] ",sn->pgrpInfo[i]);
    printf("\n");
    printf("ttyStruct: ");
    for (i = 0; i < 32; i++) printf("[%d] ",sn->ttyStruct[i]);
    printf("\nPress return:");
    ReadChar(0);
    printf("\n");
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
          case rtGSOS: printf("GSOS,"); break;
          case rtPIPE: printf("PIPE(%d),",y); break;
          case rtTTY: printf("tty%02d,",y-1); break;
          default: printf("UNK,");
        }
        printf("%d] ",rtp[i].count);
    }
    printf("\n");
    ReadChar(0);
    printf("\n");
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
char *nm = "~PROCYON~GNO~SNOOPER";

    kernStatus();
    if (toolerror()) {
        /* don't execute if GNO is not started up */
    	WriteCString("GNO Not Active\n\r");
    	goto lp;
    }
    memcpy(snoopermsg.name+1,nm,20l);
    snoopermsg.name[0] = 20;
	
    h = NewHandle(1l,userid() & 0xF0FF, 0x0000, 0l);
    if (h == (handle)0l) {
    	WriteCString("Couldn't allocate memory for Snooper Info\n\r");
	goto lp;
    }
    snoopermsg.blockLen = sizeof(snoopermsg);
    msg = MessageByName(0,&snoopermsg);
    MessageCenter(2,(word)msg,h);
    HLock(h);
    sn = (struct snoop2 *) (((byte *)*h)+0x1D);

    t = sn->si->tblockCP;
    printf("Blocked: %d\n", (t == -1) ? t : (t /128));
	
    ps = kvm_open();
redraw:
    WriteCString("GNO Snooper 2.0\r\n\r\n");
    printf("handle: %06lX ptr: %06lX\n",h,sn);
    if (ps == NULL) {
    	printf("error in kvm_open\n"); goto lp;
    }

    printf(" PID  STATE    TTY   pgrp userID   TIME COMMAND\n");

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
            printf("process table corrupted\n");
            exit(1);
        }
    }
    WriteCString("\n\rD)etails, K)ill, P)rocess Group dump, F)ile dump, Q)uit: ");
tryagain:
    c = toupper(ReadChar(0) & 0x7F);
    if (c == 'D') {
    	details(ps);
	goto redraw;
    }
    if (c == 'K') {
    	killproc(sn);
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
    if (c != 'Q') goto tryagain;
    kvm_close(ps);
    return;
lp: ReadChar(0);
    return;
}

void ShutDown(void)
{
}

/* asm {
lp:  lda 0xE0C000
     and #0x80
     beq lp
     lda 0xE0C010
   } */

#ifdef NOTCDA
int main(int argc, char *argv[])
{
    Start();
}
#endif
