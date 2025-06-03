SHELL := bash
AWK := awk

PRS := _prs.awk
TARGET := ../parts/$(PRS)

.PHONY: help
help:
	@echo 'make target - build + test + place in parent dir'
	@echo 'make build  - prs'
	@echo 'make prs    - compile the parser front end'
	@echo 'make test   - run tests'
	@echo 'make help   - this screen'

.PHONY: target
target: build $(TARGET)

.PHONY: build
build: prs

# <tests>
RUN_TESTS := $(AWK) -f $(PRS)
# </tests>
$(TARGET): $(PRS)
	$(RUN_TESTS) && cp -v $(PRS) $(TARGET)

.PHONY: prs
prs: $(PRS)

PRS_GEN := parts/_prs_gen.awk
$(PRS): $(PRS_GEN) parts/_prs_usr.awk
	(echo "# <prs>" && cat $^ && echo "# </prs>") > $@

RDPG_DIR := ../../../..
RDPG_COMP := $(AWK) -f $(RDPG_DIR)/rdpg-comp.awk
RDPG_TO_AWK := $(AWK) -f $(RDPG_DIR)/rdpg-to-awk.awk
$(PRS_GEN): parts/grammar.rdpg
	$(RDPG_COMP) $^ | $(RDPG_TO_AWK) > $@

.PHONY: test
test:
	$(RUN_TESTS)
