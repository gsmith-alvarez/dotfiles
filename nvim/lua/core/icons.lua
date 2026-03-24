-- [[ ICONS REGISTRY ]]
-- Purpose: Centralized UI Aesthetics
-- Domain: Visual Identity / NerdFonts
-- Architecture: Static Registry / Single Source of Truth
-- Location: lua/core/icons.lua
--
-- PHILOSOPHY: Visual Consistency
-- This module provides a single source of truth for all icons used across
-- the configuration. By centralizing them, we ensure that blink.cmp, 
-- snacks.picker, and diagnostics all share a unified visual language.
--
-- MAINTENANCE TIPS:
-- 1. If icons appear as squares, ensure you are using a NerdFont.
-- 2. To change an icon globally, update its entry in the tables below.
-- 3. Run `:checkhealth snacks` if icons in the picker are missing.

return {
	misc = {
		dots = '󰇘',
	},
	ft = {
		octo          = ' ',
		gh            = ' ',
		['markdown.gh'] = ' ',
	},
	dap = {
		Stopped             = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
		Breakpoint          = ' ',
		BreakpointCondition = ' ',
		BreakpointRejected  = { ' ', 'DiagnosticError' },
		LogPoint            = '.>',
	},
	diagnostics = {
		Error = ' ',
		Warn  = ' ',
		Hint  = ' ',
		Info  = ' ',
	},
	git = {
		added    = ' ',
		modified = ' ',
		removed  = ' ',
	},
	kinds = {
		Array         = ' ',
		Boolean       = '󰨙 ',
		Class         = ' ',
		Codeium       = '󰘦 ',
		Color         = ' ',
		Control       = ' ',
		Collapsed     = ' ',
		Constant      = '󰏿 ',
		Constructor   = ' ',
		Copilot       = ' ',
		Enum          = ' ',
		EnumMember    = ' ',
		Event         = ' ',
		Field         = ' ',
		File          = ' ',
		Folder        = ' ',
		Function      = '󰊕 ',
		Interface     = ' ',
		Key           = ' ',
		Keyword       = ' ',
		Method        = '󰊕 ',
		Module        = ' ',
		Namespace     = '󰦮 ',
		Null          = ' ',
		Number        = '󰎠 ',
		Object        = ' ',
		Operator      = ' ',
		Package       = ' ',
		Property      = ' ',
		Reference     = ' ',
		Snippet       = '󱄽 ',
		String        = ' ',
		Struct        = '󰆼 ',
		Supermaven    = ' ',
		TabNine       = '󰏚 ',
		Text          = ' ',
		TypeParameter = ' ',
		Unit          = ' ',
		Value         = ' ',
		Variable      = '󰀫 ',
	},
}
