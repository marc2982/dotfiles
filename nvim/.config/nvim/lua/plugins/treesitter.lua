-- nvim-treesitter `main` branch (post-rewrite).
-- Requires Neovim 0.12+, tree-sitter-cli, and a C compiler.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  opts = {
    -- Languages to keep installed. install() is idempotent.
    ensure_installed = {
      "bash", "c", "diff", "go", "gomod", "gosum", "gowork",
      "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
      "html", "javascript", "jsdoc", "json", "json5", "jsonc",
      "lua", "luadoc", "luap", "make", "markdown", "markdown_inline",
      "ninja", "printf", "python", "query", "regex", "rst", "sql",
      "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
    },
  },
  config = function(_, opts)
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Install missing parsers asynchronously on startup.
    require("nvim-treesitter").install(opts.ensure_installed)

    -- Enable highlight + indent for every filetype that has a parser.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ft = args.match
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not vim.treesitter.language.add(lang) then
          return
        end
        pcall(vim.treesitter.start, args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
