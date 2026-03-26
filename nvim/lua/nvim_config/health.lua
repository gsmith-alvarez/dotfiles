-- [[ HEALTH CHECK: nvim_config ]]
-- Domain: System Integrity / Diagnostics
-- Location: lua/nvim_config/health.lua
--
-- PHILOSOPHY: Empirical Validation
-- We don't guess if the system is broken; we audit it. This health check
-- validates the entire configuration layer, from plugin installation
-- to LSP binary presence.
--
-- WHY: We use this instead of standard `:checkhealth` to verify
-- the "Phased Boot" status of JIT plugins and our Mise-managed binaries.
--
-- MAINTENANCE TIPS:
-- 1. Invoked via `:checkhealth nvim_config` or `:NvimHealth`.
-- 2. To add new dependencies to the audit, update the tables in 
--    `check_plugins`, `check_lsp`, or `check_tools`.
-- 3. If a tool is marked as "not found," check your `mise install` status.

local M = {}

local opt_path = vim.fn.stdpath('data') .. '/mini.deps/pack/deps/opt'

local function plugin_installed(name)
	return vim.fn.isdirectory(opt_path .. '/' .. name) == 1
end

-- ============================================================================
-- SECTION 1: Plugin Layer
-- ============================================================================
local function check_plugins()
	vim.health.start('Plugin Layer')

	-- Always-on plugins (installed in MiniDeps.now boot path)
	local core_plugins = {
		{ 'mini.nvim',              'mini.nvim (icons, sessions, statusline, diff…)' },
		{ 'snacks.nvim',            'snacks.nvim (picker, notifier, terminal)' },
		{ 'blink.cmp',              'blink.cmp (completion)' },
		{ 'nvim-lspconfig',         'nvim-lspconfig (LSP registry)' },
		{ 'nvim-treesitter',        'nvim-treesitter (parsing)' },
		{ 'nvim-treesitter-textobjects', 'treesitter-textobjects' },
		{ 'render-markdown.nvim',   'render-markdown.nvim' },
		{ 'lazydev.nvim',           'lazydev.nvim (Lua intelligence)' },
	}

	for _, p in ipairs(core_plugins) do
		if plugin_installed(p[1]) then
			vim.health.ok(p[2])
		else
			vim.health.error(p[2] .. ' — NOT installed (run nvim fresh to bootstrap)')
		end
	end

	-- JIT plugins (installed on first use)
	vim.health.start('Plugin Layer — JIT (installed on first use)')

	local jit_plugins = {
		{ 'aerial.nvim',          'aerial.nvim',          '<leader>va' },
		{ 'obsidian.nvim',        'obsidian.nvim',        'open a markdown file' },
		{ 'trouble.nvim',         'trouble.nvim',         '<leader>xx' },
		{ 'overseer.nvim',        'overseer.nvim',        '<leader>ot' },
		{ 'nvim-dap',             'nvim-dap',             '<leader>db' },
		{ 'nvim-dap-virtual-text','nvim-dap-virtual-text','<leader>db' },
		{ 'typst-preview.nvim',   'typst-preview.nvim',   'open a .typ file' },
		{ 'smart-splits.nvim',    'smart-splits.nvim',    '<C-h/j/k/l>' },
	}

	for _, p in ipairs(jit_plugins) do
		if plugin_installed(p[1]) then
			vim.health.ok(p[2] .. ' — installed')
		else
			vim.health.warn(p[2] .. ' — not yet installed (trigger: ' .. p[3] .. ')')
		end
	end
end

-- ============================================================================
-- SECTION 2: LSP Binaries
-- ============================================================================
local function check_lsp()
	vim.health.start('LSP Binaries')

	local servers = {
		{ 'pyright-langserver',           'Python (pyright)' },
		{ 'ruff',                         'Python linter (ruff)' },
		{ 'rust-analyzer',                'Rust' },
		{ 'gopls',                        'Go' },
		{ 'zls',                          'Zig' },
		{ 'clangd',                       'C/C++' },
		{ 'lua-language-server',          'Lua' },
		{ 'markdown-oxide',               'Markdown' },
		{ 'taplo',                        'TOML' },
		{ 'bash-language-server',         'Bash' },
		{ 'tinymist',                     'Typst' },
		{ 'vscode-json-languageserver',   'JSON' },
		{ 'yaml-language-server',         'YAML' },
		{ 'typescript-language-server',   'TypeScript/JavaScript' },
	}

	for _, s in ipairs(servers) do
		local path = vim.fn.executable(s[1]) == 1 and s[1] or nil
		if path then
			vim.health.ok(s[2] .. ' (' .. s[1] .. ')')
		else
			vim.health.warn(s[2] .. ' — ' .. s[1] .. ' not found (mise install ' .. s[1] .. ')')
		end
	end
end

-- ============================================================================
-- SECTION 3: Active LSP Servers
-- ============================================================================
local function check_active_lsp()
	vim.health.start('Active LSP Servers (current buffer)')

	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.health.warn('No LSP servers attached to current buffer')
	else
		for _, client in ipairs(clients) do
			vim.health.ok(client.name .. ' (id=' .. client.id .. ')')
		end
	end
end

-- ============================================================================
-- SECTION 4: Critical External Tools
-- ============================================================================
local function check_tools()
	vim.health.start('External Tools (mise)')

	local tools = {
		{ 'rg',        'ripgrep (required for grep picker)' },
		{ 'fd',        'fd (required for file picker)' },
		{ 'lazygit',   'lazygit' },
		{ 'stylua',    'stylua (Lua formatter)' },
		{ 'mise',      'mise (toolchain manager)' },
		{ 'zellij',    'zellij (multiplexer)' },
	}

	for _, t in ipairs(tools) do
		if vim.fn.executable(t[1]) == 1 then
			vim.health.ok(t[2])
		else
			vim.health.warn(t[2] .. ' — not found')
		end
	end
end

-- ============================================================================
-- ENTRY POINT
-- ============================================================================
M.check = function()
	check_plugins()
	check_lsp()
	check_active_lsp()
	check_tools()
end

return M
