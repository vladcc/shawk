SRC_DIR = ./src
IR = $(SRC_DIR)/common/_rdpg_ir.awk

RDPG_SRC = $(SRC_DIR)/rdpg/* $(IR)
RDPG_OPT_SRC = $(SRC_DIR)/rdpg-opt/* $(IR)
RDPG_TO_C_SRC = $(SRC_DIR)/rdpg-to-c/* $(IR)
RDPG_TO_AWK = $(SRC_DIR)/rdpg-to-awk/* $(IR)

RDPG_ALL = rdpg rdpg-opt rdpg-to-c rdpg-to-awk

.PHONY: help
help:
	@echo 'make all   - generates rdpg*'
	@echo 'make allt  - all + test'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make clean - removes generated rdpg*.awk'
	@echo 'make rdpg        - generates rdpg.awk'
	@echo 'make rdpg-opt    - generates the optimizer'
	@echo 'make rdpg-to-c   - generates the C translator'
	@echo 'make rdpg-to-awk - generates the awk translator'
	@echo 'make help  - this screen'
	
.PHONY: all
all: $(RDPG_ALL)

.PHONY: allt
allt: all test

.PHONY: test
test:
	bash tests/run-tests.sh
	
.PHONY: testv
testv:
	bash tests/run-tests.sh x

.PHONY:clean
clean:
	rm -f rdpg*.awk

rdpg: rdpg.awk

# ugly relative paths, but necessary for awk and smpg
rdpg.awk: $(RDPG_SRC)
	cd ./src/rdpg; awk -f ../../../smpg/smpg.awk ./rdpg.smpg > ../../$@; cd ../..

rdpg-opt: rdpg-opt.awk
rdpg-opt.awk: $(RDPG_OPT_SRC)
	cat $^ > $@
	
rdpg-to-c: rdpg-to-c.awk
rdpg-to-c.awk: $(RDPG_TO_C_SRC)
	cat $^ > $@
	
rdpg-to-awk: rdpg-to-awk.awk
rdpg-to-awk.awk: $(RDPG_TO_AWK)
	cat $^ > $@
