SHELL := bash
AWK := awk

PRJ_DIR := ../../..

TO_C := rdpg-to-c.awk
TARGET := $(PRJ_DIR)/$(TO_C)

.PHONY: help
help:
	@echo 'make target - build + sure + place in project dir'
	@echo 'make build  - parts + to-c'
	@echo 'make to-c   - compile to-c from its parts'
	@echo 'make parts  - build the parts of to-c'
	@echo 'make sure   - test + make sure all tests run'
	@echo 'make test   - run tests'
	@echo 'make testv  - run verbose tests'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: parts to-c

# <tests>
TEST_DIR   := ./test-base
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := ../tests/run-tests.sh ../to-c/test-base/src.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^_?test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>
$(TARGET): $(TO_C)
	$(RUN_SURE) && cp -v $(TO_C) $(TARGET) && chmod +x $(TARGET)

.PHONY: parts
parts:
	pushd ./enum && $(MAKE) target && popd

.PHONY: to-c
to-c: $(TO_C)

PARTS := parts/_to_c.awk
PARTS += parts/_enum.awk
PARTS += ../common/_parser.awk
PARTS += ../common/_main.awk
PARTS += ../../../../awklib/src/awklib_read.awk
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
