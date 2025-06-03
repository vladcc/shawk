SHELL := bash
AWK := awk

.PHONY: help
help:
	@echo 'make target      - frontend + backends'
	@echo 'make frontend    - rdpg-comp'
	@echo 'make backends    - compile all backends'
	@echo 'make rdpg-comp   - compile the frontend compiler'
	@echo 'make rdpg-to-c   - compile the C backend'
	@echo 'make rdpg-to-awk - compile the awk backend'
	@echo 'make help        - this screen'

.PHONY: target
target: frontend backends

.PHONY: frontend
frontend: rdpg-comp

.PHONY: backends
backends:
	cd src/backends && $(MAKE) target

.PHONY: rdpg-comp
rdpg-comp:
	cd src/compiler && $(MAKE) target

.PHONY: rdpg-to-c
rdpg-to-c:
	cd src/backends && $(MAKE) to-c

.PHONY: rdpg-to-awk
rdpg-to-awk:
	cd src/backends && $(MAKE) to-awk
