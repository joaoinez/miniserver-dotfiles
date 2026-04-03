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

## Resources

* <https://wiki.bazarr.media/>
* <https://github.com/Haxxnet/Compose-Examples>
* <https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md>
