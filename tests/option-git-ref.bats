#!/usr/bin/env bats

. tests/base.bats

@test "Option --git-ref need a git repository" {
  docker_test "" 1 "option-git-ref_need_git_repo" "tests/data" --on-changes --git-ref HEAD
}

@test "Option --git-ref need to be a valid Git reference" {
  docker_test "" 1 "option-git-ref_must_exists" "." --on-changes --git-ref unknown-ref
}

@test "Option --git-ref need option --on-changes" {
  docker_test "" 1 "option-git-ref_need_on-changes" "." --git-ref HEAD
}

@test "Export using --git-ref <root commit> (has changes)" {
  docker_test "" 0 "option-git-ref_root_commit" "." --on-changes --git-ref $(git rev-list HEAD | tail -n 1) --output test-assets-git-ref "tests/data/types"
}

@test "Export using --git-ref HEAD (no changes)" {
  if [ -n "$(git diff --name-only --cached)" ]; then
    skip "This test is designed to work without any files in the commit staging area"
  fi

  docker_test "" 0 "option-git-ref_HEAD" "." --on-changes --git-ref HEAD --output test-assets-git-ref "tests/data/types"
}
