-- =============================================================================
-- [ PLUGIN MANAGEMENT ]
-- Uses Neovim's native 'vim.pack' system to manage and download plugins.
-- =============================================================================

local M = {}
local u = require("core.utils")

-- Use Snacks for notifications if available, fallback to native
local function notify(msg, level, opts)
	if pcall(require, "snacks") then
		require("snacks").notify(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

-- 1. [ HELPER FUNCTIONS ]
local function host(domain)
	return function(repo)
		return "https://" .. domain .. "/" .. repo
	end
end

local gh = host("github.com")

local function get_lib_extension()
	local os = jit.os:lower()
	if os == "mac" or os == "osx" then
		return ".dylib"
	end
	if os == "windows" then
		return ".dll"
	end
	return ".so"
end

local function notify_build_failed(name, obj)
	vim.schedule(function()
		notify(
			string.format("%s build failed (code=%d)", name, obj.code),
			vim.log.levels.ERROR,
			{ title = "plugin/02-pack.lua" }
		)
	end)
end

local function build_blink(path)
	if vim.fn.executable("cargo") ~= 1 then
		notify("cargo not found; skipping blink.cmp build", vim.log.levels.WARN)
		return
	end

	notify("Building blink.cmp in the background...", vim.log.levels.INFO)
	vim.system({ "cargo", "build", "--release" }, { cwd = path }, function(obj)
		if obj.code == 0 then
			vim.schedule(function()
				notify("blink.cmp build complete.", vim.log.levels.INFO)
			end)
			return
		end
		notify_build_failed("blink.cmp", obj)
	end)
end

local function build_luasnip(path)
	if vim.fn.executable("make") ~= 1 then
		notify("make not found; skipping LuaSnip build", vim.log.levels.WARN)
		return
	end

	notify("Building LuaSnip (jsregexp) in the background...", vim.log.levels.INFO)
	vim.system({ "make", "install_jsregexp" }, { cwd = path }, function(obj)
		local ext = get_lib_extension()
		local lib_dest = path .. "/deps/luasnip-jsregexp" .. ext
		if obj.code == 0 and vim.fn.filereadable(lib_dest) == 1 then
			vim.schedule(function()
				notify("LuaSnip build complete.", vim.log.levels.INFO)
			end)
			return
		end
		notify_build_failed("LuaSnip", obj)
	end)
end

-- 2. [ AUTOMATIC POST-INSTALL/UPDATE HOOKS ]
local build_kinds = { "install", "update" }

u.on_packchanged("blink.cmp", build_kinds, function(data)
	build_blink(data.path)
end, "Build blink.cmp")

u.on_packchanged("LuaSnip", build_kinds, function(data)
	build_luasnip(data.path)
end, "Build LuaSnip")

-- 3. [ PLUGIN SPECIFICATIONS ]
vim.pack.add({
	gh("echasnovski/mini.nvim"),
	gh("echasnovski/mini.icons"),
	gh("folke/snacks.nvim"),
	gh("folke/which-key.nvim"),
	gh("Bekaboo/dropbar.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("folke/lazydev.nvim"),
	"https://plugins.ejri.dev/mise.nvim",
	gh("nvim-treesitter/nvim-treesitter"),
	gh("nvim-treesitter/nvim-treesitter-textobjects"),
	gh("rafamadriz/friendly-snippets"),
	gh("saghen/blink.cmp"),
	gh("MeanderingProgrammer/render-markdown.nvim"),
	gh("obsidian-nvim/obsidian.nvim"),
	gh("gsmith-alvarez/latex-tools.nvim"),
	gh("L3MON4D3/LuaSnip"),
})

-- 4. [ SELF-HEALING STARTUP CHECK ]
local data_site = vim.fn.stdpath("data") .. "/site/pack/core/opt"
local blink_path = data_site .. "/blink.cmp"
local luasnip_path = data_site .. "/LuaSnip"

if
	vim.fn.isdirectory(blink_path) == 1
	and vim.fn.filereadable(blink_path .. "/target/release/libblink_cmp_fuzzy" .. get_lib_extension()) == 0
then
	build_blink(blink_path)
end

if
	vim.fn.isdirectory(luasnip_path) == 1
	and vim.fn.filereadable(luasnip_path .. "/deps/luasnip-jsregexp" .. get_lib_extension()) == 0
then
	build_luasnip(luasnip_path)
end

return M
