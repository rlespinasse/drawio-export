.PHONY: build test cleanup

DOCKER_IMAGE?=rlespinasse/drawio-export:local
build:
	@docker build -t ${DOCKER_IMAGE} .

RUN_ARGS?=
run:
	docker run -it -v $(PWD):/data ${DOCKER_IMAGE} ${RUN_ARGS}

test:
	@TEST_DOCKER_IMAGE=${DOCKER_IMAGE} ./tests.sh

cleanup:
	@find tests -name "export" | xargs -I {} rm -r "{}"
	@find tests -name "images" | xargs -I {} rm -r "{}"
	@find tests -name "tests-*" | xargs -I {} rm -r "{}"
