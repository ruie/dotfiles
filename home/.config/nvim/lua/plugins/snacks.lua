-- Indent guides: no static per-level lines, just a rounded "chunk" outline
-- (╭─ … ╰─) around the current scope in the current window.
-- Ported from IMax153/nixvim config/plugins/snacks/indent.nix.
return {
  {
    "snacks.nvim",
    opts = {
      indent = {
        indent = { enabled = false },
        chunk = {
          enabled = true,
          only_current = true,
          char = {
            arrow = "─",
            corner_top = "╭",
            corner_bottom = "╰",
          },
          hl = "SnacksIndentScope",
        },
      },
    },
  },
}
