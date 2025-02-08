<https://macos-defaults.com/>

```text
█▀▄▀█ ▄▀█ █▀▀ █▀█ █▀
█░▀░█ █▀█ █▄▄ █▄█ ▄█
```

### Settings

##### `Apple ID`

#### `iCloud Drive` -> Enable `Desktop & Documents Folders`

---

##### `Control Center`

#### `Battery` -> Enable `Show Percentage`

---

##### `Desktop & Dock`

#### `Dock` -> Enable `Minimise windows into application icon`

#### `Dock` -> Enable `Automatically hide and show the Dock`

#### `Dock` -> Disable `Show suggested and recent apps in Dock`

#### `Desktop & Stage Manager` -> Set `Click wallpaper to reveal desktop` to `Only in Stage Manager`

#### `Mission Control` -> Disable `Automatically rearrange Spaces based on most recent use`

---

##### `Displays`

#### Set display resolution to `More space`

---

##### `Keyboard`

#### Set `Key repeat rate` to `Fast`

#### Set `Delay until repeat` to one tick before `Short`

#### Add `Unicode Text Input` keyboard layout

---

##### `Trackpad`

#### `More Gestures` -> Set `App Exposé` to `Swipe Down with Three Fingers`

---

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
