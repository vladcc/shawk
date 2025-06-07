SHELL := bash
AWK := awk
SMPG := $(AWK) -f ../smpg/smpg.awk

.PHONY: help
help:
	@echo 'make target  - build + sure'
	@echo 'make build   - structs'
	@echo 'make structs - compile structs'
	@echo 'make sure    - test + make sure all tests run'
	@echo 'make test    - run tests'
	@echo 'make testv   - run tests verbosely'
	@echo 'make help    - this screen'

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS)
# </tests>

.PHONY: target
target: build sure

.PHONY: build
build: structs

.PHONY: structs
structs: structs.awk
structs.awk: src/_structs.awk src/_gen.awk src/_doc.awk
	cat $^ > $@ && chmod +x $@

src/_structs.awk: structs.smpg
	$(SMPG) $^ > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
