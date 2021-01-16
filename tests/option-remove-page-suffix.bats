#!/usr/bin/env bats

. tests/base.bats

@test "Export using --remove-page-suffix" {
  docker_test "" 0 "option-remove-page-suffix" "tests/data/single-page" --remove-page-suffix --folder test-assets-remove-page-suffix
}
