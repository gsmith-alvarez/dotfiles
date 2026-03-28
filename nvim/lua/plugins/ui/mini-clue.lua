-- [[ MINI.CLUE: Key Hint Popup ]]
-- Purpose: Provide context-aware keybinding discovery for complex prefixes.
-- Domain:  UI / Discovery
-- Architecture: Immediate Setup (Fixed VimEnter Race Condition)
--
-- PHILOSOPHY: Discoverable Efficiency
-- Mini.clue provides a visual hint popup for multi-key sequences (like <leader>).
-- It is "Anti-Fragile" by using native Neovim menus instead of heavy floating
-- windows where possible.
--
-- BUG FIX: Previously, this was deferred to VimEnter, but that caused a race
-- condition when opening files directly (nvim file.txt). In that case, plugins.ui
-- loads via MiniDeps.later(), which runs AFTER VimEnter has already fired.
-- Now we setup immediately when this module loads.
--
-- MAINTENANCE TIPS:
-- 1. To add a new prefix category (e.g., <leader>x), add it to the `clues` table.
-- 2. If hints aren't appearing, verify the `triggers` table includes the
--    prefix key (e.g., 'g' or '<Leader>').
-- 3. The `delay` in `window` config controls how long to wait before showing.

local M = {}

M.setup = function()
  local miniclue = require 'mini.clue'
  miniclue.setup {
    triggers = {
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
      { mode = 'i', keys = '<C-x>' },
      { mode = 'n', keys = 'g' },
      { mode = 'x', keys = 'g' },
      { mode = 'n', keys = "'" },
      { mode = 'n', keys = '`' },
      { mode = 'x', keys = "'" },
      { mode = 'x', keys = '`' },
      { mode = 'n', keys = '"' },
      { mode = 'x', keys = '"' },
      { mode = 'i', keys = '<C-r>' },
      { mode = 'c', keys = '<C-r>' },
      { mode = 'n', keys = '<C-w>' },
      { mode = 'n', keys = 'z' },
      { mode = 'x', keys = 'z' },
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },
      { mode = { 'n', 'x' }, keys = 's' },
    },
    clues = {
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.windows(),
      miniclue.gen_clues.z(),
      { mode = 'n', keys = 'gS' },
      { mode = { 'n', 'x' }, keys = '<Leader>c', desc = '💻 Code' },
      { mode = 'n', keys = '<Leader>d', desc = '🐞 Debug' },
      { mode = 'n', keys = '<Leader>e', desc = '⚡ Execute' },
      { mode = { 'n', 'x' }, keys = '<Leader>g', desc = '📦 Git' },
      { mode = { 'n', 'x' }, keys = '<Leader>n', desc = '📝 Notes' },
      { mode = 'n', keys = '<Leader>o', desc = '🏃 Overseer' },
      { mode = 'n', keys = '<Leader>p', desc = '🚀 PlatformIO' },
      { mode = 'n', keys = '<Leader>q', desc = '💾 Session' },
      { mode = { 'n', 'x' }, keys = '<Leader>r', desc = '🛠️ Refactor' },
      { mode = 'n', keys = '<Leader>s', desc = '🔍 Search' },
      { mode = 'n', keys = '<Leader>t', desc = '🖥️ Terminal/TUI' },
      { mode = 'n', keys = '<Leader>T', desc = '🧪 Test' },
      { mode = 'n', keys = '<Leader>u', desc = '🛠️ Utils / Commands' },
      { mode = 'n', keys = '<Leader>v', desc = '👁️ View' },
      { mode = 'n', keys = '<Leader>w', desc = '🪟 Window' },
      { mode = 'n', keys = '<Leader>z', desc = '🧱 Zellij' },
      { mode = 'n', keys = '<Leader>b', desc = '󰓩 Buffers' },
      { mode = 'n', keys = '<Leader>f', desc = '🔭 Find' },
      { mode = 'n', keys = '<Leader>x', desc = ' Trouble' },
      { mode = 'n', keys = '<Leader>y', desc = '📋 Yank' },
    },
    window = { delay = 300, config = { width = 'auto', border = 'single' } },
  }
end

return M
