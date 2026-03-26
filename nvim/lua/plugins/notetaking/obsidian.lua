-- [[ OBSIDIAN: Knowledge Graph & Zettelkasten ]]
-- Domain: Notetaking / Personal Knowledge Management
-- Location: lua/plugins/notetaking/obsidian.lua
--
-- PHILOSOPHY: The Second Brain (JIT)
-- We treat notes as a high-latency domain. You don't need Obsidian features
-- while coding Rust. This module is completely dormant until you enter your
-- vault or explicitly invoke a note command. This "Phased Boot" approach
-- ensures the editor stays lean during technical work.
--
-- MAINTENANCE TIPS:
-- 1. If searching fails, ensure `ripgrep` (rg) is in your PATH (managed by Mise).
-- 2. Vault path is hardcoded to `~/Documents/Obsidian`.
-- 3. Templates are located in `500-Resources/Templates` within the vault.
--
-- ARCHITECTURE: Protected JIT Initialization
-- This module is required by `lua/autocmd/jit.lua`. It provides a `setup()` 
-- function that performs dependency checks before loading the heavy plugin.

local M = {}

function M.setup()
	-- 1. Anti-Fragility & Graceful Degradation Check
	local has_rg = vim.fn.executable('rg') == 1
	if not has_rg then
		vim.notify("Obsidian.nvim: 'rg' binary missing. Check mise configuration.", vim.log.levels.WARN)
		return
	end

	-- 2. Imperative Dependency Fetch via mini.deps
	require('mini.deps').add({
		source = 'obsidian-nvim/obsidian.nvim',
		depends = { 'nvim-lua/plenary.nvim' }
	})

	-- 3. Execute the Setup Logic
	require("obsidian").setup({
		ui = { enable = false },
		legacy_commands = false,

		-- MANDATORY: Must be the root to access both 201-University and 500-Resources
		workspaces = {
			{
				name = "vault",
				path = "~/Documents/Obsidian",
			},
		},

		picker = { name = "snacks.pick" },

		-- Matches your descriptive filename preference (No Zettelkasten IDs)
		note_id_func = function(title)
			local note_title
			if type(title) == "table" and title.title ~= nil then
				note_title = title.title
			elseif title ~= nil then
				note_title = title
			end

			if note_title ~= nil then
				return note_title
			end

			return tostring(os.time())
		end,

		attachments = { folder = "attachments" },

		-- ========================================================================
		-- AUTOMATED FRONTMATTER (MOC-Oriented)
		-- ========================================================================
		frontmatter = {
			func = function(note)
				-- Guard against nil note (can happen with templates)
				if not note then
					return {
						tags = {},
						created = os.date("%Y-%m-%d %H:%M"),
					}
				end

				local out = {
					id = note.id,
					aliases = note.aliases,
					tags = note.tags,
					created = os.date("%Y-%m-%d %H:%M"),
				}

				if not out.tags then out.tags = {} end

				-- Auto-tag MOCs for pattern recognition
				if note.title and string.match(string.lower(note.title), "moc") then
					table.insert(out.tags, "MOC")
				end

				return out
			end,
		},

		-- ========================================================================
		-- TEMPLATE CONFIGURATION
		-- ========================================================================
		templates = {
			-- Path is relative to the workspace path defined above
			folder = "500-Resources/Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			-- Allow overriding existing variables in the note
			substitutions = {},
		},

	})
	
	-- NOTE: Buffer-local keymaps are now registered in lua/autocmd/jit.lua
	-- using a User autocmd for ObsidianNoteEnter. This ensures they're
	-- available when the JIT loader triggers.
end

return M
