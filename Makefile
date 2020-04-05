cleanup:
	@find tests -name "export" | while read -r output; do rm -rf "$$output"; done
	@find tests -name "tests-*" | while read -r output; do rm -rf "$$output"; done

build:
	@docker build -t rlespinasse/drawio-export .

test:
	@./tests.sh
