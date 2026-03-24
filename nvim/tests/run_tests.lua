-- [[ NEOTEST RUNNER ]]
-- Architecture: Headless test orchestrator

-- Ensure the project root and current dir are in RTP
local root = vim.fn.getcwd()
vim.opt.rtp:append(root)

-- Bootstrap mini.deps if needed (copied from lua/core/deps.lua)
local deps_path = vim.fn.stdpath('data') .. '/mini.deps'
if not vim.uv.fs_stat(deps_path) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.deps', deps_path })
end
vim.opt.rtp:prepend(deps_path)

local ok_deps, mini_deps = pcall(require, 'mini.deps')
if ok_deps then
  mini_deps.setup({ path = { package = deps_path } })
  -- Add mini.test
  mini_deps.add('echasnovski/mini.test')
end

local ok_test, mini_test = pcall(require, 'mini.test')
if not ok_test then
  error("Failed to load mini.test")
end

-- Setup MiniTest
_G.MiniTest = mini_test
MiniTest.setup({
  collect = {
    -- Find all test_*.lua files in the tests/ directory
    find_files = function()
      return vim.fn.globpath(root .. '/tests', 'test_*.lua', true, true)
    end,
  },
})

-- The actual run is triggered via the -c "lua MiniTest.run()" command line flag
