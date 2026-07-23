# dotfiles

Nix-flake dotfiles for all machines (WSL workstation + Hetzner vps). Home Manager
symlinks configs back into this repo, so edits happen in place and `git status`
shows drift.

## New machine

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
git clone https://github.com/ruie/dotfiles ~/dotfiles
~/dotfiles/sync.sh
```

`sync.sh` is idempotent — run it again any time (after `git pull`, or after
editing configs on another machine).

## What it manages

- `nvim/` — LazyVim config (`~/.config/nvim`); copilot via the LazyVim `ai.copilot` extra
  (the old vendored `pack/copilot.vim` was redundant and is not carried over), auth with `:Copilot auth`
- `herdr/` — herdr config + the local `last-tab` plugin (registered by sync.sh)
- `aliases.sh` — `clauded`, `codexd`, `hvps` (sourced from `.bashrc`)
- CLI tools via Nix: neovim, ripgrep, fd, fzf, jq, gh, bun, node

Per-user profiles live in `flake.nix` (`vdelapena` = WSL, `ruie` = vps). Add a
machine by adding one `mkHome` line.

## Not managed (yet)

- Agent CLIs (`claude`, `codex`, `pi`) — installer/bun-based, see their docs
- Tool auth state (`gh auth login`, `claude`, `:Copilot setup`)
- herdr itself (`curl -fsSL https://herdr.dev/install.sh | sh`)
