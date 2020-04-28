.PHONY: build publish test

build:
	@docker build -t rlespinasse/drawio-export .

publish:
	@docker push rlespinasse/drawio-export

test:
	@./tests.sh

cleanup:
	@find tests -name "export" | xargs -I {} rm -r "{}"
	@find tests -name "images" | xargs -I {} rm -r "{}"
	@find tests -name "tests-*" | xargs -I {} rm -r "{}"
