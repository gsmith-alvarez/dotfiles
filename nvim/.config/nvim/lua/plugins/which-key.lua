-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local ok, wk = pcall(require, 'which-key')
if not ok then return end

-- 1. [ INITIALIZATION ]
-- Use the 'modern' preset for a clean, visually appealing UI.
wk.setup {
    preset = 'helix',
}
