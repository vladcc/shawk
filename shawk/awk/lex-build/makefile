LIBS = ./src/common/_lb_lib_common.awk
LIBS += ../awklib/src/awklib_ch_num.awk
LIBS += ../awklib/src/awklib_array.awk
LIBS += ../awklib/src/awklib_vect.awk
LIBS += ../awklib/src/awklib_eos.awk
LIBS += ../awklib/src/awklib_tabs.awk
LIBS += ../awklib/src/awklib_prog.awk
LIBS += ../awklib/src/awklib_prefix_tree.awk

LEX_LIB = ./src/common/lb_lib.awk
LEX_FIRST = ./src/lex-first/_lex-first.awk
LEX_C = ./src/lex-c/_lex-c.awk
LEX_C_LIB = ../awklib/src/awklib_sort.awk ../awklib/src/awklib_bitwise.awk
LEX_AWK = ./src/lex-awk/_lex-awk.awk

ALL = lib lex-first lex-c lex-awk

.PHONY: help
help:
	@echo 'make all       - lib + lex*'
	@echo 'make allt      - all + test'
	@echo 'make test      - run tests'
	@echo 'make testv     - like test but verbose'
	@echo 'make lib       - generates the lex-build library'
	@echo 'make lex-first - generate lex-first.awk'
	@echo 'make lex-c     - generates the C translator'
	@echo 'make lex-awk   - generates the awk translator'
	@echo 'make regen     - regenerate lexer + c-vs-lex'
	@echo 'make help      - this screen'

.PHONY: regen
regen: all
	cd ./c-vs-flex && $(MAKE) -B all CFLAGS=-O3 && $(MAKE) awk && $(MAKE) clean

.PHONY: all
all: $(ALL)

.PHONY: allt
allt: all test

.PHONY: test
test:
	bash tests/run-tests.sh
	
.PHONY: testv
testv:
	bash tests/run-tests.sh x

.PHONY: clean
clean:
	rm -f lex*.awk $(LEX_LIB)
	
.PHONY: lex-first
lex-first: lex-first.awk
lex-first.awk: $(LEX_FIRST) $(LEX_LIB)
	cat $^ > $@

.PHONY: lex-c
lex-c: lex-c.awk
lex-c.awk: $(LEX_C) $(LEX_LIB) $(LEX_C_LIB)
	cat $^ > $@

.PHONY: lex-awk
lex-awk: lex-awk.awk
lex-awk.awk: $(LEX_AWK) $(LEX_LIB)
	cat $^ > $@

.PHONY: lib
lib: $(LEX_LIB)
$(LEX_LIB): $(LIBS)
	cat $^ > $@
