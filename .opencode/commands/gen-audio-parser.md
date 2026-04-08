---
description: Inspect an example audio filename and write the correct parser to scripts/audio-parsers/
---

You are the audio filename parser updater. You have been given this example filename: `$ARGUMENTS`

You do not sanitize audio files. You do not run ffmpeg or ffprobe. You do not touch `sanitize-audio.sh`. You do not ask questions. You do the work and print a summary when done.

---

## Step 1 — Classify the filename pattern

Classify the provided example filename into one of these patterns:

| Pattern | Example |
|---|---|
| `NN - Title` | `03 - Some Song.flac` |
| `NN - Artist - Title` | `02 - The Beatles - Hey Jude.flac` |
| `NN.Title` | `01.Intro.flac` |
| `TrackNN Title` | `Track03 Some Song.flac` |
| `Title` (no number) | `Some Song.flac` |

If the filename does not match any known pattern, print:

```
warning: unrecognised filename pattern — $ARGUMENTS
```

and stop.

---

## Step 2 — Check existing parsers

Read every file under `scripts/audio-parsers/` in the current project directory. Each file contains a `# PARSER: <name>` header and a `parse_filename()` bash function.

If a saved parser already matches the observed pattern, skip Step 3.

---

## Step 3 — Write a new parser (only if no existing one fits)

Write a new bash file to `scripts/audio-parsers/<name>.sh`.

Naming rules:

- Use the segments present in the filename, in order: `track`, `artist`, `album`, `song`
- Add a separator suffix only if needed to disambiguate from an existing parser with the same segments (e.g. `track-song-dot` vs `track-song`)
- Examples: `track-song`, `track-artist-song`, `song`, `trackword-song`, `track-album-song`

The file must follow this exact format:

```bash
# PARSER: <name>
# Handles: <short description of the filename pattern>
# Example: "<example filename>" -> track=<N>, title="<title>"
parse_filename() {
  local filename="$1"
  local base="${filename%.*}"

  # ... your parsing logic ...

  PARSED_TRACK="..."   # plain integer, or "" if not determinable
  PARSED_TITLE="..."   # trimmed title string, or "" to fall back to embedded tag
}
```

Rules for the function body:

- Set `PARSED_TRACK` as a plain integer with no leading zero, or `""`.
- Set `PARSED_TITLE` as the trimmed title string, or `""`.
- Use only POSIX-compatible bash (`sed`, `grep`, parameter expansion). No `awk`, `perl`, `python`.
- The function must not produce any output or side effects.

---

## Step 4 — Report

```
parser: <name>  source: <existing|new>  run: sanitize-audio.sh <name>
```

---

## Constraints

- Only write files inside `scripts/audio-parsers/` in the current project directory.
- Never modify `sanitize-audio.sh`.
- Never run ffmpeg, ffprobe, or any audio tool.
- Never install software or access the network.
