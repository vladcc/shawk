# <help>
.PHONY: help
help:
	@echo 'make all    - lexer parser lib doc awkson'
	@echo 'make awkson - generates awkson'
	@echo 'make lexer  - generates the lexer'
	@echo 'make parser - generates the parser'
	@echo 'make lib    - generates the library'
	@echo 'make doc    - generates the api doc'
	@echo 'make test   - run tests'
	@echo 'make testv  - like test but verbose'
	@echo 'make clean  - leave only the base source files'
	@echo 'make help   - this screen'
# </help>

# <all>
.PHONY: all
all: lexer parser lib doc awkson
# </all>

# <lexer>
LB_DIR = ../lex-build
LEX_LB = ./src/lexer/lexer.lb
LEX_AWK = ./src/_lexer.awk
LEX_GEN = ./src/lexer/_lexer_gen.awk
LEX_USR = ./src/lexer/_lexer_usr.awk
.PHONY: lexer lexer-gen lex-usr
lexer: $(LEX_AWK)
$(LEX_AWK): $(LEX_GEN) $(LEX_USR)
	cat $^ > $@
$(LEX_GEN): $(LEX_LB)
	awk -f $(LB_DIR)/lex-first.awk $(LEX_LB) | \
	awk -f $(LB_DIR)/lex-awk.awk -vNamePrefix='_' > $@
# </lexer>

# <parser>
RDPG_DIR = ../rdpg
RDPG_STRICT = 0
RDPG_OLVL = 4
PRS_RDPG = ./src/parser/parser.rdpg
PRS_AWK = ./src/_parser.awk
PRS_GEN = ./src/parser/_parser_gen.awk
PRS_USR = ./src/parser/_parser_usr.awk
.PHONY: parser
parser: $(PRS_AWK)
$(PRS_AWK): $(PRS_GEN) $(PRS_USR)
	cat $^  > $@
$(PRS_GEN): $(PRS_RDPG)
	awk -f $(RDPG_DIR)/rdpg.awk -vStrict=$(RDPG_STRICT) $(PRS_RDPG) | \
	awk -f $(RDPG_DIR)/rdpg-opt.awk -vOlvl=$(RDPG_OLVL) | \
	awk -f $(RDPG_DIR)/rdpg-to-awk -vTokCallPrefix="_" > $@
# </parser>

# <libraries>
LIB_TARGET = ./src/_lib.awk
LIB_PART = ./src/lib/_misc.awk
LIB_PART += ./src/lib/_json_to_str.awk
LIB_AWKLIB_DIR = ../awklib/src

LIB_EXPORT = ./src/lib/_export.awk
LIB_EXPORT += $(LIB_AWKLIB_DIR)/awklib_prog.awk
LIB_EXPORT += $(LIB_AWKLIB_DIR)/awklib_read.awk
LIB_EXPORT += $(LIB_AWKLIB_DIR)/awklib_array.awk
LIB_EXPORT += $(LIB_AWKLIB_DIR)/awklib_vect.awk
LIB_EXPORT += $(LIB_AWKLIB_DIR)/awklib_map.awk

LIB_AWKLIB += $(LIB_AWKLIB_DIR)/awklib_prefix_tree.awk
LIB_AWKLIB += $(LIB_AWKLIB_DIR)/awklib_dotnot.awk
LIB_ALL =  $(LIB_PART) $(LIB_AWKLIB) $(LIB_EXPORT)
.PHONY: lib
lib: $(LIB_TARGET)
$(LIB_TARGET): $(LIB_ALL)
	cat $^ > $@
# </libraries>

# <doc>
MAKE_DOC = ../make-doc/make-doc.awk
AWKSON_DOC = ./src/_doc.awk
.PHONY: doc
doc: $(AWKSON_DOC)
$(AWKSON_DOC): $(LIB_EXPORT)
	awk -f $(MAKE_DOC) $^ | \
	sed 's/\\/\\\\/g;s/"/\\"/g;s/^/print "/;s/$$/"/' | \
	awk 'BEGIN {print "function print_api_doc() {"} {print} END {print "}"}' \
	> $@
# </doc>

# <awkson>
AWKSON = awkson.awk
MAIN = ./src/_main.awk
.PHONY: awkson
awkson: $(AWKSON)
$(AWKSON): $(MAIN) $(PRS_AWK) $(LEX_AWK) $(LIB_TARGET) $(AWKSON_DOC)
	cat $^ > $@
# </awkson>

# <clean>
.PHONY: clean
clean:
	rm -f $(AWKSON) $(PRS_AWK) $(LEX_AWK) $(LIB_TARGET) $(AWKSON_DOC)
# </clean>

# <test>
.PHONY: test
test:
	bash ./tests/run-tests.sh
	
.PHONY: testv
testv:
	bash ./tests/run-tests.sh x
# </test>
