-- format

local M = {}

local function apply_lines_diff(buf, new_lines)
    local orig_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if #new_lines == 0 then
        new_lines = { "" }
    end
    if #orig_lines == #new_lines then
        local same = true
        for i = 1, #orig_lines do
            if orig_lines[i] ~= new_lines[i] then
                same = false
                break
            end
        end
        if same then
            return
        end
    end

    local orig_text = table.concat(orig_lines, "\n") .. "\n"
    local new_text = table.concat(new_lines, "\n") .. "\n"
    local hunks = vim.diff(orig_text, new_text, { result_type = "indices" })
    if not hunks or #hunks == 0 then
        return
    end

    local is_curr = (buf == vim.api.nvim_get_current_buf())
    local view = is_curr and vim.fn.winsaveview() or nil

    for i = #hunks, 1, -1 do
        local hunk = hunks[i]
        local start_a, count_a, start_b, count_b = hunk[1], hunk[2], hunk[3], hunk[4]
        local start_idx = (count_a == 0) and start_a or (start_a - 1)
        local end_idx = start_idx + count_a

        local replacement = {}
        if count_b > 0 then
            for j = start_b, start_b + count_b - 1 do
                table.insert(replacement, new_lines[j] or "")
            end
        end
        vim.api.nvim_buf_set_lines(buf, start_idx, end_idx, false, replacement)
    end

    if view then
        vim.fn.winrestview(view)
    end
end

local function format_buffer(ev, cmd)
    local buf = (ev and ev.buf) or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, "\n")
    local ok, result = pcall(function()
        return vim.system(cmd, { stdin = input }):wait()
    end)
    if ok and result and result.code == 0 and result.stdout then
        local new_lines = vim.split(result.stdout, "\n", { plain = true })
        if new_lines[#new_lines] == "" then
            table.remove(new_lines)
        end
        apply_lines_diff(buf, new_lines)
    end
end

M.setup = {
    {
        event = "BufWritePre",
        pattern = "*.lua",
        action = function(ev)
            format_buffer(ev, { "stylua", "-" })
        end,
        desc = "Format Lua with stylua",
    },
    {
        event = "BufWritePre",
        pattern = { "*.sh", "*.bash" },
        action = function(ev)
            format_buffer(ev, { "shfmt", "-" })
        end,
        desc = "Format Shell with shfmt",
    },
    {
        event = "BufWritePre",
        pattern = "*.fish",
        action = function(ev)
            format_buffer(ev, { "fish_indent" })
        end,
        desc = "Format Fish with fish_indent",
    },
    {
        event = "BufWritePre",
        pattern = "*",
        action = function()
            local ft = vim.bo.filetype
            local skip = { lua = true, sh = true, bash = true, fish = true, markdown = true, text = true }
            if not skip[ft] then
                vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
            end
        end,
        desc = "LSP format on save for other filetypes",
    },
}

return M
