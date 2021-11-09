.PHONY: help
help:
	@echo 'test  - run tests'
	@echo 'testv - like test but verbose'
	@echo 'gen   - print the command used to generate smpg.awk'
	@echo 'help  - this screen'

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
