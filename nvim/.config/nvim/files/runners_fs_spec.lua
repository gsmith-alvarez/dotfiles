-- tests/build/runners_fs_spec.lua
--
-- Filesystem-dependent tests for build.runners.
-- Each test creates a real tmpdir, places marker files inside it, then
-- asserts that runners.build() returns the project-level command rather
-- than the single-file fallback.
--
-- These tests are kept separate from runners_spec.lua so the pure unit
-- tests never need disk I/O.
--
-- Run:
--   nvim --headless --cmd "set rtp+=lua" -l tests/build/runners_fs_spec.lua
-- Or:
--   ./tests/run_tests.sh runners_fs

package.path = package.path
  .. ";tests/support/?.lua"
  .. ";tests/?.lua"

local busted    = require("busted")
local describe  = busted.describe
local it        = busted.it
local before_each = busted.before_each
local after_each  = busted.after_each
local assert    = require("luassert")

assert.is_not_nil(vim, "Must be run inside Neovim headless")

local h       = require("support.helpers")
local runners

-- We need a real readable source file in our tmpdir for the C/C++ tests.
local FAKE_SRC = {
  c   = "main.c",
  cpp = "main.cpp",
}

-- Reusable tmpdir; created/destroyed around each test that needs it.
local tmpdir

before_each(function()
  package.loaded["build.runners"] = nil
  runners = require("build.runners")
  tmpdir  = h.mktmpdir()
end)

after_each(function()
  if tmpdir then h.rm_tmpdir(tmpdir) end
end)

-- ---------------------------------------------------------------------------

describe("build.runners (filesystem)", function()

  -- -------------------------------------------------------------------------
  describe("go: go.mod detection", function()

    it("uses 'go run .' when go.mod exists in root", function()
      h.touch(tmpdir, "go.mod")
      local cmd = runners.build("go", { file = tmpdir .. "/main.go", root = tmpdir })
      assert.equals("go run .", cmd)
    end)

    it("uses 'go run <file>' when go.mod is absent", function()
      local file = tmpdir .. "/main.go"
      local cmd = runners.build("go", { file = file, root = tmpdir })
      h.assert_contains(cmd, "go run")
      h.assert_contains(cmd, vim.fn.shellescape(file))
      h.assert_not_contains(cmd, "go run .")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("zig: build.zig detection", function()

    it("uses 'zig build run' when build.zig exists", function()
      h.touch(tmpdir, "build.zig")
      local cmd = runners.build("zig", { file = tmpdir .. "/main.zig", root = tmpdir })
      assert.equals("zig build run", cmd)
    end)

    it("uses 'zig run <file>' when build.zig is absent", function()
      local file = tmpdir .. "/main.zig"
      local cmd = runners.build("zig", { file = file, root = tmpdir })
      h.assert_contains(cmd, "zig run")
      h.assert_contains(cmd, vim.fn.shellescape(file))
      h.assert_not_contains(cmd, "zig build run")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("rust: Cargo.toml detection", function()

    it("uses 'cargo run -q' when Cargo.toml exists", function()
      h.touch(tmpdir, "Cargo.toml")
      local cmd = runners.build("rust", { file = tmpdir .. "/main.rs", root = tmpdir })
      assert.equals("cargo run -q", cmd)
    end)

    it("uses rustc fallback when Cargo.toml is absent", function()
      local file = tmpdir .. "/main.rs"
      local cmd = runners.build("rust", { file = file, root = tmpdir })
      h.assert_contains(cmd, "rustc")
      h.assert_not_contains(cmd, "cargo")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("c: Makefile detection", function()

    it("uses 'make' when Makefile exists", function()
      h.touch(tmpdir, "Makefile")
      local src = tmpdir .. "/" .. FAKE_SRC.c
      h.touch(tmpdir, FAKE_SRC.c)
      local cmd = runners.build("c", { file = src, root = tmpdir })
      assert.equals("make", cmd)
    end)

    it("Makefile takes priority over CMakeLists.txt", function()
      h.touch(tmpdir, "Makefile")
      h.touch(tmpdir, "CMakeLists.txt")
      local src = tmpdir .. "/" .. FAKE_SRC.c
      h.touch(tmpdir, FAKE_SRC.c)
      local cmd = runners.build("c", { file = src, root = tmpdir })
      assert.equals("make", cmd)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("c: CMakeLists.txt detection", function()

    it("uses 'cmake --build build' when CMakeLists.txt exists and no Makefile", function()
      h.touch(tmpdir, "CMakeLists.txt")
      local src = tmpdir .. "/" .. FAKE_SRC.c
      h.touch(tmpdir, FAKE_SRC.c)
      local cmd = runners.build("c", { file = src, root = tmpdir })
      assert.equals("cmake --build build", cmd)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("c: zig wrapper fallback (no project files)", function()

    it("uses zig wrapper for a real readable C file", function()
      local src = tmpdir .. "/" .. FAKE_SRC.c
      h.touch(tmpdir, FAKE_SRC.c)
      local cmd = runners.build("c", { file = src, root = tmpdir })
      h.assert_contains(cmd, "zig run")
      h.assert_contains(cmd, "-std=c23")
    end)

    it("returns nil + error for unreadable file with no project markers", function()
      local missing = tmpdir .. "/ghost.c"
      -- We do NOT create this file
      h.assert_runner_error("c", { file = missing, root = tmpdir }, "not readable")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("cpp: Makefile detection", function()

    it("uses 'make' when Makefile exists", function()
      h.touch(tmpdir, "Makefile")
      local src = tmpdir .. "/" .. FAKE_SRC.cpp
      h.touch(tmpdir, FAKE_SRC.cpp)
      local cmd = runners.build("cpp", { file = src, root = tmpdir })
      assert.equals("make", cmd)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("cpp: CMakeLists.txt detection", function()

    it("uses 'cmake --build build' when CMakeLists.txt exists and no Makefile", function()
      h.touch(tmpdir, "CMakeLists.txt")
      local src = tmpdir .. "/" .. FAKE_SRC.cpp
      h.touch(tmpdir, FAKE_SRC.cpp)
      local cmd = runners.build("cpp", { file = src, root = tmpdir })
      assert.equals("cmake --build build", cmd)
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("cpp: zig wrapper fallback", function()

    it("uses zig wrapper for a real readable C++ file", function()
      local src = tmpdir .. "/" .. FAKE_SRC.cpp
      h.touch(tmpdir, FAKE_SRC.cpp)
      local cmd = runners.build("cpp", { file = src, root = tmpdir })
      h.assert_contains(cmd, "zig run")
      h.assert_contains(cmd, "-std=c++23")
      h.assert_contains(cmd, "-lc++")
    end)

    it("returns nil + error for unreadable file with no project markers", function()
      local missing = tmpdir .. "/ghost.cpp"
      h.assert_runner_error("cpp", { file = missing, root = tmpdir }, "not readable")
    end)

  end)

  -- -------------------------------------------------------------------------
  describe("root = nil guards (has_file safety)", function()
    -- All project-marker checks must no-op gracefully when root is nil.
    -- This guards against any future regression where nil root causes an error.

    local single_file_fts = {
      { ft = "go",   file = "/tmp/main.go"  },
      { ft = "zig",  file = "/tmp/main.zig" },
      { ft = "rust", file = "/tmp/main.rs"  },
    }

    for _, tc in ipairs(single_file_fts) do
      it(("ft=%s with root=nil returns a string, not an error"):format(tc.ft), function()
        local cmd, err = runners.build(tc.ft, { file = tc.file, root = nil })
        assert.is_nil(err,  ("Expected no error for ft=%s root=nil"):format(tc.ft))
        assert.is_string(cmd, ("Expected string cmd for ft=%s root=nil"):format(tc.ft))
      end)
    end

  end)

end)
