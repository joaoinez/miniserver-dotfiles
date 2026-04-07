export TERM="xterm-256color"
export MYSCRIPTS="$HOME/.local/bin"
export MYVIMRC="$HOME/.config/nvim/init.lua"
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH=$PATH:$HOME/.local/bin
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

autoload -Uz compinit && compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

alias ll="ls -la"
alias vim="nvim"
alias source-zsh="source ~/.zshrc && source ~/.zshenv && source ~/.zprofile"
alias gfp="git fetch && git pull"
alias gst="git status"
alias launchctls="launchctl list | grep com.user"
alias down="docker compose down"
alias up="docker compose up --pull always --force-recreate -d"
alias prune="docker system prune -a --volumes -f"
alias restart="docker compose down && docker compose up --pull always --force-recreate -d && docker system prune -a --volumes -f"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
