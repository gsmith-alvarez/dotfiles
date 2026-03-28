-- [[ GUESS-INDENT: Automatic Indentation Detection ]]
-- Purpose: Automatically detect and apply indentation settings (tab/space, width).
-- Domain:  Text Manipulation & Formatting
-- Architecture: Self-Destructing Event Trap (Phased Boot)
--
-- PHILOSOPHY: The Disposable Bootloader
-- Indentation detection is critical but useless during the initial boot frame.
-- In our "Phased Boot" model, we use a self-destructing `BufReadPre` listener.
-- This is "Anti-Fragile": it ensures the correct indent is set when you open
-- a file, but the detection engine itself is deleted from memory once its
-- job is done.
--
-- MAINTENANCE TIPS:
-- 1. If indentation is wrong, check `:verbose set shiftwidth?` to see
--    what set it.
-- 2. This plugin runs once per session per filetype via the
--    `return true` self-destruct mechanism in the autocmd.

local M = {}
local utils = require 'core.utils'

local group = vim.api.nvim_create_augroup('Editing_GuessIndent', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = group,
  callback = function(args)
    local ok, err = pcall(function()
      require('mini.deps').add 'NMAC427/guess-indent.nvim'
      require('guess-indent').setup {
        auto_cmd = false, -- We manage triggering manually via our own autocmd below
      }

      -- Route the notification to DEBUG so it's captured in snacks.notifier
      -- history (<leader>sN) without appearing as a popup.
      vim.schedule(function()
        local orig = vim.notify
        vim.notify = function(msg, _, opts)
          orig(msg, vim.log.levels.DEBUG, opts)
        end
        pcall(require('guess-indent').set_from_buffer, args.buf, false, false)
        vim.notify = orig
      end)
    end)

    if not ok then
      utils.soft_notify('Guess-Indent failed to initialize: ' .. err, vim.log.levels.ERROR)
    end

    -- 2. The Native Self-Destruct
    -- Returning true signals the Neovim event loop to delete this autocommand.
    -- It will never fire again for the duration of the session.
    return true
  end,
})

-- THE CONTRACT: Return the module to satisfy the Editing Orchestrator.
return M
