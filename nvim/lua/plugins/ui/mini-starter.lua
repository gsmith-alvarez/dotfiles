-- [[ MINI.STARTER: Interactive Dashboard ]]
-- Purpose: Provide a high-speed, project-aware landing page for Neovim.
-- Domain:  UI / Onboarding
-- Architecture: Conditional Phased Boot (argc-dependent)
--
-- PHILOSOPHY: Minimalist Gateway
-- The starter provides a high-speed entry point for common tasks. In our
-- "Phased Boot" strategy, it only initializes if Neovim is opened without
-- file arguments. This keeps CLI-pipe usage (`cat file | nvim -`) lean.
--
-- WHY: By using `MiniDeps.add` inside the `setup` function, we ensure that
-- headless or server-side instances of Neovim never even download the
-- dashboard code.
--
-- MAINTENANCE TIPS:
-- 1. To add a new project shortcut, update the `paths` table.
-- 2. If the dashboard doesn't appear, check if you passed an argument to `nvim`.
-- 3. Header quotes are managed by the asynchronous `quotes.lua` engine.

local M = {}

M.setup = function()
	if vim.fn.argc() ~= 0 then return end

	require('mini.deps').add 'echasnovski/mini.starter'
	local starter = require 'mini.starter'
	local quotes_engine = require 'plugins.ui.quotes'
	local paths = {
		projects = vim.fn.expand '~/Documents/Projects',
		obsidian = vim.fn.expand '~/Documents/Obsidian',
		dotfiles = vim.fn.expand '~/dotfiles',
		code = vim.fn.expand '~/code',
	}

	local function snacks_action(cwd)
		return function()
			require('snacks').picker.files({ cwd = cwd })
		end
	end

	-- [[ FOOTER: dynamic system context ]]
	local function build_footer()
		local parts = {}

		-- Neovim version
		local v = vim.version()
		table.insert(parts, string.format('󰇅  v%d.%d.%d', v.major, v.minor, v.patch))

		-- Plugin count (mini.deps managed)
		local ok, deps = pcall(require, 'mini.deps')
		if ok then
			local snap = deps.get_session_data and deps.get_session_data() or nil
			local count = snap and #vim.tbl_keys(snap.plugins or {}) or nil
			if count then
				table.insert(parts, string.format('󰏗  %d plugins', count))
			end
		end

		-- Git branch of cwd (if any)
		local branch = vim.fn.system('git -C ' .. vim.fn.getcwd() .. ' rev-parse --abbrev-ref HEAD 2>/dev/null')
		    :gsub('%s+$', '')
		if branch ~= '' and not branch:find('fatal') then
			table.insert(parts, ' ' .. branch)
		end

		-- Lazy startup time (if profiler recorded it)
		local startuptime = vim.g.loaded_startuptime
		if startuptime then
			table.insert(parts, string.format('⚡ %.0fms', startuptime))
		end

		local info_line = table.concat(parts, '   ')
		return info_line .. '\n\n' .. 'Type highlighted letter to jump  ·  q to quit'
	end

	local function wrap_quote(text, max_width)
		max_width = max_width or 60
		local lines = {}
		-- Split on the attribution suffix (" - Author" at end of last line)
		local quote, attr = text:match('^(.*)" %- (.+)$')
		local body = quote and (quote .. '"') or text

		for _, paragraph in ipairs(vim.split(body, '\n')) do
			local line = ''
			for word in paragraph:gmatch('%S+') do
				local candidate = line == '' and word or line .. ' ' .. word
				if #candidate > max_width then
					if line ~= '' then table.insert(lines, line) end
					line = word
				else
					line = candidate
				end
			end
			if line ~= '' then table.insert(lines, line) end
		end

		if attr then table.insert(lines, '  ─  ' .. attr) end
		return table.concat(lines, '\n')
	end

	-- Short path: show …/parent/filename instead of full path
	local function short_path(path)
		local home = vim.fn.expand('~')
		path = path:gsub('^' .. home, '~')
		local parts = vim.split(path, '/', { plain = true })
		if #parts <= 3 then return path end
		return '\226\128\166/' .. parts[#parts - 1] .. '/' .. parts[#parts]
	end

	-- Items with icons baked into the name for visual richness
	local my_items = {
		vim.fn.isdirectory(paths.projects) == 1
		and { name = 'Projects 󰉖 ', action = snacks_action(paths.projects), section = '  Workspaces' }
		or nil,
		vim.fn.isdirectory(paths.code) == 1
		and { name = 'Code  ', action = snacks_action(paths.code), section = '  Workspaces' }
		or nil,
		vim.fn.isdirectory(paths.dotfiles) == 1
		and { name = 'dotfiles 󰄻 ', action = snacks_action(paths.dotfiles), section = '  Workspaces' }
		or nil,
		vim.fn.isdirectory(paths.obsidian) == 1
		and { name = 'Obsidian 󰌱 ', action = snacks_action(paths.obsidian), section = '  Workspaces' }
		or nil,
		{ name = 'New file 󰈤 ', action = 'ene | startinsert', section = '  Actions' },
		{ name = 'Quit     󰈆', action = 'qall', section = '  Actions' },
		starter.sections.recent_files(5, false, short_path),
		starter.sections.recent_files(3, true, short_path),
		starter.sections.sessions(5, true),
	}

	starter.setup {
		evaluate_single = true,
		items = vim.tbl_filter(function(x) return x ~= nil end, my_items),
		header = function()
			local v = vim.version()
			local logo = string.format([[
┌─────────────────────────────────────────┐
│                                         │
│   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗  │
│   ████╗  ██║██╔════╝██╔═══██╗██║   ██║  │
│   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║  │
│   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝  │
│   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝   │
│   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝    │
│                                         │
│             v%d.%d.%d                     │
└─────────────────────────────────────────┘]], v.major, v.minor, v.patch)
			return logo .. '\n\n' .. wrap_quote(quotes_engine.get_cached_quote())
		end,
		footer = build_footer,
		content_hooks = {
			starter.gen_hook.adding_bullet '  ',
			starter.gen_hook.aligning('center', 'center'),
			starter.gen_hook.padding(3, 1),
		},
	}

	vim.api.nvim_set_hl(0, 'MiniStarterHeader', { fg = '#89b4fa' })
	vim.api.nvim_set_hl(0, 'MiniStarterSection', { fg = '#cba6f7', bold = true })
	vim.api.nvim_set_hl(0, 'MiniStarterItem', { fg = '#cdd6f4' })
	vim.api.nvim_set_hl(0, 'MiniStarterItemBullet', { fg = '#313244' })
	vim.api.nvim_set_hl(0, 'MiniStarterItemPrefix', { fg = '#f38ba8', bold = true })
	vim.api.nvim_set_hl(0, 'MiniStarterFooter', { fg = '#6c7086', italic = true })

	local starter_group = vim.api.nvim_create_augroup('UI_Starter', { clear = true })
	vim.api.nvim_create_autocmd('User', {
		group = starter_group,
		pattern = 'MiniStarterOpened',
		callback = function(ev)
			vim.bo.buftype = 'nofile'
			vim.bo.bufhidden = 'wipe'
			vim.bo.modifiable = false
			vim.keymap.set('n', 'q', '<cmd>quit<CR>', { buffer = true, silent = true })
			-- mini.clue intercepts g/z globally; disable it for the starter buffer
			-- so those keys pass through to mini.starter's query handler
			vim.b[ev.buf].miniclue_disable = true
		end,
	})
end

return M
