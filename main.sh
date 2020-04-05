#!/usr/bin/env bash
set -eo pipefail
set -u
IFS=$'\n\t'

if [ -z "${DRAWIO_CLI:-}" ]; then
    >&2 echo "define DRAWIO_CLI as the path to draw.io desktop application"
    exit 1
fi

function export_pages() {
    path="$1"
    folder="$2"
    filename="$3"

    pagenum=0
    while read -r page
    do
        pagenum=$((pagenum + 1))
        printf "export page %s > " "$pagenum"
        # shellcheck disable=SC2086
        "$DRAWIO_CLI" \
            -x \
            -f "$FILEEXT" \
            $CLI_OPTIONS \
            -p "$pagenum" \
            -o "$folder/$FOLDER/$filename-$page.$FILEEXT" \
            "$path" 2>/dev/null
    done < <(sgrep '"name=\"".."\""' "$path" | sed 's/^name="//;s/"name="/\n/g;s/"$//')
}

function export_file() {
    while read -r current_path
    do
        current_folder=$(dirname "$current_path")
        current_file=$(basename "$current_path")
        current_filename="${current_file%.*}"

        echo "prepare '$current_folder/$FOLDER' folder"
        mkdir -p "$current_folder/$FOLDER"

        echo "cleanup '$current_folder/$FOLDER/$current_filename-*' content"
        find "$current_folder/$FOLDER" -name "$current_filename-*" -delete

        export_pages "$current_path" "$current_folder" "$current_filename"
    done < <(find . -name "*.drawio" | sort)
}

command -v sgrep >/dev/null 2>&1 || { echo >&2 "I require sgrep but it's not installed.  Aborting."; exit 1; }

args="${*}"
if [ -n "$args" ]; then
    # shellcheck disable=SC2086
    "$DRAWIO_CLI" $args
    exit 0
fi

DEFAULT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DEFAULT_FOLDER/default.env"

FILEEXT=${DRAWIO_EXPORT_FILEEXT:-${DEFAULT_DRAWIO_EXPORT_FILEEXT}}
CLI_OPTIONS=${DRAWIO_EXPORT_CLI_OPTIONS:-${DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS}} 
FOLDER=${DRAWIO_EXPORT_FOLDER:-${DEFAULT_DRAWIO_EXPORT_FOLDER}}

export_file
