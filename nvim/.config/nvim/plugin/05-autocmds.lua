-- =============================================================================
-- [ GLOBAL AUTOCOMMANDS ]
-- =============================================================================

-- 1. [ TREESITTER ATTACHMENT ]
-- Automatically start Treesitter highlighting for supported filetypes.
vim.api.nvim_create_autocmd('FileType', {
	desc = 'Automatically start Treesitter highlighting',
	callback = function(args)
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang then
			pcall(vim.treesitter.start, args.buf)
		end
	end,
})

-- 2. [ UI POLISH ]
-- Highlight the text briefly after it is yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight yanked text',
	callback = function()
		vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
	end,
})
