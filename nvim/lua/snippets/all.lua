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

local ls  = require 'luasnip'
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

return {
	-- todo: annotate something for later (with severity picker)
	s('todo', fmt('-- {}({}): {}', {
		ls.choice_node(1, { t 'TODO', t 'FIXME', t 'BUG', t 'HACK', t 'NOTE' }),
		i(2, 'author'),
		i(3, 'description')
	})),

	-- bool: toggle between true and false
	s('bool', ls.choice_node(1, { t 'true', t 'false' })),


	-- date: insert today's date (YYYY-MM-DD)
	s('date', {
		f(function() return os.date '%Y-%m-%d' end),
	}),

	-- time: insert current timestamp (ISO 8601)
	s('time', {
		f(function() return os.date '%Y-%m-%dT%H:%M:%S%z' end),
	}),

	-- uuid: generate a random UUIDv4 via Lua
	s('uuid', {
		f(function()
			local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
			return string.gsub(template, '[xy]', function(c)
				local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
				return string.format('%x', v)
			end)
		end),
	}),

	-- lorem: quick placeholder text
	s('lorem', {
		t 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
	}),

	-- sep: section separator comment (80 chars)
	s('sep', {
		t '-- =============================================================================',
	}),
}
