-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Clear search highlighting
vim.keymap.set("n", "<leader><space>", ":noh<CR>", { silent = true, desc = "Clear search highlighting" })

-- Quick escape in insert mode
vim.keymap.set("i", "jf", "<ESC>", { desc = "Exit insert mode" })

-- Keep visual selection when indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Find non-ASCII characters
vim.keymap.set("n", "<F6>", "/[^ -~^I]<CR>", { desc = "Find non-ASCII characters" })

-- Alt-based window navigation (works in both normal and terminal modes)
-- This provides consistent Alt+h/j/k/l navigation everywhere
vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Move to right window" })

-- Terminal mode window navigation (for Claude Code and other terminal buffers)
-- Using Alt key to avoid conflicts with terminal's Ctrl-h (backspace)
vim.keymap.set("t", "<M-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window from terminal" })
vim.keymap.set("t", "<M-j>", "<C-\\><C-n><C-w>j", { desc = "Move to bottom window from terminal" })
vim.keymap.set("t", "<M-k>", "<C-\\><C-n><C-w>k", { desc = "Move to top window from terminal" })
vim.keymap.set("t", "<M-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window from terminal" })

-- grep for the current word under the cursor
vim.keymap.set("n", "<leader>f/", function()
  require("telescope.builtin").live_grep({
    default_text = vim.fn.expand("<cword>"),
  })
end, { desc = "Grep word under cursor" })

-- Revert H and L to native behavior
vim.keymap.set("n", "H", "H", { desc = "Cursor to top of screen" })
vim.keymap.set("n", "L", "L", { desc = "Cursor to bottom of screen" })
