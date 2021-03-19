#!/usr/bin/env bats

. tests/base.bats

@test "Export as adoc" {
  docker_test "" 0 "types-adoc" "tests/data/types" -f adoc -t -o test-assets-adoc
}

