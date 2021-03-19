#!/usr/bin/env bats

. tests/base.bats

@test "Export and print deprecation message when using env var DRAWIO_EXPORT_FILEEXT" {
  docker_test "-e DRAWIO_EXPORT_FILEEXT=adoc" 0 "deprecation" "tests/data/types" -t -o test-assets-adoc
}

@test "Export and print deprecation message when using env var DRAWIO_EXPORT_CLI_OPTIONS" {
  docker_test "-e DRAWIO_EXPORT_CLI_OPTIONS=-t" 0 "deprecation" "tests/data/types" -f adoc -o test-assets-adoc
}

@test "Export and print deprecation message when using env var DRAWIO_EXPORT_FOLDER" {
  docker_test "-e DRAWIO_EXPORT_FOLDER=test-assets-adoc" 0 "deprecation" "tests/data/types" -f adoc -t
}

@test "Export and print deprecation message when using --fileext" {
  docker_test "" 0 "deprecation" "tests/data/types" --fileext adoc -t -o test-assets-adoc
}

@test "Export and print deprecation message when using -E" {
  docker_test "" 0 "deprecation" "tests/data/types" -E adoc -t -o test-assets-adoc
}

@test "Export and print deprecation message when using --folder" {
  docker_test "" 0 "deprecation" "tests/data/types" -f adoc -t --folder test-assets-adoc
}

@test "Export and print deprecation message when using -F" {
  docker_test "" 0 "deprecation" "tests/data/types" -f adoc -t -F test-assets-adoc
}

@test "Export and print deprecation message when using --path" {
  docker_test "" 0 "deprecation" "tests/data/types" --path . -f adoc -t -o test-assets-adoc
}

