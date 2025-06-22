SHELL := bash
AWK := awk

PARSER := _parser.awk
TARGET := ../common/$(PARSER)

.PHONY: help
help:
	@echo 'make target - build + sure + place in parent dir'
	@echo 'make build  - parts + parser'
	@echo 'make parser - compile the parser from its parts'
	@echo 'make parts  - build the parts of parser'
	@echo 'make sure   - test + make sure all tests run'
	@echo 'make test   - run tests'
	@echo 'make testv  - run verbose tests'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: parts parser

# <tests>
TEST_DIR   := ./tests
PERF_TESTS := $(TEST_DIR)/performed_tests.txt
EXP_TESTS  := $(TEST_DIR)/expected_tests.txt
RUN_TESTS  := $(AWK) -f $(PARSER) && $(TEST_DIR)/run-tests.sh
RUN_TESTSV := $(RUN_TESTS) x
RUN_SURE   := $(RUN_TESTSV) > $(PERF_TESTS) && grep -E '^test_[^ ]+' $(PERF_TESTS) | diff /dev/stdin $(EXP_TESTS) && rm $(PERF_TESTS)
# </tests>
$(TARGET) : $(PARSER)
	$(RUN_SURE) && cp -v $(PARSER) $(TARGET)

.PHONY: parts
parts:
	pushd ./lexer && $(MAKE) target && popd && \
	pushd ./prs   && $(MAKE) target && popd && \
	pushd ./ast   && $(MAKE) target && popd

.PHONY: parser
parser: $(PARSER)

PARTS := ../../../../awklib/src/awklib_tabs.awk
PARTS += ../../../../awklib/src/awklib_prog.awk
PARTS += ../../common/_print.awk
PARTS += ../../common/_names.awk
PARTS += parts/_bprint.awk
PARTS += parts/_lexer.awk
PARTS += parts/_prs.awk
PARTS += parts/_ast.awk
PARTS += parts/_misc.awk
$(PARSER) : $(PARTS)
	(echo "# <parser>" && cat $^ && echo "# </parser>") > $@

.PHONY: test
test:
	$(RUN_TESTS)

.PHONY: testv
testv:
	$(RUN_TESTSV)

.PHONY: sure
sure:
	$(RUN_SURE)
