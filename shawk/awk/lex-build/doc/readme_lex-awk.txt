lex-awk.awk -- lex-build back end for awk

I. AWK Lexer Overview

The strategy for this lexer is character classification. It chooses table
look-up over regex. The user provides all lex_usr_*() functions specified by the
comments at the beginning of the generated file. Two of them have to always
exist: lex_usr_get_line(), and lex_usr_on_unknown_ch(). They return the next
input line and perform an action when an unknown character is encountered,
respectively. Each function call action becomes a lex_usr_*() function as well.
Reading patterns is done by the user, character by character, pretty much like
you would in C. This provides the same level of flexibility as you'd have in C.


II. Performance

It's interesting to compare how the different awk implementations fare against
each other. I compare gawk, mawk, and original-awk first on Intel, then on ARM.
The awk lexer recognizes a subset of C tokens, all C keywords, integer
constants, ids, and white space. It reads a ~6mb file line per line. Its output
is the same as the output of an equivalent flex lexer, i.e. it's correct. Timing
is done in silent mode, i.e. the lexer only processes the file and does not
print what it reads.

1. Intel

Linux 5.4.0-84-generic
Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz

--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

# GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
$ time gawk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real    0m4.919s
user    0m4.918s
sys 0m0.000s

# mawk 1.3.4 20200120
$ time mawk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real    0m2.929s
user    0m2.925s
sys 0m0.004s

# awk version 20121220
$ time original-awk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real    0m12.315s
user    0m12.310s
sys 0m0.004s
--------------------------------------------------------------------------------
Given that each character operation becomes a string operation and the amount of
function calls and hash table look ups, gawk runs at a respectable less than a
second per mb. mawk is quite a bit faster, and original-awk is way behind,
taking more than two seconds per mb.

2. ARM (Raspberry PI 3B)

Linux rpi 4.19.66-v7+
ARMv7 Processor rev 4 (v7l)

--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

# GNU Awk 4.1.4, API: 1.1 (GNU MPFR 3.1.5, GNU MP 6.1.2)
$ time gawk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real	0m32.743s
user	0m32.706s
sys	0m0.030s

# mawk 1.3.3 Nov 1996, Copyright (C) Michael D. Brennan
$ time mawk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real	0m13.439s
user	0m13.428s
sys	0m0.010s

# awk version 20121220
$ time original-awk -f ./awk/inc_lex.awk -f ./awk/lex.awk big_file.txt

real	1m53.053s
user	1m53.034s
sys	0m0.010s
--------------------------------------------------------------------------------
The only bearable performance here is that of mawk with ~two seconds per mb - as
much as original-awk on i5. gawk is proportionately slower here in relation to
mawk than on the i5, and original-awk, well... works.
