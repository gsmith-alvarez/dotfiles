-- =============================================================================
-- [ PLUGIN KEYMAPS ]
-- Keybindings that specifically target and require external plugins.
-- =============================================================================
local u = Config.safe_require "core.utils"
local snacks = require "snacks"

-- 1. [ MINI.FILES ]
u.nmap("-", function()
  local mf = require "mini.files"
  if not mf.close() then
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" or path:match "^minifiles://" then
      path = vim.fn.getcwd()
    elseif vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
      path = vim.fn.fnamemodify(path, ":p:h")
      if vim.fn.isdirectory(path) == 0 then
        path = vim.fn.getcwd()
      end
    end
    mf.open(path)
  end
end, "Explore: File Tree (toggle)")

-- 2. [ SNACKS: FIND (LEADER F) ]
-- History & Meta
u.nmap("<leader>f/", function() snacks.picker.search_history() end, "Search History")
u.nmap("<leader>f:", function() snacks.picker.command_history() end, "Command History")
u.nmap("<leader>fr", function() snacks.picker.resume() end, "Resume Last Search")

-- Buffers & Files
u.nmap("<leader>fb", function() snacks.picker.buffers() end, "Find Buffers")
u.nmap("<leader>ff", function() snacks.picker.files() end, "Find Files")
u.nmap("<leader>fg", function() snacks.picker.git_files() end, "Find Git Files")
u.nmap("<leader>fp", function() snacks.picker.projects() end, "Find Projects")
u.nmap("<leader>fz", function() snacks.picker.zoxide() end, "Find Zoxide Path")

-- 3. [ SNACKS: SEARCH (LEADER S) ]
-- Code & Symbols
u.nmap("<leader>ss", function() snacks.picker.lsp_symbols() end, "Search Symbols (document)")
u.nmap("<leader>sS", function() snacks.picker.lsp_workspace_symbols() end, "Search Symbols (workspace)")
u.nmap("<leader>sw", function() snacks.picker.grep_word() end, "Search Word (CWD)")
u.nmap("<leader>st", function() snacks.picker.treesitter() end, "Search Treesitter")

-- Diagnostics
u.nmap("<leader>sd", function() snacks.picker.diagnostics() end, "Search Diagnostics (workspace)")
u.nmap("<leader>sD", function() snacks.picker.diagnostics_buffer() end, "Search Diagnostics (buffer)")

-- UI & Meta
u.nmap("<leader>sh", function() snacks.picker.help() end, "Search Help Tags")
u.nmap("<leader>sH", function() snacks.picker.highlights() end, "Search Highlight Groups")
u.nmap("<leader>su", function() snacks.picker.undo() end, "Search Undo History")
u.nmap("<leader>sk", function() snacks.picker.keymaps({ layout = { preset = "vscode" } }) end, "Search Keymaps")
u.nmap("<leader>sj", function() snacks.picker.jumps() end, "Search Jumps")
u.nmap("<leader>sq", function() snacks.picker.qflist() end, "Search Quickfix List")
u.nmap("<leader>sl", function() snacks.picker.loclist() end, "Search Location List")
u.nmap("<leader>sm", function() snacks.picker.marks() end, "Search Marks")
u.nmap("<leader>si", function() snacks.picker.icons() end, "Search Icons")
u.nmap("<leader>sn", function() snacks.picker.notifications() end, "Search Notifications")
u.nmap("<leader>sM", function() snacks.picker.man() end, "Search Manuals")
u.nmap("<leader>sc", function() snacks.picker.cliphist() end, "Search Clipboard")

-- 4. [ SNACKS: EXPLORE (LEADER E) ]
u.nmap("<leader>ed", function() snacks.explorer() end, "Directory (CWD)")
u.nmap("<leader>ef", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, "File directory")
u.nmap("<leader>ei", "<Cmd>edit $MYVIMRC<CR>", "Edit init.lua")
u.nmap("<leader>ec", function()
  snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, "Find Config File")
u.nmap("<leader>ep", function()
  require("mini.files").open(vim.fn.stdpath("data") .. "/site/pack/core/opt")
end, "Explore Plugins")

-- UI Lists
u.nmap("<leader>eq", function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
end, "Quickfix List (toggle)")
u.nmap("<leader>eQ", function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
end, "Location List (toggle)")

-- 5. [ EXECUTE (LEADER X) ]
u.nmap("<leader>xx", "<Cmd>Run<CR>", "Execute: Smart Run")
u.nmap("<leader>xw", "<Cmd>RunWatch<CR>", "Execute: Smart Run (watch)")

-- 6. [ GIT (LEADER G) ]
u.nmap("<leader>gs", function() snacks.picker.git_status() end, "Git Status")
u.nmap("<leader>gb", function() snacks.picker.git_branches() end, "Git Branches")
u.nmap("<leader>gg", function() snacks.lazygit() end, "Lazygit")
u.map({ "n", "v" }, "<leader>gB", function() snacks.gitbrowse() end, "Git Browse")
-- Git Log
u.nmap("<leader>gl", function() snacks.picker.git_log() end, "Git Log (all)")
u.nmap("<leader>gL", function() snacks.picker.git_log_file() end, "Git Log (buffer)")
-- Git Hunks
u.nmap("<leader>gha", function() snacks.picker.git_diff({ staged = true }) end, "Added Hunks (staged)")
u.nmap("<leader>ghm", function() snacks.picker.git_diff() end, "Modified Hunks (workspace)")
u.nmap("<leader>ghM", function() snacks.picker.git_diff({ path = "%" }) end, "Modified Hunks (buffer)")
u.nmap("<leader>ghd", function() snacks.picker.git_diff() end, "Git Diff (Hunks)")

-- 7. [ TOP-LEVEL UTILS ]
u.nmap("<leader><space>", function() snacks.picker.smart() end, "Smart Find Files")
u.nmap("<leader>/", function() snacks.picker.grep() end, "Global Grep")
u.nmap("<leader>n", function() snacks.notifier.show_history() end, "Notification History")
u.nmap("<leader>.", function() snacks.scratch() end, "Toggle Scratch Buffer")
u.nmap("<leader>S", function() snacks.scratch.select() end, "Select Scratch Buffer")

-- 8. [ NAVIGATION & LSP ]
u.nmap("gd", function() snacks.picker.lsp_definitions() end, "LSP: Definitions")
u.nmap("gr", function() snacks.picker.lsp_references() end, "LSP: References")
u.nmap("gy", function() snacks.picker.lsp_type_definitions() end, "LSP: Type Definitions")
u.nmap("<C-/>", function() snacks.terminal() end, "Toggle Terminal")

-- Reference Navigation
u.map({ "n", "t" }, "]]", function() snacks.words.jump(vim.v.count1) end, "Next Reference")
u.map({ "n", "t" }, "[[", function() snacks.words.jump(-vim.v.count1) end, "Prev Reference")
