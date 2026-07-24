#!/usr/bin/env bash
# One-command environment sync for every machine. Prereq: Homebrew.
#   git clone git@github.com:ruie/dotfiles.git ~/dotfiles && ~/dotfiles/sync.sh
set -euo pipefail

cd "$(dirname "$0")"

# Homebrew (linuxbrew on Linux, /opt/homebrew on Apple Silicon). Its installer
# needs sudo, so only run it where sudo can prompt.
if ! command -v brew >/dev/null; then
  for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew; do
    [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
  done
fi
if ! command -v brew >/dev/null; then
  if [ -t 0 ]; then
    echo "Homebrew not found — running its installer (sudo will prompt)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew; do
      [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
    done
  else
    echo "Homebrew not found — install it, then rerun sync:" >&2
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
    exit 1
  fi
fi

# No auto-update: versions come from brew's JSON API anyway, and a stale
# multi-tap git update can stall sync for many minutes (seen on WSL)
export HOMEBREW_NO_AUTO_UPDATE=1
# On WSL, drop Windows /mnt/* PATH entries for brew: its Ruby stats every
# PATH dir over the 9p bridge, which can hang for minutes (seen 2026-07-23)
PATH=$(printf %s "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd:)

# Packages: shared base + per-machine extras
brew bundle --quiet --file packages/bundle
if [ "$USER" = "vdelapena" ]; then brew bundle --quiet --file packages/bundle.work; fi
if [ "$(uname)" = "Darwin" ]; then brew bundle --quiet --file packages/bundle.mac; fi

# Self-updating tools brew can't manage well, installed once on fresh
# machines: bun (dev runtime, `bun upgrade`), claude (native installer,
# self-updates), nvm (node versions). Auth stays manual (gh auth login,
# claude first run, :Copilot auth).
if [ ! -d "$HOME/.bun" ]; then
  curl -fsSL https://bun.sh/install | bash
fi
if ! command -v claude >/dev/null && [ ! -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"
  nvm install --lts
fi

# Migration (2026-07): configs used to be symlinked by home-manager into
# /nix/store — clear those so stow can own the links. Delete this block once
# every machine has synced past the nix removal.
for cfg in nvim herdr/config.toml starship.toml shell.sh wezterm; do
  target="$HOME/.config/$cfg"
  if [ -L "$target" ] && readlink "$target" | grep -q "^/nix/store"; then
    rm "$target"
  fi
done

# Symlink home/ into ~ (home/.config/<x> IS ~/.config/<x>)
stow -R -d "$PWD" -t "$HOME" home

# Wire shared shell setup into the machine-local rc file once
if [ "$(uname)" = "Darwin" ]; then RC=~/.zshrc; else RC=~/.bashrc; fi
LINE='[ -f ~/.config/shell.sh ] && . ~/.config/shell.sh'
grep -qxF "$LINE" "$RC" 2>/dev/null || echo "$LINE" >>"$RC"

# Register herdr plugins once (herdr keeps its own registry)
if command -v herdr >/dev/null; then
  herdr plugin list 2>/dev/null | grep -q last-tab ||
    herdr plugin link "$PWD/home/.config/herdr/plugins/last-tab" >/dev/null
  herdr plugin list 2>/dev/null | grep -q vim-herdr-navigation ||
    herdr plugin install paulbkim-dev/vim-herdr-navigation --yes >/dev/null
  mkdir -p ~/.local/state/herdr/plugins/last-tab
  # if herdr's watcher catches a symlink swap mid-sync it falls back to
  # defaults — force a clean re-read
  herdr server reload-config >/dev/null 2>&1 || true
fi

echo "Synced"
