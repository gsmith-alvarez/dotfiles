-- [[ TEST RUNNER: Language-Aware Test Dispatch ]]
-- Domain: Workflow
-- Covers: Rust, Zig, Python, C/C++
-- No neotest dependency — uses snacks.terminal for output.

local M = {}

M.setup = function()
	local function run(cmd)
		require('snacks').terminal.toggle(cmd .. "; echo ''; read -p 'Press Enter to close...'")
	end

	-- [[ ROOT RESOLVER ]]
	local root_markers = { 'Cargo.toml', 'build.zig', 'pyproject.toml', 'setup.py', 'CMakeLists.txt', 'Makefile', '.git' }
	local function project_root()
		local path = vim.api.nvim_buf_get_name(0)
		path = path ~= '' and vim.fn.fnamemodify(path, ':p:h') or vim.fn.getcwd()
		for dir in vim.fs.parents(path) do
			for _, m in ipairs(root_markers) do
				if vim.uv.fs_stat(dir .. '/' .. m) then return dir end
			end
		end
		return vim.fn.getcwd()
	end

	-- [[ NEAREST TEST RESOLVER ]]
	-- Searches upward from cursor for a recognisable test declaration.
	local nearest_patterns = {
		rust    = { '^%s*fn%s+([%w_]+)', '^%s*async%s+fn%s+([%w_]+)' },
		zig     = { '^%s*test%s+"([^"]+)"' },
		python  = { '^%s*def%s+(test[%w_]*)' },
		c       = { 'TEST[_A-Z]*%(([%w_]+)' },
		cpp     = { 'TEST[_A-Z]*%(([%w_]+)', 'BOOST_AUTO_TEST_CASE%(([%w_]+)' },
	}

	local function nearest_test(ft)
		local patterns = nearest_patterns[ft] or {}
		local lnum = vim.fn.line '.'
		for i = lnum, 1, -1 do
			local line = vim.fn.getline(i)
			for _, pat in ipairs(patterns) do
				local m = line:match(pat)
				if m then return m end
			end
		end
		return nil
	end

	-- [[ DISPATCH TABLE ]]
	-- Each entry: { all, file, nearest }
	-- `nearest` receives the matched test name as its argument.
	local runners = {
		rust = {
			all     = function(root) return 'cd ' .. root .. ' && cargo test' end,
			file    = function(_)    return 'cargo test' end,
			nearest = function(root, name) return 'cd ' .. root .. ' && cargo test ' .. name end,
		},
		zig = {
			all     = function(root) return 'cd ' .. root .. ' && zig build test' end,
			file    = function(file) return 'zig test ' .. file end,
			nearest = function(root, _) return 'cd ' .. root .. ' && zig build test' end,
		},
		python = {
			all     = function(root) return 'cd ' .. root .. ' && pytest' end,
			file    = function(file) return 'pytest ' .. file end,
			nearest = function(_, name) return 'pytest -k ' .. name end,
		},
		c = {
			all     = function(root)
				if vim.uv.fs_stat(root .. '/CMakeLists.txt') then
					return 'cd ' .. root .. ' && cmake --build build && cd build && ctest --output-on-failure'
				end
				return 'cd ' .. root .. ' && make test'
			end,
			file    = function(_) return nil end, -- no per-file runner for C
			nearest = function(_,_) return nil end,
		},
		cpp = {
			all     = function(root)
				if vim.uv.fs_stat(root .. '/CMakeLists.txt') then
					return 'cd ' .. root .. ' && cmake --build build && cd build && ctest --output-on-failure'
				end
				return 'cd ' .. root .. ' && make test'
			end,
			file    = function(_) return nil end,
			nearest = function(_, name)
				-- For Google Test, filter by test name
				return name and ('ctest -R ' .. name) or nil
			end,
		},
	}

	local ft_map = { c = 'c', cpp = 'cpp', rust = 'rust', zig = 'zig', python = 'python' }

	local function get_runner()
		local ft = vim.bo.filetype
		local key = ft_map[ft]
		return key and runners[key], key
	end

	-- Export runner functions for plugin-keymaps.lua
	M.run_all = function()
		local r, key = get_runner()
		if not r then
			vim.notify('No test runner for filetype: ' .. vim.bo.filetype, vim.log.levels.WARN)
			return
		end
		local cmd = r.all(project_root())
		if cmd then run(cmd) else vim.notify('No project-wide runner for ' .. key, vim.log.levels.WARN) end
	end

	M.run_file = function()
		local r, key = get_runner()
		if not r then
			vim.notify('No test runner for filetype: ' .. vim.bo.filetype, vim.log.levels.WARN)
			return
		end
		local file = vim.fn.expand('%:p')
		local cmd = r.file(file)
		if cmd then run(cmd) else vim.notify('No file-level runner for ' .. key, vim.log.levels.WARN) end
	end

	M.run_nearest = function()
		local r, key = get_runner()
		if not r then
			vim.notify('No test runner for filetype: ' .. vim.bo.filetype, vim.log.levels.WARN)
			return
		end
		local name = nearest_test(key)
		if not name then
			vim.notify('No test found near cursor', vim.log.levels.WARN)
			return
		end
		local cmd = r.nearest(project_root(), name)
		if cmd then run(cmd) else vim.notify('No nearest-test runner for ' .. key, vim.log.levels.WARN) end
	end
end

return M
