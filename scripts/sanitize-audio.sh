#!/usr/bin/env bash
# sanitize-audio.sh <parser>
#
# Must be run from a directory that contains an `in` folder.
# Walks every audio file in every immediate subdirectory of `in/` and
# writes sanitized files (corrected metadata, clean filename) to `out/`.
#
# <parser> is the name of a file in ~/dotfiles/scripts/audio-parsers/,
# without the .sh extension. Example:
#
#   sanitize-audio.sh track-artist-song
#
# The parser file must define a parse_filename() function that sets
# PARSED_TRACK and PARSED_TITLE. Run with no arguments to see available parsers.

set -euo pipefail

PARSERS_DIR="$HOME/dotfiles/scripts/audio-parsers"

# --- Argument handling ---
if [[ $# -eq 0 ]]; then
  echo "Usage: sanitize-audio.sh <parser>" >&2
  echo "" >&2
  echo "Available parsers:" >&2
  for f in "$PARSERS_DIR"/*.sh; do
    name="$(basename "$f" .sh)"
    desc="$(grep '^# Handles:' "$f" | sed 's/^# Handles: //')"
    printf "  %-30s %s\n" "$name" "$desc" >&2
  done
  exit 1
fi

PARSER_NAME="$1"
PARSER_FILE="$PARSERS_DIR/$PARSER_NAME.sh"

if [[ ! -f "$PARSER_FILE" ]]; then
  echo "Error: parser '$PARSER_NAME' not found at $PARSER_FILE" >&2
  exit 1
fi

# Source the parser — defines parse_filename()
# shellcheck source=/dev/null
source "$PARSER_FILE"

# Verify the function was actually defined
if ! declare -f parse_filename &>/dev/null; then
  echo "Error: $PARSER_FILE did not define a parse_filename() function" >&2
  exit 1
fi

# --- Paths ---
CWD="$(pwd)"
INPUT_DIR="$CWD/in"
OUTPUT_DIR="$CWD/out"

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Error: no 'in' directory found in $(pwd)" >&2
  echo "Run this script from the directory that contains 'in'." >&2
  exit 1
fi

if ! command -v ffmpeg &>/dev/null || ! command -v ffprobe &>/dev/null; then
  echo "Error: ffmpeg and ffprobe must be installed and in PATH" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# --- Helpers ---

# Returns 0 if file has an audio stream, 1 otherwise
is_audio_file() {
  local file="$1"
  ffprobe -v error -select_streams a:0 -show_entries stream=codec_type \
    -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q audio
}

# Returns 0 if file has an embedded image stream, 1 otherwise
has_embedded_image() {
  local file="$1"
  ffprobe -v error -select_streams v:0 -show_entries stream=codec_type \
    -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q video
}

# Finds a single cover image in a directory.
# Sets COVER_IMAGE to the path, or "" if none found.
# Prints a warning and returns 1 if multiple images are found.
find_cover_image() {
  local dir="$1"
  COVER_IMAGE=""
  local images=()
  while IFS= read -r -d '' f; do
    images+=("$f")
  done < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 | sort -z)

  if [[ ${#images[@]} -gt 1 ]]; then
    echo "  WARNING: multiple cover images found in $(basename "$dir") — skipping embed. Remove all but one:" >&2
    for img in "${images[@]}"; do
      echo "    $(basename "$img")" >&2
    done
    return 1
  fi

  [[ ${#images[@]} -eq 1 ]] && COVER_IMAGE="${images[0]}"
  return 0
}

process_file() {
  local src="$1"
  local cover="${2:-}" # optional path to a cover image
  local filename
  filename="$(basename "$src")"
  local ext="${filename##*.}"

  # Skip non-audio and cover/playlist files
  case "$filename" in
  folder.jpg | cover.jpg | *.m3u | *.m3u8 | *.jpg | *.jpeg | *.png | *.pdf | *.txt | *.log | *.cue)
    echo "  skip  $filename"
    return 0
    ;;
  esac

  if ! is_audio_file "$src"; then
    echo "  skip  $filename (not an audio stream)"
    return 0
  fi

  # --- Read embedded tags via ffprobe ---
  local tag_track tag_title tag_artist tag_album
  tag_track="$(ffprobe -v error -show_entries format_tags=track \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"
  tag_title="$(ffprobe -v error -show_entries format_tags=title \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"
  tag_artist="$(ffprobe -v error -show_entries format_tags=artist \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"
  tag_album="$(ffprobe -v error -show_entries format_tags=album \
    -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null | head -1 || true)"

  # --- Run filename parser ---
  PARSED_TRACK=""
  PARSED_TITLE=""
  parse_filename "$filename"

  # --- Resolve final values ---
  local final_track final_title final_artist final_album

  # Track number: prefer embedded tag, fall back to parsed
  if [[ -n "$tag_track" && "$tag_track" =~ ^[1-9][0-9]*$ ]]; then
    final_track="$tag_track"
  else
    final_track="${PARSED_TRACK:-}"
  fi

  # Title: prefer embedded tag, fall back to parsed filename
  if [[ -n "$tag_title" ]]; then
    final_title="$tag_title"
  else
    final_title="${PARSED_TITLE:-${filename%.*}}"
  fi

  # Artist / album: embedded only (no filename fallback for these)
  final_artist="${tag_artist:-Unknown Artist}"
  final_album="${tag_album:-Singles}"

  # --- Build output path ---
  local out_dir="$OUTPUT_DIR/$final_artist/$final_album"
  local out_file="$out_dir/$final_title.$ext"

  mkdir -p "$out_dir"

  local overwrite_note=""
  [[ -f "$out_file" ]] && overwrite_note=" (overwritten)"

  # --- Write output file ---
  local ffmpeg_args=(-v error -y -i "$src")

  if [[ -n "$cover" ]] && ! has_embedded_image "$src"; then
    ffmpeg_args+=(-i "$cover" -map 0 -map 1 -c copy -disposition:v:0 attached_pic)
  else
    ffmpeg_args+=(-c copy)
  fi

  [[ -n "$final_track" ]] && ffmpeg_args+=(-metadata "track=$final_track")
  ffmpeg_args+=(-metadata "title=$final_title" "$out_file")

  if ffmpeg "${ffmpeg_args[@]}" 2>&1; then
    printf "  ok    %-45s -> %s%s\n" "$filename" "$out_file" "$overwrite_note"
  else
    echo "  ERROR $filename" >&2
    return 1
  fi
}

# --- Main ---
echo "Parser: $PARSER_NAME"
echo "Input:  $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

album_count=0
file_count=0
error_count=0

while IFS= read -r -d '' album_dir; do
  album_name="$(basename "$album_dir")"
  echo "Album: $album_name"

  COVER_IMAGE=""
  find_cover_image "$album_dir" || true

  while IFS= read -r -d '' src_file; do
    if process_file "$src_file" "$COVER_IMAGE"; then
      ((file_count++)) || true
    else
      ((error_count++)) || true
    fi
  done < <(find "$album_dir" -maxdepth 1 -type f -print0 | sort -z)

  ((album_count++)) || true
  echo ""
done < <(find "$INPUT_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

echo "Done. Parser: $PARSER_NAME  Albums: $album_count  Files: $file_count  Errors: $error_count"
