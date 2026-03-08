CC=gcc
SHELL=/bin/bash
AWK=awk

ifdef G_AWK
AWK=$(G_AWK)
endif

FLEX_BINS=flex.bin flex.full.bin
LEX_BINS=lex_bsearch.bin lex_bsearch_bias.bin lex_ifs.bin lex_ifs_bias.bin
FILE_SML=small.almost.c
FILE_SML_ZIP=small.almost.c.zip
FILE_BIG=big.almost.c
FILE_BIG_ZIP=big.almost.c.zip

override CFLAGS+=-Wall

.PHONY: help
help:
	@echo make all            - makes, checks, and tests flex vs lex.c
	@echo make all CFLAGS=-O3 - like above but with optimizations
	@echo make awk            - makes, checks, and times the awk implementation
	@echo make clean          - remove binaries

all: lexers input confirm tests

confirm: lexers input
	diff -q <(./flex.bin $(FILE_SML) x) <(./flex.full.bin $(FILE_SML) x)
	diff -q <(./flex.bin $(FILE_SML) x) <(./lex_bsearch.bin $(FILE_SML) x)
	diff -q <(./flex.bin $(FILE_SML) x) <(./lex_ifs.bin $(FILE_SML) x)
	diff -q <(./flex.bin $(FILE_SML) x) <(./lex_bsearch_bias.bin $(FILE_SML) x)
	diff -q <(./flex.bin $(FILE_SML) x) <(./lex_ifs_bias.bin $(FILE_SML) x)

tests: lexers input test_all

test_all: test_flex test_flex_full test_bsr test_ifs test_bsr_bs test_ifs_bs

test_flex: flex.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./flex.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

test_flex_full: flex.full.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./flex.full.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

test_ifs: lex_ifs.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./lex_ifs.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

test_bsr: lex_bsearch.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./lex_bsearch.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

test_ifs_bs: lex_ifs_bias.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./lex_ifs_bias.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

test_bsr_bs: lex_bsearch_bias.bin $(FILE_BIG)
	for n in $$(seq 1 51); \
	do ./lex_bsearch_bias.bin $(FILE_BIG); done | sort -n -k1,1 | awk 'FNR==26'

awk: flex.bin ./awk/inc_lex.awk $(FILE_BIG)
	diff -q <(./flex.bin $(FILE_SML) x) \
	<($(AWK) -f ./awk/inc_lex.awk -f ./awk/lex.awk $(FILE_SML) x)
	time $(AWK) -f ./awk/inc_lex.awk -f ./awk/lex.awk $(FILE_BIG)

lexers: $(FLEX_BINS) $(LEX_BINS)

input: $(FILE_SML) $(FILE_BIG)

$(FILE_SML):
	unzip -o $(FILE_SML_ZIP)

$(FILE_BIG):
	unzip -o $(FILE_BIG_ZIP)

lex_bsearch.c: lex.lb
	bash ./generate-lex.sh bsearch

lex_ifs.c: lex.lb
	bash ./generate-lex.sh ifs

lex_bsearch.bin: lex_bsearch.c lex_main.c
	$(CC) lex_bsearch.c lex_main.c -o lex_bsearch.bin $(CFLAGS)

lex_ifs.bin: lex_ifs.c lex_main.c
	$(CC) lex_ifs.c lex_main.c -o lex_ifs.bin $(CFLAGS)

lex_bsearch_bias.bin: lex_bsearch_bias.c lex_main.c
	$(CC) lex_bsearch_bias.c lex_main.c -o lex_bsearch_bias.bin $(CFLAGS)

lex_ifs_bias.bin: lex_ifs_bias.c lex_main.c
	$(CC) lex_ifs_bias.c lex_main.c -o lex_ifs_bias.bin $(CFLAGS)

flex.bin: flex.c
	$(CC) flex.c -o flex.bin $(CFLAGS)

flex.full.bin: flex.full.c
	$(CC) flex.full.c -o flex.full.bin $(CFLAGS)

flex.c: flex.fl
	flex -o flex.c flex.fl

flex.full.c: flex.fl
	flex -f -o flex.full.c flex.fl

./awk/inc_lex.awk: ../lex-awk.awk lex.lb
	bash ./generate-lex.sh awk

.PHONY: clean
clean:
	rm -f $(FLEX_BINS) $(LEX_BINS) *.almost.c
