SHELL := bash
AWK := awk

CMPL := rdpg-comp.awk
TARGET := ../../$(CMPL)

.PHONY: help
help:
	@echo 'make target   - build + sure + place to project dir'
	@echo 'make build    - parts + compiler'
	@echo 'make compiler - compile the compiler from its parts'
	@echo 'make parts    - build the parts of the compiler'
	@echo 'make sure     - test + check'
	@echo 'make test     - run tests'
	@echo 'make testv    - run verbose tests'
	@echo 'make help     - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: parts compiler

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>
$(TARGET): $(CMPL)
	$(RUN_SURE) && cp -v $(CMPL) $(TARGET) && chmod +x $(TARGET)

.PHONY: parts
parts:
	pushd ./parser && $(MAKE) target && popd && \
	pushd ./sync   && $(MAKE) target && popd

.PHONY: compiler
compiler: $(CMPL)

PARTS := parts/_main.awk
PARTS += ../common/_rdpg_ir.awk
PARTS += ../common/_print.awk
PARTS += parts/_parser.awk
PARTS += parts/_checks.awk
PARTS += parts/_code_gen.awk
PARTS += parts/_doc.awk
PARTS += parts/_prs_tbl.awk
PARTS += parts/_sets.awk
PARTS += parts/_sync.awk
PARTS += ../../../awklib/src/awklib_prog.awk
PARTS += ../../../awklib/src/awklib_tabs.awk
PARTS += ../../../awklib/src/awklib_str_list.awk
PARTS += ../../../awklib/src/awklib_str_set.awk
$(CMPL): $(PARTS)
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
