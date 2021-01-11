#!/usr/bin/env bats

@test "Print help" {
  docker_test "" 0 "help" --help
}

@test "Print help using short option" {
  docker_test "" 0 "help" -h
}

@test "Print help when using wrong argument" {
  docker_test "" 1 "help_wrong_argument" --wrong-argument
}

@test "Export using default configuration" {
  docker_test "" 0 "default"
}

@test "Export as png using short options" {
  docker_test "" 0 "png" -E png -t -F test-assets-png
}

@test "Export as pdf using long options" {
  docker_test "" 0 "pdf" --fileext pdf --crop --folder test-assets-pdf
}

@test "Export as adoc using environment variables" {
  docker_test "-e DRAWIO_EXPORT_FILEEXT=adoc -e DRAWIO_EXPORT_CLI_OPTIONS=-t -e DRAWIO_EXPORT_FOLDER=test-assets-adoc" 0 "adoc"
}

@test "Export as xml using short options" {
  docker_test "" 0 "xml" -E xml -u -F test-assets-xml
}

@test "Export as xml using long options" {
  docker_test "" 0 "xml" -E xml --uncompressed -F test-assets-xml
}

@test "Export using remove page suffix flag" {
  docker_test "" 0 "remove-page-suffix" --remove-page-suffix --folder test-assets-remove-page-suffix
}

@test "Export using on changes flag" {
  docker_test "" 0 "on-changes" --on-changes --folder test-assets-on-changes
  docker_test " " 0 "on-changes-not-changed" --on-changes --folder test-assets-on-changes
}

docker_test() {
  local docker_opts="$1"
  local status=$2
  local output_file=$3
  shift
  shift
  shift
  run docker run -t $docker_opts -w /data -v $(pwd)/tests/data:/data ${DOCKER_IMAGE} "$@"

  echo "Status: $status"
  echo "Output:"
  echo "$output"

  [ "$status" -eq $status ]
  [ "$(diff --strip-trailing-cr <(echo "$output") "tests/expected/$output_file.log")" = "" ]
}
