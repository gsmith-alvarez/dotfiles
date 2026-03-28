local T = MiniTest.new_set()

T['Utils'] = MiniTest.new_set()

T['Utils']['soft_notify'] = function()
  local utils = require 'core.utils'
  local log_path = vim.fn.stdpath 'state' .. '/config_diagnostics.log'

  -- Clear or backup current log if needed, but for testing we can just check if new entry is appended
  local test_msg = 'TEST_LOG_ENTRY_' .. os.time()

  -- Mock vim.notify to avoid UI noise during tests
  local old_notify = vim.notify
  local notified_msg, notified_level
  vim.notify = function(msg, level)
    notified_msg = msg
    notified_level = level
  end

  utils.soft_notify(test_msg, vim.log.levels.WARN)

  -- Restore vim.notify
  vim.notify = old_notify

  -- 1. Check if vim.notify was called
  MiniTest.expect.equality(notified_msg, test_msg)
  MiniTest.expect.equality(notified_level, vim.log.levels.WARN)

  -- 2. Check if it was written to the file
  local file = io.open(log_path, 'r')
  if file then
    local content = file:read '*a'
    file:close()
    MiniTest.expect.equality(content:find(test_msg) ~= nil, true)
    MiniTest.expect.equality(content:find '%[WARN%]' ~= nil, true)
  else
    error('Could not open log file: ' .. log_path)
  end
end

return T
