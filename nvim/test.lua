vim.cmd('source ~/.config/nvim/init.lua')
-- Wait for a moment to let 'later' tasks run
vim.defer_fn(function()
    local map_gS = vim.fn.maparg('gS', 'n', false, true)
    print("gS mapping in normal mode:")
    print(vim.inspect(map_gS))
    vim.cmd('q!')
end, 1000)
