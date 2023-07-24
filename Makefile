.PHONY: build build-no-cache build-multiarch cleanup run test test-ci-setup test-ci

DOCKER_IMAGE?=rlespinasse/drawio-export:local
build:
	@docker build -t ${DOCKER_IMAGE} .

build-no-cache:
	@docker build --no-cache --progress plain -t ${DOCKER_IMAGE} .

build-multiarch:
	@docker buildx build --platform linux/amd64,linux/arm64 -t ${DOCKER_IMAGE} .

cleanup:
	@rm -rf tests/output
	@find tests -name "export" | xargs -I {} rm -r "{}"
	@find tests -name "test-*" | xargs -I {} rm -r "{}"

RUN_ARGS?=
DOCKER_OPTIONS?=
run:
	@docker run -t $(DOCKER_OPTIONS) -w /data -v $(PWD):/data ${DOCKER_IMAGE} ${RUN_ARGS}

test: cleanup build test-ci

test-ci-setup:
	@npm install bats
	@sudo apt-get install -y libxml2-utils

test-ci:
	@mkdir -p tests/output
	@DOCKER_IMAGE=$(DOCKER_IMAGE) npx bats -r tests
