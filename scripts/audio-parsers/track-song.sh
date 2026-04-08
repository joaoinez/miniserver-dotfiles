# PARSER: track-song
# Handles: "01 - Song Title.flac", "01.Song Title.flac", "1 - Song Title.flac"
# Example: "03 - Some Song.flac" -> track=3, title="Some Song"
parse_filename() {
  local filename="$1"         # e.g. "03 - Some Song.flac"
  local base="${filename%.*}" # strip extension

  # Strip leading track number (digits, followed by optional separators)
  local after_num
  after_num="$(sed 's/^[0-9]\+[[:space:]]*[-\.][[:space:]]*//' <<<"$base")"

  # Extract leading digits as track number
  PARSED_TRACK="$(grep -oE '^[0-9]+' <<<"$base" || true)"
  PARSED_TRACK="${PARSED_TRACK#0}" # strip leading zero (bash arithmetic safe)

  # Title is whatever remains after the number+separator
  PARSED_TITLE="$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' <<<"$after_num")"
}
