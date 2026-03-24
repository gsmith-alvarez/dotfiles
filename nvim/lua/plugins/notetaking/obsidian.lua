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
	local has_rg = require('core.utils').mise_shim('rg')
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

		picker = { name = "snacks" },

		-- Matches your descriptive filename preference (No Zettelkasten IDs)
		note_id_func = function(_, title)
		  if title ~= nil then return title end
			return tostring(os.time())
		end,

		attachments = { folder = "attachments" },

		-- ========================================================================
		-- AUTOMATED FRONTMATTER (MOC-Oriented)
		-- ========================================================================
		frontmatter = {
		  func = function(_, note)
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

		-- ========================================================================
		-- CALLBACKS: Buffer-local keymaps (mappings option removed in 4.0)
		-- ========================================================================
		callbacks = {
		  enter_note = function(_, note)
		    local map = vim.keymap.set				local function buf(desc) return { buffer = true, desc = desc } end

				local function follow(strategy)
					local api = require "obsidian.api"
					vim.lsp.buf.definition {
						on_list = function(t)
							if #t.items >= 1 then
								if strategy == "tab" then
									vim.cmd("tabedit " ..
									vim.fn.fnameescape(t.items[1].filename))
								else
									api.open_note(t.items[1],
										api.get_open_strategy(strategy))
								end
							end
						end
					}
				end

				vim.keymap.set("n", "<leader>na", function()
					local obs = require("obsidian.api")
					local link = obs.cursor_link()
					local tag = obs.cursor_tag()
					local check = obs.cursor_checkbox()
					local head = obs.cursor_heading()
					if link then
						vim.cmd("Obsidian follow_link")
					elseif tag then
						vim.cmd("Obsidian tags")
					elseif check then
						vim.cmd("Obsidian toggle_checkbox")
					elseif head then
						vim.cmd("normal! za")
					else
						vim.notify("Not on a link, tag, checkbox, or heading",
							vim.log.levels.INFO)
					end
				end, { buffer = true, desc = "Obsidian: Smart Action" })
				map("n", "<leader>nf", function() follow("tab") end,
					buf("Obsidian: Follow Link (New Tab)"))
				map("n", "<leader>nv", function() follow("vsplit") end,
					buf("Obsidian: Follow Link (V-Split)"))
				map("n", "<leader>nh", function() follow("hsplit") end,
					buf("Obsidian: Follow Link (H-Split)"))

				-- Remove obsidian's default <CR> (smart_action) and give it to mini.jump2d
				vim.keymap.del("n", "<CR>", { buffer = true })
				map("n", "<CR>", function()
					require('mini.jump2d').start(require('mini.jump2d').builtin_opts.word_start)
				end, buf("Jump2d: jump to word"))
				map("n", "<leader>nT", function() vim.cmd("Obsidian tags") end,
					buf("Obsidian: Search [T]ags"))
				map("n", "<leader>no", function() vim.cmd("Obsidian open") end,
					buf("Obsidian: [O]pen in GUI"))
				map("n", "<leader>nc", function() vim.cmd("Obsidian toc") end,
					buf("Obsidian: [C]ontents (TOC)"))

				-- 2. Note Creation & Templates
				map("n", "<leader>nt", function() vim.cmd("Obsidian template") end,
					buf("Obsidian: Insert [T]emplate"))
				map("n", "<leader>ne", function() vim.cmd("Obsidian extract_note") end,
					buf("Obsidian: [E]xtract to Note"))
				map("n", "<leader>nl", function() vim.cmd("Obsidian link") end,
					buf("Obsidian: [L]ink Existing Note"))
				map("n", "<leader>nN", function() vim.cmd("Obsidian link_new") end,
					buf("Obsidian: Link [N]ew Note"))

				-- 3. Media & Attachments
				map("n", "<leader>np", function() vim.cmd("Obsidian paste_img") end,
					buf("Obsidian: [P]aste Image"))
			end,
		},

	})
end

return M
