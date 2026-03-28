local T = MiniTest.new_set()

T['Boot'] = MiniTest.new_set()

T['Boot']['Sequence'] = function()
  -- Verifies that the primary modules in the boot sequence are accessible and loadable.
  -- This effectively tests Phase 1 and Phase 2.

  -- Load init.lua to verify it runs without error
  local ok_init = pcall(dofile, 'init.lua')
  MiniTest.expect.equality(ok_init, true)
end

T['Boot']['JIT Deferral'] = function()
  -- Test the JIT automation trigger
  -- Initially, autocmds should be set up
  local autocmds = vim.api.nvim_get_autocmds { group = 'JIT_Automation' }
  MiniTest.expect.equality(#autocmds > 0, true)
end

return T
