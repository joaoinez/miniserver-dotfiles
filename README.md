# Miniserver

## DNS

<https://developers.cloudflare.com/1.1.1.1/ip-addresses/>

<https://quad9.net/>

## Setup

### Settings

#### `Energy`

##### Enable `Prevent automatic sleeping when the display is off`

##### Enable `Wake for network access`

##### Enable `Start up automatically after a power failure`

### Install `git`

```shell
git --version
```

### Install homebrew

```shell
brew bundle
```

### Start services

```shell
./scripts/run-services.sh
```

### qBittorrent note

Set up qBittorrent with Gluetun before using magnet links.

If you skip this, magnet links will not work.

<https://github.com/qdm12/gluetun-wiki/blob/main/setup/popular-apps.md>

### Sync folder with `~`

#### To link `dotfiles` with `~`

```shell
stow --no-folding .
```

#### After a change in `dotfiles`

```shell
stow --restow .
```

#### After a change in `~`

```shell
stow --restow --adopt .
```

### Load `launchd` agents

```shell
launchctl load ~/Library/LaunchAgents/com.user.renew-tailscale-certs.plist
```

```shell
launchctl load ~/Library/LaunchAgents/com.user.serve-chat-llm.plist
```

```shell
launchctl load ~/Library/LaunchAgents/com.user.serve-small-llm.plist
```

```shell
launchctl load ~/Library/LaunchAgents/com.user.start-glances.plist
```

### Install OpenCode

```bash
curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
```

### Generate audio filename parsers

Use the `audio-parser` alias to inspect files in `./in` and look for a matching parser in `scripts/audio-parsers/`.

```bash
audio-parser
```

If all files in `./in` match one naming convention, the agent reuses an existing parser or writes a new one.

If the files use different formats, it prints a warning, lists the formats found, and stops.

The agent prints the parser name to use, for example:

```text
parser: track-artist-song  source: new  run: sanitize-audio.sh track-artist-song
```

Then run `sanitize-audio.sh` with that parser name.

```bash
./scripts/sanitize-audio.sh track-artist-song
```

Parsers are stored in `scripts/audio-parsers/`.

Run `sanitize-audio.sh` with no arguments to list available parsers.

## Resources

* <https://wiki.bazarr.media/>
* <https://github.com/Haxxnet/Compose-Examples>
* <https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md>
