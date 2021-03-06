
;***********************************************************************
;*
;*  Copyright (C) Kopriha Software, 1990 - 1991
;*  All rights reserved.
;*  Licensed material -- property of Kopriha Software
;*
;*  This software is made available solely pursuant to the terms
;*  of a Kopriha Software license agreement which governs its use.
;*
;*
;* Memory copy of copyright notice
;* Error messages for FilePort Port Driver
;*
;*
;* Description:
;*  The copyright notice is included for anyone that gets a copy of
;*  this software and decides to disassemble it.
;*
;*  The error messages are defined in assembler, because Orca/C makes
;*  the errors take up extra space (i.e.: All strings must be of a
;*  fixed length).  In assembler, no such restriction exists...
;*
;*
;* History: April 13 Dave  Created this module
;*
;*
;*
;***********************************************************************

         case  on                       Set case sensitivity in assembler
         objcase on                     Set case sensitivity in object

         gen off                        List generated code
         trace off                      List all macro generation

dummy	start		Throw away *.root file
	end

;***********************************************************************
;*
copyright_strings data
;*
;***********************************************************************

; First a copyright notice that will be in our executable...

  dc c'Copyright (C) Kopriha Software, 1990 - 1991  '
  dc c'All rights reserved.  '
  dc c'Licensed material -- property of Kopriha Software  '
  dc c'This software is made available solely pursuant to the terms '
  dc c'of a Kopriha Software license agreement which governs its use. '

  dc c'**** If you are reading this message then I''ll assume that you '
  dc c'are disassembling this program - Good Luck! It is a collection '
  dc c'of Orca/C and Orca/M.  If you would like a copy of the sources '
  dc c'then send a self addressed diskette mailer with a ProDOS formatted '
  dc c'diskette to me: Kopriha Software,  c/o Dave Kopper, 81 Main '
  dc c'Boulevard, Shrewsbury, MA 01545-3146 ****'


; Define pointers to all the error messages...

error_strings  entry

         dc    a4'E0'
         dc    a4'E1'
         dc    a4'E2'
         dc    a4'E3'
         dc    a4'E4'
         dc    a4'E5'
         dc    a4'E6'
         dc    a4'E7'
         dc    a4'E8'
         dc    a4'E9'
         dc    a4'E10'
         dc	a4'E11'

         dc    a4'EI'


; Now define all the error message strings...

E0       dc  c'I can''t set the buffer size correctly',i1'0'
E1       dc  c'I can''t open the configuration file {FilePort.Data}',i1'0'
E2       dc  c'I can''t allocate the pathname buffer',i1'0'
E3       dc  c'I can''t read the configuration file {FilePort.Data}',i1'0'
E4       dc  c'I can''t open the FilePort output directory',i1'0'
E5       dc  c'I can''t get the FilePort output directory count',i1'0'
E6       dc  c'I can''t get the next FilePort output directory entry',i1'0'
E7       dc  c'I can''t create the FilePort output file. '
         dc  c'There are too many printer data files in the '
         dc  c'FilePort output directory. Delete at least one and '
         dc  c'print your document again.',i1'0'
E8       dc  c'I can''t create a FilePort output file',i1'0'
E9       dc  c'I can''t open the FilePort output file',i1'0'
E10      dc  c'I can''t write to the FilePort output file',i1'0'
E11      dc  c'The line printer daemon is not active',i1'0'

EI       dc  c'Oops... Invalid error message number (programmer error)',i1'0'


         end                  ; End of Error message definitions
