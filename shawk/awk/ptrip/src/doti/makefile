.PHONY: help
help:
	@echo 'make doti  - generates doti'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make help  - this screen'

TARGET_DIR = ../..
LIB_DIR = ../../../awklib/src
LIBS = $(LIB_DIR)/awklib_prog.awk $(LIB_DIR)/awklib_gtree.awk
MAIN = ./_main.awk
DOTI = $(TARGET_DIR)/doti.awk

.PHONY: doti
doti: $(DOTI)
$(DOTI): $(MAIN) $(LIBS)
	cat $^ > $@

TEST_DIR = ./tests
.PHONY: test
test:
	bash $(TEST_DIR)/run-tests.sh

.PHONY: testv
testv:
	bash $(TEST_DIR)/run-tests.sh x
