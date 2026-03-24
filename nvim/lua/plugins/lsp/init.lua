-- [[ LSP DOMAIN ORCHESTRATOR ]]
-- Purpose: Orchestrate the "Code Intelligence" stack with a focus on startup speed.
-- Domain:  LSP & Intelligence
-- Architecture: Phased Boot / Ordered Injection
--
-- PHILOSOPHY: The "Strict Order" Protocol
-- In an Anti-Fragile system, dependencies must be deterministic. We load
-- 'blink.cmp' BEFORE 'native-lsp' to ensure that when LSP servers attach, 
-- they immediately receive the enhanced completion capabilities (snippets, 
-- documentation, fuzzy matching) broadcast by the completion engine.
--
-- MAINTENANCE TIPS:
-- 1. If completions are missing, check `blink.lua`.
-- 2. If servers fail to attach, check `native-lsp.lua` for binary paths.
-- 3. Use `:LspInfo` to debug active server connections.

local M = {}
local utils = require 'core.utils'

local modules = {
	'lsp.blink',      -- Completion engine (must be first)
	'lsp.native-lsp', -- Server configs + keymaps
}

for _, mod in ipairs(modules) do
	local module_path = 'plugins.' .. mod
	local ok, mod_or_err = pcall(require, module_path)
	if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
		local setup_ok, setup_err = pcall(mod_or_err.setup)
		if not setup_ok then
			utils.soft_notify(string.format('LSP SETUP FAILURE: [%s]\n%s', module_path, setup_err), vim.log.levels.ERROR)
		end
	elseif not ok then
		utils.soft_notify(string.format('LSP DOMAIN FAILURE: [%s]\n%s', module_path, mod_or_err), vim.log.levels.ERROR)
	end
end

return M
