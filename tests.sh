#!/usr/bin/env bash
IFS=$'\n\t'

# shellcheck disable=SC1091
source ./default.env

function cleanup() {
  echo "+ cleanup '$1' folder(s)"
  find tests -name "$1" | while read -r output; do
    rm -rf "$output"
  done
}

function run_test() {
  echo "+ run '$1' command"

  # shellcheck disable=SC2086
  docker run -t \
    -e DRAWIO_EXPORT_FILEEXT="$2" \
    -e DRAWIO_EXPORT_CLI_OPTIONS="$3" \
    -e DRAWIO_EXPORT_FOLDER="$4" \
    -v "$(pwd)"/tests/data:/data:rw \
    --privileged "${TEST_DOCKER_IMAGE}" $5 | tee "tests/actual/$1-output.log"

  echo "+ run '$1' test"
  # shellcheck disable=SC2038
  find . -type d -name "$4" | xargs -n 1 -I {} find "{}" -type f | tee "tests/actual/$1-files.log"
  output_test=$(diff --strip-trailing-cr "tests/actual/$1-output.log" "tests/expected/$1-output.log")
  files_test=$(comm -13 <(sort "tests/actual/$1-files.log") <(sort "tests/expected/$1-files.log"))

  echo "+ check '$1' test"
  if [ -n "$output_test" ]; then
    echo >&2 "ERR! unexpected $1 output"
    echo "$output_test"
  fi

  if [ -n "$files_test" ]; then
    echo >&2 "ERR! unexpected $1 files"
    echo "$files_test"
  fi

  if [ -n "$output_test" ] || [ -n "$files_test" ]; then
    return 1
  fi
  return 0
}

# In order to works everywhere
chmod -R 777 tests/data
mkdir -p tests/actual
cleanup "export"
cleanup "tests-*"

#run_test "name" "ext" "cli_options" "folder" "args"
run_test "default" "$DEFAULT_DRAWIO_EXPORT_FILEEXT" "$DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS" "$DEFAULT_DRAWIO_EXPORT_FOLDER" ""
result_default=$?
run_test "png" "png" "" "tests-png" ""
result_png=$?
run_test "other" "notused" "notused" "test-notused" "-V"
result_other=$?
run_test "adoc" "adoc" "" "tests-adoc" ""
result_adoc=$?

if [ "$result_default" == "1" ] ||
  [ "$result_png" == "1" ] ||
  [ "$result_adoc" == "1" ] ||
  [ "$result_other" == "1" ]; then

  if [ "$result_default" == "1" ]; then
    echo >&2 "ERR! test default"
  fi
  if [ "$result_png" == "1" ]; then
    echo >&2 "ERR! test png"
  fi
  if [ "$result_other" == "1" ]; then
    echo >&2 "ERR! test other"
  fi
  exit 1
fi
