return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  { "tokyonight.nvim", enabled = false },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
