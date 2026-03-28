-- [[ BASH SNIPPETS: lua/ssnippets/bash.lua ]]
-- These snippets are available in bash filetypes (those ending in .sh)
-- LuaSnip docs: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
--
-- QUICK REFERENCE:
--   s(trigger, nodes)       -- define a snippet
--   t("text")               -- static text node
--   i(#, "placeholder")     -- insert node (jumpable placeholder)
--   f(fn, refs)             -- function node (computed from other nodes)
--   c(#, choices)           -- choice node (cycle with <C-e>)
--   rep(#)                  -- repeat/mirror another insert node
--   fmt("template", nodes)  -- format-string style (easier to read)
--
-- To add a new snippet: copy any block below and modify trigger + body.
-- Run :LuaSnipListAvailable to verify it's loaded.

local ls  = require 'luasnip'
local s   = ls.s
local t   = ls.t
local i   = ls.i
local f   = ls.f -- You'll need this for the date/filename
local fmt = require('luasnip.extras.fmt').fmt

return {
	-- The Google Style Header
	s('ghdr', fmt([[
#######################################
# {}
# Globals:
#   {}
# Arguments:
#   {}
# Outputs:
#   {}
# Returns:
#   {}
#######################################
]], {
		i(1, 'Description'),
		i(2, 'None'),
		i(3, '$@'),
		i(4, 'None'),
		i(5, '0'),
	})),


	s('bash', t { '#!/usr/bin/env bash', }),

	s('strict', t { 'set -euo pipefail', 'IFS=$\'\\n\\t\'' }),
}
