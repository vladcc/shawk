.PHONY: help
help:
	@echo 'make ptrip  - generates the whole ptrip'
	@echo 'make lexer  - generates the lexer'
	@echo 'make parser - generates the parser'
	@echo 'make test   - run tests'
	@echo 'make testv  - like test but verbose'
	@echo 'make sure   - make sure all tests run'
	@echo 'make help   - this screen'

LB_DIR := ../../../lex-build
LEX_LB := ./lexer/lexer.lb
LEX_AWK := ./lexer/ptrip_lexer.awk
LEX_USR := ./lexer/ptrip_lexer_usr.awk
LEX_HACK := ./lexer/ptrip_lexer_state_hack.awk
.PHONY: lexer
lexer: $(LEX_AWK)
$(LEX_AWK): $(LEX_LB)
	awk -f $(LB_DIR)/lex-first.awk $(LEX_LB) | awk -f $(LB_DIR)/lex-awk.awk > $@
	bash ./lexer/lexer-hack-check.sh

RDPG_DIR := ../../../rdpg
PRS_GRAMMAR := ./parser/info-grammar.rdpg
PRS_AWK := ./parser/ptrip_parser.awk
PRS_USR := ./parser/ptrip_parser_usr.awk
.PHONY: parser
parser: $(PRS_AWK)
$(PRS_AWK): $(PRS_GRAMMAR)
	awk -f $(RDPG_DIR)/rdpg-comp.awk -v Sync=0 -v Imm=0 $(PRS_GRAMMAR) | \
	awk -f $(RDPG_DIR)/rdpg-to-awk -v TokHack=1 > $@

TARGET_DIR := ../..
LIB_DIR := ../../../awklib/src
LIBS := $(LIB_DIR)/awklib_prog.awk
MAIN := ./_main.awk
PTRIP := $(TARGET_DIR)/ptrip.awk
PRS_ALL := $(PRS_AWK) $(PRS_USR)
LEX_ALL := $(LEX_AWK) $(LEX_USR) $(LEX_HACK)

.PHONY: ptrip
ptrip: $(PTRIP)
$(PTRIP): $(MAIN) $(PRS_ALL) $(LEX_ALL) $(LIBS)
	cat $^ > $@

.PHONY: sure
sure: SHELL := bash
sure:
	diff <($(MAKE) testv | grep '^test_' | sort) <(cat $(TEST_DIR)/run-tests.sh | grep 'function test_' | awk '{print $$NF}' | sort)

TEST_DIR := ./tests
.PHONY: test
test:
	bash $(TEST_DIR)/run-tests.sh

.PHONY: testv
testv:
	bash $(TEST_DIR)/run-tests.sh x
