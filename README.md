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
htpasswd -nbm admin <password> | pbcopy
```

### Start services

```shell
./scripts/run-services.sh
```
