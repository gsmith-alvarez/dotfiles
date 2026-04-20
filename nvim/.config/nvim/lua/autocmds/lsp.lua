-- [[ LSP DOMAIN: lua/autocmds/lsp.lua ]]
-- =============================================================================
-- Purpose: Autocommands related to Language Server Protocol features.
-- Domain:  Intelligence & Diagnostics
-- =============================================================================

local M = {}
local u = require "core.utils"

--- Refactored LSP Attachment
--- Why: Uses client:supports_method directly to avoid race conditions and
---      loops on every cursor move/save. Sets up buffer-local autocommands.
local lsp_attach = function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if not client then
		return
	end

	-- [[ Inlay Hints ]]
	if client:supports_method "textDocument/inlayHint" then
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
	end

	-- [[ Document Highlight ]]
	-- Highlights all instances of the symbol under the cursor.
	if client:supports_method "textDocument/documentHighlight" then
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = args.buf,
			callback = function()
				if vim.fn.mode() ~= "i" then
					vim.lsp.buf.clear_references()
					vim.lsp.buf.document_highlight()
				end
			end,
			desc = "LSP Reference Highlighting",
		})
	end

	-- [[ Keymaps ]]
	-- grn: Rename, gra: Code Action, grr: References, gri: Implementation, gO: Symbols.
	local function map(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
	end

	if client:supports_method "textDocument/definition" then
		map("gd", vim.lsp.buf.definition, "Go to Definition")
	end

	if client:supports_method "textDocument/typeDefinition" then
		map("gy", vim.lsp.buf.type_definition, "Type Definition")
	end

	if client:supports_method "textDocument/declaration" then
		map("gD", vim.lsp.buf.declaration, "Go to Declaration")
	end

	-- [[ Range Formatting ]]
	if client:supports_method "textDocument/rangeFormatting" then
		vim.keymap.set("x", "<leader>f", function()
			vim.lsp.buf.format { bufnr = args.buf }
		end, { buffer = args.buf, desc = "LSP: Format Range" })
	end

	-- [[ Code Lens ]]
	if client:supports_method "textDocument/codeLens" then
		map("<leader>cl", vim.lsp.codelens.run, "CodeLens Action")
		vim.lsp.codelens.enable(true, { bufnr = args.buf })
	end
end

-- [[ Diagnostic Configuration ]]
-- Define how errors and warnings are displayed globally.
vim.diagnostic.config {
	virtual_text = true, -- Show message at the end of the line
	signs = true, -- gutter signs (E/W)
}

-- [[ Autocmd Definitions ]]
-- Exported to the registrar for automatic setup.
M.setup = {
	{
		event = "LspAttach",
		pattern = "*",
		action = lsp_attach,
		desc = "Initialize LSP features on attach",
	},
}

return M
