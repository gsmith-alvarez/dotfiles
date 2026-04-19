-- [[ PLUGIN MANAGEMENT DOMAIN: lua/commands/pack.lua ]]
-- =============================================================================
-- Purpose: Interface for the native 'vim.pack' plugin manager.
-- Domain:  Package Management & Lifecycle
--
-- Philosophy: "Keep the core minimal, manage the extensions effectively."
--             This module provides high-level commands for synchronizing,
--             auditing, and cleaning up plugins managed by the pack system.
-- =============================================================================

local M = {}

M.setup = {
	-- [[ PackUpdate: Plugin Synchronization ]]
	-- Synchronizes all plugins with the remote source.
	PackUpdate = {
		options = { desc = 'Update all vim.pack plugins' },
		impl = function()
			-- Pass nil to update ALL registered plugins (empty table {} updates nothing)
			vim.pack.update()
		end,
	},

	-- [[ PackRestore: Lockfile Recovery ]]
	-- Forces plugins back to the exact version defined in the lockfile.
	PackRestore = {
		options = { desc = 'Revert all plugins to the exact state in the lockfile' },
		impl = function()
			-- Pass nil to target ALL plugins. offline=true prevents fetching. target='lockfile' forces rollback.
			vim.pack.update(nil, { offline = true, target = 'lockfile' })
		end,
	},

	-- [[ PackStatus: Plugin Audit ]]
	-- Generates a detailed report of what is currently loaded, lazy-loaded, or inactive.
	PackStatus = {
		options = { desc = 'Print a summary of active and inactive plugins' },
		impl = function()
			local plugins = vim.pack.get(nil, { info = true })
			local loaded, added, inactive = {}, {}, {}

			-- Cache current runtime paths for fast lookup
			local rtp_paths = vim.api.nvim_list_runtime_paths()
			local rtp_lookup = {}
			for _, p in ipairs(rtp_paths) do
				-- Normalize paths to ensure accurate matching
				rtp_lookup[p:gsub('/$', '')] = true
			end

			for _, data in pairs(plugins) do
				local plugin_name = data.name
					or (data.spec and data.spec.name)
					or vim.fn.fnamemodify(data.path, ':t')
					or 'unknown'
				local intent = (data.spec and data.spec.version) and data.spec.version or 'main'
				local hash = data.rev and data.rev:sub(1, 7) or 'unknown'

				local line = string.format('  - %-25s | %-8s | %s', plugin_name, intent, hash)

				local plugin_path = data.path:gsub('/$', '')
				local is_loaded = rtp_lookup[plugin_path]

				if is_loaded then
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
				'vim.pack Status & Version Report',
				'-----------------------------------',
				string.format('[ LOADED IN MEMORY: %d ]', #loaded),
			}

			for _, line in ipairs(loaded) do
				table.insert(msg, line)
			end

			-- Only show this section if you actually have lazy-loaded plugins
			if #added > 0 then
				table.insert(msg, '')
				table.insert(msg, string.format('[ ADDED BUT DEFERRED/LAZY: %d ]', #added))
				for _, line in ipairs(added) do
					table.insert(msg, line)
				end
			end

			table.insert(msg, '')
			table.insert(msg, string.format('[ INACTIVE ON DISK: %d ] (Run :PackPurge to clean)', #inactive))

			for _, line in ipairs(inactive) do
				table.insert(msg, line)
			end

			vim.notify(table.concat(msg, '\n'), vim.log.levels.INFO, { title = 'Pack Status' })
		end,
	},

	-- [[ PackCleanLock: Lockfile Reset ]]
	-- Safety valve for when the lockfile becomes corrupted or out of sync.
	PackCleanLock = {
		options = { desc = 'Delete the pack lockfile to fix corruption/sync issues' },
		impl = function()
			local lockfile_path = vim.fn.stdpath('config') .. '/nvim-pack-lock.json'

			if vim.fn.filereadable(lockfile_path) == 1 then
				local success = vim.fn.delete(lockfile_path)
				if success == 0 then
					vim.notify(
						'Deleted lockfile. Restart Neovim to rebuild it cleanly.',
						vim.log.levels.WARN,
						{ title = 'Pack Status' }
					)
				else
					vim.notify(
						'Failed to delete lockfile. Check file permissions.',
						vim.log.levels.ERROR,
						{ title = 'Pack Status' }
					)
				end
			else
				vim.notify('No lockfile found at ' .. lockfile_path, vim.log.levels.INFO, { title = 'Pack Status' })
			end
		end,
	},

	-- [[ PackPurge: Interactive Inactive Plugin Cleanup ]]
	-- Opens a temporary buffer to review and delete orphaned plugin directories.
	PackPurge = {
		options = { desc = 'Interactively select and delete inactive plugins' },
		impl = function()
			-- 1. Get all inactive plugins
			local inactive_plugins = vim
				.iter(vim.pack.get())
				:filter(function(x)
					return not x.active
				end)
				:map(function(x)
					return x.spec.name
				end)
				:totable()

			if #inactive_plugins == 0 then
				vim.notify('No inactive plugins found to clean up.', vim.log.levels.INFO, { title = 'Plugin Purge' })
				return
			end

			-- 2. Create the interactive buffer
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(buf, 'Plugin_Purge_List')

			-- 3. Add instructions and the plugin list to the buffer
			local lines = {
				'# --- INTERACTIVE PLUGIN PURGE ---',
				'# Leave the plugins you WANT TO DELETE.',
				'# Delete the lines of plugins you want to keep.',
				'# Run :w to execute the deletion.',
				"# Press 'q' to cancel and close.",
				'# --------------------------------',
			}
			for _, name in ipairs(inactive_plugins) do
				table.insert(lines, name)
			end
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

			-- 4. Configure buffer settings
			vim.bo[buf].filetype = 'plugin_purge'
			vim.bo[buf].buftype = 'acwrite' -- Tells Neovim to let us handle the :w command
			vim.bo[buf].modified = false

			-- 5. Open in a vertical split
			vim.cmd('vsplit')
			vim.api.nvim_win_set_buf(0, buf)

			-- 6. Add a quick-cancel keymap ('q' to abort)
			vim.keymap.set('n', 'q', '<cmd>bwipeout!<CR>', { buffer = buf, silent = true, desc = 'Cancel plugin purge' })

			-- 7. Intercept the :w command to execute the deletion
			vim.api.nvim_create_autocmd('BufWriteCmd', {
				buffer = buf,
				callback = function()
					local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					local to_delete = {}

					-- Parse the buffer, ignoring our instructional header comments
					for _, line in ipairs(current_lines) do
						if line ~= '' and not line:match('^#') then
							table.insert(to_delete, line)
						end
					end

					if #to_delete > 0 then
						local ok, err = pcall(vim.pack.del, to_delete)
						if ok then
							vim.notify(
								'Successfully deleted ' .. #to_delete .. ' plugins from disk.',
								vim.log.levels.INFO,
								{ title = 'Plugin Purge' }
							)
						else
							vim.notify(
								'Error deleting plugins: ' .. tostring(err),
								vim.log.levels.ERROR,
								{ title = 'Plugin Purge' }
							)
						end
					else
						vim.notify('Operation aborted: No plugins selected.', vim.log.levels.WARN, { title = 'Plugin Purge' })
					end

					-- Clean up the buffer and close the window
					vim.bo[buf].modified = false
					vim.cmd('bwipeout!')
				end,
			})
		end,
	},
}

return M
