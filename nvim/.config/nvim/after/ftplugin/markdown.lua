-- =============================================================================
-- [ MARKDOWN / OBSIDIAN KEYMAPS ]
-- Buffer-local mappings for Markdown files and Obsidian integration.
-- =============================================================================

local u = Config.safe_require("core.utils")
if not u then
	return
end

local autolist = Config.safe_require("autolist")

-- 1. [ SMART ACTIONS ]
u.nmap("<leader>oa", function()
	if require("obsidian.api").cursor_link() then
		return "<cmd>Obsidian follow_link<CR>"
	else
		return "<cmd>Obsidian toggle_checkbox<CR>"
	end
end, "Obsidian: Smart Action", { buffer = true, expr = true })

-- 2. [ NAVIGATION & LINKS ]
-- Open in new tab via LSP definition with a custom on_list handler,
-- since obsidian.nvim does not have a built-in 'tab' open strategy.
u.nmap("<leader>of", function()
	vim.lsp.buf.definition({
		on_list = function(options)
			if #options.items == 0 then
				return
			end
			local item = options.items[1]
			local fname = item.filename or vim.uri_to_fname(item.uri or "")
			if fname ~= "" then
				vim.cmd("tabedit " .. vim.fn.fnameescape(fname))
			end
		end,
	})
end, "Obsidian: Follow Link (New Tab)", { buffer = true })
u.nmap("<leader>ov", "<cmd>Obsidian follow_link vsplit<CR>", "Obsidian: Follow Link (V-Split)", { buffer = true })
u.nmap("<leader>oh", "<cmd>Obsidian follow_link hsplit<CR>", "Obsidian: Follow Link (H-Split)", { buffer = true })
u.nmap("<leader>oc", "<cmd>Obsidian toc<CR>", "Obsidian: Contents (TOC)", { buffer = true })
u.nmap("<leader>oo", "<cmd>Obsidian open<CR>", "Obsidian: Open in GUI", { buffer = true })

-- 3. [ SEARCH ]
u.nmap("<leader>os", "<cmd>Obsidian search<CR>", "Obsidian: Search Notes", { buffer = true })
u.nmap("<leader>oq", "<cmd>Obsidian quick_switch<CR>", "Obsidian: Quick Switch", { buffer = true })
u.nmap("<leader>ot", "<cmd>Obsidian tags<CR>", "Obsidian: Search Tags", { buffer = true })

-- 4. [ NOTE CREATION ]
u.nmap("<leader>on", "<cmd>Obsidian new<CR>", "Obsidian: New Note", { buffer = true })
u.nmap("<leader>ou", "<cmd>Obsidian unique_note<CR>", "Obsidian: Unique Note", { buffer = true })
u.nmap("<leader>oT", "<cmd>Obsidian template<CR>", "Obsidian: Insert Template", { buffer = true })

-- 5. [ VISUAL MODE ]
u.map("v", "<leader>oe", "<cmd>Obsidian extract_note<CR>", "Obsidian: Extract Note", { buffer = true })
u.map("v", "<leader>ol", "<cmd>Obsidian link<CR>", "Obsidian: Link Selection", { buffer = true })
u.map("v", "<leader>oN", "<cmd>Obsidian link_new<CR>", "Obsidian: Link Selection to New", { buffer = true })

-- 6. [ MEDIA ]
u.nmap("<leader>op", "<cmd>Obsidian paste_img<CR>", "Obsidian: Paste Image", { buffer = true })

-- 7. [ OVERRIDES ]
u.imap("<Tab>", "<cmd>AutolistTab<CR>", "Autolist: Indent", { buffer = true })
u.imap("<S-Tab>", "<cmd>AutolistShiftTab<CR>", "Autolist: Dedent", { buffer = true })
u.imap("<CR>", "<CR><cmd>AutolistNewBullet<CR>", "Autolist: New Bullet", { buffer = true })
u.nmap("o", "o<cmd>AutolistNewBullet<CR>", "Autolist: New Bullet Below", { buffer = true })
u.nmap("O", "O<cmd>AutolistNewBulletBefore<CR>", "Autolist: New Bullet Above", { buffer = true })

-- Give <CR> to checkbox toggle, link follow, or jump2d.
u.nmap("<CR>", function()
	local line = vim.api.nvim_get_current_line()
	if line:match("%[[ xX/%-!?]%]") then
		autolist.toggle_checkbox()
		return
	end
	if require("obsidian.api").cursor_link() then
		vim.cmd("Obsidian follow_link")
	else
		require("mini.jump2d").start(require("mini.jump2d").builtin_opts.word_start)
	end
end, "Obsidian: Toggle Checkbox, Jump, or Follow Link", { buffer = true })
