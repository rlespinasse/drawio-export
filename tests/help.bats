#!/usr/bin/env bats

. tests/base.bats

@test "Print help when using wrong argument" {
  docker_test "" 1 "print_help_if_wrong_argument" "tests/data" --wrong-argument
}
