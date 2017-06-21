/*
 * ftypes.c
 *
 * data/routines to change an official Apple 3-letter filetype abbrevation
 * into a full filetype/auxtype pair (or back, I suppose)
 *
 * also data/routines to change a language type (as specified in chtyp.1)
 * into a filetype/auxtype pair.
 *
 * $Id: ftypes.c,v 1.1 1997/10/03 05:06:50 gdr Exp $
 */

#include <string.h>

static struct type_list {
	char *name;
	int file_type;
	long aux_type;
} types[] = {
	{ "non", 0x00, 0x0000 },		/* common abbrev for $00 */
	{ "unk", 0x00, 0x0000 },		/* official abbrev for $00 */
	{ "bad", 0x01, 0x0000 },
	{ "pcd", 0x02, 0x0000 },
	{ "ptx", 0x03, 0x0000 },
	{ "txt", 0x04, 0x0000 },
	{ "pda", 0x05, 0x0000 },
	{ "bin", 0x06, 0x0000 },
	{ "fnt", 0x07, 0x0000 },
	{ "fot", 0x08, 0x0000 },
	{ "ba3", 0x09, 0x0000 },
	{ "da3", 0x0a, 0x0000 },
	{ "wpf", 0x0b, 0x0000 },
	{ "sos", 0x0c, 0x0000 },
	{ "dir", 0x0f, 0x0000 },
	{ "rpd", 0x10, 0x0000 },
	{ "rpi", 0x11, 0x0000 },
	{ "afd", 0x12, 0x0000 },
	{ "afm", 0x13, 0x0000 },
	{ "afr", 0x14, 0x0000 },
	{ "scl", 0x15, 0x0000 },
	{ "pfs", 0x16, 0x0000 },
	{ "adb", 0x19, 0x0000 },
	{ "awp", 0x1a, 0x0000 },
	{ "asp", 0x1b, 0x0000 },
	{ "tdm", 0x20, 0x0000 },
	{ "8sc", 0x2a, 0x0000 },
	{ "8ob", 0x2b, 0x0000 },
	{ "8ic", 0x2c, 0x0000 },
	{ "8ld", 0x2d, 0x0000 },
	{ "p8c", 0x2e, 0x0000 },
	{ "ptp", 0x2e, 0x8001 },		/* Point-to-point drivers */
	{ "ftd", 0x42, 0x0000 },
	{ "gwp", 0x50, 0x0000 },
	{ "gss", 0x51, 0x0000 },
	{ "gdb", 0x52, 0x0000 },
	{ "drw", 0x53, 0x0000 },
	{ "gdp", 0x54, 0x0000 },
	{ "hmd", 0x55, 0x0000 },
	{ "edu", 0x56, 0x0000 },
	{ "stn", 0x57, 0x0000 },
	{ "hlp", 0x58, 0x0000 },
	{ "com", 0x59, 0x0000 },
	{ "cfg", 0x5a, 0x0000 },
	{ "anm", 0x5b, 0x0000 },
	{ "mum", 0x5c, 0x0000 },
	{ "ent", 0x5d, 0x0000 },
	{ "dvu", 0x5e, 0x0000 },
	{ "bio", 0x6b, 0x0000 },
	{ "tdr", 0x6d, 0x0000 },
	{ "pre", 0x6e, 0x0000 },
	{ "hdv", 0x6f, 0x0000 },
	{ "wp",  0xa0, 0x0000 },
	{ "gsb", 0xab, 0x0000 },
	{ "tdf", 0xac, 0x0000 },
	{ "bdf", 0xad, 0x0000 },
	{ "src", 0xb0, 0x0000 },
	{ "obj", 0xb1, 0x0000 },
	{ "lib", 0xb2, 0x0000 },
	{ "s16", 0xb3, 0x0000 },
	{ "rtl", 0xb4, 0x0000 },
	{ "exe", 0xb5, 0x0000 },
	{ "pif", 0xb6, 0x0000 },
	{ "tif", 0xb7, 0x0000 },
	{ "nda", 0xb8, 0x0000 },
	{ "cda", 0xb9, 0x0000 },
	{ "tol", 0xba, 0x0000 },
	{ "dvr", 0xbb, 0x0000 },
	{ "ldf", 0xbc, 0x0000 },
	{ "fst", 0xbd, 0x0000 },
	{ "doc", 0xbf, 0x0000 },
	{ "pnt", 0xc0, 0x0000 },
	{ "pic", 0xc1, 0x0000 },
	{ "ani", 0xc2, 0x0000 },
	{ "pal", 0xc3, 0x0000 },
	{ "oog", 0xc5, 0x0000 },
	{ "scr", 0xc6, 0x0000 },
	{ "cdv", 0xc7, 0x0000 },
	{ "fon", 0xc8, 0x0000 },
	{ "fnd", 0xc9, 0x0000 },
	{ "icn", 0xca, 0x0000 },
	{ "mus", 0xd5, 0x0000 },
	{ "ins", 0xd6, 0x0000 },
	{ "mdi", 0xd7, 0x0000 },
	{ "snd", 0xd8, 0x0000 },
	{ "dbm", 0xdb, 0x0000 },
	{ "lbr", 0xe0, 0x0000 },
	{ "atk", 0xe2, 0x0000 },
	{ "r16", 0xee, 0x0000 },
	{ "pas", 0xef, 0x0000 },
	{ "cmd", 0xf0, 0x0000 },
	{ "os" , 0xf9, 0x0000 },
	{ "int", 0xfa, 0x0000 },
	{ "ivr", 0xfb, 0x0000 },
	{ "bas", 0xfc, 0x0801 },
	{ "var", 0xfd, 0x0000 },
	{ "rel", 0xfe, 0x0000 },
	{ "sys", 0xff, 0x0000 }
};

#define NUM_TYPES 98

static struct lang_list {
	char *name;
	int file_type;
	long aux_type;
} langs[] = {
	{ "apwtxt",    0xb0, 0x0001},
	{ "asm",       0xb0, 0x0003},
	{ "ibasic",    0xb0, 0x0004},
	{ "pascal",    0xb0, 0x0005},
	{ "exec",      0xb0, 0x0006},
	{ "cc",        0xb0, 0x0008},
	{ "linker",    0xb0, 0x0009},
	{ "apwc",      0xb0, 0x000a},
	{ "desktop",   0xb0, 0x000c},
	{ "rez",       0xb0, 0x0015},
	{ "tmlpascal", 0xb0, 0x001e},
	{ "gsoft",     0xb0, 0x0104},
	{ "modula2",   0xb0, 0x0110},
	{ "disasm",    0xb0, 0x0115},
	{ "sdeasm",    0xb0, 0x0503},
	{ "sdecmd",    0xb0, 0x0506},
	{ "ps",        0xb0, 0x0719},
	{ "mdbasic",   0xb0, 0x0a04},
};

#define NUM_LANGS 18

int find_type(char *type_str, int *f, long *a) 
{
    int i;

    for(i = 0; i < NUM_TYPES; i++)
	if(!stricmp(type_str, types[i].name)) {
	    *f = types[i].file_type;
	    *a = types[i].aux_type;
	    return(0);
	}

    return(-1);
}

int find_lang(char *lang_str, int *f, long *a)
{
    int i;

    for(i = 0; i < NUM_LANGS; i++) 
	if(!stricmp(lang_str, langs[i].name)) {
	    *f = langs[i].file_type;
	    *a = langs[i].aux_type;
	    return(0);
	}

    return(-1);
}
