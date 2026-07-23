-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Clipboard over OSC 52: herdr forwards the escape sequence to the outer
-- terminal, so yanks reach the Windows clipboard without win32yank/xclip.
-- Paste reads Neovim's own register because Windows Terminal doesn't answer
-- OSC 52 paste queries (a real query would make `p` hang); use Ctrl+Shift+V
-- to paste the actual system clipboard.
local osc52 = require("vim.ui.clipboard.osc52")
local function paste_from_register()
  return vim.split(vim.fn.getreg('"'), "\n")
end
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste_from_register, ["*"] = paste_from_register },
}
