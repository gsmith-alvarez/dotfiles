local T = MiniTest.new_set()
local utils = require('core.utils')

-- Setup: Before each test
T['setup'] = function()
  -- Ensure a clean state if needed
end

-- 1. Test mise_shim
T['mise_shim'] = MiniTest.new_set()

T['mise_shim']['resolves_system_binary'] = function()
  -- 'ls' is guaranteed to be on the system path
  local path = utils.mise_shim('ls')
  MiniTest.expect.equality(path, 'ls')
end

T['mise_shim']['returns_nil_for_missing_binary'] = function()
  local path = utils.mise_shim('non_existent_binary_xyz_123')
  MiniTest.expect.equality(path, nil)
end

-- 2. Test soft_notify
T['soft_notify'] = MiniTest.new_set()

T['soft_notify']['logs_to_file'] = function()
  local test_msg = "TEST_MESSAGE_" .. os.time()
  local log_path = vim.fn.stdpath('state') .. '/config_diagnostics.log'
  
  -- Clear or check existing log
  utils.soft_notify(test_msg, vim.log.levels.INFO)
  
  local file = io.open(log_path, "r")
  if not file then
    error("Log file not found at " .. log_path)
  end
  
  local content = file:read("*all")
  file:close()
  
  MiniTest.expect.equality(type(content:find(test_msg)), 'number')
end

return T
