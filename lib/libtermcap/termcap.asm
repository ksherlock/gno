                    case      on
                    longa     on
                    longi     on

                    mcopy termcap.mac

rootdummy           start
                    end

tgetent             start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0014                                            ; 0002: e9 14 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       #pathbuf                                          ; 0008: a9 00 00     ...
                    sta       <$05                                              ; 000b: 85 05        ..
                    lda       #pathbuf|-$0010                                   ; 000d: a9 00 00     ...
                    sta       <$07                                              ; 0010: 85 07        ..
                    lda       #pathvec                                          ; 0012: a9 00 00     ...
                    sta       <$01                                              ; 0015: 85 01        ..
                    lda       #pathvec|-$0010                                   ; 0017: a9 00 00     ...
                    sta       <$03                                              ; 001a: 85 03        ..
                    lda       #pathvec                                          ; 001c: a9 00 00     ...
                    sta       pvec                                              ; 001f: 8d 00 00     ...
                    lda       #pathvec|-$0010                                   ; 0022: a9 00 00     ...
                    sta       pvec+$0002                                        ; 0025: 8d 00 00     ...
                    lda       <$18                                              ; 0028: a5 18        ..
                    sta       tbuf                                              ; 002a: 8d 00 00     ...
                    lda       <$1a                                              ; 002d: a5 1a        ..
                    sta       tbuf+$0002                                        ; 002f: 8d 00 00     ...
                    pea       |TERMCAP|-$0010                                   ; 0032: f4 00 00     ...
                    pea       |TERMCAP                                          ; 0035: f4 00 00     ...
                    jsl       >getenv                                           ; 0038: 22 00 00 00  "...
                    sta       <$11                                              ; 003c: 85 11        ..
                    stx       <$13                                              ; 003e: 86 13        ..
                    ora       <$13                                              ; 0040: 05 13        ..
                    beq       _0062                                             ; 0042: f0 1e        ..
                    sep       #$30                                              ; 0044: e2 30        .0
                    longa     off
                    longi     off
                    ldy       #$00                                              ; 0046: a0 00        ..

_0048               anop
                    lda       [<$11],y                                          ; 0048: b7 11        ..
                    beq       _0052                                             ; 004a: f0 06        ..
                    sta       pathbuf,y                                         ; 004c: 99 00 00     ...
                    iny                                                         ; 004f: c8           .
                    bra       _0048                                             ; 0050: 80 f6        ..

_0052               anop
                    sta       pathbuf,y                                         ; 0052: 99 00 00     ...
                    rep       #$30                                              ; 0055: c2 30        .0
                    longa     on
                    longi     on
                    pei       <$13                                              ; 0057: d4 13        ..
                    pei       <$11                                              ; 0059: d4 11        ..
                    jsl       >~DISPOSE                                         ; 005b: 22 00 00 00  "...
                    jmp       |_0102                                            ; 005f: 4c 00 00     L..

_0062               anop
                    pea       |TERMPATH|-$0010                                  ; 0062: f4 00 00     ...
                    pea       |TERMPATH                                         ; 0065: f4 00 00     ...
                    jsl       >getenv                                           ; 0068: 22 00 00 00  "...
                    sta       <$0d                                              ; 006c: 85 0d        ..
                    stx       <$0f                                              ; 006e: 86 0f        ..
                    ora       <$0f                                              ; 0070: 05 0f        ..
                    beq       _0092                                             ; 0072: f0 1e        ..
                    sep       #$30                                              ; 0074: e2 30        .0
                    longa     off
                    longi     off
                    ldy       #$00                                              ; 0076: a0 00        ..

_0078               anop
                    lda       [<$0d],y                                          ; 0078: b7 0d        ..
                    beq       _0082                                             ; 007a: f0 06        ..
                    sta       pathbuf,y                                         ; 007c: 99 00 00     ...
                    iny                                                         ; 007f: c8           .
                    bra       _0078                                             ; 0080: 80 f6        ..

_0082               anop
                    sta       pathbuf,y                                         ; 0082: 99 00 00     ...
                    rep       #$30                                              ; 0085: c2 30        .0
                    longa     on
                    longi     on
                    pei       <$0f                                              ; 0087: d4 0f        ..
                    pei       <$0d                                              ; 0089: d4 0d        ..
                    jsl       >~DISPOSE                                         ; 008b: 22 00 00 00  "...
                    jmp       |_0102                                            ; 008f: 4c 00 00     L..

_0092               anop
                    pea       |HOME|-$0010                                      ; 0092: f4 00 00     ...
                    pea       |HOME                                             ; 0095: f4 00 00     ...
                    jsl       >getenv                                           ; 0098: 22 00 00 00  "...
                    sta       <$09                                              ; 009c: 85 09        ..
                    stx       <$0b                                              ; 009e: 86 0b        ..
                    ora       <$0b                                              ; 00a0: 05 0b        ..
                    beq       _00f0                                             ; 00a2: f0 4c        .L
                    sep       #$30                                              ; 00a4: e2 30        .0
                    longa     off
                    longi     off
                    ldy       #$00                                              ; 00a6: a0 00        ..

_00a8               anop                    
                    lda       [<$09],y                                          ; 00a8: b7 09        ..
                    beq       _00b2                                             ; 00aa: f0 06        ..
                    sta       pathbuf,y                                         ; 00ac: 99 00 00     ...
                    iny                                                         ; 00af: c8           .
                    bra       _00a8                                             ; 00b0: 80 f6        ..

_00b2               anop
                    phy                                                         ; 00b2: 5a           Z
                    ldy       #$00                                              ; 00b3: a0 00        ..
                    sep       #$20                                              ; 00b5: e2 20        . 
                    longa     off

_00b7               anop
                    lda       [<$09],y                                          ; 00b7: b7 09        ..
                    beq       _00c6                                             ; 00b9: f0 0b        ..
                    cmp       #$3a                                              ; 00bb: c9 3a        .:
                    beq       _00c8                                             ; 00bd: f0 09        ..
                    cmp       #$2f                                              ; 00bf: c9 2f        ./
                    beq       _00c8                                             ; 00c1: f0 05        ..
                    iny                                                         ; 00c3: c8           .
                    bra       _00b7                                             ; 00c4: 80 f1        ..

_00c6               anop
                    lda       #$3a                                              ; 00c6: a9 3a        .:

_00c8               anop
                    ply                                                         ; 00c8: 7a           z
                    sta       pathbuf,y                                         ; 00c9: 99 00 00     ...
                    rep       #$20                                              ; 00cc: c2 20        . 
                    longa     on
                    lda       #$002f                                            ; 00ce: a9 2f 00     ./.
                    sta       pathbuf,y                                         ; 00d1: 99 00 00     ...
                    iny                                                         ; 00d4: c8           .
                    rep       #$31                                              ; 00d5: c2 31        .1
                    longa     on
                    longi     on
                    rep       #$30                                              ; 00d7: c2 30        .0
                    longa     on
                    longi     on
                    tya                                                         ; 00d9: 98           .
                    and       #$00ff                                            ; 00da: 29 ff 00     )..
                    adc       <$05                                              ; 00dd: 65 05        e.
                    sta       <$05                                              ; 00df: 85 05        ..
                    lda       #$0000                                            ; 00e1: a9 00 00     ...
                    adc       <$07                                              ; 00e4: 65 07        e.
                    sta       <$07                                              ; 00e6: 85 07        ..
                    pei       <$0b                                              ; 00e8: d4 0b        ..
                    pei       <$09                                              ; 00ea: d4 09        ..
                    jsl       >~DISPOSE                                         ; 00ec: 22 00 00 00  "...

_00f0               anop
                    sep       #$30                                              ; 00f0: e2 30        .0
                    longa     off
                    longi     off
                    ldy       #$00                                              ; 00f2: a0 00        ..

_00f4               anop
                    lda       |termpath,y                                       ; 00f4: b9 00 00     ...
                    beq       _00fe                                             ; 00f7: f0 05        ..
                    sta       [<$05],y                                          ; 00f9: 97 05        ..
                    iny                                                         ; 00fb: c8           .
                    bra       _00f4                                             ; 00fc: 80 f6        ..

_00fe               anop
                    sta       [<$05],y                                          ; 00fe: 97 05        ..
                    rep       #$30                                              ; 0100: c2 30        .0
                    longa     on
                    longi     on
_0102               anop
                    lda       #pathbuf                                          ; 0102: a9 00 00     ...
                    sta       [<$01]                                            ; 0105: 87 01        ..
                    ldy       #$0002                                            ; 0107: a0 02 00     ...
                    lda       #pathbuf|-$0010                                   ; 010a: a9 00 00     ...
                    sta       [<$01],y                                          ; 010d: 97 01        ..
                    clc                                                         ; 010f: 18           .
                    lda       <$01                                              ; 0110: a5 01        ..
                    adc       #$0004                                            ; 0112: 69 04 00     i..
                    sta       <$01                                              ; 0115: 85 01        ..
                    lda       <$03                                              ; 0117: a5 03        ..
                    adc       #$0000                                            ; 0119: 69 00 00     i..
                    sta       <$03                                              ; 011c: 85 03        ..

_011e               anop
                    clc                                                         ; 011e: 18           .
                    lda       <$05                                              ; 011f: a5 05        ..
                    adc       #$0001                                            ; 0121: 69 01 00     i..
                    sta       <$05                                              ; 0124: 85 05        ..
                    lda       <$07                                              ; 0126: a5 07        ..
                    adc       #$0000                                            ; 0128: 69 00 00     i..
                    sta       <$07                                              ; 012b: 85 07        ..
                    lda       [<$05]                                            ; 012d: a7 05        ..
                    and       #$00ff                                            ; 012f: 29 ff 00     )..
                    beq       _0178                                             ; 0132: f0 44        .D
                    cmp       #$0020                                            ; 0134: c9 20 00     . .
                    bne       _011e                                             ; 0137: d0 e5        ..
                    sep       #$20                                              ; 0139: e2 20        . 
                    longa     off
                    lda       #$00                                              ; 013b: a9 00        ..
                    sta       [<$05]                                            ; 013d: 87 05        ..
                    rep       #$20                                              ; 013f: c2 20        . 
                    longa     on

_0141               anop
                    clc                                                         ; 0141: 18           .
                    lda       <$05                                              ; 0142: a5 05        ..
                    adc       #$0001                                            ; 0144: 69 01 00     i..
                    sta       <$05                                              ; 0147: 85 05        ..
                    lda       <$07                                              ; 0149: a5 07        ..
                    adc       #$0000                                            ; 014b: 69 00 00     i..
                    sta       <$07                                              ; 014e: 85 07        ..
                    lda       [<$05]                                            ; 0150: a7 05        ..
                    and       #$00ff                                            ; 0152: 29 ff 00     )..
                    beq       _0178                                             ; 0155: f0 21        .!
                    cmp       #$0020                                            ; 0157: c9 20 00     . .
                    beq       _0141                                             ; 015a: f0 e5        ..
                    lda       <$05                                              ; 015c: a5 05        ..
                    sta       [<$01]                                            ; 015e: 87 01        ..
                    ldy       #$0002                                            ; 0160: a0 02 00     ...
                    lda       <$07                                              ; 0163: a5 07        ..
                    sta       [<$01],y                                          ; 0165: 97 01        ..
                    clc                                                         ; 0167: 18           .
                    lda       <$01                                              ; 0168: a5 01        ..
                    adc       #$0004                                            ; 016a: 69 04 00     i..
                    sta       <$01                                              ; 016d: 85 01        ..
                    lda       <$03                                              ; 016f: a5 03        ..
                    adc       #$0000                                            ; 0171: 69 00 00     i..
                    sta       <$03                                              ; 0174: 85 03        ..
                    bra       _011e                                             ; 0176: 80 a6        ..

_0178               anop
                    lda       #$0000                                            ; 0178: a9 00 00     ...
                    sta       [<$01]                                            ; 017b: 87 01        ..
                    ldy       #$0002                                            ; 017d: a0 02 00     ...
                    sta       [<$01],y                                          ; 0180: 97 01        ..
                    pei       <$1e                                              ; 0182: d4 1e        ..
                    pei       <$1c                                              ; 0184: d4 1c        ..
                    pei       <$1a                                              ; 0186: d4 1a        ..
                    pei       <$18                                              ; 0188: d4 18        ..
                    jsl       >tfindent                                         ; 018a: 22 00 00 00  "...
                    tay                                                         ; 018e: a8           .
                    lda       <$16                                              ; 018f: a5 16        ..
                    sta       <$1e                                              ; 0191: 85 1e        ..
                    lda       <$15                                              ; 0193: a5 15        ..
                    sta       <$1d                                              ; 0195: 85 1d        ..
                    pld                                                         ; 0197: 2b           +
                    tsc                                                         ; 0198: 3b           ;
                    clc                                                         ; 0199: 18           .
                    adc       #$001c                                            ; 019a: 69 1c 00     i..
                    tcs                                                         ; 019d: 1b           .
                    tya                                                         ; 019e: 98           .
                    rtl                                                         ; 019f: 6b           k

TERMCAP             anop
                    dc c'TERMCAP',h'00'

TERMPATH            anop
                    dc c'TERMPATH',h'00'

HOME                anop
                    dc c'HOME',h'00'

termpath            anop
                    dc c'termcap /etc/termcap',h'00'

                    end

                    case      on
                    longa     on
                    longi     on

tfindent            private

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0018                                            ; 0002: e9 18 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       <$1c                                              ; 0008: a5 1c        ..
                    sta       tbuf                                              ; 000a: 8d 00 00     ...
                    lda       <$1e                                              ; 000d: a5 1e        ..
                    sta       tbuf+$0002                                        ; 000f: 8d 00 00     ...
                    lda       pvec                                              ; 0012: ad 00 00     ...
                    sta       <$13                                              ; 0015: 85 13        ..
                    lda       pvec+$0002                                        ; 0017: ad 00 00     ...
                    sta       <$15                                              ; 001a: 85 15        ..
                    stz       <$17                                              ; 001c: 64 17        d.
_001e               anop
                    stz       <$09                                              ; 001e: 64 09        d.
                    stz       <$07                                              ; 0020: 64 07        d.
_0022               anop
                    ldy       #$0002                                            ; 0022: a0 02 00     ...
                    lda       [<$13]                                            ; 0025: a7 13        ..
                    ora       [<$13],y                                          ; 0027: 17 13        ..
                    bne       _0036                                             ; 0029: d0 0b        ..
                    ldy       #$0000                                            ; 002b: a0 00 00     ...
                    lda       <$17                                              ; 002e: a5 17        ..
                    bne       _0033                                             ; 0030: d0 01        ..
                    dey                                                         ; 0032: 88           .

_0033               anop
                    jmp       |_0192                                            ; 0033: 4c 00 00     L..

_0036               anop
                    lda       [<$13],y                                          ; 0036: b7 13        ..
                    sta       <$03                                              ; 0038: 85 03        ..
                    lda       [<$13]                                            ; 003a: a7 13        ..
                    sta       <$01                                              ; 003c: 85 01        ..
                    ldy       #$0000                                            ; 003e: a0 00 00     ...

_0041               anop
                    lda       [<$01],y                                          ; 0041: b7 01        ..
                    and       #$00ff                                            ; 0043: 29 ff 00     )..
                    beq       _004e                                             ; 0046: f0 06        ..
                    sta       |_01da+$0002,y                                    ; 0048: 99 00 00     ...
                    iny                                                         ; 004b: c8           .
                    bra       _0041                                             ; 004c: 80 f3        ..

_004e               anop
                    sty       |_01da                                            ; 004e: 8c 00 00     ...
;                    jsl       >$e100a8                                          ; 0051: 22 a8 00 e1  "...
;                    dc        i1'$10, $20'                                      ; 0055: 10 20        . 
;                    dc        i4'_01a3'                                         ; 0057: 00 00 00 00  ....
                    _OpenGS   _01a3
                    bcc       _006f                                             ; 005b: 90 12        ..
                    clc                                                         ; 005d: 18           .
                    lda       <$13                                              ; 005e: a5 13        ..
                    adc       #$0004                                            ; 0060: 69 04 00     i..
                    sta       <$13                                              ; 0063: 85 13        ..
                    lda       <$15                                              ; 0065: a5 15        ..
                    adc       #$0000                                            ; 0067: 69 00 00     i..
                    sta       <$15                                              ; 006a: 85 15        ..
                    jmp       |_0022                                            ; 006c: 4c 00 00     L..

_006f               anop
                    lda       |_01a5                                            ; 006f: ad 00 00     ...
                    sta       |_01af                                            ; 0072: 8d 00 00     ...
                    sta       |_01bf                                            ; 0075: 8d 00 00     ...
                    pea       |$0000                                            ; 0078: f4 00 00     ...
                    pea       |$0400                                            ; 007b: f4 00 04     ...
                    jsl       >~NEW                                             ; 007e: 22 00 00 00  "...
                    sta       <$0f                                              ; 0082: 85 0f        ..
                    stx       <$11                                              ; 0084: 86 11        ..
                    sta       |_01b1                                            ; 0086: 8d 00 00     ...
                    stx       |_01b1+$0002                                      ; 0089: 8e 00 00     ...
                    inc       <$17                                              ; 008c: e6 17        ..
_008e               anop
                    lda       <$1c                                              ; 008e: a5 1c        ..
                    sta       <$0b                                              ; 0090: 85 0b        ..
                    lda       <$1e                                              ; 0092: a5 1e        ..
                    sta       <$0d                                              ; 0094: 85 0d        ..
_0096               anop
                    lda       <$09                                              ; 0096: a5 09        ..
                    cmp       <$07                                              ; 0098: c5 07        ..
                    bne       _00d3                                             ; 009a: d0 37        .7
;                    jsl       >$e100a8                                          ; 009c: 22 a8 00 e1  "...
;                    dc        i1'$12, $20'                                      ; 00a0: 12 20        . 
;                    dc        i4'_01ad'                                         ; 00a2: 00 00 00 00  ....
                    _ReadGS   _01ad
                    lda       |_01b9                                            ; 00a6: ad 00 00     ...
                    sta       <$07                                              ; 00a9: 85 07        ..
                    bne       _00d1                                             ; 00ab: d0 24        .$
;                    jsl       >$e100a8                                          ; 00ad: 22 a8 00 e1  "...
;                    dc        i1'$14, $20'                                      ; 00b1: 14 20        . 
;                    dc        i4'_01bd'                                         ; 00b3: 00 00 00 00  ....
                    _CloseGS  _01bd

                    clc                                                         ; 00b7: 18           .
                    lda       <$13                                              ; 00b8: a5 13        ..
                    adc       #$0004                                            ; 00ba: 69 04 00     i..
                    sta       <$13                                              ; 00bd: 85 13        ..
                    lda       <$15                                              ; 00bf: a5 15        ..
                    adc       #$0000                                            ; 00c1: 69 00 00     i..
                    sta       <$15                                              ; 00c4: 85 15        ..
                    pei       <$11                                              ; 00c6: d4 11        ..
                    pei       <$0f                                              ; 00c8: d4 0f        ..
                    jsl       >~DISPOSE                                         ; 00ca: 22 00 00 00  "...
                    jmp       |_001e                                            ; 00ce: 4c 00 00     L..

_00d1               anop
                    stz       <$09                                              ; 00d1: 64 09        d.

_00d3               anop
                    ldy       <$09                                              ; 00d3: a4 09        ..
                    lda       [<$0f],y                                          ; 00d5: b7 0f        ..
                    inc       <$09                                              ; 00d7: e6 09        ..
                    and       #$00ff                                            ; 00d9: 29 ff 00     )..
                    sta       <$05                                              ; 00dc: 85 05        ..
                    cmp       #$000d                                            ; 00de: c9 0d 00     ...
                    beq       _00e8                                             ; 00e1: f0 05        ..
                    cmp       #$000a                                            ; 00e3: c9 0a 00     ...
                    bne       _0124                                             ; 00e6: d0 3c        .<

_00e8               anop
                    lda       <$0d                                              ; 00e8: a5 0d        ..
                    cmp       <$1e                                              ; 00ea: c5 1e        ..
                    bcc       _0166                                             ; 00ec: 90 78        .x
                    beq       _00f2                                             ; 00ee: f0 02        ..
                    bra       _00fa                                             ; 00f0: 80 08        ..

_00f2               anop
                    lda       <$0b                                              ; 00f2: a5 0b        ..
                    cmp       <$1c                                              ; 00f4: c5 1c        ..
                    beq       _0166                                             ; 00f6: f0 6e        .n
                    bcc       _0166                                             ; 00f8: 90 6c        .l

_00fa               anop
                    sec                                                         ; 00fa: 38           8
                    lda       <$0b                                              ; 00fb: a5 0b        ..
                    sbc       #$0001                                            ; 00fd: e9 01 00     ...
                    sta       <$0b                                              ; 0100: 85 0b        ..
                    lda       <$0d                                              ; 0102: a5 0d        ..
                    sbc       #$0000                                            ; 0104: e9 00 00     ...
                    sta       <$0d                                              ; 0107: 85 0d        ..
                    lda       [<$0b]                                            ; 0109: a7 0b        ..
                    and       #$00ff                                            ; 010b: 29 ff 00     )..
                    cmp       #$005c                                            ; 010e: c9 5c 00     .\.
                    beq       _0096                                             ; 0111: f0 83        ..
                    clc                                                         ; 0113: 18           .
                    lda       <$0b                                              ; 0114: a5 0b        ..
                    adc       #$0001                                            ; 0116: 69 01 00     i..
                    sta       <$0b                                              ; 0119: 85 0b        ..
                    lda       <$0d                                              ; 011b: a5 0d        ..
                    adc       #$0000                                            ; 011d: 69 00 00     i..
                    sta       <$0d                                              ; 0120: 85 0d        ..
                    bra       _0166                                             ; 0122: 80 42        .B

_0124               anop
                    clc                                                         ; 0124: 18           .
                    lda       <$1c                                              ; 0125: a5 1c        ..
                    adc       #$0400                                            ; 0127: 69 00 04     i..
                    sta       <$01                                              ; 012a: 85 01        ..
                    lda       <$1e                                              ; 012c: a5 1e        ..
                    adc       #$0000                                            ; 012e: 69 00 00     i..
                    sta       <$03                                              ; 0131: 85 03        ..
                    lda       <$0d                                              ; 0133: a5 0d        ..
                    cmp       <$03                                              ; 0135: c5 03        ..
                    beq       _013b                                             ; 0137: f0 02        ..
                    bcs       _0141                                             ; 0139: b0 06        ..

_013b                anop
                    lda       <$0b                                              ; 013b: a5 0b        ..
                    cmp       <$01                                              ; 013d: c5 01        ..
                    bcc       _0150                                             ; 013f: 90 0f        ..

_0141               anop
                    pea       |_01c1|-$0010                                     ; 0141: f4 00 00     ...
                    pea       |_01c1                                            ; 0144: f4 00 00     ...
;                    ldx       #$210c                                            ; 0147: a2 0c 21     ..!
;                    jsl       >$e10000                                          ; 014a: 22 00 00 e1  "...
                    _ErrWriteCString
                    bra       _0166                                             ; 014e: 80 16        ..

_0150               anop
                    lda       <$05                                              ; 0150: a5 05        ..
                    sta       [<$0b]                                            ; 0152: 87 0b        ..
                    clc                                                         ; 0154: 18           .
                    lda       <$0b                                              ; 0155: a5 0b        ..
                    adc       #$0001                                            ; 0157: 69 01 00     i..
                    sta       <$0b                                              ; 015a: 85 0b        ..
                    lda       <$0d                                              ; 015c: a5 0d        ..
                    adc       #$0000                                            ; 015e: 69 00 00     i..
                    sta       <$0d                                              ; 0161: 85 0d        ..
                    jmp       |_0096                                            ; 0163: 4c 00 00     L..

_0166               anop
                    lda       #$0000                                            ; 0166: a9 00 00     ...
                    sta       [<$0b]                                            ; 0169: 87 0b        ..
                    pei       <$22                                              ; 016b: d4 22        ."
                    pei       <$20                                              ; 016d: d4 20        . 
                    jsl       >tnamatch                                         ; 016f: 22 00 00 00  "...
                    cmp       #$0000                                            ; 0173: c9 00 00     ...
                    bne       _017b                                             ; 0176: d0 03        ..
                    jmp       |_008e                                            ; 0178: 4c 00 00     L..

_017b               anop
;                    jsl       >$e100a8                                          ; 017b: 22 a8 00 e1  "...
;                    dc        i1'$14, $20'                                      ; 017f: 14 20        . 
;                    dc        i4'_01bd'                                         ; 0181: 00 00 00 00  ....
                    _CloseGS  _01bd
                    pei       <$11                                              ; 0185: d4 11        ..
                    pei       <$0f                                              ; 0187: d4 0f        ..
                    jsl       >~DISPOSE                                         ; 0189: 22 00 00 00  "...
                    jsl       >tnchktc                                          ; 018d: 22 00 00 00  "...
                    tay                                                         ; 0191: a8           .
_0192               anop
                    lda       <$1a                                              ; 0192: a5 1a        ..
                    sta       <$22                                              ; 0194: 85 22        ."
                    lda       <$19                                              ; 0196: a5 19        ..
                    sta       <$21                                              ; 0198: 85 21        .!
                    pld                                                         ; 019a: 2b           +
                    tsc                                                         ; 019b: 3b           ;
                    clc                                                         ; 019c: 18           .
                    adc       #$0020                                            ; 019d: 69 20 00     i .
                    tcs                                                         ; 01a0: 1b           .
                    tya                                                         ; 01a1: 98           .
                    rtl                                                         ; 01a2: 6b           k

;                   OpenGS DCB
_01a3               anop
                    dc        i2'3'                                             ; 01a3: 03 00        ..
_01a5               anop
                    dc        i2'0'                                             ; 01a5: 00 00        ..
                    dc        i4'_01da'                                         ; 01a7: 00 00 00 00  ....
                    dc        i2'1'                                             ; 01ab: 01 00        ..

;                   ReadGS DCB
_01ad               anop
                    dc        i2'4'                                             ; 01ad: 04 00        ..
_01af               anop
                    dc        i2'0'                                             ; 01af: 00 00        ..
_01b1               anop
                    dc        i1'$00, $00, $00, $00'                            ; 01b1: 00 00 00 00  ....
                    dc        i1'$00, $04, $00, $00'                            ; 01b5: 00 04 00 00  ....
_01b9               anop
                    dc        i1'$00, $00, $00, $00'                            ; 01b9: 00 00 00 00  ....

;                   CloseGS DCB
_01bd               anop
                    dc        i2'1'                                             ; 01bd: 01 00        ..
_01bf               anop
                    dc        i2'0'                                             ; 01bf: 00 00        ..


_01c1               anop
                    dc c'Termcap entry too long',h'0d 0a 00'

_01da               anop
                    ds        256                                               ; 01da:
                    end

                    case      on
                    longa     on
                    longi     on

tnamatch            private

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$000a                                            ; 0002: e9 0a 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       tbuf                                              ; 0008: ad 00 00     ...
                    sta       <$07                                              ; 000b: 85 07        ..
                    lda       tbuf+$0002                                        ; 000d: ad 00 00     ...
                    sta       <$09                                              ; 0010: 85 09        ..
                    ldy       #$0000                                            ; 0012: a0 00 00     ...
                    lda       [<$07]                                            ; 0015: a7 07        ..
                    and       #$00ff                                            ; 0017: 29 ff 00     )..
                    cmp       #$0023                                            ; 001a: c9 23 00     .#.
                    beq       _0073                                             ; 001d: f0 54        .T

_001f               anop
                    lda       <$0e                                              ; 001f: a5 0e        ..
                    sta       <$03                                              ; 0021: 85 03        ..
                    lda       <$10                                              ; 0023: a5 10        ..
                    sta       <$05                                              ; 0025: 85 05        ..

_0027               anop
                    lda       [<$03]                                            ; 0027: a7 03        ..
                    and       #$00ff                                            ; 0029: 29 ff 00     )..
                    beq       _0042                                             ; 002c: f0 14        ..
                    sta       <$01                                              ; 002e: 85 01        ..
                    lda       [<$07],y                                          ; 0030: b7 07        ..
                    and       #$00ff                                            ; 0032: 29 ff 00     )..
                    cmp       <$01                                              ; 0035: c5 01        ..
                    bne       _0042                                             ; 0037: d0 09        ..
                    iny                                                         ; 0039: c8           .
                    inc       <$03                                              ; 003a: e6 03        ..
                    bne       _0027                                             ; 003c: d0 e9        ..
                    inc       <$05                                              ; 003e: e6 05        ..
                    bra       _0027                                             ; 0040: 80 e5        ..

_0042               anop
                    lda       [<$03]                                            ; 0042: a7 03        ..
                    and       #$00ff                                            ; 0044: 29 ff 00     )..
                    bne       _005f                                             ; 0047: d0 16        ..
                    lda       [<$07],y                                          ; 0049: b7 07        ..
                    and       #$00ff                                            ; 004b: 29 ff 00     )..
                    beq       _005a                                             ; 004e: f0 0a        ..
                    cmp       #$007c                                            ; 0050: c9 7c 00     .|.
                    beq       _005a                                             ; 0053: f0 05        ..
                    cmp       #$003a                                            ; 0055: c9 3a 00     .:.
                    bne       _005f                                             ; 0058: d0 05        ..

_005a               anop
                    ldy       #$0001                                            ; 005a: a0 01 00     ...
                    bra       _0076                                             ; 005d: 80 17        ..

_005f               anop
                    lda       [<$07],y                                          ; 005f: b7 07        ..
                    and       #$00ff                                            ; 0061: 29 ff 00     )..
                    beq       _0073                                             ; 0064: f0 0d        ..
                    cmp       #$003a                                            ; 0066: c9 3a 00     .:.
                    beq       _0073                                             ; 0069: f0 08        ..
                    iny                                                         ; 006b: c8           .
                    cmp       #$007c                                            ; 006c: c9 7c 00     .|.
                    beq       _001f                                             ; 006f: f0 ae        ..
                    bra       _005f                                             ; 0071: 80 ec        ..

_0073               anop
                    ldy       #$0000                                            ; 0073: a0 00 00     ...

_0076               anop
                    lda       <$0c                                              ; 0076: a5 0c        ..
                    sta       <$10                                              ; 0078: 85 10        ..
                    lda       <$0b                                              ; 007a: a5 0b        ..
                    sta       <$0f                                              ; 007c: 85 0f        ..
                    pld                                                         ; 007e: 2b           +
                    tsc                                                         ; 007f: 3b           ;
                    clc                                                         ; 0080: 18           .
                    adc       #$000e                                            ; 0081: 69 0e 00     i..
                    tcs                                                         ; 0084: 1b           .
                    tya                                                         ; 0085: 98           .
                    rtl                                                         ; 0086: 6b           k
                    end

                    case      on
                    longa     on
                    longi     on

tnchktc             private

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0002                                            ; 0002: e9 02 00     ...
                    tcs                                                         ; 0005: 1b           .
                    inc       a                                                 ; 0006: 1a           .
                    phd                                                         ; 0007: 0b           .
                    tcd                                                         ; 0008: 5b           [
                    phb                                                         ; 0009: 8b           .
                    phk                                                         ; 000a: 4b           K
                    plb                                                         ; 000b: ab           .
                    lda       #$0001                                            ; 000c: a9 01 00     ...
                    sta       <$00                                              ; 000f: 85 00        ..
                    ldy       <$00                                              ; 0011: a4 00        ..
                    plb                                                         ; 0013: ab           .
                    pld                                                         ; 0014: 2b           +
                    tsc                                                         ; 0015: 3b           ;
                    clc                                                         ; 0016: 18           .
                    adc       #$0002                                            ; 0017: 69 02 00     i..
                    tcs                                                         ; 001a: 1b           .
                    tya                                                         ; 001b: 98           .
                    rtl                                                         ; 001c: 6b           k
                    end

                    case      on
                    longa     on
                    longi     on

tgetnum             start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0008                                            ; 0002: e9 08 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       tbuf                                              ; 0008: ad 00 00     ...
                    sta       <$05                                              ; 000b: 85 05        ..
                    lda       tbuf+$0002                                        ; 000d: ad 00 00     ...
                    sta       <$07                                              ; 0010: 85 07        ..
                    ldy       #$ffff                                            ; 0012: a0 ff ff     ...
                    sty       <$03                                              ; 0015: 84 03        ..

_0017               anop
                    iny                                                         ; 0017: c8           .

_0018               anop
                    lda       [<$05],y                                          ; 0018: b7 05        ..
                    and       #$00ff                                            ; 001a: 29 ff 00     )..
                    bne       _0022                                             ; 001d: d0 03        ..
                    jmp       |_00bb                                            ; 001f: 4c 00 00     L..

_0022               anop
                    cmp       #$003a                                            ; 0022: c9 3a 00     .:.
                    bne       _0017                                             ; 0025: d0 f0        ..

_0027               anop
                    iny                                                         ; 0027: c8           .
                    lda       [<$05],y                                          ; 0028: b7 05        ..
                    and       #$00ff                                            ; 002a: 29 ff 00     )..
                    bne       _0032                                             ; 002d: d0 03        ..
                    jmp       |_00bb                                            ; 002f: 4c 00 00     L..

_0032               anop
                    cmp       #$003a                                            ; 0032: c9 3a 00     .:.
                    beq       _0027                                             ; 0035: f0 f0        ..
                    eor       [<$0c]                                            ; 0037: 47 0c        G.
                    and       #$00ff                                            ; 0039: 29 ff 00     )..
                    bne       _0017                                             ; 003c: d0 d9        ..
                    iny                                                         ; 003e: c8           .
                    lda       [<$05],y                                          ; 003f: b7 05        ..
                    and       #$00ff                                            ; 0041: 29 ff 00     )..
                    bne       _0049                                             ; 0044: d0 03        ..
                    jmp       |_00bb                                            ; 0046: 4c 00 00     L..

_0049               anop
                    cmp       #$003a                                            ; 0049: c9 3a 00     .:.
                    beq       _0027                                             ; 004c: f0 d9        ..
                    xba                                                         ; 004e: eb           .
                    eor       [<$0c]                                            ; 004f: 47 0c        G.
                    and       #$ff00                                            ; 0051: 29 00 ff     )..
                    bne       _0017                                             ; 0054: d0 c1        ..
                    iny                                                         ; 0056: c8           .
                    lda       [<$05],y                                          ; 0057: b7 05        ..
                    and       #$00ff                                            ; 0059: 29 ff 00     )..
                    cmp       #$0040                                            ; 005c: c9 40 00     .@.
                    bne       _0064                                             ; 005f: d0 03        ..
                    jmp       |_00bb                                            ; 0061: 4c 00 00     L..

_0064               anop
                    cmp       #$0023                                            ; 0064: c9 23 00     .#.
                    bne       _0018                                             ; 0067: d0 af        ..
                    iny                                                         ; 0069: c8           .
                    stz       <$03                                              ; 006a: 64 03        d.
                    ldx       #$0000                                            ; 006c: a2 00 00     ...
                    lda       [<$05],y                                          ; 006f: b7 05        ..
                    and       #$00ff                                            ; 0071: 29 ff 00     )..
                    cmp       #$0030                                            ; 0074: c9 30 00     .0.
                    beq       _009b                                             ; 0077: f0 22        ."

_0079               anop
                    lda       [<$05],y                                          ; 0079: b7 05        ..
                    and       #$00ff                                            ; 007b: 29 ff 00     )..
                    cmp       #$0030                                            ; 007e: c9 30 00     .0.
                    bcc       _00bb                                             ; 0081: 90 38        .8
                    cmp       #$003a                                            ; 0083: c9 3a 00     .:.
                    bcs       _00bb                                             ; 0086: b0 33        .3
                    sbc       #$002f                                            ; 0088: e9 2f 00     ./.
                    sta       <$01                                              ; 008b: 85 01        ..
                    lda       <$03                                              ; 008d: a5 03        ..
                    asl       a                                                 ; 008f: 0a           .
                    asl       a                                                 ; 0090: 0a           .
                    adc       <$03                                              ; 0091: 65 03        e.
                    asl       a                                                 ; 0093: 0a           .
                    adc       <$01                                              ; 0094: 65 01        e.
                    sta       <$03                                              ; 0096: 85 03        ..
                    iny                                                         ; 0098: c8           .
                    bra       _0079                                             ; 0099: 80 de        ..

_009b               anop
                    lda       [<$05],y                                          ; 009b: b7 05        ..
                    and       #$00ff                                            ; 009d: 29 ff 00     )..
                    cmp       #$0030                                            ; 00a0: c9 30 00     .0.
                    bcc       _00bb                                             ; 00a3: 90 16        ..
                    cmp       #$0038                                            ; 00a5: c9 38 00     .8.
                    bcs       _00bb                                             ; 00a8: b0 11        ..
                    sbc       #$002f                                            ; 00aa: e9 2f 00     ./.
                    sta       <$01                                              ; 00ad: 85 01        ..
                    lda       <$03                                              ; 00af: a5 03        ..
                    asl       a                                                 ; 00b1: 0a           .
                    asl       a                                                 ; 00b2: 0a           .
                    asl       a                                                 ; 00b3: 0a           .
                    adc       <$01                                              ; 00b4: 65 01        e.
                    sta       <$03                                              ; 00b6: 85 03        ..
                    iny                                                         ; 00b8: c8           .
                    bra       _009b                                             ; 00b9: 80 e0        ..
_00bb               anop
                    ldy       <$03                                              ; 00bb: a4 03        ..
                    lda       <$0a                                              ; 00bd: a5 0a        ..
                    sta       <$0e                                              ; 00bf: 85 0e        ..
                    lda       <$09                                              ; 00c1: a5 09        ..
                    sta       <$0d                                              ; 00c3: 85 0d        ..
                    pld                                                         ; 00c5: 2b           +
                    tsc                                                         ; 00c6: 3b           ;
                    clc                                                         ; 00c7: 18           .
                    adc       #$000c                                            ; 00c8: 69 0c 00     i..
                    tcs                                                         ; 00cb: 1b           .
                    tya                                                         ; 00cc: 98           .
                    rtl                                                         ; 00cd: 6b           k
                    end

                    case      on
                    longa     on
                    longi     on

tgetflag            start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0008                                            ; 0002: e9 08 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    stz       <$07                                              ; 0008: 64 07        d.
                    lda       tbuf                                              ; 000a: ad 00 00     ...
                    sta       <$01                                              ; 000d: 85 01        ..
                    lda       tbuf+$0002                                        ; 000f: ad 00 00     ...
                    sta       <$03                                              ; 0012: 85 03        ..
                    ldy       #$ffff                                            ; 0014: a0 ff ff     ...

_0017               anop
                    iny                                                         ; 0017: c8           .

_0018               anop
                    lda       [<$01],y                                          ; 0018: b7 01        ..
                    and       #$00ff                                            ; 001a: 29 ff 00     )..
                    beq       _0063                                             ; 001d: f0 44        .D
                    cmp       #$003a                                            ; 001f: c9 3a 00     .:.
                    bne       _0017                                             ; 0022: d0 f3        ..

_0024               anop
                    iny                                                         ; 0024: c8           .
                    lda       [<$01],y                                          ; 0025: b7 01        ..
                    and       #$00ff                                            ; 0027: 29 ff 00     )..
                    beq       _0063                                             ; 002a: f0 37        .7
                    cmp       #$003a                                            ; 002c: c9 3a 00     .:.
                    beq       _0024                                             ; 002f: f0 f3        ..
                    eor       [<$0c]                                            ; 0031: 47 0c        G.
                    and       #$00ff                                            ; 0033: 29 ff 00     )..
                    bne       _0017                                             ; 0036: d0 df        ..
                    iny                                                         ; 0038: c8           .
                    lda       [<$01],y                                          ; 0039: b7 01        ..
                    and       #$00ff                                            ; 003b: 29 ff 00     )..
                    beq       _0017                                             ; 003e: f0 d7        ..
                    cmp       #$003a                                            ; 0040: c9 3a 00     .:.
                    beq       _0024                                             ; 0043: f0 df        ..
                    xba                                                         ; 0045: eb           .
                    eor       [<$0c]                                            ; 0046: 47 0c        G.
                    and       #$ff00                                            ; 0048: 29 00 ff     )..
                    bne       _0017                                             ; 004b: d0 ca        ..
                    iny                                                         ; 004d: c8           .
                    lda       [<$01],y                                          ; 004e: b7 01        ..
                    and       #$00ff                                            ; 0050: 29 ff 00     )..
                    beq       _0061                                             ; 0053: f0 0c        ..
                    cmp       #$0040                                            ; 0055: c9 40 00     .@.
                    beq       _0063                                             ; 0058: f0 09        ..
                    cmp       #$003a                                            ; 005a: c9 3a 00     .:.
                    beq       _0061                                             ; 005d: f0 02        ..
                    bra       _0018                                             ; 005f: 80 b7        ..

_0061               anop
                    inc       <$07                                              ; 0061: e6 07        ..

_0063               anop
                    ldy       <$07                                              ; 0063: a4 07        ..
                    lda       <$0a                                              ; 0065: a5 0a        ..
                    sta       <$0e                                              ; 0067: 85 0e        ..
                    lda       <$09                                              ; 0069: a5 09        ..
                    sta       <$0d                                              ; 006b: 85 0d        ..
                    pld                                                         ; 006d: 2b           +
                    tsc                                                         ; 006e: 3b           ;
                    clc                                                         ; 006f: 18           .
                    adc       #$000c                                            ; 0070: 69 0c 00     i..
                    tcs                                                         ; 0073: 1b           .
                    tya                                                         ; 0074: 98           .
                    rtl                                                         ; 0075: 6b           k
                    end

                    case      on
                    longa     on
                    longi     on

tgetstr             start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0008                                            ; 0002: e9 08 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    stz       <$01                                              ; 0008: 64 01        d.
                    stz       <$03                                              ; 000a: 64 03        d.
                    lda       tbuf                                              ; 000c: ad 00 00     ...
                    sta       <$05                                              ; 000f: 85 05        ..
                    lda       tbuf+$0002                                        ; 0011: ad 00 00     ...
                    sta       <$07                                              ; 0014: 85 07        ..

_0016               anop
                    lda       [<$05]                                            ; 0016: a7 05        ..
                    and       #$00ff                                            ; 0018: 29 ff 00     )..
                    bne       _0020                                             ; 001b: d0 03        ..
                    jmp       |_008d                                            ; 001d: 4c 00 00     L..

_0020               anop
                    cmp       #$003a                                            ; 0020: c9 3a 00     .:.
                    beq       _002d                                             ; 0023: f0 08        ..
                    inc       <$05                                              ; 0025: e6 05        ..
                    bne       _0016                                             ; 0027: d0 ed        ..
                    inc       <$07                                              ; 0029: e6 07        ..
                    bra       _0016                                             ; 002b: 80 e9        ..

_002d               anop
                    inc       <$05                                              ; 002d: e6 05        ..
                    bne       _0033                                             ; 002f: d0 02        ..
                    inc       <$07                                              ; 0031: e6 07        ..

_0033               anop
                    lda       [<$05]                                            ; 0033: a7 05        ..
                    and       #$00ff                                            ; 0035: 29 ff 00     )..
                    beq       _008d                                             ; 0038: f0 53        .S
                    cmp       #$003a                                            ; 003a: c9 3a 00     .:.
                    beq       _002d                                             ; 003d: f0 ee        ..
                    inc       <$05                                              ; 003f: e6 05        ..
                    bne       _0045                                             ; 0041: d0 02        ..
                    inc       <$07                                              ; 0043: e6 07        ..

_0045               anop
                    eor       [<$0c]                                            ; 0045: 47 0c        G.
                    and       #$00ff                                            ; 0047: 29 ff 00     )..
                    bne       _0016                                             ; 004a: d0 ca        ..
                    lda       [<$05]                                            ; 004c: a7 05        ..
                    and       #$00ff                                            ; 004e: 29 ff 00     )..
                    beq       _008d                                             ; 0051: f0 3a        .:
                    cmp       #$003a                                            ; 0053: c9 3a 00     .:.
                    beq       _002d                                             ; 0056: f0 d5        ..
                    inc       <$05                                              ; 0058: e6 05        ..
                    bne       _005e                                             ; 005a: d0 02        ..
                    inc       <$07                                              ; 005c: e6 07        ..

_005e               anop
                    ldy       #$0001                                            ; 005e: a0 01 00     ...
                    eor       [<$0c],y                                          ; 0061: 57 0c        W.
                    and       #$00ff                                            ; 0063: 29 ff 00     )..
                    bne       _0016                                             ; 0066: d0 ae        ..
                    lda       [<$05]                                            ; 0068: a7 05        ..
                    and       #$00ff                                            ; 006a: 29 ff 00     )..
                    cmp       #$0040                                            ; 006d: c9 40 00     .@.
                    beq       _008d                                             ; 0070: f0 1b        ..
                    cmp       #$003d                                            ; 0072: c9 3d 00     .=.
                    bne       _0016                                             ; 0075: d0 9f        ..
                    inc       <$05                                              ; 0077: e6 05        ..
                    bne       _007d                                             ; 0079: d0 02        ..
                    inc       <$07                                              ; 007b: e6 07        ..

_007d               anop
                    pei       <$12                                              ; 007d: d4 12        ..
                    pei       <$10                                              ; 007f: d4 10        ..
                    pei       <$07                                              ; 0081: d4 07        ..
                    pei       <$05                                              ; 0083: d4 05        ..
                    jsl       >tdecode                                          ; 0085: 22 00 00 00  "...
                    sta       <$01                                              ; 0089: 85 01        ..
                    stx       <$03                                              ; 008b: 86 03        ..
_008d               anop
                    ldy       <$01                                              ; 008d: a4 01        ..
                    ldx       <$03                                              ; 008f: a6 03        ..
                    lda       <$0a                                              ; 0091: a5 0a        ..
                    sta       <$12                                              ; 0093: 85 12        ..
                    lda       <$09                                              ; 0095: a5 09        ..
                    sta       <$11                                              ; 0097: 85 11        ..
                    pld                                                         ; 0099: 2b           +
                    tsc                                                         ; 009a: 3b           ;
                    clc                                                         ; 009b: 18           .
                    adc       #$0010                                            ; 009c: 69 10 00     i..
                    tcs                                                         ; 009f: 1b           .
                    tya                                                         ; 00a0: 98           .
                    rtl                                                         ; 00a1: 6b           k
                    end

                    case      on
                    longa     on
                    longi     on

tdecode             private

                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0006                                            ; 0002: e9 06 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       [<$0e]                                            ; 0008: a7 0e        ..
                    sta       <$03                                              ; 000a: 85 03        ..
                    ldy       #$0002                                            ; 000c: a0 02 00     ...
                    lda       [<$0e],y                                          ; 000f: b7 0e        ..
                    sta       <$05                                              ; 0011: 85 05        ..
                    ldy       #$0000                                            ; 0013: a0 00 00     ...
_0016               anop
                    lda       [<$0a],y                                          ; 0016: b7 0a        ..
                    and       #$00ff                                            ; 0018: 29 ff 00     )..
                    bne       _0020                                             ; 001b: d0 03        ..
                    jmp       |_00a4                                            ; 001d: 4c 00 00     L..

_0020               anop
                    cmp       #$003a                                            ; 0020: c9 3a 00     .:.
                    bne       _0028                                             ; 0023: d0 03        ..
                    jmp       |_00a4                                            ; 0025: 4c 00 00     L..

_0028               anop
                    iny                                                         ; 0028: c8           .
                    cmp       #$005e                                            ; 0029: c9 5e 00     .^.
                    bne       _0036                                             ; 002c: d0 08        ..
                    lda       [<$0a],y                                          ; 002e: b7 0a        ..
                    and       #$001f                                            ; 0030: 29 1f 00     )..
                    iny                                                         ; 0033: c8           .
                    bra       _0096                                             ; 0034: 80 60        .`

_0036               anop
                    cmp       #$005c                                            ; 0036: c9 5c 00     .\.
                    bne       _0096                                             ; 0039: d0 5b        .[
                    lda       [<$0a],y                                          ; 003b: b7 0a        ..
                    and       #$00ff                                            ; 003d: 29 ff 00     )..
                    sta       <$01                                              ; 0040: 85 01        ..
                    iny                                                         ; 0042: c8           .
                    ldx       #$0000                                            ; 0043: a2 00 00     ...

_0046               anop
                    lda       |_00d7,x                                          ; 0046: bd 00 00     ...
                    and       #$00ff                                            ; 0049: 29 ff 00     )..
                    beq       _005d                                             ; 004c: f0 0f        ..
                    cmp       <$01                                              ; 004e: c5 01        ..
                    beq       _0055                                             ; 0050: f0 03        ..
                    inx                                                         ; 0052: e8           .
                    bra       _0046                                             ; 0053: 80 f1        ..

_0055               anop
                    lda       |_00e1,x                                          ; 0055: bd 00 00     ...
                    and       #$00ff                                            ; 0058: 29 ff 00     )..
                    bra       _0096                                             ; 005b: 80 39        .9

_005d               anop
                    lda       <$01                                              ; 005d: a5 01        ..
                    cmp       #$0030                                            ; 005f: c9 30 00     .0.
                    bcc       _0096                                             ; 0062: 90 32        .2
                    cmp       #$0038                                            ; 0064: c9 38 00     .8.
                    bcs       _0096                                             ; 0067: b0 2d        .-
                    sbc       #$002f                                            ; 0069: e9 2f 00     ./.
                    sta       <$01                                              ; 006c: 85 01        ..
                    ldx       #$0002                                            ; 006e: a2 02 00     ...
                    lda       [<$0a],y                                          ; 0071: b7 0a        ..
                    and       #$00ff                                            ; 0073: 29 ff 00     )..

_0076               anop
                    asl       <$01                                              ; 0076: 06 01        ..
                    asl       <$01                                              ; 0078: 06 01        ..
                    asl       <$01                                              ; 007a: 06 01        ..
                    sbc       #$002f                                            ; 007c: e9 2f 00     ./.
                    tsb       <$01                                              ; 007f: 04 01        ..
                    iny                                                         ; 0081: c8           .
                    dex                                                         ; 0082: ca           .
                    beq       _0096                                             ; 0083: f0 11        ..
                    lda       [<$0a],y                                          ; 0085: b7 0a        ..
                    and       #$00ff                                            ; 0087: 29 ff 00     )..
                    cmp       #$0030                                            ; 008a: c9 30 00     .0.
                    bcc       _0094                                             ; 008d: 90 05        ..
                    cmp       #$0038                                            ; 008f: c9 38 00     .8.
                    bcc       _0076                                             ; 0092: 90 e2        ..
_0094               anop
                    lda       <$01                                              ; 0094: a5 01        ..

_0096               anop
                    sta       [<$03]                                            ; 0096: 87 03        ..
                    inc       <$03                                              ; 0098: e6 03        ..
                    beq       _009f                                             ; 009a: f0 03        ..
                    jmp       |_0016                                            ; 009c: 4c 00 00     L..

_009f               anop
                    inc       <$05                                              ; 009f: e6 05        ..
                    jmp       |_0016                                            ; 00a1: 4c 00 00     L..

_00a4               anop
                    lda       #$0000                                            ; 00a4: a9 00 00     ...
                    sta       [<$03]                                            ; 00a7: 87 03        ..
                    inc       <$03                                              ; 00a9: e6 03        ..
                    bne       _00af                                             ; 00ab: d0 02        ..
                    inc       <$05                                              ; 00ad: e6 05        ..

_00af               anop
                    ldy       #$0002                                            ; 00af: a0 02 00     ...
                    lda       [<$0e]                                            ; 00b2: a7 0e        ..
                    sta       <$0a                                              ; 00b4: 85 0a        ..
                    lda       [<$0e],y                                          ; 00b6: b7 0e        ..
                    sta       <$0c                                              ; 00b8: 85 0c        ..
                    lda       <$03                                              ; 00ba: a5 03        ..
                    sta       [<$0e]                                            ; 00bc: 87 0e        ..
                    lda       <$05                                              ; 00be: a5 05        ..
                    sta       [<$0e],y                                          ; 00c0: 97 0e        ..
                    ldy       <$0a                                              ; 00c2: a4 0a        ..
                    ldx       <$0c                                              ; 00c4: a6 0c        ..
                    lda       <$08                                              ; 00c6: a5 08        ..
                    sta       <$10                                              ; 00c8: 85 10        ..
                    lda       <$07                                              ; 00ca: a5 07        ..
                    sta       <$0f                                              ; 00cc: 85 0f        ..
                    pld                                                         ; 00ce: 2b           +
                    tsc                                                         ; 00cf: 3b           ;
                    clc                                                         ; 00d0: 18           .
                    adc       #$000e                                            ; 00d1: 69 0e 00     i..
                    tcs                                                         ; 00d4: 1b           .
                    tya                                                         ; 00d5: 98           .
                    rtl                                                         ; 00d6: 6b           k

_00d7               anop
                    dc c'E^\:nrtbf',h'00'

_00e1               anop
                    dc h'1b',c'^\:',h'0a 0d 09 08 0c'

                    end

                    case      on
                    longa     on
                    longi     on

tgoto               start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0014                                            ; 0002: e9 14 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       #_021a                                            ; 0008: a9 00 00     ...
                    sta       <$09                                              ; 000b: 85 09        ..
                    lda       #_021a|-$0010                                     ; 000d: a9 00 00     ...
                    sta       <$0b                                              ; 0010: 85 0b        ..
                    lda       #_020a                                            ; 0012: a9 00 00     ...
                    sta       <$0d                                              ; 0015: 85 0d        ..
                    lda       #_020a|-$0010                                     ; 0017: a9 00 00     ...
                    sta       <$0f                                              ; 001a: 85 0f        ..
                    lda       <$18                                              ; 001c: a5 18        ..
                    sta       <$11                                              ; 001e: 85 11        ..
                    lda       <$1a                                              ; 0020: a5 1a        ..
                    sta       <$13                                              ; 0022: 85 13        ..
                    lda       <$1e                                              ; 0024: a5 1e        ..
                    sta       <$05                                              ; 0026: 85 05        ..
                    stz       <$03                                              ; 0028: 64 03        d.
                    lda       <$11                                              ; 002a: a5 11        ..
                    ora       <$13                                              ; 002c: 05 13        ..
                    bne       _0033                                             ; 002e: d0 03        ..
                    jmp       |_01f5                                            ; 0030: 4c 00 00     L..

_0033               anop
                    stz       |_0210                                            ; 0033: 9c 00 00     ...
_0036               anop
                    lda       [<$11]                                            ; 0036: a7 11        ..
                    and       #$00ff                                            ; 0038: 29 ff 00     )..
                    bne       _0040                                             ; 003b: d0 03        ..
                    jmp       |_01eb                                            ; 003d: 4c 00 00     L..

_0040               anop
                    sta       <$07                                              ; 0040: 85 07        ..
                    inc       <$11                                              ; 0042: e6 11        ..
                    bne       _0048                                             ; 0044: d0 02        ..
                    inc       <$13                                              ; 0046: e6 13        ..

_0048               anop
                    cmp       #'%'                                              ; 0048: c9 25 00     .%.
                    beq       _0057                                             ; 004b: f0 0a        ..
                    sta       [<$09]                                            ; 004d: 87 09        ..
                    inc       <$09                                              ; 004f: e6 09        ..
                    bne       _0036                                             ; 0051: d0 e3        ..
                    inc       <$0b                                              ; 0053: e6 0b        ..
                    bra       _0036                                             ; 0055: 80 df        ..

_0057               anop
                    lda       [<$11]                                            ; 0057: a7 11        ..
                    and       #$00ff                                            ; 0059: 29 ff 00     )..
                    sta       <$07                                              ; 005c: 85 07        ..
                    inc       <$11                                              ; 005e: e6 11        ..
                    bne       _0064                                             ; 0060: d0 02        ..
                    inc       <$13                                              ; 0062: e6 13        ..

_0064               anop
                    cmp       #'n'                                              ; 0064: c9 6e 00     .n.
                    bne       _0072                                             ; 0067: d0 09        ..
                    lda       #$0060                                            ; 0069: a9 60 00     .`.
                    tsb       <$1c                                              ; 006c: 04 1c        ..
                    tsb       <$1e                                              ; 006e: 04 1e        ..
                    bra       _0036                                             ; 0070: 80 c4        ..

_0072               anop
                    cmp       #'d'                                              ; 0072: c9 64 00     .d.
                    bne       _0085                                             ; 0075: d0 0e        ..
                    lda       <$05                                              ; 0077: a5 05        ..
                    cmp       #$000a                                            ; 0079: c9 0a 00     ...
                    bcc       _00cf                                             ; 007c: 90 51        .Q
                    cmp       #'d'                                              ; 007e: c9 64 00     .d.
                    bcc       _00b0                                             ; 0081: 90 2d        .-
                    bra       _008a                                             ; 0083: 80 05        ..

_0085               anop
                    cmp       #'3'                                              ; 0085: c9 33 00     .3.
                    bne       _00ab                                             ; 0088: d0 21        .!

_008a               anop
                    pha                                                         ; 008a: 48           H
                    pha                                                         ; 008b: 48           H
                    lda       <$05                                              ; 008c: a5 05        ..
                    pha                                                         ; 008e: 48           H
                    pea       |$0064                                            ; 008f: f4 64 00     .d.
;                    ldx       #$0b0b                                            ; 0092: a2 0b 0b     ...
;                    jsl       >$e10000                                          ; 0095: 22 00 00 e1  "...
                    _UDivide
                    plx                                                         ; 0099: fa           .
                    pla                                                         ; 009a: 68           h
                    sta       <$05                                              ; 009b: 85 05        ..
                    txa                                                         ; 009d: 8a           .
                    ora       #$0030                                            ; 009e: 09 30 00     .0.
                    sta       [<$09]                                            ; 00a1: 87 09        ..
                    inc       <$09                                              ; 00a3: e6 09        ..
                    bne       _00b0                                             ; 00a5: d0 09        ..
                    inc       <$0b                                              ; 00a7: e6 0b        ..
                    bra       _00b0                                             ; 00a9: 80 05        ..

_00ab               anop
                    cmp       #'2'                                              ; 00ab: c9 32 00     .2.
                    bne       _0100                                             ; 00ae: d0 50        .P

_00b0               anop
                    pha                                                         ; 00b0: 48           H
                    pha                                                         ; 00b1: 48           H
                    lda       <$05                                              ; 00b2: a5 05        ..
                    pha                                                         ; 00b4: 48           H
                    pea       |$000a                                            ; 00b5: f4 0a 00     ...
;                    ldx       #$0b0b                                            ; 00b8: a2 0b 0b     ...
;                    jsl       >$e10000                                          ; 00bb: 22 00 00 e1  "...
                    _UDivide
                    pla                                                         ; 00bf: 68           h
                    plx                                                         ; 00c0: fa           .
                    ora       #$0030                                            ; 00c1: 09 30 00     .0.
                    sta       [<$09]                                            ; 00c4: 87 09        ..
                    txa                                                         ; 00c6: 8a           .
                    inc       <$09                                              ; 00c7: e6 09        ..
                    bne       _00e0                                             ; 00c9: d0 15        ..
                    inc       <$0b                                              ; 00cb: e6 0b        ..
                    bra       _00e0                                             ; 00cd: 80 11        ..

_00cf               anop
                    pha                                                         ; 00cf: 48           H
                    pha                                                         ; 00d0: 48           H
                    lda       <$05                                              ; 00d1: a5 05        ..
                    pha                                                         ; 00d3: 48           H
                    pea       |$000a                                            ; 00d4: f4 0a 00     ...
;                    ldx       #$0b0b                                            ; 00d7: a2 0b 0b     ...
;                    jsl       >$e10000                                          ; 00da: 22 00 00 e1  "...
                    _UDivide
                    plx                                                         ; 00de: fa           .
                    pla                                                         ; 00df: 68           h

_00e0               anop
                    ora       #$0030                                            ; 00e0: 09 30 00     .0.
                    sta       [<$09]                                            ; 00e3: 87 09        ..
                    inc       <$09                                              ; 00e5: e6 09        ..
                    bne       _00eb                                             ; 00e7: d0 02        ..
                    inc       <$0b                                              ; 00e9: e6 0b        ..
_00eb               anop
                    sec                                                         ; 00eb: 38           8
                    lda       #$0001                                            ; 00ec: a9 01 00     ...
                    sbc       <$03                                              ; 00ef: e5 03        ..
                    sta       <$03                                              ; 00f1: 85 03        ..
_00f3               anop
                    ldx       <$1c                                              ; 00f3: a6 1c        ..
                    lda       <$03                                              ; 00f5: a5 03        ..
                    bne       _00fb                                             ; 00f7: d0 02        ..
                    ldx       <$1e                                              ; 00f9: a6 1e        ..

_00fb               anop
                    stx       <$05                                              ; 00fb: 86 05        ..
                    jmp       |_0036                                            ; 00fd: 4c 00 00     L..

_0100               anop
                    cmp       #'>'                                              ; 0100: c9 3e 00     .>.
                    bne       _0139                                             ; 0103: d0 34        .4
                    lda       [<$11]                                            ; 0105: a7 11        ..
                    and       #$00ff                                            ; 0107: 29 ff 00     )..
                    sta       <$01                                              ; 010a: 85 01        ..
                    clc                                                         ; 010c: 18           .
                    lda       <$11                                              ; 010d: a5 11        ..
                    adc       #$0001                                            ; 010f: 69 01 00     i..
                    sta       <$11                                              ; 0112: 85 11        ..
                    lda       <$13                                              ; 0114: a5 13        ..
                    adc       #$0000                                            ; 0116: 69 00 00     i..
                    sta       <$13                                              ; 0119: 85 13        ..
                    lda       <$05                                              ; 011b: a5 05        ..
                    cmp       <$01                                              ; 011d: c5 01        ..
                    beq       _012d                                             ; 011f: f0 0c        ..
                    bcc       _012d                                             ; 0121: 90 0a        ..
                    lda       [<$11]                                            ; 0123: a7 11        ..
                    and       #$00ff                                            ; 0125: 29 ff 00     )..
                    clc                                                         ; 0128: 18           .
                    adc       <$05                                              ; 0129: 65 05        e.
                    sta       <$05                                              ; 012b: 85 05        ..

_012d               anop
                    inc       <$11                                              ; 012d: e6 11        ..
                    beq       _0134                                             ; 012f: f0 03        ..
                    jmp       |_0036                                            ; 0131: 4c 00 00     L..

_0134               anop
                    inc       <$13                                              ; 0134: e6 13        ..
                    jmp       |_0036                                            ; 0136: 4c 00 00     L..

_0139               anop
                    cmp       #'+'                                              ; 0139: c9 2b 00     .+.
                    bne       _0150                                             ; 013c: d0 12        ..
                    lda       [<$11]                                            ; 013e: a7 11        ..
                    and       #$00ff                                            ; 0140: 29 ff 00     )..
                    clc                                                         ; 0143: 18           .
                    adc       <$05                                              ; 0144: 65 05        e.
                    sta       <$05                                              ; 0146: 85 05        ..
                    inc       <$11                                              ; 0148: e6 11        ..
                    bne       _0155                                             ; 014a: d0 09        ..
                    inc       <$13                                              ; 014c: e6 13        ..
                    bra       _0155                                             ; 014e: 80 05        ..

_0150               anop
                    cmp       #'.'                                              ; 0150: c9 2e 00     ...
                    bne       _017d                                             ; 0153: d0 28        .(

_0155               anop
                    lda       <$05                                              ; 0155: a5 05        ..
                    bne       _0163                                             ; 0157: d0 0a        ..
                    cmp       #$0004                                            ; 0159: c9 04 00     ...
                    beq       _0163                                             ; 015c: f0 05        ..
                    cmp       #$000a                                            ; 015e: c9 0a 00     ...
                    bne       _016d                                             ; 0161: d0 0a        ..

_0163               anop
                    lda       <$03                                              ; 0163: a5 03        ..
                    ora       UP                                                ; 0165: 0d 00 00     ...
                    ora       UP+$0002                                          ; 0168: 0d 00 00     ...
                    beq       _016d                                             ; 016b: f0 00        ..

_016d               anop
                    lda       <$05                                              ; 016d: a5 05        ..
                    sta       [<$09]                                            ; 016f: 87 09        ..
                    inc       <$09                                              ; 0171: e6 09        ..
                    beq       _0178                                             ; 0173: f0 03        ..
                    jmp       |_00eb                                            ; 0175: 4c 00 00     L..

_0178               anop
                    inc       <$0b                                              ; 0178: e6 0b        ..
                    jmp       |_00eb                                            ; 017a: 4c 00 00     L..

_017d               anop
                    cmp       #'r'                                              ; 017d: c9 72 00     .r.
                    bne       _018a                                             ; 0180: d0 08        ..
                    lda       #$0001                                            ; 0182: a9 01 00     ...
                    sta       <$03                                              ; 0185: 85 03        ..
                    jmp       |_00f3                                            ; 0187: 4c 00 00     L..

_018a               anop
                    cmp       #'i'                                              ; 018a: c9 69 00     .i.
                    bne       _0198                                             ; 018d: d0 09        ..
                    inc       <$1c                                              ; 018f: e6 1c        ..
                    inc       <$1e                                              ; 0191: e6 1e        ..
                    inc       <$05                                              ; 0193: e6 05        ..
                    jmp       |_0036                                            ; 0195: 4c 00 00     L..

_0198               anop
                    cmp       #'%'                                              ; 0198: c9 25 00     .%.
                    bne       _01ab                                             ; 019b: d0 0e        ..
                    sta       [<$09]                                            ; 019d: 87 09        ..
                    inc       <$09                                              ; 019f: e6 09        ..
                    beq       _01a6                                             ; 01a1: f0 03        ..
                    jmp       |_0036                                            ; 01a3: 4c 00 00     L..

_01a6               anop
                    inc       <$0b                                              ; 01a6: e6 0b        ..
                    jmp       |_0036                                            ; 01a8: 4c 00 00     L..

_01ab               anop
                    cmp       #'B'                                              ; 01ab: c9 42 00     .B.
                    bne       _01d2                                             ; 01ae: d0 22        ."
                    pha                                                         ; 01b0: 48           H
                    pha                                                         ; 01b1: 48           H
                    lda       <$05                                              ; 01b2: a5 05        ..
                    pha                                                         ; 01b4: 48           H
                    pea       |$000a                                            ; 01b5: f4 0a 00     ...
;                    ldx       #$0b0b                                            ; 01b8: a2 0b 0b     ...
;                    jsl       >$e10000                                          ; 01bb: 22 00 00 e1  "...
                    _UDivide
                    pla                                                         ; 01bf: 68           h
                    plx                                                         ; 01c0: fa           .
                    asl       a                                                 ; 01c1: 0a           .
                    asl       a                                                 ; 01c2: 0a           .
                    asl       a                                                 ; 01c3: 0a           .
                    asl       a                                                 ; 01c4: 0a           .
                    clc                                                         ; 01c5: 18           .
                    adc       <$05                                              ; 01c6: 65 05        e.
                    sta       <$05                                              ; 01c8: 85 05        ..
                    txa                                                         ; 01ca: 8a           .
                    adc       <$05                                              ; 01cb: 65 05        e.
                    sta       <$05                                              ; 01cd: 85 05        ..
                    jmp       |_0036                                            ; 01cf: 4c 00 00     L..

_01d2               anop
                    cmp       #'D'                                              ; 01d2: c9 44 00     .D.
                    bne       _01e9                                             ; 01d5: d0 12        ..
                    lda       <$05                                              ; 01d7: a5 05        ..
                    and       #$000f                                            ; 01d9: 29 0f 00     )..
                    asl       a                                                 ; 01dc: 0a           .
                    sta       <$01                                              ; 01dd: 85 01        ..
                    lda       <$05                                              ; 01df: a5 05        ..
                    sec                                                         ; 01e1: 38           8
                    sbc       <$01                                              ; 01e2: e5 01        ..
                    sta       <$05                                              ; 01e4: 85 05        ..
                    jmp       |_0036                                            ; 01e6: 4c 00 00     L..

_01e9               anop
                    bra       _01f5                                             ; 01e9: 80 0a        ..

_01eb               anop
                    lda       #_021a                                            ; 01eb: a9 00 00     ...
                    sta       <$0d                                              ; 01ee: 85 0d        ..
                    lda       #_021a|-$0010                                     ; 01f0: a9 00 00     ...
                    sta       <$0f                                              ; 01f3: 85 0f        ..
_01f5               anop
                    ldy       <$0d                                              ; 01f5: a4 0d        ..
                    ldx       <$0f                                              ; 01f7: a6 0f        ..
                    lda       <$16                                              ; 01f9: a5 16        ..
                    sta       <$1e                                              ; 01fb: 85 1e        ..
                    lda       <$15                                              ; 01fd: a5 15        ..
                    sta       <$1d                                              ; 01ff: 85 1d        ..
                    pld                                                         ; 0201: 2b           +
                    tsc                                                         ; 0202: 3b           ;
                    clc                                                         ; 0203: 18           .
                    adc       #$001c                                            ; 0204: 69 1c 00     i..
                    tcs                                                         ; 0207: 1b           .
                    tya                                                         ; 0208: 98           .
                    rtl                                                         ; 0209: 6b           k

_020a               anop
                    dc c'OOPS!',h'00'

_0210               anop
                    ds        10                                                ; 0210:

_021a               anop
                    ds        64                                                ; 021a:

                    end

                    case      on
                    longa     on
                    longi     on

tputs               start

                    using     ~TERMGLOBALS
                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$0006                                            ; 0002: e9 06 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    lda       <$0a                                              ; 0008: a5 0a        ..
                    ora       <$0c                                              ; 000a: 05 0c        ..
                    bne       _0011                                             ; 000c: d0 03        ..
                    jmp       |_0111                                            ; 000e: 4c 00 00     L..

_0011               anop
                    lda       <$10                                              ; 0011: a5 10        ..
                    sta       |_00cf+$0001                                      ; 0013: 8d 00 00     ...
                    sta       |_0109+$0001                                      ; 0016: 8d 00 00     ...
                    lda       <$11                                              ; 0019: a5 11        ..
                    sta       |_00cf+$0002                                      ; 001b: 8d 00 00     ...
                    sta       |_0109+$0002                                      ; 001e: 8d 00 00     ...
                    stz       <$05                                              ; 0021: 64 05        d.

_0023               anop
                    lda       [<$0a]                                            ; 0023: a7 0a        ..
                    and       #$00ff                                            ; 0025: 29 ff 00     )..
                    cmp       #$0030                                            ; 0028: c9 30 00     .0.
                    bcc       _004a                                             ; 002b: 90 1d        ..
                    cmp       #$003a                                            ; 002d: c9 3a 00     .:.
                    bcs       _004a                                             ; 0030: b0 18        ..
                    sta       <$03                                              ; 0032: 85 03        ..
                    lda       <$05                                              ; 0034: a5 05        ..
                    asl       a                                                 ; 0036: 0a           .
                    asl       a                                                 ; 0037: 0a           .
                    adc       <$05                                              ; 0038: 65 05        e.
                    asl       a                                                 ; 003a: 0a           .
                    adc       <$03                                              ; 003b: 65 03        e.
                    sbc       #$002f                                            ; 003d: e9 2f 00     ./.
                    sta       <$05                                              ; 0040: 85 05        ..
                    inc       <$0a                                              ; 0042: e6 0a        ..
                    bne       _0023                                             ; 0044: d0 dd        ..
                    inc       <$0c                                              ; 0046: e6 0c        ..
                    bra       _0023                                             ; 0048: 80 d9        ..

_004a               anop
                    lda       <$05                                              ; 004a: a5 05        ..
                    beq       _0055                                             ; 004c: f0 07        ..
                    asl       a                                                 ; 004e: 0a           .
                    asl       a                                                 ; 004f: 0a           .
                    adc       <$05                                              ; 0050: 65 05        e.
                    asl       a                                                 ; 0052: 0a           .
                    sta       <$05                                              ; 0053: 85 05        ..

_0055               anop
                    lda       [<$0a]                                            ; 0055: a7 0a        ..
                    and       #$00ff                                            ; 0057: 29 ff 00     )..
                    cmp       #$002e                                            ; 005a: c9 2e 00     ...
                    bne       _009c                                             ; 005d: d0 3d        .=
                    clc                                                         ; 005f: 18           .
                    lda       <$0a                                              ; 0060: a5 0a        ..
                    adc       #$0001                                            ; 0062: 69 01 00     i..
                    sta       <$0a                                              ; 0065: 85 0a        ..
                    lda       <$0c                                              ; 0067: a5 0c        ..
                    adc       #$0000                                            ; 0069: 69 00 00     i..
                    sta       <$0c                                              ; 006c: 85 0c        ..
                    lda       [<$0a]                                            ; 006e: a7 0a        ..
                    and       #$00ff                                            ; 0070: 29 ff 00     )..
                    cmp       #$0030                                            ; 0073: c9 30 00     .0.
                    bcc       _009c                                             ; 0076: 90 24        .$
                    cmp       #$003a                                            ; 0078: c9 3a 00     .:.
                    bcs       _009c                                             ; 007b: b0 1f        ..
                    sbc       #$002f                                            ; 007d: e9 2f 00     ./.
                    clc                                                         ; 0080: 18           .
                    adc       <$05                                              ; 0081: 65 05        e.
                    sta       <$05                                              ; 0083: 85 05        ..

_0085               anop
                    lda       [<$0a]                                            ; 0085: a7 0a        ..
                    and       #$00ff                                            ; 0087: 29 ff 00     )..
                    cmp       #$0030                                            ; 008a: c9 30 00     .0.
                    bcc       _009c                                             ; 008d: 90 0d        ..
                    cmp       #$003a                                            ; 008f: c9 3a 00     .:.
                    bcs       _009c                                             ; 0092: b0 08        ..
                    inc       <$0a                                              ; 0094: e6 0a        ..
                    bne       _0085                                             ; 0096: d0 ed        ..
                    inc       <$0c                                              ; 0098: e6 0c        ..
                    bra       _0085                                             ; 009a: 80 e9        ..

_009c               anop
                    cmp       #$002a                                            ; 009c: c9 2a 00     .*.
                    bne       _00c1                                             ; 009f: d0 20        . 
                    inc       <$0a                                              ; 00a1: e6 0a        ..
                    bne       _00a7                                             ; 00a3: d0 02        ..
                    inc       <$0c                                              ; 00a5: e6 0c        ..

_00a7               anop
                    lda       <$0e                                              ; 00a7: a5 0e        ..
                    beq       _00bf                                             ; 00a9: f0 14        ..
                    dec       a                                                 ; 00ab: 3a           :
                    beq       _00c1                                             ; 00ac: f0 13        ..
                    pha                                                         ; 00ae: 48           H
                    pha                                                         ; 00af: 48           H
                    lda       <$05                                              ; 00b0: a5 05        ..
                    pha                                                         ; 00b2: 48           H
                    lda       <$0e                                              ; 00b3: a5 0e        ..
                    pha                                                         ; 00b5: 48           H
;                    ldx       #$090b                                            ; 00b6: a2 0b 09     ...
;                    jsl       >$e10000                                          ; 00b9: 22 00 00 e1  "...
                    _Multiply
                    pla                                                         ; 00bd: 68           h
                    plx                                                         ; 00be: fa           .

_00bf               anop
                    sta       <$05                                              ; 00bf: 85 05        ..

_00c1               anop
                    lda       [<$0a]                                            ; 00c1: a7 0a        ..
                    and       #$00ff                                            ; 00c3: 29 ff 00     )..
                    beq       _00d5                                             ; 00c6: f0 0d        ..
                    pha                                                         ; 00c8: 48           H
                    inc       <$0a                                              ; 00c9: e6 0a        ..
                    bne       _00cf                                             ; 00cb: d0 02        ..
                    inc       <$0c                                              ; 00cd: e6 0c        ..
_00cf               anop
                    jsl       >$ffffff                                          ; 00cf: 22 ff ff ff  "...
                    bra       _00c1                                             ; 00d3: 80 ec        ..

_00d5               anop
                    lda       <$05                                              ; 00d5: a5 05        ..
                    beq       _0111                                             ; 00d7: f0 38        .8
                    lda       ospeed                                            ; 00d9: ad 00 00     ...
                    beq       _0111                                             ; 00dc: f0 33        .3
                    bmi       _0111                                             ; 00de: 30 31        01
                    cmp       #$000f                                            ; 00e0: c9 0f 00     ...
                    bcs       _0111                                             ; 00e3: b0 2c        .,
                    asl       a                                                 ; 00e5: 0a           .
                    tax                                                         ; 00e6: aa           .
                    lda       |tmspc10,x                                        ; 00e7: bd 00 00     ...
                    sta       <$01                                              ; 00ea: 85 01        ..
                    lsr       a                                                 ; 00ec: 4a           J
                    clc                                                         ; 00ed: 18           .
                    adc       <$05                                              ; 00ee: 65 05        e.
                    sta       <$05                                              ; 00f0: 85 05        ..
                    pha                                                         ; 00f2: 48           H
                    pha                                                         ; 00f3: 48           H
                    lda       <$05                                              ; 00f4: a5 05        ..
                    pha                                                         ; 00f6: 48           H
                    lda       <$01                                              ; 00f7: a5 01        ..
                    pha                                                         ; 00f9: 48           H
;                    ldx       #$0b0b                                            ; 00fa: a2 0b 0b     ...
;                    jsl       >$e10000                                          ; 00fd: 22 00 00 e1  "...
                    _UDivide
                    pla                                                         ; 0101: 68           h
                    sta       <$05                                              ; 0102: 85 05        ..
                    plx                                                         ; 0104: fa           .

_0105               anop
                    lda       #$0000                                            ; 0105: a9 00 00     ...
                    pha                                                         ; 0108: 48           H
_0109               anop
                    jsl       >$ffffff                                          ; 0109: 22 ff ff ff  "...
                    dec       <$05                                              ; 010d: c6 05        ..
                    bne       _0105                                             ; 010f: d0 f4        ..
_0111               anop
                    lda       <$08                                              ; 0111: a5 08        ..
                    sta       <$12                                              ; 0113: 85 12        ..
                    lda       <$07                                              ; 0115: a5 07        ..
                    sta       <$11                                              ; 0117: 85 11        ..
                    pld                                                         ; 0119: 2b           +
                    tsc                                                         ; 011a: 3b           ;
                    clc                                                         ; 011b: 18           .
                    adc       #$0010                                            ; 011c: 69 10 00     i..
                    tcs                                                         ; 011f: 1b           .
                    rtl                                                         ; 0120: 6b           k
tmspc10             anop
                    dc        i2'1, 2000, 1333, 909'
                    dc        i2'743, 666, 500, 333'
                    dc        i2'166, 83, 55, 41'
                    dc        i2'20, 10, 5, 1'
                    dc        i2'1, 1, 1, 1'
                    dc        i2'1, 1, 1, 1'

; 0121: 01 00 d0 07  ....
; 0125: 35 05 8d 03  5...
; 0129: e7 02 9a 02  ....
; 012d: f4 01 4d 01  ..M.
; 0131: a6 00 53 00  ..S.
; 0135: 37 00 29 00  7.).
; 0139: 14 00 0a 00  ....
; 013d: 05 00 01 00  ....
; 0141: 01 00 01 00  ....
; 0145: 01 00 01 00  ....
; 0149: 01 00 01 00  ....
; 014d: 01 00 01 00  ....
                    end

                    case      on
                    longa     on
                    longi     on

getenv              private

                    tsc                                                         ; 0000: 3b           ;
                    sec                                                         ; 0001: 38           8
                    sbc       #$000e                                            ; 0002: e9 0e 00     ...
                    tcs                                                         ; 0005: 1b           .
                    phd                                                         ; 0006: 0b           .
                    tcd                                                         ; 0007: 5b           [
                    stz       <$0b                                              ; 0008: 64 0b        d.
                    stz       <$0d                                              ; 000a: 64 0d        d.
                    sep       #$20                                              ; 000c: e2 20        . 
                    longa     off
                    ldy       #$0000                                            ; 000e: a0 00 00     ...

_0011               anop
                    lda       [<$12],y                                          ; 0011: b7 12        ..
                    beq       _0018                                             ; 0013: f0 03        ..
                    iny                                                         ; 0015: c8           .
                    bra       _0011                                             ; 0016: 80 f9        ..

_0018               anop
                    rep       #$20                                              ; 0018: c2 20        . 
                    longa     on
                    sty       <$05                                              ; 001a: 84 05        ..
                    iny                                                         ; 001c: c8           .
                    pea       |$0000                                            ; 001d: f4 00 00     ...
                    phy                                                         ; 0020: 5a           Z
                    jsl       >~NEW                                             ; 0021: 22 00 00 00  "...
                    sta       <$07                                              ; 0025: 85 07        ..
                    stx       <$09                                              ; 0027: 86 09        ..
                    sta       |_00ca                                            ; 0029: 8d 00 00     ...
                    stx       |_00ca+$0002                                      ; 002c: 8e 00 00     ...
                    ora       <$09                                              ; 002f: 05 09        ..
                    bne       _0036                                             ; 0031: d0 03        ..
                    jmp       |_00b5                                            ; 0033: 4c 00 00     L..

_0036               anop
                    sep       #$30                                              ; 0036: e2 30        .0
                    longa     off
                    longi     off
                    lda       <$05                                              ; 0038: a5 05        ..
                    sta       [<$07]                                            ; 003a: 87 07        ..
                    ldy       #$00                                              ; 003c: a0 00        ..

_003e               anop
                    lda       [<$12],y                                          ; 003e: b7 12        ..
                    beq       _0047                                             ; 0040: f0 05        ..
                    iny                                                         ; 0042: c8           .
                    sta       [<$07],y                                          ; 0043: 97 07        ..
                    bra       _003e                                             ; 0045: 80 f7        ..

_0047               anop
                    rep       #$30                                              ; 0047: c2 30        .0
                    longa     on
                    longi     on
                    pea       |$0000                                            ; 0049: f4 00 00     ...
                    pea       |$00ff                                            ; 004c: f4 ff 00     ...
                    jsl       >~NEW                                             ; 004f: 22 00 00 00  "...
                    sta       <$01                                              ; 0053: 85 01        ..
                    stx       <$03                                              ; 0055: 86 03        ..
                    sta       |_00ca+$0004                                      ; 0057: 8d 00 00     ...
                    stx       |_00ca+$0006                                      ; 005a: 8e 00 00     ...
                    ora       <$03                                              ; 005d: 05 03        ..
                    bne       _0064                                             ; 005f: d0 03        ..
                    jmp       |_00ad                                            ; 0061: 4c 00 00     L..

_0064               anop
                    _GET_VAR  _00ca
;                    jsl       >$e100a8                                          ; 0064: 22 a8 00 e1  "...
;                    dc        i1'$0b, $01'                                      ; 0068: 0b 01        ..
;                    dc        i4'_00ca'                                         ; 006a: 00 00 00 00  ....
                    lda       [<$01]                                            ; 006e: a7 01        ..
                    and       #$00ff                                            ; 0070: 29 ff 00     )..
                    bne       _0078                                             ; 0073: d0 03        ..
                    jmp       |_00a5                                            ; 0075: 4c 00 00     L..

_0078               anop
                    inc       a                                                 ; 0078: 1a           .
                    pea       |$0000                                            ; 0079: f4 00 00     ...
                    pha                                                         ; 007c: 48           H
                    jsl       >~NEW                                             ; 007d: 22 00 00 00  "...
                    sta       <$0b                                              ; 0081: 85 0b        ..
                    stx       <$0d                                              ; 0083: 86 0d        ..
                    ora       <$0d                                              ; 0085: 05 0d        ..
                    bne       _008c                                             ; 0087: d0 03        ..
                    jmp       |_00a5                                            ; 0089: 4c 00 00     L..

_008c               anop
                    sep       #$30                                              ; 008c: e2 30        .0
                    longa     off
                    longi     off
                    lda       [<$01]                                            ; 008e: a7 01        ..
                    tay                                                         ; 0090: a8           .

_0091               anop
                    cpy       #$00                                              ; 0091: c0 00        ..
                    beq       _009c                                             ; 0093: f0 07        ..
                    lda       [<$01],y                                          ; 0095: b7 01        ..
                    dey                                                         ; 0097: 88           .
                    sta       [<$0b],y                                          ; 0098: 97 0b        ..
                    bra       _0091                                             ; 009a: 80 f5        ..

_009c               anop
                    lda       [<$01]                                            ; 009c: a7 01        ..
                    tay                                                         ; 009e: a8           .
                    lda       #$00                                              ; 009f: a9 00        ..
                    sta       [<$0b],y                                          ; 00a1: 97 0b        ..
                    rep       #$30                                              ; 00a3: c2 30        .0
                    longa     on
                    longi     on

_00a5               anop
                    pei       <$03                                              ; 00a5: d4 03        ..
                    pei       <$01                                              ; 00a7: d4 01        ..
                    jsl       >~DISPOSE                                         ; 00a9: 22 00 00 00  "...
_00ad               anop
                    pei       <$09                                              ; 00ad: d4 09        ..
                    pei       <$07                                              ; 00af: d4 07        ..
                    jsl       >~DISPOSE                                         ; 00b1: 22 00 00 00  "...

_00b5               anop
                    ldy       <$0b                                              ; 00b5: a4 0b        ..
                    ldx       <$0d                                              ; 00b7: a6 0d        ..
                    lda       <$10                                              ; 00b9: a5 10        ..
                    sta       <$14                                              ; 00bb: 85 14        ..
                    lda       <$0f                                              ; 00bd: a5 0f        ..
                    sta       <$13                                              ; 00bf: 85 13        ..
                    pld                                                         ; 00c1: 2b           +
                    tsc                                                         ; 00c2: 3b           ;
                    clc                                                         ; 00c3: 18           .
                    adc       #$0012                                            ; 00c4: 69 12 00     i..
                    tcs                                                         ; 00c7: 1b           .
                    tya                                                         ; 00c8: 98           .
                    rtl                                                         ; 00c9: 6b           k
_00ca               anop
                    ds        8                                                 ; 00ca:
                    end

                    case      on
                    longa     on
                    longi     on

~TERMGLOBALS        privdata

pathbuf             ds        512                                               ; 0000:
pathvec             ds        128                                               ; 0200:
pvec                ds        4                                                 ; 0280:
tbuf                ds        4                                                 ; 0284:
                    end

                    case      on
                    longa     on
                    longi     on

~GLOBALS            start

ospeed              entry
                    dc        i2'$0000'                                         ; 0000: 00 00        ..

PC                  entry
                    dc        i2'$0000'                                         ; 0002: 00 00        ..

UP                  entry
                    dc        i4'$00000000'                                     ; 0004: 00 00 00 00  ....

BC                  entry
                    dc        i4'$00000000'                                     ; 0008: 00 00 00 00  ....
                    end

