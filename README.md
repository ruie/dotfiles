# dotfiles

Homebrew + GNU Stow dotfiles for all three machines. Stow symlinks configs
back into this repo, so edits happen in place and `git status` shows drift.

| Machine | OS | Packages | Extras |
|---|---|---|---|
| work | Windows WSL (Ubuntu) | linuxbrew | `packages/bundle.work` |
| personal | macOS (Apple Silicon) | Homebrew | `packages/bundle.mac` (casks, fonts) |
| vps | Hetzner Ubuntu | linuxbrew | — |

## Layout

```
sync.sh       the one command — apply everything, idempotent
packages/
  bundle        base Brewfile: CLI tools, every machine
  bundle.work   work-only CLIs (shopify, flyctl, axiom)
  bundle.mac    macOS casks (WezTerm, nerd font)
home/         mirrors ~ — home/.config/<x> IS ~/.config/<x> (via stow)
  .config/
    nvim/           LazyVim config
    herdr/          herdr config + local last-tab plugin
    wezterm/        WezTerm config (used on macOS)
    starship.toml   prompt
    shell.sh        PATH order, aliases (sync, .., lg, clauded, codexd, hvps), starship init
docs/         notes on setups this repo doesn't manage yet
  claude-code-pstack.md   pclaude: Claude Code + pstack, loaded on demand
```

## Any machine, fresh or not

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:ruie/dotfiles.git ~/dotfiles
~/dotfiles/sync.sh
```

`sync.sh` installs the Brewfiles for the machine, stows `home/` into `~`, and
registers herdr plugins. It is idempotent — rerun any time (after `git pull`,
or after editing configs). The `sync` alias does the pull + rerun.

macOS first run: install Homebrew first (its installer prompts for sudo); the
Mac needs an SSH key on GitHub before the clone (private repo).

## What it manages

- All CLI tools via Homebrew (`packages/bundle`): neovim, ripgrep, fd, fzf,
  jq, gh, lazygit, starship, tree, ast-grep, stow, herdr, hunk.
  Upgrade with `brew upgrade` (never `herdr update` — refuses on brew).
- `home/.config/nvim/` — LazyVim (`~/.config/nvim`); copilot via the LazyVim
  `ai.copilot` extra, auth with `:Copilot auth`
- `home/.config/herdr/` — herdr config + the local `last-tab` plugin
  (registered by sync.sh)
- `home/.config/shell.sh` — PATH order (bun, ~/.local/bin, brew), aliases,
  starship init (sourced from `.bashrc`/`.zshrc`; sync.sh prepends the line
  so machine-local settings below it win)

## Not managed (deliberately)

- `bun` — official installer (`~/.bun`), self-updates via `bun upgrade`
- `node` — nvm per machine (its installer appends the loader to `.bashrc`)
- Agent CLIs (`claude`, `codex`, `pi`) — installer/bun-based, see their docs
- Tool auth state (`gh auth login`, `claude`, `:Copilot auth`)
- Tailscale — system-level per machine (apt on the vps, Windows client for
  WSL, the macOS app); shell.sh aliases `tailscale` to the right CLI everywhere
