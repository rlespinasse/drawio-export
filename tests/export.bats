#!/usr/bin/env bats

. tests/base.bats

@test "Export files with a name collision" {
  docker_test "" 0 "export-name-collision" "tests/data/name-collision"
  # both files must exists
  [ -f "tests/data/name-collision/export/name-Page-1.pdf" ]
  [ -f "tests/data/name-collision/export/name-collision-Page-1.pdf" ]
}

@test "Export files from a folders tree" {
  docker_test "" 0 "export-tree" "tests/data/tree"
}

@test "Export file with spaces" {
  docker_test "" 0 "export-spaces" "tests/data/space"
}

@test "Export file using shapes" {
  docker_test "" 0 "export-shapes" "tests/data/shapes"
}

@test "Export file without any diagrams" {
  docker_test "" 0 "export-empty" "tests/data/empty"
}

@test "Export file from vscode" {
  docker_test "" 0 "export-vscode" "tests/data/vscode"
}
