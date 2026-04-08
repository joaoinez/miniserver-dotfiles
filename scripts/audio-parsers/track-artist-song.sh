# PARSER: track-artist-song
# Handles: "01 - Artist - Song Title.flac"
# Example: "02 - The Beatles - Hey Jude.flac" -> track=2, title="Hey Jude"
# Note: the artist segment between the two dashes is stripped; artist comes from embedded tags.
parse_filename() {
	local filename="$1"
	local base="${filename%.*}"

	PARSED_TRACK="$(grep -oE '^[0-9]+' <<<"$base" || true)"
	PARSED_TRACK="${PARSED_TRACK#0}"

	# Strip "NN - Artist - " prefix, leaving just the title
	local after_num
	after_num="$(sed 's/^[0-9]\+[[:space:]]*-[[:space:]]*//' <<<"$base")"
	# If there is still a " - " delimiter, the segment before it was the artist name — drop it
	if grep -q ' - ' <<<"$after_num"; then
		after_num="$(sed 's/^[^-]*-[[:space:]]*//' <<<"$after_num")"
	fi

	PARSED_TITLE="$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' <<<"$after_num")"
}
