#!/usr/bin/env bats

@test "Print help" {
  docker_test "--help" "" 0 "help"
}

@test "Print help using short option" {
  docker_test "-h" "" 0 "help"
}

@test "Print help when using wrong argument" {
  docker_test "--wrong-argument" "" 1 "help_wrong_argument"
}

@test "Export using default configuration" {
  docker_test "" "" 0 "default"
}

@test "Export as png using short options" {
  docker_test "-E png -t -F test-assets-png" "" 0 "png"
}

@test "Export as pdf using long options" {
  docker_test "--fileext pdf --crop --folder test-assets-pdf" "" 0 "pdf"
}

@test "Export as adoc using environment variables" {
  docker_test "" "-e DRAWIO_EXPORT_FILEEXT=adoc -e DRAWIO_EXPORT_CLI_OPTIONS=-t -e DRAWIO_EXPORT_FOLDER=test-assets-adoc" 0 "adoc"
}

@test "Export as xml using short options" {
  docker_test "-E xml -u -F test-assets-xml" "" 0 "xml"
}

@test "Export as xml using long options" {
  docker_test "-E xml --uncompressed -F test-assets-xml" "" 0 "xml"
}

@test "Export using remove page suffix flag" {
  docker_test "--remove-page-suffix --folder test-assets-remove-page-suffix" "" 0 "remove-page-suffix"
}

docker_test() {
  run docker run -t $2 -v $(pwd)/tests/data:/data ${DOCKER_IMAGE} $1

  echo "Status: $status"
  echo "Output:"
  echo "$output"

  [ "$status" -eq $3 ]
  [ "$(diff --strip-trailing-cr <(echo "$output") "tests/expected/$4.log")" = "" ]
}
