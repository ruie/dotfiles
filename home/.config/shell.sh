# Shared shell setup — sourced from .bashrc/.zshrc on every machine

# bun-installed globals (agent CLIs)
case ":$PATH:" in *":$HOME/.bun/bin:"*) ;; *) export PATH="$HOME/.bun/bin:$PATH" ;; esac

# ~/.local/bin (claude, user scripts) — .profile only covers login shells;
# herdr-spawned tabs are non-login and need it here
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

# Homebrew (linuxbrew on Linux, /opt/homebrew on Apple Silicon)
for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew; do
  [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
done
unset brew_bin

# nix tools win even when the parent env predates nix (e.g. terminals inside a
# herdr server started before a sync): Linux standalone profile, macOS
# home-manager-module profile, determinate default profile.
for nix_bin in "/nix/var/nix/profiles/default/bin" "/etc/profiles/per-user/$USER/bin" "$HOME/.nix-profile/bin"; do
  [ -d "$nix_bin" ] || continue
  case ":$PATH:" in *":$nix_bin:"*) ;; *) export PATH="$nix_bin:$PATH" ;; esac
done
unset nix_bin

alias ..="cd .."
alias clauded="claude --dangerously-skip-permissions"

# Pull the latest dotfiles and apply them (subshell keeps the current cwd;
# shadows /usr/bin/sync, which nobody types by hand)
alias sync='(cd ~/dotfiles && git pull --ff-only && ./sync.sh)'
alias codexd="codex --dangerously-bypass-approvals-and-sandbox"

# Attach to the vps herdr workspace (from any machine that isn't the vps)
[ "$(hostname)" != "vps" ] && alias hvps='herdr --remote vps --remote-keybindings server'

# tailscale CLI everywhere: native on the vps (apt), Windows client's CLI on
# WSL, the GUI app's bundled CLI on macOS — no second install needed
if ! command -v tailscale > /dev/null; then
  if command -v tailscale.exe > /dev/null; then
    alias tailscale=tailscale.exe
  elif [ -x "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  fi
fi

# Prompt
if command -v starship > /dev/null; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  else
    eval "$(starship init bash)"
  fi
fi
