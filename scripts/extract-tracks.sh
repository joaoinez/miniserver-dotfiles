#!/usr/bin/env bash

set -euo pipefail

mkdir -p in

for zip in *.zip; do
  [ -e "$zip" ] || {
    echo "No zip files found."
    exit 0
  }
  echo "Extracting: $zip"
  unzip -o "$zip" -d in
done
