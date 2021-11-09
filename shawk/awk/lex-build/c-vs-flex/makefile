CC=gcc
SHELL=/bin/bash
AWK=awk

FLEX_BINS=flex.bin flex.full.bin
LEX_BINS=lex_bsearch.bin lex_ifs.bin
FILE=big_file.txt

override CFLAGS+=-Wall

.PHONY: help
help:
	@echo make all            - makes, checks, and tests flex vs lex.c
	@echo make all CFLAGS=-O3 - like above but with optimizations
	@echo make awk            - makes, checks, and times the awk implementation
	@echo make clean          - remove binaries

all: lexers input confirm tests

confirm: lexers input
	diff -q <(./flex.bin $(FILE) x) <(./flex.full.bin $(FILE) x)
	diff -q <(./flex.bin $(FILE) x) <(./lex_bsearch.bin $(FILE) x)
	diff -q <(./flex.bin $(FILE) x) <(./lex_ifs.bin $(FILE) x)
	
tests: lexers input test_all

test_all: test_flex test_flex_full test_bsearch test_ifs

test_flex: flex.bin $(FILE)
	for n in $$(seq 1 51); \
	do ./flex.bin $(FILE); done | sort -n -k1,1 | awk 'FNR==26'

test_flex_full: flex.full.bin $(FILE)
	for n in $$(seq 1 51); \
	do ./flex.full.bin $(FILE); done | sort -n -k1,1 | awk 'FNR==26'

test_ifs: lex_ifs.bin $(FILE)
	for n in $$(seq 1 51); \
	do ./lex_ifs.bin $(FILE); done | sort -n -k1,1 | awk 'FNR==26'

test_bsearch: lex_bsearch.bin $(FILE)
	for n in $$(seq 1 51); \
	do ./lex_bsearch.bin $(FILE); done | sort -n -k1,1 | awk 'FNR==26'

awk: flex.bin ./awk/inc_lex.awk $(FILE)
	diff -q <(./flex.bin $(FILE) x) \
	<($(AWK) -f ./awk/inc_lex.awk -f ./awk/lex.awk $(FILE) x)
	time $(AWK) -f ./awk/inc_lex.awk -f ./awk/lex.awk $(FILE)
	
lexers: $(FLEX_BINS) $(LEX_BINS)

input: $(FILE)

big_file.txt:
	unzip -o big_file.zip

lex_bsearch.c: lex.lb
	bash ./generate-lex.sh bsearch
	
lex_ifs.c: lex.lb
	bash ./generate-lex.sh ifs
	
lex_bsearch.bin: lex_bsearch.c lex_main.c
	$(CC) lex_bsearch.c lex_main.c -o lex_bsearch.bin $(CFLAGS)

lex_ifs.bin: lex_ifs.c lex_main.c
	$(CC) lex_ifs.c lex_main.c -o lex_ifs.bin $(CFLAGS)

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
	rm -f $(FLEX_BINS) $(LEX_BINS) big_file.txt
