#!/usr/bin/env bats

. tests/base.bats

@test "Issue 140 : page index mismatch" {
  docker_test "" 0 "export-issue-140" "tests/data" -f svg issue-140
  diff <(xmllint --format tests/expected/issue-140-page-index-mismatch-Blue.svg) <(xmllint --format tests/data/issue-140/export/page-index-mismatch-Blue.svg)
  diff <(xmllint --format tests/expected/issue-140-page-index-mismatch-Green.svg) <(xmllint --format tests/data/issue-140/export/page-index-mismatch-Green.svg)
  diff <(xmllint --format tests/expected/issue-140-page-index-mismatch-Purple.svg) <(xmllint --format tests/data/issue-140/export/page-index-mismatch-Purple.svg)
  diff <(xmllint --format tests/expected/issue-140-page-index-mismatch-Yellow.svg) <(xmllint --format tests/data/issue-140/export/page-index-mismatch-Yellow.svg)
}
