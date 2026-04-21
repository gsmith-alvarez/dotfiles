-- =============================================================================
-- [ OPTIONS ]
-- Global Neovim settings, behaviors, and UI configurations.
-- =============================================================================

local M = {}

-- 1. [ FILETYPE OPTIMIZATION ]
-- Predefine common filetypes for a slight speed boost and to ensure
-- specific extensions or filenames map correctly.
vim.filetype.add({
	extension = {
		lua = "lua",
		sh = "sh",
		py = "python",
		yaml = "yaml",
		yml = "yaml",
		fish = "fish",
		toml = "toml",
		md = "markdown",
	},
	filename = {
		[".gitignore"] = "gitignore",
		[".env"] = "sh",
		["Justfile"] = "just",
		["justfile"] = "just",
		["Dockerfile"] = "dockerfile",
	},
})

-- 2. [ LEADERS & GENERAL ]
vim.g.mapleader = " " -- Set leader key to Space
vim.g.maplocalleader = " " -- Set local leader key to Space
vim.g.have_nerd_font = true -- Inform plugins that a Nerd Font is available

local set = vim.opt

-- 3. [ INTERACTION & UI ]
set.mouse = "a" -- Enable mouse support in all modes
set.number = true -- Show absolute line numbers
set.relativenumber = true -- Show relative line numbers for easier jumping
set.showmode = false -- Don't show mode (e.g. -- INSERT --) as statusline handles it
set.clipboard = "unnamedplus" -- Use system clipboard for all yanks/pastes
set.confirm = true -- Ask to save changes before quitting an unsaved buffer

-- 4. [ PROVIDER DEACTIVATION ]
-- Disable providers for languages not used for scripting Neovim to save startup time.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- 5. [ TREESITTER & FOLDING ]
-- Use Treesitter for high-performance, semantic code folding.
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.treesitter.foldexpr()"
set.foldtext = "v:lua.vim.lsp.foldtext()" -- NOTE: Nightly Feature
set.foldlevel = 99 -- Start with all folds open
set.foldnestmax = 10 -- Limit fold nesting depth
set.fillchars = "eob: ,fold:╌" -- Custom characters for end-of-buffer and folds

-- 6. [ SEARCH & SPELL ]
set.ignorecase = true -- Ignore case in search patterns...
set.smartcase = true -- ...unless the pattern contains upper case characters.
set.inccommand = "split" -- Show search/replace effects in a live-preview split
set.spelloptions = "camel" -- Handle camelCase words in spell checking
set.spelllang = { "en_us" }
set.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- 7. [ FORMATTING ]
-- Pattern for detecting the start of a numbered list (used for `gw` and formatting).
set.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- 8. [ PERFORMANCE & PERSISTENCE ]
set.undofile = true -- Enable persistent undo across sessions
set.timeoutlen = 300 -- Time (ms) to wait for a mapped sequence to complete
set.scrolloff = 10 -- Minimum lines to keep above/below the cursor
set.shada = "'100,<50,s10,:1000,/100,@100,h" -- Optimize ShaDa file for faster startup
set.switchbuf = "usetab" -- Jump to existing tab if buffer is already open

-- 9. [ SYNTAX & FILETYPE ]
-- Ensure filetype detection and syntax highlighting are fully enabled.
vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
	vim.cmd("syntax enable")
end

-- 10. [ WRAPPING & INDENTATION ]
set.wrap = true -- Disable line wrapping by default
set.linebreak = true -- Wrap at words instead of characters when enabled
set.showbreak = "↪ " -- Visual indicator at the start of wrapped lines
set.breakindent = true -- Wrapped lines retain the same indentation level
set.breakindentopt = "list:-1" -- Special indentation for lists
set.colorcolumn = "+1" -- Highlight the column after 'textwidth'
set.cursorline = true -- Highlight the current cursor line

-- Standard 4-space indentation
set.expandtab = true -- Use spaces instead of tabs
set.shiftwidth = 4 -- Size of an indent
set.tabstop = 4 -- Number of spaces a tab counts for
set.softtabstop = 4 -- Number of spaces for a tab while editing

-- 11. [ COMPLETION & PUM ]
set.autocomplete = false -- Disable built-in completion (using blink.cmp)
set.completeopt:append("nearest") -- Prioritize completion matches near the cursor
set.pumborder = "rounded" -- Rounded borders for the popup menu
set.pummaxwidth = 20 -- Limit popup menu width
set.messagesopt:append("progress:c") -- Show background job progress in messages

-- 12. [ WINDOWS & SPLITS ]
set.splitright = true -- Vertical splits open to the right
set.splitbelow = true -- Horizontal splits open below
set.winborder = "rounded" -- Rounded borders for floating windows

-- 13. [ WHITESPACE VISUALIZATION ]
set.list = true -- Show invisible characters
set.listchars = {
	tab = "» ",
	trail = "·",
	nbsp = "␣",
	leadtab = "» ",
	extends = "…",
	precedes = "…",
}

-- 14. [ COMMAND LINE & STATUS ]
set.laststatus = 3 -- Use a single global statusline
set.showcmd = true -- Show the (partial) command in the last line
set.showcmdloc = "statusline" -- Show command keys in the statusline

-- 15. [ PROJECT-SPECIFIC CONFIG ]
-- Automatically load .nvim.lua, .nvimrc, or .exrc files in the current directory.
-- Includes security check: Neovim will ask for permission before running them.
set.exrc = true

return M
