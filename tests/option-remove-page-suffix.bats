#!/usr/bin/env bats

. tests/base.bats

@test "Export using --remove-page-suffix" {
  docker_test "" 0 "option-remove-page-suffix" "tests/data/single-page" --remove-page-suffix --output test-assets-remove-page-suffix
}
