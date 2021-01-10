#!/usr/bin/env bash
#set -x
set -euo pipefail
IFS=$'\n\t'

#/ Usage: drawio-export [Options]
#/ Options:
#/   -E, --fileext <fileext>           Extension of exported files (default 'pdf').
#/                                     [adoc, jpg, pdf, png, svg, vsdx, xml]
#/   -F, --folder <folder>             Export folder name (default 'export').
#/   -h, --help                        Display this help message.
#/   --remove-page-suffix              Remove page suffix when possible
#/                                     (in case of single page file)
#/   --on-changes                      Export drawio files only if it's newer than exported files
#/
#/ Also support Draw.io CLI Options:
#/   [For all formats]
#/   -b, --border <border>             Sets the border width around the diagram (default: 0).
#/   -s, --scale <scale>               Scales the diagram size.
#/
#/   [Only for PDF format]
#/   --width <width>                   Fits the generated image/pdf into
#/                                     the specified width, preserves aspect ratio.
#/   --height <height>                 Fits the generated image/pdf into
#/                                     the specified height, preserves aspect ratio.
#/   --crop                            Crops PDF to diagram size.
#/
#/   [Only for PNG format]
#/   -e, --embed-diagram               Includes a copy of the diagram.
#/   -t, --transparent                 Set transparent background for PNG.
#/
#/   [Only for JPEG format]
#/   -q, --quality <quality>           Output image quality for JPEG (default: 90).
#/
#/   [Only for XML format]
#/   -u, --uncompressed                Uncompressed XML output.
#/
#/ Environment variables:
#/   DRAWIO_EXPORT_FILEEXT             Same as '--fileext', will be override
#/                                     if '--fileext' is set.
#/   DRAWIO_EXPORT_CLI_OPTIONS         Options for Draw.io CLI (default '--crop'),
#/                                     will be override if any CLI option is set.
#/   DRAWIO_EXPORT_FOLDER              Same as '--export-folder', will be override
#/                                     if '--export-folder' is set.
#/
#/ Deprecated Options:
#/   -C, --cli-options <options>       Options for Draw.io CLI (default '--crop'),
#/                                     See 'Draw.io CLI Options' section.
#/                                     DEPRECATED: only support one argument.
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

    export_drawio_pages "$path" "$folder" "$filename"

    echo "++ cleanup export content : $folder/$OUTPUT_FOLDER/${filename}*"
    find "$folder/$OUTPUT_FOLDER" -type f -name "${filename}*" -not -newer "$path" -delete

  done < <(find . -name "*.drawio" | sort)
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
  output_filename="$folder/$OUTPUT_FOLDER/$output_file"

  local should_retry=false
  if [ "$path" -nt "$output_filename.$export_type" ]; then
    should_retry=true
  fi

  if [ "$should_retry" == "false" ] && [ "$ON_CHANGES" == "true" ]; then
    printf "++ page %s is already exported (skip this file)\n" "$pagenum"
  else
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
  fi
}

export_diagram_file() {
  local export_type="$1"
  local path="$2"
  local pagenum="$3"
  local output_filename="$4"

  # shellcheck disable=SC2086
  DRAWIO_CLI_SUPPRESS_WARNINGS=true \
    "$SCRIPT_FOLDER/cli-runner.sh" \
    -x \
    -f "$export_type" \
    "${CLI_OPTIONS_ARRAY[*]}" \
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

SCRIPT_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
# shellcheck disable=SC1090
source "$SCRIPT_FOLDER/runner.env"
EXPORT_TYPE=${DRAWIO_EXPORT_FILEEXT:-${DEFAULT_DRAWIO_EXPORT_FILEEXT}}
CLI_OPTIONS=${DRAWIO_EXPORT_CLI_OPTIONS:-${DEFAULT_DRAWIO_EXPORT_CLI_OPTIONS}}
OUTPUT_FOLDER=${DRAWIO_EXPORT_FOLDER:-${DEFAULT_DRAWIO_EXPORT_FOLDER}}
REMOVE_PAGE_SUFFIX=false
ON_CHANGES=false
CLI_OPTIONS_ARRAY=()

set +e
GETOPT=$(getopt -o hE:F:q:teb:s:uC: -l help,fileext:,folder:,quality:,transparent,embed-diagram,border:,scale:,uncompressed,height:,width:,crop,remove-page-suffix,on-changes,cli-options: --name "draw-export" -- "$@")
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
  -E | --fileext)
    EXPORT_TYPE=$2
    shift 2
    ;;
  -F | --folder)
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
