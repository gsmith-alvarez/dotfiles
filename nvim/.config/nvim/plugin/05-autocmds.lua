-- =============================================================================
-- [ GLOBAL AUTOCOMMANDS ]
-- Event-driven automation and UI enhancements.
-- =============================================================================
local u = Config.safe_require "core.utils"
if not u then
  return
end
-- 1. [ TREESITTER ATTACHMENT ]
-- Automatically start Treesitter highlighting for supported filetypes.
--- @param args table Autocmd callback args.
local treesitter_attach = function(args)
  local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
  if lang then
    pcall(vim.treesitter.start, args.buf, lang)
  end
end
u.autocmd("FileType", "*", treesitter_attach, "Start Treesitter highlighting")
-- 2. [ UI POLISH ]
-- Highlight the text briefly after it is yanked to provide visual feedback.
local highlight_yank = function()
  vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
end
u.autocmd("TextYankPost", "*", highlight_yank, "Highlight yanked text")
-- 3. [ CURSOR PERSISTENCE ]
-- Retains the position of the cursor between Neovim instances.
--- @param args table Autocmd callback args.
local cursor_persist = function(args)
  local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
  local line_count = vim.api.nvim_buf_line_count(args.buf)
  if mark[1] > 0 and mark[1] <= line_count then
    vim.api.nvim_win_set_cursor(0, mark)
    -- Defer centering slightly so it's applied after the buffer renders.
    vim.schedule(function()
      vim.cmd "normal! zz"
    end)
  end
end
u.autocmd("BufReadPost", "*", cursor_persist, "Restore cursor position on file open")
-- 4. [ WINDOW BEHAVIOR ]
-- Ensure help/man files open in a vertical split on the right.
u.autocmd("FileType", { "help", "man" }, function() vim.cmd("wincmd L") end, "Open help/man in a vertical split")

-- Automatically equalize splits when the terminal window is resized.
u.autocmd("VimResized", "*", "wincmd =", "Equalize splits on window resize")
-- 5. [ FILETYPE OVERRIDES ]
-- Force specific highlighting for secret files or configurations.
u.autocmd("BufRead", { ".env", ".env.*" }, function()
  vim.bo.filetype = "dosini"
end, "Syntax highlighting for secret files")
-- 6. [ WHITESPACE MANAGEMENT ]
-- Convert tabs to spaces on save to maintain consistent formatting.
u.autocmd("BufWritePre", "*", "silent! %retab!", "Convert tabs to spaces on save")
-- 7. [ FILESYSTEM HELPERS ]
-- Automatically create parent directories if they don't exist when saving a file.
u.autocmd("BufWritePre", "*", function(event)
  if event.match:match "^%w%w+://" then
    return
  end
  local file = vim.uv.fs_realpath(event.match) or event.match
  local dir = vim.fn.fnamemodify(file, ":p:h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end, "Auto-create parent directories on save")

-- Integrated File Renaming:
-- When a file is renamed via 'mini.files', this hook triggers 'snacks.rename'
-- to automatically update LSP references and imports across the project.
u.autocmd("User", "MiniFilesActionRename", function(event)
  require("snacks").rename.on_rename_file(event.data.from, event.data.to)
end, "Project-aware file renaming (mini.files + snacks.rename)")

-- 8. [ MODULAR REGISTRATION ]
-- Load domain-specific autocommands from the lua/autocmds/ directory.
-- Maintained either for really large commands or for specific categories
local autocmds = Config.safe_require "autocmds"
if not autocmds then
  return
end
autocmds.register "lsp"
autocmds.register "format"
