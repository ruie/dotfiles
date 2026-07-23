#!/usr/bin/env bash
#
# last-tab — tmux-style "last window" for herdr tabs.
#
# record: invoked by the tab.focused event hook; keeps a two-line state file
#         (line 1 = previous tab id, line 2 = current tab id).
# toggle: invoked by a keybinding; focuses the previous tab from the state file.
#
# Requires `jq` (same dependency as vim-herdr-navigation).

set -euo pipefail

# jq comes from nix; the herdr server's env may predate nix on PATH
# (Linux: ~/.nix-profile, macOS home-manager module: /etc/profiles/per-user).
PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH"

cmd="${1:?usage: last-tab.sh <record|toggle>}"
herdr="${HERDR_BIN_PATH:-herdr}"
state_dir="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr/plugins/last-tab}"
state="$state_dir/history"
mkdir -p "$state_dir"

focused_tab() {
  "$herdr" api snapshot 2>/dev/null \
    | jq -r '.result.snapshot.focused_tab_id // empty'
}

read_state() {
  prev=""
  cur=""
  if [ -f "$state" ]; then
    { read -r prev || true; read -r cur || true; } < "$state"
  fi
}

case "$cmd" in
  record)
    now="$(focused_tab)"
    [ -n "$now" ] || exit 0
    read_state
    if [ "$now" != "$cur" ]; then
      printf '%s\n%s\n' "$cur" "$now" > "$state"
    fi
    ;;
  toggle)
    read_state
    now="$(focused_tab)"
    if [ -n "$prev" ] && [ "$prev" != "$now" ]; then
      # If the previous tab was closed, focusing fails; drop the stale entry.
      "$herdr" tab focus "$prev" >/dev/null 2>&1 \
        || printf '%s\n%s\n' "" "$now" > "$state"
    fi
    ;;
  *)
    echo "last-tab.sh: unknown command: $cmd" >&2
    exit 2
    ;;
esac
