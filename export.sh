#!/usr/bin/env bash
#set -x
set -euo pipefail
IFS=$'\n\t'

#/ Usage: drawio-export [Options] PATH
#/
#/ Arguments:
#/   PATH                          Path to the drawio files to export (default '.')
#/
#/ Options:
#/   -f, --format <format>         Extension of exported files (default 'pdf').
#/                                 [adoc, jpg, pdf, png, svg, vsdx, xml]
#/   -o, --output <folder>         Exported folder name (default 'export').
#/   -h, --help                    Display this help message.
#/   --remove-page-suffix          Remove page suffix when possible
#/                                 (in case of single page file)
#/   --on-changes                  Export drawio files only if it's newer than exported files
#/   --git-ref <reference>         Any git reference (branch, tag, commit it, ...)
#/                                 Need to be used with --on-changes in a git repository
#/
#/ Also support Draw.io CLI Options:
#/   [For all formats]
#/   -b, --border <border>         Sets the border width around the diagram (default: 0).
#/   -s, --scale <scale>           Scales the diagram size.
#/
#/   [Only for PDF format]
#/   --width <width>               Fits the generated image/pdf into
#/                                 the specified width, preserves aspect ratio.
#/   --height <height>             Fits the generated image/pdf into
#/                                 the specified height, preserves aspect ratio.
#/   --crop                        Crops PDF to diagram size.
#/
#/   [Only for PNG format]
#/   -e, --embed-diagram           Includes a copy of the diagram.
#/   -t, --transparent             Set transparent background for PNG.
#/
#/   [Only for JPEG format]
#/   -q, --quality <quality>       Output image quality for JPEG (default: 90).
#/
#/   [Only for XML format]
#/   -u, --uncompressed            Uncompressed XML output.
#/
#/ Environment variables:
#/   DRAWIO_EXPORT_FILEEXT         Same as '--fileext', will be override
#/                                 if '--fileext' is set.
#/   DRAWIO_EXPORT_CLI_OPTIONS     Options for Draw.io CLI (default '--crop'),
#/                                 will be override if any CLI option is set.
#/   DRAWIO_EXPORT_FOLDER          Same as '--export-folder', will be override
#/                                 if '--export-folder' is set.
#/
#/ Deprecated Options:
#/   -E, --fileext <fileext>       DEPRECATED: Use -f, --format <format> instead
#/   -F, --folder <folder>         DEPRECATED: Use -o, --output <folder> instead
#/   --path <path>                 DEPRECATED: Use argument PATH instead
#/   -C, --cli-options <options>   DEPRECATED: Use specfic argument instead
usage() {
  grep '^#/' "$0" | cut -c4-
}

# ----------------------------------------------------

get_drawio_filepaths() {

  if [ -n "${GIT_REF:-}" ]; then
    get_drawio_filepaths_using_git | sort -u
  else
    get_drawio_filepaths_using_find | sort
  fi
}

get_drawio_filepaths_using_git() {
  local drawio_path="$DRAWIO_PATH"
  if [ "$drawio_path" == "." ]; then
    drawio_path=""
  fi
  while read -r filepath; do
    if [ -f "${filepath}" ]; then
      echo "$filepath"
    fi
  done \
    < \
    <({
      git diff --name-only --cached
      git diff --name-only "$GIT_REF"..HEAD
    } | grep "^${drawio_path}" | grep ".drawio$")
}

get_drawio_filepaths_using_find() {
  while read -r filepath; do
    if [ "${ON_CHANGES}" == "true" ]; then
      folder=$(dirname "$filepath")
      file=$(basename "$filepath")
      filename="${file%.*}"

      mkdir -p "$folder/$OUTPUT_FOLDER"
      if [ -n "$(find "$folder/$OUTPUT_FOLDER" -type f -name "${filename}*${EXPORT_TYPE}" -not -newer "$filepath")" ]; then
        echo "$filepath"
      fi
    else
      echo "$filepath"
    fi
  done \
    < \
    <(find "$DRAWIO_PATH" -name "*.drawio")
}

export_drawio_files() {
  local folder
  local file
  local filename

  while read -r path; do
    echo "+ export file : $path"
    folder=$(dirname "$path")
    file=$(basename "$path")
    filename="${file%.*}"

    export_drawio_pages "$path" "$folder" "$filename"

  done < <(get_drawio_filepaths)
}

export_drawio_pages() {
  local path="$1"
  local folder="$2"
  local filename="$3"

  local pagenum=0

  local page_suffix=true
  if [ "$REMOVE_PAGE_SUFFIX" == "true" ] && [ "$(sgrep -c '"name=\"".."\""' "$path")" -eq 1 ]; then
    page_suffix=false
  fi

  while read -r page; do
    pagenum=$((pagenum + 1))
    export_drawio_page "$pagenum" "$page" "$filename" "$path" "$folder" "$page_suffix"
  done < <(sgrep '"name=\"".."\""' "$path" | sed 's/^name="//;s/"name="/\n/g;s/"$//')
}

export_drawio_page() {
  local pagenum="$1"
  local page="$2"
  local filename="$3"
  local path="$4"
  local folder="$5"
  local page_suffix="$6"

  local export_type="$EXPORT_TYPE"
  if [ "$EXPORT_TYPE" == "adoc" ]; then
    export_type="png"
  fi

  local output_file
  local output_filename
  if [ "$page_suffix" == "true" ]; then
    output_file="${filename// /-}-${page// /-}"
  else
    output_file="${filename// /-}"
  fi
  mkdir -p "$folder/$OUTPUT_FOLDER"
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
  "$SCRIPT_FOLDER/runner.sh" \
    -x \
    -f "$export_type" \
    "${CLI_OPTIONS_ARRAY[@]}" \
    $CLI_OPTIONS \
    -p "$((pagenum - 1))" \
    -o "$output_filename.$export_type" \
    "$path" \
    --disable-dev-shm-usage
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

  local diagramdata
  diagramdata="$(sgrep '"name=\"'"$page"'\""..">".."<"' "$path" | sed 's/<$//;s/.*">//;s/^\s*//;s/\s*$//;/^$/d')"

  local xmldata
  local xmlprint
  if [ -n "$diagramdata" ]; then
    xmldata=$(get_rawxml_diagram_page "$diagramdata" "$page")
    xmlprint="%b"
  else
    xmldata=$(tr -d '\n' <"$path" | sgrep '"name=\"'"$page"'\""..">".."</diagram"')
    xmlprint="%s"
  fi

  local linknum=0
  while read -r linkdata; do
    linknum=$((linknum + 1))
    include_link_in_asciidoc_page "$linknum" "$linkdata" "$output_filename"
  done < <(
    # shellcheck disable=SC2059
    printf "$xmlprint" "$xmldata" |
      sgrep '"<UserObject"..">"' |
      sed 's/<UserObject/\n/g' |
      sed 's/.*label="//g;s/" link="/'"$link_separator"'/g;s/".*//;/^$/d'
  )
}

get_rawxml_diagram_page() {
  local data="$1"
  local page="$2"

  {
    printf "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x00"
    echo "$data" | base64 -d -w 0
  } | (gzip -dc 2>/dev/null || true) | sed 's@+@ @g;s@%@\\x@g'
}

cleanup_link() {
  echo "${1}" |
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
}

include_link_in_asciidoc_page() {
  local linknum="$1"
  local linkdata="$2"
  local output_filename="$3"

  local link
  # shellcheck disable=SC2001
  link=$(cleanup_link "$(echo "$linkdata" | sed 's/.*'"$link_separator"'//')")

  local text
  # shellcheck disable=SC2001
  text=$(cleanup_link "$(echo "$linkdata" | sed 's/'"$link_separator"'.*//')")

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

SCRIPT_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
# shellcheck disable=SC1090
source "$SCRIPT_FOLDER/export.env"

SHOW_DEPRECATED_MESSAGE=false
if [ -n "${DRAWIO_EXPORT_FILEEXT:-}" ] || [ -n "${DRAWIO_EXPORT_CLI_OPTIONS:-}" ] || [ -n "${DRAWIO_EXPORT_FOLDER:-}" ]; then
  SHOW_DEPRECATED_MESSAGE=true
fi
EXPORT_TYPE=${DRAWIO_EXPORT_FILEEXT:-${DEFAULT_DRAWIO_EXPORT_FILEEXT}}
CLI_OPTIONS=${DRAWIO_EXPORT_CLI_OPTIONS:-${DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS}}
OUTPUT_FOLDER=${DRAWIO_EXPORT_FOLDER:-${DEFAULT_DRAWIO_EXPORT_FOLDER}}
REMOVE_PAGE_SUFFIX=false
ON_CHANGES=false
GIT_REF=
DRAWIO_PATH=.
CLI_OPTIONS_ARRAY=()

set +e
GETOPT=$(getopt -o hf:E:o:F:q:teb:s:uC: -l help,format:,fileext:,output:,folder:,quality:,transparent,embed-diagram,border:,scale:,uncompressed,height:,width:,crop,remove-page-suffix,on-changes,git-ref:,path:,cli-options: --name "draw-export" -- "$@")
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
  # Draw.io Export options
  -h | --help)
    usage
    exit 0
    ;;
  -f | --format)
    EXPORT_TYPE=$2
    shift 2
    ;;
  -E | --fileext)
    SHOW_DEPRECATED_MESSAGE=true
    EXPORT_TYPE=$2
    shift 2
    ;;
  -o | --output)
    OUTPUT_FOLDER=$2
    shift 2
    ;;
  -F | --folder)
    SHOW_DEPRECATED_MESSAGE=true
    OUTPUT_FOLDER=$2
    shift 2
    ;;
  --remove-page-suffix)
    REMOVE_PAGE_SUFFIX=true
    shift
    ;;
  --on-changes)
    ON_CHANGES=true
    shift
    ;;
  --git-ref)
    GIT_REF=$2
    shift 2
    ;;
  --path)
    SHOW_DEPRECATED_MESSAGE=true
    DRAWIO_PATH=$2
    shift 2
    ;;
  # Draw.io CLI options
  -q | --quality)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-q")
    CLI_OPTIONS_ARRAY+=("$2")
    shift 2
    ;;
  -t | --transparent)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-t")
    shift
    ;;
  -e | --embed-diagram)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-e")
    shift
    ;;
  -b | --border)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-b")
    CLI_OPTIONS_ARRAY+=("$2")
    shift 2
    ;;
  -s | --scale)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-s")
    CLI_OPTIONS_ARRAY+=("$2")
    shift 2
    ;;
  -u | --uncompressed)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("-u")
    shift
    ;;
  --width)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("--width")
    CLI_OPTIONS_ARRAY+=("$2")
    shift 2
    ;;
  --height)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("--height")
    CLI_OPTIONS_ARRAY+=("$2")
    shift 2
    ;;
  --crop)
    CLI_OPTIONS=""
    CLI_OPTIONS_ARRAY+=("--crop")
    shift
    ;;
  # Deprecated options
  -C | --cli-options)
    SHOW_DEPRECATED_MESSAGE=true
    CLI_OPTIONS=$2
    shift 2
    ;;
  # Others
  --)
    shift
    break
    ;;
  esac
done

if [ -n "${1:-}" ]; then
  DRAWIO_PATH="${1}"
fi

link_separator='###'

if [ -z "${DRAWIO_DESKTOP_EXECUTABLE_PATH:-}" ]; then
  echo >&2 "define DRAWIO_DESKTOP_EXECUTABLE_PATH as the path to draw.io desktop application"
  exit 1
fi

if [ "${SHOW_DEPRECATED_MESSAGE}" == "true" ]; then
  echo >&2 "WARN: Consider not using a deprecated option, it's will be removed in the next major version."
  echo >&2 "WARN: Print help for more information."
fi

command -v sgrep >/dev/null 2>&1 || {
  echo >&2 "I require sgrep but it's not installed.  Aborting."
  exit 1
}

if [ -n "${GIT_REF:-}" ]; then
  if ! git -C . rev-parse >/dev/null 2>/dev/null; then
    echo "--git-ref need a git repository to work with"
    exit 1
  elif ! git rev-parse --verify "$GIT_REF" >/dev/null 2>/dev/null; then
    echo "--git-ref need a valid git reference"
    exit 1
  elif [ "$ON_CHANGES" == "false" ]; then
    echo "--git-ref to be used with --on-changes"
    exit 1
  fi
fi

if [ -n "${DRAWIO_PATH:-}" ]; then
  if [ ! -f "$DRAWIO_PATH" ] && [ ! -d "$DRAWIO_PATH" ]; then
    echo "Path '${DRAWIO_PATH}' must exists (as directory or file)"
    exit 1
  fi
fi

export_drawio_files
