-- =============================================================================
-- [ SNACKS.NVIM ]
-- Configuration for the snacks.nvim utility collection.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"
if not mini then
  return
end

-- [[ GLOBAL DEBUG HELPERS ]]
-- Available immediately for bootstrap debugging.
_G.dd = function(...)
  require("snacks").debug.inspect(...)
end
_G.bt = function()
  require("snacks").debug.backtrace()
end

---@diagnostic disable-next-line: duplicate-set-field
vim._print = function(...)
  _G.dd(...)
end

mini.later(function()
  local snacks = Config.safe_require "snacks"
  snacks.setup {
    animate = { enabled = true },
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = false }, -- Will set up later
    debug = { enabled = true },
    dim = { enabled = true },
    gh = { enabled = true },
    git = { enabled = true },
    image = { enabled = true }, -- Comeback later for obsidian
    indent = {
      enabled = true,
      char = "│",
      scope = {
        enabled = true,
        char = "│",
        edge = true,
      },
      chunk = {
        enabled = true,
      },
    },
    lazygit = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    terminal = {
      shell = "/usr/bin/fish",
      win = {
        border = "rounded",
        winblend = 3,
        keys = { q = 'hide' },
        style = {
          statusline = " %{fnamemodify(getcwd(), ':~')} ",
        },
      },
    },
  }
end)

return M
