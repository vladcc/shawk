DEP = ./src/_main.awk
DEP += ../awklib/src/awklib_prep.awk
DEP += ../awklib/src/awklib_str_check.awk
DEP += ../awklib/src/awklib_prog.awk

.PHONY: help
help:
	@echo 'make all   - does prep'
	@echo 'make prep  - compiles prep.awk'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make help  - this screen'

.PHONY: all
all: prep

.PHONY: prep
prep: prep.awk

prep.awk: $(DEP)
	cat $^ > $@

.PHONY: test
test:
	bash tests/run-tests.sh

.PHONY: testv
testv:
	bash tests/run-tests.sh x
