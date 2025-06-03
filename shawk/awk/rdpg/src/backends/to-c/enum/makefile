SHELL := bash
AWK := awk

ENUM := _enum.awk
TARGET := ../parts/$(ENUM)

.PHONY: help
help:
	@echo 'make target - build + sure + place in parent dir'
	@echo 'make build  - enum'
	@echo 'make enum   - compile the enum parser'
	@echo 'make sure   - test + make sure all tests run'
	@echo 'make test   - run tests'
	@echo 'make testv  - run tests verbosely'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: enum

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>

$(TARGET): $(ENUM)
	$(RUN_SURE) && cp -v $(ENUM) $(TARGET)

.PHONY: enum
enum: $(ENUM)

PARTS := parts/_enum.awk
$(ENUM): $(PARTS)
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
