SHELL  := bash
AWK    := awk
SMPG   := $(AWK) -f ../smpg/smpg.awk
TABLES := $(AWK) -f ./tables.awk

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

SRC_DIR := ./src
TABLES_SMPG   := tables.smpg
TABLES_TABLES := tables.tables

TABLES_SMPG_AWK   := $(SRC_DIR)/_tables_smpg.awk
TABLES_TABLES_AWK := $(SRC_DIR)/_tables_tables.awk
TABLES_USR_AWK    := $(SRC_DIR)/_tables_usr.awk
TABLES_DOC_AWK    := $(SRC_DIR)/_doc.awk

TABLES_AWK     := tables.awk
TABLES_AWK_DEP := $(TABLES_SMPG_AWK)
TABLES_AWK_DEP += $(TABLES_TABLES_AWK)
TABLES_AWK_DEP += $(TABLES_USR_AWK)
TABLES_AWK_DEP += $(TABLES_DOC_AWK)

.PHONY: all
all: target

.PHONY: target
target: build sure

.PHONY: build
build: tables

.PHONY: tables
tables: $(TABLES_AWK)
$(TABLES_AWK): $(TABLES_AWK_DEP)
	cat $^ > $@ && chmod +x $@

$(TABLES_SMPG_AWK): $(TABLES_SMPG)
	$(SMPG) $^ > $@

$(TABLES_TABLES_AWK): $(TABLES_TABLES)
	$(TABLES) $^ > $@

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
