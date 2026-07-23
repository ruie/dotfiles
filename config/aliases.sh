# Shared aliases — sourced from .bashrc on every machine
alias clauded="claude --dangerously-skip-permissions"
alias codexd="codex --dangerously-bypass-approvals-and-sandbox"

# Attach to the vps herdr workspace (from any machine that isn't the vps)
[ "$(hostname)" != "vps" ] && alias hvps='herdr --remote vps --remote-keybindings server'
