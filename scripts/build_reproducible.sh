#!/usr/bin/env bash
set -euo pipefail

SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
BUILD="/tmp/com.domai_tb.openplants"

[[ -f "$SOURCE/android/key.properties" ]] || {
  echo 'android/key.properties is required for a signed release build.' >&2
  exit 1
}

rm -rf -- "$BUILD"
mkdir -m 700 -- "$BUILD"
rsync -a \
  --exclude='.git/' --exclude='.fvm/' --exclude='.dart_tool/' \
  --exclude='.gradle/' --exclude='build/' --exclude='.flutter-plugins*' \
  --exclude='android/local.properties' --exclude='scripts/.venv/' \
  "$SOURCE/" "$BUILD/"

cd "$BUILD"
fvm flutter pub get --enforce-lockfile
fvm flutter build apk --release "$@"
