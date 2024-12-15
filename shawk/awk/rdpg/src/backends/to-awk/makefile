SHELL := bash
AWK := awk

PRJ_DIR := ../../..

TO_AWK := rdpg-to-awk.awk
TARGET := $(PRJ_DIR)/$(TO_AWK)

.PHONY: help
help:
	@echo 'make target - to-awk + sure + place in project dir'
	@echo 'make to-awk - compile the to-awk'
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
RUN_TESTS  := ../tests/run-tests.sh ../to-awk/test-base/src.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS)
# </tests>
$(TARGET): $(TO_AWK)
	$(RUN_SURE) && cp -v $(TO_AWK) $(TARGET) && chmod +x $(TARGET)

.PHONY: to-awk
to-awk: $(TO_AWK)

PARTS := parts/_to_awk.awk
PARTS += ../common/_parser.awk
PARTS += ../common/_main.awk
$(TO_AWK): $(PARTS)
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
