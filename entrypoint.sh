#!/usr/bin/env bash
set -e

# Start Xvfb
Xvfb -ac -screen scrn 1280x2000x24 :9.0 2>/dev/null &
export DISPLAY=:9.0

exec /drawio/drawio-export.sh "$@"
