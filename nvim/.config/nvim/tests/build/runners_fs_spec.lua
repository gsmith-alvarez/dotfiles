package.path = package.path
  .. ";./tests/support/?.lua"
  .. ";./lua/?.lua"
  .. ";./lua/?/init.lua"

local h = require("helpers")
h.ensure_vim_stub()

describe("commands.building.runners (fs)", function()
  local runners
  local tmpdir

  before_each(function()
    package.loaded["commands.building.runners"] = nil
    runners = require("commands.building.runners")
    tmpdir = h.mktmpdir()
  end)

  after_each(function()
    h.rm_tmpdir(tmpdir)
  end)

  it("c: Makefile branch", function()
    h.touch(tmpdir, "Makefile")
    local src = h.touch(tmpdir, "main.c")
    local cmd = runners.build("c", { file = src, root = tmpdir })
    assert.equals("make", cmd)
  end)

  it("c: CMake branch", function()
    h.touch(tmpdir, "CMakeLists.txt")
    local src = h.touch(tmpdir, "main.c")
    local cmd = runners.build("c", { file = src, root = tmpdir })
    assert.equals("cmake --build build", cmd)
  end)

  it("c: Makefile wins over CMake", function()
    h.touch(tmpdir, "CMakeLists.txt")
    h.touch(tmpdir, "Makefile")
    local src = h.touch(tmpdir, "main.c")
    local cmd = runners.build("c", { file = src, root = tmpdir })
    assert.equals("make", cmd)
  end)

  it("c: zig fallback branch", function()
    local src = h.touch(tmpdir, "main.c")
    local cmd = runners.build("c", { file = src, root = tmpdir })
    h.assert_contains(cmd, "zig run")
    h.assert_contains(cmd, "-std=c23")
  end)

  it("cpp: Makefile branch", function()
    h.touch(tmpdir, "Makefile")
    local src = h.touch(tmpdir, "main.cpp")
    local cmd = runners.build("cpp", { file = src, root = tmpdir })
    assert.equals("make", cmd)
  end)

  it("cpp: CMake branch", function()
    h.touch(tmpdir, "CMakeLists.txt")
    local src = h.touch(tmpdir, "main.cpp")
    local cmd = runners.build("cpp", { file = src, root = tmpdir })
    assert.equals("cmake --build build", cmd)
  end)

  it("cpp: zig fallback branch", function()
    local src = h.touch(tmpdir, "main.cpp")
    local cmd = runners.build("cpp", { file = src, root = tmpdir })
    h.assert_contains(cmd, "zig run")
    h.assert_contains(cmd, "-std=c++23")
    h.assert_contains(cmd, "-lc++")
  end)

  it("go.mod -> go run .", function()
    h.touch(tmpdir, "go.mod")
    local cmd = runners.build("go", { file = tmpdir .. "/main.go", root = tmpdir })
    assert.equals("go run .", cmd)
  end)

  it("build.zig -> zig build run", function()
    h.touch(tmpdir, "build.zig")
    local cmd = runners.build("zig", { file = tmpdir .. "/main.zig", root = tmpdir })
    assert.equals("zig build run", cmd)
  end)

  it("Cargo.toml -> cargo run -q", function()
    h.touch(tmpdir, "Cargo.toml")
    local cmd = runners.build("rust", { file = tmpdir .. "/main.rs", root = tmpdir })
    assert.equals("cargo run -q", cmd)
  end)

  it("root=nil never throws for marker-checked ft", function()
    local set = {
      { ft = "go", file = "/tmp/main.go" },
      { ft = "zig", file = "/tmp/main.zig" },
      { ft = "rust", file = "/tmp/main.rs" },
    }
    for _, tc in ipairs(set) do
      local ok, cmd, err = pcall(runners.build, tc.ft, { file = tc.file, root = nil })
      assert.is_true(ok)
      assert.is_string(cmd)
      assert.is_nil(err)
    end
  end)
end)
