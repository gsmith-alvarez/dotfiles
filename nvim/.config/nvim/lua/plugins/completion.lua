-- =============================================================================
-- [ COMPLETION ]
-- LuaSnip — snippet engine and loader.
-- blink.cmp — high-performance completion engine.
-- Note: blink.cmp Cargo build script is in plugin/02-pack.lua.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")
local icons = Config.safe_require("mini.icons")

-- -----------------------------------------------------------------------------
-- 1. [ LUASNIP ]
-- -----------------------------------------------------------------------------
mini.later(function()
	local ls = Config.safe_require("luasnip")
	local types = require("luasnip.util.types")

	ls.config.set_config({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = true,
		region_check_events = "InsertEnter",
		delete_check_events = "InsertEnter",
		ft_func = function()
			local ft = vim.bo.filetype
			local aliases = {
				ts = "typescript",
				tsx = "typescriptreact",
				js = "javascript",
				jsx = "javascriptreact",
				py = "python",
				sh = "bash",
				shell = "bash",
				yml = "yaml",
			}
			if ft ~= "markdown" and ft ~= "markdown.mdx" and ft ~= "mdx" then
				return { ft }
			end

			local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
			local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)
			local in_fence = false
			local fence_lang = nil

			for _, line in ipairs(lines) do
				if line:match("^%s*```+") then
					in_fence = not in_fence
					if in_fence then
						fence_lang = line:match("^%s*```+%s*([%w_+-]+)")
						if fence_lang then
							fence_lang = fence_lang:lower()
						end
					else
						fence_lang = nil
					end
				end
			end

			if in_fence and fence_lang and #fence_lang > 0 then
				fence_lang = aliases[fence_lang] or fence_lang
				return { ft, fence_lang }
			end

			return { ft }
		end,
		ext_opts = {
			[types.choiceNode] = {
				active = { virt_text = { { " ● Choice", "DiagnosticInfo" } } },
			},
		},
	})

	-- Load friendly-snippets + custom VSCode/JSON snippets
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_vscode").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets" },
	})

	-- Load custom Lua snippets (for advanced logic)
	require("luasnip.loaders.from_lua").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets" },
	})
end)

local latex_setup_done = false
local function setup_latex_tools_once()
	if latex_setup_done then
		return
	end

	local lt = Config.safe_require("latex-tools")
	if not lt then
		return
	end

	lt.setup({
		snippets = {
			filetypes = { "markdown" },
		},
	})

	latex_setup_done = true
end

mini.on_filetype("markdown", setup_latex_tools_once)
mini.on_filetype("markdown.mdx", setup_latex_tools_once)
mini.on_filetype("mdx", setup_latex_tools_once)

-- -----------------------------------------------------------------------------
-- 2. [ BLINK.CMP ]
-- -----------------------------------------------------------------------------
local function get_mini_icon(ctx)
	if ctx.source_name == "Path" then
		local is_unknown_type =
			vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, ctx.item.data.type)
		local mini_icon, mini_hl, _ =
			icons.get(is_unknown_type and "os" or ctx.item.data.type, is_unknown_type and "" or ctx.label)
		if mini_icon then
			return mini_icon, mini_hl
		end
	end
	local mini_icon, mini_hl, _ = icons.get("lsp", ctx.kind)
	return mini_icon, mini_hl
end

mini.later(function()
	local cmp = Config.safe_require("blink.cmp")
	cmp.build():wait(60000)
	cmp.setup({
		keymap = {
			preset = "super-tab",
			["<C-l>"] = { "snippet_forward", "accept", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
			["<C-j>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.select_next()
					end
					local ls = Config.safe_require("luasnip")
					if ls.choice_active() then
						ls.change_choice(1)
						return true
					end
				end,
				"fallback",
			},
			["<C-k>"] = {
				function(cmp)
					if cmp.is_visible() then
						return cmp.select_prev()
					end
					local ls = Config.safe_require("luasnip")
					if ls.choice_active() then
						ls.change_choice(-1)
						return true
					end
				end,
				"show_signature",
				"hide_signature",
				"fallback",
			},
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				update_delay_ms = 100,
			},
			ghost_text = { enabled = false },
			menu = {
				direction_priority = { "s", "n" },
				draw = {
					components = {
						kind_icon = {
							text = function(ctx)
								local kind_icon, _ = get_mini_icon(ctx)
								return kind_icon
							end,
							highlight = function(ctx)
								local _, hl = get_mini_icon(ctx)
								return hl
							end,
						},
						kind = {
							highlight = function(ctx)
								local _, hl = get_mini_icon(ctx)
								return hl
							end,
						},
					},
				},
			},
		},
		signature = {
			enabled = true,
			trigger = {
				show_on_keyword = false,
				show_on_trigger_character = true,
			},
			window = {
				direction_priority = { "n", "s" },
				show_documentation = false,
			},
		},
	})
end)
