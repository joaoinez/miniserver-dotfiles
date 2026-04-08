#!/usr/bin/env bash
# organize-tracks.sh
#
# Run from a directory containing scattered audio files.
# Reads artist and album metadata from each file in the current directory
# (non-recursively) and moves it into artist/album subdirectories.
#
# Files with no artist tag  -> "Unknown Artist/"
# Files with no album tag   -> "Singles/"
#
# Example:
#   cd ~/Music/unsorted && organize-tracks.sh

set -euo pipefail

if ! command -v ffprobe &>/dev/null; then
  echo "Error: ffprobe must be installed and in PATH" >&2
  exit 1
fi

CWD="$(pwd)"

# Returns 0 if file has an audio stream, 1 otherwise
is_audio_file() {
  local file="$1"
  ffprobe -v error -select_streams a:0 -show_entries stream=codec_type \
    -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q audio
}

moved=0
skipped=0
errors=0

while IFS= read -r -d '' src; do
  filename="$(basename "$src")"

  # Skip non-audio / cover / playlist files
  case "$filename" in
  folder.jpg | cover.jpg | *.m3u | *.m3u8 | *.jpg | *.jpeg | *.png | *.pdf | *.txt | *.log | *.cue)
    echo "  skip  $filename"
    ((skipped++)) || true
    continue
    ;;
  esac

  if ! is_audio_file "$src"; then
    echo "  skip  $filename (not an audio stream)"
    ((skipped++)) || true
    continue
  fi

  # Read embedded tags
  tag_artist="$(ffprobe -v error -show_entries format_tags=artist \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"
  tag_album="$(ffprobe -v error -show_entries format_tags=album \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"

  final_artist="${tag_artist:-Unknown Artist}"
  final_album="${tag_album:-Singles}"

  dest_dir="$CWD/$final_artist/$final_album"
  dest_file="$dest_dir/$filename"

  mkdir -p "$dest_dir"

  if [[ -e "$dest_file" ]]; then
    echo "  skip  $filename (already exists at $dest_file)"
    ((skipped++)) || true
    continue
  fi

  if mv "$src" "$dest_file"; then
    printf "  moved %-45s -> %s/%s\n" "$filename" "$final_artist" "$final_album"
    ((moved++)) || true
  else
    echo "  ERROR $filename" >&2
    ((errors++)) || true
  fi

done < <(find "$CWD" -maxdepth 1 -type f -print0 | sort -z)

echo ""
echo "Done. Moved: $moved  Skipped: $skipped  Errors: $errors"
