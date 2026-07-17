-- [[ LSP DOMAIN: lua/autocmds/lsp.lua ]]
-- =============================================================================
-- Purpose: Autocommands related to Language Server Protocol features.
-- Domain:  Intelligence & Diagnostics
-- =============================================================================

local M = {}
local u = require("core.utils")

---@type table<number, { token: lsp.ProgressToken, msg: string, done: boolean }[]>
local progress = vim.defaulttable()

local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local lsp_progress = function(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	local value = ev.data.params.value --[[@as { percentage?: number, title?: string, message?: string, kind: "begin"|"report"|"end" }]]
	if not client or type(value) ~= "table" then
		return
	end

	local p = progress[client.id]
	for i = 1, #p + 1 do
		if i == #p + 1 or p[i].token == ev.data.params.token then
			p[i] = {
				token = ev.data.params.token,
				msg = ("[%3d%%] %s%s"):format(
					value.kind == "end" and 100 or value.percentage or 100,
					value.title or "",
					value.message and (" **%s**"):format(value.message) or ""
				),
				done = value.kind == "end",
			}
			break
		end
	end

	local msg = {}
	progress[client.id] = vim.tbl_filter(function(v)
		return table.insert(msg, v.msg) or not v.done
	end, p)

	vim.notify(table.concat(msg, "\n"), vim.log.levels.INFO, {
		id = "lsp_progress",
		title = client.name,
		opts = function(notif)
			notif.icon = #progress[client.id] == 0 and " "
				or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
		end,
	})
end

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

	-- [[ Keymaps ]]
	-- grn/gra/grr/gri/grt/grx/gO are Nvim 0.13 default global mappings and
	-- are intentionally not redefined here (longest-match resolution means
	-- mini.jump's standalone f/t maps never intercept the gr* sequences).

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
	-- Note: <leader>cl and grx (run lens) are mapped globally elsewhere.
	if client:supports_method("textDocument/codeLens") then
		vim.lsp.codelens.enable(true, { bufnr = args.buf })
	end
end

-- [[ Autocmd Definitions ]]
-- Exported to the registrar for automatic setup.
M.setup = {
	{
		event = "LspAttach",
		pattern = "*",
		action = lsp_attach,
		desc = "Initialize LSP features on attach",
	},
	{
		event = "LspProgress",
		pattern = "*",
		action = lsp_progress,
		desc = "Show LSP progress notifications",
	},
}

return M
