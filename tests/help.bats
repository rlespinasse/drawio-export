#!/usr/bin/env bats

. tests/base.bats

@test "Print help" {
  docker_test "" 0 "print_help" "tests/data" --help
}

@test "Print help using short option" {
  docker_test "" 0 "print_help" "tests/data" -h
}

@test "Print help when using wrong argument" {
  docker_test "" 1 "print_help_if_wrong_argument" "tests/data" --wrong-argument
}
