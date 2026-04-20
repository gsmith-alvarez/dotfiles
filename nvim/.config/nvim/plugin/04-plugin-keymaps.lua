-- =============================================================================
-- [ PLUGIN KEYMAPS ]
-- Keybindings that specifically target and require external plugins.
-- =============================================================================
local M = {}
local u = Config.safe_require "core.utils"
-- 1. [ MINI.FILES ]
-- Toggle the file explorer using the '-' key (mnemonic: think of a tree branch).
u.nmap("-", function()
	local mf = Config.safe_require "mini.files"
	-- Attempt to close the explorer. If it's already closed (returns false), open it.
	if not mf.close() then
		local path = vim.api.nvim_buf_get_name(0)
		-- Case 1: Empty buffer (new file) or already inside a minifiles buffer.
		-- Fallback to the current working directory.
		if path == "" or path:match "^minifiles://" then
			path = vim.fn.getcwd()
		-- Case 2: Buffer has a name, but the file doesn't exist on disk yet.
		elseif vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
			-- Attempt to open at the parent directory of the intended file path.
			path = vim.fn.fnamemodify(path, ":p:h")
			-- Safety net: If the parent folder doesn't exist either, fallback to CWD.
			if vim.fn.isdirectory(path) == 0 then
				path = vim.fn.getcwd()
			end
		end
		-- Open the file explorer at the resolved path.
		mf.open(path)
	end
end, "File: Explorer (toggle)")
return M
