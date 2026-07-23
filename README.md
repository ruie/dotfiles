# dotfiles

Nix-flake dotfiles for all three machines. Home Manager symlinks configs back
into this repo, so edits happen in place and `git status` shows drift.

| Machine | OS | Profile | Driver |
|---|---|---|---|
| work | Windows WSL (Ubuntu) | `vdelapena` | home-manager standalone |
| personal | macOS (Apple Silicon) | `mac` (user `ruie`) | nix-darwin + nix-homebrew + home-manager |
| vps | Hetzner Ubuntu | `ruie` | home-manager standalone |

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
`darwin/configuration.nix` once the brews/casks list is the machine's complete
inventory.

## What it manages

- `nvim/` — LazyVim config (`~/.config/nvim`); copilot via the LazyVim `ai.copilot` extra, auth with `:Copilot auth`
- `herdr/` — herdr config + the local `last-tab` plugin (registered by sync.sh)
- `aliases.sh` — `clauded`, `codexd`, `hvps` (sourced from `.bashrc`/`.zshrc`)
- CLI tools via Nix: neovim, ripgrep, fd, fzf, jq, gh, bun, node
- macOS only: Homebrew itself + brews/casks, declared in `darwin/configuration.nix`

## Not managed (yet)

- Agent CLIs (`claude`, `codex`, `pi`) — installer/bun-based, see their docs
- Tool auth state (`gh auth login`, `claude`, `:Copilot auth`)
- herdr on Linux (`curl -fsSL https://herdr.dev/install.sh | sh`); on macOS it's a managed brew
