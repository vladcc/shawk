SHELL := bash
AWK := awk

PARSER := _parser.awk
TARGET := ../parts/$(PARSER)

.PHONY: help
help:
	@echo 'make target - parser + sure + place in parent dir'
	@echo 'make parser - compile the parser'
	@echo 'make sure   - test + check'
	@echo 'make test   - run tests'
	@echo 'make testv  - run verbose tests'
	@echo 'make help   - this screen'

.PHONY: target
target: parser $(TARGET)

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(AWK) -f $(PARSER) && $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | sort | diff /dev/stdin $(EXP_TESTS)
# </tests>
$(TARGET) : $(PARSER)
	$(RUN_SURE) && cp -v $(PARSER) $(TARGET)

.PHONY: parts
parts:
	pushd ./lexer && $(MAKE) target && popd && \
	pushd ./prs   && $(MAKE) target && popd && \
	pushd ./ast   && $(MAKE) target && popd

.PHONY: parser
parser: parts $(PARSER)

PARTS := parts/_lexer.awk
PARTS += parts/_prs.awk
PARTS += parts/_ast.awk
PARTS += parts/_sym_tbl.awk
PARTS += parts/_misc.awk
$(PARSER) : $(PARTS)
	(echo "# <parser>"; cat $^; echo "# </parser>") > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
