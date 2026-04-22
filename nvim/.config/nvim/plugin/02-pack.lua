-- =============================================================================
-- [ PLUGIN MANAGEMENT ]
-- Uses Neovim's native 'vim.pack' system to manage and download plugins.
-- =============================================================================

local M = {}
local u = require("core.utils")

-- Use Snacks for notifications if available, fallback to native
local function notify(msg, level, opts)
	local snacks = Config.safe_require("snacks")
	if snacks then
		snacks.notify(msg, vim.tbl_extend("force", { level = level }, opts or {}))
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

local function build_blink()
	local ok, cmp = pcall(require, "blink.cmp")
	if not ok then
		notify("blink.cmp not loadable; skipping build", vim.log.levels.WARN, { title = "plugin/02-pack.lua" })
		return
	end
	notify("Building blink.cmp...", vim.log.levels.INFO, { title = "plugin/02-pack.lua" })
	local build_ok, err = pcall(function()
		cmp.build():wait(60000)
	end)
	vim.schedule(function()
		if build_ok then
			notify("blink.cmp build complete.", vim.log.levels.INFO, { title = "plugin/02-pack.lua" })
		else
			notify("blink.cmp build failed: " .. tostring(err), vim.log.levels.ERROR, { title = "plugin/02-pack.lua" })
		end
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

u.on_packchanged("blink.cmp", build_kinds, function()
	build_blink()
end, "Build blink.cmp")

u.on_packchanged("LuaSnip", build_kinds, function(data)
	build_luasnip(data.path)
end, "Build LuaSnip")

-- 3. [ PLUGIN SPECIFICATIONS ]
vim.pack.add({
	gh("catppuccin/nvim"),
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
	gh("saghen/blink.lib"),
	gh("saghen/blink.cmp"),
	gh("MeanderingProgrammer/render-markdown.nvim"),
	gh("obsidian-nvim/obsidian.nvim"),
	gh("gaoDean/autolist.nvim"),
	gh("gsmith-alvarez/latex-tools.nvim"),
	gh("L3MON4D3/LuaSnip"),
	gh("stevearc/quicker.nvim"),
	gh("kevinhwang91/nvim-bqf"),
	gh("gsmith-alvarez/sigils.nvim"),
})

-- 4. [ SELF-HEALING STARTUP CHECK ]
local data_site = vim.fn.stdpath("data") .. "/site/pack/core/opt"
local blink_path = data_site .. "/blink.cmp"
local luasnip_path = data_site .. "/LuaSnip"

local site_lib = vim.fn.stdpath("data") .. "/site/lib"
if vim.fn.isdirectory(blink_path) == 1 and vim.fn.glob(site_lib .. "/libblink_cmp_fuzzy*") == "" then
	build_blink()
end

if
	vim.fn.isdirectory(luasnip_path) == 1
	and vim.fn.filereadable(luasnip_path .. "/deps/luasnip-jsregexp" .. get_lib_extension()) == 0
then
	build_luasnip(luasnip_path)
end

return M
