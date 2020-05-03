#!/usr/bin/env bash
#set -x
set -euo pipefail
IFS=$'\n\t'

if [ -z "${DRAWIO_CLI:-}" ]; then
  echo >&2 "define DRAWIO_CLI as the path to draw.io desktop application"
  exit 1
fi

function export_pages() {
  local path="$1"
  local folder="$2"
  local filename="$3"
  local protected_filename="${filename// /-}"
  local pagenum=0
  local pagefileext="$FILEEXT"

  if [ "$FILEEXT" == "adoc" ]; then
    pagefileext="png"
  fi

  while read -r page; do
    local protected_page="${page// /-}"
    pagenum=$((pagenum + 1))
    printf "++ export page %s : %s\n" "$pagenum" "$page"
    printf "+++ generate %s file\n" "$pagefileext"
    output_file="$folder/$FOLDER/$protected_filename-$protected_page.$pagefileext"

    # shellcheck disable=SC2086
    "$DRAWIO_CLI" \
      --no-sandbox \
      -x \
      -f "$pagefileext" \
      $CLI_OPTIONS \
      -p "$pagenum" \
      -o "$output_file" \
      "$path" 2>/dev/null

    if [ "$FILEEXT" == "adoc" ]; then
      printf "+++ generate %s file\n" "$FILEEXT"

      adoc_file="$folder/$FOLDER/$protected_filename-$protected_page.$FILEEXT"
      {
        echo "= ${filename} ${page}"
        echo ""
        echo "image::${protected_filename}-${protected_page}.${pagefileext}[${page}]"
        echo ""
      } >"$adoc_file"
      echo "$adoc_file"

      printf "+++ include links in %s file\n" "$FILEEXT"

      xmldata=$({
        printf "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x00"
        sgrep '"name=\"'"$page"'\""..">".."<"' "$path" | sed 's/<$//;s/.*">//' | base64 -d -w 0
      } | (gzip -dc 2>/dev/null || true) | sed 's@+@ @g;s@%@\\x@g')

      local linknum=0
      while read -r linkdata; do
        linknum=$((linknum + 1))
        local text="${linkdata//###*/}"
        local link="${linkdata//*###/}"
        printf "link %s : %s\n" "$linknum" "$link"
        printf "link text %s : %s\n" "$linknum" "$text"
        printf "* %s[%s]\n" "$link" "$text" >>"$adoc_file"
      done < <(
        printf "%b" "$xmldata" |
          sgrep '"<UserObject"..">"' |
          sed 's/<UserObject/\n/g' |
          sed 's/.*label="//g;s/" link="/###/g;s/".*//;/^$/d'
      )
    fi
  done < <(sgrep '"name=\"".."\""' "$path" | sed 's/^name="//;s/"name="/\n/g;s/"$//')
}

function export_file() {
  while read -r current_path; do
    echo "+ export file : $current_path"
    current_folder=$(dirname "$current_path")
    current_file=$(basename "$current_path")
    current_filename="${current_file%.*}"

    echo "++ prepare export folder : $current_folder/$FOLDER"
    mkdir -p "$current_folder/$FOLDER"

    export_pages "$current_path" "$current_folder" "$current_filename"
  done < <(find . -name "*.drawio" | sort)
}

command -v sgrep >/dev/null 2>&1 || {
  echo >&2 "I require sgrep but it's not installed.  Aborting."
  exit 1
}

args="${*}"
if [ -n "$args" ]; then
  # shellcheck disable=SC2086
  "$DRAWIO_CLI" --no-sandbox $args
  exit 0
fi

DEFAULT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck disable=SC1090
source "$DEFAULT_FOLDER/drawio-default.env"

FILEEXT=${DRAWIO_EXPORT_FILEEXT:-${DEFAULT_DRAWIO_EXPORT_FILEEXT}}
CLI_OPTIONS=${DRAWIO_EXPORT_CLI_OPTIONS:-${DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS}}
FOLDER=${DRAWIO_EXPORT_FOLDER:-${DEFAULT_DRAWIO_EXPORT_FOLDER}}

export_file
