#!/usr/bin/env bats

. tests/base.bats

@test "Export as xml using short options" {
  docker_test "" 0 "types-xml" "tests/data/types" -f xml -u -o test-assets-xml
}

@test "Export as xml using long options" {
  docker_test "" 0 "types-xml" "tests/data/types" -f xml --uncompressed -o test-assets-xml
}
