SHELL := bash
AWK := awk

AST := _ast.awk
TARGET := ../parts/$(AST)

.PHONY: help
help:
	@echo 'make target - ast + test + place to parent dir'
	@echo 'make ast    - compile the ast'
	@echo 'make test   - run tests'
	@echo 'make help   - this screen'

.PHONY: target
target: $(TARGET)

RUN_TESTS := $(AWK) -f $(AST)
$(TARGET): $(AST)
	$(RUN_TESTS) && cp -v $(AST) $(TARGET)

.PHONY: ast
ast: $(AST)

ADT_GEN := parts/_structs.awk
$(AST): $(ADT_GEN) parts/_ast_usr.awk
	(echo "# <ast>"; cat $^; echo "# </ast>") > $@

STRUCTS_DIR := ../../../../../structs
STRUCTS := $(AWK) -f $(STRUCTS_DIR)/structs.awk
$(ADT_GEN): parts/ast.structs
	$(STRUCTS) $^ > $@

.PHONY: test
test:
	$(RUN_TESTS)
