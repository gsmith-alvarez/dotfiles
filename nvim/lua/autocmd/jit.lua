-- [[ JIT NOTETAKING ]]
-- Domain: Deferred Plugin Initialization
-- Location: lua/autocmd/jit.lua
--
-- PHILOSOPHY: Asymmetric Resource Allocation
-- Why load a 10,000-line Markdown plugin when you're editing a C++ file? 
-- This module implements "Stubs" and "Proxy Autocmds" to defer plugin 
-- loading until the exact moment the functionality is required. This is 
-- the core of the "Phased Boot" strategy, keeping the initial startup time 
-- extremely low (usually <20ms).
--
-- MAINTENANCE TIPS:
-- 1. If Obsidian keymaps aren't working, check if you're in a Markdown file 
--    inside your vault (`~/Documents/Obsidian`).
-- 2. New JIT plugins should follow the "Proxy" pattern: check for loading, 
--    load if needed, then execute the command.
-- 3. Use `pcall(require, ...)` to ensure a missing plugin doesn't break 
--    the entire JIT engine.

local M = {}

local utils = require('core.utils')
local jit_group = vim.api.nvim_create_augroup("JIT_Notetaking", { clear = true })

-- [[ INTERNAL STATE: Atomic Loading ]]
-- Why: We use a local table instead of global vim.g variables to keep the 
-- global namespace clean and avoid accidental overrides.
local loaded = {
  obsidian = false,
}

--- Atomic Loader for Obsidian.
--- Uses pcall to ensure a missing config file doesn't crash the editor.
local function load_obsidian(args)
  if loaded.obsidian then return true end

  -- If triggered by opening a markdown file, only load if in an Obsidian vault.
  -- Why: We don't want the full Obsidian plugin features active when 
  -- editing a random README.md in a git repository.
  local buf = args and args.buf or 0
  if type(args) == "table" and args.event == "FileType" then
    local vault_path = vim.fn.expand("~/Documents/Obsidian")
    local current_file = vim.api.nvim_buf_get_name(buf)

    if current_file ~= "" and not current_file:find(vault_path, 1, true) then
      utils.soft_notify("Not in Obsidian vault. Skipping plugin load.", vim.log.levels.DEBUG)
      return false
    end
  end

  -- Load the actual plugin configuration file.
  local ok, plugin = pcall(require, "plugins.notetaking.obsidian")
  if ok and plugin.setup then
    -- ASYMMETRIC LEVERAGE: Only call setup once to avoid duplicate hooks.
    pcall(plugin.setup)
    loaded.obsidian = true
    
    -- CRITICAL FIX: The plugin registers its FileType autocmd during setup(),
    -- but if we're loading JIT (triggered BY FileType), that event already fired.
    -- We must manually re-trigger the FileType event for the current buffer
    -- to ensure obsidian's autocmds run and keymaps get registered.
    if type(args) == "table" and args.event == "FileType" and vim.bo[buf].filetype == "markdown" then
      -- Re-trigger FileType to let obsidian's autocmds register their BufEnter hooks
      vim.api.nvim_exec_autocmds("FileType", { 
        buffer = buf, 
        group = "obsidian_setup",
        modeline = false 
      })
      -- Then trigger BufEnter to actually set up the buffer
      vim.api.nvim_exec_autocmds("BufEnter", { 
        buffer = buf, 
        group = "obsidian_setup",
        modeline = false 
      })
    end
    
    return true
  else
    utils.soft_notify("Failed to JIT load Obsidian: " .. (plugin or "Unknown Error"), vim.log.levels.ERROR)
    return false
  end
end

-- ========================================================================
-- OBSIDIAN BUFFER-LOCAL KEYMAPS
-- ========================================================================
-- Register this BEFORE the FileType autocmd so it's ready when ObsidianNoteEnter fires.
-- Must be at module level (not inside load_obsidian) to avoid duplicate registrations.
vim.api.nvim_create_autocmd("User", {
	desc = "Setup Obsidian buffer-local keymaps",
	pattern = "ObsidianNoteEnter",
	group = vim.api.nvim_create_augroup("ObsidianKeymaps", { clear = true }),
	callback = function(ev)
		-- Ensure obsidian is loaded before requiring actions
		if not loaded.obsidian then return end
		
		local ok, actions = pcall(require, "obsidian.actions")
		if not ok then return end
		
		-- Use 0 (current buffer) instead of ev.buf to ensure we're in the right context
		local function set_keymap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = 0, desc = desc })
		end
		
		-- Smart action (follow link, tag picker, toggle checkbox, fold cycle)
		set_keymap("n", "<leader>na", actions.smart_action, "Obsidian: Smart Action")

		-- Follow link variants
		set_keymap("n", "<leader>nf", function() vim.cmd("Obsidian follow_link tab") end, "Obsidian: Follow Link (New Tab)")
		set_keymap("n", "<leader>nv", function() vim.cmd("Obsidian follow_link vsplit") end, "Obsidian: Follow Link (V-Split)")
		set_keymap("n", "<leader>nh", function() vim.cmd("Obsidian follow_link hsplit") end, "Obsidian: Follow Link (H-Split)")

		-- Remove obsidian's default <CR> (smart_action) and give it to mini.jump2d
		pcall(vim.keymap.del, "n", "<CR>", { buffer = 0 })
		set_keymap("n", "<CR>", function()
			require('mini.jump2d').start(require('mini.jump2d').builtin_opts.word_start)
		end, "Jump2d: jump to word")

		set_keymap("n", "<leader>nT", function() vim.cmd("Obsidian tags") end, "Obsidian: Search [T]ags")
		set_keymap("n", "<leader>no", function() vim.cmd("Obsidian open") end, "Obsidian: [O]pen in GUI")
		set_keymap("n", "<leader>nc", function() vim.cmd("Obsidian toc") end, "Obsidian: [C]ontents (TOC)")

		-- Note Creation & Templates
		set_keymap("n", "<leader>nt", function() vim.cmd("Obsidian template") end, "Obsidian: Insert [T]emplate")
		set_keymap("n", "<leader>ne", function() vim.cmd("Obsidian extract_note") end, "Obsidian: [E]xtract to Note")
		set_keymap("n", "<leader>nl", function() vim.cmd("Obsidian link") end, "Obsidian: [L]ink Existing Note")
		set_keymap("n", "<leader>nN", function() vim.cmd("Obsidian link_new") end, "Obsidian: Link [N]ew Note")

		-- Media & Attachments
		set_keymap("n", "<leader>np", function() vim.cmd("Obsidian paste_img") end, "Obsidian: [P]aste Image")
	end,
})

-- [[ 1. AUTO-TRIGGER: FileType Interceptors ]]
-- These autocmds detect when you enter a specific domain (like Markdown) 
-- and transparently initialize the required plugin in the background.

vim.api.nvim_create_autocmd("FileType", {
  desc = "JIT Load Obsidian on Markdown entry",
  group = jit_group,
  pattern = "markdown",
  callback = load_obsidian,
})

-- [[ 2. PROXY COMMANDS: Global Stub Entry Points ]]
-- Why: These keymaps act as "Proxies." When pressed, they first verify 
-- the plugin is loaded, and then pass the intended command through to 
-- the newly initialized plugin. This allows you to have a global 
-- "Search Notes" keymap that works even if the plugin hasn't loaded yet.

--- Higher-order function to create Obsidian command stubs.
--- @param cmd string The Obsidian command to run after loading.
local function obsidian_stub(cmd)
  return function()
    if load_obsidian() then
      vim.cmd(cmd)
    end
  end
end

local map = vim.keymap.set
map("n", "<leader>nq", obsidian_stub("Obsidian quick_switch"), { desc = "Notes: Quick Switch" })
map("n", "<leader>ns", obsidian_stub("Obsidian search"), { desc = "Notes: Search" })
map("n", "<leader>nn", obsidian_stub("Obsidian new"), { desc = "Notes: New Note" })

return M
