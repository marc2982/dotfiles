return {
  "ThePrimeagen/git-worktree.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    {
      "<leader>gws",
      function()
        local git_worktree = require("git-worktree")
        local output = vim.fn.systemlist("git worktree list")
        local items = {}
        for _, line in ipairs(output) do
          local fields = vim.split(string.gsub(line, "%s+", " "), " ")
          local path, sha, branch = fields[1], fields[2], fields[3]
          if sha ~= "(bare)" then
            table.insert(items, {
              text = string.format("%s  %s  %s", branch or "", path or "", sha or ""),
              path = path,
              branch = branch,
            })
          end
        end
        Snacks.picker({
          title = "Git Worktrees",
          items = items,
          format = function(item)
            local ret = {}
            table.insert(ret, { item.branch or "", "SnacksPickerLabel" })
            table.insert(ret, { "  " })
            table.insert(ret, { item.path or "", "SnacksPickerComment" })
            return ret
          end,
          confirm = function(picker, item)
            picker:close()
            if item and item.path then
              git_worktree.switch_worktree(item.path)
            end
          end,
        })
      end,
      desc = "List/Switch worktrees",
    },
    {
      "<leader>gwn",
      function()
        local git_worktree = require("git-worktree")
        Snacks.picker.git_branches({
          title = "New Worktree (select branch)",
          confirm = function(picker, item)
            picker:close()
            if not item then
              return
            end
            local branch = item.branch or item.text
            vim.ui.input({ prompt = "Worktree path (blank = branch name): " }, function(name)
              if name == nil then
                return
              end
              if name == "" then
                name = branch
              end
              git_worktree.create_worktree(name, branch)
            end)
          end,
        })
      end,
      desc = "New worktree",
    },
    {
      "<leader>gwr",
      function()
        local git_worktree = require("git-worktree")
        local output = vim.fn.systemlist("git worktree list")
        local items = {}
        for _, line in ipairs(output) do
          local fields = vim.split(string.gsub(line, "%s+", " "), " ")
          local path, sha, branch = fields[1], fields[2], fields[3]
          if sha ~= "(bare)" then
            table.insert(items, {
              text = string.format("%s  %s  %s", branch or "", path or "", sha or ""),
              path = path,
              branch = branch,
            })
          end
        end
        Snacks.picker({
          title = "Remove Worktree",
          items = items,
          format = function(item)
            local ret = {}
            table.insert(ret, { item.branch or "", "SnacksPickerLabel" })
            table.insert(ret, { "  " })
            table.insert(ret, { item.path or "", "SnacksPickerComment" })
            return ret
          end,
          confirm = function(picker, item)
            picker:close()
            if not item or not item.path then
              return
            end
            vim.ui.input({ prompt = "Delete worktree " .. item.path .. "? [y/n]: " }, function(answer)
              if answer and answer:lower():sub(1, 1) == "y" then
                git_worktree.delete_worktree(item.path)
              end
            end)
          end,
        })
      end,
      desc = "Remove worktree",
    },
  },
}
