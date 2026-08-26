#!/usr/bin/env -S just --justfile

set quiet := true

# Default docker image name
docker_image := env_var_or_default("DOCKER_IMAGE", "rlespinasse/drawio-export:local")

default:
  just --choose

# Build the Docker image
[group('Development mode')]
build:
  docker build -t {{docker_image}} .

# Build the Docker image without cache
[group('Development mode')]
build-no-cache:
  docker build --no-cache --progress plain -t {{docker_image}} .

# Build for multiple architectures
[group('Development mode')]
build-multiarch:
  docker buildx build --platform linux/amd64,linux/arm64 -t {{docker_image}} .

# Clean up test artifacts
[group('Development mode')]
cleanup:
  rm -rf tests/output
  find tests -name "export" | xargs -I {} rm -r "{}"
  find tests -name "test-*" | xargs -I {} rm -r "{}"

# Run the Docker container
[group('Development mode')]
run *ARGS:
  docker run -t {{env_var_or_default("DOCKER_OPTIONS", "")}} -w /data -v {{invocation_directory()}}:/data {{docker_image}} {{ARGS}}

# Run tests
[group('Testing mode')]
test: cleanup build test-ci

# Setup CI test environment
[group('Testing mode')]
test-ci-setup:
  npm install bats
  sudo apt-get update
  sudo apt-get install -y libxml2-utils

# Run CI tests
[group('Testing mode')]
test-ci:
  mkdir -p tests/output
  DOCKER_IMAGE={{docker_image}} npx bats --verbose-run -r tests

# Auto-update drawio-exporter version
[group('Maintenance mode')]
autoupdate-drawio-exporter:
  #!/usr/bin/env bash
  DRAWIO_EXPORTER_RELEASE=$(gh release list --repo rlespinasse/drawio-exporter | grep "Latest" | cut -f1 | sed 's/^v//')
  sed -i "s/version.*/version $DRAWIO_EXPORTER_RELEASE/" Dockerfile
  if [ -n "${GITHUB_OUTPUT}" ]; then
    echo "release_version=$DRAWIO_EXPORTER_RELEASE" >> "${GITHUB_OUTPUT}"
  fi
  echo "Updated to drawio-exporter version $DRAWIO_EXPORTER_RELEASE"
