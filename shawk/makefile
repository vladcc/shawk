.PHONY: help
help:
	@echo 'test  - run tests'
	@echo 'help  - this screen'

.PHONY: test
test:
	find . -name 'run-test*.sh' | \
	while read f; do echo $$f; bash $$f || { echo $$f failed; exit 1; }; done
