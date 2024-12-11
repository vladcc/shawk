SHELL := bash
AWK := awk

PRJ_DIR := ../../..

TO_C := rdpg-to-c.awk
TARGET := $(PRJ_DIR)/$(TO_C)

.PHONY: help
help:
	@echo 'make target - to-c + sure + place in project dir'
	@echo 'make to-c   - compile the to-c'
	@echo 'make sure   - test + check'
	@echo 'make test   - run tests'
	@echo 'make testv  - verbose tests'
	@echo 'make help   - this screen'

.PHONY: target
target: $(TARGET)

# <tests>
TEST_DIR   := ./test-base
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := ../tests/run-tests.sh ../to-c/test-base/src.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) | grep -E '^test_[^ ]+' > $(PERF_TESTS) && diff $(PERF_TESTS) $(EXP_TESTS)
# </tests>
$(TARGET): $(TO_C)
	$(RUN_SURE) && cp -v $(TO_C) $(TARGET) && chmod +x $(TARGET)

.PHONY: to-c
to-c: $(TO_C)

PARTS := parts/_to_c.awk
PARTS += ../common/_parser.awk
PARTS += ../common/_main.awk
$(TO_C): $(PARTS)
	cat $^ > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
