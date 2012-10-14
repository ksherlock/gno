/*
 * $Id: bmem.c,v 1.2 1997/09/21 06:04:59 gdr Exp $
 *
 * This file is formatted with tabs every 8 columns.
 */

#ifdef __ORCAC__
segment "libc_str__";
#endif

#include <strings.h>

void
bzero(void *buf, size_t len) {
	memset(buf, 0, len);
}

void
bcopy(const void *src, const void *dest, size_t len) {
	memmove(dest, src, len);
}


int
bcmp(const void *s1, const void *s2, size_t len) {
	memcmp(s1, s2, len);
}