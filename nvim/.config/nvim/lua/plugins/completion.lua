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
		paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
	})
end)

local latex_setup_done = false
local function setup_latex_tools_once()
	if latex_setup_done then
		return
	end
	Config.safe_require("latex-tools").setup()
	latex_setup_done = true
end

mini.on_filetype("tex", setup_latex_tools_once)
mini.on_filetype("plaintex", setup_latex_tools_once)
mini.on_filetype("markdown", setup_latex_tools_once)

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
	require("blink.cmp").setup({
		keymap = {
			preset = "super-tab",
			["<C-l>"] = { "snippet_forward", "accept", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "show_signature", "hide_signature", "fallback" },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				-- HACK: blink.cmp@61a1391 defines add_source_provider() calling validate_provider which
				-- doesn't exist in config/sources.lua. Declared here statically to bypass that broken path.
				-- When fixed, remove these three providers and set completion.blink = true in obsidian setup.
				obsidian = {
					name = "obsidian",
					module = "obsidian.completion.sources.blink.refs",
					async = true,
					opts = {},
					enabled = function()
						return vim.bo.filetype == "markdown"
							and vim.bo.buftype ~= "prompt"
							and vim.b.completion ~= false
					end,
				},
				obsidian_new = {
					name = "obsidian_new",
					module = "obsidian.completion.sources.blink.new",
					async = true,
					opts = {},
					enabled = function()
						return vim.bo.filetype == "markdown"
							and vim.bo.buftype ~= "prompt"
							and vim.b.completion ~= false
					end,
				},
				obsidian_tags = {
					name = "obsidian_tags",
					module = "obsidian.completion.sources.blink.tags",
					async = true,
					opts = {},
					enabled = function()
						return vim.bo.filetype == "markdown"
							and vim.bo.buftype ~= "prompt"
							and vim.b.completion ~= false
					end,
				},
			},
		},
		completion = {
			trigger = {
				show_on_insert_on_trigger_character = true,
			},
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

return M
