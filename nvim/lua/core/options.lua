-- [[ THE EDITOR OPTIONS: lua/core/options.lua ]]
-- =============================================================================
-- This file contains all your general Neovim configuration settings.
-- Think of this as the "Global Settings" menu in a typical app.
--
-- See `:help vim.o` for a full list of all available options.
-- =============================================================================

local M = {}

-- =============================================================================
-- [[ ENVIRONMENT SETUP: MISE & EXTERNAL BINARIES ]]
-- -----------------------------------------------------------------------------
-- This configuration is optimized for `mise` (modern ASDF alternative).
-- We ensure that Neovim and its plugins look for language servers, linters,
-- and formatters in your mise-managed directories first.
-- =============================================================================

-- Force Neovim to use mise-managed Python and Node interpreters.
-- This prevents issues where Neovim might not find the right version of python/node.
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/mise/shims/python'
vim.g.node_host_prog = vim.fn.expand '~/.local/share/mise/shims/node'

-- =============================================================================
-- [[ LEADER KEY CONFIGURATION ]]
-- -----------------------------------------------------------------------------
-- The "Leader Key" is a special prefix key (like a hotkey) used to trigger
-- custom actions (e.g. <leader>ff to find files).
-- This MUST be set before plugins load.
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- Set <Space> as the leader key.
vim.g.maplocalleader = ' '

-- [[ FONT CONFIGURATION ]]
-- Set to true if you have a "Nerd Font" (like JetBrainsMono Nerd Font) installed.
-- Nerd Fonts contain icons (icons like 󰓩, , 🛠️) used by many plugins.
vim.g.have_nerd_font = true

-- =============================================================================
-- [[ EDITOR BEHAVIOR & UI SETTINGS ]]
-- =============================================================================

-- DISABLE MOUSE: To master Neovim, we force keyboard navigation.
vim.opt.mouse = ''

-- LINE NUMBERS: Hybrid setup (Absolute current, Relative everything else).
-- This makes jumping to lines (e.g. typing "15k" to jump 15 lines up) very easy.
vim.o.number = true
vim.o.relativenumber = true

-- MODE: Hide standard "-- INSERT --" text (the status line handles this).
vim.o.showmode = false

-- CLIPBOARD: Sync Neovim and OS clipboard.
-- Note: Copying/Pasting will use your system-wide clipboard!
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- WRAPPING: Enable soft-wrapping (long lines wrap visually but stay on one line).
vim.opt.wrap = true
vim.opt.linebreak = true -- Wrap at words, not in the middle of a word.
vim.opt.showbreak = '↪ ' -- Visual marker for wrapped lines.

-- HISTORY & PERFORMANCE:
vim.o.undofile = true -- Persistent undo! Even after closing/reopening a file.
vim.o.ignorecase = true -- Case-insensitive search.
vim.o.smartcase = true -- ...unless you search for a capital letter.
vim.o.signcolumn = 'yes' -- Keep space for git/errors icons on the left.
vim.o.timeoutlen = 300 -- Wait 300ms for keymaps to complete.
vim.o.scrolloff = 10 -- Always keep at least 10 lines visible above/below the cursor.

-- WINDOWS:
vim.o.splitright = true -- New vertical splits open on the right.
vim.o.splitbelow = true -- New horizontal splits open on the bottom.

-- UI FEEDBACK:
vim.o.cursorline = true -- Subtly highlight the current line.
vim.o.inccommand = 'split' -- Show live results of find/replace as you type.
vim.o.confirm = true -- Show a dialog asking to save changes before quitting.

-- WHITESPACE:
vim.o.list = true -- Show hidden characters.
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- COMMAND LINE:
vim.opt.laststatus = 3 -- Use a single, shared statusline across all windows.
vim.opt.showcmd = true
vim.opt.showcmdloc = 'statusline' -- Show current command in the statusline.

return M
