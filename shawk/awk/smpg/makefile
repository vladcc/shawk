.PHONY: help
help:
	@echo 'make all   - smpg test clean'
	@echo 'make smpg  - generate smpg'
	@echo 'make test  - run tests'
	@echo 'make testv - like test but verbose'
	@echo 'make gen   - print the command used to generate smpg.awk'
	@echo 'make help  - this screen'

.PHONY: all
all: smpg test clean

.PHONY: smpg
smpg:
	mv -v smpg.awk smpg.awk.old && awk -f smpg.awk.old self.smpg > smpg.awk

.PHONY: test
test:
	bash tests/run-tests.sh

.PHONY: testv
testv:
	bash tests/run-tests.sh x

.PHONY: gen
gen:
	@echo '# generates itself'
	@echo awk -f smpg.awk self.smpg

.PHONY: clean
clean:
	rm -f smpg.awk.old
