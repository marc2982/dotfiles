return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              format = { enable = false },
            },
            javascript = {
              format = { enable = false },
            },
          },
        },
      },
    },
  },
}
