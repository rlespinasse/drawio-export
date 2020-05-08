#!/usr/bin/env bash
#set -x
IFS=$'\n\t'

# shellcheck disable=SC1091
source ./drawio-default.env

function cleanup() {
  if [ -n "$1" ]; then
    echo "+ cleanup '$1' folder(s)"
    find tests -name "$1" | while read -r output; do
      rm -rf "$output"
    done
  fi
}

function run_test() {
  local test_name="${1:-}"
  local type="${2:-}"
  local fileext="${3:-}"
  local cli_options="${4:-}"
  local folder="${5:-}"
  local args="${6:-}"
  local test_output_folder="${7:-}"

  echo "+ run '$test_name' command"

  if [ "$type" == "envvars" ]; then
    # shellcheck disable=SC2086
    docker run -t \
      -e DRAWIO_EXPORT_FILEEXT="$fileext" \
      -e DRAWIO_EXPORT_CLI_OPTIONS="$cli_options" \
      -e DRAWIO_EXPORT_FOLDER="$folder" \
      -v "$(pwd)"/tests/data:/data "${TEST_DOCKER_IMAGE}" |
      tee "tests/actual/$test_name-output.log"
  elif [ "$type" == "args" ]; then
    # shellcheck disable=SC2086
    docker run -t "${TEST_DOCKER_IMAGE}" $args |
      tee "tests/actual/$test_name-output.log"
  elif [ "$type" == "options" ]; then
    # shellcheck disable=SC2086
    docker run -t -v "$(pwd)"/tests/data:/data "${TEST_DOCKER_IMAGE}" \
      -E "$fileext" -C "$cli_options" -F "$folder" |
      tee "tests/actual/$test_name-output.log"
  elif [ "$type" == "long-options" ]; then
    # shellcheck disable=SC2086
    docker run -t -v "$(pwd)"/tests/data:/data "${TEST_DOCKER_IMAGE}" \
      --fileext "$fileext" --cli-options "$cli_options" --folder "$folder" |
      tee "tests/actual/$test_name-output.log"
  else
    docker run -t -v "$(pwd)"/tests/data:/data "${TEST_DOCKER_IMAGE}" | tee "tests/actual/$test_name-output.log"
  fi

  echo "+ run '$test_name' test"
  touch "tests/expected/$test_name-output.log"
  output_test=$(diff --strip-trailing-cr "tests/actual/$test_name-output.log" "tests/expected/$test_name-output.log")

  if [ -n "$test_output_folder" ]; then
    # shellcheck disable=SC2038
    find . -type d -name "$test_output_folder" | xargs -n 1 -I {} find "{}" -type f | tee "tests/actual/$test_name-files.log"
    touch "tests/expected/$test_name-files.log"
    files_test=$(diff --strip-trailing-cr <(sort "tests/actual/$test_name-files.log") <(sort "tests/expected/$test_name-files.log"))
  fi

  echo "+ check '$test_name' test"
  if [ -n "$output_test" ]; then
    echo >&2 "ERR! unexpected $test_name output"
    echo "$output_test"
  fi

  if [ -n "$files_test" ]; then
    echo >&2 "ERR! unexpected $test_name files"
    echo "$files_test"
  fi

  cleanup "$test_output_folder"

  if [ -n "$output_test" ] || [ -n "$files_test" ]; then
    echo >&2 "ERR! test $test_name"
    exit 1
  fi
}

mkdir -p tests/actual
cleanup "export"
cleanup "tests-*"

#run_test "test name" "type" "fileext" "cli_options" "folder" "args" "output folder for test"

run_test "args-png-short" "options" "png" "-t" "tests-args-png-short" "" "tests-args-png-short"
run_test "args-adoc-short" "options" "adoc" "-t" "tests-args-adoc-short" "" "tests-args-adoc-short"

run_test "args-png-long" "long-options" "png" "-t" "tests-args-png-long" "" "tests-args-png-long"
run_test "args-adoc-long" "long-options" "adoc" "-t" "tests-args-adoc-long" "" "tests-args-adoc-long"

run_test "default" "none" "" "" "" "" "$DEFAULT_DRAWIO_EXPORT_FOLDER"
run_test "envvar-png" "envvars" "png" "-t" "tests-envvar-png" "" "tests-envvar-png"
run_test "envvar-adoc" "envvars" "adoc" "-t" "tests-envvar-adoc" "" "tests-envvar-adoc"

run_test "args-help-short" "args" "" "" "" "-h" ""
run_test "args-help-long" "args" "" "" "" "--help" ""
