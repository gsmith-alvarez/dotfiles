-- languages

local M = {}
local mini = Config.safe_require("plugins.mini")

-- 1. Treesitter
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
		"nix",
	})
	Config.safe_require("nvim-treesitter-textobjects").setup()
end)

-- 2. Diagnostics

-- DIAGNOSTICS: UI & SIGNS
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
})

-- 3. LSP

Config.safe_require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- LUA (lua_ls)
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false },
			hint = { enable = true, setType = true },
		},
	},
})

-- C/C++ (clangd)
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
	cmd = {
		"clangd",
		"--background-index", -- Force clangd to index the project in the background
		"--clang-tidy", -- Enable linter diagnostics
		"--header-insertion=never", -- Prevents auto-inserting unwanted headers
	},
})
-- PYTHON (Astral: ty & ruff)
vim.lsp.config("ty", {
	settings = {
		ty = {
			diagnosticMode = "workspace",
		},
	},
})

-- Bash
vim.lsp.config("bashls", {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
})

vim.lsp.config("ruff", {
	settings = {},
})

vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	settings = {
		nixd = {
			formatting = {
				command = { "nixfmt" },
			},
		},
	},
})
-- blink.cmp doesn't auto-inject capabilities; advertise via wildcard when present.
local blink = Config.safe_require("blink.cmp")
if blink then
	vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

-- 4. Activation
vim.lsp.enable({
	"ty", -- Python Type Checker
	"ruff", -- Python Linter & Formatter
	"lua_ls", -- Lua
	"bashls", -- Bash
	"clangd", -- C/C++
	"jsonls", -- JSON
	"yamlls", -- YAML
	"dockerls", -- Docker
	"taplo", -- TOML
	"nixd", -- Nix
})

return M
