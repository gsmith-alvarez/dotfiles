-- =============================================================================
-- [ BLINK.CMP ]
-- Configuration for the high-performance completion engine.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")
local icons = Config.safe_require("mini.icons")

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
								local kind_icon, kind_hl = get_mini_icon(ctx)
								return kind_icon
							end,
							-- (optional) use highlights from mini.icons
							highlight = function(ctx)
								local _, hl = get_mini_icon(ctx)
								return hl
							end,
						},
						kind = {
							-- (optional) use highlights from mini.icons
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
				show_on_insert_on_trigger_character = true,
			},
			window = {
				border = "rounded",
				direction_priority = { "n", "s" },
				show_documentation = false,
			},
		},
	})
end)

-- Note: Automated build script (Cargo) is in plugin/02-pack.lua.

return M
