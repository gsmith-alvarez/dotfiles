-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"
local icons = Config.safe_require("mini.icons")
local wk = Config.safe_require("which-key")

mini.later(function()
  wk.setup {
    preset = "helix",
  }
  wk.add {
    -- Top level groups
    { "<leader><tab>", group = "Tabs", icon = icons.get("lsp", "class") },
    { "<leader>c", group = "Code", icon = icons.get("lsp", "function") },
    { "<leader>d", group = "Debug", icon = icons.get("lsp", "event") },
    { "<leader>dp", group = "Debug Profiler", icon = icons.get("lsp", "event") },
    { "<leader>e", group = "Explore", icon = icons.get("directory", "index") },
    { "<leader>f", group = "Find", icon = icons.get("lsp", "reference") },
    { "<leader>g", group = "Git", icon = icons.get("filetype", "git") },
    { "<leader>gh", group = "Git Hunk", icon = icons.get("lsp", "event") },
    { "<leader>o", group = "Obsidian", icon = icons.get("filetype", "markdown") },
    { "<leader>q", group = "Quit/Session", icon = icons.get("os", "exit") },
    { "<leader>p", group = "Profiler", icon = icons.get("lsp", "event") },
    { "<leader>s", group = "Search", icon = icons.get("lsp", "snippet") },
    { "<leader>u", group = "UI", icon = icons.get("lsp", "interface") },
    { "<leader>x", group = "Execute", icon = icons.get("lsp", "method") },

    { "s", group = "surround", icon = icons.get("lsp", "operator") },
    { "sa", desc = "Add" },
    { "sd", desc = "Delete" },
    { "sr", desc = "Replace" },
    { "sf", desc = "Find right" },
    { "sF", desc = "Find left" },
    { "sh", desc = "Highlight" },
    { "sn", desc = "Update next" },
    { "sl", desc = "Update last" },

    -- Bracket Navigation (mini.bracketed)
    { "[", group = "prev", icon = icons.get("lsp", "variable") },
    { "]", group = "next", icon = icons.get("lsp", "variable") },
    { "g", group = "goto", icon = icons.get("lsp", "method") },
    { "z", group = "fold", icon = icons.get("lsp", "operator") },
    { "[b", desc = "Buffer" },
    { "]b", desc = "Buffer" },
    { "[d", desc = "Diagnostic" },
    { "]d", desc = "Diagnostic" },
    { "[f", desc = "File" },
    { "]f", desc = "File" },
    { "[q", desc = "Quickfix" },
    { "]q", desc = "Quickfix" },

    -- Expanders for built-in info
    {
      "<leader>b",
      group = "buffer",
      icon = icons.get("file", "file"),
      expand = function()
        return require("which-key.extras").expand.buf()
      end,
    },
    {
      "<leader>w",
      group = "window",
      icon = icons.get("os", "windows"),
      expand = function()
        return require("which-key.extras").expand.win()
      end,
    },

    -- Single Key Overrides
    { "<leader><space>", desc = "Find: Smart Files", icon = icons.get("lsp", "constant") },
    { "<leader>/", desc = "Search: Global Grep", icon = icons.get("lsp", "keyword") },
    { "<leader>n", desc = "Notify: Show History", icon = icons.get("lsp", "event") },
    { "<leader>.", desc = "Scratch: Toggle Buffer", icon = icons.get("lsp", "snippet") },
    { "<leader>S", desc = "Scratch: Select Buffer", icon = icons.get("lsp", "snippet") },
    { "gx", desc = "Open with system app", icon = icons.get("lsp", "keyword") },

    -- Global/Local help
    {
      "<leader>?",
      function()
        wk.show { global = false }
      end,
      desc = "Buffer Local Keymaps",
      icon = icons.get("file", "info"),
    },

    -- Text Objects (mini.ai support)
    {
      mode = { "o", "x" },
      { "a", group = "around", icon = icons.get("lsp", "class") },
      { "i", group = "inside", icon = icons.get("lsp", "class") },
      { "g", group = "goto", icon = icons.get("lsp", "method") },
      { "gg", desc = "first line" },
      { "ge", desc = "prev word end" },
      { "gE", desc = "prev WORD end" },
      { "g_", desc = "last char" },
      { "g,", desc = "next change" },
      { "g;", desc = "prev change" },
      { "s", group = "surround", icon = icons.get("lsp", "operator") },
      { "as", desc = "around surround" },
      { "is", desc = "inside surround" },
      { "[", group = "prev", icon = icons.get("lsp", "variable") },
      { "[b", desc = "buffer" },
      { "[d", desc = "diagnostic" },
      { "[q", desc = "quickfix" },
      { "]", group = "next", icon = icons.get("lsp", "variable") },
      { "]b", desc = "buffer" },
      { "]d", desc = "diagnostic" },
      { "]q", desc = "quickfix" },
      { "at", desc = "tag" },
      { "it", desc = "tag" },
      { "af", desc = "function" },
      { "if", desc = "function" },
      { "ao", desc = "block" },
      { "io", desc = "block" },
      { "aa", desc = "argument" },
      { "ia", desc = "argument" },
    },
    -- Jump Navigation (Snacks Words)
    { "[[", desc = "Prev Reference" },
    { "]]", desc = "Next Reference" },

    -- LSP: Builtin gr* group
    { "gr",  group = "LSP Builtin",                   icon = icons.get("lsp", "method") },
    { "grn", desc = "Rename" },
    { "gra", desc = "Code Action",    mode = { "n", "x" } },
    { "grr", desc = "References" },
    { "gri", desc = "Implementation" },
    { "grt", desc = "Type Definition" },
    { "grx", desc = "CodeLens Run" },
    { "grd", desc = "Declaration" },
    { "gO",  desc = "Document Symbols" },

    -- LSP: Picker gp* group
    { "gp",  group = "LSP Picker",                     icon = icons.get("lsp", "method") },
    { "gpd", desc = "Definition" },
    { "gpr", desc = "References" },
    { "gpt", desc = "Type Definition" },
    { "gpi", desc = "Implementation" },
    { "gpO", desc = "Document Symbols" },
  }

	vim.keymap.set("n", "<C-w><space>", function()
		wk.show({ keys = "<c-w>", loop = true })
	end, { desc = "Window Hydra Mode (which-key)" })
end)

return M
