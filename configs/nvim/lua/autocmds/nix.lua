-- nix.lua: async linting with deadnix and statix for Nix files

local M = {}

local deadnix_ns = vim.api.nvim_create_namespace("deadnix")
local statix_ns = vim.api.nvim_create_namespace("statix")

local function run_nix_linters(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local file_path = vim.api.nvim_buf_get_name(buf)
	if file_path == "" or not file_path:match("%.nix$") then
		return
	end

	-- Deadnix: scan for dead code / unused bindings
	if vim.fn.executable("deadnix") == 1 then
		vim.system({ "deadnix", "-o", "json", file_path }, { text = true }, function(out)
			local diagnostics = {}
			if (out.code == 0 or out.code == 1) and out.stdout and out.stdout ~= "" then
				local ok, data = pcall(vim.json.decode, out.stdout)
				if ok and data and data.results then
					for _, item in ipairs(data.results) do
						table.insert(diagnostics, {
							bufnr = buf,
							lnum = math.max(0, (item.line or 1) - 1),
							col = math.max(0, (item.column or 1) - 1),
							end_lnum = math.max(0, (item.line or 1) - 1),
							end_col = math.max(0, (item.endColumn or item.column or 1) - 1),
							severity = vim.diagnostic.severity.WARN,
							message = item.message or "Unused binding",
							source = "deadnix",
						})
					end
				end
			end
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.diagnostic.set(deadnix_ns, buf, diagnostics)
				end
			end)
		end)
	end

	-- Statix: scan for anti-patterns and lint suggestions
	if vim.fn.executable("statix") == 1 then
		vim.system({ "statix", "check", "-o", "json", file_path }, { text = true }, function(out)
			local diagnostics = {}
			if (out.code == 0 or out.code == 1) and out.stdout and out.stdout ~= "" then
				for line in out.stdout:gmatch("[^\r\n]+") do
					local ok, data = pcall(vim.json.decode, line)
					if ok and data and data.report then
						for _, r in ipairs(data.report) do
							local note = r.note or "Statix warning"
							if r.diagnostics then
								for _, d in ipairs(r.diagnostics) do
									local at = d.at and d.at.from
									if at then
										table.insert(diagnostics, {
											bufnr = buf,
											lnum = math.max(0, (at.line or 1) - 1),
											col = math.max(0, (at.column or 1) - 1),
											severity = vim.diagnostic.severity.WARN,
											message = note .. (d.message and (": " .. d.message) or ""),
											source = "statix",
										})
									end
								end
							end
						end
					end
				end
			end
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.diagnostic.set(statix_ns, buf, diagnostics)
				end
			end)
		end)
	end
end

M.setup = {
	{
		event = { "BufReadPost", "BufWritePost" },
		pattern = "*.nix",
		action = function(args)
			run_nix_linters(args.buf)
		end,
		desc = "Run deadnix and statix linters on Nix files",
	},
}

return M
