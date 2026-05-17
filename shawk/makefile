.PHONY: help
help:
	@echo "make all  - run make all for all projects"
	@echo "make help - this screen"

ALL := $(notdir $(shell find . -mindepth 1 -maxdepth 1 -type d))
REBUILD := $(addprefix rebuild_,$(ALL))

define GEN_RULE
$(1)_$(2):
	cd $(2) && $(MAKE) $(3)

endef

define MAKE_RULES
$(foreach rule,$(ALL), $(call $(3),$(call GEN_RULE,$(1),$(rule),$(2))))
endef

.PHONY: rebuild
rebuild: $(REBUILD)

$(call MAKE_RULES,rebuild,-B all,eval)

.PHONY: all
all: rebuild
