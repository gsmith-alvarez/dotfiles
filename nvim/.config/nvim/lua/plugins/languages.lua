-- =============================================================================
-- [ LANGUAGES ]
-- Source of truth for language-specific intelligence.
-- Treesitter — syntax, parsing, and text objects.
-- LSP        — language server configuration and activation.
-- =============================================================================

local M = {}
local mini = Config.safe_require("plugins.mini")

-- -----------------------------------------------------------------------------
-- 1. [ TREESITTER ]
-- Uses 'now' to ensure parsers are available immediately for pickers.
-- -----------------------------------------------------------------------------
mini.now(function()
	require("nvim-treesitter").setup({
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"markdown",
			"markdown_inline",
			"python",
			"cpp",
			"bash",
			"fish",
			"latex",
			"regex",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		incremental_selection = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
			},
			move = {
				enable = true,
				set_jumps = true,
			},
		},
	})
end)

-- -----------------------------------------------------------------------------
-- 2. [ DIAGNOSTICS ]
-- -----------------------------------------------------------------------------

-- [ DIAGNOSTICS: UI & SIGNS ]
-- Configure the diagnostic engine to use mini.icons.
-- Uses the 'signs.text' table for gutter icons.
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = require("mini.icons").get("lsp", "error"),
			[vim.diagnostic.severity.WARN] = require("mini.icons").get("lsp", "warn"),
			[vim.diagnostic.severity.HINT] = require("mini.icons").get("lsp", "hint"),
			[vim.diagnostic.severity.INFO] = require("mini.icons").get("lsp", "info"),
		},
	},
	virtual_text = {
		spacing = 4,
		prefix = "●",
	},
	severity_sort = true,
	float = { border = "rounded" },
})

-- -----------------------------------------------------------------------------
-- 3. [ LSP ]
-- -----------------------------------------------------------------------------
-- Use vim.lsp.config() to merge project-specific overrides with the
-- default configurations provided by nvim-lspconfig.

Config.safe_require("lazydev").setup({
	library = {
		-- load luvit types when vim.uv is found
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- [ LUA (lua_ls) ]
-- Note: lazydev.nvim handles the VIMRUNTIME and workspace library injection.
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false },
			hint = { enable = true, setType = true },
		},
	},
})

-- [ C/C++ (clangd) ]
vim.lsp.config("clangd", {
	filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
	settings = {
		clangd = {
			InlayHints = {
				Designators = true,
				Enabled = true,
				ParameterNames = true,
				DeducedTypes = true,
			},
		},
	},
})

-- [ JSON (jsonls) ]
-- Enable snippet support for jsonls (often required for schema completions)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("jsonls", {
	capabilities = capabilities,
})

-- 4. [ ACTIVATION ]
-- Enable the configured servers for the current session.
vim.lsp.enable({
	"ty", -- Python (Astral)
	"ruff", -- Python (Formatting/Linting)
	"lua_ls", -- Lua
	"bashls", -- Bash
	"clangd", -- C/C++
	"jsonls", -- JSON
	"yamlls", -- YAML
	"dockerls", -- Docker
	"taplo", -- TOML
})

return M
