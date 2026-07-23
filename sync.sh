#!/usr/bin/env bash
# One-command environment sync for every machine. Prereq: Determinate Nix.
#   git clone git@github.com:ruie/dotfiles.git ~/dotfiles && ~/dotfiles/sync.sh
set -euo pipefail

cd "$(dirname "$0")"

# Nix binaries aren't always on PATH in fresh shells
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] &&
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

command -v nix >/dev/null || {
  echo "nix not found — install Determinate Nix first:" >&2
  echo "  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate" >&2
  exit 1
}

if [ "$(uname)" = "Darwin" ]; then
  # macOS: nix-darwin drives everything (system, Homebrew, home-manager module).
  # darwin-rebuild isn't on PATH before the first switch, so run it from the flake.
  sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#mac"
  RC=~/.zshrc
else
  nix run home-manager -- switch --flake ".#$USER" -b backup
  RC=~/.bashrc
fi

# Wire shared shell setup into the machine-local rc file once
LINE='[ -f ~/.config/shell.sh ] && . ~/.config/shell.sh'
sed -i.bak '/config\/dotfiles\/\(aliases\|shell\)\.sh/d' "$RC" 2>/dev/null && rm -f "$RC.bak"
grep -qxF "$LINE" "$RC" 2>/dev/null || echo "$LINE" >>"$RC"

# hunk isn't in nixpkgs; bun covers Linux, Homebrew covers macOS
export PATH="$HOME/.bun/bin:$PATH"
command -v hunk >/dev/null || bun install -g hunkdiff >/dev/null

# Register herdr plugins once (herdr keeps its own registry)
if command -v herdr >/dev/null; then
  herdr plugin list 2>/dev/null | grep -q last-tab ||
    herdr plugin link "$PWD/home/.config/herdr/plugins/last-tab" >/dev/null
  herdr plugin list 2>/dev/null | grep -q vim-herdr-navigation ||
    herdr plugin install paulbkim-dev/vim-herdr-navigation --yes >/dev/null
  mkdir -p ~/.local/state/herdr/plugins/last-tab
fi

echo "Synced"
