local function find_godot_project_root()
  local cwd = vim.fn.getcwd()

  for _, dir in ipairs({ cwd, vim.fs.dirname(cwd) }) do
    if dir and vim.uv.fs_stat(dir .. "/project.godot") then
      return dir
    end
  end

  return nil
end

local function is_godot_server_running(project_path)
  return vim.uv.fs_stat(project_path .. "/server.pipe") ~= nil
end

local function start_godot_server_if_needed()
  local project_path = find_godot_project_root()

  if project_path and not is_godot_server_running(project_path) then
    vim.notify("Starting Godot server for project: " .. project_path, vim.log.levels.INFO)
    vim.fn.serverstart(project_path .. "/server.pipe")
    vim.lsp.enable("gdscript", true)
    vim.lsp.enable("gdshader_lsp", true)
  end
end

-- Check if we're running inside a Godot project and start a server if needed
start_godot_server_if_needed()

return {
  { "habamax/vim-godot" },
  { "skywind3000/asyncrun.vim" },
  { "teatek/gdscript-extended-lsp.nvim", opts = { view_type = "floating", picker = "snacks" } },
}
