#!/usr/bin/env bash
set -euo pipefail

exec /opt/drawio/drawio "$@" --disable-gpu \
  --disable-features=VaapiVideoDecoder,VaapiVideoEncoder \
  --disable-accelerated-video-decode --disable-accelerated-video-encode
