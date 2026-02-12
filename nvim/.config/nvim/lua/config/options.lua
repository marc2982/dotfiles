-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Indentation (LazyVim defaults to spaces, but we want tabs)
vim.opt.expandtab = false -- use tabs instead of spaces
vim.opt.tabstop = 4 -- tab width
vim.opt.shiftwidth = 4 -- indent width
vim.opt.softtabstop = 4 -- backspace removes 4 spaces

-- Line length and wrapping
vim.opt.wrap = true
vim.opt.textwidth = 127
vim.opt.colorcolumn = "128" -- visual guide at 128 characters

vim.opt.swapfile = false
vim.opt.autoread = true
