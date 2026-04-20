-- =============================================================================
-- [ WHICH-KEY ]
-- Displays a popup with available keybindings for the current mode/prefix.
-- =============================================================================

local M = {}

local mini = Config.safe_require "plugins.mini"

mini.later(function()
  require("which-key").setup {
    preset = "helix",
    spec = {
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

      -- Expanders for built-in info
      {
        "<leader>b", group = "buffer", icon = "",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
      {
        "<leader>w", group = "window", icon = "",
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
          require("which-key").show { global = false }
        end,
        desc = "Buffer Local Keymaps",
        icon = "󰈔",
      },

      -- Text Objects (mini.ai support)
      {
        mode = { "o", "x" },
        { "a", group = "around" },
        { "i", group = "inside" },
      },
    },
  }
end)

return M
