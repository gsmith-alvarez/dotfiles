-- [[ SNACKS.NVIM: The Centralized Pillar ]]
-- Domain: Workflow, UI, Navigation, and Profiling
--
-- PHILOSOPHY: Extreme JIT Configuration
-- To achieve a sub-15ms startup, we defer the entire snacks.setup call.
-- Most Snacks modules are already lazy, but the setup() call itself 
-- performs table merges and logic that we can push out of the hot path.

local M = {}
local utils = require 'core.utils'

-- Internal flag to prevent double-setup
local snacks_configured = false

--- Bootstraps the Snacks configuration only when needed.
--- Why: This avoids the ~7ms setup cost during the initial render.
M.bootstrap = function()
	if snacks_configured then return end
	
	local ok, err = pcall(function()
		require('snacks').setup {
			-- 1. UI: Immediate Message Interception
			notifier = {
				enabled = true,
				timeout = 3000,
				top_down = false,
				level = vim.log.levels.INFO,
			},

			-- 2. PROFILING
			profiler = { enabled = vim.env.PROFILE ~= nil },

			-- 3. WORKFLOW
			terminal = {
				win = { border = 'rounded', winblend = 3, keys = { q = 'hide' } },
			},

			-- 4. NAVIGATION
			picker = {
				enabled = true,
				ui_select = true,
				sources = {
					files = {
						hidden = true,
						ignored = true,
						exclude = { ".git", ".pio", "node_modules", "build" },
					},
				},
				win = {
					input = {
						keys = {
							["<C-j>"] = { "list_down", mode = { "i", "n" } },
							["<C-k>"] = { "list_up",   mode = { "i", "n" } },
						},
					},
				},
			},

			progress = { enabled = true },

			-- 5. EXPLICIT OPT-OUT
			dashboard = { enabled = false },
			indent = { enabled = false },
			input = { enabled = false },
			scope = { enabled = false },
			scroll = { enabled = true },
			words = { enabled = false },
			statuscolumn = { enabled = false },
			lazygit = { enabled = true },
		}
	end)

	if ok then
		snacks_configured = true
	else
		utils.soft_notify('Snacks.nvim JIT setup failed: ' .. err, vim.log.levels.ERROR)
	end
end

M.setup = function()
	-- We no longer call setup() here. 
	-- Instead, we wait for either a keymap trigger OR the first idle loop.
	
	-- Fallback: Load after boot is complete so background features (like notifications)
	-- eventually initialize without blocking the initial render.
	vim.api.nvim_create_autocmd('VimEnter', {
		group = vim.api.nvim_create_augroup('SnacksJIT', { clear = true }),
		callback = function()
			-- We defer by 1ms to ensure we are completely out of the startup path.
			vim.defer_fn(M.bootstrap, 1)
		end,
	})
end

return M
