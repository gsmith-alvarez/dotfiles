-- [[ AUDITING & REDIRECTION DOMAIN ]]
-- Domain: System Health & Code Quality
-- Location: lua/commands/auditing.lua
--
-- PHILOSOPHY: Empirical Validation
-- This module provides commands to audit the state of the editor and the 
-- underlying system. It prioritizes "knowing" over "guessing" by 
-- checking for physical binaries and parsing their output into 
-- standard Neovim interfaces (like Markdown reports or the Quickfix list).
--
-- MAINTENANCE TIPS:
-- 1. To add a new tool to the audit, add it to the `tools` list in `ToolCheck`.
-- 2. If `Typos` fails, verify `typos-cli` is installed via `mise`.
-- 3. All commands here are auto-registered by `commands/init.lua`.

local M = {}

M.commands = {
	-- [[ Dependency Auditing: :ToolCheck ]]
	-- Why: Instead of wondering why an LSP or Formatter isn't working, 
	-- :ToolCheck provides a definitive report of what's missing and how 
	-- to install it. This is a key part of the "Anti-Fragile" pillar.
	ToolCheck = {
		desc = 'Audit required dependencies and suggest installation steps',
		keymap = '<leader>ua', -- 'a' for Audit
		impl = function()
			local utils = require 'core.utils'
			local tools = {
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
				'stylua',
				'oxfmt',
				'oxlint',
				'shfmt',
				'typstyle',
				'yamllint',
				'markdownlint-cli2',
				'shellcheck',
				'typos',
				'rg',
				'fd',
				'sd',
				'gojq',
				'xh',
				'btm',
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
				local path = utils.mise_shim(tool)
				if path then
					table.insert(found, tool)
				else
					table.insert(missing, tool)
				end
			end

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
				table.insert(lines, '*(For true system dependencies like `make`, `gcc`, use your system package manager if mise cannot install them)*')
			end

			table.insert(lines, '')
			table.insert(lines, '## Found Tools')
			for _, tool in ipairs(found) do
				table.insert(lines, '- ' .. tool .. ' ✅')
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.cmd 'vsplit'
			vim.api.nvim_win_set_buf(0, buf)
			vim.bo[buf].modifiable = false
		end,
	},

	-- [[ Typos-CLI to Quickfix Pipeline ]]
	-- Why: Spell checking code is hard. Typos-cli is a fast Rust tool that 
	-- handles this project-wide. We parse its JSON output into the 
	-- Quickfix list so you can jump through errors instantly.
	Typos = {
		desc = 'Populate Quickfix with project typos',
		keymap = '<leader>ut',
		impl = function()
			local utils = require 'core.utils'
			local typos = utils.mise_shim 'typos'
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
			for _, line in ipairs(vim.split(obj.stdout, '\n')) do
				if line ~= '' then
					local ok, data = pcall(vim.json.decode, line)
					if ok and data.type == 'typo' then
						table.insert(qf_items, {
							filename = data.path,
							lnum = data.line_num,
							col = data.byte_offset,
							text = string.format("Typo: '%s' -> %s", data.typo, table.concat(data.corrections, ', ')),
						})
					end
				end
			end

			if #qf_items > 0 then
				vim.fn.setqflist(qf_items, 'r')
				local has_trouble, _ = pcall(require, 'trouble')
				if has_trouble then
					vim.cmd 'Trouble quickfix toggle'
				else
					vim.cmd 'copen'
				end
			else
				vim.notify('No typos found!', vim.log.levels.INFO)
			end
		end,
	},

	-- [[ Typos-CLI Raw Terminal View ]]
	TyposCheck = {
		desc = 'Run typos-cli raw output on the current project',
		impl = function()
			local utils = require 'core.utils'
			local typos_bin = utils.mise_shim 'typos'
			if not typos_bin then
				utils.soft_notify('Typos binary not found. Please run: mise install typos', vim.log.levels.WARN)
				return
			end

			local cmd = string.format("%s ; echo ''; read -p 'Press Enter to close...'", typos_bin)
			require('snacks').terminal.toggle(cmd)
		end,
	},

	-- [[ NvimHealth: Plugin + LSP Health Check ]]
	-- Why: This is a shortcut to our custom health check in `lua/nvim_config/health.lua`.
	NvimHealth = {
		desc = 'Check plugin layer, LSP binaries, and active servers',
		keymap = '<leader>uh',
		impl = function()
			vim.cmd 'checkhealth nvim_config'
		end,
	},
}

return M
