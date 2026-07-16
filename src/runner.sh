#!/usr/bin/env bash
set -euo pipefail

"${DRAWIO_DESKTOP_EXECUTABLE_PATH:?}" --drawio-desktop-headless "$@" --no-sandbox --disable-gpu \
  --disable-features=VaapiVideoDecoder,VaapiVideoEncoder \
  --disable-accelerated-video-decode --disable-accelerated-video-encode
