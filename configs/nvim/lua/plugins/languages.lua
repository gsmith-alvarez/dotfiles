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
		"bash",
		"fish",
		"regex",
		"nix",
		"python",
		"rust",
		"zig",
		"cpp",
		"javascript",
		"typescript",
		"tsx",
		"html",
		"css",
		"json",
		"yaml",
		"toml",
		"kdl",
		"sql",
		"dockerfile",
		"latex",
		"gitcommit",
		"gitignore",
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
local clangd_cmd = { "clangd" }
if vim.env.CLANGD_QUERY_DRIVER and vim.env.CLANGD_QUERY_DRIVER ~= "" then
	table.insert(clangd_cmd, "--query-driver=" .. vim.env.CLANGD_QUERY_DRIVER)
end
vim.list_extend(clangd_cmd, {
	"--background-index",
	"--clang-tidy",
	"--header-insertion=never",
})

vim.lsp.config("clangd", {
	filetypes = { "c", "cpp", "objc", "objcpp" },
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
	cmd = clangd_cmd,
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

-- NIX (nil_ls)
vim.lsp.config("nil_ls", {
	settings = {
		["nil"] = {
			formatting = {
				command = { "nixfmt" },
			},
			nix = {
				binary = "nix",
				maxMemoryMB = 4096,
				flake = {
					autoArchive = true,
					autoEvalInputs = false,
					nixpkgsInputName = "nixpkgs",
				},
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
	"fish_lsp", -- Fish
	"nil_ls", -- Nix
	"rust_analyzer", -- Rust
	"zls", -- Zig
	"html", -- HTML
	"cssls", -- CSS
	"typos_lsp", -- Spell / Typo Checker
})

return M
