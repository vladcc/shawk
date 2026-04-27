SHELL := bash
AWK := awk

.PHONY: help
help:
	@echo 'make target   - parser + backends'
	@echo 'make test     - run all tests'
	@echo 'make backends - to-c + to-awk'
	@echo 'make to-c     - compile the C translator'
	@echo 'make to-awk   - compile the awk translator'
	@echo 'make parser   - compile the common parser'
	@echo 'make help     - this screen'

.PHONY: target
target: parser backends

.PHONT: test
test:
	cd parser && $(MAKE) test
	cd to-awk && $(MAKE) test
	cd to-c   && $(MAKE) test

.PHONY: backends
backends: to-c to-awk

.PHONY: parser
parser:
	cd parser && $(MAKE) target

.PHONY: to-awk
to-awk:
	cd to-awk && $(MAKE) target

.PHONY: to-c
to-c:
	cd to-c && $(MAKE) target
