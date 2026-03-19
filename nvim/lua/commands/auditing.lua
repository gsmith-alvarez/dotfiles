-- [[ AUDITING & REDIRECTION DOMAIN ]]

local M = {}

-- [[ Dependency Auditing: :ToolCheck ]]
-- A custom command to scan for all required external tools and LSPs.
-- This prevents the "silent failure" state where an LSP is configured but
-- the binary is missing from the system PATH.
vim.api.nvim_create_user_command('ToolCheck', function()
	local utils = require('core.utils')
	local tools = {
		-- LSPs (Core intelligence)
		'pyright-langserver',
		'ruff',
		'rust-analyzer',
		'bash-language-server',
		'vscode-json-languageserver',
		'yaml-language-server',
		'taplo',
		'lua-language-server',
		'markdown-oxide',
		'gopls',
		'zls',
		'typescript-language-server',
		'clangd',
		'tinymist',
		'dockerfile-language-server-nodejs',

		-- Formatters & Linters (Quality control)
		'stylua',
		'oxfmt',
		'oxlint',
		'shfmt',
		'typstyle',
		'yamllint',
		'markdownlint-cli2',
		'shellcheck',
		'typos',

		-- Performance & Search (Native core)
		'rg',
		'fd',
		'sd',
		'gojq',
		'xh',
		'btm',

		-- System & Build (Foundational)
		'make',
		'gcc',
		'lazygit',
		'dlv',
		'watchexec',
		'uv',
		'zig',
		'zellij',
		'ouch',
	}

	local missing, found = {}, {}

	for _, tool in ipairs(tools) do
		-- We leverage the utils.lua logic to check both mise shims and the system PATH.
		local path = utils.mise_shim(tool)
		if path then
			table.insert(found, tool)
		else
			table.insert(missing, tool)
		end
	end

	-- UI STATE MANAGEMENT: Creating an ephemeral buffer.
	-- false = not listed in :ls (hidden), true = acts as a scratchpad.
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = 'markdown'
	vim.bo[buf].bufhidden = 'wipe'

	local lines = { '# Dependency Audit Results', '' }

	if #missing == 0 then
		table.insert(lines, '✅ All tools are correctly installed and available!')
	else
		table.insert(lines, '❌ Missing dependencies found!')
		table.insert(lines, '')
		table.insert(lines, '## Missing Tools')
		for _, tool in ipairs(missing) do
			table.insert(lines, '- ' .. tool)
		end
		table.insert(lines, '')
		table.insert(lines, '## Recommended Fix')
		table.insert(lines, 'You can install missing tools globally with mise by running the following commands:')
		table.insert(lines, '```bash')
		for _, tool in ipairs(missing) do
			table.insert(lines, 'mise install -g ' .. tool)
		end
		table.insert(lines, '```')
		table.insert(lines,
			'*(For true system dependencies like `make`, `gcc`, use your system package manager if mise cannot install them)*')
	end

	table.insert(lines, '')
	table.insert(lines, '## Found Tools')
	for _, tool in ipairs(found) do
		table.insert(lines, '- ' .. tool .. ' ✅')
	end

	-- Inject the compiled lines array into the buffer memory
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Window Management: Open a vertical split and assign our new buffer to it.
	vim.cmd('vsplit')
	vim.api.nvim_win_set_buf(0, buf)
	-- Lock the buffer so the user doesn't accidentally type in the report
	vim.bo[buf].modifiable = false
end, { desc = 'Audit required dependencies and suggest installation steps' })

-- Keymaps moved to lua/core/plugin-keymaps.lua under Utilities (<leader>u) section.
-- Keymaps moved to lua/core/plugin-keymaps.lua.

-- [[ Output Capture Engine ]]
-- Intercepts the output of any internal Neovim ex-command (like :messages or :hi)
-- and dumps it into an ephemeral buffer so you can search/filter it with normal Vim motions.
vim.api.nvim_create_user_command('Redir', function(ctx)
	local output = vim.fn.execute(ctx.args)
	vim.cmd('vnew')
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe'
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
end, { nargs = '+', complete = 'command', desc = 'Redirect command output to buffer' })

-- [[ Typos-CLI to Quickfix Pipeline ]]
-- A heavy-duty, project-wide spellchecker.
-- Instead of rendering wavy underlines inline via LSP (which is visually noisy),
-- we run this as a batch process, decode the JSON output, and build an interactive
-- Quickfix list of every typo in the repository.
vim.api.nvim_create_user_command('Typos', function()
	local utils = require('core.utils')
	local typos = utils.mise_shim('typos')
	if not typos then
		utils.soft_notify('typos is missing. Install via cargo/mise.', vim.log.levels.WARN)
		return
	end

	local obj = vim.system({ typos, '--format', 'json' }, { text = true }):wait()

	if obj.stdout == '' then
		vim.notify('No typos found project-wide!', vim.log.levels.INFO)
		return
	end

	local qf_items = {}
	-- Iterate through the NDJSON (Newline Delimited JSON) output
	for _, line in ipairs(vim.split(obj.stdout, '\n')) do
		if line ~= '' then
			-- Safely attempt to decode the JSON line. If it fails, ignore it rather than crashing.
			local ok, data = pcall(vim.json.decode, line)
			if ok and data.type == 'typo' then
				table.insert(qf_items, {
					filename = data.path,
					lnum = data.line_num,
					col = data.byte_offset,
					-- Format: "Typo: 'teh' -> the, then"
					text = string.format("Typo: '%s' -> %s", data.typo,
						table.concat(data.corrections, ", ")),
				})
			end
		end
	end

	if #qf_items > 0 then
		vim.fn.setqflist(qf_items, 'r')
		local has_trouble, _ = pcall(require, 'trouble')
		if has_trouble then
			vim.cmd('Trouble quickfix toggle')
		else
			vim.cmd('copen')
		end
	else
		vim.notify('No typos found!', vim.log.levels.INFO)
	end
end, { desc = 'Populate Quickfix with project typos' })

-- Keymaps moved to lua/core/plugin-keymaps.lua.
local utils = require('core.utils')

-- [[ Typos-CLI Raw Terminal View ]]
vim.api.nvim_create_user_command('TyposCheck', function()
	local typos_bin = utils.mise_shim('typos')
	if not typos_bin then
		utils.soft_notify('Typos binary not found. Please run: mise install typos', vim.log.levels.WARN)
		return
	end

	-- We wrap the command in a shell wait so it mimics 'close_on_exit = false'.
	-- This allows you to read the output before the Snacks terminal destroys itself.
	local cmd = string.format("%s ; echo ''; read -p 'Press Enter to close...'", typos_bin)

	require('snacks').terminal.toggle(cmd)
end, { desc = "Run typos-cli raw output on the current project" })

-- [[ NvimHealth: Plugin + LSP Health Check ]]
-- Wraps the custom vim.health reporter for quick access.
vim.api.nvim_create_user_command('NvimHealth', function()
	vim.cmd('checkhealth nvim_config')
end, { desc = 'Check plugin layer, LSP binaries, and active servers' })

return M
