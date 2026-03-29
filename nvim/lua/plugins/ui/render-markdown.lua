-- [[ RENDER-MARKDOWN: Typographic Visual Augmentation ]]
-- Purpose: Enhance Markdown documents with stylized headers, lists, and tables.
-- Domain:  UI & Aesthetics
-- Architecture: FileType-Aware Sandbox (Phased Boot)
--
-- PHILOSOPHY: Context-Aware Activation
-- Markdown rendering is computationally expensive. To remain "Anti-Fragile,"
-- we strictly sandbox this plugin to only initialize when a Markdown file
-- is actually opened. This prevents Treesitter overhead from affecting
-- Lua or Rust editing sessions.
--
-- MAINTENANCE TIPS:
-- 1. If rendering is slow, check if the file is massive (Treesitter bottleneck).
-- 2. This plugin only activates on specific FileTypes (markdown, org, etc.).
-- 3. Heading icons can be customized in the `heading.icons` table.

local M = {}
local utils = require 'core.utils'

-- [[ DEFERRED BOOTSTRAPPER: FileType Sandbox ]]
local group = vim.api.nvim_create_augroup('UI_RenderMarkdown', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'markdown', 'markdown.mdx', 'norg', 'rmd', 'org' },
    callback = function()
        local ok, err = pcall(function()
            require('mini.deps').add {
                source = 'MeanderingProgrammer/render-markdown.nvim',
                -- Explicitly define dependencies to guarantee render stability
                depends = {
                    'nvim-treesitter/nvim-treesitter',
                    'echasnovski/mini.icons',
                },
            }

            require('render-markdown').setup {
                -- Minimalist configuration. The plugin has excellent defaults,
                -- This we render with snacks.image
                latex = { enabled = false },
                -- Explicitly define the heading style for visual hierarchy.
                heading = {
                    sign = false,
                    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                },
            }
        end)

        if not ok then
            utils.soft_notify('Render-markdown failed to initialize: ' .. err, vim.log.levels.ERROR)
        end

        -- Self-destruct to ensure this bootstrap logic only runs once per session
        vim.api.nvim_clear_autocmds { group = 'UI_RenderMarkdown' }
    end,
})

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M
