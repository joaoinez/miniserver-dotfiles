# Miniserver

## DNS

<https://developers.cloudflare.com/1.1.1.1/ip-addresses/>

<https://quad9.net/>

## Setup

### Install `git`

```shell
git --version
```

### Install homebrew

```shell
brew install mas
brew bundle
```

### Sync folder with `~`

```shell
stow --no-folding .
```

### Edit `services/traefik/config/usersFile.txt`

```shell
cp services/traefik/config/usersFile.sample.txt services/traefik/config/usersFile.txt
htpasswd -nbm admin <password> | pbcopy
```

### Edit `services/tsdproxy/config/tsdproxy.yaml` to use `authKey` instead of `controlurl`

```shell
cp services/traefik/config/usersFile.sample.txt services/traefik/config/usersFile.txt
htpasswd -nbm admin <password> | pbcopy
```

### Edit `services/perplexica/config.toml`

```shell
cp services/perplexica/config.sample.toml services/perplexica/config.toml
```

### Start services

```shell
./scripts/run-services.sh
```

### Start `Glances`

```shell
glances -w
```

### Rebuild `bat` cache

```shell
bat cache --build
```

### Create a cron job to restart arr suite containers everyday at midnight

```shell
crontab -e
```

```crontab
0 0 * * * /Users/miniserver/.local/bin/restart-arrsuite.sh
```

## Resources

* <https://wiki.bazarr.media/>
* <https://github.com/Haxxnet/Compose-Examples>
* <https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/protonvpn.md>
