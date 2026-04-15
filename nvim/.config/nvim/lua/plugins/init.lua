-- =============================================================================
-- [ PLUGIN ORCHESTRATOR ]
-- Manages the loading and initialization of all plugin-specific configurations.
-- =============================================================================

local M = {}

-- List of plugin configuration modules to be loaded.
-- Each module is expected to handle the setup and configuration of specific plugins.
local plugin_modules = {
    'plugins.mini',         -- Configuration for mini.nvim collection
    'plugins.snacks',       -- Configuration for snacks.nvim
    'plugins.which-key',    -- Keybinding hints and discovery
    'plugins.languages',    -- LSP servers, Treesitter, and language support
    'plugins.blink',        -- Completion engine configuration
    'plugins.luaSnips',     -- Snippet engine configuration
    'plugins.conform',      -- [PLAN] Formatting & Linting
}

-- Iterate through the modules and load them safely.
for _, module in ipairs(plugin_modules) do
    local ok, err = pcall(require, module)
    if not ok then
        -- Notify the user if a plugin module fails to load.
        vim.schedule(function()
            vim.notify(
                string.format('[PLUGIN MODULE FAILURE]\nModule: %s\nError: %s', module, err),
                vim.log.levels.ERROR,
                { title = 'Plugin Orchestrator' }
            )
        end)
    end
end

return M
