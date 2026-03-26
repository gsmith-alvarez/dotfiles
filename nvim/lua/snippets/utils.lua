local M = {}

---Check if the cursor is inside a Treesitter node of a given type
---@param types string|table Node type(s) to check for
---@return boolean
function M.in_ts_node(types)
    if type(types) == "string" then
        types = { types }
    end
    local has_ts, ts = pcall(require, "vim.treesitter")
    if not has_ts then
        return false
    end

    local node = ts.get_node()
    while node do
        if vim.tbl_contains(types, node:type()) then
            return true
        end
        node = node:parent()
    end
    return false
end

---Check if cursor is in a comment
function M.in_comment()
    return M.in_ts_node({ "comment", "line_comment", "block_comment" })
end

---Check if cursor is in a string
function M.in_string()
    return M.in_ts_node({ "string", "string_content" })
end

---Check if cursor is in a math zone (Markdown/LaTeX)
function M.in_mathzone()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1] - 1, pos[2]
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if line then
        local sub_line = line:sub(1, col)
        local i = #sub_line
        local brace_count = 0
        while i > 0 do
            local c = sub_line:sub(i, i)
            if c == '}' then
                brace_count = brace_count + 1
            elseif c == '{' then
                if brace_count > 0 then
                    brace_count = brace_count - 1
                else
                    local before = sub_line:sub(1, i - 1)
                    if before:match("\\text%s*$") or before:match("\\intertext%s*$") then
                        return false
                    end
                    local cmd = before:match("\\text(%a+)%s*$")
                    if cmd then
                        local text_cmds = { bf=true, it=true, rm=true, sf=true, tt=true, sc=true, sl=true, up=true, md=true, normal=true }
                        if text_cmds[cmd] then
                            return false
                        end
                    end
                end
            end
            i = i - 1
        end
    end

    local has_ts, ts = pcall(require, "vim.treesitter")
    if has_ts then
        local node = ts.get_node()
        while node do
            if node:type() == "text_mode" then
                return false
            end
            if node:type() == "generic_command" or node:type() == "command" then
                local text = vim.treesitter.get_node_text(node, 0)
                if text:match("^\\text") or text:match("^\\intertext") then
                    return false
                end
            end
            if
                vim.tbl_contains({
                    "math_environment",
                    "latex_block",
                    "inline_formula",
                    "math",
                    "displayed_equation",
                    "inline_math",
                }, node:type())
            then
                return true
            end
            node = node:parent()
        end
    end

    -- Fallback for Markdown: manually count $ signs if TS doesn't catch it
    if vim.bo.filetype == "markdown" then
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1] - 1, pos[2]
        local lines = vim.api.nvim_buf_get_lines(0, 0, row + 1, false)
        if #lines == 0 then return false end
        lines[#lines] = lines[#lines]:sub(1, col)

        local display_math = false
        local inline_math = false

        for _, line in ipairs(lines) do
            inline_math = false
            line = line:gsub("\\%$", "  ")
            line = line:gsub("`[^`]*`", function(m) return string.rep(" ", #m) end)
            
            local idx = 1
            while idx <= #line do
                if line:sub(idx, idx + 1) == "$$" then
                    if not inline_math then display_math = not display_math end
                    idx = idx + 2
                elseif line:sub(idx, idx) == "$" then
                    if not display_math then inline_math = not inline_math end
                    idx = idx + 1
                else
                    idx = idx + 1
                end
            end
        end
        return display_math or inline_math
    end

    return false
end

M.not_in_mathzone = function() return not M.in_mathzone() end
M.not_in_comment = function() return not M.in_comment() end
M.not_in_string = function() return not M.in_string() end

return M
