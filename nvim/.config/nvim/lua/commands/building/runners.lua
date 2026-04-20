local M = {}

local function esc(s)
	return vim.fn.shellescape(s)
end

local function has_file(root, name)
	return root ~= nil and vim.uv.fs_stat(root .. "/" .. name) ~= nil
end

local runners = {
	python = function(ctx)
		return ("uv run %s"):format(esc(ctx.file))
	end,

	go = function(ctx)
		if has_file(ctx.root, "go.mod") then
			return "go run ."
		end
		return ("go run %s"):format(esc(ctx.file))
	end,

	zig = function(ctx)
		if has_file(ctx.root, "build.zig") then
			return "zig build run"
		end
		return ("zig run %s"):format(esc(ctx.file))
	end,

	lua = function(ctx)
		return ("nvim -l %s 2>&1"):format(esc(ctx.file))
	end,

	sh = function(ctx)
		return ("bash %s"):format(esc(ctx.file))
	end,

	bash = function(ctx)
		return ("bash %s"):format(esc(ctx.file))
	end,

	rust = function(ctx)
		if has_file(ctx.root, "Cargo.toml") then
			return "cargo run -q"
		end
		local tmp_bin = "/tmp/" .. vim.fn.expand("%:t:r") .. "_rust_run"
		return ("rustc %s -o %s && %s"):format(esc(ctx.file), esc(tmp_bin), esc(tmp_bin))
	end,

	c = function(ctx)
		if has_file(ctx.root, "Makefile") then
			return "make"
		end
		if has_file(ctx.root, "CMakeLists.txt") then
			return "cmake --build build"
		end
		if vim.uv.fs_stat(ctx.file) == nil then
			return nil, "C file not readable: " .. ctx.file
		end
		return ("zig run -cflags -std=c23 -Wall -Wextra -O2 -Werror -- %s -lc"):format(esc(ctx.file))
	end,

	cpp = function(ctx)
		if has_file(ctx.root, "Makefile") then
			return "make"
		end
		if has_file(ctx.root, "CMakeLists.txt") then
			return "cmake --build build"
		end
		if vim.uv.fs_stat(ctx.file) == nil then
			return nil, "C++ file not readable: " .. ctx.file
		end
		return ("zig run -cflags -std=c++23 -Wall -Wextra -O2 -Werror -- %s -lc -lc++"):format(esc(ctx.file))
	end,
}

function M.build(ft, ctx)
	local runner = runners[ft]
	if not runner then
		return nil, "No smart runner for filetype: " .. ft
	end
	return runner(ctx)
end

function M.has(ft)
	return runners[ft] ~= nil
end

return M
