-- vim-tmux-navigator kept for its :TmuxNavigate* commands (tmux fallback);
-- <C-h/j/k/l> mappings come from vim-herdr-navigation's editor script, which
-- handles herdr panes and falls back to tmux/wincmd outside herdr.
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  -- <C-h/j/k/l> mappings are set in config/keymaps.lua, which LazyVim loads
  -- after its own defaults — setting them here (plugin config) runs too early
  -- and LazyVim's "Go to Left Window" maps clobber them on VeryLazy.
}
