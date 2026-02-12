return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed =
        vim.list_extend(opts.ensure_installed, { "go", "gomod", "gosum", "gowork", "python", "vim", "yaml" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = true,
              buildFlags = { "-tags=integration,e2e,staging,slow,integrationv0,integrationrepo,bench,load,target" },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
      },
    },
  },
}
