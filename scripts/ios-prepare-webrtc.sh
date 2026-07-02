#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${ROOT_DIR}/apps/ios/Vendor/WebRTC"
ZIP_PATH="${VENDOR_DIR}/WebRTC-M147.xcframework.zip"
FRAMEWORK_DIR="${VENDOR_DIR}/WebRTC.xcframework"
URL="https://github.com/stasel/WebRTC/releases/download/147.0.0/WebRTC-M147.xcframework.zip"
CHECKSUM="49f9b1713432c19f408e3218fc8526c7692fafca5869f7ec5f5991614276ed40"

if [[ -f "${FRAMEWORK_DIR}/Info.plist" ]]; then
  echo "WebRTC binary already prepared: ${FRAMEWORK_DIR}"
  exit 0
fi

mkdir -p "${VENDOR_DIR}"

if [[ ! -f "${ZIP_PATH}" ]]; then
  echo "Downloading WebRTC M147 binary..."
  curl -L --fail --show-error -o "${ZIP_PATH}" "${URL}"
fi

actual_checksum="$(swift package compute-checksum "${ZIP_PATH}")"
if [[ "${actual_checksum}" != "${CHECKSUM}" ]]; then
  echo "ERROR: WebRTC checksum mismatch." >&2
  echo "Expected: ${CHECKSUM}" >&2
  echo "Actual:   ${actual_checksum}" >&2
  exit 1
fi

ditto -x -k "${ZIP_PATH}" "${VENDOR_DIR}"

if [[ ! -f "${FRAMEWORK_DIR}/Info.plist" ]]; then
  echo "ERROR: WebRTC.xcframework was not extracted correctly." >&2
  exit 1
fi

echo "Prepared WebRTC binary: ${FRAMEWORK_DIR}"
