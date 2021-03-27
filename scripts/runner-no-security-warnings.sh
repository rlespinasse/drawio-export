#!/usr/bin/env bash
set -e

"$DRAWIO_DESKTOP_EXECUTABLE_PATH" --drawio-desktop-headless "$@" 2>&1
