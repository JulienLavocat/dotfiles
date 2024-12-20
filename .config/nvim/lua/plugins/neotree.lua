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
      never_show = {},
    }
    opts.filesystem.group_empty_dirs = true
  end,
}
