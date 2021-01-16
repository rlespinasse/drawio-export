#!/usr/bin/env bats

. tests/base.bats

@test "Export as pdf using long options" {
  docker_test "" 0 "types-pdf" "tests/data/types" --fileext pdf --crop --folder test-assets-pdf
}
