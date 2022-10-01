#!/usr/bin/env bash
set -e

if [ "${ELECTRON_DISABLE_SECURITY_WARNINGS}" == "true" ]; then
  "$DRAWIO_DESKTOP_EXECUTABLE_PATH" --drawio-desktop-headless "$@" 3>&1 >&2 2>&3 3>&- |
    grep -v "Failed to connect to socket" |
    grep -v "Could not parse server address" |
    grep -v "Floss manager not present" |
    grep -v "Exiting GPU process" |
    grep -v "called with multiple threads" |
    grep -v "extension not supported" |
    grep -v "Failed to send GpuControl.CreateCommandBuffer"
else
  "$DRAWIO_DESKTOP_EXECUTABLE_PATH" --drawio-desktop-headless "$@" 2>&1
fi
