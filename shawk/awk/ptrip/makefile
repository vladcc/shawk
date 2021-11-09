.PHONY: help
help:
	@echo 'make all              - generates ptrip + doti + repli'
	@echo 'make ptrip            - generates the whole ptrip'
	@echo 'make doti             - generates doti'
	@echo 'make repli            - generates repli'
	@echo 'make test             - run all tests'
	@echo 'make testv            - like test but verbose'
	@echo 'G_AWK=<awk> make test - use <awk> instead of the default'
	@echo 'make help             - this screen'

T_ = t_
TV_ = tv_
_ALL = _ptrip _doti _repli
ALL = $(subst _,,$(_ALL))
ALL_T = $(subst _,$(T_),$(_ALL))
ALL_TV = $(subst _,$(TV_),$(_ALL))

.PHONY: all $(ALL)
all: $(ALL)
$(ALL):
	cd ./src/$@ && $(MAKE) $@

TEST = test
.PHONY: $(TEST) $(ALL_T)
$(TEST): $(ALL_T) test_end_to_end
$(ALL_T):
	cd ./src/$(subst $(T_),,$@) && $(MAKE) $(TEST)

TESTV = testv
.PHONY: $(TESTV) $(ALL_TV)
$(TESTV): $(ALL_TV) test_end_to_endv
$(ALL_TV):
	cd ./src/$(subst $(TV_),,$@) && $(MAKE) $(TESTV)

test_end_to_end:
	bash ./tests/run-tests.sh

test_end_to_endv:
	bash ./tests/run-tests.sh x
