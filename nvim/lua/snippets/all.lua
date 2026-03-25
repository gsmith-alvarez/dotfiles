-- [[ GLOBAL SNIPPETS: lua/snippets/all.lua ]]
-- These snippets are available in ALL filetypes.
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

local ls = require 'luasnip'
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

return {
	-- todo: annotate something for later
	s('todo', fmt('-- TODO({}): {}', { i(1, 'author'), i(2, 'description') })),

	-- fixme: mark a known issue
	s('fixme', fmt('-- FIXME({}): {}', { i(1, 'author'), i(2, 'issue') })),

	-- date: insert today's date (ISO 8601)
	s('date', {
		t(os.date '%Y-%m-%d'),
	}),

	-- sep: section separator comment
	s('sep', {
		t '-- =============================================================================',
	}),
}
