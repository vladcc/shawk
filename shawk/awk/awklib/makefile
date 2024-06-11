SHELL := bash

.PHONY: help
help:
	@echo 'make all   - does nothing; placeholder'
	@echo 'make sure  - confirms all tests run'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make help  - this screen'


.PHONY: all
all:

.PHONY: sure
sure:
	diff <(bash tests/run-tests.sh x | grep -oE 'test_awklib_[^.]+.awk|^test_[a-z_]+' | sort) ./tests/expected_tests.txt

.PHONY: test
test:
	bash tests/run-tests.sh

.PHONY: testv
testv:
	bash tests/run-tests.sh x
