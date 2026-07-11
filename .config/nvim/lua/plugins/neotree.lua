return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {
      visible = true,
      show_hidden_count = true,
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_by_name = {
        ".git",
        ".DS_Store",
        "thumbs.db",
      },
      never_show_by_pattern = {},
      never_show = {},
    }

    local function is_godot_project()
      local cwd = vim.fn.getcwd()

      for _, dir in ipairs({ cwd, vim.fs.dirname(cwd) }) do
        if dir and vim.uv.fs_stat(dir .. "/project.godot") then
          return true
        end
      end

      return false
    end

    if is_godot_project() then
      table.insert(opts.filesystem.filtered_items.never_show_by_pattern, "*.uid")
    end

    opts.filesystem.group_empty_dirs = true
  end,
}
