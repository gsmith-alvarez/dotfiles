-- =============================================================================
-- [ LUASNIPS ]
-- Configuration for the snippet engine.
-- =============================================================================

local M = {}

local mini = Config.safe_require("plugins.mini")

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

	-- 1. Load friendly-snippets + custom VSCode/JSON snippets
	require("luasnip.loaders.from_vscode").lazy_load()
	require("luasnip.loaders.from_vscode").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets" },
	})

	-- 2. Load custom Lua snippets (for advanced logic)
	require("luasnip.loaders.from_lua").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
	})
end)

Config.safe_require("latex-tools").setup()

return M
