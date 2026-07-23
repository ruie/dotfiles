#!/usr/bin/env bash
# One-command environment sync. Prereq: Determinate Nix.
#   git clone https://github.com/ruie/dotfiles ~/dotfiles && ~/dotfiles/sync.sh
set -euo pipefail

cd "$(dirname "$0")"

# Nix binaries aren't always on PATH in fresh shells
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] &&
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

command -v nix > /dev/null || {
  echo "nix not found — install Determinate Nix first:" >&2
  echo "  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate" >&2
  exit 1
}

nix run home-manager -- switch --flake ".#$USER" -b backup

# Wire aliases into the machine-local .bashrc once
LINE='[ -f ~/.config/dotfiles/aliases.sh ] && . ~/.config/dotfiles/aliases.sh'
grep -qxF "$LINE" ~/.bashrc || echo "$LINE" >> ~/.bashrc

# Register the local herdr plugin once (herdr keeps its own registry)
if command -v herdr > /dev/null; then
  herdr plugin list 2> /dev/null | grep -q last-tab ||
    herdr plugin link "$PWD/herdr/plugins/last-tab" > /dev/null
  herdr plugin list 2> /dev/null | grep -q vim-herdr-navigation ||
    herdr plugin install paulbkim-dev/vim-herdr-navigation --yes > /dev/null
  mkdir -p ~/.local/state/herdr/plugins/last-tab
fi

echo "synced: home-manager generation $(home-manager generations 2> /dev/null | head -1 || echo ok)"
