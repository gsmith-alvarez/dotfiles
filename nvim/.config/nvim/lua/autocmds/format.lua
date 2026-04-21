-- [[ FORMAT DOMAIN: lua/autocmds/format.lua ]]
-- =============================================================================
-- Purpose: Format on save for multiple filetypes using external tools or LSP.
-- Domain:  Formatting
-- =============================================================================

local M = {}

M.setup = {
	{
		event = "BufWritePre",
		pattern = "*.lua",
		action = function()
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local input = table.concat(lines, "\n")
			local result = vim.system({ "stylua", "-" }, { stdin = input }):wait()
			if result.code == 0 then
				local new_lines = vim.split(result.stdout, "\n", { plain = true })
				if new_lines[#new_lines] == "" then
					table.remove(new_lines)
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
			end
		end,
		desc = "Format Lua with stylua",
	},
	{
		event = "BufWritePre",
		pattern = { "*.sh", "*.bash" },
		action = function()
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local result = vim.system({ "shfmt", "-" }, { stdin = table.concat(lines, "\n") }):wait()
			if result.code == 0 then
				local new_lines = vim.split(result.stdout, "\n", { plain = true })
				if new_lines[#new_lines] == "" then
					table.remove(new_lines)
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
			end
		end,
		desc = "Format Shell with shfmt",
	},
	{
		event = "BufWritePre",
		pattern = "*.fish",
		action = function()
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local result = vim.system({ "fish_indent" }, { stdin = table.concat(lines, "\n") }):wait()
			if result.code == 0 then
				local new_lines = vim.split(result.stdout, "\n", { plain = true })
				if new_lines[#new_lines] == "" then
					table.remove(new_lines)
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
			end
		end,
		desc = "Format Fish with fish_indent",
	},
	{
		event = "BufWritePre",
		pattern = "*",
		action = function()
			local ft = vim.bo.filetype
			local skip = { lua = true, sh = true, bash = true, fish = true, markdown = true, text = true }
			if not skip[ft] then
				vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
			end
		end,
		desc = "LSP format on save for other filetypes",
	},
}

return M
