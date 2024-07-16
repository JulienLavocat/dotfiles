-- source: https://www.youtube.com/watch?v=CEMPq_r8UYQ&t=920s
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              -- assignment
              ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
              ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
              ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
              ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

              -- parameter
              ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

              -- conditional
              ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

              -- loop
              ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
              ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

              -- call
              ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
              ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

              -- method / function
              ["am"] = { query = "@function.outer", desc = "Select outer part of a function definition" },
              ["im"] = { query = "@function.inner", desc = "Select inner part of a function definition" },

              -- class
              ["ac"] = { query = "@class.outer", desc = "Select outer part of a class definition" },
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class definition" },
            },
          },
        },
      })
    end,
  },
}
