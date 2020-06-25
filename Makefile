.PHONY: build run setup-test test cleanup

DOCKER_IMAGE?=rlespinasse/drawio-export:local
build:
	@docker build -t ${DOCKER_IMAGE} .

RUN_ARGS?=
run:
	@docker run -it -v $(PWD):/data ${DOCKER_IMAGE} ${RUN_ARGS}

setup-test:
	@npm install -g bats

test: build
	@DOCKER_IMAGE=$(DOCKER_IMAGE) bats -r .

cleanup:
	@find tests -name "export" | xargs -I {} rm -r "{}"
	@find tests -name "test-*" | xargs -I {} rm -r "{}"
