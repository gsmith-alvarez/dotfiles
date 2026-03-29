-- [[ SNACKS.NVIM: The Centralized Pillar ]]
-- Domain: Workflow, UI, Navigation, and Profiling
--
-- PHILOSOPHY: Extreme JIT Configuration
-- To achieve a sub-15ms startup, we defer the entire snacks.setup call.
-- Most Snacks modules are already lazy, but the setup() call itself
-- performs table merges and logic that we can push out of the hot path.

local M = {}
local utils = require 'core.utils'

-- Internal flag to prevent double-setup
local snacks_configured = false

--- Bootstraps the Snacks configuration only when needed.
--- Why: This avoids the ~7ms setup cost during the initial render.
M.bootstrap = function()
    if snacks_configured then
        return
    end

    local ok, err = pcall(function()
        require('snacks').setup {
            -- 1. UI: Immediate Message Interception
            notifier = {
                enabled = true,
                timeout = 3000,
                top_down = false,
                level = vim.log.levels.INFO,
            },

            -- 2. PROFILING
            profiler = { enabled = vim.env.PROFILE ~= nil },

            -- 3. WORKFLOW
            terminal = {
                win = { border = 'rounded', winblend = 3, keys = { q = 'hide' } },
            },

            -- 4. NAVIGATION
            picker = {
                enabled = true,
                ui_select = true,
                sources = {
                    files = {
                        hidden = true,
                        ignored = true,
                        exclude = { '.git', '.pio', 'node_modules', 'build' },
                    },
                },
                win = {
                    input = {
                        keys = {
                            ['<C-j>'] = { 'list_down', mode = { 'i', 'n' } },
                            ['<C-k>'] = { 'list_up', mode = { 'i', 'n' } },
                        },
                    },
                },
            },

            progress = { enabled = true },

            image = {
                enabled = true,
                resolve = function(file, src)
                    -- Custom Inject: YouTube Iframe Thumbnail Hack
                    -- (Relies on the after/queries/markdown/images.scm Treesitter injection)
                    local video_id = src:match('youtube%.com/embed/([a-zA-Z0-9_%-]+)')
                    if video_id then
                        return 'https://img.youtube.com/vi/' .. video_id .. '/maxresdefault.jpg'
                    end

                    -- Handle Obsidian wikilink-style image references [[image.png]]
                    -- and strip optional size arguments like [[image.png|200]]
                    local clean_src = src:gsub('^%[%[', ''):gsub('%]%]$', ''):gsub('|.*$', '')

                    local ok, obsidian = pcall(require, 'obsidian')
                    if not ok then
                        return
                    end

                    -- Only use Obsidian's resolver if we're in an active vault
                    -- and the current file is actually a note within that vault.
                    if _G.Obsidian and _G.Obsidian.workspace then
                        local api = obsidian.api
                        if api.path_is_note(file) then
                            -- 1. Try Obsidian's strict resolution
                            local resolved = api.resolve_attachment_path(clean_src)
                            if resolved and vim.fn.filereadable(resolved) == 1 then
                                return resolved
                            end

                            -- 2. Fallback: Search the entire vault for the image
                            -- (Handles attachments saved in deep sub-folders instead of root /attachments)
                            local vault_root = tostring(_G.Obsidian.workspace.root)
                            local basename = vim.fs.basename(clean_src)
                            local found = vim.fs.find(basename, {
                                path = vault_root,
                                type = 'file',
                                limit = 1,
                            })

                            if found and #found > 0 then
                                return found[1]
                            end
                        end
                    end
                end,
            },

            bigfile = { enabled = true },

            dashboard = { enabled = false },
            indent = { enabled = true },
            input = { enabled = false },
            scope = { enabled = false },
            scroll = { enabled = true },
            words = { enabled = true },
            statuscolumn = { enabled = false },
            lazygit = { enabled = true },
        }
    end)

    if ok then
        snacks_configured = true
    else
        utils.soft_notify('Snacks.nvim JIT setup failed: ' .. err, vim.log.levels.ERROR)
    end
end

M.setup = function()
    -- We no longer call setup() here.
    -- Instead, we wait for either a keymap trigger OR the first idle loop.

    -- Fallback: Load after boot is complete so background features (like notifications)
    -- eventually initialize without blocking the initial render.
    vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('SnacksJIT', { clear = true }),
        callback = function()
            -- We defer by 1ms to ensure we are completely out of the startup path.
            vim.defer_fn(M.bootstrap, 1)
        end,
    })
end

return M
