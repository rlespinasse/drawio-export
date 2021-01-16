#!/usr/bin/env bats

. tests/base.bats

@test "Export as xml using short options" {
  docker_test "" 0 "types-xml" "tests/data/types" -E xml -u -F test-assets-xml
}

@test "Export as xml using long options" {
  docker_test "" 0 "types-xml" "tests/data/types" -E xml --uncompressed -F test-assets-xml
}
