#!/usr/bin/env bash
set -euo pipefail

"${DRAWIO_DESKTOP_EXECUTABLE_PATH:?}" --drawio-desktop-headless \
  --application /opt/drawio-exporter/drawio-desktop-wrapper.sh "$@"
