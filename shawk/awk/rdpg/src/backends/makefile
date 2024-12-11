SHELL := bash
AWK := awk

.PHONY: help
help:
	@echo 'make all    - make all backend'
	@echo 'make to-c   - generates the C translator'
	@echo 'make to-awk - generates the awk translator'
	@echo 'make help   - this screen'

.PHONY: all
all: to-c to-awk

.PHONY: parser
parser:
	cd parser && make target

.PHONY: to-awk
to-awk: parser
	cd to-awk && make target

.PHONY: to-c
to-c: parser
	cd to-c && make target
