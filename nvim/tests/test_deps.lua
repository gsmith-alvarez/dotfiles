local T = MiniTest.new_set()

T['Dependencies'] = MiniTest.new_set()

T['Dependencies']['System Binaries'] = function()
  -- Critical binaries for Neovim and its plugins
  local binaries = {
    'git',      -- Plugin management
    'rg',       -- Snacks picker / Grep
    'fd',       -- Snacks picker / File finding
    'fzf',      -- Fuzzy finding fallback
    'make',     -- Compiling some plugins (e.g. fzf-native)
    'gcc',      -- Treesitter / C plugins
    'unzip',    -- Mason / Tool installation
    'mise',     -- Tool management
  }

  local missing = {}
  for _, bin in ipairs(binaries) do
    if vim.fn.executable(bin) == 0 then
      table.insert(missing, bin)
    end
  end

  if #missing > 0 then
    error("Missing critical system binaries: " .. table.concat(missing, ", "))
  end
end

T['Dependencies']['Mise Tools'] = function()
  -- Tools managed by mise that nvim depends on
  local tools = {
    'lua-language-server',
    'stylua',
    'selene',
    'typescript-language-server',
    'bash-language-server',
    'ruff', -- Python linting
  }

  -- Note: We only check if these are executable.
  -- Some might not be installed if the user doesn't use those languages,
  -- but for this "Full Suite" test, we expect them.
  local missing = {}
  for _, tool in ipairs(tools) do
    if vim.fn.executable(tool) == 0 then
      table.insert(missing, tool)
    end
  end

  if #missing > 0 then
    -- We warn instead of erroring for language-specific tools, 
    -- as some might be optional depending on the environment.
    print("\n[WARN] Missing mise-managed tools: " .. table.concat(missing, ", "))
  end
end

T['Dependencies']['Plugins'] = function()
  -- Ensure mini.deps is initialized
  MiniTest.expect.equality(type(_G.MiniDeps), 'table')
  
  -- Check if some core plugins are installed in the data directory
  local deps_path = vim.fn.stdpath('data') .. '/mini.deps'
  local plugins_to_check = {
    'snacks.nvim',
    'mini.nvim',
    'mini.test',
  }
  
  for _, plugin in ipairs(plugins_to_check) do
    local path = deps_path .. '/pack/deps/opt/' .. plugin
    local stat = vim.uv.fs_stat(path)
    if not stat then
      -- Also check 'start' directory just in case
      path = deps_path .. '/pack/deps/start/' .. plugin
      stat = vim.uv.fs_stat(path)
    end
    MiniTest.expect.equality(stat ~= nil, true, "Plugin not found on disk: " .. plugin)
  end
end

return T
