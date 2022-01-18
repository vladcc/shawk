.PHONY: help
help:
	@echo "make all  - run all rebuild and test"
	@echo "make help - this screen"

ALL := $(notdir $(shell find . -mindepth 1 -maxdepth 1 -type d))
REBUILD := $(addprefix rebuild_,$(ALL))
TEST := $(addprefix test_,$(ALL))

define GEN_RULE
$(1)_$(2):
	cd $(2) && $(MAKE) $(3)

endef

define MAKE_RULES
$(foreach rule,$(ALL), $(call $(3),$(call GEN_RULE,$(1),$(rule),$(2))))
endef

.PHONY: rebuild
rebuild: $(REBUILD)

.PHONY: test
test: $(TEST)

$(call MAKE_RULES,test,test,eval)
$(call MAKE_RULES,rebuild,-B all,eval)

.PHONY: all
all: rebuild test
