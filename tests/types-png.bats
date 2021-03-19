#!/usr/bin/env bats

. tests/base.bats

@test "Export as png using short options" {
  docker_test "" 0 "types-png" "tests/data/types" -f png -t -o test-assets-png
}
