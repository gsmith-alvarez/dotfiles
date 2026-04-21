-- [[ PLUGIN MANAGEMENT DOMAIN: lua/commands/pack.lua ]]
-- =============================================================================

local M = {}

-- Use Snacks for notifications if available, fallback to native
local function notify(msg, level, opts)
	local snacks = Config.safe_require("snacks")
	if snacks then
		snacks.notify(msg, vim.tbl_extend("force", { level = level }, opts or {}))
	else
		vim.notify(msg, level, opts)
	end
end

M.setup = {
	PackUpdate = {
		options = { desc = "Update all vim.pack plugins" },
		impl = function()
			vim.pack.update()
		end,
	},
	PackRestore = {
		options = { desc = "Revert all plugins to the exact state in the lockfile" },
		impl = function()
			vim.pack.update(nil, { offline = true, target = "lockfile" })
		end,
	},
	PackStatus = {
		options = { desc = "Print a summary of active and inactive plugins" },
		impl = function()
			local plugins = vim.pack.get(nil, { info = true })
			local loaded, added, inactive = {}, {}, {}
			local rtp_paths = vim.api.nvim_list_runtime_paths()
			local rtp_lookup = {}
			for _, p in ipairs(rtp_paths) do
				rtp_lookup[p:gsub("/$", "")] = true
			end

			for _, data in pairs(plugins) do
				local plugin_name = data.name
					or (data.spec and data.spec.name)
					or vim.fn.fnamemodify(data.path, ":t")
					or "unknown"
				local intent = (data.spec and data.spec.version) and data.spec.version or "main"
				local hash = data.rev and data.rev:sub(1, 7) or "unknown"
				local line = string.format("  - %-25s | %-8s | %s", plugin_name, intent, hash)
				local plugin_path = data.path:gsub("/$", "")
				if rtp_lookup[plugin_path] then
					table.insert(loaded, line)
				elseif data.active then
					table.insert(added, line)
				else
					table.insert(inactive, line)
				end
			end

			table.sort(loaded)
			table.sort(added)
			table.sort(inactive)

			local msg = {
				"vim.pack Status Report",
				"-----------------------------------",
				string.format("[ LOADED: %d ]", #loaded),
			}
			for _, l in ipairs(loaded) do
				table.insert(msg, l)
			end
			if #added > 0 then
				table.insert(msg, "")
				table.insert(msg, string.format("[ LAZY: %d ]", #added))
				for _, l in ipairs(added) do
					table.insert(msg, l)
				end
			end
			table.insert(msg, "")
			table.insert(msg, string.format("[ INACTIVE: %d ]", #inactive))
			for _, l in ipairs(inactive) do
				table.insert(msg, l)
			end

			notify(table.concat(msg, "\n"), vim.log.levels.INFO, { title = "Pack Status" })
		end,
	},
	PackCleanLock = {
		options = { desc = "Delete the pack lockfile" },
		impl = function()
			local lockfile_path = vim.fn.stdpath "config" .. "/nvim-pack-lock.json"
			if vim.fn.filereadable(lockfile_path) == 1 then
				if vim.fn.delete(lockfile_path) == 0 then
					notify(
						"Deleted lockfile. Restart Neovim to rebuild.",
						vim.log.levels.WARN,
						{ title = "Pack Status" }
					)
				else
					notify("Failed to delete lockfile.", vim.log.levels.ERROR, { title = "Pack Status" })
				end
			else
				notify("No lockfile found.", vim.log.levels.INFO, { title = "Pack Status" })
			end
		end,
	},
	PackPurge = {
		options = { desc = "Interactively select and delete inactive plugins" },
		impl = function()
			local inactive_plugins = vim.iter(vim.pack.get())
				:filter(function(x)
					return not x.active
				end)
				:map(function(x)
					return x.spec and x.spec.name or vim.fn.fnamemodify(x.path, ":t")
				end)
				:totable()

			if #inactive_plugins == 0 then
				notify("No inactive plugins found to clean up.", vim.log.levels.INFO, { title = "Plugin Purge" })
				return
			end

			table.sort(inactive_plugins)

			-- Reuse existing purge buffer if already open
			local buf_name = "Plugin_Purge_List"
			local existing = vim.fn.bufnr(buf_name)
			if existing ~= -1 then
				vim.api.nvim_buf_delete(existing, { force = true })
			end

			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(buf, buf_name)

			local lines = {
				"# --- INTERACTIVE PLUGIN PURGE ---",
				"# Leave the plugins you WANT TO DELETE.",
				"# Delete the lines of plugins you want to keep.",
				"# Run :w to execute the deletion.",
				"# Press 'q' to cancel and close.",
				"# --------------------------------",
			}
			for _, name in ipairs(inactive_plugins) do
				table.insert(lines, name)
			end
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

			vim.bo[buf].filetype = "plugin_purge"
			vim.bo[buf].buftype = "acwrite"
			vim.bo[buf].modified = false

			vim.cmd "vsplit"
			vim.api.nvim_win_set_buf(0, buf)

			local function close()
				vim.bo[buf].modified = false
				vim.cmd "close"
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end

			vim.keymap.set("n", "q", close, { buffer = buf, silent = true, desc = "Cancel plugin purge" })

			vim.api.nvim_create_autocmd("BufWriteCmd", {
				buffer = buf,
				callback = function()
					local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local to_delete = {}
					for _, line in ipairs(current_lines) do
						if line ~= "" and not line:match "^#" then
							table.insert(to_delete, line)
						end
					end

					if #to_delete > 0 then
						local ok, err = pcall(vim.pack.del, to_delete)
						if ok then
							notify(
								"Successfully deleted " .. #to_delete .. " plugins from disk.",
								vim.log.levels.INFO,
								{ title = "Plugin Purge" }
							)
						else
							notify("Error deleting plugins: " .. tostring(err), vim.log.levels.ERROR, { title = "Plugin Purge" })
						end
					else
						notify("Operation aborted: No plugins selected.", vim.log.levels.WARN, { title = "Plugin Purge" })
					end

					close()
				end,
			})
		end,
	},
}

return M
