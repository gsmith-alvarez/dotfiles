package.path = package.path
  .. ";./tests/support/?.lua"
  .. ";./lua/?.lua"
  .. ";./lua/?/init.lua"

local h = require("helpers")
h.ensure_vim_stub()

describe("commands.building.runners (pure)", function()
  local runners

  before_each(function()
    package.loaded["commands.building.runners"] = nil
    runners = require("commands.building.runners")
  end)

  it("has() supports expected filetypes", function()
    local supported = { "python", "go", "zig", "lua", "sh", "bash", "rust", "c", "cpp" }
    for _, ft in ipairs(supported) do
      assert.is_true(runners.has(ft), ft)
    end
    assert.is_false(runners.has("javascript"))
  end)

  it("python no-root command shape", function()
    local file = "/tmp/main.py"
    local cmd = runners.build("python", { file = file, root = nil })
    h.assert_contains(cmd, "uv run")
    h.assert_contains(cmd, vim.fn.shellescape(file))
  end)

  it("go no-root falls back to file", function()
    local file = "/tmp/main.go"
    local cmd = runners.build("go", { file = file, root = nil })
    h.assert_contains(cmd, "go run")
    h.assert_contains(cmd, vim.fn.shellescape(file))
    h.assert_not_contains(cmd, "go run .")
  end)

  it("zig no-root falls back to file", function()
    local file = "/tmp/main.zig"
    local cmd = runners.build("zig", { file = file, root = nil })
    h.assert_contains(cmd, "zig run")
    h.assert_contains(cmd, vim.fn.shellescape(file))
  end)

  it("lua uses nvim -l with stderr redirect", function()
    local file = "/tmp/main.lua"
    local cmd = runners.build("lua", { file = file, root = nil })
    h.assert_contains(cmd, "nvim -l")
    h.assert_contains(cmd, "2>&1")
  end)

  it("sh/bash command shape", function()
    local file = "/tmp/main.sh"
    local sh_cmd = runners.build("sh", { file = file, root = nil })
    local bash_cmd = runners.build("bash", { file = file, root = nil })
    assert.equals(sh_cmd, bash_cmd)
    h.assert_contains(sh_cmd, "bash")
  end)

  it("rust no nested bash -c", function()
    local file = "/tmp/main.rs"
    local cmd = runners.build("rust", { file = file, root = nil })
    h.assert_contains(cmd, "rustc")
    h.assert_not_contains(cmd, "bash -c")
  end)

  it("c unreadable file returns error", function()
    local cmd, err = runners.build("c", { file = "/tmp/does_not_exist_abc.c", root = nil })
    assert.is_nil(cmd)
    assert.is_string(err)
    h.assert_contains(err, "not readable")
  end)

  it("cpp unreadable file returns error", function()
    local cmd, err = runners.build("cpp", { file = "/tmp/does_not_exist_xyz.cpp", root = nil })
    assert.is_nil(cmd)
    assert.is_string(err)
    h.assert_contains(err, "not readable")
  end)

  it("c zig wrapper flags", function()
    local file = "/etc/hosts"
    local cmd = runners.build("c", { file = file, root = nil })
    h.assert_contains(cmd, "zig run")
    h.assert_contains(cmd, "-std=c23")
    h.assert_contains(cmd, "-lc")
    h.assert_not_contains(cmd, "-lc++")
  end)

  it("cpp zig wrapper flags", function()
    local file = "/etc/hosts"
    local cmd = runners.build("cpp", { file = file, root = nil })
    h.assert_contains(cmd, "zig run")
    h.assert_contains(cmd, "-std=c++23")
    h.assert_contains(cmd, "-lc++")
  end)

  it("unknown ft returns nil+error", function()
    local cmd, err = runners.build("javascript", { file = "/tmp/main.js", root = nil })
    assert.is_nil(cmd)
    h.assert_contains(err, "javascript")
  end)
end)
