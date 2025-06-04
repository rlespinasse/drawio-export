#!/usr/bin/env bats

docker_test() {
  local docker_opts="$1"
  local status=$2
  local output_file=$3
  local data_folder=$4
  shift 4

  # shellcheck disable=SC2086,SC2046
  echo docker container run -t $docker_opts -w /data -v $(pwd)/${data_folder:-}:/data ${DOCKER_IMAGE} "$@" >>tests/output/$output_file-command.log
  # shellcheck disable=SC2046
  run docker container run -t $docker_opts -w /data -v $(pwd)/${data_folder:-}:/data ${DOCKER_IMAGE} "$@"

  # shellcheck disable=SC2154
  echo "$output" | tee "tests/output/$output_file.log" | sed 's#\[.*:.*/.*\..*:.*:.*\(.*\)\] ##' >"tests/output/$output_file-comp.log"

  # Test status
  # shellcheck disable=SC2086
  [ "$status" -eq $status ]

  # Test output
  if [ -f "tests/expected/$output_file.log" ]; then
    diff -u --strip-trailing-cr "tests/expected/$output_file.log" "tests/output/$output_file-comp.log" >"tests/output/$output_file-diff.log"
  elif [ -f "tests/expected/uniq-$output_file.log" ]; then
    diff -u --strip-trailing-cr "tests/expected/uniq-$output_file.log" <(sort -u "tests/output/$output_file-comp.log") >"tests/output/$output_file-diff.log"
  fi
  if [ -f "tests/output/$output_file-diff.log" ]; then
    [ "$(cat "tests/output/$output_file-diff.log")" = "" ]
  fi
}
