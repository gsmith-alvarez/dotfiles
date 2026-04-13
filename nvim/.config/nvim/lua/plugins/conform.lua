-- =============================================================================
-- [ CONFORM & FORMATTING PLAN ]
-- Goal: Implement non-blocking formatting and integrate with native linting.
-- =============================================================================

-- [[ STEP 1: REGISTRATION ]]
-- Add 'stevearc/conform.nvim' to lua/core/pack.lua and run :PackUpdate.

-- [[ STEP 2: CONFIGURATION ]]
-- Map specific filetypes to their respective formatters (managed by mise).
-- 
-- Recommended Mapping:
-- - python: { "ruff_format" }
-- - lua:    { "stylua" }
-- - cpp/c:  { "clang-format" }
-- - sh:     { "shfmt" }
-- - "*":    { "codespell" } -- Optional: global spell checker

-- [[ STEP 3: MISE SYNC ]]
-- Ensure binaries (stylua, shfmt, clang-format) are installed via mise.
-- Since path.lua already adds shims to PATH, conform will find them automatically.

-- [[ STEP 4: FORMAT ON SAVE ]]
-- Implement the `format_on_save` callback:
-- - lsp_fallback = true (uses LSP if no specific formatter is found)
-- - timeout_ms = 500

-- [[ STEP 5: VIRTUAL TEXT (LINTING) ]]
-- Since linting is handled by LSPs (Ruff/Lua_LS), configure the visuals here:
--
-- vim.diagnostic.config({
--   virtual_text = {
--     prefix = '●', -- Or use icons from mini.icons
--     severity = { min = vim.diagnostic.severity.WARN }
--   },
--   float = { border = 'rounded' },
-- })

-- [[ STEP 6: KEYBINDINGS ]]
-- Add to lua/core/keymaps.lua:
-- - <leader>cf : Trigger manual format

local M = {}

-- TODO: Implement require('conform').setup({ ... })

return M
