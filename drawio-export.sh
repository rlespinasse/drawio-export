#!/usr/bin/env bash
#set -x
set -euo pipefail
IFS=$'\n\t'

#/ Usage: drawio-export [Options]
#/ Options:
#/   -E, --fileext <fileext>           Extension of exported files (default 'pdf').
#/                                     pdf, png, jpg, svg, vsdx, adoc
#/   -C, --cli-options <options>       Options for Draw.io CLI (default '--crop'),
#/                                     see 'Draw.io CLI Options' section.
#/   -F, --folder <folder>             Export folder name (default 'export').
#/   -h, --help                        Display this help message.
#/
#/ Draw.io CLI Options:
#/   -q, --quality <quality>           Output image quality for JPEG (default: 90).
#/   -t, --transparent                 Set transparent background for PNG.
#/   -e, --embed-diagram               Includes a copy of the diagram (for PNG format only).
#/   -b, --border <border>             Sets the border width around the diagram (default: 0).
#/   -s, --scale <scale>               Scales the diagram size.
#/   --width <width>                   Fits the generated image/pdf into the specified width, preserves aspect ratio.
#/   --height <height>                 Fits the generated image/pdf into the specified height, preserves aspect ratio.
#/   --crop                            Crops PDF to diagram size.
#/
#/ Environment variables:
#/   DRAWIO_EXPORT_FILEEXT             Same as '--fileext', will be override if '--fileext' is set.
#/   DRAWIO_EXPORT_CLI_OPTIONS         Same as '--cli-options', will be override if '--cli-options' is set.
#/   DRAWIO_EXPORT_FOLDER              Same as '--export-folder', will be override if '--export-folder' is set.
usage() {
  grep '^#/' "$0" | cut -c4-
}

# ----------------------------------------------------

export_drawio_files() {
  local folder
  local file
  local filename

  while read -r path; do
    echo "+ export file : $path"
    folder=$(dirname "$path")
    file=$(basename "$path")
    filename="${file%.*}"

    echo "++ prepare export folder : $folder/$OUTPUT_FOLDER"
    mkdir -p "$folder/$OUTPUT_FOLDER"

    echo "++ cleanup export content : $folder/$OUTPUT_FOLDER/${filename}*"
    find "$folder/$OUTPUT_FOLDER" -type f -name "${filename}*" -delete

    export_drawio_pages "$path" "$folder" "$filename"
  done < <(find . -name "*.drawio" | sort)
}

export_drawio_pages() {
  local path="$1"
  local folder="$2"
  local filename="$3"

  local pagenum=0
  while read -r page; do
    pagenum=$((pagenum + 1))
    export_drawio_page "$pagenum" "$page" "$filename" "$path" "$folder"
  done < <(sgrep '"name=\"".."\""' "$path" | sed 's/^name="//;s/"name="/\n/g;s/"$//')
}

export_drawio_page() {
  local pagenum="$1"
  local page="$2"
  local filename="$3"
  local path="$4"
  local folder="$5"

  local export_type="$EXPORT_TYPE"
  if [ "$EXPORT_TYPE" == "adoc" ]; then
    export_type="png"
  fi

  local output_file
  local output_filename
  output_file="${filename// /-}-${page// /-}"
  output_filename="$folder/$OUTPUT_FOLDER/$output_file"

  printf "++ export page %s : %s\n" "$pagenum" "$page"
  printf "+++ generate %s file\n" "$export_type"
  export_diagram_file "$export_type" "$path" "$pagenum" "$output_filename"

  if [ "$EXPORT_TYPE" == "adoc" ]; then
    echo "+++ generate adoc file"
    create_asciidoc_page "$path" "$filename" "$page" "$output_filename" "$output_file"
    echo "image '$output_file.png'"

    echo "+++ include links in adoc file"
    include_links_in_asciidoc_page "$path" "$page" "$output_filename"
  fi
}

export_diagram_file() {
  local export_type="$1"
  local path="$2"
  local pagenum="$3"
  local output_filename="$4"

  # shellcheck disable=SC2086
  "$DRAWIO_CLI" \
    --no-sandbox \
    --disable-dev-shm-usage \
    -x \
    -f "$export_type" \
    $CLI_OPTIONS \
    -p "$((pagenum - 1))" \
    -o "$output_filename.$export_type" \
    "$path" 2> >(
      # Remove Election 9 deprecation warnings from error output
      grep -v "allowRendererProcessReuse is deprecated" |
        grep -v "DeprecationWarning: Passing functions"
    )
}

create_asciidoc_page() {
  local path="$1"
  local filename="$2"
  local page="$3"
  local output_filename="$4"
  local output_file="$5"

  {
    echo "= ${filename} ${page}"
    echo ""
    echo "image::${output_file}.png[${page}]"
    echo ""
  } >"$output_filename.adoc"
  echo "$output_filename.adoc"
}

include_links_in_asciidoc_page() {
  local path="$1"
  local page="$2"
  local output_filename="$3"

  local rawxml
  rawxml=$(get_rawxml_diagram_page "$path" "$page")

  local linknum=0
  while read -r linkdata; do
    linknum=$((linknum + 1))
    include_link_in_asciidoc_page "$linknum" "$linkdata" "$output_filename"
  done < <(
    printf "%b" "$rawxml" |
      sgrep '"<UserObject"..">"' |
      sed 's/<UserObject/\n/g' |
      sed 's/.*label="//g;s/" link="/'"$link_separator"'/g;s/".*//;/^$/d'
  )
}

get_rawxml_diagram_page() {
  local path="$1"
  local page="$2"

  {
    printf "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x00"
    sgrep '"name=\"'"$page"'\""..">".."<"' "$path" | sed 's/<$//;s/.*">//' | base64 -d -w 0
  } | (gzip -dc 2>/dev/null || true) | sed 's@+@ @g;s@%@\\x@g'
}

include_link_in_asciidoc_page() {
  local linknum="$1"
  local linkdata="$2"
  local output_filename="$3"

  local link
  link=$(
    echo "$linkdata" |
      # Isolate the link
      sed 's/.*'"$link_separator"'//' |
      # Clean <br>
      sed 's/&lt;br&gt;\?/ /g' |
      # Clean &nbsp;
      sed 's/&amp;nbsp;/ /g' |
      # Clean <div>text</div>
      sed 's/&lt;div&gt;/ /g;s/&lt;\/div&gt;\?/ /g' |
      # Manage '--' (Em dash) string in asciidoc
      sed 's/\([^-]\+\)\(--\)/\1\\\2/g' |
      # Trim space
      sed 's/\s\+/ /g;s/^\s//;s/\s$//'
  )

  local text
  text=$(
    echo "$linkdata" |
      # Isolate the link text
      sed 's/'"$link_separator"'.*//' |
      # Clean <br>
      sed 's/&lt;br&gt;\?/ /g' |
      # Clean &nbsp;
      sed 's/&amp;nbsp;/ /g' |
      # Clean <div>text</div>
      sed 's/&lt;div&gt;/ /g;s/&lt;\/div&gt;\?/ /g' |
      # Manage '--' (Em dash) string in asciidoc
      sed 's/\([^-]\+\)\(--\)/\1\\\2/g' |
      # Trim space
      sed 's/\s\+/ /g;s/^\s//;s/\s$//'
  )

  printf "link text %s : %s\n" "$linknum" "$text"
  if [ "$link" == "$text" ]; then
    echo >&2 "WARNING: link is the same as the link text"
  elif [ "$link" == "" ]; then
    echo >&2 "WARNING: link is empty"
  elif [ "${link//,*/}" == "data:page/id" ]; then
    echo >&2 "WARNING: link between pages is not currently supported"
  else
    printf "link %s : %s\n" "$linknum" "$link"
    printf "* %s[%s]\n" "$link" "$text" >>"$output_filename.adoc"
  fi
}

# ----------------------------------------------------

# shellcheck disable=SC1090
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/drawio-default.env"
EXPORT_TYPE=${DRAWIO_EXPORT_FILEEXT:-${DEFAULT_DRAWIO_EXPORT_FILEEXT}}
CLI_OPTIONS=${DRAWIO_EXPORT_CLI_OPTIONS:-${DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS}}
OUTPUT_FOLDER=${DRAWIO_EXPORT_FOLDER:-${DEFAULT_DRAWIO_EXPORT_FOLDER}}

set +e
GETOPT=$(getopt -o hE:C:F: -l help,fileext:,cli-options:,folder: --name "draw-export" -- "$@")
# shellcheck disable=SC2181
if [ $? != 0 ]; then
  echo "Failed to parse options...exiting." >&2
  usage
  exit 1
fi
set -e

eval set -- "$GETOPT"
while true; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  -E | --fileext)
    EXPORT_TYPE=$2
    shift 2
    ;;
  -C | --cli-options)
    CLI_OPTIONS=$2
    shift 2
    ;;
  -F | --folder)
    OUTPUT_FOLDER=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  esac
done

link_separator='###'

if [ -z "${DRAWIO_CLI:-}" ]; then
  echo >&2 "define DRAWIO_CLI as the path to draw.io desktop application"
  exit 1
fi

command -v sgrep >/dev/null 2>&1 || {
  echo >&2 "I require sgrep but it's not installed.  Aborting."
  exit 1
}

export_drawio_files
