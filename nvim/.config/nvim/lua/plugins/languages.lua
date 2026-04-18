-- =============================================================================
-- [ LANGUAGES ]
-- Comprehensive configuration for Language Servers and Treesitter.
-- This file acts as the source of truth for language-specific intelligence.
-- =============================================================================

local M = {}

local mini = require('plugins.mini')

mini.later(function()
	-- 1. [ TREESITTER: SYNTAX & PARSING ]
	-- Manage Treesitter parsers and enable automatic installation for core languages.
	require('tree-sitter-manager').setup({
		ensure_installed = { 'python', 'cpp', 'bash', 'fish', 'lua', 'markdown', 'markdown_inline' },
		auto_install = true,
	})

	-- 2. [ LSP: LANGUAGE SERVER REGISTRY ]
	-- Configure individual language servers using the native Neovim LSP client.
	-- Binaries are resolved via mise (see plugin/01-path.lua).

	-- [ C/C++ (clangd) ]
	vim.lsp.config('clangd', {
		cmd = {
			'clangd',
			'--background-index',
			'--clang-tidy',
			'--completion-style=detailed',
			'--fallback-style=llvm',
		},
		filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
		root_markers = { 'compile_commands.json', '.git' },
	})

	-- [ PYTHON (ty) ]
	-- 'ty' is a fast, specialized Python server for intelligence and navigation.
	vim.lsp.config('ty', {
		cmd = { 'ty', 'server' },
		filetypes = { 'python' },
		root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
	})

	-- [ PYTHON (ruff) ]
	-- 'ruff' provides high-performance linting and formatting as a language server.
	vim.lsp.config('ruff', {
		cmd = { 'ruff', 'server' },
		filetypes = { 'python' },
		root_markers = { 'pyproject.toml', '.git' },
	})

	-- [ LUA (lua_ls) ]
	vim.lsp.config('lua_ls', {
		cmd = { 'lua-language-server' },
		filetypes = { 'lua' },
		root_markers = { '.luarc.json', '.git' },
		settings = {
			Lua = {
				diagnostics = { globals = { 'vim', 'Config' } }, -- What to recongize as globals
				workspace = { checkThirdParty = false },
			},
		},
	})

	-- [ BASH (bashls) ]
	vim.lsp.config('bashls', {
		cmd = { 'bash-language-server', 'start' },
		filetypes = { 'sh', 'bash' },
	})

	-- [ TOML (taplo) ]
	vim.lsp.config('taplo', {
		cmd = { 'taplo', 'lsp', 'stdio' },
		filetypes = { 'toml' },
	})

	-- [ YAML (yamlls) ]
	vim.lsp.config('yamlls', {
		cmd = { 'yaml-language-server', '--stdio' },
		filetypes = { 'yaml' },
		root_markers = { '.git' },
		settings = {
			yaml = {
				format = { enable = true },
				schemaStore = { enable = true },
			},
		},
	})

	-- [ JSON (jsonls) ]
	vim.lsp.config('jsonls', {
		cmd = { 'vscode-json-languageserver', '--stdio' },
		filetypes = { 'json', 'jsonc' },
		root_markers = { '.git' },
	})

	-- [ DOCKER (dockerls) ]
	vim.lsp.config('dockerls', {
		cmd = { 'docker-langserver', '--stdio' },
		filetypes = { 'dockerfile' },
		root_markers = { 'Dockerfile', '.git' },
	})

	-- 3. [ ACTIVATION ]
	-- Enable the configured servers for the current session.
	vim.lsp.enable({
		'ty', -- Python (Astral)
		'ruff', -- Python (Formatting/Linting)
		'lua_ls', -- Lua
		'bashls', -- Bash
		'clangd', -- C/C++
		'jsonls', -- JSON
		'yamlls', -- YAML
		'dockerls', -- Docker
		'taplo', -- TOML
	})
end)

return M
