-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"
local icons = require("mini.icons")

local wk = require("which-key")

mini.later(function()
  wk.setup {
    preset = "helix",
  }
  wk.add {
    -- Top level groups
    { "<leader>c", group = "Code", icon = icons.get("lsp", "function") },
    { "<leader>e", group = "Explore", icon = icons.get("directory", "index") },
    { "<leader>f", group = "Find", icon = icons.get("lsp", "reference") },
    { "<leader>g", group = "Git", icon = icons.get("filetype", "git") },
    { "<leader>gh", group = "Git Hunk", icon = icons.get("lsp", "event") },
    { "<leader>o", group = "Obsidian", icon = icons.get("filetype", "markdown") },
    { "<leader>q", group = "Quit/Session", icon = icons.get("os", "exit") },
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
    { "<leader><space>", icon = icons.get("lsp", "constant") },
    { "<leader>/", icon = icons.get("lsp", "keyword") },

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
      { "a", group = "around" },
      { "i", group = "inside" },
      { "g", group = "goto" },
      { "gg", desc = "first line" },
      { "ge", desc = "prev word end" },
      { "gE", desc = "prev WORD end" },
      { "g_", desc = "last char" },
      { "g,", desc = "next change" },
      { "g;", desc = "prev change" },
      { "s", group = "surround" },
      { "as", desc = "around surround" },
      { "is", desc = "inside surround" },
      { "[", group = "prev" },
      { "[b", desc = "buffer" },
      { "[d", desc = "diagnostic" },
      { "[q", desc = "quickfix" },
      { "]", group = "next" },
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
  }
end)

return M
