return {
  "mrcjkb/rustaceanvim",
  opts = {
    server = {
      settings = {
        -- The following settings are required to make rust-analyzer work with Arduino / HAL projects
        ["rust-analyzer"] = {
          cargo = {
            target = nil,
          },
          checkOnSave = {
            allTargets = false,
          },
        },
      },
    },
  },
}
