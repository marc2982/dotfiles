-- Fugitive (Git wrapper)
return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  keys = {
    { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
    { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    { "<leader>gl", "<cmd>Git log<cr>", desc = "Git log" },
  },
}
