# Miniserver

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
