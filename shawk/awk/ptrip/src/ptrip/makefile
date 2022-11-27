.PHONY: help
help:
	@echo 'make ptrip  - generates the whole ptrip'
	@echo 'make lexer  - generates the lexer'
	@echo 'make parser - generates the parser'
	@echo 'make test   - run tests'
	@echo 'make testv  - like test but verbose'
	@echo 'make sure   - make sure all tests run'
	@echo 'make help   - this screen'

LB_DIR = ../../../lex-build
LEX_LB = ./lexer/lexer.lb
LEX_AWK = ./lexer/ptrip_lexer.awk
LEX_USR = ./lexer/ptrip_lexer_usr.awk
LEX_HACK = ./lexer/ptrip_lexer_state_hack.awk
.PHONY: lexer
lexer: $(LEX_AWK)
$(LEX_AWK): $(LEX_LB)
	awk -f $(LB_DIR)/lex-first.awk $(LEX_LB) | awk -f $(LB_DIR)/lex-awk.awk > $@
	bash ./lexer/lexer-hack-check.sh	

RDPG_DIR = ../../../rdpg
RDPG_STRICT = 1
RDPG_OLVL = 5
PRS_RDPG = ./parser/parser.rdpg
PRS_AWK = ./parser/ptrip_parser.awk
PRS_USR = ./parser/ptrip_parser_usr.awk
.PHONY: parser
parser: $(PRS_AWK)
$(PRS_AWK): $(PRS_RDPG)
	awk -f $(RDPG_DIR)/rdpg.awk -vStrict=$(RDPG_STRICT) $(PRS_RDPG) | \
	awk -f $(RDPG_DIR)/rdpg-opt.awk -vOlvl=$(RDPG_OLVL) | \
	awk -f $(RDPG_DIR)/rdpg-to-awk -vTokCallPrefix="ptree_" | \
	sed 's/(    _arr)/()/g' | \
	sed 's/function ptree_fmt(/&    _arr/' | \
	sed 's/function ptree_include_fname(/&    _arr/' | \
	sed 's/function ptree_opt_subtree(/&    _arr/' | \
	sed 's/definitions>/parser_&/' > $@
# The seds above remove the _arr private variable which otherwise exists for
# each awk function. In this parser, however, it's needed only by two functions.
# All other instances of the variable will potentially lead to needless object
# creations.


TARGET_DIR = ../..
LIB_DIR = ../../../awklib/src
LIBS = $(LIB_DIR)/awklib_prog.awk
MAIN = ./_main.awk
PTRIP = $(TARGET_DIR)/ptrip.awk
PRS_ALL = $(PRS_AWK) $(PRS_USR)
LEX_ALL = $(LEX_AWK) $(LEX_USR) $(LEX_HACK)

.PHONY: ptrip
ptrip: $(PTRIP)
$(PTRIP): $(MAIN) $(PRS_ALL) $(LEX_ALL) $(LIBS)
	cat $^ > $@

.PHONY: sure
sure: SHELL := bash
sure:
	diff <($(MAKE) testv | grep '^test_' | sort) <(cat $(TEST_DIR)/run-tests.sh | grep 'function test_' | awk '{print $$NF}' | sort)

TEST_DIR = ./tests
.PHONY: test
test:
	bash $(TEST_DIR)/run-tests.sh

.PHONY: testv
testv:
	bash $(TEST_DIR)/run-tests.sh x
