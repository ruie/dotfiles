# Claude Code with pstack, on demand

[pstack](https://github.com/michael-denyer/pstack-claude) is a Claude Code
plugin: Lauren Tan's skill stack (`poteto-mode`, `architect`, `deslop`, …),
subagents, and a SessionStart hook that routes tasks to `poteto-mode`.

It is never installed. `pclaude` loads it for one session, together with a
context file written for pstack sessions. `claude` and `clauded` stay clean.

**Status:** set up by hand on the work machine (WSL, Claude Code 2.1.322) on
2026-11-12. This repo does not manage it yet: `sync.sh` doesn't create it, and
the alias lives in the machine-local `~/.bashrc`. See
[Bring it into dotfiles](#bring-it-into-dotfiles).

## Commands

| Command | Session |
|---|---|
| `claude` | clean |
| `clauded` | clean, `--dangerously-skip-permissions` |
| `pclaude` | `clauded` + pstack + the pstack context file |

## Where things live

| What | Path |
|---|---|
| pstack clone (upstream code, don't edit) | `~/.local/share/pstack-claude` |
| Plugin loaded by `pclaude` | `~/.local/share/pstack-claude/plugins/pstack` |
| Context for pstack sessions only | `~/.config/pstack-claude/CLAUDE.md` |
| `pclaude` alias | `~/.bashrc` (machine-local) |
| `clauded` alias, which `pclaude` builds on | `home/.config/shell.sh` |
| pstack model choices (written by `/setup-pstack`) | `~/.claude/pstack-models.md` |

## How it works

```bash
PSTACK_PLUGIN="$HOME/.local/share/pstack-claude/plugins/pstack"
PSTACK_CONTEXT_DIR="$HOME/.config/pstack-claude"
alias pclaude='CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 clauded --plugin-dir "$PSTACK_PLUGIN" --add-dir="$PSTACK_CONTEXT_DIR"'
```

- `--plugin-dir` loads the plugin's skills, agents and hooks for this session
  only. Nothing goes into `/plugin`, a marketplace, or `settings.json`.
- `--add-dir` gives the session access to the context folder.
  `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` makes Claude Code also load
  that folder's `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` and
  `.claude/rules/*.md` as memory. Without the variable, no context loads.
- The variable is set for that one command only. It never reaches your shell.
- `pclaude` calls `clauded`, so it picks up whatever arguments `clauded` has.

## Gotchas

- **Keep the `=` in `--add-dir=`.** `--add-dir` takes several folders, so
  `--add-dir <folder>` at the end of the alias reads the next word, your
  prompt, as another folder. `pclaude "fix X"` then fails with "Input must be
  provided".
- **Define `clauded` only in `home/.config/shell.sh`.** A second copy in
  `~/.bashrc` would run later and win, so edits in `shell.sh` would stop
  reaching `clauded` and `pclaude`. One was removed on 2026-11-12. Bash looks up
  `clauded` when `pclaude` runs, so the order the two are defined in doesn't
  matter.
- **Other added folders load too.** Inside a `pclaude` session, any extra
  `--add-dir` folder also has its `CLAUDE.md` loaded.
- **Claude can edit the context folder** because `--add-dir` grants access.
- **Edits reach new sessions.** Not checked yet: whether the context file loads
  again after `/compact`. Check `/context all` after a compaction.
- **Rules with `paths:` frontmatter** don't load from an added folder.

## Why the clone and the context folder are separate

- `--add-dir` grants file access and loads instruction files. Pointed at the
  clone, it would let Claude edit pstack's code. It would also load any
  `CLAUDE.md` upstream adds later; the clone has none today.
- Your own file inside the clone blocks `git pull` once upstream adds a file at
  the same path.
- `--plugin-dir` never reads `CLAUDE.md`, so the context needs `--add-dir`
  whichever folder it lives in.

## Options considered

| Option | Verdict |
|---|---|
| `--append-system-prompt-file` | Works, but it isn't real memory: not in `/context`, can't be split into rules, and resumed sessions keep the old text. |
| **`--add-dir` + `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD`** | **Chosen.** Loads as real memory. Needs the `--add-dir=` form. |
| A second local plugin whose SessionStart hook prints the file | Reloads on resume, clear and compact, but adds a hooks file and a script. |
| A separate profile (`CLAUDE_CONFIG_DIR=~/.claude-pstack`) | Needs another login. Settings, MCP, hooks and memory would all need copying. |
| Editing pstack's own context file in the clone | Conflicts with `git pull`. |

## Common tasks

```sh
# Update pstack (manual; nothing auto-updates), then start a new session
git -C ~/.local/share/pstack-claude pull

# Add pstack-only instructions
$EDITOR ~/.config/pstack-claude/CLAUDE.md
# or split them into ~/.config/pstack-claude/.claude/rules/*.md

# Remove everything: then delete the pstack block in ~/.bashrc
rm -rf ~/.local/share/pstack-claude ~/.config/pstack-claude
```

## Verify

- `type pclaude` shows the alias.
- In a `pclaude` session, `/context all` lists
  `~/.config/pstack-claude/CLAUDE.md` under **Memory files**, and `/poteto-mode`
  exists.
- In a plain `claude` session, neither shows up.

## Bring it into dotfiles

The setup is machine-local today. To manage it here instead:

1. Move the pstack block (the `PSTACK_*` lines and the alias) from
   `~/.bashrc` into `home/.config/shell.sh`.
2. Move `~/.config/pstack-claude/` to `home/.config/pstack-claude/` so stow
   links it.
3. Add a first-run clone step to `sync.sh`, like the bun and claude bootstraps:
   `git clone https://github.com/michael-denyer/pstack-claude ~/.local/share/pstack-claude`.
