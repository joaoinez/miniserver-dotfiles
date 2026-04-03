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

### Start `Glances`

```shell
glances -w
```

<!-- ### Create a cron job to restart arr suite containers everyday at midnight

```shell
crontab -e
```

```crontab
0 0 * * * /Users/miniserver/.local/bin/restart-arrsuite.sh
``` -->

## Resources

* <https://wiki.bazarr.media/>
* <https://github.com/Haxxnet/Compose-Examples>
* <https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md>
