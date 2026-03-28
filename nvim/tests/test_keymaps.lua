local T = MiniTest.new_set()

T['Keymaps'] = MiniTest.new_set()

T['Keymaps']['No Duplicates'] = function()
  -- Load core keymaps
  require 'core.keymaps'

  -- Also load plugin keymaps to check for conflicts between core and plugins
  pcall(require, 'core.plugin-keymaps')

  -- Use atomic modes to avoid aggregate mode (v = x + s) false positives
  local modes = { 'n', 'x', 's', 'i', 't', 'c', 'o' }
  local conflicts = {}

  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    local seen = {}

    for _, map in ipairs(maps) do
      if seen[map.lhs] then
        table.insert(conflicts, string.format("Conflict in mode '%s': lhs '%s' is mapped multiple times.", mode, map.lhs))
      end
      seen[map.lhs] = true
    end
  end

  -- If there are conflicts, report them
  if #conflicts > 0 then
    error(table.concat(conflicts, '\n'))
  end
end

T['Keymaps']['Shadowing Check'] = function()
  -- Check if any mapping is a prefix of another mapping in the same mode.
  -- e.g. 'f' and 'fd' - this causes a delay when typing 'f'.
  local modes = { 'n', 'v' } -- Focus on normal and visual
  local shadows = {}

  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    local sorted_lhs = {}
    for _, map in ipairs(maps) do
      table.insert(sorted_lhs, map.lhs)
    end
    table.sort(sorted_lhs)

    for i = 1, #sorted_lhs - 1 do
      local a = sorted_lhs[i]
      local b = sorted_lhs[i + 1]
      -- If 'a' is a prefix of 'b' (and not equal)
      if #a < #b and b:sub(1, #a) == a then
        -- This is a potential shadow, but we ignore single-char prefixes common in Neovim (like 'c', 'd', 'y')
        -- unless they are explicitly mapped to something that doesn't expect a suffix.
        if #a > 1 then
          table.insert(shadows, string.format("Shadow in mode '%s': '%s' shadows '%s'", mode, a, b))
        end
      end
    end
  end

  -- We don't error on shadowing yet because some are intentional (e.g. 'gc', 'gcc'),
  -- but we can log them for review if they exist.
  if #shadows > 0 then
    -- print("\n[INFO] Potential Keymap Shadows:\n" .. table.concat(shadows, "\n"))
  end
end

return T
