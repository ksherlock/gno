#ifdef __ORCAC__
segment "escape____";
#if !defined(TEST)
#pragma noroot
#endif
#pragma optimize 79
//#pragma memorymodel 1
#endif

static struct chars {
	unsigned short key;
	const char *value;
	unsigned short padding;
} table[] = {

#include "chars.h"

};

/*
 * specialchar
 *	handles \(xx escape sequences for special characters
 */

const char *specialchar (const register char *s) {

	unsigned begin = 0;
	unsigned end = sizeof(table) / sizeof(table[0]);

	unsigned short target = (s[0] << 8) | (s[1] << 0);

	/* binary search */
	for (;;) {
		
		unsigned mid = (begin+end)>>1;
		unsigned key = table[mid].key;
		if (key == target) return table[mid].value;

		if (key < target) {
			begin = mid + 1;
			if (begin >= end) return "";
			continue;
		}
		//if (key > target) {
		end = mid;
		if (end <= begin) return "";
		continue;
		//}
	}
}


#if defined(TEST)
#include <stdio.h>
#include <assert.h>
#include <string.h>
int main(int argc, char **argv) {

	int i;
	for (i = 0; i < sizeof(table) / sizeof(table[0]); ++i) {
		char lookup[3];
		lookup[0] = table[i].key >> 8;
		lookup[1] = table[i].key & 0xff;
		lookup[2] = 9;
		assert(table[i].value == specialchar(lookup));
	}
	assert(!strlen(specialchar("xx")));
	return 0;
}

#endif
