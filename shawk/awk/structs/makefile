SHELL := bash
AWK := awk
SMPG := $(AWK) -f ../smpg/smpg.awk

.PHONY: help
help:
	@echo 'make all     - structs + sure'
	@echo 'make sure    - test + check'
	@echo 'make structs - compile structs'
	@echo 'make test    - run tests'
	@echo 'make testv   - run tests verbosely'
	@echo 'make help    - this screen'

.PHONY: all
all : structs sure

.PHONY: structs
structs: structs.awk
structs.awk: src/_structs.awk src/_gen.awk src/_doc.awk
	cat $^ > $@ && chmod +x $@

src/_structs.awk: structs.smpg
	$(SMPG) $^ > $@

.PHONY: sure
sure:
	diff <(./tests/run-tests.sh x | grep -E '^test_[^ ]+' | sort) ./tests/expected_tests.txt

.PHONY: test
test:
	cd tests/; ./run-tests.sh

.PHONY: testv
testv:
	cd tests/; ./run-tests.sh x
