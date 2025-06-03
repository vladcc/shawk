SHELL := bash
AWK := awk

SYNC := _sync.awk
TARGET := ../parts/$(SYNC)

.PHONY: help
help:
	@echo 'make target - build + sure + place in parent dir'
	@echo 'make build  - sync'
	@echo 'make sync   - compile sync'
	@echo 'make sure   - make sure all tests run'
	@echo 'make test   - run tests'
	@echo 'make testv  - run tests verbosely'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: sync

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>
$(TARGET): $(SYNC)
	$(RUN_SURE) && cp -v $(SYNC) $(TARGET)

.PHONY: sync
sync: $(SYNC)

PARTS := parts/_sync.awk
PARTS += ../../common/_names.awk
$(SYNC): $(PARTS)
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
