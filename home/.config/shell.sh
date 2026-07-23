# Shared shell setup — sourced from .bashrc/.zshrc on every machine

# bun-installed globals (hunk, agent CLIs)
case ":$PATH:" in *":$HOME/.bun/bin:"*) ;; *) export PATH="$HOME/.bun/bin:$PATH" ;; esac

alias ..="cd .."
alias clauded="claude --dangerously-skip-permissions"

# Pull the latest dotfiles and apply them (subshell keeps the current cwd;
# shadows /usr/bin/sync, which nobody types by hand)
alias sync='(cd ~/dotfiles && git pull --ff-only && ./sync.sh)'
alias codexd="codex --dangerously-bypass-approvals-and-sandbox"

# Attach to the vps herdr workspace (from any machine that isn't the vps)
[ "$(hostname)" != "vps" ] && alias hvps='herdr --remote vps --remote-keybindings server'

# Prompt
if command -v starship > /dev/null; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  else
    eval "$(starship init bash)"
  fi
fi
