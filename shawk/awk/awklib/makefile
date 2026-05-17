SHELL := bash

.PHONY: help
help:
	@echo 'make all   - sure'
	@echo 'make sure  - test + confirms all tests run'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make help  - this screen'


.PHONY: all
all: sure

.PHONY: sure
sure:
	cd tests/ && bash run-tests.sh x | grep -oE 'test_awklib_[^.]+.awk|^test_[a-z_]+' | sort > tests_run.txt
	cd tests/ && diff tests_expected.txt tests_run.txt

.PHONY: test
test:
	bash tests/run-tests.sh

.PHONY: testv
testv:
	bash tests/run-tests.sh x
