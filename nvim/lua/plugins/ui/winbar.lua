-- [[ NATIVE WINBAR: Code Context Breadcrumbs ]]
-- Purpose: Provide structural context (Class > Method) at the top of the window.
-- Domain:  UI / Aesthetics
-- Architecture: Direct-to-Metal (Zero-Proxy)
--
-- PHILOSOPHY: The Native Advantage
-- By leveraging Neovim 0.10's native Treesitter and Winbar APIs, we provide
-- high-performance breadcrumbs with ZERO external dependencies. This 
-- is "Anti-Fragile": it cannot break during plugin updates and adds 
-- negligible overhead to the rendering loop.
--
-- MAINTENANCE TIPS:
-- 1. If breadcrumbs are missing, ensure Treesitter is working for that filetype.
-- 2. To add icons for new node types, update the `type_to_kind` table.
-- 3. Performance: The winbar redrawing is tied to `redrawstatus` to avoid
--    excessive computation during high-speed scrolling.

local M = {}
local icons = require('core.icons').kinds

-- Mapping of Treesitter node types to our standardized Kind icons.
local type_to_kind = {
	-- Standard
	class_declaration    = "Class",
	class_definition     = "Class",
	method_declaration   = "Method",
	method_definition    = "Method",
	function_declaration = "Function",
	function_definition  = "Function",
	interface_declaration = "Interface",
	enum_declaration     = "Enum",
	struct_declaration   = "Struct",

	-- Lua
	function_item        = "Function",
	local_function       = "Function",

	-- Go
	type_declaration     = "Struct", -- Often used for structs
	method_spec          = "Method",

	-- Rust
	function_item        = "Function",
	impl_item            = "Class", -- Close enough for context
	trait_item           = "Interface",
}

--- Resolves the breadcrumb path for the current cursor position.
--- @return string The formatted winbar string.
function M.render()
	local bufnr = vim.api.nvim_get_current_buf()

	-- 1. BUFFER EXCLUSIONS: Ignore special, non-file, or empty buffers.
	if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "" then
		return ""
	end

	-- 2. FILE INFO: Name and modified marker.
	local filename = vim.fn.expand("%:t")
	local modified = vim.bo[bufnr].modified and " %#[email protected]#●%*" or ""
	local winbar_str = " " .. filename .. modified

	-- 3. TREESITTER CONTEXT: Walk up the tree to find named containers.
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return winbar_str
	end

	local parts = {}
	local current = node
	while current do
		local type = current:type()
		local kind = type_to_kind[type]

		-- If we found a node that we consider a "container" (class, function, etc.)
		if kind then
			local name_nodes = current:field("name")
			local name_node = name_nodes and name_nodes[1]
			if name_node then
				local name = vim.treesitter.get_node_text(name_node, bufnr)
				local icon = icons[kind] or ""
				table.insert(parts, 1, string.format("%%#Comment#›%%* %s%s", icon, name))
			end
		end
		current = current:parent()
	end

	-- 4. ASSEMBLY: Combine file info with the breadcrumb path.
	if #parts > 0 then
		winbar_str = winbar_str .. " " .. table.concat(parts, " ")
	end

	return winbar_str
end

--- Initializes the Winbar globally.
function M.setup()
	-- Set the winbar globally for all windows.
	-- %{% ... %} evaluates the Lua expression for every window redraw.
	vim.opt.winbar = "%{%v:lua.require'plugins.ui.winbar'.render()%}"

	-- Ensure it updates on cursor move to provide real-time context.
	vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter" }, {
		group = vim.api.nvim_create_augroup("NativeWinbar", { clear = true }),
		callback = function()
			-- Redrawing statusline also forces winbar to update.
			vim.cmd('redrawstatus')
		end,
	})
end

return M
