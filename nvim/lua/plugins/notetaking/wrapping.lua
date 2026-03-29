-- [[ WRAPPING.NVIM: Intelligent Text Wrapping ]]
-- Domain: Notetaking & Prose
-- Location: lua/plugins/notetaking/wrapping.lua

local M = {}
local utils = require('core.utils')

function M.setup()
    require('mini.deps').add {
        source = 'andrewferrier/wrapping.nvim',
    }

    require('wrapping').setup {
        -- Disable the default loud notification
        notify_on_switch = false,
        -- Force these prose formats to default to SOFT wrapping 
        -- (Visual wrapping only, no physical newlines inserted)
        softener = { 
            markdown = true, 
            typst = true, 
            tex = true, 
            text = true, 
            latex = true, 
            asciidoc = true, 
            norg = true, 
            rst = true, 
            gitcommit = true, 
            mail = true 
        },
        -- Enable auto-wrapping for prose-heavy filetypes
        auto_set_mode_filetype_allowlist = {
            'asciidoc',
            'gitcommit',
            'latex',
            'mail',
            'markdown',
            'norg',
            'rst',
            'tex',
            'text',
            'typst',
        },
        create_keybindings = true,
        create_commands = true,
    }

    -- Intercept the WrappingSet event and route it to our DEBUG channel
    -- This keeps the UI completely quiet unless we are actively profiling.
    vim.api.nvim_create_autocmd('User', {
        pattern = 'WrappingSet',
        group = vim.api.nvim_create_augroup('WrappingNotifications', { clear = true }),
        callback = function(args)
            if args.data and args.data.mode then
                utils.soft_notify('Wrapping: ' .. args.data.mode .. ' mode enabled', vim.log.levels.DEBUG)
            end
        end,
    })
end

return M
