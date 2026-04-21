-- [[ LSP DOMAIN: lua/autocmds/lsp.lua ]]
-- =============================================================================
-- Purpose: Autocommands related to Language Server Protocol features.
-- Domain:  Intelligence & Diagnostics
-- =============================================================================

local M = {}
local u = require("core.utils")

--- Refactored LSP Attachment
--- Why: Uses client:supports_method directly to avoid race conditions and
---      loops on every cursor move/save. Sets up buffer-local autocommands.
--- @param args table LspAttach autocmd callback args.
local lsp_attach = function(args)
	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if not client then
		return
	end

	-- [[ Inlay Hints ]]
	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
	end

	-- [[ Document Highlight ]]
	-- Highlights all instances of the symbol under the cursor.
	if client:supports_method("textDocument/documentHighlight") then
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
	-- Explicitly defined to override mini.jump's f/t hooks which otherwise
	-- intercept the trailing character of gr* sequences (e.g. grt, grf).
	u.nmap("grn", vim.lsp.buf.rename, "LSP: Rename", { buffer = args.buf })
	u.map({ "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP: Code Action", { buffer = args.buf })
	u.nmap("grr", vim.lsp.buf.references, "LSP: References", { buffer = args.buf })
	u.nmap("gri", vim.lsp.buf.implementation, "LSP: Implementation", { buffer = args.buf })
	u.nmap("grt", vim.lsp.buf.type_definition, "LSP: Type Definition", { buffer = args.buf })
	u.nmap("grx", vim.lsp.codelens.run, "LSP: CodeLens Run", { buffer = args.buf })
	u.nmap("gO", vim.lsp.buf.document_symbol, "LSP: Document Symbols", { buffer = args.buf })

	if client:supports_method("textDocument/declaration") then
		u.nmap("grd", vim.lsp.buf.declaration, "LSP: Declaration", { buffer = args.buf })
	end

	-- [[ Range Formatting ]]
	if client:supports_method("textDocument/rangeFormatting") then
		u.map("x", "<leader>f", function()
			vim.lsp.buf.format({ bufnr = args.buf })
		end, "LSP: Format Range", { buffer = args.buf })
	end

	-- [[ Code Lens ]]
	if client:supports_method("textDocument/codeLens") then
		u.nmap("<leader>cl", vim.lsp.codelens.run, "LSP: CodeLens Action", { buffer = args.buf })
		vim.lsp.codelens.enable(true, { bufnr = args.buf })
	end
end

-- [[ Diagnostic Configuration ]]
-- Define how errors and warnings are displayed globally.
vim.diagnostic.config({
	virtual_text = true, -- Show message at the end of the line
	signs = true, -- gutter signs (E/W)
})

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
