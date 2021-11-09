.PHONY: help
help:
	@echo 'make repli - generates repli'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make help  - this screen'

TARGET_DIR = ../..
LIB_DIR = ../../../awklib/src

LIBS = $(LIB_DIR)/awklib_prog.awk
LIBS += $(LIB_DIR)/awklib_exec_cmd.awk
LIBS += $(LIB_DIR)/awklib_array.awk
LIBS += $(LIB_DIR)/awklib_vect.awk
LIBS += $(LIB_DIR)/awklib_eos.awk

MAIN = ./_main.awk
REPLI = $(TARGET_DIR)/repli.awk

.PHONY: repli
repli: $(REPLI)
$(REPLI): $(MAIN) $(LIBS)
	cat $^ > $@

TEST_DIR = ./tests
.PHONY: test
test:
	bash $(TEST_DIR)/run-tests.sh

.PHONY: testv
testv:
	bash $(TEST_DIR)/run-tests.sh x
