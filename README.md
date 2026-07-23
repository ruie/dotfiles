# dotfiles

Nix-flake dotfiles for all three machines. Home Manager symlinks configs back
into this repo, so edits happen in place and `git status` shows drift.

| Machine | OS | Profile | Driver |
|---|---|---|---|
| work | Windows WSL (Ubuntu) | `vdelapena` | home-manager standalone |
| personal | macOS (Apple Silicon) | `mac` (user `ruie`) | nix-darwin + nix-homebrew + home-manager |
| vps | Hetzner Ubuntu | `ruie` | home-manager standalone |

## Layout

```
flake.nix     machine profiles (the only place machines are declared)
sync.sh       the one command — apply everything, idempotent
nix/          how machines are built
  home.nix      shared user env: packages, symlinks (all machines)
  darwin.nix    macOS system: nix-darwin + Homebrew
config/       what gets symlinked into ~/.config
  nvim/           LazyVim config
  herdr/          herdr config + local last-tab plugin
  wezterm/        WezTerm config (macOS only)
  starship.toml   prompt
  shell.sh        aliases (.., clauded, codexd, hvps), PATH, starship init
```

## Any machine, fresh or not

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
git clone git@github.com:ruie/dotfiles.git ~/dotfiles
~/dotfiles/sync.sh
```

`sync.sh` detects the OS: macOS runs `darwin-rebuild switch` (system settings +
Homebrew + user env), Linux runs `home-manager switch` (user env only). It is
idempotent — rerun any time (after `git pull`, or after editing configs).

macOS first run: if the Mac's username isn't `ruie`, change the one `macUser`
line in `flake.nix` first. Homebrew cleanup is `"none"` — flip to `"zap"` in
`nix/darwin.nix` once the brews/casks list is the machine's complete inventory.

## What it manages

- `config/nvim/` — LazyVim (`~/.config/nvim`); copilot via the LazyVim `ai.copilot` extra, auth with `:Copilot auth`
- `config/herdr/` — herdr config + the local `last-tab` plugin (registered by sync.sh)
- `config/shell.sh` — aliases (`..`, `clauded`, `codexd`, `hvps`), bun PATH, starship init (sourced from `.bashrc`/`.zshrc`)
- `config/starship.toml` — prompt config
- `config/wezterm/` — WezTerm config (symlinked on macOS only; the cask is in `nix/darwin.nix`)
- CLI tools via Nix: neovim, ripgrep, fd, fzf, jq, tree, ast-grep, gh, lazygit, starship, bun, node, JetBrainsMono Nerd Font
- `hunk` — via bun on Linux (sync.sh), via Homebrew on macOS
- macOS only: Homebrew itself + brews/casks (herdr, hunk, WezTerm), declared in `nix/darwin.nix`

## Not managed (yet)

- Agent CLIs (`claude`, `codex`, `pi`) — installer/bun-based, see their docs
- Tool auth state (`gh auth login`, `claude`, `:Copilot auth`)
- herdr on Linux (`curl -fsSL https://herdr.dev/install.sh | sh`); on macOS it's a managed brew
