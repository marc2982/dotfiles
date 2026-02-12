return {
  "andythigpen/nvim-coverage",
  version = "*", -- Use the latest version
  config = function()
    require("coverage").setup({
      auto_reload = true, -- Optional: Automatically reload coverage when report file changes
      -- Further configuration options can be added here
    })
  end,
  dependencies = { "nvim-lua/plenary.nvim" }, -- Plenary is a required dependency
}
