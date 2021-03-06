
/*
 * Copyright (c) Kopriha Software, 1991
 *       All Rights Reserved
 *
 * Errors.H
 *
 * Description: This include file contains all the error
 *              code definitions required for this program.
 *
 *
 * Table of contents:
 *
 *   Macros:
 *
 *     ERROR_DIALOG() . . . . . . . . Display an error dialog and
 *                                    wait for the user to choose
 *                                    an option (usually only one).
 *
 *
 *  History:April 13, 1991  Dave  Created this file
 *
 */

#ifndef _ERROR_
#define _ERROR_

#ifndef __TYPES__
#include <types.h>
#endif

#ifndef _PORTABLE_C_
#include "Portable.C.h"
#endif




/* ****************************************************************** *
 *  Error code definitions for this product:                          *
 * ****************************************************************** */


#define BAD_BUFFER_SIZE         0
#define CANT_OPEN_CONFIG_FILE   BAD_BUFFER_SIZE+1
#define CANT_ALLOCATE_PATHNAME  CANT_OPEN_CONFIG_FILE+1
#define CANT_READ_PATHNAME      CANT_ALLOCATE_PATHNAME+1
#define CANT_OPEN_DIR           CANT_READ_PATHNAME+1
#define CANT_GET_ENTRY_COUNT    CANT_OPEN_DIR+1
#define CANT_GET_NEXT_FILE      CANT_GET_ENTRY_COUNT+1
#define TOO_MANY_SPOOLFILES     CANT_GET_NEXT_FILE+1
#define CANT_CREATE_SPOOL_FILE  TOO_MANY_SPOOLFILES+1
#define CANT_OPEN_SPOOL_FILE    CANT_CREATE_SPOOL_FILE+1
#define CANT_WRITE_DATA         CANT_OPEN_SPOOL_FILE+1
#define DAEMON_NOT_ACTIVE	CANT_WRITE_DATA+1
#define NUMBER_OF_ERROR_CODES   DAEMON_NOT_ACTIVE+1


/* ****************************************************************** *
 *  Macro definitions:                                                *
 * ****************************************************************** */

/*
 * ERROR_DIALOG - display an error dialog (with string substitution).
 *                Returning the button pressed to our caller.
 */

#define ERROR_DIALOG(_error_msg, _error_code, _button)               \
                                                                     \
        /*word*/_button = error_dialog( (_error_msg), (_error_code))



/* ****************************************************************** *
 *  Prototypes of all functions:                                      *
 * ****************************************************************** */

Word error_dialog(Word, Word);


#endif
