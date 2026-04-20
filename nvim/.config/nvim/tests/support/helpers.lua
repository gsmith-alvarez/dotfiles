local M = {}

local function shquote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

function M.ensure_vim_stub()
  if _G.vim ~= nil then
    return
  end

  _G.vim = {
    fn = {
      shellescape = function(s)
        return shquote(s)
      end,
      expand = function(expr)
        if expr == "%:t:r" then
          return "main"
        end
        return ""
      end,
    },
    uv = {
      fs_stat = function(path)
        local f = io.open(path, "r")
        if f then
          f:close()
          return { type = "file" }
        end
        return nil
      end,
      cwd = function()
        local p = io.popen("pwd")
        if not p then
          return "."
        end
        local out = p:read("*l") or "."
        p:close()
        return out
      end,
    },
  }
end

function M.mktmpdir()
  local p = io.popen("mktemp -d")
  assert(p, "mktemp -d failed")
  local dir = (p:read("*l") or ""):gsub("%s+$", "")
  p:close()
  assert(dir ~= "", "mktemp returned empty path")
  return dir
end

function M.rm_tmpdir(path)
  if path and path ~= "" then
    os.execute("rm -rf " .. shquote(path))
  end
end

function M.touch(dir, name)
  local full = dir .. "/" .. name
  local parent = full:match("^(.+)/[^/]+$")
  if parent then
    os.execute("mkdir -p " .. shquote(parent))
  end
  local f = assert(io.open(full, "w"))
  f:close()
  return full
end

function M.assert_contains(haystack, needle, msg)
  assert(haystack:find(needle, 1, true) ~= nil, msg or ("expected substring: " .. needle))
end

function M.assert_not_contains(haystack, needle, msg)
  assert(haystack:find(needle, 1, true) == nil, msg or ("unexpected substring: " .. needle))
end

return M
