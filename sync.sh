#!/usr/bin/env bash
# One-command environment sync for every machine. Prereq: Homebrew.
#   git clone git@github.com:ruie/dotfiles.git ~/dotfiles && ~/dotfiles/sync.sh
set -euo pipefail

cd "$(dirname "$0")"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

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

# One explicit catalog refresh per sync, instead of implicit auto-updates
# before every brew command below. Without a refresh brew never learns about
# new versions and bundle "upgrades" nothing (seen with codex 2026-07-29).
export HOMEBREW_NO_AUTO_UPDATE=1
# On WSL, drop Windows /mnt/* PATH entries for brew: its Ruby stats every
# PATH dir over the 9p bridge, which can hang for minutes (seen 2026-07-23)
PATH=$(printf %s "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd:)
step "Packages: refresh brew catalog"
brew update --quiet

# Packages: shared base + per-machine extras
step "Packages: base (packages/bundle)"
brew bundle --file packages/bundle
if [ "$USER" = "vdelapena" ]; then
  step "Packages: work extras (packages/bundle.work)"
  brew bundle --file packages/bundle.work
fi
if [ "$(uname)" = "Darwin" ]; then
  step "Packages: macOS casks (packages/bundle.mac)"
  brew bundle --file packages/bundle.mac
fi

# Self-updating tools brew can't manage well, installed once on fresh
# machines: bun (dev runtime, `bun upgrade`), claude (native installer,
# self-updates), nvm (node versions). Auth stays manual (gh auth login,
# claude first run, :Copilot auth).
if [ ! -d "$HOME/.bun" ]; then
  step "Bootstrap: bun (first run only)"
  curl -fsSL https://bun.sh/install | bash
fi
if ! command -v claude >/dev/null && [ ! -x "$HOME/.local/bin/claude" ]; then
  step "Bootstrap: claude (first run only)"
  curl -fsSL https://claude.ai/install.sh | bash
fi
if [ ! -d "$HOME/.nvm" ]; then
  step "Bootstrap: nvm + node LTS (first run only)"
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
step "Configs: stow home/ into ~"
stow -R -v -d "$PWD" -t "$HOME" home

# Wire shared shell setup into the machine-local rc file once
if [ "$(uname)" = "Darwin" ]; then RC=~/.zshrc; else RC=~/.bashrc; fi
LINE='[ -f ~/.config/shell.sh ] && . ~/.config/shell.sh'
grep -qxF "$LINE" "$RC" 2>/dev/null || echo "$LINE" >>"$RC"

# Register herdr plugins once (herdr keeps its own registry)
if command -v herdr >/dev/null; then
  step "herdr: plugins + config reload"
  herdr plugin list 2>/dev/null | grep -q last-tab ||
    herdr plugin link "$PWD/home/.config/herdr/plugins/last-tab" >/dev/null
  herdr plugin list 2>/dev/null | grep -q vim-herdr-navigation ||
    herdr plugin install paulbkim-dev/vim-herdr-navigation --yes >/dev/null
  mkdir -p ~/.local/state/herdr/plugins/last-tab
  # if herdr's watcher catches a symlink swap mid-sync it falls back to
  # defaults — force a clean re-read
  herdr server reload-config >/dev/null 2>&1 || true
fi

step "Synced"
