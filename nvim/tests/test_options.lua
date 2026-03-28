local T = MiniTest.new_set()

T['Options'] = MiniTest.new_set()

T['Options']['core.options'] = function()
  -- Load options
  require 'core.options'

  -- Test some basic options from lua/core/options.lua
  MiniTest.expect.equality(vim.o.number, true)
  MiniTest.expect.equality(vim.o.relativenumber, true)
  MiniTest.expect.equality(vim.o.splitright, true)
  MiniTest.expect.equality(vim.o.splitbelow, true)
  MiniTest.expect.equality(vim.o.undofile, true)
end

T['Options']['Leader key'] = function()
  require 'core.options'
  MiniTest.expect.equality(vim.g.mapleader, ' ')
end

return T
