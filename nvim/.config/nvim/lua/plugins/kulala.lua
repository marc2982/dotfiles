-- Synctera / kulala integration commands
vim.api.nvim_create_user_command("SyncteraEnv", function(opts)
  require("synctera")["set-env"](opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "dev", "preview", "staging", "sandbox", "prod", "loadtest", "operations" }
  end,
  desc = "Switch the active Synctera env for kulala requests",
})

vim.api.nvim_create_user_command("SyncteraReset", function()
  require("synctera").clear()
end, { desc = "Clear synctera service registry and JWT caches" })

vim.api.nvim_create_user_command("SyncteraStatus", function()
  require("synctera").status()
end, { desc = "Show current Synctera env and JWT cache state" })

return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = "<leader>R",
    kulala_keymaps_prefix = "",
    debug = true,
    -- 1 MiB; default 32 KiB truncates real Synctera responses
    ui = { max_response_size = 1048576 },
    -- Don't attach kulala's LSP to plain json/yaml buffers. It also matches
    -- the compound `json.kulala_ui` filetype of kulala's own response window,
    -- where the buffer is not valid JSON (it has a summary header), producing
    -- bogus diagnostics. Restrict to http/rest only.
    lsp = { filetypes = { "http", "rest" } },
    -- Synctera service-name remap + auth header injection
    before_request = function(req)
      return require("synctera")["before-request"](req)
    end,
  },
}
