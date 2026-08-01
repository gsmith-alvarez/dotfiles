-- options

local M = {}

-- 2. Leaders & general
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

local set = vim.opt

-- 3. Interaction & UI
set.mouse = "a"
set.mousescroll = "ver:25,hor:6"
set.number = true
set.relativenumber = true
set.showmode = false
set.clipboard = "unnamedplus" -- System clipboard; OSC52 fallback over SSH
set.confirm = true

-- 4. Provider deactivation
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- 5. Treesitter & folding
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldtext = "v:lua.vim.lsp.foldtext()"
set.foldlevel = 99
set.foldnestmax = 10
set.fillchars = "eob: ,fold:╌"

-- 6. Search & spell
set.ignorecase = true
set.smartcase = true
set.inccommand = "split"
set.spelloptions = "camel"
set.spelllang = { "en_us" }
set.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- 7. Formatting
set.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
set.iskeyword = "@,48-57,_,192-255,-" -- Keep dash-separated words as one word

-- 8. Performance & persistence
set.undofile = true
set.timeoutlen = 300
set.updatetime = 200
set.jumpoptions = "view" -- Preserve view when jumping
set.splitkeep = "screen" -- Keep screen stable on split changes
set.smoothscroll = true
set.scrolloff = 10
set.scrolloffpad = 1 -- Allow the cursor to stay centered at end-of-file
set.switchbuf = "usetab"

-- Nvim enables filetype detection & syntax at startup.
vim.api.nvim_create_autocmd("FileType", {
	desc = "Keep formatoptions clean for editing",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "o" })
	end,
})

-- 10. Wrapping & indentation
set.wrap = true
set.linebreak = true
set.showbreak = "↪ "
set.breakindent = true
set.breakindentopt = "list:-1"
set.colorcolumn = "" -- scoped to markdown ftplugin; +1 needs a textwidth to render correctly
set.cursorline = true
set.cursorlineopt = "screenline,number"

-- Standard 4-space indentation
set.expandtab = true
set.shiftwidth = 4
set.tabstop = 4
set.softtabstop = 4

-- 11. Completion & pum
set.autocomplete = false
set.completeopt:append("nearest")
set.completetimeout = 100
set.pumborder = "rounded"
set.pummaxwidth = 20

-- 12. Windows & splits
set.splitright = true
set.splitbelow = true
set.winborder = "rounded"

-- 13. Whitespace visualization
set.list = true
set.listchars = {
	tab = "» ",
	trail = "·",
	nbsp = "␣",
	leadtab = "» ",
	extends = "…",
	precedes = "…",
}

-- 14. Command line & status
set.laststatus = 3
set.showcmd = true
set.showcmdloc = "statusline"

-- 15. Project-specific config
set.exrc = true
set.secure = true -- block untrusted :autocmd/:shell/:python in project .nvimrc/.exrc

-- 16. Markdown
vim.g.markdown_recommended_style = 0

return M
