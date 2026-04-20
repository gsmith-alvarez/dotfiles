local M = {}

-- 1. [ INITIALIZATION ]
-- Use the global Config.safe_require to load the icon provider.
-- This aligns with the 'clay-dots' architecture for fault tolerance.
local icon_provider = Config.safe_require "mini.icons"

--- Safe Icon Fetcher
--- @param category string The mini.icons category (lsp, diagnostic, file, etc.)
--- @param name string The icon name within that category
--- @param fallback string String to return if category/icon is missing
local function get(category, name, fallback)
	-- If safe_require failed, it returned false
	if not icon_provider then
		return fallback
	end

	-- Guard against invalid categories to prevent [SEQUENCE FAILURE]
	-- mini.icons validates categories strictly.
	local success, icon = pcall(icon_provider.get, category, name)
	if not success or not icon then
		return fallback
	end

	return icon
end

-- 2. [ REGISTRY ]

M.kinds = {
	Array = get("lsp", "array", " "),
	Boolean = get("lsp", "boolean", "󰨙 "),
	Class = get("lsp", "class", " "),
	Color = get("lsp", "color", " "),
	Control = get("lsp", "control", " "),
	Collapsed = get("lsp", "collapsed", " "),
	Constant = get("lsp", "constant", " "),
	Constructor = get("lsp", "constructor", " "),
	Enum = get("lsp", "enum", " "),
	EnumMember = get("lsp", "enummember", " "),
	Event = get("lsp", "event", " "),
	Field = get("lsp", "field", " "),
	File = get("lsp", "file", " "),
	Folder = get("lsp", "folder", " "),
	Function = get("lsp", "function", " "),
	Interface = get("lsp", "interface", " "),
	Key = get("lsp", "key", " "),
	Keyword = get("lsp", "keyword", " "),
	Method = get("lsp", "method", " "),
	Module = get("lsp", "module", " "),
	Namespace = get("lsp", "namespace", " "),
	Null = get("lsp", "null", " "),
	Number = get("lsp", "number", "󰎠 "),
	Object = get("lsp", "object", " "),
	Operator = get("lsp", "operator", " "),
	Package = get("lsp", "package", " "),
	Property = get("lsp", "property", " "),
	Reference = get("lsp", "reference", " "),
	Snippet = get("lsp", "snippet", " "),
	String = get("lsp", "string", " "),
	Struct = get("lsp", "struct", " "),
	Text = get("lsp", "text", " "),
	TypeParameter = get("lsp", "typeparameter", " "),
	Unit = get("lsp", "unit", " "),
	Value = get("lsp", "value", " "),
	Variable = get("lsp", "variable", " "),
}

M.git = {
	added = " ",
	modified = " ",
	removed = " ",
	renamed = "➜ ",
	untracked = " ",
	ignored = "◌ ",
	unstaged = "✗ ",
	staged = "✓ ",
	conflict = " ",
}

M.diagnostics = {
	Error = get("diagnostic", "error", " "),
	Warn = get("diagnostic", "warn", " "),
	Hint = get("diagnostic", "hint", "󰌵 "),
	Info = get("diagnostic", "info", " "),
}

M.ui = {
	BigError = " ",
	BigWarning = " ",
	BigInfo = " ",
	BigHint = " ",
	Lock = " ",
	CircleNone = " ",
	CirclePaused = "󰏤 ",
	CirclePlay = "󰐊 ",
	CircleStop = "󰓛 ",
	CircleFilled = " ",
}

return M
