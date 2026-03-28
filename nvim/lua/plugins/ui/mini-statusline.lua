-- [[ MINI.STATUSLINE: Global Telemetry Bar ]]
-- Purpose: Provide real-time context (Git, LSP, Mode) with zero input lag.
-- Domain:  UI / Information Density
-- Architecture: "Just-in-Time" Telemetry (Phased Boot)
--
-- PHILOSOPHY: Non-Blocking Observability
-- The statusline must never block the UI thread. In an "Anti-Fragile" system,
-- expensive operations (like Mise version polling) are handled via throttled
-- async loops. We use `MiniDeps.later` to ensure the statusline doesn't
-- even attempt to draw until the buffer is interactive.
--
-- MAINTENANCE TIPS:
-- 1. If the statusline is missing information, check the `render_telemetry` function.
-- 2. LSP icons are integrated directly into the `strings` table.
-- 3. If Mise versions aren't updating, check if `mise` is in your system PATH.

local M = {}

M.setup = function()
  require('mini.deps').later(function()
    local statusline = require 'mini.statusline'

    local ft_to_tool = {
      python = 'python',
      javascript = 'node',
      typescript = 'node',
      javascriptreact = 'node',
      typescriptreact = 'node',
      go = 'go',
      rust = 'rust',
      zig = 'zig',
      ruby = 'ruby',
      php = 'php',
      java = 'java',
      lua = 'lua',
      c = 'clang',
      cpp = 'clang',
    }

    local telemetry_group = vim.api.nvim_create_augroup('MiniStatuslineTelemetry', { clear = true })
    if vim.fn.executable 'mise' == 1 then
      vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter', 'DirChanged' }, {
        group = telemetry_group,
        callback = function(event)
          local buf = event.buf
          if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf]._mise_polling then
            return
          end
          local ft = vim.bo[buf].filetype
          local target_tool = ft_to_tool[ft]
          if not target_tool then
            vim.b[buf].mise_status = ''
            vim.cmd 'redrawstatus'
            return
          end
          vim.b[buf]._mise_polling = true
          vim.system({ 'mise', 'current', target_tool }, { text = true }, function(out)
            local status = ''
            if out.code == 0 and out.stdout and out.stdout ~= '' then
              local version = out.stdout:gsub('\n', ''):gsub('%s+$', '')
              version = version:match '([^@%s]+)$' or version
              status = '🛠 ' .. version
            end
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(buf) then
                vim.b[buf].mise_status = status
                vim.b[buf]._mise_polling = false
                vim.cmd 'redrawstatus'
              end
            end)
          end)
        end,
        desc = 'Targeted Mise Version Poller',
      })
    end

    local function render_telemetry()
      local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
      local git = statusline.section_git { trunc_width = 40 }
      local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
      local filename = statusline.section_filename { trunc_width = 140 }
      local location = statusline.section_location { trunc_width = 75 }
      local lsp_status = ''
      local active_clients = vim.lsp.get_clients { bufnr = 0 }
      if #active_clients > 0 then
        lsp_status = '⚡ ' .. active_clients[1].name
      end

      local mise_status = vim.b.mise_status or ''

      -- Diff counts from mini.diff (vim.b.minidiff_summary)
      local diff_status = ''
      local summary = vim.b.minidiff_summary
      if summary then
        local parts = {}
        if (summary.add or 0) > 0 then
          table.insert(parts, '+' .. summary.add)
        end
        if (summary.change or 0) > 0 then
          table.insert(parts, '~' .. summary.change)
        end
        if (summary.delete or 0) > 0 then
          table.insert(parts, '-' .. summary.delete)
        end
        if #parts > 0 then
          diff_status = table.concat(parts, ' ')
        end
      end

      return statusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff_status, diagnostics } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        '%S ',
        { hl = 'MiniStatuslineDevinfo', strings = { lsp_status, mise_status } },
        { hl = mode_hl, strings = { location } },
      }
    end

    statusline.setup {
      content = { active = render_telemetry },
      use_icons = true,
      set_vim_settings = false,
    }
    vim.opt.showcmdloc = 'statusline'
  end)
end

return M
