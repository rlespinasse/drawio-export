#!/usr/bin/env bats

. tests/base.bats

@test "Export as png using short options" {
  docker_test "" 0 "types-png" "tests/data/types" -E png -t -F test-assets-png
}
