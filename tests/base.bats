#!/usr/bin/env bats

docker_test() {
  local docker_opts="$1"
  local status=$2
  local output_file=$3
  local data_folder=$4
  shift
  shift
  shift
  shift

  # shellcheck disable=SC2086,SC2046
  run docker container run -t $docker_opts -w /data -v $(pwd)/${data_folder:-}:/data ${DOCKER_IMAGE} "$@"

  # shellcheck disable=SC2154
  echo "$output" | tee "tests/output/$output_file.log" | sed 's#\[.*:.*/.*\..*:.*:.*\(.*\)\] ##' >"tests/output/$output_file-comp.log"

  # shellcheck disable=SC2086
  [ "$status" -eq $status ]
  if [ -f "tests/expected/$output_file.log" ]; then
    [ "$(diff --strip-trailing-cr "tests/output/$output_file-comp.log" "tests/expected/$output_file.log")" = "" ]
  fi
}
