vim.opt_local.formatoptions:append({ "r", "o" })

-- Ask ty for native workspace diagnostics when a Python buffer opens or changes.
local group = vim.api.nvim_create_augroup("python_workspace_diagnostics_" .. vim.api.nvim_get_current_buf(), {
	clear = true,
})

local function request_workspace_diagnostics()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "ty" })) do
		if client:supports_method("workspace/diagnostic") then
			vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
			return
		end
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	buffer = 0,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "ty" then
			vim.schedule(request_workspace_diagnostics)
		end
	end,
	desc = "Request ty workspace diagnostics",
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	callback = request_workspace_diagnostics,
	desc = "Refresh ty workspace diagnostics",
})

request_workspace_diagnostics()
