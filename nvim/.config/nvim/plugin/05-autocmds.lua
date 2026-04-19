-- =============================================================================
-- [ GLOBAL AUTOCOMMANDS ]
-- Event-driven automation and UI enhancements.
-- =============================================================================
local u = require('core.utils')

-- 1. [ TREESITTER ATTACHMENT ]
-- Automatically start Treesitter highlighting for supported filetypes.
local treesitter_attach = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if lang then
        pcall(vim.treesitter.start, args.buf, lang)
    end
end
u.autocmd('FileType', '*', treesitter_attach, 'Automatically start Treesitter highlighting')

-- 2. [ UI POLISH ]
-- Highlight the text briefly after it is yanked to provide visual feedback.
local highlight_yank = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
end
u.autocmd('TextYankPost', '*', highlight_yank, 'Highlight yanked text')

-- 3. [ CURSOR PERSISTENCE ]
-- Retains the position of the cursor between Neovim instances.
local cursor_persist = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
        vim.api.nvim_win_set_cursor(0, mark)
        -- Defer centering slightly so it's applied after the buffer renders.
        vim.schedule(function()
            vim.cmd('normal! zz')
        end)
    end
end
u.autocmd('BufReadPost', '*', cursor_persist, 'Restore cursor position on file open')

-- 4. [ WINDOW BEHAVIOR ]
-- Ensure help files open in a vertical split on the right.
u.autocmd('FileType', 'help', 'wincmd L', 'Open help in a vertical split')

-- Automatically equalize splits when the terminal window is resized.
u.autocmd('VimResized', '*', 'wincmd =', 'Equalize splits on window resize')

-- 5. [ FILETYPE OVERRIDES ]
-- Force specific highlighting for secret files or configurations.
u.autocmd('BufRead', { '.env', '.env.*' }, function()
    vim.bo.filetype = 'dosini'
end, 'Syntax highlighting for secret files')

-- 6. [ WHITESPACE MANAGEMENT ]
-- Convert tabs to spaces on save to maintain consistent formatting.
u.autocmd('BufWritePre', '*', 'retab!', 'Convert tabs to spaces on save')

-- 7. [ MODULAR REGISTRATION ]
-- Load domain-specific autocommands from the lua/autocmds/ directory.
-- Maintained either for really large commands or for specific categories
local autocmds = require('autocmds')
autocmds.register('lsp')
