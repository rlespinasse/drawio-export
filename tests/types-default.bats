#!/usr/bin/env bats

. tests/base.bats

@test "Export using default configuration" {
  docker_test "" 0 "types-default" "tests/data/types"
}
