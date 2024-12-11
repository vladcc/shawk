SHELL := bash
AWK := awk

LEXER := _lexer.awk
TARGET := ../parts/$(LEXER)

.PHONY: help
help:
	@echo 'make target - lexer + sure + place in parent dir'
	@echo 'make lexer  - compile the lexer'
	@echo 'make sure   - test + check'
	@echo 'make test   - run tests'
	@echo 'make testv  - verbose tests'
	@echo 'make help   - this screen'

.PHONY: target
target: $(TARGET)

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(AWK) -f $(LEXER) && $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | sort | diff /dev/stdin $(EXP_TESTS)
# </tests>
$(TARGET): $(LEXER)
	$(RUN_SURE) && cp -v $(LEXER) $(TARGET)

.PHONY: lexer
lexer: $(LEXER)

$(LEXER): parts/$(LEXER) ../../../common/_rdpg_ir.awk
	(echo "# <lexer>"; cat $^; echo "# </lexer>") > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
