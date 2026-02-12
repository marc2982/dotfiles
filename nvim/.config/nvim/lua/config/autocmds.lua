-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Use spaces for Python files (tabs for everything else)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
  end,
})

-- Highlight characters beyond column 121
vim.cmd([[highlight OverLength ctermfg=0 ctermbg=15 cterm=bold]])
vim.fn.matchadd("OverLength", [[\%>121v.\+]])

-- Auto-open neo-tree on startup (but not on dashboard)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Don't open if we're on the dashboard or no arguments
    if vim.fn.argc() == 0 then
      return
    end

    -- Defer to allow plugins to load
    vim.schedule(function()
      -- Check if Neotree command exists before calling it
      if vim.fn.exists(":Neotree") == 2 then
        vim.cmd("Neotree show")
      end
    end)
  end,
})

-- Disable LazyVim's aggressive whitespace trimming (ws-butler handles this better)
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimSetup",
  callback = function()
    -- Remove LazyVim's trim_whitespace autocmd if it exists
    pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_trim_whitespace")
  end,
})
