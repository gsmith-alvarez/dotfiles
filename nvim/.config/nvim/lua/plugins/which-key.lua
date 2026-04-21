-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"

local wk = require("which-key")

mini.later(function()
  wk.setup {
    preset = "helix",
  }
  wk.add {
    -- Top level groups
    { "<leader>c", group = "Code", icon = "" },
    { "<leader>e", group = "Explore", icon = "󰙅" },
    { "<leader>f", group = "Find", icon = "" },
    { "<leader>g", group = "Git", icon = "󰊢" },
    { "<leader>gh", group = "Git Hunk", icon = "󱖋" },
    { "<leader>q", group = "Quit/Session", icon = "󰗼" },
    { "<leader>s", group = "Search", icon = "󰍉" },
    { "<leader>u", group = "UI", icon = "󰙵" },
    { "<leader>x", group = "Execute", icon = "" },

    { "s", group = "surround", icon = "󰗈" },
    { "sa", desc = "Add" },
    { "sd", desc = "Delete" },
    { "sr", desc = "Replace" },
    { "sf", desc = "Find right" },
    { "sF", desc = "Find left" },
    { "sh", desc = "Highlight" },
    { "sn", desc = "Update next" },
    { "sl", desc = "Update last" },

    -- Bracket Navigation (mini.bracketed)
    { "[", group = "prev", icon = "󰮳" },
    { "]", group = "next", icon = "󰮳" },
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
      icon = "",
      expand = function()
        return require("which-key.extras").expand.buf()
      end,
    },
    {
      "<leader>w",
      group = "window",
      icon = "",
      expand = function()
        return require("which-key.extras").expand.win()
      end,
    },

    -- Single Key Overrides
    { "<leader><space>", icon = "󰈞" },
    { "<leader>/", icon = "󰱽" },

    -- Global/Local help
    {
      "<leader>?",
      function()
        wk.show { global = false }
      end,
      desc = "Buffer Local Keymaps",
      icon = "󰈔",
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
  }
end)

return M
