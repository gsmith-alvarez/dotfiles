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
-- nvim-treesitter tracks the rewritten 'main' branch, where setup() only
-- accepts 'install_dir'. Parser installation is explicit and idempotent
-- (already-installed parsers are skipped).
-- Highlighting is started per-buffer by the FileType autocmd in
-- plugin/05-autocmds.lua (vim.treesitter.start) — the recommended pattern.
-- Node selection is built into Nvim 0.13: an/in (parent/child node) and
-- [n/]n/[N/]N (node/sibling) in Visual mode.
-- -----------------------------------------------------------------------------
mini.now(function()
	local ts = Config.safe_require("nvim-treesitter")
	ts.setup()
	ts.install({
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
		"html",
		"yaml",
	})
	-- textobjects is kept for its queries/*.scm files, which back the
	-- mini.ai treesitter textobjects (f/c/o specs). No modules are enabled.
	Config.safe_require("nvim-treesitter-textobjects").setup()
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

-- [ CAPABILITIES ]
-- blink.cmp does not auto-inject its capabilities; advertise them to every
-- server through the wildcard config (includes snippetSupport, so the old
-- jsonls-only override is no longer needed).
vim.lsp.config("*", { capabilities = Config.safe_require("blink.cmp").get_lsp_capabilities() })

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
