return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "proto",
        "yaml",
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "buf",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",

    init = function()
      vim.filetype.add({
        filename = {
          ["buf.yaml"] = "buf-config",
          ["buf.gen.yaml"] = "buf-config",
          ["buf.policy.yaml"] = "buf-config",
          ["buf.lock"] = "buf-config",
        },
      })

      vim.treesitter.language.register("yaml", "buf-config")
    end,

    opts = {
      servers = {
        buf_ls = {},
      },
    },
  },
}
