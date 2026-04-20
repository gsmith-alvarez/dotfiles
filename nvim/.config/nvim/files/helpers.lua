-- tests/support/helpers.lua
-- Shared utilities for build.runners specs.
-- Loaded via require("support.helpers") — add tests/ to package.path before
-- requiring this in each spec (see the spec files for how).

local M = {}

-- ---------------------------------------------------------------------------
-- Temporary directory helpers
-- ---------------------------------------------------------------------------

--- Create a temporary directory and return its path.
--- Caller is responsible for cleanup via M.rm_tmpdir(path).
---@return string
function M.mktmpdir()
  local handle = io.popen("mktemp -d")
  assert(handle, "mktemp failed")
  local path = handle:read("*l"):gsub("%s+$", "")
  handle:close()
  return path
end

--- Recursively remove a directory (uses `rm -rf`, test-only, obviously).
---@param path string
function M.rm_tmpdir(path)
  assert(path:match("^/tmp/"), "safety check: only rm paths under /tmp")
  os.execute("rm -rf " .. vim.fn.shellescape(path))
end

--- Touch a file inside dir (creates empty file).
---@param dir string
---@param name string  relative path, e.g. "go.mod" or "sub/Makefile"
function M.touch(dir, name)
  local full = dir .. "/" .. name
  -- Ensure parent dirs exist
  local parent = full:match("^(.+)/[^/]+$")
  if parent then os.execute("mkdir -p " .. vim.fn.shellescape(parent)) end
  local f = assert(io.open(full, "w"))
  f:close()
end

-- ---------------------------------------------------------------------------
-- Assertion helpers
-- ---------------------------------------------------------------------------

--- Assert cmd contains the expected substring and error clearly if not.
---@param cmd string
---@param expected string
---@param label string?  human-readable context
function M.assert_contains(cmd, expected, label)
  local ctx = label and (" [" .. label .. "]") or ""
  assert(
    cmd:find(expected, 1, true),
    ("Expected command%s to contain %q\n  Got: %s"):format(ctx, expected, cmd)
  )
end

--- Assert cmd does NOT contain substring.
---@param cmd string
---@param unexpected string
---@param label string?
function M.assert_not_contains(cmd, unexpected, label)
  local ctx = label and (" [" .. label .. "]") or ""
  assert(
    not cmd:find(unexpected, 1, true),
    ("Expected command%s NOT to contain %q\n  Got: %s"):format(ctx, unexpected, cmd)
  )
end

--- Assert a runner call failed with an error message containing `expected`.
---@param ft string
---@param ctx table
---@param expected_err string
function M.assert_runner_error(ft, ctx, expected_err)
  local runners = require("build.runners")
  local cmd, err = runners.build(ft, ctx)
  assert(cmd == nil, ("Expected nil cmd for ft=%s, got: %s"):format(ft, tostring(cmd)))
  assert(err ~= nil, ("Expected error string for ft=%s, got nil"):format(ft))
  assert(
    err:find(expected_err, 1, true),
    ("Expected error for ft=%s to contain %q\n  Got: %s"):format(ft, expected_err, err)
  )
end

return M
