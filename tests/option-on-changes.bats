#!/usr/bin/env bats

. tests/base.bats

@test "Export using --on-changes" {
  # Setup exported files 2 hours before drawio file
  docker_test "" 0 "dev_null" "tests/data/types" --folder test-assets-dev_null
  cp -r tests/data/types/test-assets-dev_null tests/data/types/test-assets-on-changes # To support GitHub Action context
  find tests/data/types/test-assets-on-changes -exec touch -d "2 hours ago" -r tests/data/types/nominal.drawio {} +

  # Tests
  docker_test "" 0 "option-on-changes" "tests/data/types" --on-changes --folder test-assets-on-changes
  docker_test "" 0 "option-on-changes_no_changes" "tests/data/types" --on-changes --folder test-assets-on-changes
}
