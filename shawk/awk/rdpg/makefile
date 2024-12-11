SHELL := bash
AWK := awk

.PHONY: help
help:
	@echo 'make all         - generates rdpg-*'
	@echo 'make rdpg-comp   - generates the compiler'
	@echo 'make rdpg-to-c   - generates the C translator'
	@echo 'make rdpg-to-awk - generates the awk translator'
	@echo 'make help        - this screen'

.PHONY: all
all: rdpg-comp rdpg-to-c rdpg-to-awk

.PHONY: rdpg-comp
rdpg-comp:
	cd src/compiler && $(MAKE) target

.PHONY: rdpg-to-c
rdpg-to-c:
	cd src/backends && $(MAKE) to-c

.PHONY: rdpg-to-awk
rdpg-to-awk:
	cd src/backends && $(MAKE) to-awk
