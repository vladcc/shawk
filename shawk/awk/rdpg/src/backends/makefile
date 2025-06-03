SHELL := bash
AWK := awk

.PHONY: help
help:
	@echo 'make target   - parser + backends'
	@echo 'make backends - to-c + to-awk'
	@echo 'make to-c     - compile the C translator'
	@echo 'make to-awk   - compile the awk translator'
	@echo 'make parser   - compile the common parser'
	@echo 'make help     - this screen'

.PHONY: target
target: parser backends

.PHONY: backends
backends: to-c to-awk

.PHONY: parser
parser:
	cd parser && make target

.PHONY: to-awk
to-awk:
	cd to-awk && make target

.PHONY: to-c
to-c:
	cd to-c && make target
