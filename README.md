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

### Install system `launchd` files

This repo keeps system-level files under `root/`, but install the daemon plists as real files so `launchd` sees the expected ownership and permissions.

```shell
sudo install -o root -g wheel -m 644 \
  root/Library/LaunchDaemons/com.user.renew-tailscale-certs.plist \
  /Library/LaunchDaemons/com.user.renew-tailscale-certs.plist
```

```shell
sudo install -o root -g wheel -m 644 \
  root/Library/LaunchDaemons/com.user.serve-chat-llm.plist \
  /Library/LaunchDaemons/com.user.serve-chat-llm.plist
```

```shell
sudo install -o root -g wheel -m 644 \
  root/Library/LaunchDaemons/com.user.serve-small-llm.plist \
  /Library/LaunchDaemons/com.user.serve-small-llm.plist
```

```shell
sudo install -o root -g wheel -m 644 \
  root/Library/LaunchDaemons/com.user.start-glances.plist \
  /Library/LaunchDaemons/com.user.start-glances.plist
```

```shell
sudo install -o root -g wheel -m 644 \
  root/Library/LaunchDaemons/com.user.start-orbstack.plist \
  /Library/LaunchDaemons/com.user.start-orbstack.plist
```

### Load `launchd` jobs

```shell
sudo launchctl bootstrap system /Library/LaunchDaemons/com.user.renew-tailscale-certs.plist
```

```shell
sudo launchctl bootstrap system /Library/LaunchDaemons/com.user.serve-chat-llm.plist
```

```shell
sudo launchctl bootstrap system /Library/LaunchDaemons/com.user.serve-small-llm.plist
```

```shell
sudo launchctl bootstrap system /Library/LaunchDaemons/com.user.start-glances.plist
```

```shell
sudo launchctl bootstrap system /Library/LaunchDaemons/com.user.start-orbstack.plist
```

### Remove a system `launchd` daemon

Unload the daemon first:

```shell
sudo launchctl bootout system /Library/LaunchDaemons/<file>.plist
```

Remove the plist file:

```shell
sudo rm /Library/LaunchDaemons/<file>.plist
```

### Karakeep URL webhook

The Karakeep stack includes a webhook sidecar that rewrites supported bookmark URLs.

Currently it rewrites:

- `www.reddit.com/...` to `old.reddit.com/...`
- `youtube.com/shorts/<id>` to `youtube.com/watch?v=<id>`

Run the stack with the sample `WEBHOOK_TOKEN` and `KARAKEEP_API_TOKEN` values.

Create `KARAKEEP_API_TOKEN` in Karakeep under `User Settings > API Keys`.

Restart the Karakeep services:

```sh
cd services/karakeep
restart
```

Then create a webhook in Karakeep under `User Settings > Webhooks` with:

- URL: `http://karakeep-url-rewriter:8080/webhook`
- Token: the same value as `WEBHOOK_TOKEN`
- Event: `created`

### qBittorrent note

Set up qBittorrent with Gluetun before using magnet links.

If you skip this, magnet links will not work.

<https://github.com/qdm12/gluetun-wiki/blob/main/setup/popular-apps.md>

### Install OpenCode

```bash
curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
```

## Resources

- <https://wiki.bazarr.media/>
- <https://github.com/Haxxnet/Compose-Examples>
- <https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md>
