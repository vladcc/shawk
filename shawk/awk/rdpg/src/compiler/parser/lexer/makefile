SHELL := bash
AWK := awk

LEXER := _lexer.awk
TARGET := ../parts/$(LEXER)

.PHONY: help
help:
	@echo 'make target - build + sure + place in parent dir'
	@echo 'make build  - lexer'
	@echo 'make lexer  - compile the lexer'
	@echo 'make sure   - make sure all tests run'
	@echo 'make test   - run tests'
	@echo 'make testv  - run tests verbosely'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: lexer

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(AWK) -f $(LEXER) && $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>
$(TARGET): $(LEXER)
	$(RUN_SURE) && cp -v $(LEXER) $(TARGET)

.PHONY: lexer
lexer: $(LEXER)

LEX_GEN := parts/_lex_gen.awk
$(LEXER): $(LEX_GEN) parts/_lex_usr.awk
	(echo "# <lexer>" && cat $^ && echo "# </lexer>") > $@

LB_DIR := ../../../../../lex-build
LB_FIRST := $(AWK) -f $(LB_DIR)/lex-first.awk
LB_AWK := $(AWK) -f $(LB_DIR)/lex-awk.awk
$(LEX_GEN): parts/lex.lb
	$(LB_FIRST) $^ | $(LB_AWK) > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
