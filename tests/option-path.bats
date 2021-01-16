#!/usr/bin/env bats

. tests/base.bats

@test "Option --path value must exists" {
  docker_test "" 1 "option-path_must_exists" "tests/data" --path unknown-folder
}

@test "Export using --path" {
  docker_test "" 0 "option-path" "tests/data" --path "types"
}
