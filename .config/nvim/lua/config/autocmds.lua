-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Open neotree on startup when there are no arguments (plays nicely with auto-sessions)
if vim.fn.argc(-1) == 0 then
  vim.cmd("Neotree show")
end
