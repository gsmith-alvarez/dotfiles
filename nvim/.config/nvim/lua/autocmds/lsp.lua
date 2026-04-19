-- [[ LSP DOMAIN: lua/autocmds/lsp.lua ]]
-- =============================================================================
-- Purpose: Autocommands related to Language Server Protocol features.
-- Domain:  Intelligence & Diagnostics
-- =============================================================================

local M = {}

--- Enable inlay hints for the current buffer if supported by the server.
local lsp_attach = function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client and client:supports_method('textDocument/inlayHint') then
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
	end
end

--- Highlight all instances of the symbol under the cursor.
local symbol_highlight = function()
	-- Only run if NOT in insert mode to avoid flickering during typing.
	if vim.fn.mode() ~= 'i' then
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		local supports_highlight = false
		for _, client in ipairs(clients) do
			if client.server_capabilities.documentHighlightProvider then
				supports_highlight = true
				break
			end
		end

		-- Proceed only if an LSP is active AND supports this feature.
		if supports_highlight then
			vim.lsp.buf.clear_references()
			vim.lsp.buf.document_highlight()
		end
	end
end

-- [[ Diagnostic Configuration ]]
-- Define how errors and warnings are displayed globally.
vim.diagnostic.config({
	virtual_text = true, -- Show message at the end of the line
	signs = false,       -- Hide gutter signs (E/W) for a cleaner UI
})

-- [[ Autocmd Definitions ]]
-- Exported to the registrar for automatic setup.
M.setup = {
	{
		event = 'LspAttach',
		pattern = '*',
		action = lsp_attach,
		desc = 'Enable LSP inlay hints on attach',
	},
	{
		event = 'CursorMoved',
		pattern = '*',
		action = symbol_highlight,
		desc = 'LSP Reference Highlighting',
	},
}

return M
