-- tests/build/runners_spec.lua
--
-- Unit tests for build.runners.
-- All tests operate on the return value of runners.build(ft, ctx) — a plain
-- string — so there is no side-effect to clean up.
--
-- Run via:
--   nvim --headless --cmd "set rtp+=lua" -l tests/build/runners_spec.lua
-- Or via the test runner:
--   ./tests/run_tests.sh runners_spec

-- Inject support/ into Lua path so require("support.helpers") works.
package.path = package.path
  .. ";tests/support/?.lua"
  .. ";tests/?.lua"

local busted = require("busted")
local describe = busted.describe
local it       = busted.it
local before_each = busted.before_each
local assert   = require("luassert")

-- Make sure the real vim.* is available (we're running inside Neovim headless).
assert.is_not_nil(vim, "Must be run inside Neovim headless — vim global missing")

local h       = require("support.helpers")
local runners -- loaded fresh in before_each to avoid module-cache bleed

-- A synthetic absolute path that exists on any machine.
local FAKE_FILE = "/tmp/test_runner_file.lua"
local FAKE_ROOT = "/tmp/fake_project"

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Build ctx for a filetype with a fake file and no project root.
---@param ft string
---@param file string?
---@return table
local function ctx_noroot(ft, file)
  return { file = file or FAKE_FILE, root = nil }
end

--- Build ctx for a filetype with a fake project root (no marker files).
---@param ft string
---@param file string?
---@return table
local function ctx_root(ft, file)
  return { file = file or FAKE_FILE, root = FAKE_ROOT }
end

-- ---------------------------------------------------------------------------
-- Specs
-- ---------------------------------------------------------------------------

describe("build.runners", function()

  before_each(function()
    -- Clear module cache so each describe block starts clean.
    package.loaded["build.runners"] = nil
    runners = require("build.runners")
  end)

  -- -------------------------------------------------------------------------
  describe("M.has(ft)", function()

    it("returns true for every supported filetype", function()
      local supported = { "python", "go", "zig", "lua", "sh", "bash", "rust", "c", "cpp" }
      for _, ft in ipairs(supported) do
        assert.is_true(runners.has(ft), "has() returned false for ft=" .. ft)
      end
    end)

    it("returns false for unknown filetypes", function()
      local unknown = { "javascript", "typescript", "haskell", "nix", "" }
      for _, ft in ipairs(unknown) do
        assert.is_false(runners.has(ft), "has() returned true for ft=" .. ft)
      end
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("M.build() unknown filetype", function()

    it("returns nil, err for an unrecognised filetype", function()
      local cmd, err = runners.build("javascript", ctx_noroot("javascript"))
      assert.is_nil(cmd)
      assert.is_not_nil(err)
      h.assert_contains(err, "javascript")
    end)

    it("error message mentions the filetype", function()
      local _, err = runners.build("haskell", ctx_noroot("haskell"))
      h.assert_contains(err, "haskell")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("python runner", function()

    it("uses uv run with the escaped file path", function()
      local file = "/home/gio/project/script.py"
      local cmd = assert.is_not_nil(runners.build("python", ctx_noroot("python", file)))
      h.assert_contains(cmd, "uv run")
      h.assert_contains(cmd, vim.fn.shellescape(file))
    end)

    it("does not reference the root at all", function()
      local cmd = runners.build("python", ctx_root("python"))
      h.assert_not_contains(cmd, FAKE_ROOT)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("go runner", function()

    it("uses 'go run .' when root is nil (no go.mod check possible)", function()
      -- root=nil means has_file(nil, ...) is always false → single-file path
      local cmd = runners.build("go", ctx_noroot("go"))
      h.assert_contains(cmd, "go run")
      -- Single-file path should NOT be "go run ."
      h.assert_not_contains(cmd, "go run .")
    end)

    it("uses 'go run <file>' when root has no go.mod", function()
      -- FAKE_ROOT exists but has no go.mod inside it
      local cmd = runners.build("go", ctx_root("go", "/tmp/main.go"))
      h.assert_contains(cmd, "go run")
      h.assert_contains(cmd, vim.fn.shellescape("/tmp/main.go"))
    end)

    -- go.mod case is tested in runners_fs_spec.lua where we create a real file

  end)

  -- -------------------------------------------------------------------------
  describe("zig runner", function()

    it("uses 'zig run <file>' when no build.zig present", function()
      local file = "/tmp/hello.zig"
      local cmd = runners.build("zig", { file = file, root = nil })
      h.assert_contains(cmd, "zig run")
      h.assert_contains(cmd, vim.fn.shellescape(file))
    end)

    -- build.zig case is tested in runners_fs_spec.lua

  end)

  -- -------------------------------------------------------------------------
  describe("lua runner", function()

    it("uses 'nvim -l' with the file path", function()
      local file = "/tmp/test.lua"
      local cmd = runners.build("lua", ctx_noroot("lua", file))
      h.assert_contains(cmd, "nvim -l")
      h.assert_contains(cmd, vim.fn.shellescape(file))
    end)

    it("redirects stderr to stdout", function()
      local cmd = runners.build("lua", ctx_noroot("lua"))
      h.assert_contains(cmd, "2>&1")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("sh / bash runner", function()

    it("sh: uses bash with the file path", function()
      local file = "/tmp/test.sh"
      local cmd = runners.build("sh", ctx_noroot("sh", file))
      h.assert_contains(cmd, "bash")
      h.assert_contains(cmd, vim.fn.shellescape(file))
    end)

    it("bash: same as sh", function()
      local file = "/tmp/test.bash"
      local cmd = runners.build("bash", ctx_noroot("bash", file))
      h.assert_contains(cmd, "bash")
      h.assert_contains(cmd, vim.fn.shellescape(file))
    end)

    it("sh and bash produce equivalent commands for the same file", function()
      local file = "/tmp/script.sh"
      local sh_cmd   = runners.build("sh",   { file = file, root = nil })
      local bash_cmd = runners.build("bash", { file = file, root = nil })
      assert.equals(sh_cmd, bash_cmd)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("rust runner", function()

    it("uses rustc + tmp binary when no Cargo.toml present", function()
      local file = "/tmp/main.rs"
      local cmd = runners.build("rust", { file = file, root = nil })
      h.assert_contains(cmd, "rustc")
      h.assert_contains(cmd, vim.fn.shellescape(file))
      -- Must compile then run with &&
      h.assert_contains(cmd, "&&")
    end)

    it("tmp binary path is under /tmp", function()
      local cmd = runners.build("rust", { file = "/tmp/hello.rs", root = nil })
      h.assert_contains(cmd, "/tmp/")
    end)

    it("does not produce nested bash -c wrappers", function()
      local cmd = runners.build("rust", { file = "/tmp/hello.rs", root = nil })
      -- The rust runner itself must NOT wrap in bash -c — the executor does that
      h.assert_not_contains(cmd, "bash -c")
    end)

    -- cargo run case tested in runners_fs_spec.lua (needs real Cargo.toml)

  end)

  -- -------------------------------------------------------------------------
  describe("c runner (no project files)", function()

    it("returns nil + error when file is unreadable and no Makefile/CMake", function()
      local missing = "/tmp/definitely_does_not_exist_xyzzy.c"
      h.assert_runner_error("c", { file = missing, root = nil }, "not readable")
    end)

    it("error message contains the file path", function()
      local missing = "/tmp/ghost.c"
      local _, err = runners.build("c", { file = missing, root = nil })
      h.assert_contains(err, missing)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("cpp runner (no project files)", function()

    it("returns nil + error when file is unreadable and no Makefile/CMake", function()
      local missing = "/tmp/definitely_does_not_exist_xyzzy.cpp"
      h.assert_runner_error("cpp", { file = missing, root = nil }, "not readable")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("c runner zig wrapper (readable file)", function()
    -- We use an existing file. /etc/hostname is always readable on Linux.
    -- We only care about command shape, not that it compiles.
    local READABLE = "/etc/hostname"

    it("uses zig run as the compiler", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_contains(cmd, "zig run")
    end)

    it("passes -std=c23 flag", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_contains(cmd, "-std=c23")
    end)

    it("passes -Wall -Wextra -O2 -Werror", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_contains(cmd, "-Wall")
      h.assert_contains(cmd, "-Wextra")
      h.assert_contains(cmd, "-O2")
      h.assert_contains(cmd, "-Werror")
    end)

    it("passes -lc link flag", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_contains(cmd, "-lc")
    end)

    it("does NOT pass -lc++ for C", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_not_contains(cmd, "-lc++")
    end)

    it("includes the source file path", function()
      local cmd = runners.build("c", { file = READABLE, root = nil })
      h.assert_contains(cmd, vim.fn.shellescape(READABLE))
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("cpp runner zig wrapper (readable file)", function()
    local READABLE = "/etc/hostname"

    it("uses zig run as the compiler", function()
      local cmd = runners.build("cpp", { file = READABLE, root = nil })
      h.assert_contains(cmd, "zig run")
    end)

    it("passes -std=c++23 flag", function()
      local cmd = runners.build("cpp", { file = READABLE, root = nil })
      h.assert_contains(cmd, "-std=c++23")
    end)

    it("passes -lc++ link flag", function()
      local cmd = runners.build("cpp", { file = READABLE, root = nil })
      h.assert_contains(cmd, "-lc++")
    end)

    it("does NOT pass -std=c23 for C++", function()
      local cmd = runners.build("cpp", { file = READABLE, root = nil })
      -- -std=c23 must not appear; -std=c++23 is fine
      assert.is_nil(cmd:match("-std=c23[^+]"))
    end)

  end)

end)
