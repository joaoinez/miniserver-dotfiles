#!/usr/bin/env bash
# sanitize-audio.sh
#
# Must be run from a directory that contains an `in` folder.
# Walks every immediate subdirectory of `in`, calls `opencode run` with the
# audio-sanitizer agent for each album, and writes sanitized files to
# `out/<artist>/<album>/` next to `in`.
#
# The opencode agent is locked down to ffprobe, ffmpeg, mv, mkdir, and read
# operations, and is instructed to only touch the given album folder and the
# corresponding output directory.

set -euo pipefail

CWD="$(pwd)"
INPUT_DIR="$CWD/in"
OUTPUT_DIR="$CWD/out"

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Error: no 'in' directory found in $(pwd)" >&2
  echo "Run this script from the directory that contains 'in'." >&2
  exit 1
fi

if ! command -v opencode &>/dev/null; then
  echo "Error: opencode is not installed or not in PATH" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Input:  $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

album_count=0
error_count=0

while IFS= read -r -d '' album_dir; do
  album_name="$(basename "$album_dir")"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Album: $album_name"
  echo "Path:  $album_dir"
  echo ""

  if opencode run \
    --agent audio-sanitizer \
    "Sanitize all audio files in this album folder and write the results to the output directory. Album folder: $album_dir. Output root: $OUTPUT_DIR" \
    2>&1; then
    ((album_count++)) || true
  else
    echo "Warning: opencode returned non-zero for: $album_name" >&2
    ((error_count++)) || true
  fi

  echo ""
done < <(find "$INPUT_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done. Albums processed: $album_count  Errors: $error_count"
