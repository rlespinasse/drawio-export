#!/usr/bin/env bats

. tests/base.bats

@test "Export as pdf using long options" {
  docker_test "" 0 "types-pdf" "tests/data/types" --format pdf --crop --output test-assets-pdf
}

@test "Export as pdf using all-pages option" {
  docker_test "" 0 "types-pdf-all-pages" "tests/data/types" --format pdf --all-pages --output test-assets-pdf
}
