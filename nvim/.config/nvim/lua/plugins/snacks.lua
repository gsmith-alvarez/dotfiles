-- =============================================================================
-- [ SNACKS.NVIM ]
-- Configuration for the snacks.nvim utility collection.
-- =============================================================================

local M = {}

-- 1. [ INITIALIZATION ]
-- Load snacks immediately to ensure global helpers and 'get' functions
-- are available for early-attach events (LSP, BufRead).
local snacks = Config.safe_require("snacks")

local youtube_cache_dir = vim.fn.stdpath("state") .. "/youtube_thumbnails"

M.resolve_youtube = function(video_id)
	local cached = youtube_cache_dir .. "/" .. video_id .. ".jpg"
	if vim.fn.filereadable(cached) == 1 then
		return cached
	end

	local max_url = "https://img.youtube.com/vi/" .. video_id .. "/maxresdefault.jpg"
	local hq_url = "https://img.youtube.com/vi/" .. video_id .. "/hqdefault.jpg"

	if vim.net and vim.net.request then
		vim.net.request(max_url, {
			method = "HEAD",
			callback = function(err, res)
				local target = (not err and res and res.status == 200) and max_url or hq_url
				vim.net.request(target, {
					method = "GET",
					callback = function(get_err, get_res)
						if get_err or not get_res or not get_res.body then
							return
						end
						vim.fn.mkdir(youtube_cache_dir, "p")
						local f = io.open(cached, "wb")
						if f then
							f:write(get_res.body)
							f:close()
						end
					end,
				})
			end,
		})
	end

	return max_url
end

M.resolve_obsidian = function(file, src)
	local ok, obsidian = pcall(require, "obsidian")
	if not ok or not (_G.Obsidian and _G.Obsidian.workspace) then
		return
	end

	local api = obsidian.api
	if not api.path_is_note(file) then
		return
	end

	local resolved = api.resolve_attachment_path(src)
	if resolved and vim.fn.filereadable(resolved) == 1 then
		return resolved
	end

	local found = vim.fs.find(vim.fs.basename(src), {
		path = tostring(_G.Obsidian.workspace.root),
		type = "file",
		limit = 1,
	})

	return found and found[1] or nil
end

-- [[ GLOBAL DEBUG HELPERS ]]
_G.dd = function(...)
	snacks.debug.inspect(...)
end
_G.bt = function()
	snacks.debug.backtrace()
end

---@diagnostic disable-next-line: duplicate-set-field
vim._print = function(...)
	_G.dd(...)
end

-- 2. [ CONSOLIDATED SETUP ]
-- Snacks is highly modular and lazy-loads its tools by default.
-- We call setup once here to initialize the core config table.
snacks.setup({
	-- A. UI & VISUALS (Logic runs on buffer events)
	bigfile = { enabled = true },
	indent = {
		enabled = true,
		char = "│",
		scope = {
			enabled = true,
			char = "│",
			edge = true,
		},
		chunk = {
			enabled = true,
		},
	},
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	words = { enabled = true },
	quickfile = { enabled = true },

	-- B. TOOLS & UTILITIES (Lazy-loaded on demand)
	animate = { enabled = true },
	bufdelete = { enabled = true },
	dashboard = { enabled = false },
	debug = { enabled = true },
	dim = { enabled = true },
	gh = { enabled = true },
	git = { enabled = true },
	image = {
		enabled = true,
		resolve = function(file, src)
			local video_id = src:match("youtube%.com/embed/([%w_%-]+)")
			if video_id then
				return M.resolve_youtube(video_id)
			end

			local clean_src = src:gsub("^%[%[", ""):gsub("%]%]$", ""):gsub("|.*$", "")
			return M.resolve_obsidian(file, clean_src)
		end,
	},
	lazygit = { enabled = true },
	picker = {
		enabled = true,
		layout = "custom",
		layouts = {
			custom = {
				layout = {
					box = "vertical",
					backdrop = false,
					row = -1,
					width = 0,
					height = 0.4,
					border = "none",
					title = " {title} {live} {flags}",
					title_pos = "left",
					{
						box = "horizontal",
						{ win = "list", border = "rounded" },
						{ win = "preview", title = "{preview}", width = 0.6, border = "rounded" },
					},
					{ win = "input", height = 1, border = "none" },
				},
			},
		},
	},
	scope = { enabled = true },
	terminal = {
		win = {
			border = "rounded",
			winblend = 3,
			keys = { q = "hide" },
			style = {
				statusline = " %{fnamemodify(getcwd(), ':~')} ",
			},
		},
	},
	scratch = { enabled = true },
	toggle = { enabled = true },
	zen = { enabled = true },
})

-- 3. [ TOGGLES ]
-- We define these here using the Snacks Toggle API.
-- These will automatically appear in Which-Key with proper descriptions.
local mini = Config.safe_require("plugins.mini")
mini.later(function()
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle.line_number():map("<leader>ul")
	Snacks.toggle
		.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
		:map("<leader>uc")
	Snacks.toggle.treesitter():map("<leader>uT")
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
	Snacks.toggle.inlay_hints():map("<leader>uh")
	Snacks.toggle.indent():map("<leader>ug")
	Snacks.toggle.dim():map("<leader>uD")
	Snacks.toggle.zen():map("<leader>uz")
	Snacks.toggle.zoom():map("<leader>uZ")
end)

return M
