#!/usr/bin/env bats

. tests/base.bats

@test "Argument PATH must exists" {
  docker_test "" 1 "args-path_must_exists" "tests/data" "unknown-folder"
}

@test "Export using specific PATH" {
  docker_test "" 0 "args-path" "tests/data" "types"
}
