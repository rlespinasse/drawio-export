#!/usr/bin/env bash
set -e

filter_electron_security_warnings() {
  while read -r line; do
    echo "$line" | grep -v "is deprecated and will be changing"
  done
}

if [ "${ELECTRON_DISABLE_SECURITY_WARNINGS}" == "true" ]; then
  "$DRAWIO_DESKTOP_EXECUTABLE_PATH" --drawio-desktop-headless "$@" 2> >(filter_electron_security_warnings)
else
  "$DRAWIO_DESKTOP_EXECUTABLE_PATH" --drawio-desktop-headless "$@" 2>&1
fi
