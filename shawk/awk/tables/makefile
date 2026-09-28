SHELL := bash
AWK := awk
SMPG := $(AWK) -f ../smpg/smpg.awk

.PHONY: help
help:
	@echo 'make all     - target'
	@echo 'make target  - build + sure'
	@echo 'make build   - tables'
	@echo 'make tables  - compile tables'
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
# </tests>

.PHONY: all
all: target

.PHONY: target
target: build sure

.PHONY: build
build: tables

.PHONY: tables
tables: tables.awk
tables.awk: src/_tables_gen.awk src/_tables_usr.awk src/_doc.awk
	cat $^ > $@ && chmod +x $@

src/_tables_gen.awk: tables.smpg
	$(SMPG) $^ > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_TESTSV) | grep '^test_' | sort -u > $(PERF_TESTS)
	diff $(PERF_TESTS) $(EXP_TESTS)
