return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "fredrikaverpil/neotest-golang",
        version = "*",
        dependencies = {
          "andythigpen/nvim-coverage",
        },
      },
    },
    -- Override default keys to clear output before running
    keys = {
      {
        "<leader>tr",
        function()
          local neotest = require("neotest")
          neotest.output_panel.clear()
          neotest.output_panel.open()
          neotest.run.run()
        end,
        desc = "Run Nearest (Clear Output)",
      },
      {
        "<leader>tt",
        function()
          local neotest = require("neotest")
          neotest.output_panel.clear()
          neotest.output_panel.open()
          neotest.run.run(vim.fn.expand("%"))
        end,
        desc = "Run File (Clear Output)",
      },
    },
    opts = {
      status = { virtual_text = true }, -- Shows pass/fail at end of lines
      output = { open_on_run = true }, -- Auto-opens the panel (doesnt seem to work)
      adapters = {
        ["neotest-golang"] = {
          runner = "gotestsum", -- specialized runner for nested tests
          go_test_args = {
            "-v",
            "-count=1",
            "-tags=integration",
            "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
          },
        },
      },
    },
  },
}
