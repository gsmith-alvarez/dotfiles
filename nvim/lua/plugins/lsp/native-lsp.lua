-- [[ LSP: The Code Intelligence Engine ]]
-- Purpose: Direct, low-overhead LSP configuration using Neovim's native registry.
-- Domain:  LSP & Intelligence
-- Architecture: Native-First / Zero-Proxy
--
-- PHILOSOPHY: Native Capability Injection
-- We bypass the 'lspconfig' abstraction layer in favor of Neovim 0.10's
-- native 'vim.lsp.config' registry. This is a core "Anti-Fragile" decision:
-- by removing an entire plugin layer, we reduce memory footprint and 
-- eliminate an entire category of "plugin update" bugs.
--
-- MAINTENANCE TIPS:
-- 1. If a server isn't starting, verify its binary is in `mise ls`.
-- 2. Check `:messages` for "LSP server bin missing" warnings.
-- 3. Configuration for specific servers (like clangd) happens in the `servers` table.
-- 4. If a server behaves weirdly, check its specific `settings` or `args` below.

local M = {}
local utils = require 'core.utils'

M.setup = function()
        -- [[ THE BOOTSTRAPPER ]]
        local ok, err = pcall(function()
                local MiniDeps = require 'mini.deps'

                -- 1. Infrastructure Registration
                MiniDeps.add 'neovim/nvim-lspconfig' -- Required for server-specific logic stubs

                -- TARGET ADDITION: Snacks Notifier
                -- Replaces j-hui/fidget.nvim. This provides visual LSP progress and system
                -- notifications natively via Neovim 0.10+ and vim.notify.
                -- Fault Tolerance: Ensure snacks is available for early notifications.
                -- If it fails, we warn.
                local snacks_ok, _ = pcall(require, 'snacks')
                if not snacks_ok then
                        vim.notify('LSP: snacks.nvim not found. Proceeding without advanced notifications.',
                                vim.log.levels.WARN)
                end

                -- 2. Capability Resolution
                -- We explicitly pull capabilities from our blink.cmp engine.
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                local has_blink, blink = pcall(require, 'blink.cmp')
                if has_blink then
                        capabilities = blink.get_lsp_capabilities(capabilities)
                else
                        vim.notify('LSP: blink.cmp not found. Proceeding with default capabilities.', vim.log.levels
                        .WARN)
                end

                -- 3. The Server Registry
                -- Maps lspconfig names to mise binary shims.
                local servers = {
                        clangd = {
                                bin = 'clangd',

                                args = {
                                        -- 1. Standard "Quality of Life" features
                                        '--background-index',
                                        '--clang-tidy',
                                        '--header-insertion=iwyu',
                                        '--completion-style=detailed',
                                        '--function-arg-placeholders',
                                        '--fallback-style=llvm',

                                        -- 2. THE ZIG FIX: Allow clangd to query your zig compiler drivers
                                        -- This matches "zig" or "zig cc" in your compile_commands.json
                                        '--query-driver=' ..
                                        vim.fn.expand('$HOME') ..
                                        '/.local/share/mise/installs/zig/*/bin/zig,/usr/bin/zig,*/zig',
                                },
                                ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
                                root = {
                                        'compile_commands.json', -- Crucial: generate this with `zig build` or cmake
                                        '.git'
                                }
                        },
                        gopls = { bin = 'gopls', ft = { 'go' }, root = { 'go.work', 'go.mod', '.git' } },
                        rust_analyzer = { bin = 'rust-analyzer', ft = { 'rust' }, root = { 'Cargo.toml', 'Cargo.lock', '.git' } },
                        zls = { bin = 'zls', ft = { 'zig' }, root = { 'zls.json', 'build.zig', '.git' } },
                        pyright = { bin = 'pyright-langserver', args = { '--stdio' }, ft = { 'python' }, root = { 'pyproject.toml', '.git' } },
                        ruff = { bin = 'ruff', args = { 'server' }, ft = { 'python' }, root = { 'pyproject.toml', '.git' } },
                        ts_ls = {
                                bin = 'typescript-language-server',
                                args = { '--stdio' },
                                ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
                                root = { 'bun.lockb', 'package.json', '.git' },
                                init_options = {
                                        hostInfo = 'neovim',
                                        tsserver = {
                                                path = utils.get_tsdk_path(),
                                        },
                                },
                        },
                        sqls = { bin = 'sqls', ft = { 'sql' }, root = { '.git' } },
                        lua_ls = {
                                bin = 'lua-language-server',
                                ft = { 'lua' },
                                root = { '.luarc.json', '.git' },
                                settings = { Lua = { diagnostics = { globals = { 'vim' } }, workspace = { checkThirdParty = false } } },
                        },
                        tinymist = {
                                bin = 'tinymist',
                                ft = { 'typst' },
                                root = { 'main.typ', 'typst.toml', '.git' },
                                settings = {
                                        exportPdf = 'onSave', -- or "onType" for real-time PDF generation
                                        formatterMode = 'typstyle',
                                        semantic_tokens = 'enable',
                                },
                                -- Critical for encoding compatibility between Rust (UTF-8) and Neovim
                                capabilities = {
                                        offsetEncoding = { 'utf-8', 'utf-16' },
                                },
                        },
                        -- Formats/Config
                        jsonls = { bin = 'vscode-json-languageserver', args = { '--stdio' }, ft = { 'json' }, root = { '.git' } },
                        yamlls = { bin = 'yaml-language-server', args = { '--stdio' }, ft = { 'yaml' }, root = { '.git' } },
                        taplo = { bin = 'taplo', args = { 'lsp', 'stdio' }, ft = { 'toml' }, root = { '.git' } },
                        bashls = { bin = 'bash-language-server', args = { 'start' }, ft = { 'sh', 'bash' }, root = { '.git' } },
                        markdown_oxide = { bin = 'markdown-oxide', ft = { 'markdown' }, root = { '.git' } },
                }

                local configured_servers = {}

                for name, cfg in pairs(servers) do
                        local bin_path = utils.mise_shim(cfg.bin)

                        if bin_path then
                                -- Merge server-specific capabilities if they exist
                                local server_capabilities = vim.tbl_deep_extend('force', {}, capabilities,
                                        cfg.capabilities or {})

                                -- Construct native Neovim LSP configuration payload
                                vim.lsp.config[name] = {
                                        cmd = { bin_path, unpack(cfg.args or {}) },
                                        capabilities = server_capabilities,
                                        filetypes = cfg.ft,
                                        root_markers = cfg.root,
                                        settings = cfg.settings,
                                        init_options = cfg.init_options,
                                }
                                table.insert(configured_servers, name)
                        else
                                utils.soft_notify('LSP server bin missing: ' .. cfg.bin, vim.log.levels.WARN)
                        end
                end

                -- 4. Enable configured servers globally
                vim.lsp.enable(configured_servers)
        end)

        if not ok then
                utils.soft_notify('LSP Config engine failure: ' .. err, vim.log.levels.ERROR)
                return
        end

        -- [[ GLOBAL ATTACH LOGIC ]]
        -- This fires EVERY time a server attaches to a buffer.

        -- Rounded borders on hover and signature help
        vim.lsp.handlers['textDocument/hover']         = vim.lsp.with(vim.lsp.handlers.hover,           { border = 'rounded' })
        vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help,  { border = 'rounded' })

        vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('LSP_Attach_Common', { clear = true }),
                callback = function(event)
                        local client = vim.lsp.get_client_by_id(event.data.client_id)

                        local map = function(keys, func, desc, mode)
                                vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                        end

                        -- Standard Mappings
                        map('<leader>cn', vim.lsp.buf.rename, 'Re[n]ame')
                        map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ctions', { 'n', 'x' })
                        map('<leader>cc', vim.lsp.buf.declaration, 'Go to Declaration')

                        -- snacks.picker-integrated Intelligence
                        map('gd', function()
                                require('snacks').picker.lsp_definitions()
                        end, 'Definitions')
                        map('gr', function()
                                require('snacks').picker.lsp_references()
                        end, 'References')
                        map('<leader>ci', function()
                                require('snacks').picker.lsp_implementations()
                        end, 'Implementations')
                        map('<leader>ct', function()
                                require('snacks').picker.lsp_type_definitions()
                        end, 'Type Definitions')
                        map('<leader>co', function()
                                require('snacks').picker.lsp_symbols()
                        end, 'Document Symbols')

                        -- Semantic Highlighting
                        if client and client.server_capabilities.documentHighlightProvider then
                                local highlight_group = vim.api.nvim_create_augroup('LSP_Highlight_' .. event.buf,
                                        { clear = false })
                                vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                                        buffer = event.buf,
                                        group = highlight_group,
                                        callback = vim.lsp.buf.document_highlight,
                                })
                                vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                                        buffer = event.buf,
                                        group = highlight_group,
                                        callback = vim.lsp.buf.clear_references,
                                })
                        end

                        -- Inlay Hints (auto-enabled, toggle available)
                        if client and client.server_capabilities.inlayHintProvider then
                                vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                                map('<leader>ch', function()
                                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
                                end, 'Toggle Inlay [H]ints')
                        end
                        -- Typst watch keymap moved to plugins/workflow/typst-preview.lua
                end,
        })
end

return M
