.PHONY: help
help:
	@echo "make all  - run top level rebuild and test; regenerates if needed"
	@echo "make help - this screen"

SH_GEN = ./gen-make.sh
MF_GEN = makefile.gen

.PHONY: all
all:
	bash -c '(diff <($(SH_GEN)) $(MF_GEN) > /dev/null) || ($(SH_GEN) > $(MF_GEN))'
	$(MAKE) -f $(MF_GEN) all
