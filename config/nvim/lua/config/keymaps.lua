-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

-- vim-herdr-navigation: <C-h/j/k/l> moves between Neovim splits and hands off
-- to herdr panes at the edges. Must load here (after LazyVim's default
-- <C-h/j/k/l> window maps) so these mappings win.
-- herdr installs plugins under a content-hashed dir; glob so updates keep working
local herdr_nav = vim.fn.glob("~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua", true, true)
if #herdr_nav > 0 then
  dofile(herdr_nav[1])
else
  vim.notify("vim-herdr-navigation editor script not found; run `herdr plugin list`", vim.log.levels.WARN)
end

-- Function to close the current buffer while keeping Neo-tree open
local function smart_close()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_windows = vim.call("win_findbuf", bufnr)
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  local buf_type = vim.api.nvim_buf_get_option(bufnr, "buftype")

  if buf_type == "nofile" then
    vim.cmd("close")
  elseif #buf_windows > 1 then
    vim.cmd("close")
  elseif #vim.api.nvim_list_bufs() > 1 then
    local command = modified and "confirm bdelete" or "bdelete"
    vim.cmd(command .. " " .. bufnr)
  else
    vim.cmd("enew")
    vim.cmd("bdelete " .. bufnr)
  end
end

-- Better Escape with 'jk' or 'kj'
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Escape insert mode" })

-- Move line up/down
keymap("n", "<leader>j", "ddp", opts)
keymap("n", "<leader>k", "ddkP", opts)

-- Save
keymap("n", "<leader>w", "<cmd>:w<CR>", opts)

-- Close windows
keymap("n", "<leader>q", ":q<CR>", opts)

-- Close current buffer with Shift+Q in normal mode, keeping neo-tree open
vim.keymap.set("n", "Q", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local buftype = vim.api.nvim_buf_get_option(current_buf, "buftype")

  -- Check if the current buffer is neo-tree
  if buftype == "nofile" and vim.bo[current_buf].filetype == "neo-tree" then
    -- If it's neo-tree, just close the window
    vim.api.nvim_win_close(current_win, false)
    return
  end

  -- Get list of valid buffers
  local valid_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted
      and vim.api.nvim_buf_get_option(buf, "buftype") ~= "nofile"
  end, vim.api.nvim_list_bufs())

  -- Remove the current buffer from the list
  valid_buffers = vim.tbl_filter(function(buf)
    return buf ~= current_buf
  end, valid_buffers)

  if #valid_buffers > 0 then
    -- Switch to the next buffer if available
    vim.api.nvim_set_current_buf(valid_buffers[1])
  else
    -- Find and focus neo-tree if it exists
    local neo_tree_win = vim.tbl_filter(function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      return vim.api.nvim_buf_get_option(buf, "filetype") == "neo-tree"
    end, vim.api.nvim_list_wins())[1]

    if neo_tree_win then
      vim.api.nvim_set_current_win(neo_tree_win)
    end
  end

  -- Delete the original buffer
  vim.api.nvim_buf_delete(current_buf, { force = false })
end, { desc = "Close current buffer" })
