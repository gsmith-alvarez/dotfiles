--- [[ NATIVE DIAGNOSTIC BRIDGE ]]
--- Purpose: Non-Blocking Code Quality Auditing
--- Domain: Static Analysis
--- Architecture: Async CLI Pipeline (Native-First)
--- Location: lua/core/lint.lua
---
--- PHILOSOPHY: Anti-Fragile Performance
--- This module implements an asynchronous linting architecture. By 
--- communicating directly with CLI tools and parsing their output into 
--- Neovim's diagnostic API, we achieve lower overhead than any third-party 
--- plugin. This ensures a fluid UI even when running heavy analysis.
---
--- MAINTENANCE TIPS:
--- 1. To add a linter, add an entry to the `linters` table below.
--- 2. Ensure the binary (e.g., `shellcheck`) is installed via `mise`.
--- 3. Check the `parser` logic if diagnostics aren't appearing correctly.
--- 4. Linting happens on `BufWritePost` (when you save the file).

local M = {}

--- Namespace for our native linter bridge.
-- Why: Namespaces allow us to clear or update ONLY our diagnostics without 
-- affecting those from LSP or other plugins.
local ns = vim.api.nvim_create_namespace('native-lint')

--- Map filetypes to their respective CLI linters and their parsing logic.
local linters = {
  sh = {
    bin = 'shellcheck',
    -- Note: We use -f json for easier, non-fragile parsing.
    args = { '-f', 'json', '$FILENAME' },
    parser = function(output)
      local diagnostics = {}
      local ok, data = pcall(vim.json.decode, output)
      if ok and data then
        for _, entry in ipairs(data) do
          table.insert(diagnostics, {
            lnum = entry.line - 1,
            col = entry.column - 1,
            end_lnum = entry.endLine - 1,
            end_col = entry.endColumn - 1,
            severity = entry.level == 'error' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            message = entry.message,
            source = 'shellcheck',
          })
        end
      end
      return diagnostics
    end,
  },
  markdown = {
    bin = 'markdownlint-cli2',
    -- Note: markdownlint-cli2 doesn't always support JSON output natively 
    -- without external tools. We parse its default format via regex.
    args = { '$FILENAME' },
    parser = function(output)
      local diagnostics = {}
      -- Safely iterate over lines using Neovim's native split API.
      for _, line in ipairs(vim.split(output, '\n', { trimempty = true })) do
        -- Format: filename:line:column MDXXX/message
        local lnum, col, msg = line:match(':(%d+):(%d+)%s+(.*)')
        if lnum and col then
          table.insert(diagnostics, {
            lnum = tonumber(lnum) - 1,
            col = tonumber(col) - 1,
            severity = vim.diagnostic.severity.WARN,
            message = msg,
            source = 'markdownlint',
          })
        end
      end
      return diagnostics
    end,
  },
}

--- Orchestrates an asynchronous linting run.
--- @param bufnr integer The buffer number to lint.
function M.lint(bufnr)
  local ft = vim.bo[bufnr].filetype
  local config = linters[ft]
  if not config then return end

  -- Resolve binary path via mise shim.
  local bin_path = vim.fn.executable(config.bin) == 1 and config.bin or nil
  if not bin_path then return end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  local args = {}
  for _, arg in ipairs(config.args) do
    if arg == '$FILENAME' then
      table.insert(args, filename)
    else
      table.insert(args, arg)
    end
  end

  -- EXECUTION: Run the linter asynchronously.
  -- Why: Running it asynchronously ensures that the UI remains completely 
  -- fluid while the linter runs in the background. Even slow linters 
  -- won't cause "micro-stuttering" during editing.
  vim.system({ bin_path, unpack(args) }, { text = true }, function(obj)
    local stdout = obj.stdout or ''
    local stderr = obj.stderr or ''
    local output = stdout ~= '' and stdout or stderr

    -- Inject diagnostics back into the Neovim event loop.
    -- Why: vim.diagnostic.set must be called on the main thread. If we called 
    -- it from inside this async callback directly, Neovim might crash or 
    -- behave unpredictably.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local diagnostics = config.parser(output)
      vim.diagnostic.set(ns, bufnr, diagnostics)
    end)
  end)
end

-- [[ Automated Orchestration ]]
-- Hook into the Neovim event loop directly on BufWritePost.
-- This ensures that linting only runs when the file is on disk and stable.
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('native-lint', { clear = true }),
  callback = function(args)
    M.lint(args.buf)
  end,
  desc = 'Asynchronously lint buffer on save using native APIs',
})

return M
