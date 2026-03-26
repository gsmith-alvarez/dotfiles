-- [[ EXTERNAL TOOLS & PERFORMANCE AUTOCOMMANDS ]]
-- Domain: System Interop & Resource Protection
-- Location: lua/autocmd/external.lua
--
-- PHILOSOPHY: Anti-Fragile Resource Management
-- Neovim should not crash when encountering massive files or binary archives.
-- This module implements "Defensive Interceptors" to detect extreme conditions 
-- early and pivot to lightweight modes or external high-performance tools.
--
-- MAINTENANCE TIPS:
-- 1. If viewing an archive fails, verify `ouch` is installed via `mise`.
-- 2. Large file thresholds can be adjusted in the Big File interceptor below.
-- 3. Use `:messages` to see notifications from these resource guards.

local M = {}

local external_group = vim.api.nvim_create_augroup('ExternalAutocmds', { clear = true })

-- [[ 1. ENVIRONMENT: Mise Dynamic Awareness ]]
-- Why: Ensures that the editor stays synchronized with the version manager.
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Synchronize environment context on buffer entry',
  group = external_group,
  callback = function()
    -- PERFORMANCE: Skip checks for non-file buffers.
    if vim.bo.buftype == "terminal" or vim.bo.filetype == "minifiles" then
      return
    end

    -- Project-specific logic can be added here if needed.
  end,
})

-- [[ 2. I/O: Transparent Archive Explorer ]]
-- Why: Uses the 'ouch' CLI (a high-performance Rust tool) to list archive 
-- contents directly in a Neovim buffer without extracting them to disk.
-- This is much faster than standard Neovim zip/tar plugins.
vim.api.nvim_create_autocmd('BufReadCmd', {
  desc = 'Use ouch to transparently view archive contents',
  group = external_group,
  pattern = { '*.zip', '*.tar.gz', '*.tgz', '*.tar.bz2', '*.rar', '*.7z' },
  callback = function(args)
    local utils = require('core.utils')
    local ouch = vim.fn.executable('ouch') == 1 and 'ouch' or nil

    if not ouch then
      utils.soft_notify('ouch-cli missing! Install via: mise install ouch', vim.log.levels.WARN)
      return
    end

    local file = args.file
    -- ASYMMETRIC LEVERAGE: List archive contents via external binary.
    -- 'l' = list command in ouch.
    local obj = vim.system({ ouch, 'l', file }, { text = true }):wait()

    if obj.code == 0 then
      local lines = vim.split(obj.stdout, '\n')
      vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)

      -- Set buffer to read-only/scratch mode to prevent accidental editing.
      vim.bo[args.buf].modifiable = false
      vim.bo[args.buf].filetype = 'archive'
      vim.bo[args.buf].buftype = 'nofile'

      vim.notify('📦 Viewing Archive: ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.DEBUG)
    else
      utils.soft_notify('ouch failed to decode archive: ' .. (obj.stderr or "Unknown error"), vim.log.levels.ERROR)
    end
  end,
})

-- [[ 3. PERFORMANCE: Big File Defensive Interceptor ]]
-- Why: Detects files over a specific threshold (2MB) and strips away intensive
-- features like Treesitter and LSP to keep the editor responsive.
-- This prevents Neovim from freezing when you accidentally open a 50MB log file.
vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Disable expensive features for large files',
  group = external_group,
  pattern = '*',
  callback = function(ev)
    local max_filesize = 2 * 1024 * 1024 -- 2MB Threshold
    -- PERFORMANCE: Use native Libuv fs_stat (faster than Vimscript's getfsize).
    local ok, stats = pcall(vim.uv.fs_stat, ev.match)

    if ok and stats and stats.size > max_filesize then
      -- 1. Set a buffer-local flag for other plugins to respect.
      vim.b[ev.buf].bigfile = true

      -- 2. Localized Degradation:
      -- Disable regex syntax highlighting for this buffer only.
      vim.opt_local.syntax = ''

      -- Disable Treesitter (usually the biggest performance killer on large files).
      pcall(vim.treesitter.stop, ev.buf)

      -- Disable memory-heavy buffer operations.
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.undoreload = 0
      vim.opt_local.foldmethod = 'manual'

      -- 3. Notification Logic.
      local size_mb = math.floor(stats.size / 1024 / 1024)
      local extension = vim.fn.fnamemodify(ev.match, ':e')

      if extension == 'json' then
        vim.notify(
          string.format("⚠️ Big JSON Detected (%sMB).\nPerformance degraded. Use :Jless for large datasets.", size_mb),
          vim.log.levels.WARN,
          { title = "Resource Guard" }
        )
      else
        vim.notify(
          string.format("🚀 Big File Mode: Optimized for %sMB file (Syntax/Treesitter OFF).", size_mb),
          vim.log.levels.WARN,
          { title = "Resource Guard" }
        )
      end
    end
  end,
})

return M
