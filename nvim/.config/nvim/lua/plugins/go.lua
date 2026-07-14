return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- Use the PATH gopls (~/go/bin/gopls); don't let Mason install/manage a second copy.
          mason = false,
          cmd = { "gopls" },
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
