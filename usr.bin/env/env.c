#pragma lint -1

#include <types.h>
#include <shell.h>
#include <gsos.h>

#include <errno.h>
#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syslimits.h>

static ResultBuf255 name = { 255 };
static ResultBuf255 value = { 255 };

static UnsetVariableGSPB unset_dcb = { 1, &name.bufString };

unsigned _v = 0;

void reset_env(void) {
	static ReadIndexedGSPB dcb = { 4, &name, &value, 1, 0 };

	for(;;) {
		ReadIndexedGS(&dcb);
		if (_toolErr) {
			fprintf(stderr, "env: ReadIndexedGS: $04x\n", _toolErr);
			exit(1);
		}

		if (name.bufString.length == 0) break;

		if (_v > 1) {
			fprintf(stderr, "#env unsetting %.*s\n",
				name.bufString.length, name.bufString.text);
		}

		UnsetVariableGS(&unset_dcb);
		if (_toolErr) {
			fprintf(stderr, "env: UnsetVariableGS: $04x\n", _toolErr);
			exit(1);
		}
	}
}

void unset_env(const char *cp) {


	unsigned len = strlen(cp);
	if (memchr(cp, '=', len) || len > 255) {
		fprintf(stderr, "env: unsetenv %s: Invalid argument\n", cp);
		exit(1);
	}

	name.bufString.length = len;
	memcpy(name.bufString.text, cp, len);

	UnsetVariableGS(&unset_dcb);
	if (_toolErr) {
		fprintf(stderr, "env: UnsetVariableGS %s: $04x\n", cp, _toolErr);
		exit(1);
	}
}

/*
char get_env(const char *cp) {
	static ReadVariableGSPB dcb = { 3, &name.bufString, &value.bufString, 0 };

	int len = strlen(cp);
	if (len > 255) return NULL;
	name.bufString.length = len;
	memcpy(name.bufString.text, name, len);

	ReadVariableGS(&dcb);

	if ((len = value.bufString.length)) {
		cp = malloc(len + 1);
		memcpy(cp, value.bufString.text, len);
		cp[len] = 0;
		return cp;
	}

	return NULL;
}
*/

char *get_path(void) {

	static GSString32 name = { 4, "path" };
	static ReadVariableGSPB dcb = { 3, &name, &value.bufString, 0 };

	int len;

	ReadVariableGS(&dcb);
	if (_toolErr) return _PATH_DEFPATH;

	if ((len = value.bufString.length)) {
		char *cp = malloc(len + 1);
		memcpy(cp, value.bufString.text, len);
		cp[len] = 0;
		return cp;
	}

	return _PATH_DEFPATH;
}

int set_env(const char *cp) {

	static ReadVariableGSPB dcb = { 3, &name.bufString, &value.bufString, 1 };

	unsigned i;
	unsigned l;

	for (i = 0; ; ++i) {
		if (cp[i] == 0) return 0; 
		if (cp[i] != '=') continue;

		if (i == 0 || i > 255) {
			fprintf(stderr, "env: setenv %s: Invalid argument\n", cp);
			exit(1);
		}

		name.bufString.length = i;
		memcpy(name.bufString.text, cp, i);
		break;
	}

	cp += i + 1;
	l = strlen(cp);
	if (l > 255) {
		fprintf(stderr, "env: setenv %s: Invalid argument\n", cp);
		exit(1);
	}

	value.bufString.length = l;
	memcpy(value.bufString.text, cp, l);

	SetGS(&dcb);
	if (_toolErr) {
		fprintf(stderr, "env: SetGS %s: $04x\n", cp, _toolErr);
		exit(1);
	}

	return 1;
}

void print_env(void) {
	static ReadIndexedGSPB dcb = { 4, &name, &value };
	
	for (dcb.index = 1;;++dcb.index) {
		ReadIndexedGS(&dcb);
		if (_toolErr) {
			fprintf(stderr, "env: ReadIndexedGS: $04x\n", _toolErr);
			//exit(1);
		}
		if (name.bufString.length == 0) break;
		(void)printf("%.*s=%.*s\n", 
			name.bufString.length, name.bufString.text,
			value.bufString.length, value.bufString.text
		);
	}
}



void usage(void) {
	fprintf(stderr, "usage: env [-iv] [-P utilpath] [-u name] [name=value ...]\n");
	fprintf(stderr, "           [utility [argument ...]]\n");
	exit(1);
}


char *find_path(const char *arg, char *path) {

	static struct {
		unsigned length;
		char text[PATH_MAX];
	} buffer;

	static FileInfoRecGS dcb = {
		4,
		(GSString255Ptr)&buffer,
		0, 0, 0
	};

	const char *d;
	unsigned len = strlen(arg);

	if (memchr(arg, '/', len)) return arg;
	if (memchr(arg, ':', len)) return arg;


	if (!path) path = get_path();

	// gno uses space as separator, not ':'
	while ((d = strsep(&path, " "))) {
		unsigned l = strlen(d);

		if (l + len + 2 > PATH_MAX) continue;

		memcpy(buffer.text, d, l);
		if (l) buffer.text[l++] = '/';
		memcpy(buffer.text + l, arg, len + 1);
		buffer.length = l + len;

		// check if it exists...
		GetFileInfo(&dcb);
		if (_toolErr) continue;
		// filetype?
		return buffer.text;
	}

	// enoent.
	fprintf(stderr, "env: %s: No such file or directory.\n", arg);
	exit(127);
}

#if defined(__STACK_CHECK__)
#include <gno/gno.h>
static void
stackResults(void) {
	fprintf(stderr, "stack usage:\t ===> %d bytes <===\n",
		_endStackCheck());
}
#endif

int main(int argc, char **argv) {

	unsigned i;
	int ch;
	const char *path;
	const char *search_path;
	static unsigned zero = 0;


#ifdef __STACK_CHECK__
	_beginStackCheck();
	atexit(stackResults);
#endif


	// work around GNO/ME environment bug.
	PushVariablesGS(&zero);

	if (_toolErr) {
		fprintf(stderr, "env: PushVariablesGS: $04x\n", _toolErr);
		exit(1);
	}


	while ((ch = getopt(argc, argv, "-ivP:S:u:")) != -1) {
		switch(ch) {
			case 'v':
				_v++;
				break;

			case 'i':
			case '-':
				if (_v) fprintf(stderr, "#env clearing environ\n");
				reset_env();
				break;

			case 'u':
				if (_v) fprintf(stderr, "#env unsetting %s\n", optarg);
				unset_env(optarg);
				break;

			case 'P':
				search_path = optarg;
				break;

			case 'S':
				// not a posix flag.
				fprintf(stderr, "env: -S is not supported\n");
				exit(1);
				break;

			case '?':
			default:
				usage();
		}
	}

	argc -= optind;
	argv += optind;

	for( ; argc; ++argv, --argc) {

		if (!set_env(*argv)) break;
	}

	if (!argc) {
		print_env();
		exit(0);
	}

	path = find_path(argv[0], search_path);
	if (_v) {
		fprintf(stderr, "#env executing: %s\n", path);
	}
	execv(path, argv);

	exit(errno == ENOENT ? 127 : 126);
	return 0;
}
