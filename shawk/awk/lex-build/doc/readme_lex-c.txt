lex-c.awk -- lex-build back end for C

I. C Lexer Overview

The C lexer is very simple. The focus is on performance and readability. It
achieves that by adhering to the following restrictions:
0. Favor code over memory.
1. Favor static inline functions over macros. This also means compiling with
function inlining makes a huge difference.
2. Use only the standard library.
3. No dynamic memory allocation.
4. No regex.

The user has to provide the lexer with the following:
1. A function which returns a char buffer with text to read. The lexer is input
agnostic. It doesn't know where the input comes from, it doesn't even know how
long the it is. The user is free to implement buffering strategies as they
please.

2. A buffer which serves as write space for the lexer. This space is manipulated
by the lex_save_begin(), lex_save_ch(), and lex_save_end() functions. They zero
out the space, save the current character, and terminate the saved string,
respectively. This is how the user can use the lexer to read patterns like
numbers and identifiers.

3. Callbacks for each specified function action from the lexer's input
description. E.g. if you want to read an identifier when the lexer encounters
a letter, the user provides a function which uses lex_read_ch(), lex_peek_ch(),
lex_save*(), etc. to save all consecutive letters in the lexer write buffer.

4. A function which gets called when the lexer encounters an unknown character.

All functions which have to be provided by the user have a 'lex_usr_' prefix.

The actual lexing revolves around two functions:
lex_next(), which returns the next token from the input, and
lex_keyword_or_base(). lex_keyword_or_base() is called when the user needs to
distinguish between an id and a keyword. The function looks at the lexer's
write buffer and figures out if it's looking at a keyword, and if yes which one,
or not. One of the arguments is a default value (a 'base') which gets returned
if what's in the buffer is not a keyword.

The keyword lookup is critical for performance. Two strategies are used:
1. Optimized binary search. The optimization consists of restricting the number
of keywords bsearch() needs to look at. This results in work <= compared to
hashing.

2. A literal if - else if tree which checks the string character by character.
This is as if you're trying to recognize "abc" by doing:
...
if ('a' == next_ch())
	if ('b' == next_ch())
		if ('c' == next_ch())
...
It's usually faster that bsearch(), doesn't produce extra function calls, but
could result in a lot of code if there are many keywords.

Which approach the lexer uses can be specified with the Keywords flag, e.g.:
.. | awk -f lex-c.awk -vKeywords=ifs
or
.. | awk -f lex-c.awk -vKeywords=bsearch
The default value is bsearch.


II. Performance

I decided to see how the above strategy would fare against flex. Not to put down
flex in any way - flex is a really amazing tool. That's why you'd want to
compare against it. The results, however, are surprising considering how simple
the lex_* implementations are in comparison.

I measured a flex with compressed tables (the default), flex with full tables
(the fastest option available, as far as I know), a lex-c lexer using binary
search, and a lex-c lexer using ifs. The input is a subset of C single and multi
character tokens, all 32 C keywords, integer constants, ids, and white space all
shuffled in a 5.9 mb file. When compiled with optimizations, lex_* are always
faster than default flex. On the i5 below, lex_ifs is consistently a bit faster
than full flex. Without optimizations, lex_* tend to be close to compressed
flex - slower on some systems, faster on others. All in all there appears to
always be some lex_* and flex* combination with very similar performance on this
type of basic input. 

1. Length:
--------------------------------------------------------------------------------
$ wc -l ./c-vs-flex/lex.h ./c-vs-flex/lex_bsearch.c 
  164 ./c-vs-flex/lex.h
  448 ./c-vs-flex/lex_bsearch.c
  612 total

$ wc -l ./c-vs-flex/lex.h ./c-vs-flex/lex_ifs.c 
  164 ./c-vs-flex/lex.h
  963 ./c-vs-flex/lex_ifs.c
 1127 total

$ wc -l ./c-vs-flex/flex.c
2400 ./c-vs-flex/flex.c

$ wc -l ./c-vs-flex/flex.full.c
5428 ./c-vs-flex/flex.full.c
--------------------------------------------------------------------------------
A pretty significant difference. flex output is very table heavy and it
implements its own input handling, so that makes sense. flex.full uses a lot
more tables than vanilla flex.

2. Timing:
All lexers read the file in 8kb chunks. The timing is done in silent mode, i.e.
the lexers only process the file but do not output anything. The final value is
the median out of 51 runs.

2.1. Intel

Linux 5.4.0-73-generic
gcc (Ubuntu 10.2.0-5ubuntu1~20.04) 10.2.0
Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz

No optimizations:
--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

for n in $(seq 1 51); \
do ./flex.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.099854 sec

for n in $(seq 1 51); \
do ./flex.full.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.072045 sec

for n in $(seq 1 51); \
do ./lex_bsearch.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.112468 sec

for n in $(seq 1 51); \
do ./lex_ifs.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.109493 sec
--------------------------------------------------------------------------------
Here lex_* are expected to be slower - each lexer operation is a function call
and no functions have been inlined. Interestingly enough, though, they are still
pretty close to the flex with compressed tables. Flex with full tables is the
fastest one, which makes sense.

-O3:
--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

for n in $(seq 1 51); \
do ./flex.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.058767 sec

for n in $(seq 1 51); \
do ./flex.full.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.035657 sec

for n in $(seq 1 51); \
do ./lex_bsearch.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.035029 sec

for n in $(seq 1 51); \
do ./lex_ifs.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.032499 sec
--------------------------------------------------------------------------------
This is where it gets interesting. Both lex_ifs and lex_bsearch turn out
consistently faster than full flex.

2.2. ARM (Raspberry PI 3B)

Linux 4.19.66-v7+
gcc (Raspbian 6.3.0-18+rpi1+deb9u1) 6.3.0 20170516
ARMv7 Processor rev 4 (v7l)

No optimizations:
--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

for n in $(seq 1 51); \
do ./flex.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.760939 sec

for n in $(seq 1 51); \
do ./flex.full.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.370874 sec

for n in $(seq 1 51); \
do ./lex_bsearch.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.693551 sec

for n in $(seq 1 51); \
do ./lex_ifs.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.672709 sec
--------------------------------------------------------------------------------
Here compressed flex is the weakest one, even with all the function calls in
lex_*

-O3:
--------------------------------------------------------------------------------
$ ls -lh ./big_file.txt | awk '{print $5,$NF}'
5.9M ./big_file.txt

for n in $(seq 1 51); \
do ./flex.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.384480 sec

for n in $(seq 1 51); \
do ./flex.full.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.174035 sec

for n in $(seq 1 51); \
do ./lex_bsearch.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.215173 sec

for n in $(seq 1 51); \
do ./lex_ifs.bin big_file.txt; done | sort -n -k1,1 | awk 'FNR==26'
0.194506 sec
--------------------------------------------------------------------------------
And here lex_ifs is about as much slower than flex.full as it is faster on the
i5. Compressed flex is still by far the slowest one.
