-- =============================================================================
-- [ CORE ORCHESTRATOR ]
-- Manages the loading of all fundamental editor configurations.
-- =============================================================================

local M = {}

-- List of core modules to be loaded in sequence.
-- Order matters here: options should generally come before keymaps.
local sync_modules = {
    'core.options',         -- Global settings and behavior
    'core.path',            -- External tool path resolution (e.g. mise)
    'core.pack',            -- Plugin management and bootstrapping
    'core.keymaps',         -- Global, non-plugin keybindings
    'core.plugin-keymaps',  -- Keybindings specifically for plugin features
}

-- Iterate through the core modules and attempt to load each one safely.
for _, module in ipairs(sync_modules) do
    local ok, err = pcall(require, module)
    if not ok then
        -- Notify the user if a core module fails to load.
        -- Using vim.schedule prevents issues during the early startup phase.
        vim.schedule(function()
            vim.notify(
                string.format('[CORE MODULE FAILURE]\nModule: %s\nError: %s', module, err),
                vim.log.levels.ERROR,
                { title = 'Core Orchestrator' }
            )
        end)
    end
end

return M
