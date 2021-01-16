#!/usr/bin/env bats

. tests/base.bats

@test "Export as adoc using environment variables" {
  docker_test "-e DRAWIO_EXPORT_FILEEXT=adoc -e DRAWIO_EXPORT_CLI_OPTIONS=-t -e DRAWIO_EXPORT_FOLDER=test-assets-adoc" 0 "types-adoc" "tests/data/types"
}

@test "Export as adoc" {
  docker_test "" 0 "types-adoc" "tests/data/types" -E adoc -t -F test-assets-adoc
}

